import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/meal_provider.dart';
import '../../models/meal.dart';
import '../meal_details/meal_details_screen.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);

    // Get all meals for search
    final allMeals = mealProvider.meals;
    

    // Filter meals based on search query
    List<Meal> searchResults = [];
    if (_searchQuery.isNotEmpty) {
      searchResults = allMeals.where((meal) {
        // Search in meal name
        if (meal.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return true;
        }
        // Search in category names
        for (var categoryName in meal.categories) {
          if (categoryName.toLowerCase().contains(_searchQuery.toLowerCase())) {
            return true;
          }
        }
        // Search in ingredients
        for (var ingredient in meal.ingredients) {
          if (ingredient.toLowerCase().contains(_searchQuery.toLowerCase())) {
            return true;
          }
        }
        return false;
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _buildSearchResults(searchResults),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'ابحث عن وجبة، مكون، أو تصنيف...',
        hintStyle: const TextStyle(color: Colors.grey),
        border: InputBorder.none,
        prefixIcon: Icon(
          Icons.search,
          color: Theme.of(context).colorScheme.primary,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                    _isSearching = false;
                  });
                },
              )
            : null,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim();
          _isSearching = value.isNotEmpty;
        });
      },
      onSubmitted: (_) {
        // Handle search submission if needed
      },
    );
  }

  Widget _buildSearchResults(List<Meal> results) {
    if (!_isSearching) {
      return _buildRecentSearches();
    }

    if (_searchQuery.isEmpty) {
      return _buildPopularSearches();
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد نتائج',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'لم نتمكن من العثور على "$_searchQuery"',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: results.length,
      itemBuilder: (ctx, index) {
        final meal = results[index];
        return _buildMealItem(meal);
      },
    );
  }

  Widget _buildMealItem(Meal meal) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            MealDetailsScreen.routeName,
            arguments: meal.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Meal image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  meal.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.fastfood, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Meal details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meal.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          meal.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          color: Colors.grey[500],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${meal.preparationTime} دقيقة',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Price
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '${meal.price.toStringAsFixed(1)} ر.س',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    // In a real app, you would get this from shared preferences or a provider
    final recentSearches = [
      'بيتزا',
      'برجر',
      'مشاوي',
      'سلطة',
      'حلويات',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'عمليات البحث الأخيرة',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentSearches
                .map((search) => ActionChip(
                      label: Text(search),
                      onPressed: () {
                        setState(() {
                          _searchController.text = search;
                          _searchQuery = search;
                          _isSearching = true;
                        });
                      },
                      avatar: const Icon(Icons.history, size: 16),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          _buildPopularSearches(),
        ],
      ),
    );
  }

  Widget _buildPopularSearches() {
    // In a real app, you might fetch this from an API
    final popularSearches = [
      'وجبة إفطار',
      'وجبة غداء',
      'وجبة عشاء',
      'مشروبات',
      'مقبلات',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'عمليات البحث الشائعة',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularSearches
              .map((search) => ActionChip(
                    label: Text(search),
                    onPressed: () {
                      setState(() {
                        _searchController.text = search;
                        _searchQuery = search;
                        _isSearching = true;
                      });
                    },
                    avatar: const Icon(Icons.trending_up, size: 16),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
