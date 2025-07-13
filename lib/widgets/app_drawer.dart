import 'package:flutter/material.dart';
import 'package:food_delivery_app/screens/orders_screen.dart';
import 'package:food_delivery_app/screens/favorites_screen.dart';
import 'package:food_delivery_app/screens/addresses_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/profile_screen.dart';
// TODO: Uncomment when these screens are created
// import '../screens/orders_screen.dart';
// import '../screens/addresses_screen.dart';
// import '../screens/favorites_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('هذه الميزة قريباً!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Consumer<AuthProvider>(
            builder: (ctx, auth, _) {
              final user = auth.currentUser;
              return UserAccountsDrawerHeader(
                accountName: Text(user?.name ?? 'Guest'),
                accountEmail: Text(user?.email ?? 'guest@example.com'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    (user?.name?.isNotEmpty ?? false) ? user!.name![0].toUpperCase() : 'G',
                    style: const TextStyle(fontSize: 40.0, color: Colors.white),
                  ),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('الملف الشخصي'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, ProfileScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('طلباتي'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, OrdersScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('المفضلة'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, FavoritesScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('العناوين'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AddressesScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('الإعدادات'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings screen
            },
          ),
          const Divider(),
          Consumer<AuthProvider>(
            builder: (ctx, auth, _) {
              return ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('تسجيل خروج'),
                onTap: () async {
                  Navigator.pop(context);
                  await auth.logout();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
