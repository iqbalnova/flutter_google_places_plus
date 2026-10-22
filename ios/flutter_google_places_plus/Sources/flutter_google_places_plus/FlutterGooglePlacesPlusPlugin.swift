import Flutter
import Foundation
import UIKit

public final class FlutterGooglePlacesPlusPlugin: NSObject, FlutterPlugin, PlacesHostApi {

    private var gateway: PlacesGateway

    public override init() {
        self.gateway = RealPlacesGateway()
        super.init()
    }

    init(gateway: PlacesGateway) {
        self.gateway = gateway
        super.init()
    }

    func setGatewayForTesting(_ customGateway: PlacesGateway) {
        self.gateway = customGateway
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        let instance = FlutterGooglePlacesPlusPlugin()
        PlacesHostApiSetup.setUp(binaryMessenger: messenger, api: instance)
    }

    func initialize(apiKey: String, locale: String?) throws {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else {
            throw PigeonError(code: "INVALID_ARGUMENT", message: "API key must not be empty.", details: nil)
        }
        do {
            if Thread.isMainThread {
                try MainActor.assumeIsolated {
                    try gateway.initialize(apiKey: trimmedKey, locale: locale)
                }
            } else {
                try DispatchQueue.main.sync {
                    try gateway.initialize(apiKey: trimmedKey, locale: locale)
                }
            }
        } catch {
            throw PigeonError(code: "INITIALIZATION_ERROR", message: sanitizeMessage(error.localizedDescription), details: nil)
        }
    }

    func findAutocompletePredictions(
        request: PlatformAutocompleteRequest
    ) async throws -> [PlatformAutocompletePrediction] {
        do {
            return try await gateway.findAutocompletePredictions(request: request)
        } catch let error as PigeonError {
            throw error
        } catch {
            throw mapError(error)
        }
    }

    func fetchPlace(request: PlatformFetchPlaceRequest) async throws -> PlatformPlace {
        do {
            return try await gateway.fetchPlace(request: request)
        } catch let error as PigeonError {
            throw error
        } catch {
            throw mapError(error)
        }
    }

    private func mapError(_ error: Error) -> PigeonError {
        let message = sanitizeMessage(error.localizedDescription)
        let nsError = error as NSError
        let code = "API_ERROR_\(nsError.code)"
        return PigeonError(code: code, message: message, details: "\(nsError.domain):\(nsError.code)")
    }

    private func sanitizeMessage(_ msg: String) -> String {
        var result = msg
        if let regex = try? NSRegularExpression(pattern: "key=[^&\\s]+") {
            let range = NSRange(result.startIndex..<result.endIndex, in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "key=REDACTED")
        }
        if let regex = try? NSRegularExpression(pattern: "AIza[0-9A-Za-z-_]{35}") {
            let range = NSRange(result.startIndex..<result.endIndex, in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "REDACTED_API_KEY")
        }
        return result
    }
}
