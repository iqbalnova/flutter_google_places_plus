import Foundation

@MainActor
final class FakePlacesGateway: PlacesGateway, @unchecked Sendable {
    var initialized = false
    var initializedKey: String?
    var initializedLocale: String?

    var autocompleteResponse: [PlatformAutocompletePrediction] = []
    var autocompleteError: Error?
    var lastAutocompleteRequest: PlatformAutocompleteRequest?

    var fetchPlaceResponse: PlatformPlace?
    var fetchPlaceError: Error?
    var lastFetchPlaceRequest: PlatformFetchPlaceRequest?

    nonisolated init() {}

    func initialize(apiKey: String, locale: String?) throws {
        initialized = true
        initializedKey = apiKey
        initializedLocale = locale
    }

    func isInitialized() -> Bool {
        return initialized
    }

    func findAutocompletePredictions(
        request: PlatformAutocompleteRequest
    ) async throws -> [PlatformAutocompletePrediction] {
        if let error = autocompleteError {
            throw error
        }
        lastAutocompleteRequest = request
        return autocompleteResponse
    }

    func fetchPlace(request: PlatformFetchPlaceRequest) async throws -> PlatformPlace {
        if let error = fetchPlaceError {
            throw error
        }
        lastFetchPlaceRequest = request
        var place = fetchPlaceResponse ?? PlatformPlace()
        if place.id == nil {
            place.id = request.placeId
        }
        return place
    }
}
