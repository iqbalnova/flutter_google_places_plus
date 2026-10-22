/// Supported place data fields for Place Details requests.
///
/// Use an explicit set of fields to avoid requesting unnecessary data and reduce billing costs.
enum PlaceField {
  id,
  displayName,
  formattedAddress,
  location,
  viewport,
  addressComponents,
  types,
  primaryType,
  internationalPhoneNumber,
  nationalPhoneNumber,
  rating,
  userRatingCount,
  businessStatus,
  priceLevel,
  websiteUri,
  googleMapsUri,
  iconMaskUrl,
  iconBackgroundColor,
  utcOffsetMinutes,
}
