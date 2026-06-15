import '../models/chat_model.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/app_constants.dart';

class ChatRepository {
  final ApiService _api = ApiService();

  Future<List<ChatModel>> getAllChats() async {
    final response = await _api.get(AppConstants.chatsEndpoint);
    final List<dynamic> data = response.data['chats'];
    return data.map((json) => ChatModel.fromJson(json)).toList();
  }

  Future<ChatModel> createChat({String? title}) async {
    final response = await _api.post(AppConstants.chatsEndpoint, {'title': title});
    return ChatModel.fromJson(response.data);
  }

  Future<ChatModel> renameChat(String chatId, String newTitle) async {
    final response = await _api.patch('${AppConstants.chatsEndpoint}/$chatId', {'title': newTitle});
    return ChatModel.fromJson(response.data);
  }

  Future<void> deleteChat(String chatId) async {
    await _api.delete('${AppConstants.chatsEndpoint}/$chatId');
  }
}
