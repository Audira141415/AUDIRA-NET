class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }

    final phoneRegex = RegExp(r'^(\+62|62|0)[0-9]{9,12}$');
    final cleaned = value.replaceAll(RegExp(r'\D'), '');

    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Format nomor telepon tidak valid';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }

    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  // Numeric validation
  static String? validateNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nilai tidak boleh kosong';
    }

    if (int.tryParse(value) == null) {
      return 'Harus berupa angka';
    }

    return null;
  }

  // Min length validation
  static String? validateMinLength(String? value, int minLength) {
    if (value == null || value.isEmpty) {
      return 'Nilai tidak boleh kosong';
    }

    if (value.length < minLength) {
      return 'Minimal $minLength karakter';
    }

    return null;
  }

  // Max length validation
  static String? validateMaxLength(String? value, int maxLength) {
    if (value == null) return null;

    if (value.length > maxLength) {
      return 'Maksimal $maxLength karakter';
    }

    return null;
  }
}
