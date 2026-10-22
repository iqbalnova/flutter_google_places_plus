import 'dart:ui' show Locale;

import 'package:flutter/services.dart';

import 'messages.g.dart';
import 'models/address_component.dart';
import 'models/autocomplete_prediction.dart';
import 'models/circular_bounds.dart';
import 'models/lat_lng.dart';
import 'models/lat_lng_bounds.dart';
import 'models/location_bias.dart';
import 'models/location_restriction.dart';
import 'models/place.dart';
import 'models/place_field.dart';
import 'models/places_exception.dart';
import 'models/session_token.dart';

/// Client for Google Places SDK.
class FlutterGooglePlacesPlus {
  FlutterGooglePlacesPlus({PlacesHostApi? api}) : _api = api ?? PlacesHostApi();

  final PlacesHostApi _api;
  bool _initialized = false;

  /// Whether the plugin has been initialized with an API key.
  bool get isInitialized => _initialized;

  /// Initializes the Places SDK with the provided [apiKey].
  ///
  /// Optionally supply a [locale] to format names and addresses in the preferred language.
  Future<void> initialize({required String apiKey, Locale? locale}) async {
    final trimmedKey = apiKey.trim();
    if (trimmedKey.isEmpty) {
      throw const PlacesException(
        code: 'INVALID_ARGUMENT',
        message: 'API key must not be empty.',
      );
    }

    try {
      final localeString = locale != null
          ? (locale.countryCode != null
                ? '${locale.languageCode}_${locale.countryCode}'
                : locale.languageCode)
          : null;
      await _api.initialize(trimmedKey, localeString);
      _initialized = true;
    } on PlatformException catch (e) {
      throw _mapPlatformException(e);
    } catch (e) {
      throw PlacesException(code: 'UNKNOWN', message: e.toString(), details: e);
    }
  }

  /// Creates a new [AutocompleteSessionToken] to group an autocomplete query
  /// and place selection into a single billing session.
  AutocompleteSessionToken newSessionToken() =>
      AutocompleteSessionToken.newInstance();

  /// Retrieves autocomplete predictions for a user query string.
  ///
  /// - [query]: Partial search query text.
  /// - [sessionToken]: Session token tracking this autocomplete session.
  /// - [countries]: Up to 5 two-letter ISO 3166-1 alpha-2 country codes to restrict results.
  /// - [placeTypes]: Up to 5 place type filters.
  /// - [locationBias]: Prefer results within this boundary.
  /// - [locationRestriction]: Restrict results strictly within this boundary.
  /// - [origin]: Coordinates used to compute straight-line distance to predictions.
  /// - [regionCode]: Two-letter CLDR/ccTLD region code to influence formatting.
  /// - [inputOffset]: Zero-based character cursor position within [query].
  Future<List<AutocompletePrediction>> findAutocompletePredictions({
    required String query,
    AutocompleteSessionToken? sessionToken,
    List<String>? countries,
    List<String>? placeTypes,
    LocationBias? locationBias,
    LocationRestriction? locationRestriction,
    LatLng? origin,
    String? regionCode,
    int? inputOffset,
  }) async {
    if (query.trim().isEmpty) {
      return const <AutocompletePrediction>[];
    }

    if (locationBias != null && locationRestriction != null) {
      throw const PlacesException(
        code: 'INVALID_ARGUMENT',
        message: 'Cannot specify both locationBias and locationRestriction in the same request.',
      );
    }

    try {
      final platformRequest = PlatformAutocompleteRequest(
        query: query,
        sessionToken: sessionToken?.value,
        countries: countries,
        placeTypes: placeTypes,
        locationBias: _mapLocationBias(locationBias),
        locationRestriction: _mapLocationRestriction(locationRestriction),
        origin: origin != null ? _mapLatLng(origin) : null,
        regionCode: regionCode,
        inputOffset: inputOffset,
      );

      final platformResults = await _api.findAutocompletePredictions(
        platformRequest,
      );

      return platformResults.map(_mapPrediction).toList(growable: false);
    } on PlatformException catch (e) {
      throw _mapPlatformException(e);
    } catch (e) {
      if (e is PlacesException) rethrow;
      throw PlacesException(code: 'UNKNOWN', message: e.toString(), details: e);
    }
  }

