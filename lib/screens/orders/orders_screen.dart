import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Listen to tab changes to load the appropriate orders
    _tabController.addListener(_handleTabChange);
    
    // Initialize the order provider when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id ?? '';
      if (userId.isNotEmpty) {
        Provider.of<OrderProvider>(context, listen: false).initialize(userId);
      }
      _loadOrders();
    });
  }
  

  
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        // This will trigger a rebuild with the correct tab's data
      });
    }
  }

  Future<void> _loadOrders() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final userId = authProvider.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      // Handle case where user is not logged in
      return;
    }
    
    await orderProvider.fetchOrders(userId);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
          labelColor: Theme.of(context).colorScheme.primary,
          indicatorColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Orders Tab
          Consumer<OrderProvider>(
            builder: (context, orderProvider, _) {
              // Sort active orders by date (newest first)
              final activeOrders = orderProvider.activeOrders
                ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
              if (orderProvider.isLoading && orderProvider.activeOrders.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (orderProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading orders',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadOrders,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (activeOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No active orders',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your active orders will appear here',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _loadOrders,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activeOrders.length,
                  itemBuilder: (context, index) {
                    final order = activeOrders[index];
                    // Subscribe to real-time updates for this order
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      orderProvider.getOrderById(order.id);
                    });
                    return _buildOrderCard(context, order);
                  },
                ),
              );
            },
          ),
          
          // Order History Tab
          Consumer<OrderProvider>(
            builder: (context, orderProvider, _) {
              // Sort past orders by date (newest first)
              final pastOrders = orderProvider.pastOrders
                ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
              if (orderProvider.isLoading && orderProvider.pastOrders.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (orderProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading order history',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadOrders,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (pastOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No order history',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your past orders will appear here',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _loadOrders,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pastOrders.length,
                  itemBuilder: (context, index) {
                    final order = pastOrders[index];
                    return _buildOrderCard(context, order);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

    Widget _buildOrderCard(BuildContext context, Order order) {
    // Subscribe to real-time updates for this order
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    orderProvider.getOrderById(order.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Navigate to order details screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 6).toUpperCase()}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: order.statusColor.withAlpha((255 * 0.1).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.formattedStatus,
                      style: TextStyle(
                        color: order.statusColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Order items preview
              if (order.items.isNotEmpty) ...[
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: order.items.length,
                    itemBuilder: (context, index) {
                      final item = order.items[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            // Item image or icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                image: item.imageUrl != null
                                    ? DecorationImage(
                                        image: AssetImage(item.imageUrl!), // Use NetworkImage for real API
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: item.imageUrl == null
                                  ? const Icon(Icons.fastfood, color: Colors.grey, size: 30)
                                  : null,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (order.status != OrderStatus.delivered &&
                      order.status != OrderStatus.cancelled) ...[
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Track order on map
                      },
                      child: const Text('Track Order'),
                    ),
                    if (order.status == OrderStatus.pending ||
                        order.status == OrderStatus.confirmed ||
                        order.status == OrderStatus.preparing) ...[
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          _showCancelOrderDialog(context, order);
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCancelOrderDialog(BuildContext context, Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final success = await orderProvider.cancelOrder(
        order.id,
        reason: 'Cancelled by user',
      );
      
      if (success) {
        // Update the order status locally for immediate feedback
        orderProvider.updateOrderStatus(
          order.id,
          OrderStatus.cancelled,
          cancellationReason: 'Cancelled by user',
        );
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Order cancelled' : 'Failed to cancel order',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id.substring(0, 6).toUpperCase()}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatusStep(
                      context,
                      title: 'Order Placed',
                      isActive: true,
                      isCompleted: true,
                    ),
                    _buildStatusStep(
                      context,
                      title: 'Order Confirmed',
                      isActive: order.status.index >= OrderStatus.confirmed.index,
                      isCompleted: order.status.index > OrderStatus.confirmed.index,
                    ),
                    _buildStatusStep(
                      context,
                      title: 'Preparing',
                      isActive: order.status.index >= OrderStatus.preparing.index,
                      isCompleted: order.status.index > OrderStatus.preparing.index,
                    ),
                    _buildStatusStep(
                      context,
                      title: 'Ready for Delivery',
                      isActive: order.status.index >= OrderStatus.readyForDelivery.index,
                      isCompleted: order.status.index > OrderStatus.readyForDelivery.index,
                    ),
                    _buildStatusStep(
                      context,
                      title: 'On the Way',
                      isActive: order.status.index >= OrderStatus.onTheWay.index,
                      isCompleted: order.status.index > OrderStatus.onTheWay.index,
                    ),
                    _buildStatusStep(
                      context,
                      title: 'Delivered',
                      isActive: order.status == OrderStatus.delivered,
                      isCompleted: false,
                    ),
                    if (order.status == OrderStatus.cancelled) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Order was cancelled',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Order items
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Items',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.items.length,
                      separatorBuilder: (context, index) => const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final item = order.items[index];
                        return Row(
                          children: [
                            // Item image
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                image: item.imageUrl != null
                                    ? DecorationImage(
                                        image: AssetImage(item.imageUrl!), // Use NetworkImage for real API
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: item.imageUrl == null
                                  ? const Icon(Icons.fastfood, color: Colors.grey, size: 30)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            // Item details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qty: ${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            // Item total
                            Text(
                              '\$${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Order summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Delivery Fee', '\$${order.deliveryFee.toStringAsFixed(2)}'),
                    const Divider(height: 24),
                    _buildSummaryRow(
                      'Total',
                      '\$${order.total.toStringAsFixed(2)}',
                      isBold: true,
                      textColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Delivery info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.location_on, 'Address', order.deliveryAddress),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.payment, 'Payment Method', order.paymentMethod),
                    if (order.deliveryPersonName != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.person, 'Delivery Person', order.deliveryPersonName!),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.phone, 'Contact', order.deliveryPersonPhone ?? 'N/A'),
                    ],
                  ],
                ),
              ),
            ),
            
            // Order notes if available
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(order.notes!),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Action buttons
            if (order.status == OrderStatus.pending ||
                order.status == OrderStatus.confirmed)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Implement contact support
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text('Contact Support'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Track order on map
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Track Order'),
                    ),
                  ),
                ],
              ),
            
            if (order.status == OrderStatus.delivered ||
                order.status == OrderStatus.cancelled) ...[
              ElevatedButton(
                onPressed: () {
                  // TODO: Reorder functionality
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Reorder'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  // TODO: Leave a review
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                child: Text(
                  'Leave a Review',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStep(
    BuildContext context, {
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: isCompleted
                ? Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: textColor ?? Colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
