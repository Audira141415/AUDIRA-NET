import 'package:flutter/foundation.dart';

class Logger {
  static const String _prefix = '[AUDIRA]';

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix ℹ️ $message');
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix ✅ $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix ⚠️ $message');
    }
  }

  static void error(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('$_prefix ❌ $message${error != null ? ': $error' : ''}');
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix 🔧 $message');
    }
  }
}
