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
                  
              MealDetailsScreen.routeName: (context) => 
                  MealDetailsScreen(
                    mealId: ModalRoute.of(context)!.settings.arguments as String,
                  ),
                    
              SearchScreen.routeName: (context) => const SearchScreen(),
              '/orders': (context) => const OrdersScreen(),
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
    // For protected screens, check authentication
    if (index >= 2 && !Provider.of<AuthProvider>(context, listen: false).isAuthenticated) {
      // Show login screen if trying to access protected screens
      Navigator.pushNamed(context, LoginScreen.routeName);
      return;
    }
    
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is authenticated before showing main app
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (!authProvider.isAuthenticated) {
      // If not authenticated, show login screen
      return const LoginScreen();
    }
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
