package id.gmedia.flutter_google_places_plus

import com.google.android.gms.maps.model.LatLng
import com.google.android.libraries.places.api.model.AddressComponent
import com.google.android.libraries.places.api.model.AutocompletePrediction
import com.google.android.libraries.places.api.model.CircularBounds
import com.google.android.libraries.places.api.model.Place
import com.google.android.libraries.places.api.model.RectangularBounds

object Mappers {

    fun mapLatLng(p: PlatformLatLng): LatLng {
        return LatLng(p.latitude, p.longitude)
    }

    fun unmapLatLng(l: LatLng): PlatformLatLng {
        return PlatformLatLng(latitude = l.latitude, longitude = l.longitude)
    }

    fun mapCircularBounds(b: PlatformCircularBounds): CircularBounds {
        return CircularBounds.newInstance(mapLatLng(b.center), b.radiusMeters)
    }

    fun mapRectangularBounds(b: PlatformLatLngBounds): RectangularBounds {
        return RectangularBounds.newInstance(mapLatLng(b.southwest), mapLatLng(b.northeast))
    }

    fun mapPlaceField(field: PlatformPlaceField): Place.Field {
        return when (field) {
            PlatformPlaceField.ID -> Place.Field.ID
            PlatformPlaceField.DISPLAY_NAME -> Place.Field.DISPLAY_NAME
            PlatformPlaceField.FORMATTED_ADDRESS -> Place.Field.FORMATTED_ADDRESS
            PlatformPlaceField.LOCATION -> Place.Field.LOCATION
            PlatformPlaceField.VIEWPORT -> Place.Field.VIEWPORT
            PlatformPlaceField.ADDRESS_COMPONENTS -> Place.Field.ADDRESS_COMPONENTS
            PlatformPlaceField.TYPES -> Place.Field.TYPES
            PlatformPlaceField.PRIMARY_TYPE -> Place.Field.PRIMARY_TYPE
            PlatformPlaceField.INTERNATIONAL_PHONE_NUMBER -> Place.Field.INTERNATIONAL_PHONE_NUMBER
            PlatformPlaceField.NATIONAL_PHONE_NUMBER -> Place.Field.NATIONAL_PHONE_NUMBER
            PlatformPlaceField.RATING -> Place.Field.RATING
            PlatformPlaceField.USER_RATING_COUNT -> Place.Field.USER_RATING_COUNT
            PlatformPlaceField.BUSINESS_STATUS -> Place.Field.BUSINESS_STATUS
            PlatformPlaceField.PRICE_LEVEL -> Place.Field.PRICE_LEVEL
            PlatformPlaceField.WEBSITE_URI -> Place.Field.WEBSITE_URI
            PlatformPlaceField.GOOGLE_MAPS_URI -> Place.Field.GOOGLE_MAPS_URI
            PlatformPlaceField.ICON_MASK_URL -> Place.Field.ICON_MASK_URL
            PlatformPlaceField.ICON_BACKGROUND_COLOR -> Place.Field.ICON_BACKGROUND_COLOR
            PlatformPlaceField.UTC_OFFSET_MINUTES -> Place.Field.UTC_OFFSET
        }
    }

    fun mapPrediction(prediction: AutocompletePrediction): PlatformAutocompletePrediction {
        val fullText = prediction.getFullText(null).toString()
        val primaryText = prediction.getPrimaryText(null).toString()
        val secondaryText = prediction.getSecondaryText(null).toString().ifEmpty { null }
        val types = prediction.types
        val distance = prediction.distanceMeters?.toLong()
        return PlatformAutocompletePrediction(
            placeId = prediction.placeId,
            fullText = fullText,
            primaryText = primaryText,
            secondaryText = secondaryText,
            placeTypes = types,
            distanceMeters = distance
        )
    }

    fun mapAddressComponent(c: AddressComponent): PlatformAddressComponent {
        return PlatformAddressComponent(
            name = c.name,
            shortName = c.shortName,
            types = c.types
        )
    }

    fun mapPlace(place: Place): PlatformPlace {
        val location = place.location?.let { unmapLatLng(it) }
        val viewport = place.viewport?.let {
            PlatformLatLngBounds(
                southwest = unmapLatLng(it.southwest),
                northeast = unmapLatLng(it.northeast)
            )
        }
        val addressComponents = place.addressComponents?.asList()?.map { mapAddressComponent(it) }
        val types = place.placeTypes
        val colorHex = place.iconBackgroundColor?.let { color ->
            String.format("#%06X", 0xFFFFFF and color)
        }
        return PlatformPlace(
            id = place.id,
            displayName = place.displayName,
            formattedAddress = place.formattedAddress,
            location = location,
            viewport = viewport,
            addressComponents = addressComponents,
            types = types,
            primaryType = place.primaryType,
            internationalPhoneNumber = place.internationalPhoneNumber,
            nationalPhoneNumber = place.nationalPhoneNumber,
            rating = place.rating,
            userRatingCount = place.userRatingCount?.toLong(),
            businessStatus = place.businessStatus?.name,
            priceLevel = place.priceLevel?.toLong(),
            websiteUri = place.websiteUri?.toString(),
            googleMapsUri = place.googleMapsUri?.toString(),
            iconMaskUrl = place.iconMaskUrl,
            iconBackgroundColor = colorHex,
            utcOffsetMinutes = place.utcOffsetMinutes?.toLong()
        )
    }
}
