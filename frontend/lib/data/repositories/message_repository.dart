import '../models/message_model.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/app_constants.dart';

class MessageRepository {
  final ApiService _api = ApiService();

  Future<List<MessageModel>> getMessagesByChat(String chatId) async {
    final response = await _api.get(AppConstants.messagesEndpoint(chatId));
    final List<dynamic> data = response.data['messages'];
    return data.map((json) => MessageModel.fromJson(json)).toList();
  }

  Stream<String> streamAiResponse(String chatId, String content, {String? model}) {
    return _api.streamChatResponse(chatId, content, model: model);
  }

  Future<MessageModel> askOnce(String chatId, String content, {String? model}) async {
    final response = await _api.post('${AppConstants.chatsEndpoint}/$chatId/ask-once', {
      'content': content,
      if (model != null) 'model': model,
    });
    return MessageModel.fromJson(response.data);
  }
}
