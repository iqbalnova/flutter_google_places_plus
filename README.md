# flutter_google_places_plus

Modern Flutter plugin for Google Places built directly on top of official **Native Google Places SDKs**:
- **Android**: Official Places SDK for Android (Kotlin coroutines, native Places API New enabled).
- **iOS**: Official Places Swift SDK (**`GooglePlacesSwift` 11.2.0** supporting **iOS 16.0+** with native `async/await`).
- **Single Source of Truth**: Pigeon generates type-safe Dart, Kotlin, and Swift contracts (no legacy untyped method channels).

---

## Requirements

| Platform | Minimum Target | Native SDK Version | Tooling Required |
|---|---|---|---|
| **iOS** | **iOS 16.0+** | `GooglePlacesSwift` **11.2.0** | Xcode 15.0+, Swift 5.9+ (SPM / CocoaPods) |
| **Android** | **minSdk 24** (Android 7.0), `compileSdk` 36 | `places` **5.3.0** | Java 17, Kotlin 2.0+, AGP 8.0+ |
| **Flutter** | Flutter **>= 3.3.0** | - | Dart **>= 3.13.4** |

> **Need iOS 15 support?** Pin your dependency to tag [`v1.0.0`](https://github.com/iqbalnova/flutter_google_places_plus/tree/v1.0.0) which uses Google Places SDK 9.4.1.

---

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_google_places_plus:
    git:
      url: https://github.com/iqbalnova/flutter_google_places_plus.git
      ref: v2.0.0 # Or use v1.0.0 if you need iOS 15 support
```

Then fetch dependencies:

```sh
flutter pub get
```

---

## Platform Setup & API Key Restrictions

Because this plugin uses **100% native SDKs** on both Android and iOS (not HTTP/REST wrapper), your API key can be strictly whitelisted per platform in the Google Cloud Console.

### 1. Enable APIs in Google Cloud Console
- Enable **Places API (New)** under your Google Cloud project.

### 2. Lock Down Your Keys
Do not use unrestricted API keys in production. Create two separate restricted keys:

- **Android API Key**:
  - Restrict Key -> **Android apps**.
  - Add your Android package name (e.g. `com.example.myapp`) and SHA-1 certificate fingerprint (`./gradlew signingReport` or from your Play Console App Integrity).
  - Restrict API access to **Places API (New)**.

- **iOS API Key**:
  - Restrict Key -> **iOS apps**.
  - Add your iOS Bundle Identifier (e.g. `com.example.myapp`).
  - Restrict API access to **Places API (New)**.

---

## Usage

### 1. Initialize the SDK

Call `initialize` early in your app lifecycle (for example, in your splash or main service setup).

```dart
import 'package:flutter_google_places_plus/flutter_google_places_plus.dart';

final places = FlutterGooglePlacesPlus();

await places.initialize(
  apiKey: 'YOUR_GOOGLE_PLACES_API_KEY',
  locale: const Locale('id', 'ID'), // Optional localization
);
```

### 2. Autocomplete Suggestions

Use `findAutocompletePredictions` to get real-time place suggestions as the user types.

```dart
// 1. Create a session token at the start of a user search session
final sessionToken = places.newSessionToken();

// 2. Fetch predictions
final predictions = await places.findAutocompletePredictions(
  query: 'Monas',
  sessionToken: sessionToken,
  countries: ['ID'], // Restrict to Indonesia (ISO-3166-1 alpha-2)
  placeTypes: ['tourist_attraction', 'point_of_interest'],
  locationBias: const LocationBias.circular(
    CircularBounds(
      center: LatLng(-6.175392, 106.827153),
      radiusMeters: 10000,
    ),
  ),
);

for (final item in predictions) {
  print('${item.primaryText} (${item.secondaryText}) - ID: ${item.placeId}');
}
```

### 3. Fetch Place Details

When the user selects a prediction, call `fetchPlace` using the **same session token** to conclude the billing session.

> **Important**: Field masks are **explicit and required**. Request only the data fields your app needs to avoid unexpected billing charges.

```dart
final place = await places.fetchPlace(
  placeId: predictions.first.placeId,
  fields: {
    PlaceField.id,
    PlaceField.displayName,
    PlaceField.formattedAddress,
    PlaceField.location,
    PlaceField.addressComponents,
    PlaceField.rating,
    PlaceField.userRatingCount,
    PlaceField.businessStatus,
    PlaceField.googleMapsUri,
  },
  sessionToken: sessionToken, // Concludes the autocomplete billing session
);

print('Name: ${place.displayName}');
print('Address: ${place.formattedAddress}');
print('Coordinates: ${place.location?.latitude}, ${place.location?.longitude}');
print('Google Maps Link: ${place.googleMapsUri}');
```

---

## Billing & Session Tokens

Google Places Autocomplete (New) uses sessions to group prediction queries and place selection into a single, predictable billing event:

1. **Session Start**: Create an `AutocompleteSessionToken` via `places.newSessionToken()` when the user begins typing.
2. **Intermediate Queries**: Pass the token into every `findAutocompletePredictions` call for that search interaction.
3. **Session Conclusion**: Pass the **same** token to `fetchPlace` when the user selects a place. This ends the session and bills the request under the Autocomplete Session SKU rather than per individual keystroke.
4. **New Search**: Once `fetchPlace` finishes, generate a fresh `AutocompleteSessionToken` for subsequent searches.

---

## Error Handling

Errors from the underlying native Google Places SDK are mapped to `PlacesException`. Sensitive values like API keys are automatically redacted from error messages.

```dart
try {
  final results = await places.findAutocompletePredictions(query: 'Cafe');
} on PlacesException catch (e) {
  switch (e.code) {
    case 'NOT_INITIALIZED':
      print('Call initialize() first');
      break;
    case 'INVALID_ARGUMENT':
      print('Check input parameters: ${e.message}');
      break;
    case 'REQUEST_DENIED':
      print('Check API key restrictions and billing status: ${e.message}');
      break;
    default:
      print('Places error: [${e.code}] ${e.message}');
  }
}
```

---

## Attribution & Terms of Service

When displaying Place results retrieved from the Google Places SDK:
- You must display required attributions and the "Powered by Google" logo if required by Google Maps Platform policies.
- For full details, consult the [Google Places API Policies & Attribution Guidelines](https://developers.google.com/maps/documentation/places/web-service/policies).

---

## Architecture & Testing

Google Places SDK interactions are abstracted behind the `PlacesGateway` interface (`PlacesGateway.kt` on Android, `PlacesGateway.swift` on iOS). This architecture decouples Flutter channel glue from native Google SDKs, enabling deterministic unit testing with fake gateways without real network calls.

---

## License

BSD 3-Clause License. See [LICENSE](LICENSE) for details.
