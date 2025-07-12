import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  readyForDelivery,
  onTheWay,
  delivered,
  cancelled
}

class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  double get totalPrice => quantity * price;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'],
    );
  }
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String deliveryAddress;
  final String paymentMethod;
  OrderStatus status;
  final String? deliveryPersonId;
  final String? deliveryPersonName;
  final String? deliveryPersonPhone;
  final String? notes;
  final String? cancellationReason;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.orderDate,
    this.deliveryDate,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.status = OrderStatus.pending,
    this.deliveryPersonId,
    this.deliveryPersonName,
    this.deliveryPersonPhone,
    this.notes,
    this.cancellationReason,
    this.updatedAt,
  });

  String get formattedOrderDate => DateFormat('MMM dd, yyyy - hh:mm a').format(orderDate);
  
  String get formattedStatus {
    if (status == OrderStatus.cancelled && cancellationReason != null) {
      return 'Cancelled: $cancellationReason';
    }
    
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.readyForDelivery:
        return 'Ready for Delivery';
      case OrderStatus.onTheWay:
        return 'On the Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.onTheWay:
        return Colors.blue;
      case OrderStatus.readyForDelivery:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.orange[300]!;
      case OrderStatus.confirmed:
        return Colors.blue[300]!;
      case OrderStatus.pending:
        return Colors.grey;

    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'status': status.toString().split('.').last,
      'deliveryPersonId': deliveryPersonId,
      'deliveryPersonName': deliveryPersonName,
      'deliveryPersonPhone': deliveryPersonPhone,
      'notes': notes,
      'cancellationReason': cancellationReason,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    List<OrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    DateTime? orderDate,
    DateTime? deliveryDate,
    String? deliveryAddress,
    String? paymentMethod,
    OrderStatus? status,
    String? deliveryPersonId,
    String? deliveryPersonName,
    String? deliveryPersonPhone,
    String? notes,
    String? cancellationReason,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      deliveryPersonId: deliveryPersonId ?? this.deliveryPersonId,
      deliveryPersonName: deliveryPersonName ?? this.deliveryPersonName,
      deliveryPersonPhone: deliveryPersonPhone ?? this.deliveryPersonPhone,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: List<OrderItem>.from(
          (map['items'] ?? []).map((item) => OrderItem.fromMap(item))),
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      orderDate: DateTime.parse(map['orderDate'] ?? DateTime.now().toIso8601String()),
      deliveryDate: map['deliveryDate'] != null 
          ? DateTime.parse(map['deliveryDate']) 
          : null,
      deliveryAddress: map['deliveryAddress'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      status: map['status'] != null
          ? OrderStatus.values.firstWhere(
              (e) => e.toString() == 'OrderStatus.${map['status']}',
              orElse: () => OrderStatus.pending,
            )
          : OrderStatus.pending,
      deliveryPersonId: map['deliveryPersonId'],
      deliveryPersonName: map['deliveryPersonName'],
      deliveryPersonPhone: map['deliveryPersonPhone'],
      notes: map['notes'],
      cancellationReason: map['cancellationReason'],
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}
