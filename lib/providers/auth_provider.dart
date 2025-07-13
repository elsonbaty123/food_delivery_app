import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  late GlobalKey<NavigatorState> navigatorKey;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  GlobalKey<NavigatorState>? _navigatorKey;

  UserModel? get user => _user;
  UserModel? get currentUser => _user; // Alias for user to maintain backward compatibility
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  // Load user data (refresh from server)
  Future<void> loadUserData() async {
    if (_user == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate API call to get fresh user data
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, you would fetch the latest user data from the server
      // For now, we'll just notify listeners to refresh the UI
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user data: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initialize AuthProvider
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load user from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      
      if (userJson != null) {
        _user = UserModel.fromJson(json.decode(userJson));
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, you would validate credentials with your backend
      // This is a mock implementation
      if (email.isNotEmpty && password.isNotEmpty) {
        // Mock user data - in a real app, this would come from your API
        _user = UserModel(
          id: '1',
          name: 'مستخدم تجريبي',
          email: email,
          phoneNumber: '+966501234567',
          notificationPreferences: {
            'order_updates': true,
            'promotions': true,
            'new_meals': true,
            'account_activity': true,
          },
          profileImageUrl: 'https://ui-avatars.com/api/?name=User&background=random',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );
        
        // Save user to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', json.encode(_user!.toJson()));
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء تسجيل الدخول. يرجى المحاولة مرة أخرى';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign up a new user
  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    UserType userType = UserType.customer,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Create new user
      _user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phoneNumber: phone,
        userType: userType,
        createdAt: DateTime.now(),
        notificationPreferences: {
          'order_updates': true,
          'promotions': true,
          'newsletter': false,
        },
        profileImageUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random',
      );
      
      // Save user to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(_user!.toJson()));
      
      _isLoading = false;
      notifyListeners();
      return true;
      
    } catch (e) {
      _error = 'حدث خطأ أثناء إنشاء الحساب';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    File? profileImage,
  }) async {
    if (_user == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Update user data
      _user = _user!.copyWith(
        name: name,
        email: email,
        phoneNumber: phone,
        // In a real app, you would upload the image and get the URL
        profileImageUrl: profileImage != null 
            ? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name ?? _user!.name)}&background=random'
            : _user!.profileImageUrl,
      );
      
      // Save updated user to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(_user!.toJson()));
      
      _isLoading = false;
      notifyListeners();
      return true;
      
    } catch (e) {
      _error = 'حدث خطأ أثناء تحديث الملف الشخصي';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update notification preferences
  Future<bool> updateNotificationPreference(String key, bool value) async {
    if (_user == null) return false;
    
    try {
      // Create a new map with updated preferences
      final updatedPreferences = Map<String, bool>.from(_user!.notificationPreferences);
      updatedPreferences[key] = value;
      
      // Update user with new preferences
      _user = _user!.copyWith(notificationPreferences: updatedPreferences);
      
      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(_user!.toJson()));
      
      notifyListeners();
      return true;
      
    } catch (e) {
      debugPrint('Error updating notification preference: $e');
      return false;
    }
  }

  // Log out the current user
  Future<void> logout() async {
    try {
      // Clear user data from shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      
      _user = null;
      _error = null;
      notifyListeners();
      
      // Navigate to home screen after logout
      if (_navigatorKey?.currentContext != null) {
        Navigator.of(_navigatorKey!.currentContext!).pushNamedAndRemoveUntil(
          '/',
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
      rethrow;
    }
  }

  // Toggle notification preference for order updates
  Future<void> toggleNotifications(bool value) async {
    if (_user == null) return;
    
    // In a real app, you would make an API call to update the notification preference
    try {
      _isLoading = true;
      notifyListeners();
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Update the user's notification preferences
      final updatedPreferences = Map<String, bool>.from(_user!.notificationPreferences);
      updatedPreferences['order_updates'] = value;
      
      _user = _user!.copyWith(
        notificationPreferences: updatedPreferences,
        updatedAt: DateTime.now(),
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update notification preferences';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  void addAddress(Address address) {
    if (_user == null) return;
    
    final addresses = List<Address>.from(_user!.addresses);
    addresses.add(address);
    
    _user = _user!.copyWith(addresses: addresses);
    notifyListeners();
  }

  void updateAddress(Address address) {
    if (_user == null) return;
    
    final addresses = List<Address>.from(_user!.addresses);
    final index = addresses.indexWhere((addr) => addr.id == address.id);
    
    if (index >= 0) {
      addresses[index] = address;
      _user = _user!.copyWith(addresses: addresses);
      notifyListeners();
    }
  }

  void removeAddress(String addressId) {
    if (_user == null) return;
    
    final addresses = List<Address>.from(_user!.addresses)
      ..removeWhere((addr) => addr.id == addressId);
    
    _user = _user!.copyWith(addresses: addresses);
    notifyListeners();
  }

  void addPaymentMethod(PaymentMethod paymentMethod) {
    if (_user == null) return;
    
    final paymentMethods = List<PaymentMethod>.from(_user!.paymentMethods);
    
    // If this is the first payment method, set it as default
    final isFirstMethod = paymentMethods.isEmpty;
    final newPaymentMethod = paymentMethod.copyWith(
      isDefault: isFirstMethod ? true : paymentMethod.isDefault,
    );
    
    paymentMethods.add(newPaymentMethod);
    _user = _user!.copyWith(paymentMethods: paymentMethods);
    notifyListeners();
  }

  void updatePaymentMethod(PaymentMethod paymentMethod) {
    if (_user == null) return;
    
    final paymentMethods = List<PaymentMethod>.from(_user!.paymentMethods);
    final index = paymentMethods.indexWhere((pm) => pm.id == paymentMethod.id);
    
    if (index >= 0) {
      paymentMethods[index] = paymentMethod;
      _user = _user!.copyWith(paymentMethods: paymentMethods);
      notifyListeners();
    }
  }

  void removePaymentMethod(String paymentMethodId) {
    if (_user == null) return;
    
    final paymentMethods = List<PaymentMethod>.from(_user!.paymentMethods)
      ..removeWhere((pm) => pm.id == paymentMethodId);
    
    _user = _user!.copyWith(paymentMethods: paymentMethods);
    notifyListeners();
  }

  void addToFavorites(String mealId) {
    if (_user == null) return;
    
    final favorites = List<String>.from(_user!.favoriteMealIds);
    if (!favorites.contains(mealId)) {
      favorites.add(mealId);
      _user = _user!.copyWith(favoriteMealIds: favorites);
      notifyListeners();
    }
  }

  void removeFromFavorites(String mealId) {
    if (_user == null) return;
    
    final favorites = List<String>.from(_user!.favoriteMealIds)
      ..remove(mealId);
    
    _user = _user!.copyWith(favoriteMealIds: favorites);
    notifyListeners();
  }

  bool isFavorite(String mealId) {
    return _user?.favoriteMealIds.contains(mealId) ?? false;
  }
}
