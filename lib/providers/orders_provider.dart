import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<OrderMeal> meals;
  final DateTime dateTime;
  final String status;
  final String? deliveryAddress;

  OrderItem({
    required this.id,
    required this.amount,
    required this.meals,
    required this.dateTime,
    required this.status,
    this.deliveryAddress,
  });
}

class OrderMeal {
  final String id;
  final String title;
  final int quantity;
  final double price;

  OrderMeal({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class OrdersProvider with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    // TODO: Implement actual API call to fetch orders
    // This is a mock implementation
    _orders = [
      OrderItem(
        id: 'o1',
        amount: 89.99,
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        status: 'تم التوصيل',
        deliveryAddress: '123 شارع الرياض، حي المروج',
        meals: [
          OrderMeal(
            id: 'm1',
            title: 'برجر لحم مشوي',
            quantity: 2,
            price: 44.99,
          ),
        ],
      ),
      OrderItem(
        id: 'o2',
        amount: 129.99,
        dateTime: DateTime.now().subtract(const Duration(days: 3)),
        status: 'تم التوصيل',
        deliveryAddress: '456 طريق الملك فهد، حي الصحافة',
        meals: [
          OrderMeal(
            id: 'm2',
            title: 'بيتزا كبيرة',
            quantity: 1,
            price: 64.99,
          ),
          OrderMeal(
            id: 'm3',
            title: 'كولا',
            quantity: 2,
            price: 10.00,
          ),
        ],
      ),
    ];
    
    notifyListeners();
  }

  Future<void> addOrder(List<OrderMeal> cartMeals, double total, String? addressId) async {
    // TODO: Implement actual API call to place order
    final newOrder = OrderItem(
      id: DateTime.now().toString(),
      amount: total,
      dateTime: DateTime.now(),
      status: 'قيد التجهيز',
      meals: cartMeals,
      deliveryAddress: addressId, // In a real app, you'd fetch the full address using this ID
    );
    
    _orders.insert(0, newOrder);
    notifyListeners();
  }

  Future<OrderItem> getOrderById(String orderId) async {
    // TODO: Implement actual API call to fetch single order
    return _orders.firstWhere((order) => order.id == orderId);
  }
}
