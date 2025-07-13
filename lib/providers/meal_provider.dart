import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';

class MealProvider with ChangeNotifier {
  final List<String> _favoriteMealIds = [];
  final List<Meal> _meals = [
    // Sample meals - in a real app, this would come from an API
    Meal(
      id: '1',
      name: 'كبسة دجاج',
      description: 'أكلة سعودية تقليدية تتكون من الأرز البسمتي مع الدجاج المشوي والتوابل الخاصة',
      price: 45.0,
      rating: 4.8,
      imageUrl: 'https://via.placeholder.com/300x200?text=كبسة+دجاج',
      categories: ['1', '2'],
      isPopular: true,
      isRecommended: true,
      preparationTime: 45,
      ingredients: [
        'أرز بسمتي',
        'دجاج',
        'بهارات الكبسة',
        'بصل',
        'ثوم',
        'طماطم',
      ],
      nutrition: {
        'calories': 850,
        'protein': 45,
        'carbs': 90,
        'fat': 35,
      },
    ),
    Meal(
      id: '2',
      name: 'مندي لحم',
      description: 'لحم ضأن مطبوخ على البخار مع الأرز والبهارات الخاصة',
      price: 65.0,
      rating: 4.9,
      imageUrl: 'https://via.placeholder.com/300x200?text=مندي+لحم',
      categories: ['1', '3'],
      isPopular: true,
      isRecommended: true,
      preparationTime: 60,
      ingredients: [
        'لحم ضأن',
        'أرز بسمتي',
        'بهارات المندي',
        'سمنة بلدية',
      ],
      nutrition: {
        'calories': 950,
        'protein': 55,
        'carbs': 85,
        'fat': 45,
      },
    ),
    // Add more sample meals as needed
  ];

  final BuildContext context;

  MealProvider(this.context);

  List<Meal> get meals => List.unmodifiable(_meals);

  List<Meal> get popularMeals =>
      _meals.where((meal) => meal.isPopular).toList();

  List<Meal> get recommendedMeals =>
      _meals.where((meal) => meal.isRecommended).toList();

  List<Meal> get favoriteMeals => _meals.where((meal) => _favoriteMealIds.contains(meal.id)).toList();

  List<Meal> get chefMeals => _meals.where((meal) => meal.chefId == currentUser?.id).toList();

  void toggleFavoriteStatus(String mealId) {
    if (_favoriteMealIds.contains(mealId)) {
      _favoriteMealIds.remove(mealId);
    } else {
      _favoriteMealIds.add(mealId);
    }
    notifyListeners();
  }

  bool isFavorite(String mealId) {
    return _favoriteMealIds.contains(mealId);
  }

  List<Meal> getMealsByCategory(String categoryId) {
    return _meals
        .where((meal) => meal.categories.contains(categoryId))
        .toList();
  }

  Meal? getMealById(String mealId) {
    try {
      return _meals.firstWhere((meal) => meal.id == mealId);
    } catch (e) {
      return null;
    }
  }

  List<Meal> searchMeals(String query) {
    if (query.isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase();
    return _meals.where((meal) {
      return meal.name.toLowerCase().contains(lowercaseQuery) ||
          meal.description.toLowerCase().contains(lowercaseQuery) ||
          meal.ingredients.any(
            (ingredient) => ingredient.toLowerCase().contains(lowercaseQuery),
          );
    }).toList();
  }

  Future<void> addMeal(Meal meal) async {
    _meals.add(meal);
    notifyListeners();
    
    // In a real app, you would also update the backend here
    try {
      // await apiService.addMeal(meal);
    } catch (error) {
      _meals.remove(meal);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateMeal(Meal meal) async {
    final index = _meals.indexWhere((m) => m.id == meal.id);
    if (index >= 0) {
      _meals[index] = meal;
      notifyListeners();
    }
  }

  Future<void> deleteMeal(String mealId) async {
    _meals.removeWhere((meal) => meal.id == mealId);
    notifyListeners();
  }

  // In a real app, you would have methods to fetch meals from an API
  Future<void> fetchMeals() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // In a real app, you would fetch data from an API here
    notifyListeners();
  }

  UserModel? get currentUser {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.currentUser;
  }
}
