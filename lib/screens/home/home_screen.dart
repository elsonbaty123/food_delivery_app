import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/location_provider.dart';
import '../location/location_search_screen.dart';
import '../../models/meal.dart';
import '../../models/category.dart';
import '../meal_details/meal_details_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/';
  
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<MealProvider, CategoryProvider, CartProvider>(
      builder: (context, mealProvider, categoryProvider, cartProvider, _) {
        final popularMeals = mealProvider.popularMeals;
        final categories = categoryProvider.getPopularCategories();
        
        return Scaffold(
          appBar: AppBar(
            title: Consumer<LocationProvider>(
              builder: (context, locationProvider, _) {
                return GestureDetector(
                  onTap: () async {
                    final selectedLocation = await Navigator.pushNamed(
                      context, 
                      LocationSearchScreen.routeName,
                    );
                    if (selectedLocation != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تحديث الموقع بنجاح'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'التوصيل إلى',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            locationProvider.currentLocation?.name ?? 'تحديد الموقع',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.pushNamed(context, SearchScreen.routeName);
                },
              ),
              Consumer<CartProvider>(
                builder: (context, cart, _) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        onPressed: () {
                          Navigator.pushNamed(context, '/cart');
                        },
                      ),
                      if (cart.itemCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${cart.itemCount > 99 ? '99+' : cart.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with greeting and location
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildHeader(context),
                  ),
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: _buildSearchBar(context),
                  ),
                  const SizedBox(height: 24),
                  // Categories section
                  _buildCategoriesSection(categories, context),
                  const SizedBox(height: 24),
                  // Popular meals section
                  _buildPopularMealsSection(popularMeals, context, cartProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مرحباً بك',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 20),
            const SizedBox(width: 4),
            Text(
              'موقع التوصيل',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, SearchScreen.routeName);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.search),
            const SizedBox(width: 8),
            Text(
              'ابحث عن وجبتك المفضلة...',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(List<Category> categories, BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التصنيفات',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryItem(
                icon: _getCategoryIcon(category.icon),
                label: category.name,
                color: category.color,
                onTap: () {
                  // Navigate to category details or filter meals by category
                  // Navigator.pushNamed(context, CategoryDetailsScreen.routeName, arguments: category.id);
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  IconData _getCategoryIcon(String icon) {
    // Map icon strings to actual icons
    switch (icon) {
      case '🍛':
        return Icons.restaurant;
      case '🍖':
        return Icons.outdoor_grill;
      case '🐟':
        return Icons.set_meal;
      case '🥤':
        return Icons.local_drink;
      case '🍰':
        return Icons.cake;
      case '🥗':
        return Icons.eco;
      default:
        return Icons.fastfood;
    }
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withAlpha((255 * 0.2).round()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withAlpha((255 * 0.3).round()), width: 1),
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: SizedBox(
                width: 70,
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularMealsSection(
    List<Meal> popularMeals,
    BuildContext context,
    CartProvider cartProvider,
  ) {
    if (popularMeals.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الوجبات الشعبية',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all popular meals
                // Navigator.push(...);
              },
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: popularMeals.length,
            itemBuilder: (context, index) {
              final popularMeal = popularMeals[index];
              return _buildMealCard(
                meal: popularMeal,
                isInCart: cartProvider.isMealInCart(popularMeal.id),
                onAddToCart: () {
                  Map<String, dynamic> cartItem = {
                    'id': popularMeal.id,
                    'name': popularMeal.name,
                    'price': popularMeal.price,
                    'quantity': 1,
                    'meal': popularMeal,
                  };

                  cartProvider.addToCart(cartItem);
                  
                  // Show a snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تمت إضافة ${popularMeal.name} إلى السلة'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                onTap: () {
                  Navigator.pushNamed(context, MealDetailsScreen.routeName, arguments: popularMeal.id);
                },
                context: context,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard({
    required Meal meal,
    required bool isInCart,
    required VoidCallback onAddToCart,
    required VoidCallback? onTap,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      meal.imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 120,
                        color: Colors.grey[200],
                        child: const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                  if (isInCart)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              // Details
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          meal.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const Spacer(),
                        Text(
                          '${meal.price.toStringAsFixed(1)} ر.س',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isInCart ? null : onAddToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isInCart
                              ? Colors.grey[300]
                              : Theme.of(context).colorScheme.primary,
                          foregroundColor: isInCart ? Colors.grey[600] : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isInCart ? 'مضاف للسلة' : 'أضف للسلة',
                          style: TextStyle(
                            fontSize: 12,
                            color: isInCart ? Colors.grey[800] : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
