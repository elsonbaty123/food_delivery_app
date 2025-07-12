import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/cart_provider.dart';
import '../../providers/meal_provider.dart';
import '../../models/meal.dart';
import '../../models/cart_item.dart';
import '../../constants/app_constants.dart';

class MealDetailsScreen extends StatelessWidget {
  static const routeName = '/meal-details';
  
  final String mealId;
  
  const MealDetailsScreen({
    super.key,
    required this.mealId,
  });

  @override
  Widget build(BuildContext context) {
    final meal = Provider.of<MealProvider>(context, listen: false).getMealById(mealId);
    
    if (meal == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('الوجبة غير متوفرة'),
        ),
        body: const Center(
          child: Text('عذراً، لم يتم العثور على الوجبة المطلوبة'),
        ),
      );
    }
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, meal),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMealInfo(meal),
                  const SizedBox(height: 24),
                  _buildIngredientsSection(meal),
                  const SizedBox(height: 24),
                  _buildNutritionInfo(meal),
                  const SizedBox(height: 24),
                  _buildSpecialInstructions(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, meal),
    );
  }
  
  Widget _buildAppBar(BuildContext context, Meal meal) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          meal.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Hero(
          tag: 'meal-${meal.id}',
          child: CachedNetworkImage(
            imageUrl: meal.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.fastfood, size: 60, color: Colors.grey),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            final isInCart = cartProvider.isMealInCart(meal.id);
            return IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isInCart ? Icons.shopping_cart_checkout : Icons.shopping_cart_outlined,
                  color: Colors.white,
                ),
              ),
              onPressed: isInCart 
                  ? () => Navigator.pushNamed(context, '/cart')
                  : null,
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildMealInfo(Meal meal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              meal.rating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.access_time, size: 20, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '${meal.preparationTime} دقيقة',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          meal.description,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }
  
  Widget _buildIngredientsSection(Meal meal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المكونات',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: meal.ingredients
              .map((ingredient) => Chip(
                    label: Text(ingredient),
                    backgroundColor: Colors.grey[200],
                  ))
              .toList(),
        ),
      ],
    );
  }
  
  Widget _buildNutritionInfo(Meal meal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'القيمة الغذائية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutritionItem('سعرات حرارية', '${meal.nutrition['calories']}'),
              _buildNutritionItem('بروتين', '${meal.nutrition['protein']} جم'),
              _buildNutritionItem('كربوهيدرات', '${meal.nutrition['carbs']} جم'),
              _buildNutritionItem('دهون', '${meal.nutrition['fat']} جم'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildNutritionItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSpecialInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تعليمات خاصة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'مثال: بدون بصل، إضافة مخلل، إلخ...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!), 
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }
  
  Widget _buildBottomBar(BuildContext context, Meal meal) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        final isInCart = cartProvider.isMealInCart(meal.id);
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha((255 * 0.1).round()),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'السعر',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${meal.price.toStringAsFixed(1)} ر.س',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: isInCart
                      ? () => Navigator.pushNamed(context, '/cart')
                      : () {
                          cartProvider.addItem(
                            CartItem(
                              id: '${meal.id}_${DateTime.now().millisecondsSinceEpoch}',
                              meal: meal,
                              quantity: 1,
                              specialInstructions: [],
                              addons: {},
                            ),
                          );
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تمت إضافة ${meal.name} إلى السلة'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isInCart 
                        ? Colors.green 
                        : Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isInCart ? 'الذهاب للسلة' : 'أضف إلى السلة',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
