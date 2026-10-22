package id.gmedia.flutter_google_places_plus

import android.content.Context
import java.util.Locale

class FakePlacesGateway : PlacesGateway {
    var initialized = false
    var initializedKey: String? = null
    var initializedLocale: Locale? = null

    var autocompleteResponse: List<PlatformAutocompletePrediction> = emptyList()
    var autocompleteError: Throwable? = null
    var lastAutocompleteRequest: PlatformAutocompleteRequest? = null

    var fetchPlaceResponse: PlatformPlace? = null
    var fetchPlaceError: Throwable? = null
    var lastFetchPlaceRequest: PlatformFetchPlaceRequest? = null

    override fun initialize(context: Context, apiKey: String, locale: Locale?) {
        initialized = true
        initializedKey = apiKey
        initializedLocale = locale
    }

    override fun isInitialized(): Boolean = initialized

    override suspend fun findAutocompletePredictions(
        request: PlatformAutocompleteRequest
    ): List<PlatformAutocompletePrediction> {
        autocompleteError?.let { throw it }
        lastAutocompleteRequest = request
        return autocompleteResponse
    }

    override suspend fun fetchPlace(request: PlatformFetchPlaceRequest): PlatformPlace {
        fetchPlaceError?.let { throw it }
        lastFetchPlaceRequest = request
        return fetchPlaceResponse ?: PlatformPlace(id = request.placeId)
    }
}