  /// Fetches place details for a specific [placeId].
  ///
  /// [fields] must be an explicit, non-empty set of requested fields to prevent
  /// unexpected billing costs.
  ///
  /// Provide [sessionToken] matching the token used during autocomplete to conclude
  /// the billing session.
  Future<Place> fetchPlace({
    required String placeId,
    required Set<PlaceField> fields,
    AutocompleteSessionToken? sessionToken,
    String? regionCode,
  }) async {
    final trimmedId = placeId.trim();
    if (trimmedId.isEmpty) {
      throw const PlacesException(
        code: 'INVALID_ARGUMENT',
        message: 'placeId must not be empty.',
      );
    }
    if (fields.isEmpty) {
      throw const PlacesException(
        code: 'INVALID_ARGUMENT',
        message:
            'fields mask must not be empty. Specify at least one PlaceField.',
      );
    }

    try {
      final platformFields = fields.map(_mapPlaceField).toList(growable: false);
      final request = PlatformFetchPlaceRequest(
        placeId: trimmedId,
        fields: platformFields,
        sessionToken: sessionToken?.value,
        regionCode: regionCode,
      );

      final platformPlace = await _api.fetchPlace(request);
      return _mapPlace(platformPlace);
    } on PlatformException catch (e) {
      throw _mapPlatformException(e);
    } catch (e) {
      if (e is PlacesException) rethrow;
      throw PlacesException(code: 'UNKNOWN', message: e.toString(), details: e);
    }
  }

  static PlatformLatLng _mapLatLng(LatLng latLng) =>
      PlatformLatLng(latitude: latLng.latitude, longitude: latLng.longitude);

  static LatLng _unmapLatLng(PlatformLatLng latLng) =>
      LatLng(latLng.latitude, latLng.longitude);

  static PlatformLatLngBounds _mapLatLngBounds(LatLngBounds bounds) =>
      PlatformLatLngBounds(
        southwest: _mapLatLng(bounds.southwest),
        northeast: _mapLatLng(bounds.northeast),
      );

  static LatLngBounds _unmapLatLngBounds(PlatformLatLngBounds bounds) =>
      LatLngBounds(
        southwest: _unmapLatLng(bounds.southwest),
        northeast: _unmapLatLng(bounds.northeast),
      );

  static PlatformCircularBounds _mapCircularBounds(CircularBounds bounds) =>
      PlatformCircularBounds(
        center: _mapLatLng(bounds.center),
        radiusMeters: bounds.radiusMeters,
      );

  static PlatformLocationBias? _mapLocationBias(LocationBias? bias) {
    if (bias == null) return null;
    return PlatformLocationBias(
      rectangular: bias.rectangular != null
          ? _mapLatLngBounds(bias.rectangular!)
          : null,
      circular: bias.circular != null
          ? _mapCircularBounds(bias.circular!)
          : null,
    );
  }

  static PlatformLocationRestriction? _mapLocationRestriction(
    LocationRestriction? restriction,
  ) {
    if (restriction == null) return null;
    return PlatformLocationRestriction(
      rectangular: restriction.rectangular != null
          ? _mapLatLngBounds(restriction.rectangular!)
          : null,
      circular: restriction.circular != null
          ? _mapCircularBounds(restriction.circular!)
          : null,
    );
  }

  static AutocompletePrediction _mapPrediction(
    PlatformAutocompletePrediction p,
  ) {
    return AutocompletePrediction(
      placeId: p.placeId,
      fullText: p.fullText,
      primaryText: p.primaryText,
      secondaryText: p.secondaryText,
      placeTypes: List<String>.unmodifiable(p.placeTypes),
      distanceMeters: p.distanceMeters,
    );
  }

  static PlatformPlaceField _mapPlaceField(PlaceField field) {
    return PlatformPlaceField.values.byName(field.name);
  }

  static Place _mapPlace(PlatformPlace p) {
    return Place(
      id: p.id,
      displayName: p.displayName,
      formattedAddress: p.formattedAddress,
      location: p.location != null ? _unmapLatLng(p.location!) : null,
      viewport: p.viewport != null ? _unmapLatLngBounds(p.viewport!) : null,
      addressComponents: p.addressComponents
          ?.map(
            (c) => AddressComponent(
              name: c.name,
              shortName: c.shortName,
              types: List<String>.unmodifiable(c.types),
            ),
          )
          .toList(growable: false),
      types: p.types != null ? List<String>.unmodifiable(p.types!) : null,
      primaryType: p.primaryType,
      internationalPhoneNumber: p.internationalPhoneNumber,
      nationalPhoneNumber: p.nationalPhoneNumber,
      rating: p.rating,
      userRatingCount: p.userRatingCount,
      businessStatus: p.businessStatus,
      priceLevel: p.priceLevel,
      websiteUri: p.websiteUri,
      googleMapsUri: p.googleMapsUri,
      iconMaskUrl: p.iconMaskUrl,
      iconBackgroundColor: p.iconBackgroundColor,
      utcOffsetMinutes: p.utcOffsetMinutes,
    );
  }

  static PlacesException _mapPlatformException(PlatformException e) {
    return PlacesException(
      code: e.code,
      message: e.message ?? 'Unknown Places SDK error.',
      details: e.details,
    );
  }
}
