import CoreLocation
import Foundation
import GooglePlaces
import UIKit

enum Mappers {

    static func mapLatLng(_ p: PlatformLatLng) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: p.latitude, longitude: p.longitude)
    }

    static func unmapLatLng(_ c: CLLocationCoordinate2D) -> PlatformLatLng {
        return PlatformLatLng(latitude: c.latitude, longitude: c.longitude)
    }

    static func mapPlaceField(_ field: PlatformPlaceField) -> GMSPlaceProperty {
        switch field {
        case .id:
            return .placeID
        case .displayName:
            return .name
        case .formattedAddress:
            return .formattedAddress
        case .location:
            return .coordinate
        case .viewport:
            return .viewport
        case .addressComponents:
            return .addressComponents
        case .types:
            return .types
        case .primaryType:
            return .types
        case .internationalPhoneNumber, .nationalPhoneNumber:
            return .phoneNumber
        case .rating:
            return .rating
        case .userRatingCount:
            return .userRatingsTotal
        case .businessStatus:
            return .businessStatus
        case .priceLevel:
            return .priceLevel
        case .websiteUri:
            return .website
        case .googleMapsUri:
            return GMSPlaceProperty(rawValue: "googleMapsLinks")
        case .iconMaskUrl:
            return .iconImageURL
        case .iconBackgroundColor:
            return .iconBackgroundColor
        case .utcOffsetMinutes:
            return .utcOffsetMinutes
        }
    }

    static func mapPrediction(_ prediction: GMSAutocompletePrediction) -> PlatformAutocompletePrediction {
        let fullText = prediction.attributedFullText.string
        let primaryText = prediction.attributedPrimaryText.string
        let secondaryText = prediction.attributedSecondaryText?.string
        let types = prediction.types
        let distance = prediction.distanceMeters?.int64Value

        return PlatformAutocompletePrediction(
            placeId: prediction.placeID,
            fullText: fullText,
            primaryText: primaryText,
            secondaryText: secondaryText,
            placeTypes: types,
            distanceMeters: distance
        )
    }

    static func mapBusinessStatus(_ status: GMSPlacesBusinessStatus) -> String? {
        switch status {
        case .operational:
            return "OPERATIONAL"
        case .closedTemporarily:
            return "CLOSED_TEMPORARILY"
        case .closedPermanently:
            return "CLOSED_PERMANENTLY"
        case .unknown:
            return nil
        @unknown default:
            return nil
        }
    }

    static func mapPriceLevel(_ level: GMSPlacesPriceLevel) -> Int64? {
        switch level {
        case .free:
            return 0
        case .cheap:
            return 1
        case .medium:
            return 2
        case .high:
            return 3
        case .expensive:
            return 4
        case .unknown:
            return nil
        @unknown default:
            return nil
        }
    }

    static func mapPlace(_ place: GMSPlace) -> PlatformPlace {
        let location = unmapLatLng(place.coordinate)
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
        let types = place.types
        let colorHex = place.iconBackgroundColor.map { color -> String in
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
            return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        }

        var result = PlatformPlace()
        result.id = place.placeID
        result.displayName = place.name
        result.formattedAddress = place.formattedAddress
        result.location = location
        result.viewport = viewport
        result.addressComponents = addressComponents
        result.types = types
        result.internationalPhoneNumber = place.phoneNumber
        result.rating = Double(place.rating)
        result.userRatingCount = Int64(place.userRatingsTotal)
        result.businessStatus = mapBusinessStatus(place.businessStatus)
        result.priceLevel = mapPriceLevel(place.priceLevel)
        result.websiteUri = place.website?.absoluteString
        result.iconMaskUrl = place.iconImageURL?.absoluteString
        result.iconBackgroundColor = colorHex
        result.utcOffsetMinutes = Int64(place.utcOffsetMinutes?.intValue ?? 0)
        return result
    }
}
