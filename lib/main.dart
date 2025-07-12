import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home/home_screen.dart';
import 'screens/categories/categories_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/meal_details/meal_details_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';

import 'constants/app_constants.dart';
import 'providers/cart_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/category_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'providers/location_provider.dart';
import 'screens/location/location_search_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FoodDeliveryApp());
}

class FoodDeliveryApp extends StatelessWidget {
  const FoodDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'مطبخ البيت',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'SA'), // Arabic
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
            initialRoute: authProvider.isAuthenticated ? '/' : LoginScreen.routeName,
            routes: {
              // Auth Routes
              LoginScreen.routeName: (context) => const LoginScreen(),
              SignUpScreen.routeName: (context) => const SignUpScreen(),
              ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
              
              // Main App Routes
              '/': (context) => authProvider.isAuthenticated 
                  ? const HomePage() 
                  : const LoginScreen(),
                  
              // Other Routes
              MealDetailsScreen.routeName: (context) => 
                  MealDetailsScreen(
                    mealId: ModalRoute.of(context)!.settings.arguments as String,
                  ),
                    
              SearchScreen.routeName: (context) => const SearchScreen(),
              LocationSearchScreen.routeName: (context) => const LocationSearchScreen(),
            },
            onGenerateRoute: (settings) {
              // Handle any other named routes here if needed
              return null;
            },
          );
        },
      ),
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

  final List<Widget> _pages = [
    const HomeScreen(),
    const CategoriesScreen(),
    const OrdersScreen(),
    const CartScreen(),
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
    
    if (index == 3) { // Profile tab
      if (!authProvider.isAuthenticated) {
        // Show auth screen in a dialog
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => const LoginScreen(),
        );
        return;
      }
    } else if (index == 2) { // Cart tab
      if (!authProvider.isAuthenticated) {
        // Show auth screen in a dialog
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => const LoginScreen(),
        );
        return;
      }
    }
    
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  Widget _buildAuthScreen() {
    return Navigator(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case SignUpScreen.routeName:
            return MaterialPageRoute(builder: (_) => const SignUpScreen());
          case ForgotPasswordScreen.routeName:
            return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
          case LoginScreen.routeName:
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
        onPageChanged: _onPageChanged,
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
