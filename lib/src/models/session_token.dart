import 'dart:math';

import 'package:flutter/foundation.dart';

/// User-generated token that tracks Autocomplete calls as a billing session.
///
/// A session begins with the first autocomplete query and concludes with a single
/// follow-up call to fetchPlace.
@immutable
class AutocompleteSessionToken {
  const AutocompleteSessionToken(this.value);

  /// Generates a new cryptographically pseudo-random session token.
  factory AutocompleteSessionToken.newInstance() {
    final random = Random.secure();
    final values = List<int>.generate(16, (_) => random.nextInt(256));
    // Set UUID version 4 and variant
    values[6] = (values[6] & 0x0f) | 0x40;
    values[8] = (values[8] & 0x3f) | 0x80;

    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final uuid =
        '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
    return AutocompleteSessionToken(uuid);
  }

  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutocompleteSessionToken &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'AutocompleteSessionToken($value)';
}
