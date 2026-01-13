import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static bool _isEnabled = kDebugMode;

  static void enableLogs(bool enable) {
    _isEnabled = enable;
    i('Logging ${enable ? 'ENABLED' : 'DISABLED'}');
  }

  static bool get isEnabled => _isEnabled;

  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!_isEnabled) return;
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!_isEnabled) return;
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!_isEnabled) return;
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    // Errors might always be logged, or controlled by the same flag. 
    // Usually we want to see errors from Release builds in Crashlytics, but for console logs:
    if (!_isEnabled && !kReleaseMode) return; 
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
