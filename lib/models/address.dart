import 'address_type.dart';

class Address {
  final String id;
  final String title;
  final String fullAddress;
  final String buildingNumber;
  final String floor;
  final String apartment;
  final String additionalDirections;
  final bool isDefault;
  final AddressType type;

  Address({
    required this.id,
    required this.title,
    required this.fullAddress,
    this.buildingNumber = '',
    this.floor = '',
    this.apartment = '',
    this.additionalDirections = '',
    this.isDefault = false,
    this.type = AddressType.other,
  });

  // Create a copyWith method for easy updates
  Address copyWith({
    String? id,
    String? title,
    String? fullAddress,
    String? buildingNumber,
    String? floor,
    String? apartment,
    String? additionalDirections,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      title: title ?? this.title,
      fullAddress: fullAddress ?? this.fullAddress,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      floor: floor ?? this.floor,
      apartment: apartment ?? this.apartment,
      additionalDirections: additionalDirections ?? this.additionalDirections,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // Convert Address to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'fullAddress': fullAddress,
      'buildingNumber': buildingNumber,
      'floor': floor,
      'apartment': apartment,
      'additionalDirections': additionalDirections,
      'isDefault': isDefault,
      'type': type.toString().split('.').last,
    };
  }

  // Create Address from Map
  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      fullAddress: map['fullAddress'] ?? '',
      buildingNumber: map['buildingNumber'] ?? '',
      floor: map['floor'] ?? '',
      apartment: map['apartment'] ?? '',
      additionalDirections: map['additionalDirections'] ?? '',
      isDefault: map['isDefault'] ?? false,
      type: map['type'] != null 
          ? AddressType.values.firstWhere(
              (e) => e.toString() == 'AddressType.${map['type']}',
              orElse: () => AddressType.other,
            )
          : AddressType.other,
    );
  }
}
