import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/order_model.dart';
import '../services/order_notification_helper.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  WebSocketChannel? _channel;
  StreamSubscription? _orderUpdatesSubscription;
  final String _wsUrl = 'wss://your-api-url.com/ws/orders'; // Replace with your WebSocket URL
  final OrderNotificationHelper _notificationHelper = OrderNotificationHelper();

  // Getters
  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get order by ID with real-time updates
  Order? getOrderById(String orderId, {bool subscribeToUpdates = true}) {
    try {
      final order = _orders.firstWhere((order) => order.id == orderId);
      
      // Subscribe to real-time updates for this order
      if (subscribeToUpdates) {
        _channel?.sink.add(jsonEncode({
          'type': 'subscribe',
          'orderId': orderId,
        }));
      }
      
      return order;
    } catch (e) {
      // If order not found, try to fetch it
      _fetchOrderDetails(orderId);
      return null;
    }
  }
  
  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus, {String? cancellationReason}) async {
    try {
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        // Save old status for comparison
        final oldStatus = _orders[orderIndex].status;
        
        // Update the order
        _orders[orderIndex] = _orders[orderIndex].copyWith(
          status: newStatus,
          cancellationReason: cancellationReason,
          updatedAt: DateTime.now(),
        );
        
        // Notify listeners about the update
        notifyListeners();
        
        // Send notification if status changed
        if (oldStatus != newStatus) {
          await _notificationHelper.handleOrderStatusChange(_orders[orderIndex]);
        }
        
        // In a real app, you would also update the server
        _channel?.sink.add(jsonEncode({
          'type': 'status_update',
          'orderId': orderId,
          'status': newStatus.toString().split('.').last,
          'cancellationReason': cancellationReason,
        }));
        
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('خطأ في تحديث حالة الطلب: $e');
      return false;
    }
  }
  
  // Unsubscribe from order updates
  void unsubscribeFromOrder(String orderId) {
    _channel?.sink.add(jsonEncode({
      'type': 'unsubscribe',
      'orderId': orderId,
    }));
  }

  // Get orders by status
  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Get active orders (all orders except delivered and cancelled)
  List<Order> get activeOrders {
    return _orders
        .where((order) =>
            order.status != OrderStatus.delivered &&
            order.status != OrderStatus.cancelled)
        .toList();
  }

  // Get past orders (delivered or cancelled)
  List<Order> get pastOrders {
    return _orders
        .where((order) =>
            order.status == OrderStatus.delivered ||
            order.status == OrderStatus.cancelled)
        .toList();
  }

  // Cancel an order
  Future<bool> cancelOrder(String orderId, {String reason = 'تم الإلغاء من قبل المستخدم'}) async {
    try {
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        // Update local state immediately for better UX
        _orders[orderIndex] = _orders[orderIndex].copyWith(
          status: OrderStatus.cancelled,
          updatedAt: DateTime.now(),
          cancellationReason: reason,
        );
        
        notifyListeners();
        
        // Send cancellation notification
        await _notificationHelper.handleOrderStatusChange(_orders[orderIndex]);
        
        // Notify the server about the cancellation
        _channel?.sink.add(jsonEncode({
          'type': 'order_cancelled',
          'orderId': orderId,
          'reason': reason,
        }));
        
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));
        
        return true;
      }
      return false;
    } catch (e) {
      _error = 'فشل في إلغاء الطلب';
      debugPrint('خطأ في إلغاء الطلب: $e');
      notifyListeners();
      return false;
    }
  }

  // Initialize WebSocket connection for real-time updates
  void _initWebSocket(String userId) {
    try {
      // Close existing connection if any
      _channel?.sink.close();
      _orderUpdatesSubscription?.cancel();

      // Connect to WebSocket
      _channel = WebSocketChannel.connect(
        Uri.parse('$_wsUrl?userId=$userId'),
      );

      // Listen for order updates
      _orderUpdatesSubscription = _channel!.stream.listen(
        (data) {
          try {
            final update = jsonDecode(data);
            _handleOrderUpdate(update);
          } catch (e) {
            debugPrint('Error processing order update: $e');
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          // Attempt to reconnect after a delay
          Future.delayed(const Duration(seconds: 5), () => _initWebSocket(userId));
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          // Attempt to reconnect if the connection closes
          Future.delayed(const Duration(seconds: 5), () => _initWebSocket(userId));
        },
      );
    } catch (e) {
      debugPrint('Error initializing WebSocket: $e');
    }
  }

  // Handle incoming order updates
  void _handleOrderUpdate(Map<String, dynamic> update) {
    final orderId = update['orderId'];
    final status = OrderStatus.values.firstWhere(
      (s) => s.toString() == 'OrderStatus.${update['status']}',
      orElse: () => OrderStatus.pending,
    );
    
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    
    if (orderIndex != -1) {
      // Update existing order
      _orders[orderIndex] = _orders[orderIndex].copyWith(
        status: status,
        updatedAt: DateTime.now(),
        // Update other fields as needed
      );
      notifyListeners();
    } else if (status != OrderStatus.delivered && status != OrderStatus.cancelled) {
      // This is a new active order, we'll fetch the full order details
      // In a real app, you would fetch the full order details from your API
      _fetchOrderDetails(orderId);
    }
  }

  // Fetch order details by ID
  Future<void> _fetchOrderDetails(String orderId) async {
    try {
      // TODO: Replace with actual API call to get order details
      await Future.delayed(const Duration(seconds: 1));
      // Mock data for testing
      final newOrder = Order(
        id: orderId,
        userId: 'current_user_id',
        items: [], // Add actual items
        status: OrderStatus.pending,
        total: 0.0,
        subtotal: 0.0,
        deliveryFee: 0.0,
        deliveryAddress: 'Sample Address',
        paymentMethod: 'Credit Card',
        orderDate: DateTime.now(),
      );
      
      _orders.add(newOrder);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching order details: $e');
    }
  }

  // Initialize the provider
  Future<void> initialize(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize WebSocket connection
      _initWebSocket(userId);
      
      // Initialize notifications
      await _notificationHelper.init();
      
      // Load initial orders
      await fetchOrders(userId);
    } catch (e) {
      _error = 'فشل في تهيئة الطلبات';
      debugPrint('Error initializing OrderProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch orders from API
  Future<void> fetchOrders(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data for testing
      _orders = [
        Order(
          id: '1',
          userId: userId,
          items: [
            OrderItem(
              id: '1',
              name: 'Delicious Pasta',
              quantity: 2,
              price: 12.99,
              imageUrl: 'assets/images/pasta.jpg',
            ),
          ],
          subtotal: 25.98,
          deliveryFee: 2.99,
          total: 28.97,
          orderDate: DateTime.now().subtract(const Duration(hours: 2)),
          deliveryDate: DateTime.now().add(const Duration(hours: 1)),
          deliveryAddress: '123 Main St, City, Country',
          paymentMethod: 'Credit Card',
          status: OrderStatus.onTheWay,
          deliveryPersonName: 'John Doe',
          deliveryPersonPhone: '+1234567890',
        ),
        // Add more mock orders as needed
      ];
      
      _error = null;
    } catch (e) {
      _error = 'Failed to load orders: $e';
      if (kDebugMode) {
        print('Error fetching orders: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new order
  Future<bool> createOrder(Order order) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Add the new order to the beginning of the list
      _orders.insert(0, order);
      
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to create order: $e';
      if (kDebugMode) {
        print('Error creating order: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
