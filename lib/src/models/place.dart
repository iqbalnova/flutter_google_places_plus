import 'package:flutter/foundation.dart';

import 'address_component.dart';
import 'lat_lng.dart';
import 'lat_lng_bounds.dart';

/// Detailed information about a place.
@immutable
class Place {
  const Place({
    this.id,
    this.displayName,
    this.formattedAddress,
    this.location,
    this.viewport,
    this.addressComponents,
    this.types,
    this.primaryType,
    this.internationalPhoneNumber,
    this.nationalPhoneNumber,
    this.rating,
    this.userRatingCount,
    this.businessStatus,
    this.priceLevel,
    this.websiteUri,
    this.googleMapsUri,
    this.iconMaskUrl,
    this.iconBackgroundColor,
    this.utcOffsetMinutes,
  });

  final String? id;
  final String? displayName;
  final String? formattedAddress;
  final LatLng? location;
  final LatLngBounds? viewport;
  final List<AddressComponent>? addressComponents;
  final List<String>? types;
  final String? primaryType;
  final String? internationalPhoneNumber;
  final String? nationalPhoneNumber;
  final double? rating;
  final int? userRatingCount;
  final String? businessStatus;
  final int? priceLevel;
  final String? websiteUri;
  final String? googleMapsUri;
  final String? iconMaskUrl;
  final String? iconBackgroundColor;
  final int? utcOffsetMinutes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Place &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayName == other.displayName &&
          formattedAddress == other.formattedAddress &&
          location == other.location &&
          viewport == other.viewport &&
          listEquals(addressComponents, other.addressComponents) &&
          listEquals(types, other.types) &&
          primaryType == other.primaryType &&
          internationalPhoneNumber == other.internationalPhoneNumber &&
          nationalPhoneNumber == other.nationalPhoneNumber &&
          rating == other.rating &&
          userRatingCount == other.userRatingCount &&
          businessStatus == other.businessStatus &&
          priceLevel == other.priceLevel &&
          websiteUri == other.websiteUri &&
          googleMapsUri == other.googleMapsUri &&
          iconMaskUrl == other.iconMaskUrl &&
          iconBackgroundColor == other.iconBackgroundColor &&
          utcOffsetMinutes == other.utcOffsetMinutes;

  @override
  int get hashCode => Object.hashAll([
    id,
    displayName,
    formattedAddress,
    location,
    viewport,
    addressComponents != null ? Object.hashAll(addressComponents!) : null,
    types != null ? Object.hashAll(types!) : null,
    primaryType,
    internationalPhoneNumber,
    nationalPhoneNumber,
    rating,
    userRatingCount,
    businessStatus,
    priceLevel,
    websiteUri,
    googleMapsUri,
    iconMaskUrl,
    iconBackgroundColor,
    utcOffsetMinutes,
  ]);

  @override
  String toString() =>
      'Place(id: $id, displayName: $displayName, formattedAddress: $formattedAddress, location: $location)';
}
