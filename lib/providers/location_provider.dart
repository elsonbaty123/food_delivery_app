import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  LocationModel? _currentLocation;
  List<LocationModel> _recentLocations = [];
  bool _isLoading = false;
  String? _error;

  LocationModel? get currentLocation => _currentLocation;
  List<LocationModel> get recentLocations => _recentLocations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get current location
  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final position = await LocationService.getCurrentPosition();
      
      if (position != null) {
        final address = await LocationService.getAddressFromLatLng(
          position.latitude, 
          position.longitude,
        );

        final location = LocationModel(
          id: 'current',
          name: 'موقعي الحالي',
          latitude: position.latitude,
          longitude: position.longitude,
          address: address,
          isCurrent: true,
        );

        _currentLocation = location;
        _addToRecentLocations(location);
      } else {
        _error = 'تعذر الحصول على الموقع الحالي';
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء محاولة الحصول على الموقع';
      if (kDebugMode) {
        print('Location error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search for locations
  Future<List<LocationModel>> searchLocations(String query) async {
    // In a real app, this would call a geocoding API
    // For now, we'll just return a mock list
    return [
      LocationModel(
        id: '1',
        name: '$query 1',
        description: 'عنوان تجريبي 1',
        latitude: 24.7136,
        longitude: 46.6753,
        address: '$query, الرياض, السعودية',
      ),
      LocationModel(
        id: '2',
        name: '$query 2',
        description: 'عنوان تجريبي 2',
        latitude: 24.7100,
        longitude: 46.6700,
        address: '$query, الرياض, السعودية',
      ),
    ];
  }

  // Set current location
  void setCurrentLocation(LocationModel location) {
    _currentLocation = location;
    _addToRecentLocations(location);
    notifyListeners();
  }

  // Add location to recent locations
  void _addToRecentLocations(LocationModel location) {
    // Remove if already exists
    _recentLocations.removeWhere((loc) => loc.id == location.id);
    
    // Add to beginning of list
    _recentLocations.insert(0, location);
    
    // Keep only last 5 locations
    if (_recentLocations.length > 5) {
      _recentLocations = _recentLocations.sublist(0, 5);
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
