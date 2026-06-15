"""
Router for model-level endpoints: listing available Ollama models.
"""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.services.chat_service import ChatService

router = APIRouter(prefix="/models", tags=["Models"])

def get_chat_service(db: AsyncSession = Depends(get_db)) -> ChatService:
    return ChatService(db)

@router.get("")
async def list_models(service: ChatService = Depends(get_chat_service)):
    """List all available models in the local Ollama instance."""
    models = await service.ollama.list_models()
    return {"models": models}
