class Validators {
  // check null
  static String? _validateValue(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? validateUsername(String value) {
    // Empty / Null Value Check
    final emptyNullCheck = _validateValue(value, 'Username');
    if (emptyNullCheck != null) {
      return emptyNullCheck;
    }

    return null; // valid
  }

  static String? validateEmail(String value) {
    // Empty / Null Value Check
    final emptyNullCheck = _validateValue(value, 'Email address');
    if (emptyNullCheck != null) {
      return emptyNullCheck;
    }

    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email address.';
    }

    return null; // valid
  }

  static String? validatePassword(String value) {
    // Empty / Null Value Check
    final emptyNullCheck = _validateValue(value, 'Email address');
    if (emptyNullCheck != null) {
      return emptyNullCheck;
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }
}