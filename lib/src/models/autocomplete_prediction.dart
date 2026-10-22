import 'package:flutter/foundation.dart';

/// Autocomplete suggestion for a place based on a text query.
@immutable
class AutocompletePrediction {
  const AutocompletePrediction({
    required this.placeId,
    required this.fullText,
    required this.primaryText,
    this.secondaryText,
    required this.placeTypes,
    this.distanceMeters,
  });

  /// Unique stable identifier for the predicted place.
  final String placeId;

  /// Full formatted text describing the place (primary and secondary combined).
  final String fullText;

  /// Main text of the suggestion, usually the place name.
  final String primaryText;

  /// Subsidiary text of the suggestion (such as city, state, country).
  final String? secondaryText;

  /// List of place types associated with the prediction.
  final List<String> placeTypes;

  /// Straight-line distance in meters between the place and the requested origin.
  final int? distanceMeters;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutocompletePrediction &&
          runtimeType == other.runtimeType &&
          placeId == other.placeId &&
          fullText == other.fullText &&
          primaryText == other.primaryText &&
          secondaryText == other.secondaryText &&
          listEquals(placeTypes, other.placeTypes) &&
          distanceMeters == other.distanceMeters;

  @override
  int get hashCode => Object.hash(
    placeId,
    fullText,
    primaryText,
    secondaryText,
    Object.hashAll(placeTypes),
    distanceMeters,
  );

  @override
  String toString() =>
      'AutocompletePrediction(placeId: $placeId, primaryText: $primaryText, fullText: $fullText)';
}
