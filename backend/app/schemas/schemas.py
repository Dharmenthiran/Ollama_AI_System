"""
Pydantic schemas for request/response validation.
"""
from datetime import datetime
from typing import Optional, Literal

from pydantic import BaseModel, ConfigDict


# ─── Chat Schemas ─────────────────────────────────────────────────────────────

class ChatCreate(BaseModel):
    title: Optional[str] = "New Chat"


class ChatUpdate(BaseModel):
    title: str


class ChatResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    title: str
    created_at: datetime
    updated_at: datetime


class ChatListResponse(BaseModel):
    chats: list[ChatResponse]
    total: int


# ─── Message Schemas ───────────────────────────────────────────────────────────

class MessageCreate(BaseModel):
    content: str


class MessageResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    chat_id: str
    role: str
    content: str
    created_at: datetime


class MessageListResponse(BaseModel):
    messages: list[MessageResponse]
    total: int


# ─── Ollama / Ask Schemas ──────────────────────────────────────────────────────

class AskRequest(BaseModel):
    content: str  # User's new message
    model: Optional[str] = None  # Optional model to use


class OllamaMessage(BaseModel):
    role: Literal["user", "assistant", "system"]
    content: str


class OllamaRequest(BaseModel):
    model: str
    messages: list[OllamaMessage]
    stream: bool = True
