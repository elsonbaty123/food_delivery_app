class LocationModel {
  final String id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final String? address;
  final bool isCurrent;
  final DateTime timestamp;

  LocationModel({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    this.isCurrent = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert LocationModel to Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'isCurrent': isCurrent,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create LocationModel from Map
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      address: json['address'],
      isCurrent: json['isCurrent'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // Create a copy of LocationModel with some fields updated
  LocationModel copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    bool? isCurrent,
    DateTime? timestamp,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      isCurrent: isCurrent ?? this.isCurrent,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
