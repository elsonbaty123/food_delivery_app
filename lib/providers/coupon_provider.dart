import 'package:flutter/foundation.dart';
import '../models/coupon_model.dart';

class CouponProvider with ChangeNotifier {
  final List<Coupon> _coupons = [];

  List<Coupon> get coupons {
    return [..._coupons];
  }

  void addCoupon(Coupon coupon) {
    _coupons.add(coupon);
    notifyListeners();
  }

  void updateCoupon(String id, Coupon updatedCoupon) {
    final index = _coupons.indexWhere((c) => c.id == id);
    if (index >= 0) {
      _coupons[index] = updatedCoupon;
      notifyListeners();
    }
  }

  void deleteCoupon(String id) {
    _coupons.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // TODO: Add methods for fetching/saving from API
}
