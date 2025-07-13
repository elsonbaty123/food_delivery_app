import 'enums.dart';

class Meal {
  final String id;
  final String name;
  final String description;
  final double price;
  final double rating;
  final String imageUrl;
  final List<String> categories;
  final bool isPopular;
  final bool isRecommended;
  final int preparationTime; // in minutes
  final Complexity complexity;
  final Affordability affordability;
  final List<String> ingredients;
  final Map<String, int> nutrition; // e.g., {'calories': 500, 'protein': 25, ...}

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.rating = 0.0,
    required this.imageUrl,
    required this.categories,
    this.isPopular = false,
    this.isRecommended = false,
    this.preparationTime = 30,
    this.complexity = Complexity.Simple,
    this.affordability = Affordability.Affordable,
    List<String>? ingredients,
    Map<String, int>? nutrition,
  })  : ingredients = ingredients ?? [],
        nutrition = nutrition ??
            {
              'calories': 0,
              'protein': 0,
              'carbs': 0,
              'fat': 0,
            };

  // Convert a Meal to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'rating': rating,
      'imageUrl': imageUrl,
      'categories': categories,
      'isPopular': isPopular,
      'isRecommended': isRecommended,
      'preparationTime': preparationTime,
      'complexity': complexity.index,
      'affordability': affordability.index,
      'ingredients': ingredients,
      'nutrition': nutrition,
    };
  }

  // Create a Meal from a Map
  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      categories: List<String>.from(map['categories'] ?? []),
      isPopular: map['isPopular'] ?? false,
      isRecommended: map['isRecommended'] ?? false,
      preparationTime: map['preparationTime'] ?? 30,
      complexity: Complexity.values[map['complexity'] ?? 0],
      affordability: Affordability.values[map['affordability'] ?? 0],
      ingredients: List<String>.from(map['ingredients'] ?? []),
      nutrition: Map<String, int>.from(map['nutrition'] ?? {}),
    );
  }

  // Create a copy of the meal with some updated values
  Meal copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? rating,
    String? imageUrl,
    List<String>? categories,
    bool? isPopular,
    bool? isRecommended,
    int? preparationTime,
    Complexity? complexity,
    Affordability? affordability,
    List<String>? ingredients,
    Map<String, int>? nutrition,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      isPopular: isPopular ?? this.isPopular,
      isRecommended: isRecommended ?? this.isRecommended,
      preparationTime: preparationTime ?? this.preparationTime,
      complexity: complexity ?? this.complexity,
      affordability: affordability ?? this.affordability,
      ingredients: ingredients ?? this.ingredients,
      nutrition: nutrition ?? this.nutrition,
    );
  }
}
