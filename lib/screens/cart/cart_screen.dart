import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة التسوق'),
        centerTitle: true,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: cartProvider.items.isNotEmpty ? () {
                  _showClearCartDialog(context, cartProvider);
                } : null,
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'سلة التسوق فارغة',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'لم تقم بإضافة أي وجبات إلى السلة بعد',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to home screen
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text('تصفح الوجبات'),
                  ),
                ],
              ),
            );
          }

          // Calculate subtotal
          double subtotal = cartProvider.totalAmount;
          // Calculate delivery fee (example: 10% of subtotal, min 5, max 20)
          double deliveryFee = subtotal * 0.1;
          deliveryFee = deliveryFee.clamp(5.0, 20.0);
          // Calculate total
          double total = subtotal + deliveryFee;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return _buildCartItem(context, item, cartProvider);
                  },
                ),
              ),
              _buildCheckoutSection(context, cartProvider, subtotal, deliveryFee, total),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem cartItem, CartProvider cartProvider) {
    return Dismissible(
      key: ValueKey(cartItem.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.only(left: 20),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      onDismissed: (direction) {
        cartProvider.removeItem(cartItem.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت إزالة العنصر من السلة'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image (using meal imageUrl if available)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: cartItem.meal.imageUrl.isNotEmpty
                    ? Image.network(
                        cartItem.meal.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: Icon(Icons.fastfood, size: 40, color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: Icon(Icons.fastfood, size: 40, color: Colors.grey),
                      ),
              ),
              SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.meal.name,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (cartItem.specialInstructions != null && cartItem.specialInstructions!.isNotEmpty)
                      Text(
                        cartItem.specialInstructions!.join(', '),
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 8),
                    Text(
                      '${cartItem.meal.price.toStringAsFixed(2)} ر.س',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Quantity controls
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      cartProvider.updateItemQuantity(cartItem.id, cartItem.quantity + 1);
                    },
                    icon: Icon(Icons.add_circle_outline, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  Text('${cartItem.quantity}'),
                  IconButton(
                    onPressed: () {
                      if (cartItem.quantity > 1) {
                        cartProvider.updateItemQuantity(cartItem.id, cartItem.quantity - 1);
                      } else {
                        cartProvider.removeItem(cartItem.id);
                      }
                    },
                    icon: Icon(Icons.remove_circle_outline, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, CartProvider cartProvider, double subtotal, double deliveryFee, double total) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المجموع الفرعي:',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '${subtotal.toStringAsFixed(2)} ر.س',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'رسوم التوصيل:',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '${deliveryFee.toStringAsFixed(2)} ر.س',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المجموع:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${total.toStringAsFixed(2)} ر.س',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showCheckoutDialog(context, cartProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'إتمام الطلب',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تفريغ السلة'),
        content: Text('هل أنت متأكد من رغبتك في حذف جميع الوجبات من السلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              cartProvider.clear();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم تفريغ السلة بنجاح'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('حذف الكل'),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تأكيد الطلب'),
        content: Text('هل أنت متأكد من إتمام الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, you would process the order here
              // For now, we'll just show a success message and clear the cart
              final totalItems = cartProvider.itemCount;
              cartProvider.clear();
              Navigator.of(ctx).pop();

              // Show order confirmation
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => AlertDialog(
                  title: Text('تم الطلب بنجاح'),
                  content: Text('تم استلام طلبك المكون من $totalItems عنصر بنجاح. سنقوم بتحديثك بحالة الطلب.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        // Navigate to orders screen when implemented
                        // Navigator.pushReplacementNamed(context, '/orders');
                      },
                      child: Text('حسناً'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
