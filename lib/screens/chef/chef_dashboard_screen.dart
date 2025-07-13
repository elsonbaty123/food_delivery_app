import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/auth_provider.dart';
import 'manage_meals_screen.dart';
import 'edit_meal_screen.dart';
import 'coupon_management_screen.dart';

class ChefDashboardScreen extends StatelessWidget {
  static const routeName = '/chef-dashboard';

  const ChefDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersProvider = Provider.of<OrdersProvider>(context);
    final mealProvider = Provider.of<MealProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الطاهي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
            Navigator.of(context).pushNamed('/profile');
          },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Statistics Cards
            Row(
              children: [
                _buildStatCard('الطلبات اليوم', ordersProvider.orders.where((o) => o.dateTime.day == DateTime.now().day).length.toString(), Icons.receipt),
                _buildStatCard('إجمالي الوجبات', mealProvider.chefMeals.length.toString(), Icons.fastfood),
              ],
            ),
            const SizedBox(height: 20),
            
            // Quick Actions
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              childAspectRatio: 3,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildActionButton('إدارة الوجبات', Icons.restaurant_menu, () {
                  Navigator.of(context).pushNamed(ManageMealsScreen.routeName);
                }, context),
                _buildActionButton('إضافة وجبة', Icons.add_circle_outline, () {
                  Navigator.of(context).pushNamed(EditMealScreen.routeName);
                }, context),
                _buildActionButton('الطلبات الجديدة', Icons.new_releases, () {
                  Navigator.of(context).pushNamed('/new-orders');
                }, context),
                _buildActionButton('قسائم التخفيض', Icons.discount, () {
                  Navigator.of(context).pushNamed(CouponManagementScreen.routeName);
                }, context),
              ],
            ),
            
            // Recent Orders
            const SizedBox(height: 20),
            Text('آخر الطلبات', style: Theme.of(context).textTheme.titleLarge),
            // List of recent orders would go here
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 40),
              Text(title, style: const TextStyle(fontSize: 16)),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Function onTap, BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          onTap();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('جارٍ الانتقال إلى $label...'), duration: const Duration(seconds: 1)),
          );
        },
        splashColor: Theme.of(context).primaryColor.withAlpha((0.2 * 255).round()),
        highlightColor: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
