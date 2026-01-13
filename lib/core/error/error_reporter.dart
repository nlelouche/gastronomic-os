import 'package:flutter/foundation.dart';
import '../util/app_logger.dart';
import 'failures.dart';

/// Service interface for error reporting.
/// 
/// **Design Pattern: Strategy / Service**
/// 
/// This allows us to swap implementations without changing code:
/// - Development: `DebugErrorReporter` (logs to console)
/// - Production: `FirebaseErrorReporter` (sends to Crashlytics)
/// - Testing: `MockErrorReporter` (for unit tests)
/// 
/// **Benefits:**
/// - Testability (easy mocking)
/// - Flexibility (switch services: Firebase → Sentry → custom)
/// - SOLID principles (Dependency Inversion)
/// 
/// **Current Implementation:**
/// Using Singleton pattern via `ErrorReporter.instance` for convenience,
/// but can be injected via DI if preferred.
abstract class IErrorReporter {
  /// Reports a Failure (structured error)
  /// 
  /// **Parameters:**
  /// - `failure`: The failure object with context
  /// - `fatal`: Whether this error should crash the app (default: false)
  /// 
  /// **Example:**
  /// ```dart
  /// await ErrorReporter.instance.reportError(
  ///   DatabaseFailure('Query failed', context: ctx),
  ///   fatal: true,
  /// );
  /// ```
  Future<void> reportError(Failure failure, {bool fatal = false});

  /// Reports a raw exception (for unexpected/uncaught errors)
  /// 
  /// **Example:**
  /// ```dart
  /// try {
  ///   riskyOperation();
  /// } catch (e, stack) {
  ///   await ErrorReporter.instance.reportException(e, stack);
  /// }
  /// ```
  Future<void> reportException(Object error, StackTrace stackTrace);
}

//
// ══════════════════════════════════════════════════════════════
// DEBUG IMPLEMENTATION (Default)
// ══════════════════════════════════════════════════════════════
//

/// Debug implementation that logs errors to console using AppLogger.
/// 
/// **Usage:**
/// Automatically used in development. No configuration needed.
/// 
/// **Output Format:**
/// ```
/// [ERROR] [Repository.getRecipes] Failed to fetch recipes
/// Context: {userId: 123, limit: 20, offset: 0}
/// Stack trace: ...
/// ```
class DebugErrorReporter implements IErrorReporter {
  @override
  Future<void> reportError(Failure failure, {bool fatal = false}) async {
    if (kDebugMode) {
      AppLogger.e(
        '[${failure.context.operation}] ${failure.message}',
        failure,
        failure.context.stackTrace,
      );

      // Log context metadata for debugging
      if (failure.context.metadata.isNotEmpty) {
        AppLogger.d('Context metadata: ${failure.context.metadata}');
      }

      if (fatal) {
        AppLogger.e('⚠️  FATAL ERROR - This would crash in production!');
      }
    }
  }

  @override
  Future<void> reportException(Object error, StackTrace stackTrace) async {
    if (kDebugMode) {
      AppLogger.e('Uncaught exception', error, stackTrace);
    }
  }
}

//
// ══════════════════════════════════════════════════════════════
// FIREBASE CRASHLYTICS IMPLEMENTATION (Future)
// ══════════════════════════════════════════════════════════════
//

/// **IMPLEMENTATION GUIDE FOR FIREBASE CRASHLYTICS**
/// 
/// **Step 1: Add dependency**
/// ```yaml
/// # pubspec.yaml
/// dependencies:
///   firebase_core: ^2.24.0
///   firebase_crashlytics: ^3.4.0
/// ```
/// 
/// **Step 2: Initialize Firebase**
/// ```dart
/// // lib/main.dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp();
///   
///   // Set up Crashlytics
///   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
///   
///   // Switch to Firebase reporter in production
///   if (kReleaseMode) {
///     ErrorReporter._instance = FirebaseErrorReporter();
///   }
///   
///   runApp(const MyApp());
/// }
/// ```
/// 
/// **Step 3: Uncomment implementation below**
///
/// ```dart
/// class FirebaseErrorReporter implements IErrorReporter {
///   @override
///   Future<void> reportError(Failure failure, {bool fatal = false}) async {
///     final crashlytics = FirebaseCrashlytics.instance;
///     
///     // Set custom keys from context
///     await crashlytics.setCustomKey('operation', failure.context.operation);
///     await crashlytics.setCustomKey('userId', failure.context.userId ?? 'unknown');
///     await crashlytics.setCustomKey('timestamp', failure.context.timestamp.toIso8601String());
///     
///     // Set all metadata as custom keys
///     for (final entry in failure.context.metadata.entries) {
///       await crashlytics.setCustomKey(entry.key, entry.value.toString());
///     }
///     
///     // Record the error
///     await crashlytics.recordError(
///       failure,
///       failure.context.stackTrace,
///       reason: failure.message,
///       fatal: fatal,
///     );
///     
///     // Log to console in debug mode too
///     if (kDebugMode) {
///       await DebugErrorReporter().reportError(failure, fatal: fatal);
///     }
///   }
///   
///   @override
///   Future<void> reportException(Object error, StackTrace stackTrace) async {
///     await FirebaseCrashlytics.instance.recordError(error, stackTrace);
///   }
/// }
/// ```
/// 
/// **Step 4: (Optional) Test Crashlytics**
/// ```dart
/// // In debug mode, force a test crash
/// FirebaseCrashlytics.instance.crash(); // Only for testing setup!
/// ```

//
// ══════════════════════════════════════════════════════════════
// SINGLETON ACCESSOR (Convenience)
// ══════════════════════════════════════════════════════════════
//

/// Global accessor for error reporter.
/// 
/// **Default:** Uses `DebugErrorReporter` (logs to console)
/// **Production:** Override in main.dart with `FirebaseErrorReporter`
/// 
/// **Example Override:**
/// ```dart
/// void main() {
///   if (kReleaseMode) {
///     ErrorReporter._instance = FirebaseErrorReporter();
///   }
///   runApp(MyApp());
/// }
/// ```
class ErrorReporter {
  static IErrorReporter _instance = DebugErrorReporter();

  /// Get the current error reporter instance
  static IErrorReporter get instance => _instance;

  /// Override the default reporter (for production/testing)
  /// 
  /// **Usage:**
  /// ```dart
  /// ErrorReporter.setInstance(FirebaseErrorReporter());
  /// ```
  static void setInstance(IErrorReporter reporter) {
    _instance = reporter;
  }
}
