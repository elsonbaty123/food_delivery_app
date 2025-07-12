class Validators {
  // Validation for name (Arabic and English letters, spaces, 2-50 chars)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال الاسم';
    }
    
    final nameRegExp = RegExp(r'^[\u0600-\u06FF\u0750-\u077F\sA-Za-z]{2,}(?:[\s-][\u0600-\u06FF\u0750-\u077F\sA-Za-z]+)*$');
    
    if (!nameRegExp.hasMatch(value.trim())) {
      return 'الرجاء إدخال اسم صحيح (حروف عربية/إنجليزية فقط)';
    }
    
    if (value.trim().length < 2) {
      return 'الاسم يجب أن يكون على الأقل حرفين';
    }
    
    if (value.trim().length > 50) {
      return 'الاسم يجب ألا يتجاوز 50 حرفاً';
    }
    
    return null;
  }

  // Validation for email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    
    // Simple email validation pattern
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'الرجاء إدخال بريد إلكتروني صحيح';
    }
    
    return null;
  }

  // Validation for phone number (supports international formats)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    
    // Remove any non-digit characters
    final phone = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Check for minimum and maximum length
    if (phone.length < 8) {
      return 'رقم الهاتف قصير جداً';
    }
    
    if (phone.length > 15) {
      return 'رقم الهاتف طويل جداً';
    }
    
    return null;
  }

  // Validation for password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل';
    }
    
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'يجب أن تحتوي كلمة المرور على رمز خاص واحد على الأقل';
    }
    
    return null;
  }

  // Validation for confirm password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'الرجاء تأكيد كلمة المرور';
    }
    
    if (value != password) {
      return 'كلمتا المرور غير متطابقتين';
    }
    
    return null;
  }
}
