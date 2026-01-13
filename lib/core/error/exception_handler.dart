import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'error_context.dart';
import 'failures.dart';

/// Centralized exception handling and conversion to typed Failures.
/// 
/// **Purpose:**
/// Converts raw exceptions (PostgrestException, SocketException, etc.) into
/// strongly-typed Failure objects with rich context.
/// 
/// **Benefits:**
/// - Consistent error handling across the app
/// - Automatic context extraction from Supabase errors
/// - Type-safe error categorization
/// 
/// **Usage in Repositories:**
/// ```dart
/// try {
///   final result = await remoteDataSource.getRecipes();
///   return (null, result);
/// } catch (e, stackTrace) {
///   final failure = ExceptionHandler.handle(
///     e,
///     stackTrace: stackTrace,
///     context: ErrorContext.repository('getRecipes', extra: {'limit': 20}),
///   );
///   return (failure, null);
/// }
/// ```
class ExceptionHandler {
  /// Converts any exception to appropriate Failure type
  /// 
  /// **Exception Mapping:**
  /// - `PostgrestException` → `DatabaseFailure`
  /// - `AuthException` → `AuthFailure`
  /// - `SocketException`, `HttpException` → `NetworkFailure`
  /// - `FormatException`, `TypeError` → `ValidationFailure`
  /// - Unknown → `ServerFailure` (fallback)
  static Failure handle(
    Object exception, {
    StackTrace? stackTrace,
    required ErrorContext context,
  }) {
    // Update context with stack trace if available
    final enrichedContext = context.copyWith(
      stackTrace: stackTrace ?? StackTrace.current,
    );

    // Supabase database errors
    if (exception is PostgrestException) {
      return DatabaseFailure(
        _extractPostgrestMessage(exception),
        context: enrichedContext.copyWith(
          metadata: {
            ...enrichedContext.metadata,
            'postgrest_code': exception.code,
            'postgrest_details': exception.details,
            'postgrest_hint': exception.hint,
          },
        ),
      );
    }

    // Supabase auth errors
    if (exception is AuthException) {
      return AuthFailure(
        exception.message,
        context: enrichedContext.copyWith(
          metadata: {
            ...enrichedContext.metadata,
            'auth_status_code': exception.statusCode,
          },
        ),
      );
    }

    // Network errors
    if (exception is SocketException || exception is HttpException) {
      return NetworkFailure(
        'Network error: ${exception.toString()}',
        context: enrichedContext.copyWith(
          metadata: {
            ...enrichedContext.metadata,
            'network_error_type': exception.runtimeType.toString(),
          },
        ),
      );
    }

    // Validation errors
    if (exception is FormatException || exception is TypeError) {
      return ValidationFailure(
        'Validation error: ${exception.toString()}',
        context: enrichedContext,
      );
    }

    // Fallback for unknown exceptions
    return ServerFailure(
      'Unexpected error: ${exception.toString()}',
      context: enrichedContext.copyWith(
        metadata: {
          ...enrichedContext.metadata,
          'exception_type': exception.runtimeType.toString(),
        },
      ),
    );
  }

  /// Extracts human-readable message from PostgrestException
  /// 
  /// **Priority:**
  /// 1. message (if not generic)
  /// 2. hint (developer guidance)
  /// 3. details (technical info)
  /// 4. code (error code)
  static String _extractPostgrestMessage(PostgrestException exception) {
    if (exception.message.isNotEmpty && exception.message != 'null') {
      return exception.message;
    }
    if (exception.hint != null && exception.hint!.isNotEmpty) {
      return exception.hint!;
    }
    if (exception.details != null) {
      return 'Database error: ${exception.details}';
    }
    return 'Database error (code: ${exception.code})';
  }
}
