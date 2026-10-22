import 'package:flutter/foundation.dart';

/// Exception thrown by the Google Places plugin.
@immutable
class PlacesException implements Exception {
  const PlacesException({
    required this.code,
    required this.message,
    this.details,
  });

  /// The error code identifier (e.g. 'NOT_INITIALIZED', 'INVALID_ARGUMENT', 'API_ERROR').
  final String code;

  /// Human-readable error message.
  final String message;

  /// Optional underlying details or debug information.
  final Object? details;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlacesException &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message;

  @override
  int get hashCode => Object.hash(code, message);

  @override
  String toString() => 'PlacesException($code: $message)';
}
