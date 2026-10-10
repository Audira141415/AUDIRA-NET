import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class LoggerService {
  static const String _tag = 'AudiraApp';

  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      _log(LogLevel.debug, message, tag);
    }
  }

  static void info(String message, [String? tag]) {
    _log(LogLevel.info, message, tag);
  }

  static void warning(String message, [String? tag]) {
    _log(LogLevel.warning, message, tag);
  }

  static void error(
    String message, [
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log(LogLevel.error, message, tag);
    if (error != null) {
      _log(LogLevel.error, 'Error: $error', tag);
    }
    if (stackTrace != null) {
      _log(LogLevel.error, 'StackTrace: $stackTrace', tag);
    }
  }

  static void _log(LogLevel level, String message, String? tag) {
    if (kDebugMode) {
      final logTag = tag ?? _tag;
      final levelStr = level.toString().split('.').last.toUpperCase();
      developer.log('[$levelStr] $message', name: logTag, time: DateTime.now());
    }
  }

  // Database specific logging
  static void dbInfo(String message) {
    info(message, 'DatabaseService');
  }

  static void dbError(String message, [Object? error, StackTrace? stackTrace]) {
    LoggerService.error(message, 'DatabaseService', error, stackTrace);
  }

  // Auth specific logging
  static void authInfo(String message) {
    info(message, 'AuthService');
  }

  static void authError(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    LoggerService.error(message, 'AuthService', error, stackTrace);
  }

  // UI specific logging
  static void uiInfo(String message) {
    info(message, 'UI');
  }

  static void uiError(String message, [Object? error, StackTrace? stackTrace]) {
    LoggerService.error(message, 'UI', error, stackTrace);
  }
}
