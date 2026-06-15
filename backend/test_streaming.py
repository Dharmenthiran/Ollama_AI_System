import json
import requests
from flask import Flask, Response, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

OLLAMA_URL = "http://localhost:11434/api/chat"

@app.route("/test-ask", methods=["POST"])
def ask():
    user_input = request.json.get("content", "hi")
    
    def generate():
        payload = {
            "model": "deepseek-r1:7b",
            "messages": [{"role": "user", "content": user_input}],
            "stream": True
        }
        print(f"Sending to Ollama: {payload}")
        
        try:
            r = requests.post(OLLAMA_URL, json=payload, stream=True, timeout=120)
            for line in r.iter_lines():
                if line:
                    data = json.loads(line)
                    token = data.get("message", {}).get("content", "")
                    if token:
                        print(f"Token: {token}")
                        yield f"data: {json.dumps({'token': token})}\n\n"
                    if data.get("done"):
                        yield f"data: {json.dumps({'done': True})}\n\n"
                        break
        except Exception as e:
            print(f"Error: {e}")
            yield f"data: {json.dumps({'error': str(e)})}\n\n"

    return Response(generate(), mimetype="text/event-stream")

if __name__ == "__main__":
    app.run(port=8001, debug=True)
