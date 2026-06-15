"""
Repository for Message database operations.
"""
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.models import Message


class MessageRepository:
    """Handles all database interactions for the Message model."""

    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def create(self, chat_id: str, role: str, content: str) -> Message:
        """Create and persist a new message."""
        message = Message(chat_id=chat_id, role=role, content=content)
        self.db.add(message)
        await self.db.flush()
        await self.db.refresh(message)
        return message

    async def get_by_chat(self, chat_id: str) -> list[Message]:
        """Return all messages for a chat, ordered chronologically."""
        result = await self.db.execute(
            select(Message)
            .where(Message.chat_id == chat_id)
            .order_by(Message.created_at.asc())
        )
        return list(result.scalars().all())
