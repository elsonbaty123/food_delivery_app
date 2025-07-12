import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String icon;
  final String imageUrl;
  final int itemCount;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    this.imageUrl = '',
    this.itemCount = 0,
    Color? color,
  }) : color = color ?? _generateColorFromId(id);

  // Convert a Category to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'imageUrl': imageUrl,
      'itemCount': itemCount,
      // ignore: deprecated_member_use
      'color': color.value,
    };
  }

  // Create a Category from a Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      itemCount: map['itemCount'] ?? 0,
      color: Color(map['color'] ?? 0xFF000000),
    );
  }

  // Helper method to generate a consistent color from an ID
  static Color _generateColorFromId(String id) {
    // Simple hash function to generate a color from the ID
    var hash = 0;
    for (var i = 0; i < id.length; i++) {
      hash = id.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    // Generate a color with consistent hue but controlled saturation and lightness
    final hue = (hash.abs() % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.8).toColor();
  }

  // Create a copy of the category with some updated values
  Category copyWith({
    String? id,
    String? name,
    String? icon,
    String? imageUrl,
    int? itemCount,
    Color? color,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      itemCount: itemCount ?? this.itemCount,
      color: color ?? this.color,
    );
  }
}
