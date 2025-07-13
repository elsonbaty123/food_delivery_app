import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/orders_provider.dart';

class NewOrdersScreen extends StatelessWidget {
  static const routeName = '/new-orders';

  const NewOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersProvider = Provider.of<OrdersProvider>(context);
    final newOrders = ordersProvider.orders.where((order) => order.status == 'جديد').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات الجديدة'),
      ),
      body: newOrders.isEmpty
          ? const Center(child: Text('لا توجد طلبات جديدة حالياً'))
          : ListView.builder(
              itemCount: newOrders.length,
              itemBuilder: (ctx, index) {
                final order = newOrders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('طلب رقم: ${order.id}'),
                    subtitle: Text('التاريخ: ${order.dateTime.toString().substring(0, 10)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        // TODO: Implement order acceptance logic
                      },
                    ),
                    onTap: () {
                      // TODO: Navigate to order details screen
                    },
                  ),
                );
              },
            ),
    );
  }
}
