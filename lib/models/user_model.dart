
enum UserType {
  customer,
  chef,
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? imageUrl;
  final List<Address> addresses;
  final List<PaymentMethod> paymentMethods;
  final List<String> favoriteMealIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, bool> notificationPreferences;
  final double? rating; // User's average rating (0.0 to 5.0)
  final List<dynamic>? coupons; // List of coupon IDs or coupon objects
  final List<dynamic>? orderHistory; // List of order IDs or order objects
  final String profileImageUrl; // URL to the user's profile image
  final UserType userType; // Type of user (customer or chef)

  // Check if notifications are enabled (default to true if not set)
  bool get notificationsEnabled => notificationPreferences['order_updates'] ?? true;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.userType = UserType.customer, // Default to customer
    this.phoneNumber,
    this.imageUrl,
    List<Address>? addresses,
    List<PaymentMethod>? paymentMethods,
    List<String>? favoriteMealIds,
    this.rating,
    List<dynamic>? coupons,
    List<dynamic>? orderHistory,
    this.profileImageUrl = '',
    this.createdAt,
    this.updatedAt,
    Map<String, bool>? notificationPreferences,
  }) : addresses = addresses ?? [],
       paymentMethods = paymentMethods ?? [],
       favoriteMealIds = favoriteMealIds ?? [],
       coupons = coupons ?? [],
       orderHistory = orderHistory ?? [],
       notificationPreferences = notificationPreferences ?? {
         'order_updates': true,
         'promotions': true,
         'new_meals': true,
         'account_activity': true,
       };

  // Convert UserModel to a Map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'imageUrl': imageUrl,
      'addresses': addresses.map((a) => a.toMap()).toList(),
      'paymentMethods': paymentMethods.map((p) => p.toMap()).toList(),
      'favoriteMealIds': favoriteMealIds,
      'rating': rating,
      'coupons': coupons,
      'orderHistory': orderHistory,
      'profileImageUrl': profileImageUrl,
      'userType': userType.toString().split('.').last,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notificationPreferences': notificationPreferences,
    };
  }

  // Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      imageUrl: json['imageUrl'],
      addresses: (json['addresses'] as List?)?.map((a) => Address.fromMap(a)).toList() ?? [],
      paymentMethods: (json['paymentMethods'] as List?)?.map((p) => PaymentMethod.fromMap(p)).toList() ?? [],
      favoriteMealIds: List<String>.from(json['favoriteMealIds'] ?? []),
      rating: json['rating']?.toDouble(),
      coupons: json['coupons'],
      orderHistory: json['orderHistory'],
      profileImageUrl: json['profileImageUrl'] ?? '',
      userType: UserType.values.firstWhere((element) => element.toString().split('.').last == json['userType']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      notificationPreferences: Map<String, bool>.from(json['notificationPreferences'] ?? {}),
    );
  }

  // Convert a User to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'imageUrl': imageUrl,
      'addresses': addresses.map((addr) => addr.toMap()).toList(),
      'paymentMethods': paymentMethods.map((pm) => pm.toMap()).toList(),
      'favoriteMealIds': favoriteMealIds,
      'notification_preferences': notificationPreferences,
      'userType': userType.toString().split('.').last,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create a User from a Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      imageUrl: map['imageUrl'],
      addresses: map['addresses'] != null
          ? (map['addresses'] as List)
              .map((addr) => Address.fromMap(addr))
              .toList()
          : [],
      paymentMethods: map['paymentMethods'] != null
          ? (map['paymentMethods'] as List)
              .map((pm) => PaymentMethod.fromMap(pm))
              .toList()
          : [],
      favoriteMealIds: List<String>.from(map['favoriteMealIds'] ?? []),
      notificationPreferences: map['notification_preferences'] != null
          ? Map<String, bool>.from(map['notification_preferences'])
          : null,
      userType: UserType.values.firstWhere((element) => element.toString().split('.').last == map['userType']),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  // Create a copy of the user with some updated values
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? imageUrl,
    List<Address>? addresses,
    List<PaymentMethod>? paymentMethods,
    List<String>? favoriteMealIds,
    double? rating,
    List<dynamic>? coupons,
    List<dynamic>? orderHistory,
    String? profileImageUrl,
    UserType? userType,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, bool>? notificationPreferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      addresses: addresses ?? this.addresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      favoriteMealIds: favoriteMealIds ?? this.favoriteMealIds,
      rating: rating ?? this.rating,
      coupons: coupons ?? this.coupons,
      orderHistory: orderHistory ?? this.orderHistory,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
    );
  }
}

class Address {
  final String id;
  final String title;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? state;
  final String postalCode;
  final String country;
  final bool isDefault;
  final String? notes;

  const Address({
    required this.id,
    required this.title,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.state,
    required this.postalCode,
    required this.country,
    this.isDefault = false,
    this.notes,
  });

  // Convert an Address to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
      'notes': notes,
    };
  }

  // Create an Address from a Map
  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      addressLine1: map['addressLine1'] ?? '',
      addressLine2: map['addressLine2'],
      city: map['city'] ?? '',
      state: map['state'],
      postalCode: map['postalCode'] ?? '',
      country: map['country'] ?? '',
      isDefault: map['isDefault'] ?? false,
      notes: map['notes'],
    );
  }

  // Create a copy of the address with some updated values
  Address copyWith({
    String? id,
    String? title,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isDefault,
    String? notes,
  }) {
    return Address(
      id: id ?? this.id,
      title: title ?? this.title,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      notes: notes ?? this.notes,
    );
  }

  // Get the full address as a formatted string
  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2,
      city,
      if (state != null && state!.isNotEmpty) state,
      postalCode,
      country,
    ];
    return parts.where((part) => part != null && part.isNotEmpty).join(', ');
  }
}

class PaymentMethod {
  final String id;
  final String cardNumber;
  final String cardHolderName;
  final String expiryDate; // Format: MM/YY
  final String cardType; // e.g., 'visa', 'mastercard', etc.
  final bool isDefault;

  const PaymentMethod({
    required this.id,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.cardType,
    this.isDefault = false,
  });

  // Convert a PaymentMethod to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryDate': expiryDate,
      'cardType': cardType,
      'isDefault': isDefault,
    };
  }

  // Create a PaymentMethod from a Map
  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'] ?? '',
      cardNumber: map['cardNumber'] ?? '',
      cardHolderName: map['cardHolderName'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      cardType: map['cardType'] ?? 'unknown',
      isDefault: map['isDefault'] ?? false,
    );
  }

  // Get the last 4 digits of the card number
  String get lastFourDigits {
    if (cardNumber.length <= 4) return cardNumber;
    return cardNumber.substring(cardNumber.length - 4);
  }

  // Get a masked card number (e.g., •••• 1234)
  String get maskedCardNumber {
    if (cardNumber.length <= 4) return '••••';
    return '•••• ${cardNumber.substring(cardNumber.length - 4)}';
  }

  // Create a copy of this payment method with the given fields replaced with new values
  PaymentMethod copyWith({
    String? id,
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    String? cardType,
    bool? isDefault,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryDate: expiryDate ?? this.expiryDate,
      cardType: cardType ?? this.cardType,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
