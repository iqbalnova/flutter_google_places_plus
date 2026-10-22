package id.gmedia.flutter_google_places_plus

import android.content.Context
import com.google.android.libraries.places.api.Places
import com.google.android.libraries.places.api.model.AutocompleteSessionToken
import com.google.android.libraries.places.api.net.FetchPlaceRequest
import com.google.android.libraries.places.api.net.FindAutocompletePredictionsRequest
import com.google.android.libraries.places.api.net.PlacesClient
import kotlinx.coroutines.tasks.await
import java.util.Locale
import java.util.concurrent.ConcurrentHashMap

class RealPlacesGateway : PlacesGateway {

    private var client: PlacesClient? = null
    private val sessionTokens = ConcurrentHashMap<String, AutocompleteSessionToken>()

    override fun initialize(context: Context, apiKey: String, locale: Locale?) {
        val appContext = context.applicationContext
        if (locale != null) {
            Places.initializeWithNewPlacesApiEnabled(appContext, apiKey, locale)
        } else {
            Places.initializeWithNewPlacesApiEnabled(appContext, apiKey)
        }
        client = Places.createClient(appContext)
    }

    override fun isInitialized(): Boolean {
        return Places.isInitialized() && client != null
    }

    override suspend fun findAutocompletePredictions(
        request: PlatformAutocompleteRequest
    ): List<PlatformAutocompletePrediction> {
        val placesClient = client
            ?: throw IllegalStateException("Places SDK is not initialized. Call initialize() first.")

        val builder = FindAutocompletePredictionsRequest.builder()
            .setQuery(request.query)

        request.sessionToken?.let { tokenString ->
            builder.setSessionToken(resolveSessionToken(tokenString))
        }

        request.countries?.let { countries ->
            if (countries.isNotEmpty()) {
                builder.setCountries(countries)
            }
        }

        request.placeTypes?.let { types ->
            if (types.isNotEmpty()) {
                builder.setTypesFilter(types)
            }
        }

        request.locationBias?.let { bias ->
            bias.rectangular?.let { rect ->
                builder.setLocationBias(Mappers.mapRectangularBounds(rect))
            }
            bias.circular?.let { circle ->
                builder.setLocationBias(Mappers.mapCircularBounds(circle))
            }
        }

        request.locationRestriction?.let { restriction ->
            restriction.rectangular?.let { rect ->
                builder.setLocationRestriction(Mappers.mapRectangularBounds(rect))
            }
            restriction.circular?.let { circle ->
                builder.setLocationRestriction(Mappers.mapCircularBounds(circle))
            }
        }

        request.origin?.let { origin ->
            builder.setOrigin(Mappers.mapLatLng(origin))
        }

        request.regionCode?.let { regionCode ->
            if (regionCode.isNotEmpty()) {
                builder.setRegionCode(regionCode)
            }
        }

        request.inputOffset?.let { offset ->
            builder.setInputOffset(offset.toInt())
        }

        val response = placesClient.findAutocompletePredictions(builder.build()).await()
        return response.autocompletePredictions.map { Mappers.mapPrediction(it) }
    }

    override suspend fun fetchPlace(request: PlatformFetchPlaceRequest): PlatformPlace {
        val placesClient = client
            ?: throw IllegalStateException("Places SDK is not initialized. Call initialize() first.")

        val fields = request.fields.map { Mappers.mapPlaceField(it) }
        val builder = FetchPlaceRequest.builder(request.placeId, fields)

        request.sessionToken?.let { tokenString ->
            builder.setSessionToken(resolveSessionToken(tokenString))
            // A fetchPlace request concludes the session for this token.
            sessionTokens.remove(tokenString)
        }

        request.regionCode?.let { regionCode ->
            if (regionCode.isNotEmpty()) {
                builder.setRegionCode(regionCode)
            }
        }

        val response = placesClient.fetchPlace(builder.build()).await()
        return Mappers.mapPlace(response.place)
    }

    private fun resolveSessionToken(rawToken: String): AutocompleteSessionToken {
        return sessionTokens.computeIfAbsent(rawToken) {
            AutocompleteSessionToken.newInstance()
        }
    }
}
