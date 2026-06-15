"""
Router for chat-level endpoints: create, list, rename, delete.
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.schemas.schemas import (
    ChatCreate,
    ChatListResponse,
    ChatResponse,
    ChatUpdate,
)
from app.services.chat_service import ChatService

router = APIRouter(prefix="/chats", tags=["Chats"])


def get_chat_service(db: AsyncSession = Depends(get_db)) -> ChatService:
    return ChatService(db)


@router.post("", response_model=ChatResponse, status_code=status.HTTP_201_CREATED)
async def create_chat(
    payload: ChatCreate,
    service: ChatService = Depends(get_chat_service),
) -> ChatResponse:
    """Create a new chat conversation."""
    chat = await service.create_chat(title=payload.title or "New Chat")
    return ChatResponse.model_validate(chat)


@router.get("", response_model=ChatListResponse)
async def list_chats(
    service: ChatService = Depends(get_chat_service),
) -> ChatListResponse:
    """Return all chats ordered by most recently updated."""
    chats = await service.get_all_chats()
    return ChatListResponse(
        chats=[ChatResponse.model_validate(c) for c in chats],
        total=len(chats),
    )


@router.patch("/{chat_id}", response_model=ChatResponse)
async def rename_chat(
    chat_id: str,
    payload: ChatUpdate,
    service: ChatService = Depends(get_chat_service),
) -> ChatResponse:
    """Rename an existing chat."""
    chat = await service.rename_chat(chat_id, payload.title)
    if not chat:
        raise HTTPException(status_code=404, detail="Chat not found")
    return ChatResponse.model_validate(chat)


@router.delete("/{chat_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_chat(
    chat_id: str,
    service: ChatService = Depends(get_chat_service),
) -> None:
    """Delete a chat and all its messages."""
    deleted = await service.delete_chat(chat_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Chat not found")
