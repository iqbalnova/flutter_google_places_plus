import 'package:flutter/foundation.dart';

import 'lat_lng.dart';

/// Rectangular geographic bounding box defined by southwest and northeast coordinates.
@immutable
class LatLngBounds {
  const LatLngBounds({required this.southwest, required this.northeast});

  final LatLng southwest;
  final LatLng northeast;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLngBounds &&
          runtimeType == other.runtimeType &&
          southwest == other.southwest &&
          northeast == other.northeast;

  @override
  int get hashCode => Object.hash(southwest, northeast);

  @override
  String toString() =>
      'LatLngBounds(southwest: $southwest, northeast: $northeast)';
}
