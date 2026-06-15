"""
Repository for Chat database operations.
"""
from datetime import datetime, timezone
from typing import Optional

from sqlalchemy import delete, select, update
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.models import Chat


class ChatRepository:
    """Handles all database interactions for the Chat model."""

    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def create(self, title: str = "New Chat") -> Chat:
        """Create a new chat."""
        chat = Chat(title=title)
        self.db.add(chat)
        await self.db.flush()
        await self.db.refresh(chat)
        return chat

    async def get_all(self) -> list[Chat]:
        """Return all chats ordered by most recently updated."""
        result = await self.db.execute(
            select(Chat).order_by(Chat.updated_at.desc())
        )
        return list(result.scalars().all())

    async def get_by_id(self, chat_id: str) -> Optional[Chat]:
        """Return a single chat by its ID, with messages eagerly loaded."""
        result = await self.db.execute(
            select(Chat)
            .options(selectinload(Chat.messages))
            .where(Chat.id == chat_id)
        )
        return result.scalar_one_or_none()

    async def update_title(self, chat_id: str, title: str) -> Optional[Chat]:
        """Rename a chat."""
        await self.db.execute(
            update(Chat)
            .where(Chat.id == chat_id)
            .values(title=title, updated_at=datetime.now(timezone.utc))
        )
        return await self.get_by_id(chat_id)

    async def touch(self, chat_id: str) -> None:
        """Update the updated_at timestamp (called when a new message arrives)."""
        await self.db.execute(
            update(Chat)
            .where(Chat.id == chat_id)
            .values(updated_at=datetime.now(timezone.utc))
        )

    async def delete(self, chat_id: str) -> bool:
        """Delete a chat (cascades to messages)."""
        result = await self.db.execute(
            delete(Chat).where(Chat.id == chat_id)
        )
        return result.rowcount > 0
