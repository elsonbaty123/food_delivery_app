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
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => AddressesProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
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
              LoginScreen.routeName: (ctx) => const LoginScreen(),
                                      SignUpScreen.routeName: (ctx) => const SignUpScreen(),
              ForgotPasswordScreen.routeName: (ctx) => const ForgotPasswordScreen(),
              
              // Main App Routes
              '/': (ctx) => authProvider.isAuthenticated 
                  ? const HomePage() 
                  : const LoginScreen(),
                  
              // Feature Screens
              CategoriesScreen.routeName: (ctx) => const CategoriesScreen(),
              CartScreen.routeName: (ctx) => const CartScreen(),
              SearchScreen.routeName: (ctx) => const SearchScreen(),
              LocationSearchScreen.routeName: (ctx) => const LocationSearchScreen(),
              ProfileScreen.routeName: (ctx) => const ProfileScreen(),
              OrdersScreen.routeName: (ctx) => const OrdersScreen(),
              AddressesScreen.routeName: (ctx) => const AddressesScreen(),
              AddEditAddressScreen.routeName: (ctx) => const AddEditAddressScreen(),
              FavoritesScreen.routeName: (ctx) => const FavoritesScreen(),
              MealDetailsScreen.routeName: (ctx) {
                final args = ModalRoute.of(ctx)!.settings.arguments;
                return MealDetailsScreen(mealId: args as String);
              },
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
