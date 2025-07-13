import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/address.dart';

class AddressesProvider with ChangeNotifier {
  List<Address> _addresses = [];
  
  List<Address> get addresses {
    return [..._addresses];
  }
  
  Address findById(String id) {
    return _addresses.firstWhere((address) => address.id == id);
  }
  
  Future<void> fetchAndSetAddresses() async {
    // TODO: Implement actual API call to fetch addresses
    // This is a mock implementation
    _addresses = [
      Address(
        id: '1',
        title: 'المنزل',
        fullAddress: '123 شارع الرياض، حي المروج',
        buildingNumber: '1234',
        floor: '2',
        apartment: '5',
        isDefault: true,
      ),
      Address(
        id: '2',
        title: 'العمل',
        fullAddress: '456 طريق الملك فهد، حي الصحافة',
        buildingNumber: '789',
        floor: '3',
        apartment: '10',
        isDefault: false,
      ),
    ];
    
    notifyListeners();
  }
  
  Future<void> addAddress(
    String title,
    String fullAddress,
    String buildingNumber,
    String floor,
    String apartment,
    String additionalDirections,
    bool isDefault,
  ) async {
    // TODO: Implement actual API call to add address
    final newAddress = Address(
      id: DateTime.now().toString(),
      title: title,
      fullAddress: fullAddress,
      buildingNumber: buildingNumber,
      floor: floor,
      apartment: apartment,
      isDefault: isDefault,
    );
    
    _addresses.add(newAddress);
    notifyListeners();
  }
  
  Future<void> updateAddress(
    String id,
    String title,
    String fullAddress,
    String buildingNumber,
    String floor,
    String apartment,
    String additionalDirections,
    bool isDefault,
  ) async {
    // TODO: Implement actual API call to update address
    final addressIndex = _addresses.indexWhere((addr) => addr.id == id);
    if (addressIndex >= 0) {
      _addresses[addressIndex] = Address(
        id: id,
        title: title,
        fullAddress: fullAddress,
        buildingNumber: buildingNumber,
        floor: floor,
        apartment: apartment,
        isDefault: isDefault,
      );
      notifyListeners();
    }
  }
  
  Future<void> deleteAddress(String id) async {
    // TODO: Implement actual API call to delete address
    _addresses.removeWhere((addr) => addr.id == id);
    notifyListeners();
  }
}
