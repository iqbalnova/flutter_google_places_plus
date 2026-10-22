import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/id/gmedia/flutter_google_places_plus/Messages.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'id.gmedia.flutter_google_places_plus',
    ),
    swiftOut:
        'ios/flutter_google_places_plus/Sources/flutter_google_places_plus/Messages.g.swift',
    swiftOptions: SwiftOptions(),
  ),
)
class PlatformLatLng {
  PlatformLatLng({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
}

class PlatformLatLngBounds {
  PlatformLatLngBounds({required this.southwest, required this.northeast});
  final PlatformLatLng southwest;
  final PlatformLatLng northeast;
}

class PlatformCircularBounds {
  PlatformCircularBounds({required this.center, required this.radiusMeters});
  final PlatformLatLng center;
  final double radiusMeters;
}

class PlatformLocationBias {
  PlatformLocationBias({this.rectangular, this.circular});
  final PlatformLatLngBounds? rectangular;
  final PlatformCircularBounds? circular;
}

class PlatformLocationRestriction {
  PlatformLocationRestriction({this.rectangular, this.circular});
  final PlatformLatLngBounds? rectangular;
  final PlatformCircularBounds? circular;
}

class PlatformAutocompleteRequest {
  PlatformAutocompleteRequest({
    required this.query,
    this.sessionToken,
    this.countries,
    this.placeTypes,
    this.locationBias,
    this.locationRestriction,
    this.origin,
    this.regionCode,
    this.inputOffset,
  });

  final String query;
  final String? sessionToken;
  final List<String>? countries;
  final List<String>? placeTypes;
  final PlatformLocationBias? locationBias;
  final PlatformLocationRestriction? locationRestriction;
  final PlatformLatLng? origin;
  final String? regionCode;
  final int? inputOffset;
}

class PlatformAutocompletePrediction {
  PlatformAutocompletePrediction({
    required this.placeId,
    required this.fullText,
    required this.primaryText,
    this.secondaryText,
    required this.placeTypes,
    this.distanceMeters,
  });

  final String placeId;
  final String fullText;
  final String primaryText;
  final String? secondaryText;
  final List<String> placeTypes;
  final int? distanceMeters;
}

class PlatformAddressComponent {
  PlatformAddressComponent({
    required this.name,
    this.shortName,
    required this.types,
  });

  final String name;
  final String? shortName;
  final List<String> types;
}

enum PlatformPlaceField {
  id,
  displayName,
  formattedAddress,
  location,
  viewport,
  addressComponents,
  types,
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
}

class PlatformFetchPlaceRequest {
  PlatformFetchPlaceRequest({
    required this.placeId,
    required this.fields,
    this.sessionToken,
    this.regionCode,
  });

  final String placeId;
  final List<PlatformPlaceField> fields;
  final String? sessionToken;
  final String? regionCode;
}

class PlatformPlace {
  PlatformPlace({
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
  final PlatformLatLng? location;
  final PlatformLatLngBounds? viewport;
  final List<PlatformAddressComponent>? addressComponents;
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
}

@HostApi()
abstract class PlacesHostApi {
  void initialize(String apiKey, String? locale);

  @async
  List<PlatformAutocompletePrediction> findAutocompletePredictions(
    PlatformAutocompleteRequest request,
  );

  @async
  PlatformPlace fetchPlace(PlatformFetchPlaceRequest request);
}
