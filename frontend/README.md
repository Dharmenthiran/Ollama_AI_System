# 📱 Local AI Chat — Frontend

A premium, ChatGPT-style Flutter application for local AI interaction using DeepSeek-R1.

---

## Features

- **MVVM Architecture**: Clean separation of concerns.
- **Provider State Management**: Unified state for chat history and active conversations.
- **SSE Streaming**: Token-by-token rendering for smooth AI responses.
- **Markdown & Code Highlighting**: Full support for rich text and syntax-highlighted code blocks.
- **Responsive Design**: Works on Desktop (sidebar) and Mobile (drawer).
- **Dark Mode**: Premium material design with custom color palette.

---

## Setup & Run

```bash
# 1. Install dependencies
cd "d:\Olamma Testing1\frontend"
flutter pub get

# 2. Run the application
# Ensure the backend is running at http://localhost:8000
flutter run -d windows  # or -d chrome / -d android
```

---

## Dependencies

- `dio` & `http`: Networking and streaming.
- `provider`: State management.
- `flutter_markdown`: Content rendering.
- `flutter_highlight`: Code syntax highlighting.
- `google_fonts`: Typography.

---

## Folder Structure

```
lib/
├── core/
│   ├── constants/       # App-wide constants
│   ├── theme/           # Custom dark theme
│   └── services/        # Low-level API client (SSE)
├── data/
│   ├── models/          # Chat and Message models
│   └── repositories/    # Network abstraction layer
├── presentation/
│   ├── providers/       # Central ChangeNotifier
│   ├── screens/         # Main application pages
│   └── widgets/         # Reusable UI components
└── main.dart            # App entrypoint
```
