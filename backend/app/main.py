"""
FastAPI application entrypoint.
"""
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.database import create_tables
from app.routes import chats, messages, models


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Initialize the database on startup."""
    await create_tables()
    yield


def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.APP_TITLE,
        version=settings.APP_VERSION,
        description="Local AI Chat API powered by Ollama + DeepSeek-R1",
        lifespan=lifespan,
    )

    # ── CORS ────────────────────────────────────────────────────────────────────
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # ── Routers ─────────────────────────────────────────────────────────────────
    app.include_router(chats.router)
    app.include_router(messages.router)
    app.include_router(models.router)

    # ── Health check ─────────────────────────────────────────────────────────────
    @app.get("/health", tags=["Health"])
    async def health():
        return {"status": "ok", "version": settings.APP_VERSION}

    return app


app = create_app()
