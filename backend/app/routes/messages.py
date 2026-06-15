"""
Router for message-level endpoints: list messages and send/stream messages.
"""
import json
from typing import AsyncGenerator

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.schemas.schemas import AskRequest, MessageListResponse, MessageResponse
from app.services.chat_service import ChatService

router = APIRouter(prefix="/chats", tags=["Messages"])


def get_chat_service(db: AsyncSession = Depends(get_db)) -> ChatService:
    return ChatService(db)


@router.get("/{chat_id}/messages", response_model=MessageListResponse)
async def get_messages(
    chat_id: str,
    service: ChatService = Depends(get_chat_service),
) -> MessageListResponse:
    """Return all messages in a specific chat."""
    chat = await service.get_chat(chat_id)
    if not chat:
        raise HTTPException(status_code=404, detail="Chat not found")

    messages = await service.get_messages(chat_id)
    return MessageListResponse(
        messages=[MessageResponse.model_validate(m) for m in messages],
        total=len(messages),
    )


@router.post("/{chat_id}/ask-once", response_model=MessageResponse)
async def ask_once(
    chat_id: str,
    payload: AskRequest,
    service: ChatService = Depends(get_chat_service),
) -> MessageResponse:
    """
    Send a user message and get the full AI response at once (Non-streaming).
    Faster for small models if streaming overhead is an issue.
    """
    chat = await service.get_chat(chat_id)
    if not chat:
        raise HTTPException(status_code=404, detail="Chat not found")

    # Save user message
    await service.save_user_message(chat_id, payload.content)

    # Get context
    context = await service.build_ollama_context(chat_id)

    # Get full response (passing requested model)
    full_text = await service.ollama.generate_response(context, model=payload.model)

    # Save assistant message
    saved = await service.save_assistant_message(chat_id, full_text)
    await service.db.commit()

    return MessageResponse.model_validate(saved)


@router.post("/{chat_id}/ask")
async def ask(
    chat_id: str,
    payload: AskRequest,
    service: ChatService = Depends(get_chat_service),
) -> StreamingResponse:
    # ...
    chat = await service.get_chat(chat_id)
    if not chat:
        raise HTTPException(status_code=404, detail="Chat not found")

    await service.save_user_message(chat_id, payload.content)
    context = await service.build_ollama_context(chat_id)

    async def event_stream() -> AsyncGenerator[str, None]:
        full_response: list[str] = []
        try:
            print(f"[SSE] Starting stream for chat {chat_id} (Model: {payload.model})")
            async for token in service.ollama.stream_response(context, model=payload.model):
                full_response.append(token)
                yield f"data: {json.dumps({'token': token})}\n\n"

            # Persist the complete assistant message
            full_text = "".join(full_response)
            print(f"[SSE] Persisting response ({len(full_text)} chars)")
            saved = await service.save_assistant_message(chat_id, full_text)
            await service.db.commit()

            # Send done signal with message ID
            yield f"data: {json.dumps({'done': True, 'message_id': saved.id})}\n\n"
            print("[SSE] Stream done sent")

        except Exception as exc:
            print(f"[SSE] Error: {exc}")
            # Send error signal so Flutter can handle it gracefully
            yield f"data: {json.dumps({'error': str(exc)})}\n\n"

    return StreamingResponse(
        event_stream(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
            "Content-Type": "text/event-stream",
        },
    )
