class FieldInfoModel {
  final String id;
  final String userId;
  final String fieldName;
  final List<dynamic> coordinates;
  final Map<String, dynamic> geometry;
  final DateTime createdAt;
  final DateTime updatedAt;

  FieldInfoModel({
    required this.id,
    required this.userId,
    required this.fieldName,
    required this.coordinates,
    required this.geometry,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'field_name': fieldName,
      'coordinates': coordinates,
      'geometry': geometry,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory FieldInfoModel.fromMap(Map<String, dynamic> map) {
    return FieldInfoModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      fieldName: map['field_name'] ?? 'Unnamed Field',
      coordinates: map['coordinates'] ?? [],
      geometry: map['geometry'] ?? {},
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}