import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryProvider with ChangeNotifier {
  final List<Category> _categories = [
    // Sample categories - in a real app, this would come from an API
    Category(
      id: '1',
      name: 'وجبات عربية',
      icon: '🍛',
      itemCount: 15,
    ),
    Category(
      id: '2',
      name: 'مشويات',
      icon: '🍖',
      itemCount: 12,
    ),
    Category(
      id: '3',
      name: 'مأكولات بحرية',
      icon: '🐟',
      itemCount: 8,
    ),
    Category(
      id: '4',
      name: 'مشروبات',
      icon: '🥤',
      itemCount: 10,
    ),
    Category(
      id: '5',
      name: 'حلويات',
      icon: '🍰',
      itemCount: 7,
    ),
    Category(
      id: '6',
      name: 'سلطات',
      icon: '🥗',
      itemCount: 5,
    ),
  ];

  List<Category> get categories => List.unmodifiable(_categories);

  Category? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  List<Category> getPopularCategories() {
    // In a real app, this might be based on some popularity metric
    return _categories.take(4).toList();
  }

  // In a real app, you would have methods to fetch categories from an API
  Future<void> fetchCategories() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // In a real app, you would fetch data from an API here
    notifyListeners();
  }
}
