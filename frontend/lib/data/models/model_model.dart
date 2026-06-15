class ModelModel {
  final String name;

  ModelModel({required this.name});

  factory ModelModel.fromJson(Map<String, dynamic> json) {
    return ModelModel(name: json['name'] as String);
  }

  // If the backend returns just strings, we handle that in the repository
}
