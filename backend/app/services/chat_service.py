"""
Chat service — orchestrates chat and message business logic.
"""
from typing import Optional

from sqlalchemy.ext.asyncio import AsyncSession

from app.models.models import Chat, Message
from app.repositories.chat_repository import ChatRepository
from app.repositories.message_repository import MessageRepository
from app.schemas.schemas import OllamaMessage
from app.services.ollama_service import OllamaService


class ChatService:
    """Business logic layer sitting between routes and repositories."""

    def __init__(self, db: AsyncSession) -> None:
        self.db = db
        self.chat_repo = ChatRepository(db)
        self.message_repo = MessageRepository(db)
        self.ollama = OllamaService()

    # ── Chat operations ────────────────────────────────────────────────────────

    async def create_chat(self, title: str = "New Chat") -> Chat:
        return await self.chat_repo.create(title=title)

    async def get_all_chats(self) -> list[Chat]:
        return await self.chat_repo.get_all()

    async def get_chat(self, chat_id: str) -> Optional[Chat]:
        return await self.chat_repo.get_by_id(chat_id)

    async def rename_chat(self, chat_id: str, title: str) -> Optional[Chat]:
        return await self.chat_repo.update_title(chat_id, title)

    async def delete_chat(self, chat_id: str) -> bool:
        return await self.chat_repo.delete(chat_id)

    # ── Message operations ─────────────────────────────────────────────────────

    async def get_messages(self, chat_id: str) -> list[Message]:
        return await self.message_repo.get_by_chat(chat_id)

    async def save_user_message(self, chat_id: str, content: str) -> Message:
        """Persist user message and auto-title the chat from first message."""
        chat = await self.chat_repo.get_by_id(chat_id)

        # Auto-generate title from the user's first message
        if chat and chat.title in ("New Chat", ""):
            title = content[:60].strip()
            if len(content) > 60:
                title += "…"
            await self.chat_repo.update_title(chat_id, title)

        message = await self.message_repo.create(chat_id, "user", content)
        await self.chat_repo.touch(chat_id)
        return message

    async def save_assistant_message(self, chat_id: str, content: str) -> Message:
        """Persist the fully assembled assistant response."""
        message = await self.message_repo.create(chat_id, "assistant", content)
        await self.chat_repo.touch(chat_id)
        return message

    async def build_ollama_context(self, chat_id: str) -> list[OllamaMessage]:
        """
        Build the full conversation history to send to Ollama,
        so it maintains context across turns.
        """
        # Stronger system prompt to force the model to prioritize history relevance
        system_prompt = (
            "You are a helpful AI assistant. "
            "IMPORTANT: Always read the conversation history below carefully. "
            "Your response must be directly related to the previous messages and follow the flow of the conversation. "
            "If the user asks a follow-up question, use the context provided in earlier messages to answer accurately."
        )
        
        messages = await self.message_repo.get_by_chat(chat_id)
        
        context = [OllamaMessage(role="system", content=system_prompt)]
        context.extend([OllamaMessage(role=m.role, content=m.content) for m in messages])
        return context
