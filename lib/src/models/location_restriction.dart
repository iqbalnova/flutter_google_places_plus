import 'package:flutter/foundation.dart';

import 'circular_bounds.dart';
import 'lat_lng_bounds.dart';

/// Defines a strict boundary that autocomplete results must reside within.
@immutable
class LocationRestriction {
  const LocationRestriction.rectangular(LatLngBounds bounds)
    : rectangular = bounds,
      circular = null;

  const LocationRestriction.circular(CircularBounds bounds)
    : circular = bounds,
      rectangular = null;

  final LatLngBounds? rectangular;
  final CircularBounds? circular;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationRestriction &&
          runtimeType == other.runtimeType &&
          rectangular == other.rectangular &&
          circular == other.circular;

  @override
  int get hashCode => Object.hash(rectangular, circular);

  @override
  String toString() => rectangular != null
      ? 'LocationRestriction.rectangular($rectangular)'
      : 'LocationRestriction.circular($circular)';
}
