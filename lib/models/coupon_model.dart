class Coupon {
  final String id;
  final String code;
  final double discountValue;
  final bool isPercentage;
  final DateTime expiryDate;
  final List<String> eligibleMealIds;
  final int? maxUses; // Nullable for unlimited uses
  final int usedCount;
  final DateTime createdAt;

  Coupon({
    required this.id,
    required this.code,
    required this.discountValue,
    this.isPercentage = true,
    required this.expiryDate,
    required this.eligibleMealIds,
    this.maxUses, // Optional
    this.usedCount = 0,
    required this.createdAt,
  });

  bool get isExpired => expiryDate.isBefore(DateTime.now());
  bool get isAvailable {
    if (isExpired) return false;
    if (maxUses == null) return true; // Unlimited uses
    return usedCount < maxUses!;
  }

  Coupon copyWith({
    String? id,
    String? code,
    double? discountValue,
    bool? isPercentage,
    DateTime? expiryDate,
    List<String>? eligibleMealIds,
    int? maxUses,
    int? usedCount,
    DateTime? createdAt,
  }) {
    return Coupon(
      id: id ?? this.id,
      code: code ?? this.code,
      discountValue: discountValue ?? this.discountValue,
      isPercentage: isPercentage ?? this.isPercentage,
      expiryDate: expiryDate ?? this.expiryDate,
      eligibleMealIds: eligibleMealIds ?? this.eligibleMealIds,
      maxUses: maxUses ?? this.maxUses,
      usedCount: usedCount ?? this.usedCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
