## 1.0.0

* Initial release of `flutter_google_places_plus`.
* Built from scratch on modern native Google Places SDKs:
  * **Android**: Places SDK for Android (New) using idiomatic Kotlin with coroutines.
  * **iOS**: Google Places Swift SDK with native `async/await` and full Swift Package Manager (SPM) support alongside CocoaPods fallback.
* Type-safe Pigeon contracts between Dart, Kotlin, and Swift without legacy string-based method channels.
* Programmatic **Autocomplete (New)** with support for session tokens, country filters, place type filters, rectangular/circular location bias & restrictions, origin distance calculations, and locale.
* Programmatic **Place Details (New)** (`fetchPlace`) requiring an explicit field mask to optimize billing and performance.
* Session token lifecycle management: concluding sessions on place selection to group billing under Autocomplete session SKUs.
* Clean error translation into `PlacesException` with strict API key sanitization (API keys are never logged or exposed in errors).
