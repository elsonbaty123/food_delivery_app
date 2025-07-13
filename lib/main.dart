import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

// Screens
import 'screens/home/home_screen.dart';
import 'screens/categories/categories_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/addresses_screen.dart';
import 'screens/add_edit_address_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/meal_details/meal_details_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/location/location_search_screen.dart';
import 'screens/chef/manage_meals_screen.dart';
import 'screens/chef/edit_meal_screen.dart';
import 'screens/chef/chef_dashboard_screen.dart';
import 'screens/chef/coupon_management_screen.dart';
import 'screens/chef/new_orders_screen.dart';

// Constants
import 'constants/app_constants.dart';

// Providers
import 'providers/cart_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/category_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/addresses_provider.dart';
import 'providers/location_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (context) => MealProvider(context),
        ),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => AddressesProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: FoodDeliveryApp(),
    ),
  );
}

class FoodDeliveryApp extends StatelessWidget {
  FoodDeliveryApp({super.key}) {
    navigatorKey = GlobalKey<NavigatorState>();
    scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  }
  
  late final GlobalKey<NavigatorState> navigatorKey;
  late final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        authProvider.setNavigatorKey(navigatorKey);
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'مطبخ البيت',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: scaffoldMessengerKey,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar', 'SA'), 
            Locale('en', 'US'),
          ],
          locale: const Locale('ar', 'SA'),
          themeMode: ThemeMode.light,
          theme: AppTheme.lightTheme.copyWith(
            textTheme: Theme.of(context).textTheme.apply(
                  fontFamily: 'Cairo',
                  bodyColor: AppColors.textPrimary,
                  displayColor: AppColors.textPrimary,
                ),
          ),
          home: const HomeScreen(),
          routes: {
            // Auth Routes
            LoginScreen.routeName: (ctx) => const LoginScreen(),
            SignUpScreen.routeName: (ctx) => const SignUpScreen(),
            ForgotPasswordScreen.routeName: (ctx) => const ForgotPasswordScreen(),
            
            // Main App Routes
            ChefDashboardScreen.routeName: (ctx) => const ChefDashboardScreen(),
            ManageMealsScreen.routeName: (ctx) => const ManageMealsScreen(),
            EditMealScreen.routeName: (ctx) => const EditMealScreen(),
            CouponManagementScreen.routeName: (ctx) => const CouponManagementScreen(),
            NewOrdersScreen.routeName: (ctx) => const NewOrdersScreen(),
            
            // Other Routes
            CategoriesScreen.routeName: (ctx) => const CategoriesScreen(),
            CartScreen.routeName: (ctx) => const CartScreen(),
            ProfileScreen.routeName: (ctx) => const ProfileScreen(),
            OrdersScreen.routeName: (ctx) => const OrdersScreen(),
            MealDetailsScreen.routeName: (ctx) {
              final args = ModalRoute.of(ctx)!.settings.arguments;
              return MealDetailsScreen(mealId: args as String);
            },
            SearchScreen.routeName: (ctx) => const SearchScreen(),
            LocationSearchScreen.routeName: (ctx) => const LocationSearchScreen(),
            AddressesScreen.routeName: (ctx) => const AddressesScreen(),
            AddEditAddressScreen.routeName: (ctx) => const AddEditAddressScreen(),
            FavoritesScreen.routeName: (ctx) => const FavoritesScreen(),
          },

        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late PageController _pageController;

  // List of screens for the bottom navigation bar
  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoriesScreen(),
    const CartScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Indices 2 (Cart) and 4 (Profile) require authentication.
    final requiresAuth = index == 2 || index == 4;

    if (requiresAuth && !authProvider.isAuthenticated) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => const LoginScreen(),
      );
    } else {
      setState(() {
        _currentIndex = index;
        _pageController.jumpToPage(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'الأقسام',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'السلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'طلباتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}
