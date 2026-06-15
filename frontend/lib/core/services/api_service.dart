import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  // ─── Standard REST Endpoints ───────────────────────────────────────────────

  Future<Response> get(String path) async {
    return await _dio.get(path);
  }

  Future<Response> post(String path, dynamic data) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> patch(String path, dynamic data) async {
    return await _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }

  // ─── Streaming (SSE) ───────────────────────────────────────────────────────

  Stream<String> streamChatResponse(String chatId, String content, {String? model}) async* {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.askEndpoint(chatId)}');
    
    final request = http.Request('POST', url);
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'content': content,
      if (model != null) 'model': model,
    });

    final client = http.Client();
    final response = await client.send(request);

    if (response.statusCode != 200) {
      throw Exception('Failed to connect to AI backend: ${response.statusCode}');
    }

    // Process the byte stream
    try {
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        // SSE can send multiple lines in one chunk or partial lines
        final lines = chunk.split('\n');
        for (var line in lines) {
          line = line.trim();
          if (line.startsWith('data: ')) {
            final dataStr = line.substring(6).trim();
            if (dataStr.isEmpty) continue;
            
            try {
              final data = jsonDecode(dataStr);
              if (data.containsKey('token')) {
                yield data['token'] as String;
              } else if (data.containsKey('done') && data['done'] == true) {
                return;
              } else if (data.containsKey('error')) {
                throw Exception(data['error']);
              }
            } catch (e) {
               // Might be partial JSON if the split was unlucky, but typically SSE lines are full
               print('SSE JSON Error: $e in "$dataStr"');
            }
          }
        }
      }
    } catch (e) {
      print('Stream error: $e');
      rethrow;
    } finally {
      client.close();
    }
  }
}
