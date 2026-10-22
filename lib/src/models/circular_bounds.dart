import 'package:flutter/foundation.dart';

import 'lat_lng.dart';

/// Circular geographic boundary defined by a center point and radius in meters.
@immutable
class CircularBounds {
  const CircularBounds({required this.center, required this.radiusMeters})
    : assert(
        radiusMeters >= 0.0 && radiusMeters <= 50000.0,
        'Radius must be between 0.0 and 50000.0 meters',
      );

  final LatLng center;
  final double radiusMeters;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CircularBounds &&
          runtimeType == other.runtimeType &&
          center == other.center &&
          radiusMeters == other.radiusMeters;

  @override
  int get hashCode => Object.hash(center, radiusMeters);

  @override
  String toString() =>
      'CircularBounds(center: $center, radiusMeters: $radiusMeters)';
}
