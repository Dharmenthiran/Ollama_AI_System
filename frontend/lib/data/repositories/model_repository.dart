import '../../core/services/api_service.dart';
import '../../core/constants/app_constants.dart';

class ModelRepository {
  final ApiService _api = ApiService();

  Future<List<String>> getAvailableModels() async {
    try {
      print("Fetching models from ${AppConstants.baseUrl}${AppConstants.modelsEndpoint}...");
      final response = await _api.get(AppConstants.modelsEndpoint);
      print("Models response: ${response.data}");
      final data = response.data['models'] as List;
      return data.map((e) => e.toString()).toList();
    } catch (e) {
      print("Error fetching models in Repository: $e");
      rethrow;
    }
  }
}
