import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/meal_provider.dart';
import '../../models/meal.dart';

class ManageMealsScreen extends StatefulWidget {
  static const routeName = '/manage-meals';

  const ManageMealsScreen({super.key});

  @override
  State<ManageMealsScreen> createState() => _ManageMealsScreenState();
}

class _ManageMealsScreenState extends State<ManageMealsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  List<Meal> get _chefMeals {
    return Provider.of<MealProvider>(context).chefMeals;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meals = _chefMeals;
    
    final displayedMeals = _searchQuery.isEmpty
        ? meals
        : meals.where((meal) => 
            meal.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الوجبات'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/edit-meal');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'ابحث عن وجبة',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedMeals.length,
              itemBuilder: (ctx, index) {
                final meal = displayedMeals[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(meal.imageUrl),
                  ),
                  title: Text(meal.name),
                  subtitle: Text('${meal.price} ر.س'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pushNamed(
                            context, 
                            '/edit-meal',
                            arguments: meal.id,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteDialog(context, meal);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, Meal meal) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف وجبة ${meal.name}؟'),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Provider.of<MealProvider>(context, listen: false)
                  .deleteMeal(meal.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
