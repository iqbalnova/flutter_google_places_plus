import 'package:flutter/foundation.dart';

/// Geographical point represented by latitude and longitude coordinates.
@immutable
class LatLng {
  const LatLng(this.latitude, this.longitude)
    : assert(
        latitude >= -90.0 && latitude <= 90.0,
        'Latitude must be between -90 and 90 degrees',
      ),
      assert(
        longitude >= -180.0 && longitude <= 180.0,
        'Longitude must be between -180 and 180 degrees',
      );

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLng &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'LatLng($latitude, $longitude)';
}
