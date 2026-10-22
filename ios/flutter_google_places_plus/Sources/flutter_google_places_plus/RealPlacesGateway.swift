import CoreLocation
import Foundation
import GooglePlacesSwift

@MainActor
final class RealPlacesGateway: PlacesGateway, @unchecked Sendable {

    private var initialized = false
    private var sessionTokens: [String: AutocompleteSessionToken] = [:]

    nonisolated init() {}

    func initialize(apiKey: String, locale: String?) throws {
        _ = PlacesClient.provideAPIKey(apiKey)
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

        let token: AutocompleteSessionToken?
        if let tokenString = request.sessionToken {
            token = resolveSessionToken(tokenString)
        } else {
            token = nil
        }

        var types: Set<PlaceType>? = nil
        if let rawTypes = request.placeTypes, !rawTypes.isEmpty {
            types = Set(rawTypes.map { PlaceType(rawValue: $0) })
        }

        var countries: Set<String>? = nil
        if let rawCountries = request.countries, !rawCountries.isEmpty {
            countries = Set(rawCountries)
        }

        let origin: CLLocation? = request.origin.map {
            CLLocation(latitude: $0.latitude, longitude: $0.longitude)
        }

        var bias: (any CoordinateRegionBias)? = nil
        if let b = request.locationBias {
            if let rect = b.rectangular, let region = Mappers.mapRectangularBounds(rect) {
                bias = region
            } else if let circ = b.circular {
                bias = Mappers.mapCircularBounds(circ)
            }
        }

        var restriction: (any CoordinateRegionRestriction)? = nil
        if let r = request.locationRestriction {
            if let rect = r.rectangular, let region = Mappers.mapRectangularBounds(rect) {
                restriction = region
            } else if let circ = r.circular {
                restriction = Mappers.mapCircularBounds(circ)
            }
        }

        let filter = AutocompleteFilter(
            types: types,
            countries: countries,
            origin: origin,
            coordinateRegionBias: bias,
            coordinateRegionRestriction: restriction,
            regionCode: request.regionCode
        )

        let inputOffset = request.inputOffset.map { Int($0) } ?? 0
        let autocompleteRequest = AutocompleteRequest(
            query: request.query,
            sessionToken: token,
            filter: filter,
            inputOffset: inputOffset
        )

        let result = await PlacesClient.shared.fetchAutocompleteSuggestions(with: autocompleteRequest)

        switch result {
        case .success(let suggestions):
            return suggestions.compactMap { Mappers.mapSuggestion($0) }
        case .failure(let placesError):
            throw placesError
        }
    }

    func fetchPlace(request: PlatformFetchPlaceRequest) async throws -> PlatformPlace {
        guard isInitialized() else {
            throw PigeonError(code: "NOT_INITIALIZED", message: "Places SDK is not initialized. Call initialize() first.", details: nil)
        }

        let properties = request.fields.map { Mappers.mapPlaceProperty($0) }
        guard !properties.isEmpty else {
            throw PigeonError(code: "INVALID_ARGUMENT", message: "fields mask must not be empty.", details: nil)
        }

        let token: AutocompleteSessionToken?
        if let tokenString = request.sessionToken {
            token = resolveSessionToken(tokenString)
            // Conclude session on fetchPlace
            sessionTokens.removeValue(forKey: tokenString)
        } else {
            token = nil
        }

        let fetchRequest = FetchPlaceRequest(
            placeID: request.placeId,
            placeProperties: properties,
            sessionToken: token
        )

        let result = await PlacesClient.shared.fetchPlace(with: fetchRequest)

        switch result {
        case .success(let place):
            return Mappers.mapPlace(place)
        case .failure(let placesError):
            throw placesError
        }
    }

    private func resolveSessionToken(_ tokenString: String) -> AutocompleteSessionToken {
        if let existing = sessionTokens[tokenString] {
            return existing
        }
        let newToken = AutocompleteSessionToken()
        sessionTokens[tokenString] = newToken
        return newToken
    }
}
