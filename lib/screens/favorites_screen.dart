import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../widgets/meal_item.dart';
import '../widgets/app_drawer.dart';

class FavoritesScreen extends StatelessWidget {
  static const routeName = '/favorites';
  
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mealsData = Provider.of<MealProvider>(context);
        final favoriteMeals = mealsData.favoriteMeals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: favoriteMeals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'لا توجد عناصر مفضلة',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'اضغط على ♡ لإضافة الوجبات المفضلة',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: favoriteMeals.length,
              itemBuilder: (ctx, i) => MealItem(
                id: favoriteMeals[i].id,
                title: favoriteMeals[i].name,
                imageUrl: favoriteMeals[i].imageUrl,
                duration: favoriteMeals[i].preparationTime,
                complexity: favoriteMeals[i].complexity,
                affordability: favoriteMeals[i].affordability,
              ),
            ),
    );
  }
}
