import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/meal_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/meal.dart';
import '../../models/enums.dart';

class EditMealScreen extends StatefulWidget {
  static const routeName = '/edit-meal';

  const EditMealScreen({super.key});

  @override
  State<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  final _formKey = GlobalKey<FormState>();
  late Meal _editedMeal;
  bool _isInit = true;
  bool _isLoading = false;
  File? _pickedImage;
  String? _pickedImageUrl;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    
    if (pickedImage != null) {
      if (kIsWeb) {
        setState(() {
          _pickedImageUrl = pickedImage.path;
        });
      } else {
        setState(() {
          _pickedImage = File(pickedImage.path);
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final mealId = ModalRoute.of(context)?.settings.arguments as String?;
      
      if (mealId != null) {
        final meal = Provider.of<MealProvider>(context, listen: false)
              .getMealById(mealId);
              
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        _editedMeal = meal?.copyWith() ?? Meal(
          id: mealId,
          name: '',
          description: '',
          price: 0,
          chefId: authProvider.currentUser?.id,
          imageUrl: '',
          categories: const [],
          ingredients: [],
          nutrition: {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0},
          preparationTime: 30,
          complexity: Complexity.simple,
          affordability: Affordability.affordable,
          rating: 0,
        );
      } else {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        _editedMeal = Meal(
          id: '',
          name: '',
          description: '',
          price: 0,
          chefId: authProvider.currentUser?.id,
          imageUrl: '',
          categories: const [],
          ingredients: [],
          nutrition: {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0},
          preparationTime: 30,
          complexity: Complexity.simple,
          affordability: Affordability.affordable,
          rating: 0,
        );
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _formKey.currentState?.save();
    setState(() => _isLoading = true);

    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    try {
      if (_editedMeal.id.isEmpty) {
        await mealProvider.addMeal(_editedMeal);
      } else {
        await mealProvider.updateMeal(_editedMeal);
      }

      if (!mounted) return;
      navigator.pop();
    } catch (error) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('حدث خطأ'),
          content: const Text('فشل في حفظ الوجبة'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editedMeal.id.isEmpty ? 'إضافة وجبة جديدة' : 'تعديل الوجبة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _editedMeal.name,
                      decoration: const InputDecoration(labelText: 'اسم الوجبة'),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'يجب إدخال اسم الوجبة';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedMeal = _editedMeal.copyWith(name: value);
                      },
                    ),
                    TextFormField(
                      initialValue: _editedMeal.description,
                      decoration: const InputDecoration(labelText: 'الوصف'),
                      maxLines: 3,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'يجب إدخال وصف الوجبة';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedMeal = _editedMeal.copyWith(description: value);
                      },
                    ),
                    TextFormField(
                      initialValue: _editedMeal.price.toString(),
                      decoration: const InputDecoration(labelText: 'السعر'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'يجب إدخال سعر الوجبة';
                        }
                        if (double.tryParse(value!) == null) {
                          return 'يجب إدخال رقم صحيح';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedMeal = _editedMeal.copyWith(
                          price: double.parse(value!),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey),
                        ),
                        child: _pickedImageUrl != null
                            ? Image.network(_pickedImageUrl!, fit: BoxFit.cover)
                            : _pickedImage != null
                                ? Image.file(_pickedImage!, fit: BoxFit.cover)
                                : _editedMeal.imageUrl.isNotEmpty
                                    ? Image.network(_editedMeal.imageUrl, fit: BoxFit.cover)
                                    : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, size: 50),
                                      Text('اضغط لإضافة صورة')
                                    ],
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
