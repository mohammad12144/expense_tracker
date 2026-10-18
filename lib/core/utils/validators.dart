
class Validators {
  static String? required(String? value, {String message = 'Required'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().length < 2) return 'Enter your name';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!value.contains('@') || !value.contains('.')) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'At least 6 characters';
    return null;
  }

  /// للتحقق من تطابق حقلين (مثل تأكيد كلمة المرور)
  static String? Function(String?) matches(String Function() other,
      {String message = 'Passwords do not match'}) {
    return (value) => value != other() ? message : null;
  }

  static String? amount(String? value) {
    final amount = double.tryParse(value ?? '');
    if (amount == null) return 'Enter a valid number';
    if (amount <= 0) return 'Must be greater than 0';
    return null;
  }
}