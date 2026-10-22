# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-22

### Added
* **First stable release** of `flutter_google_places_plus`.
* **Platform & SDK Support**:
  * **iOS**: Deployment target **iOS 15.0+** using native `GooglePlaces` SDK v9.4.1 (Swift Package Manager & CocoaPods fallback).
  * **Android**: `minSdk 24` (Android 7.0 Nougat) to `compileSdk 36` using official Places SDK for Android (New) v5.3.0 with Kotlin coroutines.
  * **Flutter/Dart**: Flutter >= 3.3.0 and Dart >= 3.13.4.
* **Type-Safe Pigeon IPC**: Direct type-safe contracts between Dart, Kotlin, and Swift (eliminating untyped string-based method channels).
* **Autocomplete (Places New API)**:
  * Fast real-time predictions matching.
  * Autocomplete session token management (`newSessionToken()`) to optimize billing SKUs.
  * Multi-country filtering (`countries`, up to 5 ISO-3166-1 alpha-2 codes).
  * Place types filtering (`placeTypes`, primary / secondary types).
  * Location bias and location restriction via `RectangularBounds` and `CircularBounds`.
  * User `origin` distance calculation (`distanceMeters`).
  * Regional formatting (`regionCode`) and cursor `inputOffset`.
* **Place Details (`fetchPlace`)**:
  * Mandatory explicit field masking (`Set<PlaceField>`) preventing unnecessary data over-fetching.
  * Concludes session tokens upon place selection.
  * Supported fields:
    * **Identity & Geometry**: `id`, `displayName`, `formattedAddress`, `location` (LatLng), `viewport` (LatLngBounds), `addressComponents`, `types`, `primaryType`.
    * **Contact & Web**: `internationalPhoneNumber`, `nationalPhoneNumber`, `websiteUri`.
    * **Ratings & Status**: `rating`, `userRatingCount`, `businessStatus` (`OPERATIONAL`, `CLOSED_TEMPORARILY`, `CLOSED_PERMANENTLY`), `priceLevel`.
    * **Visuals & Time**: `iconMaskUrl`, `iconBackgroundColor`, `utcOffsetMinutes`.
* **Security & Reliability**:
  * Strict API key sanitization — keys are never logged or leaked in error messages.
  * Native error mapping to unified `PlacesException`.
