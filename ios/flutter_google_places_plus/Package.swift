// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_google_places_plus",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .library(name: "flutter-google-places-plus", targets: ["flutter_google_places_plus"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/googlemaps/ios-places-sdk", "11.2.0"..<"12.0.0")
    ],
    targets: [
        .target(
            name: "flutter_google_places_plus",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "GooglePlacesSwift", package: "ios-places-sdk")
            ]
        )
    ]
)
