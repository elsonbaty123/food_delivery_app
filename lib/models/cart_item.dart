import 'meal.dart';

class CartItem {
  final String id;
  final Meal meal;
  int quantity;
  final List<String>? specialInstructions;
  final Map<String, bool>? addons;

  CartItem({
    required this.id,
    required this.meal,
    this.quantity = 1,
    this.specialInstructions,
    this.addons,
  });

  // Calculate the total price including addons
  double get totalPrice {
    double total = meal.price * quantity;
    // Add any additional costs from addons here if needed
    return total;
  }

  // Convert a CartItem to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meal': meal.toMap(),
      'quantity': quantity,
      'specialInstructions': specialInstructions,
      'addons': addons,
    };
  }

  // Create a CartItem from a Map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      meal: Meal.fromMap(Map<String, dynamic>.from(map['meal'] ?? {})),
      quantity: map['quantity'] ?? 1,
      specialInstructions: map['specialInstructions'] != null
          ? List<String>.from(map['specialInstructions'])
          : null,
      addons: map['addons'] != null
          ? Map<String, bool>.from(map['addons'])
          : null,
    );
  }

  // Create a copy of the cart item with some updated values
  CartItem copyWith({
    String? id,
    Meal? meal,
    int? quantity,
    List<String>? specialInstructions,
    Map<String, bool>? addons,
  }) {
    return CartItem(
      id: id ?? this.id,
      meal: meal ?? this.meal,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      addons: addons ?? this.addons,
    );
  }

  // Override the equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.id == id &&
        other.meal.id == meal.id;
  }

  @override
  int get hashCode => id.hashCode ^ meal.id.hashCode;
}
