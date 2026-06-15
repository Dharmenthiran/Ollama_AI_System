import 'package:flutter/material.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/message_repository.dart';
import '../../data/repositories/model_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepo = ChatRepository();
  final MessageRepository _messageRepo = MessageRepository();

  // ── State ──────────────────────────────────────────────────────────────────
  
  List<ChatModel> _chats = [];
  List<ChatModel> get chats => _chats;

  ChatModel? _selectedChat;
  ChatModel? get selectedChat => _selectedChat;

  List<MessageModel> _messages = [];
  List<MessageModel> get messages => _messages;

  bool _isLoadingChats = false;
  bool get isLoadingChats => _isLoadingChats;

  bool _isLoadingMessages = false;
  bool get isLoadingMessages => _isLoadingMessages;

  bool _isAIGenerating = false;
  bool get isAIGenerating => _isAIGenerating;

  String _currentTypingContent = "";
  String get currentTypingContent => _currentTypingContent;

  bool _isStopRequested = false;
  bool get isStopRequested => _isStopRequested;

  List<String> _availableModels = [];
  List<String> get availableModels => _availableModels;

  String? _selectedModel;
  String? get selectedModel => _selectedModel;

  final ModelRepository _modelRepo = ModelRepository();

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> loadModels() async {
    try {
      _availableModels = await _modelRepo.getAvailableModels();
      if (_availableModels.isNotEmpty && _selectedModel == null) {
        _selectedModel = _availableModels.first;
      }
      notifyListeners();
    } catch (e) {
      print("Error loading models: $e");
    }
  }

  void setSelectedModel(String model) {
    _selectedModel = model;
    notifyListeners();
  }

  Future<void> refreshModels() async {
    await loadModels();
  }

  void stopGenerating() {
    _isStopRequested = true;
    notifyListeners();
  }

  Future<void> loadChats() async {
    _isLoadingChats = true;
    notifyListeners();
    try {
      _chats = await _chatRepo.getAllChats();
      // Also load models on first chat load
      if (_availableModels.isEmpty) await loadModels();
    } finally {
      _isLoadingChats = false;
      notifyListeners();
    }
  }

  Future<void> selectChat(ChatModel chat) async {
    _selectedChat = chat;
    _messages = [];
    _isLoadingMessages = true;
    notifyListeners();

    try {
      _messages = await _messageRepo.getMessagesByChat(chat.id);
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<void> createNewChat() async {
    final newChat = await _chatRepo.createChat();
    _chats.insert(0, newChat);
    await selectChat(newChat);
  }

  Future<void> deleteChat(String chatId) async {
    await _chatRepo.deleteChat(chatId);
    _chats.removeWhere((c) => c.id == chatId);
    if (_selectedChat?.id == chatId) {
      _selectedChat = null;
      _messages = [];
    }
    notifyListeners();
  }

  Future<void> renameChat(String chatId, String newTitle) async {
    final updated = await _chatRepo.renameChat(chatId, newTitle);
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = updated;
    }
    if (_selectedChat?.id == chatId) {
      _selectedChat = updated;
    }
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (_selectedChat == null || content.trim().isEmpty) return;

    final chatId = _selectedChat!.id;

    // 1. Add User Message (Optimistic)
    final userMsg = MessageModel.temp(
      chatId: chatId,
      role: MessageRole.user,
      content: content,
    );
    _messages.add(userMsg);
    
    // Auto-update sidebar title if it was "New Chat"
    if (_selectedChat!.title == "New Chat") {
       _chats = _chats.map((c) {
         if (c.id == chatId) {
           return c.copyWith(title: content.length > 50 ? "${content.substring(0, 50)}..." : content);
         }
         return c;
       }).toList();
    }

    _isAIGenerating = true;
    _isStopRequested = false;
    _currentTypingContent = "";
    notifyListeners();

    try {
      // 2. Start Streaming AI Response (ChatGPT-style)
      print("Starting to listen to AI stream for real-time response (Model: $_selectedModel)...");
      final stream = _messageRepo.streamAiResponse(chatId, content, model: _selectedModel);
      
      await for (final token in stream) {
        if (_isStopRequested) {
          print("AI Generation stopped by user.");
          break; 
        }
        _currentTypingContent += token;
        notifyListeners(); // Refresh UI for every single token!
      }
      
      print("Stream complete or stopped.");

      // 3. Finalize: Refresh to get the saved message with DB ID
      _messages = await _messageRepo.getMessagesByChat(chatId);
      await loadChats();
    } catch (e) {
      print("Chat Error in Provider: $e");
      _messages.add(MessageModel.temp(
        chatId: chatId,
        role: MessageRole.assistant,
        content: "Error: $e",
      ));
    } finally {
      _isAIGenerating = false;
      _isStopRequested = false;
      _currentTypingContent = "";
      notifyListeners();
    }
  }
}
