import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Helper class untuk password hashing dan verification
/// Menggunakan SHA-256 dengan salt untuk keamanan
class PasswordHelper {
  // Salt yang digunakan untuk hashing (dalam production, sebaiknya unique per user)
  static const String _salt = 'AudiraNet2025SecureApp';

  /// Hash password dengan SHA-256 + salt
  ///
  /// [password] Plain text password yang akan di-hash
  /// Returns hashed password dalam format hexadecimal
  static String hashPassword(String password) {
    try {
      // Gabungkan password dengan salt
      final saltedPassword = password + _salt;

      // Convert ke bytes
      final bytes = utf8.encode(saltedPassword);

      // Hash dengan SHA-256
      final digest = sha256.convert(bytes);

      // Return sebagai hex string
      return digest.toString();
    } catch (e) {
      throw Exception('Error hashing password: $e');
    }
  }

  /// Verify password dengan membandingkan hash
  ///
  /// [plainPassword] Password plain text yang diinput user
  /// [hashedPassword] Hashed password dari database
  /// Returns true jika password cocok
  static bool verifyPassword(String plainPassword, String hashedPassword) {
    try {
      final inputHash = hashPassword(plainPassword);
      return inputHash == hashedPassword;
    } catch (e) {
      return false;
    }
  }

  /// Validasi kekuatan password
  ///
  /// Returns Map dengan 'isValid' dan 'message'
  static Map<String, dynamic> validatePasswordStrength(String password) {
    if (password.length < 8) {
      return {'isValid': false, 'message': 'Password minimal 8 karakter'};
    }

    // Cek apakah ada huruf
    final hasLetter = password.contains(RegExp(r'[a-zA-Z]'));
    if (!hasLetter) {
      return {'isValid': false, 'message': 'Password harus mengandung huruf'};
    }

    // Cek apakah ada angka
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    if (!hasNumber) {
      return {'isValid': false, 'message': 'Password harus mengandung angka'};
    }

    return {'isValid': true, 'message': 'Password kuat'};
  }
}
