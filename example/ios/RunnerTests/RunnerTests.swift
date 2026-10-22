import CoreLocation
import Flutter
import UIKit
import XCTest

@testable import flutter_google_places_plus

final class RunnerTests: XCTestCase {

    @MainActor
    func testFindAutocompletePredictionsDelegatesToGateway() async throws {
        let fakeGateway = FakePlacesGateway()
        fakeGateway.autocompleteResponse = [
            PlatformAutocompletePrediction(
                placeId: "place_ios_123",
                fullText: "Malioboro St, Yogyakarta",
                primaryText: "Malioboro St",
                secondaryText: "Yogyakarta",
                placeTypes: ["route"],
                distanceMeters: 250
            )
        ]

        let plugin = FlutterGooglePlacesPlusPlugin(gateway: fakeGateway)
        let request = PlatformAutocompleteRequest(
            query: "Malioboro",
            sessionToken: "session-uuid-ios",
            countries: ["ID"],
            placeTypes: ["route"],
            origin: PlatformLatLng(latitude: -7.79, longitude: 110.37),
            regionCode: "ID",
            inputOffset: 9
        )

        let predictions = try await plugin.findAutocompletePredictions(request: request)
        XCTAssertEqual(predictions.count, 1)
        XCTAssertEqual(predictions[0].placeId, "place_ios_123")
        XCTAssertEqual(predictions[0].primaryText, "Malioboro St")
        XCTAssertEqual(predictions[0].distanceMeters, 250)

        XCTAssertEqual(fakeGateway.lastAutocompleteRequest?.query, "Malioboro")
        XCTAssertEqual(fakeGateway.lastAutocompleteRequest?.sessionToken, "session-uuid-ios")
    }

    @MainActor
    func testFetchPlaceDelegatesToGateway() async throws {
        let fakeGateway = FakePlacesGateway()
        var placeResponse = PlatformPlace()
        placeResponse.id = "place_ios_123"
        placeResponse.displayName = "Tugu Jogja"
        placeResponse.formattedAddress = "Jl. Sudirman"
        placeResponse.rating = 4.8
        placeResponse.userRatingCount = 15000
        placeResponse.businessStatus = "OPERATIONAL"
        fakeGateway.fetchPlaceResponse = placeResponse

        let plugin = FlutterGooglePlacesPlusPlugin(gateway: fakeGateway)
        let request = PlatformFetchPlaceRequest(
            placeId: "place_ios_123",
            fields: [.id, .displayName, .formattedAddress, .rating],
            sessionToken: "session-uuid-ios",
            regionCode: "ID"
        )

        let place = try await plugin.fetchPlace(request: request)
        XCTAssertEqual(place.id, "place_ios_123")
        XCTAssertEqual(place.displayName, "Tugu Jogja")
        XCTAssertEqual(place.rating, 4.8)
        XCTAssertEqual(place.userRatingCount, 15000)

        XCTAssertEqual(fakeGateway.lastFetchPlaceRequest?.placeId, "place_ios_123")
        XCTAssertEqual(fakeGateway.lastFetchPlaceRequest?.sessionToken, "session-uuid-ios")
    }

    @MainActor
    func testInitializeEmptyKeyThrowsError() {
        let fakeGateway = FakePlacesGateway()
        let plugin = FlutterGooglePlacesPlusPlugin(gateway: fakeGateway)

        XCTAssertThrowsError(try plugin.initialize(apiKey: "   ", locale: nil)) { error in
            guard let pigeonError = error as? PigeonError else {
                XCTFail("Expected PigeonError")
                return
            }
            XCTAssertEqual(pigeonError.code, "INVALID_ARGUMENT")
        }
    }

    @MainActor
    func testSanitizeMessageRedactsApiKey() async {
        let fakeGateway = FakePlacesGateway()
        let leakedKey = "AIzaSyD-abc123456789012345678901234567"
        let nsError = NSError(
            domain: "GooglePlaces",
            code: 9011,
            userInfo: [NSLocalizedDescriptionKey: "Error connecting to https://maps.googleapis.com/?key=\(leakedKey)"]
        )
        fakeGateway.autocompleteError = nsError

        let plugin = FlutterGooglePlacesPlusPlugin(gateway: fakeGateway)
        let request = PlatformAutocompleteRequest(query: "test")

        do {
            _ = try await plugin.findAutocompletePredictions(request: request)
            XCTFail("Expected error to be thrown")
        } catch let error as PigeonError {
            XCTAssertFalse(error.message?.contains(leakedKey) ?? false)
            XCTAssertTrue(error.message?.contains("REDACTED") ?? false)
        } catch {
            XCTFail("Expected PigeonError")
        }
    }

    func testMappersLatLngConversion() {
        let p = PlatformLatLng(latitude: -7.79, longitude: 110.37)
        let coord = Mappers.mapLatLng(p)
        XCTAssertEqual(coord.latitude, -7.79, accuracy: 0.0001)
        XCTAssertEqual(coord.longitude, 110.37, accuracy: 0.0001)

        let unmapped = Mappers.unmapLatLng(coord)
        XCTAssertEqual(unmapped.latitude, -7.79, accuracy: 0.0001)
        XCTAssertEqual(unmapped.longitude, 110.37, accuracy: 0.0001)
    }

    func testMappersPriceLevel() {
        XCTAssertNil(Mappers.mapPriceLevel(.unspecified))
        XCTAssertEqual(Mappers.mapPriceLevel(.free), 0)
        XCTAssertEqual(Mappers.mapPriceLevel(.inexpensive), 1)
        XCTAssertEqual(Mappers.mapPriceLevel(.moderate), 2)
        XCTAssertEqual(Mappers.mapPriceLevel(.expensive), 3)
        XCTAssertEqual(Mappers.mapPriceLevel(.veryExpensive), 4)
    }

    func testMappersBusinessStatus() {
        XCTAssertNil(Mappers.mapBusinessStatus(.unknown))
        XCTAssertEqual(Mappers.mapBusinessStatus(.operational), "OPERATIONAL")
        XCTAssertEqual(Mappers.mapBusinessStatus(.closedTemporarily), "CLOSED_TEMPORARILY")
        XCTAssertEqual(Mappers.mapBusinessStatus(.closedPermanently), "CLOSED_PERMANENTLY")
    }
}
