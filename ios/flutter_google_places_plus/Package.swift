// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_google_places_plus",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "flutter-google-places-plus", targets: ["flutter_google_places_plus"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/googlemaps/ios-places-sdk", "9.4.1"..<"10.0.0")
    ],
    targets: [
        .target(
            name: "flutter_google_places_plus",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "GooglePlaces", package: "ios-places-sdk")
            ]
        )
    ]
)
