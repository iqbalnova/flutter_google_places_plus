package id.gmedia.flutter_google_places_plus

import android.content.Context
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.CommonStatusCodes
import com.google.android.libraries.places.api.net.PlacesStatusCodes
import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.util.Locale

class FlutterGooglePlacesPlusPlugin(
    private var gateway: PlacesGateway = RealPlacesGateway()
) : FlutterPlugin, PlacesHostApi {

    private var applicationContext: Context? = null

    internal fun setGatewayForTesting(customGateway: PlacesGateway) {
        this.gateway = customGateway
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        PlacesHostApi.setUp(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        PlacesHostApi.setUp(binding.binaryMessenger, null)
        applicationContext = null
    }

    override fun initialize(apiKey: String, locale: String?) {
        val context = applicationContext
            ?: throw FlutterError("NOT_ATTACHED", "Plugin is not attached to Flutter engine", null)

        val parsedLocale = locale?.let { parseLocale(it) }
        try {
            gateway.initialize(context, apiKey, parsedLocale)
        } catch (e: Exception) {
            throw FlutterError(
                "INITIALIZATION_ERROR",
                "Failed to initialize Places SDK: ${sanitizeMessage(e.message)}",
                null
            )
        }
    }

    override suspend fun findAutocompletePredictions(
        request: PlatformAutocompleteRequest
    ): List<PlatformAutocompletePrediction> {
        try {
            return gateway.findAutocompletePredictions(request)
        } catch (e: ApiException) {
            throw mapApiException(e)
        } catch (e: IllegalStateException) {
            throw FlutterError("NOT_INITIALIZED", sanitizeMessage(e.message), null)
        } catch (e: IllegalArgumentException) {
            throw FlutterError("INVALID_ARGUMENT", sanitizeMessage(e.message), null)
        } catch (e: FlutterError) {
            throw e
        } catch (e: Exception) {
            throw FlutterError("UNKNOWN", sanitizeMessage(e.message), null)
        }
    }

    override suspend fun fetchPlace(request: PlatformFetchPlaceRequest): PlatformPlace {
        try {
            return gateway.fetchPlace(request)
        } catch (e: ApiException) {
            throw mapApiException(e)
        } catch (e: IllegalStateException) {
            throw FlutterError("NOT_INITIALIZED", sanitizeMessage(e.message), null)
        } catch (e: IllegalArgumentException) {
            throw FlutterError("INVALID_ARGUMENT", sanitizeMessage(e.message), null)
        } catch (e: FlutterError) {
            throw e
        } catch (e: Exception) {
            throw FlutterError("UNKNOWN", sanitizeMessage(e.message), null)
        }
    }

    private fun mapApiException(e: ApiException): FlutterError {
        val codeName = when (e.statusCode) {
            PlacesStatusCodes.OVER_QUERY_LIMIT -> "OVER_QUERY_LIMIT"
            PlacesStatusCodes.REQUEST_DENIED -> "REQUEST_DENIED"
            PlacesStatusCodes.INVALID_REQUEST -> "INVALID_REQUEST"
            PlacesStatusCodes.NOT_FOUND -> "NOT_FOUND"
            CommonStatusCodes.NETWORK_ERROR -> "NETWORK_ERROR"
            CommonStatusCodes.TIMEOUT -> "TIMEOUT"
            CommonStatusCodes.API_NOT_CONNECTED -> "API_NOT_CONNECTED"
            else -> "API_ERROR_${e.statusCode}"
        }
        val safeMessage = sanitizeMessage(e.message ?: "Google Places API error")
        return FlutterError(codeName, safeMessage, e.statusCode)
    }

    private fun sanitizeMessage(msg: String?): String {
        if (msg == null) return "Unknown error"
        // Ensure no API keys or key parameters leak into error strings
        return msg.replace(Regex("key=[^&\\s]+"), "key=REDACTED")
            .replace(Regex("AIza[0-9A-Za-z-_]{35}"), "REDACTED_API_KEY")
    }

    private fun parseLocale(raw: String): Locale {
        val tag = raw.replace('_', '-')
        return Locale.forLanguageTag(tag)
    }
}
