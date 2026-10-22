package id.gmedia.flutter_google_places_plus

import com.google.android.gms.maps.model.LatLng
import com.google.android.libraries.places.api.model.Place
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.Test

class MappersTest {

    @Test
    fun mapLatLng_convertsCorrectly() {
        val platformLatLng = PlatformLatLng(latitude = -7.79, longitude = 110.37)
        val latLng = Mappers.mapLatLng(platformLatLng)

        assertEquals(-7.79, latLng.latitude, 0.0001)
        assertEquals(110.37, latLng.longitude, 0.0001)

        val unmapped = Mappers.unmapLatLng(latLng)
        assertEquals(-7.79, unmapped.latitude, 0.0001)
        assertEquals(110.37, unmapped.longitude, 0.0001)
    }

    @Test
    fun mapBounds_convertsCorrectly() {
        val bounds = PlatformLatLngBounds(
            southwest = PlatformLatLng(-8.0, 110.0),
            northeast = PlatformLatLng(-7.0, 111.0)
        )
        val rectangular = Mappers.mapRectangularBounds(bounds)
        assertEquals(-8.0, rectangular.southwest.latitude, 0.0001)
        assertEquals(111.0, rectangular.northeast.longitude, 0.0001)

        val circular = PlatformCircularBounds(
            center = PlatformLatLng(-7.79, 110.37),
            radiusMeters = 500.0
        )
        val circle = Mappers.mapCircularBounds(circular)
        assertEquals(-7.79, circle.center.latitude, 0.0001)
        assertEquals(500.0, circle.radius, 0.0001)
    }

    @Test
    fun mapPlaceField_mapsAllSupportedFields() {
        assertEquals(Place.Field.ID, Mappers.mapPlaceField(PlatformPlaceField.ID))
        assertEquals(Place.Field.DISPLAY_NAME, Mappers.mapPlaceField(PlatformPlaceField.DISPLAY_NAME))
        assertEquals(Place.Field.FORMATTED_ADDRESS, Mappers.mapPlaceField(PlatformPlaceField.FORMATTED_ADDRESS))
        assertEquals(Place.Field.LOCATION, Mappers.mapPlaceField(PlatformPlaceField.LOCATION))
        assertEquals(Place.Field.VIEWPORT, Mappers.mapPlaceField(PlatformPlaceField.VIEWPORT))
        assertEquals(Place.Field.ADDRESS_COMPONENTS, Mappers.mapPlaceField(PlatformPlaceField.ADDRESS_COMPONENTS))
        assertEquals(Place.Field.TYPES, Mappers.mapPlaceField(PlatformPlaceField.TYPES))
        assertEquals(Place.Field.PRIMARY_TYPE, Mappers.mapPlaceField(PlatformPlaceField.PRIMARY_TYPE))
        assertEquals(Place.Field.INTERNATIONAL_PHONE_NUMBER, Mappers.mapPlaceField(PlatformPlaceField.INTERNATIONAL_PHONE_NUMBER))
        assertEquals(Place.Field.NATIONAL_PHONE_NUMBER, Mappers.mapPlaceField(PlatformPlaceField.NATIONAL_PHONE_NUMBER))
        assertEquals(Place.Field.RATING, Mappers.mapPlaceField(PlatformPlaceField.RATING))
        assertEquals(Place.Field.USER_RATING_COUNT, Mappers.mapPlaceField(PlatformPlaceField.USER_RATING_COUNT))
        assertEquals(Place.Field.BUSINESS_STATUS, Mappers.mapPlaceField(PlatformPlaceField.BUSINESS_STATUS))
        assertEquals(Place.Field.PRICE_LEVEL, Mappers.mapPlaceField(PlatformPlaceField.PRICE_LEVEL))
        assertEquals(Place.Field.WEBSITE_URI, Mappers.mapPlaceField(PlatformPlaceField.WEBSITE_URI))
        assertEquals(Place.Field.GOOGLE_MAPS_URI, Mappers.mapPlaceField(PlatformPlaceField.GOOGLE_MAPS_URI))
        assertEquals(Place.Field.ICON_MASK_URL, Mappers.mapPlaceField(PlatformPlaceField.ICON_MASK_URL))
        assertEquals(Place.Field.ICON_BACKGROUND_COLOR, Mappers.mapPlaceField(PlatformPlaceField.ICON_BACKGROUND_COLOR))
        assertEquals(Place.Field.UTC_OFFSET, Mappers.mapPlaceField(PlatformPlaceField.UTC_OFFSET_MINUTES))
    }
}
