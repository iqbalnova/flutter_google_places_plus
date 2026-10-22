import 'dart:ui' show Locale;

import 'package:flutter/services.dart';
import 'package:flutter_google_places_plus/flutter_google_places_plus.dart';
import 'package:flutter_google_places_plus/src/messages.g.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePlacesHostApi extends PlacesHostApi {
  String? initializedKey;
  String? initializedLocale;
  Exception? initializeError;

  PlatformAutocompleteRequest? lastAutocompleteRequest;
  List<PlatformAutocompletePrediction> autocompleteResponse = [];
  Exception? autocompleteError;

  PlatformFetchPlaceRequest? lastFetchPlaceRequest;
  PlatformPlace? fetchPlaceResponse;
  Exception? fetchPlaceError;

  @override
  Future<void> initialize(String apiKey, String? locale) async {
    if (initializeError != null) throw initializeError!;
    initializedKey = apiKey;
    initializedLocale = locale;
  }

  @override
  Future<List<PlatformAutocompletePrediction>> findAutocompletePredictions(
    PlatformAutocompleteRequest request,
  ) async {
    if (autocompleteError != null) throw autocompleteError!;
    lastAutocompleteRequest = request;
    return autocompleteResponse;
  }

  @override
  Future<PlatformPlace> fetchPlace(PlatformFetchPlaceRequest request) async {
    if (fetchPlaceError != null) throw fetchPlaceError!;
    lastFetchPlaceRequest = request;
    return fetchPlaceResponse ?? PlatformPlace(id: request.placeId);
  }
}

