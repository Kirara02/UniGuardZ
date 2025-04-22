class PendingFormsModel {
  final int id;
  final String partitionKey;
  final String timestamp;
  final double? latitude;
  final double? longitude;
  final String description;
  final int category;
  final String formId;
  final Map<String, dynamic> data;

  PendingFormsModel({
    required this.id,
    required this.partitionKey,
    required this.timestamp,
    this.latitude,
    this.longitude,
    required this.description,
    required this.category,
    required this.formId,
    required this.data,
  });

  // Convert the model to a Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partitionKey': partitionKey,
      'timestamp': timestamp,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'category': category,
      'formId': formId,
      'data': data, // Map<String, dynamic> is already serializable
    };
  }

  // Create an instance from a Map<String, dynamic>
  factory PendingFormsModel.fromJson(Map<String, dynamic> json) {
    return PendingFormsModel(
      id: json['id'] as int,
      partitionKey: json['partitionKey'] as String,
      timestamp: json['timestamp'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      description: json['description'] as String,
      category: json['category'] as int,
      formId: json['formId'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }
}
