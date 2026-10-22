import 'package:flutter/foundation.dart';

import 'circular_bounds.dart';
import 'lat_lng_bounds.dart';

/// Defines an area to bias autocomplete results toward.
@immutable
class LocationBias {
  const LocationBias.rectangular(LatLngBounds bounds)
    : rectangular = bounds,
      circular = null;

  const LocationBias.circular(CircularBounds bounds)
    : circular = bounds,
      rectangular = null;

  final LatLngBounds? rectangular;
  final CircularBounds? circular;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationBias &&
          runtimeType == other.runtimeType &&
          rectangular == other.rectangular &&
          circular == other.circular;

  @override
  int get hashCode => Object.hash(rectangular, circular);

  @override
  String toString() => rectangular != null
      ? 'LocationBias.rectangular($rectangular)'
      : 'LocationBias.circular($circular)';
}
