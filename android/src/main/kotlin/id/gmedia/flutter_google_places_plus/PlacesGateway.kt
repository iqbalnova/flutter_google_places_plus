package id.gmedia.flutter_google_places_plus

import android.content.Context
import java.util.Locale

interface PlacesGateway {
    fun initialize(context: Context, apiKey: String, locale: Locale?)
    fun isInitialized(): Boolean
    suspend fun findAutocompletePredictions(request: PlatformAutocompleteRequest): List<PlatformAutocompletePrediction>
    suspend fun fetchPlace(request: PlatformFetchPlaceRequest): PlatformPlace
}
