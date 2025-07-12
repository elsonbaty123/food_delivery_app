import 'payment_method_type.dart';

class PaymentMethod {
  final String id;
  final String cardNumber;
  final String cardHolderName;
  final String expiryDate;
  final String cvv;
  final bool isDefault;
  final PaymentMethodType type;

  PaymentMethod({
    required this.id,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.cvv,
    PaymentMethodType? type,
    this.isDefault = false,
  }) : type = type ?? PaymentMethodType.creditCard;

  // Create a copyWith method for easy updates
  PaymentMethod copyWith({
    String? id,
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    String? cvv,
    PaymentMethodType? type,
    bool? isDefault,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // Convert PaymentMethod to Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'type': type.toString().split('.').last,
      'isDefault': isDefault,
    };
  }

  // Create PaymentMethod from Map
  factory PaymentMethod.fromJson(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'] ?? '',
      cardNumber: map['cardNumber'] ?? '',
      cardHolderName: map['cardHolderName'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      cvv: map['cvv'] ?? '',
      type: map['type'] != null
          ? PaymentMethodType.values.firstWhere(
              (e) => e.toString() == 'PaymentMethodType.${map['type']}',
              orElse: () => PaymentMethodType.creditCard,
            )
          : PaymentMethodType.creditCard,
      isDefault: map['isDefault'] ?? false,
    );
  }

  // Get the last 4 digits of the card number
  String get lastFourDigits {
    if (cardNumber.length <= 4) return cardNumber;
    return cardNumber.substring(cardNumber.length - 4);
  }

  // Get the card type icon
  String get cardTypeIcon {
    switch (type) {
      case PaymentMethodType.creditCard:
        return 'assets/icons/visa.png';
      case PaymentMethodType.debitCard:
        return 'assets/icons/mastercard.png';
      case PaymentMethodType.mada:
        return 'assets/icons/mada.png';
      case PaymentMethodType.applePay:
        return 'assets/icons/apple_pay.png';
      case PaymentMethodType.googlePay:
        return 'assets/icons/google_pay.png';
      default:
        return 'assets/icons/credit_card.png';
    }
  }
}
