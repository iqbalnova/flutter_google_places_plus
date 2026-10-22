import CoreLocation
import Foundation
import GooglePlacesSwift
import UIKit

enum Mappers {

    static func mapLatLng(_ p: PlatformLatLng) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: p.latitude, longitude: p.longitude)
    }

    static func unmapLatLng(_ c: CLLocationCoordinate2D) -> PlatformLatLng {
        return PlatformLatLng(latitude: c.latitude, longitude: c.longitude)
    }

    static func mapCircularBounds(_ b: PlatformCircularBounds) -> CircularCoordinateRegion {
        return CircularCoordinateRegion(center: mapLatLng(b.center), radius: b.radiusMeters)
    }

    static func mapRectangularBounds(_ b: PlatformLatLngBounds) -> RectangularCoordinateRegion? {
        return RectangularCoordinateRegion(
            northEast: mapLatLng(b.northeast),
            southWest: mapLatLng(b.southwest)
        )
    }

    static func mapPlaceProperty(_ field: PlatformPlaceField) -> PlaceProperty {
        switch field {
        case .id:
            return .placeID
        case .displayName:
            return .displayName
        case .formattedAddress:
            return .formattedAddress
        case .location:
            return .coordinate
        case .viewport:
            return .viewportInfo
        case .addressComponents:
            return .addressComponents
        case .types:
            return .types
        case .primaryType:
            return .types
        case .internationalPhoneNumber, .nationalPhoneNumber:
            return .internationalPhoneNumber
        case .rating:
            return .rating
        case .userRatingCount:
            return .numberOfUserRatings
        case .businessStatus:
            return .businessStatus
        case .priceLevel:
            return .priceLevel
        case .websiteUri:
            return .websiteURL
        case .googleMapsUri:
            return .googleMapsLinks
        case .iconMaskUrl:
            return .iconMaskURL
        case .iconBackgroundColor:
            return .iconBackgroundColor
        case .utcOffsetMinutes:
            return .timeZone
        }
    }

    static func mapSuggestion(_ suggestion: AutocompleteSuggestion) -> PlatformAutocompletePrediction? {
        switch suggestion {
        case .place(let placeSuggestion):
            let fullText = String(placeSuggestion.attributedFullText.characters)
            let primaryText = String(placeSuggestion.attributedPrimaryText.characters)
            let secondaryText = placeSuggestion.attributedSecondaryText.map { String($0.characters) }
            let types = placeSuggestion.types.map { $0.rawValue }
            let distance = placeSuggestion.distance.map { Int64($0.converted(to: .meters).value.rounded()) }

            return PlatformAutocompletePrediction(
                placeId: placeSuggestion.placeID,
                fullText: fullText,
                primaryText: primaryText,
                secondaryText: secondaryText,
                placeTypes: types,
                distanceMeters: distance
            )
        @unknown default:
            return nil
        }
    }

    static func mapPriceLevel(_ level: PriceLevel) -> Int64? {
        switch level {
        case .unspecified:
            return nil
        case .free:
            return 0
        case .inexpensive:
            return 1
        case .moderate:
            return 2
        case .expensive:
            return 3
        case .veryExpensive:
            return 4
        }
    }

    static func mapBusinessStatus(_ status: BusinessStatus) -> String? {
        switch status {
        case .unknown:
            return nil
        case .operational:
            return "OPERATIONAL"
        case .closedTemporarily:
            return "CLOSED_TEMPORARILY"
        case .closedPermanently:
            return "CLOSED_PERMANENTLY"
        }
    }

    static func mapPlace(_ place: Place) -> PlatformPlace {
        let location = unmapLatLng(place.location)
        let viewport: PlatformLatLngBounds? = place.viewportInfo.map { vp in
            PlatformLatLngBounds(
                southwest: unmapLatLng(vp.southWest),
                northeast: unmapLatLng(vp.northEast)
            )
        }
        let addressComponents: [PlatformAddressComponent]? = place.addressComponents?.map { c in
            PlatformAddressComponent(
                name: c.name,
                shortName: c.shortName,
                types: c.types
            )
        }
        let types: [String]? = place.types.isEmpty ? nil : place.types.map { $0.rawValue }
        let colorHex = place.iconBackgroundColor.map { color -> String in
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
            return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        }

        let utcMinutes = place.timeZone.map { Int64($0.secondsFromGMT() / 60) }

        var result = PlatformPlace()
        result.id = place.placeID
        result.displayName = place.displayName
        result.formattedAddress = place.formattedAddress
        result.location = location
        result.viewport = viewport
        result.addressComponents = addressComponents
        result.types = types
        result.internationalPhoneNumber = place.internationalPhoneNumber
        result.rating = place.rating.map { Double($0) }
        result.userRatingCount = Int64(place.numberOfUserRatings)
        result.businessStatus = mapBusinessStatus(place.businessStatus)
        result.priceLevel = mapPriceLevel(place.priceLevel)
        result.websiteUri = place.websiteURL?.absoluteString
        result.googleMapsUri = place.googleMapsLinks?.placeURL?.absoluteString ?? place.googleMapsLinks?.directionsURL?.absoluteString
        result.iconMaskUrl = place.iconMaskURL?.absoluteString
        result.iconBackgroundColor = colorHex
        result.utcOffsetMinutes = utcMinutes
        return result
    }
}
