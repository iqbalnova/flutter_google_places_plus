# Google Places SDK Versions & API Audit

Dokumen ini mencatat hasil riset resmi per **22 Oktober 2026** sebagai dasar teknis pengembangan plugin `flutter_google_places_plus`.

---

## 1. Versi SDK Terpilih

| Platform | Library / Artifact | Versi Terpilih | Tanggal Cek | Sumber Resmi |
|---|---|---|---|---|
| **iOS** | `GooglePlacesSwift` via SPM (`ios-places-sdk`) | `11.2.0` | 2026-10-22 | [GitHub googlemaps/ios-places-sdk](https://github.com/googlemaps/ios-places-sdk), [Google Developers iOS Releases](https://developers.google.com/maps/documentation/places/ios-sdk/release-notes) |
| **Android** | `com.google.android.libraries.places:places` | `5.3.0` (kompatibel `6.0.2`) | 2026-10-22 | [Google Maven Repository](https://dl.google.com/dl/android/maven2/com/google/android/libraries/places/places/maven-metadata.xml), [Google Developers Android Releases](https://developers.google.com/maps/documentation/places/android-sdk/release-notes) |
| **Dart/Flutter** | Pigeon | `29.0.11` | 2026-10-22 | [pub.dev/packages/pigeon](https://pub.dev/packages/pigeon) |

### Catatan Pemilihan Versi

- **iOS (`11.2.0`)**: Google mengumumkan bahwa CocoaPods didepresiasi mulai versi `11.0.0` dan merekomendasikan Swift Package Manager (SPM). Tag rilis terbaru adalah `11.2.0` dengan dukungan `GooglePlacesSwift` terintegrasi dalam repositori utama.
- **Android (`5.3.0`)**: Versi 5.3.0 adalah rilis GA stabil yang mendukung penuh Places API (New) (`Places.initializeWithNewPlacesApiEnabled`) tanpa memaksakan dependensi Jetpack Compose Foundation 1.10 yang dibawa oleh versi 6.0.2. Versi 5.3.0 bekerja mulus dengan AGP 8/9 dan Kotlin 2.x tanpa konflik dependensi Compose pada aplikasi Flutter standar.

---

## 2. Persyaratan Minimum Sistem

### iOS
- **iOS Deployment Target**: iOS 16.0 (sesuai spesifikasi minimum `platforms: [.iOS(.v16)]` pada `Package.swift` Google Places SDK 11.2.0).
- **Xcode**: Xcode 15.0+ (disarankan Xcode 16 / 26 / 27).
- **Swift Tools Version**: 5.9+.
- **Packaging**: Swift Package Manager sebagai jalur utama, dengan CocoaPods fallback (`s.source_files` menunjuk ke folder Sources yang sama).

### Android
- **`minSdk`**: 24 (Android 7.0 Nougat, batas minimum Places SDK v5/v6).
- **`compileSdk`**: 36.
- **Android Gradle Plugin (AGP)**: 8.x / 9.x.
- **Kotlin**: 2.0+ (target JVM 17).
- **Java / JDK**: Java 17.

### Flutter & Dart
- **Flutter**: 3.44+ (versi di mana SPM diaktifkan secara default). Flutter workstation saat ini: `3.47.5` (stable).
- **Dart**: 3.11+ (mendukung Pigeon 29.x). Dart workstation saat ini: `3.13.4`.

---

## 3. Keputusan Produk iOS: `GooglePlacesSwift` vs `GooglePlaces`

**Keputusan:** Memakai **`GooglePlacesSwift`**.

**Alasan Teknis:**
1. **Swift Concurrency**: `GooglePlacesSwift` dirancang dengan `async/await` murni (`placesClient.fetchAutocompleteSuggestions(...) async -> Result<[AutocompleteSuggestion], PlacesError>`), tanpa callback Objective-C manual.
2. **Value Types & Immutability**: Menggunakan `struct Place`, `struct AutocompleteRequest`, `struct AutocompleteFilter`, dan `struct AutocompletePlaceSuggestion` yang thread-safe (`Sendable`).
3. **Pigeon Integration**: Pigeon modern mendukung method Swift `async throws` secara native, sehingga mapping dari `PlacesGateway` ke Pigeon wrapper berjalan mulus tanpa bridging Objective-C.
4. **Masa Depan**: Google secara aktif memperbarui `GooglePlacesSwift` di setiap rilis 10.x/11.x, sementara Objective-C API masuk mode pemeliharaan.

---

## 4. Audit API: Android & iOS

### A. Inisialisasi SDK
| Platform | API Baru & Direkomendasikan (Dipakai) | API Deprecated / Dihindari |
|---|---|---|
| **Android** | `Places.initializeWithNewPlacesApiEnabled(context, apiKey)` | `Places.initialize(context, apiKey)` (Didepresiasi di v5.0, dihapus di v6.0) |
| **iOS** | `PlacesClient.provideAPIKey(apiKey)` | `GMSPlacesClient.provideAPIKey(apiKey)` |

### B. Session Token
| Platform | API Digunakan | Catatan Billing |
|---|---|---|
| **Android** | `AutocompleteSessionToken.newInstance()` | Token dibagikan antara autocomplete request dan pemanggilan final `fetchPlace` untuk mengelompokkan penagihan ke SKU Session. |
| **iOS** | `AutocompleteSessionToken()` | Mendukung serialisasi string untuk interoperabilitas atau tracking sesi. |

### C. Autocomplete (New)
| Platform | API Baru & Direkomendasikan (Dipakai) | API Deprecated / Dihindari |
|---|---|---|
| **Android** | `PlacesClient.findAutocompletePredictions(FindAutocompletePredictionsRequest)` | Legacy `PlacesClient.findAutocompletePredictions` tanpa Places (New) flag; legacy `AutocompleteFragment`, `AutocompleteActivityMode`. |
| **iOS** | `PlacesClient.fetchAutocompleteSuggestions(with: AutocompleteRequest)` | `GMSPlacesClient.shared().fetchAutocompleteSuggestions(...)` callback-based; `GMSAutocompleteFilter`. |

### D. Fetch Place / Place Details (New)
| Platform | API Baru & Direkomendasikan (Dipakai) | API Deprecated / Dihindari |
|---|---|---|
| **Android** | `PlacesClient.fetchPlace(FetchPlaceRequest)` dengan field list eksplisit | `Place.Field.ADDRESS` -> ganti `FORMATTED_ADDRESS`<br>`Place.Field.LAT_LNG` -> ganti `LOCATION`<br>`Place.Field.NAME` -> ganti `DISPLAY_NAME`<br>`Place.Field.PHONE_NUMBER` -> ganti `INTERNATIONAL_PHONE_NUMBER`<br>`Place.Field.USER_RATINGS_TOTAL` -> ganti `USER_RATING_COUNT`<br>`Place.Field.WHEELCHAIR_ACCESSIBLE_ENTRANCE` -> ganti `ACCESSIBILITY_OPTIONS` |
| **iOS** | `PlacesClient.fetchPlace(with: FetchPlaceRequest)` dengan field mask eksplisit | `GMSPlaceProperty.name` -> ganti `displayName`<br>`GMSPlaceProperty.formattedAddress` -> ganti `formattedAddress`<br>`placesClient.fetchPhoto` (didepresiasi) |

---

## 5. Pemetaan Perbedaan Android vs iOS

| Aspek | Android (Kotlin) | iOS (Swift) | Normalisasi di Dart / Pigeon |
|---|---|---|---|
| **Koordinat LatLng** | `com.google.android.gms.maps.model.LatLng` (`latitude`, `longitude`) | `CoreLocation.CLLocationCoordinate2D` (`latitude`, `longitude`) | `PigeonLatLng(latitude: double, longitude: double)` |
| **Bounds Segi Empat** | `RectangularBounds.newInstance(southWest, northEast)` | `RectangularCoordinateRegion(northEast:southWest:)` | `PigeonLatLngBounds(southwest: ..., northeast: ...)` |
| **Bounds Lingkaran** | `CircularBounds.newInstance(center, radiusMeters)` | `CircularCoordinateRegion(center:radius:)` | `PigeonCircularBounds(center: ..., radiusMeters: double)` |
| **Filter Tipe Tempat** | `List<String>` (maks. 5 tipe dari Table A/B) | `Set<PlaceType>` (maks. 5 tipe) | `List<String>` |
| **Filter Negara** | `setCountries(List<String>)` (ISO-3166-1 alpha-2) | `countries: Set<String>` (ISO-3166-1 alpha-2) | `List<String>` |
| **Distance (Jarak)** | `prediction.distanceMeters: Int?` | `suggestion.distance: Measurement<UnitLength>?` | `int? distanceMeters` (dikonversi ke meter bulat) |
| **Highlighting Teks** | `getPrimaryText(null).toString()` | `attributedPrimaryText.characters` / String | String bersih (`primaryText`, `secondaryText`, `fullText`) + offset range jika dibutuhkan |
| **Error Handling** | `ApiException` (`statusCode`) | `PlacesError` enum / `NSError` | `PlacesException(code: String, message: String)` |

---

## 6. Daftar Dependensi Transitif

### Android (`places:5.3.0`)
- `com.google.android.gms:play-services-maps:17.0.0`
- `com.google.android.gms:play-services-location:21.0.1`
- `com.google.android.gms:play-services-tasks:18.2.0`
- `com.google.android.gms:play-services-base:18.5.0`
- `com.google.android.gms:play-services-basement:18.9.0`
- `org.jetbrains.kotlinx:kotlinx-coroutines-play-services:1.8.0`
- `org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.0`
- `com.android.volley:volley:1.2.1`
- `com.github.bumptech.glide:glide:4.16.0`
- `com.google.code.gson:gson:2.10`
- `com.google.guava:guava:33.3.0-android`

### iOS (`ios-places-sdk:11.2.0`)
- `GooglePlaces.xcframework` (Binary target)
- `GooglePlacesSwift.xcframework` (Binary target)
- Frameworks sistem Apple:
  - `CoreGraphics.framework`
  - `CoreLocation.framework`
  - `CoreText.framework`
  - `QuartzCore.framework`
  - `Security.framework`
  - `UIKit.framework`
  - `libc++.tbd`
  - `libz.tbd`
