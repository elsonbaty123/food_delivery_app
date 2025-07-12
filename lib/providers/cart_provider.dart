import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  void addItem(CartItem newItem) {
    final existingItemIndex = _items.indexWhere(
      (item) => item.id == newItem.id,
    );

    if (existingItemIndex >= 0) {
      // Item already exists, update quantity
      final existingItem = _items[existingItemIndex];
      _items[existingItemIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + newItem.quantity,
      );
    } else {
      // Add new item
      _items.add(newItem);
    }
    notifyListeners();
  }

  void removeItem(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }

  void removeSingleItem(String cartItemId) {
    final existingItemIndex = _items.indexWhere((item) => item.id == cartItemId);
    if (existingItemIndex < 0) return;

    final existingItem = _items[existingItemIndex];
    if (existingItem.quantity > 1) {
      // Decrease quantity
      _items[existingItemIndex] = existingItem.copyWith(
        quantity: existingItem.quantity - 1,
      );
    } else {
      // Remove item if quantity is 1
      _items.removeAt(existingItemIndex);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void updateItemQuantity(String cartItemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(cartItemId);
      return;
    }

    final existingItemIndex = _items.indexWhere((item) => item.id == cartItemId);
    if (existingItemIndex < 0) return;

    final existingItem = _items[existingItemIndex];
    _items[existingItemIndex] = existingItem.copyWith(
      quantity: newQuantity,
    );
    notifyListeners();
  }

  void updateItemSpecialInstructions(
    String cartItemId, {
    required List<String> specialInstructions,
  }) {
    final existingItemIndex = _items.indexWhere((item) => item.id == cartItemId);
    if (existingItemIndex < 0) return;

    final existingItem = _items[existingItemIndex];
    _items[existingItemIndex] = existingItem.copyWith(
      specialInstructions: specialInstructions,
    );
    notifyListeners();
  }

  void updateItemAddons(
    String cartItemId, {
    required Map<String, bool> addons,
  }) {
    final existingItemIndex = _items.indexWhere((item) => item.id == cartItemId);
    if (existingItemIndex < 0) return;

    final existingItem = _items[existingItemIndex];
    _items[existingItemIndex] = existingItem.copyWith(
      addons: addons,
    );
    notifyListeners();
  }

  bool isMealInCart(String mealId) {
    return _items.any((item) => item.meal.id == mealId);
  }

  CartItem? getCartItem(String cartItemId) {
    return _items.firstWhereOrNull((item) => item.id == cartItemId);
  }

  void addToCart(Map<String, dynamic> cartItemData) {
    final itemId = cartItemData['id'] as String;
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + (cartItemData['quantity'] as int),
      );
    } else {
      _items.add(
        CartItem(
          id: itemId,
          meal: cartItemData['meal'],
          quantity: cartItemData['quantity'] as int,
        ),
      );
    }
    notifyListeners();
  }
}
