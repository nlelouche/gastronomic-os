import 'package:flutter/foundation.dart';

/// Rich context for errors providing detailed debugging information.
/// 
/// This class captures comprehensive metadata about where and why an error occurred,
/// making debugging in production environments significantly easier.
/// 
/// **Usage Example:**
/// ```dart
/// final context = ErrorContext.repository(
///   'fetchRecipes',
///   extra: {'userId': currentUser.id, 'limit': 20},
/// );
/// ```
@immutable
class ErrorContext {
  /// Name of the operation that failed (e.g., 'fetchRecipes', 'saveInventoryItem')
  final String operation;

  /// Additional metadata relevant to the error
  /// Common keys: userId, entityId, request params, response codes
  final Map<String, dynamic> metadata;

  /// When the error occurred (UTC)
  final DateTime timestamp;

  /// Stack trace at the point of error creation
  final StackTrace? stackTrace;

  /// User ID if available (useful for user-specific debugging)
  final String? userId;

  ErrorContext({
    required this.operation,
    this.metadata = const {},
    DateTime? timestamp,
    this.stackTrace,
    this.userId,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates context for Supabase operations
  /// 
  /// **Example:**
  /// ```dart
  /// ErrorContext.supabase('select', extra: {'table': 'recipes', 'filter': 'id=123'})
  /// ```
  factory ErrorContext.supabase(
    String operation, {
    Map<String, dynamic>? extra,
    String? userId,
    StackTrace? stackTrace,
  }) {
    return ErrorContext(
      operation: 'Supabase.$operation',
      metadata: {
        'source': 'supabase',
        ...?extra,
      },
      userId: userId,
      stackTrace: stackTrace,
    );
  }

  /// Creates context for repository operations
  /// 
  /// **Example:**
  /// ```dart
  /// ErrorContext.repository('getRecipes', extra: {'limit': 20, 'offset': 0})
  /// ```
  factory ErrorContext.repository(
    String operation, {
    Map<String, dynamic>? extra,
    String? userId,
    StackTrace? stackTrace,
  }) {
    return ErrorContext(
      operation: 'Repository.$operation',
      metadata: {
        'source': 'repository',
        ...?extra,
      },
      userId: userId,
      stackTrace: stackTrace,
    );
  }

  /// Creates context for network operations
  factory ErrorContext.network(
    String operation, {
    Map<String, dynamic>? extra,
    String? userId,
    StackTrace? stackTrace,
  }) {
    return ErrorContext(
      operation: 'Network.$operation',
      metadata: {
        'source': 'network',
        ...?extra,
      },
      userId: userId,
      stackTrace: stackTrace,
    );
  }

  /// Converts to Map for logging/serialization
  /// 
  /// **Firebase Integration Note:**
  /// When integrating Firebase Crashlytics, use this method to attach custom keys:
  /// ```dart
  /// await FirebaseCrashlytics.instance.setCustomKey('operation', context.operation);
  /// context.toMap().forEach((key, value) {
  ///   FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
  /// });
  /// ```
  Map<String, dynamic> toMap() {
    return {
      'operation': operation,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'metadata': metadata,
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    };
  }

  /// Creates a copy with updated fields
  ErrorContext copyWith({
    String? operation,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
    StackTrace? stackTrace,
    String? userId,
  }) {
    return ErrorContext(
      operation: operation ?? this.operation,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'ErrorContext{operation: $operation, timestamp: $timestamp, userId: $userId, metadata: $metadata}';
  }
}
