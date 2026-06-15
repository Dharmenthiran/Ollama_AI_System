<div align="center">

# 🤖 Ollama AI Chat System

**A full-stack, locally-hosted AI chat application powered by [Ollama](https://ollama.com/) & DeepSeek-R1**

[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Ollama](https://img.shields.io/badge/AI-Ollama-black?style=for-the-badge&logo=ollama&logoColor=white)](https://ollama.com/)
[![SQLite](https://img.shields.io/badge/Database-SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white)](https://www.sqlite.org/)
[![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)

> Stream AI responses in real-time, manage multi-session conversations, and run everything **100% locally** — no cloud API keys, no data leaving your machine.

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Getting Started](#-getting-started)
  - [1. Ollama Setup](#1-ollama-setup)
  - [2. Backend Setup](#2-backend-setup)
  - [3. Frontend Setup](#3-frontend-setup)
- [API Reference](#-api-reference)
- [Configuration](#%EF%B8%8F-configuration)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🌟 Overview

The **Ollama AI Chat System** is a production-grade, full-stack application that brings large language models to your desktop — entirely offline. It pairs a **FastAPI** asynchronous backend with a **Flutter** cross-platform frontend to deliver a smooth, ChatGPT-like experience running on your own hardware.

The system supports **Server-Sent Events (SSE) streaming**, meaning AI responses are displayed token-by-token as they are generated, giving users near-instantaneous feedback without waiting for the full completion.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Flutter Frontend                    │
│  (Provider • Dio • SSE Stream • flutter_markdown)       │
└────────────────────┬────────────────────────────────────┘
                     │  HTTP / SSE  (port 8000)
┌────────────────────▼────────────────────────────────────┐
│                  FastAPI Backend                         │
│  (Async SQLAlchemy • Pydantic • CORS Middleware)         │
│                                                         │
│   /chats ──► ChatService ──► ChatRepository             │
│   /messages ──► SSE Stream ──► OllamaService            │
│   /models  ──► Ollama REST API Proxy                    │
└───────────────────┬─────────────────────────────────────┘
          ┌─────────▼──────────┐
          │   SQLite (chat.db) │    ◄── Persistent conversation history
          └────────────────────┘
                     │
          ┌─────────▼──────────┐
          │   Ollama (local)   │    ◄── Runs LLM models on your GPU/CPU
          │   port: 11434      │
          └────────────────────┘
```

---

## ✨ Features

| Feature | Description |
|---|---|
| **🔴 Live SSE Streaming** | AI tokens stream in real-time via Server-Sent Events |
| **📂 Multi-Session Chats** | Create, rename, and delete independent conversation threads |
| **📜 Persistent History** | All messages are stored in a local SQLite database |
| **🧠 Dynamic Model Switching** | Select any locally installed Ollama model at runtime |
| **⛔ Stop Generation** | Cancel an in-flight streaming response instantly |
| **📝 Markdown Rendering** | Full markdown, code blocks, and LaTeX math rendering in the UI |
| **🌐 Cross-Platform Frontend** | Flutter targets Android, iOS, Web, Windows, macOS, Linux |
| **🔒 100% Local & Private** | Zero cloud dependencies; all data stays on your machine |
| **🩺 Health Check Endpoint** | `/health` endpoint for monitoring and container probes |

---

## 🛠️ Tech Stack

### Backend
| Technology | Role |
|---|---|
| **FastAPI** | Async REST API framework |
| **Uvicorn** | ASGI server with WebSocket/SSE support |
| **SQLAlchemy (async)** | ORM with `aiosqlite` driver |
| **Pydantic v2** | Request/response schema validation |
| **httpx** | Async HTTP client for Ollama API calls |
| **python-dotenv** | Environment variable management |

### Frontend
| Technology | Role |
|---|---|
| **Flutter / Dart** | Cross-platform UI framework |
| **Provider** | Lightweight state management |
| **Dio + http** | HTTP client & low-level SSE byte streaming |
| **flutter_markdown** | Markdown + LaTeX response rendering |
| **flutter_highlight** | Syntax highlighting in code blocks |
| **Google Fonts** | Beautiful, consistent typography |
| **Shimmer** | Loading skeleton animations |

---

## 📁 Project Structure

```
ollama-ai-system/
├── backend/                        # FastAPI application
│   ├── app/
│   │   ├── core/
│   │   │   ├── config.py           # App settings & env var binding
│   │   │   └── database.py         # Async SQLAlchemy engine & session
│   │   ├── models/
│   │   │   └── models.py           # ORM: Chat & Message entities
│   │   ├── schemas/
│   │   │   └── schemas.py          # Pydantic request/response schemas
│   │   ├── repositories/           # Data access layer (CRUD)
│   │   ├── services/
│   │   │   └── chat_service.py     # Business logic & Ollama integration
│   │   ├── routes/
│   │   │   ├── chats.py            # Chat CRUD endpoints
│   │   │   ├── messages.py         # Message & SSE streaming endpoints
│   │   │   └── models.py           # Available Ollama models endpoint
│   │   └── main.py                 # App factory, CORS, lifespan
│   ├── requirements.txt
│   └── chat.db                     # SQLite database (auto-created)
│
└── frontend/                       # Flutter application
    ├── lib/
    │   ├── core/                   # Constants, theme, API client
    │   ├── data/                   # Repository & data source layer
    │   ├── presentation/
    │   │   ├── screens/
    │   │   │   └── home_screen.dart
    │   │   ├── providers/          # Provider state classes
    │   │   └── widgets/            # Reusable UI components
    │   └── main.dart               # App entry point
    ├── pubspec.yaml
    └── analysis_options.yaml
```

---

## ✅ Prerequisites

Ensure the following are installed before you begin:

- **[Ollama](https://ollama.com/download)** — Local LLM runner
- **Python 3.11+** — Required for the FastAPI backend
- **Flutter SDK 3.2+** — Required for the Flutter frontend
- **Git**

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/<your-username>/ollama-ai-system.git
cd ollama-ai-system
```

---

### 1. Ollama Setup

Install Ollama and pull the model(s) you want to use:

```bash
# Pull a lightweight model (recommended for first run)
ollama pull tinyllama

# Or use DeepSeek-R1 for more advanced reasoning
ollama pull deepseek-r1:7b

# Verify Ollama is running
ollama list
```

Ollama will serve the model at `http://localhost:11434` by default.

---

### 2. Backend Setup

```bash
cd backend

# Create and activate a virtual environment
python -m venv venv

# Windows
venv\Scripts\activate

# macOS / Linux
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start the development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at:
- **Swagger UI:** `http://localhost:8000/docs`
- **ReDoc:** `http://localhost:8000/redoc`
- **Health check:** `http://localhost:8000/health`

> **Optional:** Create a `.env` file in the `backend/` directory to override defaults:
> ```env
> OLLAMA_BASE_URL=http://localhost:11434
> OLLAMA_MODEL=deepseek-r1:7b
> OLLAMA_TIMEOUT=120
> DATABASE_URL=sqlite+aiosqlite:///./chat.db
> ```

---

### 3. Frontend Setup

```bash
cd frontend

# Fetch Flutter dependencies
flutter pub get

# Run on your target platform
flutter run -d windows       # Windows desktop
flutter run -d chrome        # Web browser
flutter run                  # Connected Android/iOS device

# Or specify a backend URL if not running locally
# Update lib/core/constants.dart with your backend IP
```

> **Note:** Ensure the backend is running before launching the frontend. The default API base URL is `http://localhost:8000`.

---

## 📡 API Reference

### Chats

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/chats` | Create a new chat session |
| `GET` | `/chats` | List all chats (ordered by last updated) |
| `PATCH` | `/chats/{chat_id}` | Rename an existing chat |
| `DELETE` | `/chats/{chat_id}` | Delete a chat and all its messages |

### Messages

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/chats/{chat_id}/messages` | Retrieve all messages in a chat |
| `POST` | `/chats/{chat_id}/ask` | Send a message; stream response via SSE |
| `POST` | `/chats/{chat_id}/ask-once` | Send a message; receive full response at once |

### Models

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/models` | List all locally available Ollama models |

### Health

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/health` | Returns `{"status": "ok", "version": "1.0.0"}` |

---

## ⚙️ Configuration

All backend settings are managed via `backend/app/core/config.py` using `pydantic-settings`. You can override any setting using environment variables or a `.env` file:

| Variable | Default | Description |
|---|---|---|
| `DATABASE_URL` | `sqlite+aiosqlite:///./chat.db` | SQLAlchemy async database URL |
| `OLLAMA_BASE_URL` | `http://localhost:11434` | Ollama server address |
| `OLLAMA_MODEL` | `tinyllama` | Default model if none is specified by the client |
| `OLLAMA_TIMEOUT` | `60` | Request timeout in seconds |
| `CORS_ORIGINS` | `["*"]` | Allowed CORS origins (restrict in production) |
| `APP_TITLE` | `Local AI Chat API` | OpenAPI title |
| `APP_VERSION` | `1.0.0` | Application version |

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/your-feature-name`
3. **Commit** your changes: `git commit -m 'feat: add some feature'`
4. **Push** to the branch: `git push origin feature/your-feature-name`
5. **Open** a Pull Request

Please ensure your code follows existing style conventions and includes appropriate documentation.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Made with ❤️ using **FastAPI** · **Flutter** · **Ollama**

*Run powerful AI locally. Own your data. Control your experience.*

</div>