void main() {
  late FakePlacesHostApi fakeApi;
  late FlutterGooglePlacesPlus client;

  setUp(() {
    fakeApi = FakePlacesHostApi();
    client = FlutterGooglePlacesPlus(api: fakeApi);
  });

  group('initialize', () {
    test('succeeds with valid API key and locale', () async {
      await client.initialize(
        apiKey: 'test-api-key',
        locale: const Locale('id', 'ID'),
      );

      expect(client.isInitialized, isTrue);
      expect(fakeApi.initializedKey, equals('test-api-key'));
      expect(fakeApi.initializedLocale, equals('id_ID'));
    });

    test('throws INVALID_ARGUMENT when API key is empty', () async {
      expect(
        () => client.initialize(apiKey: '   '),
        throwsA(
          isA<PlacesException>().having(
            (e) => e.code,
            'code',
            'INVALID_ARGUMENT',
          ),
        ),
      );
    });

    test('maps PlatformException to PlacesException', () async {
      fakeApi.initializeError = PlatformException(
        code: 'INITIALIZATION_ERROR',
        message: 'Invalid key',
      );

      expect(
        () => client.initialize(apiKey: 'bad-key'),
        throwsA(
          isA<PlacesException>().having(
            (e) => e.code,
            'code',
            'INITIALIZATION_ERROR',
          ),
        ),
      );
    });
  });

  group('findAutocompletePredictions', () {
    test(
      'returns empty list without calling API when query is empty',
      () async {
        final results = await client.findAutocompletePredictions(query: '');
        expect(results, isEmpty);
        expect(fakeApi.lastAutocompleteRequest, isNull);
      },
    );

    test(
      'throws INVALID_ARGUMENT if both bias and restriction are provided',
      () async {
        const rect = LatLngBounds(
          southwest: LatLng(-8, 110),
          northeast: LatLng(-7, 111),
        );
        expect(
          () => client.findAutocompletePredictions(
            query: 'test',
            locationBias: const LocationBias.rectangular(rect),
            locationRestriction: const LocationRestriction.rectangular(rect),
          ),
          throwsA(
            isA<PlacesException>().having(
              (e) => e.code,
              'code',
              'INVALID_ARGUMENT',
            ),
          ),
        );
      },
    );

    test('sends request and correctly maps predictions', () async {
      fakeApi.autocompleteResponse = [
        PlatformAutocompletePrediction(
          placeId: 'place_123',
          fullText: 'Malioboro, Yogyakarta',
          primaryText: 'Malioboro',
          secondaryText: 'Yogyakarta',
          placeTypes: ['route'],
          distanceMeters: 500,
        ),
      ];

      final token = client.newSessionToken();
      final predictions = await client.findAutocompletePredictions(
        query: 'Malioboro',
        sessionToken: token,
        countries: ['ID'],
        placeTypes: ['route'],
        origin: const LatLng(-7.79, 110.37),
        regionCode: 'ID',
        inputOffset: 9,
      );

      expect(predictions.length, equals(1));
      expect(predictions.first.placeId, equals('place_123'));
      expect(predictions.first.primaryText, equals('Malioboro'));
      expect(predictions.first.secondaryText, equals('Yogyakarta'));
      expect(predictions.first.placeTypes, equals(['route']));
      expect(predictions.first.distanceMeters, equals(500));

      expect(fakeApi.lastAutocompleteRequest?.query, equals('Malioboro'));
      expect(
        fakeApi.lastAutocompleteRequest?.sessionToken,
        equals(token.value),
      );
      expect(fakeApi.lastAutocompleteRequest?.countries, equals(['ID']));
      expect(fakeApi.lastAutocompleteRequest?.regionCode, equals('ID'));
      expect(fakeApi.lastAutocompleteRequest?.inputOffset, equals(9));
      expect(fakeApi.lastAutocompleteRequest?.origin?.latitude, equals(-7.79));
    });

    test('maps PlatformException from API to PlacesException', () async {
      fakeApi.autocompleteError = PlatformException(
        code: 'REQUEST_DENIED',
        message: 'The provided API key is invalid.',
      );

      expect(
        () => client.findAutocompletePredictions(query: 'query'),
        throwsA(
          isA<PlacesException>()
              .having((e) => e.code, 'code', 'REQUEST_DENIED')
              .having((e) => e.message, 'message', contains('invalid')),
        ),
      );
    });
  });

  group('fetchPlace', () {
    test('throws INVALID_ARGUMENT when placeId is empty', () async {
      expect(
        () =>
            client.fetchPlace(placeId: '  ', fields: {PlaceField.displayName}),
        throwsA(
          isA<PlacesException>().having(
            (e) => e.code,
            'code',
            'INVALID_ARGUMENT',
          ),
        ),
      );
    });

    test('throws INVALID_ARGUMENT when fields mask is empty', () async {
      expect(
        () => client.fetchPlace(placeId: 'place_123', fields: {}),
        throwsA(
          isA<PlacesException>().having(
            (e) => e.code,
            'code',
            'INVALID_ARGUMENT',
          ),
        ),
      );
    });

    test('sends request and correctly maps place details', () async {
      fakeApi.fetchPlaceResponse = PlatformPlace(
        id: 'place_123',
        displayName: 'Tugu Yogyakarta',
        formattedAddress: 'Jl. Jend. Sudirman, Gowongan, Jetis, Yogyakarta',
        location: PlatformLatLng(latitude: -7.782894, longitude: 110.367069),
        viewport: PlatformLatLngBounds(
          southwest: PlatformLatLng(latitude: -7.783, longitude: 110.366),
          northeast: PlatformLatLng(latitude: -7.782, longitude: 110.368),
        ),
        addressComponents: [
          PlatformAddressComponent(
            name: 'Yogyakarta',
            shortName: 'YK',
            types: ['locality'],
          ),
        ],
        types: ['monument'],
        rating: 4.7,
        userRatingCount: 20000,
        businessStatus: 'OPERATIONAL',
        priceLevel: 0,
        websiteUri: 'https://jogjakota.go.id',
        googleMapsUri: 'https://maps.google.com/?cid=123',
        iconMaskUrl: 'https://maps.gstatic.com/icon.png',
        iconBackgroundColor: '#1976D2',
        utcOffsetMinutes: 420,
      );

      final token = client.newSessionToken();
      final place = await client.fetchPlace(
        placeId: 'place_123',
        fields: {
          PlaceField.id,
          PlaceField.displayName,
          PlaceField.formattedAddress,
          PlaceField.location,
        },
        sessionToken: token,
        regionCode: 'ID',
      );

      expect(place.id, equals('place_123'));
      expect(place.displayName, equals('Tugu Yogyakarta'));
      expect(place.formattedAddress, contains('Sudirman'));
      expect(place.location?.latitude, equals(-7.782894));
      expect(place.location?.longitude, equals(110.367069));
      expect(place.viewport?.southwest.latitude, equals(-7.783));
      expect(place.addressComponents?.first.name, equals('Yogyakarta'));
      expect(place.types, equals(['monument']));
      expect(place.rating, equals(4.7));
      expect(place.userRatingCount, equals(20000));
      expect(place.businessStatus, equals('OPERATIONAL'));
      expect(place.priceLevel, equals(0));
      expect(place.utcOffsetMinutes, equals(420));

      expect(fakeApi.lastFetchPlaceRequest?.placeId, equals('place_123'));
      expect(fakeApi.lastFetchPlaceRequest?.sessionToken, equals(token.value));
      expect(fakeApi.lastFetchPlaceRequest?.regionCode, equals('ID'));
      expect(
        fakeApi.lastFetchPlaceRequest?.fields,
        containsAll([
          PlatformPlaceField.id,
          PlatformPlaceField.displayName,
          PlatformPlaceField.formattedAddress,
          PlatformPlaceField.location,
        ]),
      );
    });

    test('maps PlatformException from fetchPlace to PlacesException', () async {
      fakeApi.fetchPlaceError = PlatformException(
        code: 'NOT_FOUND',
        message: 'Place ID not found.',
      );

      expect(
        () => client.fetchPlace(placeId: 'missing', fields: {PlaceField.id}),
        throwsA(
          isA<PlacesException>().having((e) => e.code, 'code', 'NOT_FOUND'),
        ),
      );
    });
  });
}
