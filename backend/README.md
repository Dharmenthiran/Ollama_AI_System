# 🤖 Local AI Chat — Backend

FastAPI backend for the local AI chat system powered by Ollama + DeepSeek-R1.

---

## Prerequisites

- Python 3.11+
- [Ollama](https://ollama.com) installed and running
- DeepSeek-R1 model pulled

```bash
ollama pull deepseek-r1:7b
```

---

## Setup & Run

```bash
# 1. Create and activate a virtual environment
cd "d:\Olamma Testing1\backend"
python -m venv venv
venv\Scripts\activate       # Windows

# 2. Install dependencies
pip install -r requirements.txt

# 3. Start the backend (auto-creates chat.db on first run)
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at: **http://localhost:8000**
Interactive docs: **http://localhost:8000/docs**

---

## API Reference

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| POST | `/chats` | Create new chat |
| GET | `/chats` | List all chats |
| PATCH | `/chats/{id}` | Rename chat |
| DELETE | `/chats/{id}` | Delete chat + messages |
| GET | `/chats/{id}/messages` | Get messages in chat |
| POST | `/chats/{id}/ask` | Send message, stream AI response (SSE) |

---

## Streaming Protocol

`POST /chats/{id}/ask` returns `text/event-stream`.

Each line is a JSON payload:

```
data: {"token": "Hello"}
data: {"token": " world"}
data: {"done": true, "message_id": "abc-123"}
```

On error:
```
data: {"error": "Ollama not reachable"}
```

---

## Folder Structure

```
backend/
├── app/
│   ├── main.py              # FastAPI app entrypoint
│   ├── core/
│   │   ├── config.py        # Settings
│   │   └── database.py      # Async SQLAlchemy engine
│   ├── models/models.py     # ORM models (Chat, Message)
│   ├── schemas/schemas.py   # Pydantic schemas
│   ├── repositories/        # DB access layer
│   ├── services/            # Business logic + Ollama integration
│   └── routes/              # API route handlers
├── requirements.txt
└── README.md
```
