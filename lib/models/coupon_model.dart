class Coupon {
  final String id;
  final String code;
  final double discountValue;
  final bool isPercentage;
  final DateTime expiryDate;
  final List<String> eligibleMealIds;
  final int maxUses;
  final int usedCount;
  final DateTime createdAt;

  Coupon({
    required this.id,
    required this.code,
    required this.discountValue,
    this.isPercentage = true,
    required this.expiryDate,
    required this.eligibleMealIds,
    this.maxUses = 100,
    this.usedCount = 0,
    required this.createdAt,
  });

  bool get isExpired => expiryDate.isBefore(DateTime.now());
  bool get isAvailable => !isExpired && usedCount < maxUses;
}
