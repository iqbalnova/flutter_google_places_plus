import Foundation

@MainActor
protocol PlacesGateway: Sendable {
    func initialize(apiKey: String, locale: String?) throws
    func isInitialized() -> Bool
    func findAutocompletePredictions(request: PlatformAutocompleteRequest) async throws -> [PlatformAutocompletePrediction]
    func fetchPlace(request: PlatformFetchPlaceRequest) async throws -> PlatformPlace
}
