import CoreLocation
import Foundation
import GooglePlaces

@MainActor
final class RealPlacesGateway: PlacesGateway, @unchecked Sendable {

    private var initialized = false
    private var sessionTokens: [String: GMSAutocompleteSessionToken] = [:]

    nonisolated init() {}

    func initialize(apiKey: String, locale: String?) throws {
        _ = GMSPlacesClient.provideAPIKey(apiKey)
        self.initialized = true
    }

    func isInitialized() -> Bool {
        return initialized
    }

    func findAutocompletePredictions(
        request: PlatformAutocompleteRequest
    ) async throws -> [PlatformAutocompletePrediction] {
        guard isInitialized() else {
            throw PigeonError(code: "NOT_INITIALIZED", message: "Places SDK is not initialized. Call initialize() first.", details: nil)
        }

        let token: GMSAutocompleteSessionToken?
        if let tokenString = request.sessionToken {
            token = resolveSessionToken(tokenString)
        } else {
            token = nil
        }

        let filter = GMSAutocompleteFilter()
        if let countries = request.countries, !countries.isEmpty {
            filter.countries = countries
        }
        if let types = request.placeTypes, !types.isEmpty {
            filter.types = types
        }
        if let origin = request.origin {
            filter.origin = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
        }

        if let b = request.locationBias {
            if let rect = b.rectangular {
                filter.locationBias = GMSPlaceRectangularLocationOption(
                    Mappers.mapLatLng(rect.northeast),
                    Mappers.mapLatLng(rect.southwest)
                )
            }
        }

        if let r = request.locationRestriction {
            if let rect = r.rectangular {
                filter.locationRestriction = GMSPlaceRectangularLocationOption(
                    Mappers.mapLatLng(rect.northeast),
                    Mappers.mapLatLng(rect.southwest)
                )
            }
        }

        let client = GMSPlacesClient.shared()

        return try await withCheckedThrowingContinuation { continuation in
            client.findAutocompletePredictions(
                fromQuery: request.query,
                filter: filter,
                sessionToken: token
            ) { results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    let mapped = (results ?? []).map { Mappers.mapPrediction($0) }
                    continuation.resume(returning: mapped)
                }
            }
        }
    }

    func fetchPlace(request: PlatformFetchPlaceRequest) async throws -> PlatformPlace {
        guard isInitialized() else {
            throw PigeonError(code: "NOT_INITIALIZED", message: "Places SDK is not initialized. Call initialize() first.", details: nil)
        }

        let properties = request.fields.map { Mappers.mapPlaceField($0).rawValue }
        guard !properties.isEmpty else {
            throw PigeonError(code: "INVALID_ARGUMENT", message: "fields mask must not be empty.", details: nil)
        }

        let token: GMSAutocompleteSessionToken?
        if let tokenString = request.sessionToken {
            token = resolveSessionToken(tokenString)
            sessionTokens.removeValue(forKey: tokenString)
        } else {
            token = nil
        }

        let client = GMSPlacesClient.shared()
        let fetchRequest = GMSFetchPlaceRequest(
            placeID: request.placeId,
            placeProperties: properties,
            sessionToken: token
        )

        return try await withCheckedThrowingContinuation { continuation in
            client.fetchPlace(with: fetchRequest) { place, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let place = place {
                    continuation.resume(returning: Mappers.mapPlace(place))
                } else {
                    continuation.resume(throwing: PigeonError(code: "NOT_FOUND", message: "Place not found.", details: nil))
                }
            }
        }
    }

    private func resolveSessionToken(_ tokenString: String) -> GMSAutocompleteSessionToken {
        if let existing = sessionTokens[tokenString] {
            return existing
        }
        let newToken = GMSAutocompleteSessionToken()
        sessionTokens[tokenString] = newToken
        return newToken
    }
}
