"""
Ollama service — handles streaming communication with the local Ollama API.
"""
import json
from typing import AsyncGenerator, Optional

import httpx

from app.core.config import settings
from app.schemas.schemas import OllamaMessage


class OllamaService:
    """Communicates with the local Ollama HTTP API and streams responses."""

    def __init__(self) -> None:
        self.base_url = settings.OLLAMA_BASE_URL
        self.model = settings.OLLAMA_MODEL
        self.timeout = settings.OLLAMA_TIMEOUT

    async def stream_response(
        self, messages: list[OllamaMessage], model: Optional[str] = None
    ) -> AsyncGenerator[str, None]:
        target_model = model or self.model
        payload = {
            "model": target_model,
            "messages": [{"role": m.role, "content": m.content} for m in messages],
            "stream": True,
        }

        print(f"[Ollama] Requesting {target_model}...")
        
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            try:
                async with client.stream(
                    "POST",
                    f"{self.base_url}/api/chat",
                    json=payload,
                ) as response:
                    # ... (rest of the logic remains the same, just use target_model for logging)
                    if response.status_code != 200:
                        error_text = await response.aread()
                        print(f"[Ollama] Error {response.status_code}: {error_text}")
                        yield f"Error from Ollama: {response.status_code}"
                        return

                    async for line in response.aiter_lines():
                        if line:
                            try:
                                data = json.loads(line)
                                token = data.get("message", {}).get("content", "")
                                if token:
                                    print(f"[{target_model}] {token!r}")
                                    yield token
                                if data.get("done", False):
                                    break
                            except Exception as e:
                                print(f"[Ollama] Parse error: {e}")
            except Exception as e:
                print(f"[Ollama] Connection error: {e}")
                yield f"Connection Error: {e}"

    async def generate_response(
        self, messages: list[OllamaMessage], model: Optional[str] = None
    ) -> str:
        """
        Get a full response from Ollama in one go (non-streaming).
        """
        target_model = model or self.model
        payload = {
            "model": target_model,
            "messages": [{"role": m.role, "content": m.content} for m in messages],
            "stream": False,
        }
        
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            response = await client.post(
                f"{self.base_url}/api/chat",
                json=payload,
            )
            response.raise_for_status()
            data = response.json()
            return data.get("message", {}).get("content", "")

    async def list_models(self) -> list[str]:
        """Fetch list of available model names from Ollama."""
        try:
            async with httpx.AsyncClient(timeout=5) as client:
                response = await client.get(f"{self.base_url}/api/tags")
                if response.status_code == 200:
                    data = response.json()
                    return [m["name"] for m in data.get("models", [])]
                return []
        except Exception as e:
            print(f"[Ollama] Error listing models: {e}")
            return []

    async def check_health(self) -> bool:
        """Check whether Ollama is reachable."""
        try:
            async with httpx.AsyncClient(timeout=5) as client:
                response = await client.get(f"{self.base_url}/api/tags")
                return response.status_code == 200
        except Exception:
            return False
