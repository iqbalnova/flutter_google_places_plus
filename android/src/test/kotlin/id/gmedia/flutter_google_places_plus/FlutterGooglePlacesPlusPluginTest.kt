package id.gmedia.flutter_google_places_plus

import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows

class FlutterGooglePlacesPlusPluginTest {

    private lateinit var fakeGateway: FakePlacesGateway
    private lateinit var plugin: FlutterGooglePlacesPlusPlugin

    @BeforeEach
    fun setUp() {
        fakeGateway = FakePlacesGateway()
        plugin = FlutterGooglePlacesPlusPlugin(fakeGateway)
    }

    @Test
    fun findAutocompletePredictions_delegatesToGateway() = runTest {
        fakeGateway.autocompleteResponse = listOf(
            PlatformAutocompletePrediction(
                placeId = "place_id_123",
                fullText = "Malioboro, Yogyakarta",
                primaryText = "Malioboro",
                secondaryText = "Yogyakarta",
                placeTypes = listOf("route"),
                distanceMeters = 300L
            )
        )

        val request = PlatformAutocompleteRequest(
            query = "Malioboro",
            sessionToken = "session-uuid",
            countries = listOf("ID"),
            placeTypes = listOf("route"),
            locationBias = null,
            locationRestriction = null,
            origin = PlatformLatLng(-7.79, 110.37),
            regionCode = "ID",
            inputOffset = 9L
        )

        val results = plugin.findAutocompletePredictions(request)
        assertEquals(1, results.size)
        assertEquals("place_id_123", results[0].placeId)
        assertEquals("Malioboro", results[0].primaryText)
        assertEquals(300L, results[0].distanceMeters)

        assertEquals("Malioboro", fakeGateway.lastAutocompleteRequest?.query)
        assertEquals("session-uuid", fakeGateway.lastAutocompleteRequest?.sessionToken)
    }

    @Test
    fun fetchPlace_delegatesToGateway() = runTest {
        fakeGateway.fetchPlaceResponse = PlatformPlace(
            id = "place_id_123",
            displayName = "Keraton Yogyakarta",
            formattedAddress = "Jl. Rotowijayan",
            rating = 4.8,
            userRatingCount = 1000L,
            businessStatus = "OPERATIONAL"
        )

        val request = PlatformFetchPlaceRequest(
            placeId = "place_id_123",
            fields = listOf(
                PlatformPlaceField.ID,
                PlatformPlaceField.DISPLAY_NAME,
                PlatformPlaceField.FORMATTED_ADDRESS,
                PlatformPlaceField.RATING
            ),
            sessionToken = "session-uuid",
            regionCode = "ID"
        )

        val place = plugin.fetchPlace(request)
        assertEquals("place_id_123", place.id)
        assertEquals("Keraton Yogyakarta", place.displayName)
        assertEquals(4.8, place.rating)

        assertEquals("place_id_123", fakeGateway.lastFetchPlaceRequest?.placeId)
        assertEquals("session-uuid", fakeGateway.lastFetchPlaceRequest?.sessionToken)
    }

    @Test
    fun findAutocompletePredictions_mapsIllegalStateExceptionToNotInitialized() = runTest {
        fakeGateway.autocompleteError = IllegalStateException("SDK not initialized")

        val request = PlatformAutocompleteRequest(query = "test")
        val error = assertThrows<FlutterError> {
            plugin.findAutocompletePredictions(request)
        }

        assertEquals("NOT_INITIALIZED", error.code)
    }

    @Test
    fun findAutocompletePredictions_mapsIllegalArgumentException() = runTest {
        fakeGateway.autocompleteError = IllegalArgumentException("Invalid bounds provided")

        val request = PlatformAutocompleteRequest(query = "test")
        val error = assertThrows<FlutterError> {
            plugin.findAutocompletePredictions(request)
        }

        assertEquals("INVALID_ARGUMENT", error.code)
    }

    @Test
    fun sanitizeMessage_redactsApiKeyFromErrorMessage() = runTest {
        fakeGateway.autocompleteError = IllegalStateException(
            "Request failed for https://maps.googleapis.com/v1/places:autocomplete?key=AIzaSyD-abc123456789012345678901234567"
        )

        val request = PlatformAutocompleteRequest(query = "test")
        val error = assertThrows<FlutterError> {
            plugin.findAutocompletePredictions(request)
        }

        val message = error.message ?: ""
        assertTrue(!message.contains("AIzaSyD-abc123456789012345678901234567"))
        assertTrue(message.contains("REDACTED"))
    }
}
