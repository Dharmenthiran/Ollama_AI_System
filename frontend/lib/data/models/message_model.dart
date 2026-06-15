enum MessageRole { user, assistant }

class MessageModel {
  final String id;
  final String chatId;
  final MessageRole role;
  final String content;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      chatId: json['chat_id'],
      role: json['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'role': role == MessageRole.user ? 'user' : 'assistant',
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper to create a local temporary message (optimistic UI)
  factory MessageModel.temp({
    required String chatId,
    required MessageRole role,
    required String content,
  }) {
    return MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      role: role,
      content: content,
      createdAt: DateTime.now(),
    );
  }
}
