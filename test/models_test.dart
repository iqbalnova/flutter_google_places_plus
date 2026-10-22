import 'package:flutter_google_places_plus/flutter_google_places_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LatLng', () {
    test('valid coordinates instantiate correctly and support equality', () {
      const p1 = LatLng(-7.797068, 110.370529);
      const p2 = LatLng(-7.797068, 110.370529);
      const p3 = LatLng(0.0, 0.0);

      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
      expect(p1, isNot(equals(p3)));
      expect(p1.toString(), contains('-7.797068'));
    });

    test('invalid latitude throws assertion error', () {
      expect(() => LatLng(91.0, 0.0), throwsAssertionError);
      expect(() => LatLng(-91.0, 0.0), throwsAssertionError);
    });

    test('invalid longitude throws assertion error', () {
      expect(() => LatLng(0.0, 181.0), throwsAssertionError);
      expect(() => LatLng(0.0, -181.0), throwsAssertionError);
    });
  });

  group('LatLngBounds', () {
    test('instantiates and supports value equality', () {
      const b1 = LatLngBounds(
        southwest: LatLng(-8.0, 110.0),
        northeast: LatLng(-7.0, 111.0),
      );
      const b2 = LatLngBounds(
        southwest: LatLng(-8.0, 110.0),
        northeast: LatLng(-7.0, 111.0),
      );

      expect(b1, equals(b2));
      expect(b1.hashCode, equals(b2.hashCode));
      expect(b1.toString(), contains('LatLngBounds'));
    });
  });

  group('CircularBounds', () {
    test('instantiates and validates radius limits', () {
      const c1 = CircularBounds(
        center: LatLng(-7.79, 110.37),
        radiusMeters: 5000.0,
      );
      const c2 = CircularBounds(
        center: LatLng(-7.79, 110.37),
        radiusMeters: 5000.0,
      );

      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));

      expect(
        () => CircularBounds(center: const LatLng(0, 0), radiusMeters: -1),
        throwsAssertionError,
      );
      expect(
        () => CircularBounds(center: const LatLng(0, 0), radiusMeters: 50001),
        throwsAssertionError,
      );
    });
  });

  group('LocationBias and LocationRestriction', () {
    test('rectangular and circular biases', () {
      const rect = LatLngBounds(
        southwest: LatLng(-8.0, 110.0),
        northeast: LatLng(-7.0, 111.0),
      );
      const circ = CircularBounds(
        center: LatLng(-7.79, 110.37),
        radiusMeters: 1000,
      );

      const bias1 = LocationBias.rectangular(rect);
      const bias2 = LocationBias.rectangular(rect);
      const bias3 = LocationBias.circular(circ);

      expect(bias1, equals(bias2));
      expect(bias1, isNot(equals(bias3)));

      const restr1 = LocationRestriction.rectangular(rect);
      const restr2 = LocationRestriction.rectangular(rect);
      const restr3 = LocationRestriction.circular(circ);

      expect(restr1, equals(restr2));
      expect(restr1, isNot(equals(restr3)));
    });
  });

  group('AutocompleteSessionToken', () {
    test('generates valid UUID v4 string format', () {
      final token1 = AutocompleteSessionToken.newInstance();
      final token2 = AutocompleteSessionToken.newInstance();

      expect(token1.value, isNotEmpty);
      expect(token2.value, isNotEmpty);
      expect(token1, isNot(equals(token2)));

      final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(token1.value, matches(uuidRegex));
      expect(token2.value, matches(uuidRegex));
    });

    test('value equality by string', () {
      const token1 = AutocompleteSessionToken('custom-token-123');
      const token2 = AutocompleteSessionToken('custom-token-123');
      expect(token1, equals(token2));
      expect(token1.hashCode, equals(token2.hashCode));
      expect(token1.toString(), contains('custom-token-123'));
    });
  });

  group('AutocompletePrediction', () {
    test('equality and properties', () {
      const p1 = AutocompletePrediction(
        placeId: 'place_abc',
        fullText: 'Malioboro St, Yogyakarta, Indonesia',
        primaryText: 'Malioboro St',
        secondaryText: 'Yogyakarta, Indonesia',
        placeTypes: ['route', 'geocode'],
        distanceMeters: 1250,
      );
      const p2 = AutocompletePrediction(
        placeId: 'place_abc',
        fullText: 'Malioboro St, Yogyakarta, Indonesia',
        primaryText: 'Malioboro St',
        secondaryText: 'Yogyakarta, Indonesia',
        placeTypes: ['route', 'geocode'],
        distanceMeters: 1250,
      );

      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
      expect(p1.toString(), contains('place_abc'));
    });
  });

  group('AddressComponent and Place', () {
    test('AddressComponent equality', () {
      const c1 = AddressComponent(
        name: 'Yogyakarta',
        shortName: 'YK',
        types: ['locality', 'political'],
      );
      const c2 = AddressComponent(
        name: 'Yogyakarta',
        shortName: 'YK',
        types: ['locality', 'political'],
      );

      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));
      expect(c1.toString(), contains('Yogyakarta'));
    });

    test('Place all fields and equality', () {
      const place1 = Place(
        id: 'place_xyz',
        displayName: 'Keraton Yogyakarta',
        formattedAddress: 'Jl. Rotowijayan Blok No. 1, Yogyakarta',
        location: LatLng(-7.805284, 110.364203),
        viewport: LatLngBounds(
          southwest: LatLng(-7.806, 110.363),
          northeast: LatLng(-7.804, 110.365),
        ),
        addressComponents: [
          AddressComponent(
            name: 'Yogyakarta',
            shortName: 'YK',
            types: ['locality'],
          ),
        ],
        types: ['tourist_attraction', 'point_of_interest'],
        primaryType: 'tourist_attraction',
        internationalPhoneNumber: '+62 274 373721',
        rating: 4.8,
        userRatingCount: 35000,
        businessStatus: 'OPERATIONAL',
        priceLevel: 1,
        websiteUri: 'https://kratonjogja.id',
        googleMapsUri: 'https://maps.google.com/?cid=123',
        iconMaskUrl: 'https://maps.gstatic.com/icon.png',
        iconBackgroundColor: '#4DB6AC',
        utcOffsetMinutes: 420,
      );

      const place2 = Place(
        id: 'place_xyz',
        displayName: 'Keraton Yogyakarta',
        formattedAddress: 'Jl. Rotowijayan Blok No. 1, Yogyakarta',
        location: LatLng(-7.805284, 110.364203),
        viewport: LatLngBounds(
          southwest: LatLng(-7.806, 110.363),
          northeast: LatLng(-7.804, 110.365),
        ),
        addressComponents: [
          AddressComponent(
            name: 'Yogyakarta',
            shortName: 'YK',
            types: ['locality'],
          ),
        ],
        types: ['tourist_attraction', 'point_of_interest'],
        primaryType: 'tourist_attraction',
        internationalPhoneNumber: '+62 274 373721',
        rating: 4.8,
        userRatingCount: 35000,
        businessStatus: 'OPERATIONAL',
        priceLevel: 1,
        websiteUri: 'https://kratonjogja.id',
        googleMapsUri: 'https://maps.google.com/?cid=123',
        iconMaskUrl: 'https://maps.gstatic.com/icon.png',
        iconBackgroundColor: '#4DB6AC',
        utcOffsetMinutes: 420,
      );

      expect(place1, equals(place2));
      expect(place1.hashCode, equals(place2.hashCode));
      expect(place1.toString(), contains('Keraton Yogyakarta'));
    });
  });

  group('PlacesException', () {
    test('equality and toString', () {
      const ex1 = PlacesException(
        code: 'REQUEST_DENIED',
        message: 'API key is invalid',
      );
      const ex2 = PlacesException(
        code: 'REQUEST_DENIED',
        message: 'API key is invalid',
      );

      expect(ex1, equals(ex2));
      expect(ex1.hashCode, equals(ex2.hashCode));
      expect(
        ex1.toString(),
        equals('PlacesException(REQUEST_DENIED: API key is invalid)'),
      );
    });
  });
}
