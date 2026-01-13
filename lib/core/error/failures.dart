import 'package:equatable/equatable.dart';
import 'error_context.dart';

/// Base class for all failures in the application.
/// 
/// **Design Philosophy:**
/// - Every failure MUST have context for debugging
/// - Failures are immutable value objects
/// - Use specific subclasses for different error categories
/// 
/// **Migration Guide (from old ServerFailure):**
/// ```dart
/// // OLD (BAD - no context)
/// return (const ServerFailure(), null);
/// 
/// // NEW (GOOD - with context)
/// return (DatabaseFailure(
///   'Failed to fetch recipes',
///   context: ErrorContext.repository('getRecipes'),
/// ), null);
/// ```
abstract class Failure extends Equatable {
  final String message;
  final ErrorContext context;

  const Failure(this.message, {required this.context});

  @override
  List<Object> get props => [message, context.operation, context.timestamp];

  /// Formats failure for logging/display
  /// 
  /// **Firebase Integration:**
  /// Use this in `FirebaseCrashlytics.instance.recordError()`:
  /// ```dart
  /// await FirebaseCrashlytics.instance.recordError(
  ///   failure,
  ///   failure.context.stackTrace,
  ///   reason: failure.toString(),
  /// );
  /// ```
  @override
  String toString() {
    return '${runtimeType}{message: $message, context: $context}';
  }

  /// Converts to Map for structured logging
  Map<String, dynamic> toMap() {
    return {
      'type': runtimeType.toString(),
      'message': message,
      'context': context.toMap(),
    };
  }
}

//
// ══════════════════════════════════════════════════════════════
// SPECIFIC FAILURE TYPES
// ══════════════════════════════════════════════════════════════
//

/// Database/Backend operation failed (Supabase, PostgreSQL)
/// 
/// **Common Causes:**
/// - Query syntax error
/// - Connection timeout
/// - Permission denied (RLS policy)
/// - Constraint violation
/// 
/// **Example:**
/// ```dart
/// DatabaseFailure(
///   'Failed to insert recipe: unique constraint violation',
///   context: ErrorContext.supabase('insert', extra: {'table': 'recipes'}),
/// )
/// ```
class DatabaseFailure extends Failure {
  const DatabaseFailure(
    super.message, {
    required super.context,
  });
}

/// Network connectivity issue
/// 
/// **Common Causes:**
/// - No internet connection
/// - DNS resolution failed
/// - Timeout
/// 
/// **Example:**
/// ```dart
/// NetworkFailure(
///   'Connection timeout after 30s',
///   context: ErrorContext.network('fetch', extra: {'url': apiUrl}),
/// )
/// ```
class NetworkFailure extends Failure {
  const NetworkFailure(
    super.message, {
    required super.context,
  });
}

/// Authentication or authorization failed
/// 
/// **Common Causes:**
/// - Invalid credentials
/// - Session expired
/// - Insufficient permissions
/// 
/// **Example:**
/// ```dart
/// AuthFailure(
///   'JWT token expired',
///   context: ErrorContext.supabase('auth.getSession'),
/// )
/// ```
class AuthFailure extends Failure {
  const AuthFailure(
    super.message, {
    required super.context,
  });
}

/// Input validation failed
/// 
/// **Common Causes:**
/// - Missing required field
/// - Invalid format (email, phone)
/// - Out of range value
/// 
/// **Example:**
/// ```dart
/// ValidationFailure(
///   'Email format invalid',
///   context: ErrorContext.repository('validateUser', extra: {'email': email}),
/// )
/// ```
class ValidationFailure extends Failure {
  const ValidationFailure(
    super.message, {
    required super.context,
  });
}

/// Generic server error (fallback for unknown errors)
/// 
/// **Usage:**
/// Only use when error doesn't fit other categories.
/// Prefer specific failures when possible for better debugging.
/// 
/// **Example:**
/// ```dart
/// ServerFailure(
///   'Unexpected error: ${exception.toString()}',
///   context: ErrorContext.repository('unknownOperation'),
/// )
/// ```
class ServerFailure extends Failure {
  const ServerFailure(
    super.message, {
    required super.context,
  });
}

/// Local cache operation failed
/// 
/// **Common Causes:**
/// - Storage full
/// - Permission denied
/// - Corrupted data
class CacheFailure extends Failure {
  const CacheFailure(
    super.message, {
    required super.context,
  });
}
