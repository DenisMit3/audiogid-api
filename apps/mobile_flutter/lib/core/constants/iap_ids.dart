class IAPIds {
  // POI purchases - Consumable or Non-Consumable depending on logic.
  // Using 'app.audiogid.poi.{id}'
  static String poiProduct(String poiId) => 'app.audiogid.poi.$poiId';

  // Bundle purchases
  static String bundleProduct(String bundleId) =>
      'app.audiogid.bundle.$bundleId';

  // Tour purchases
  static String tourProduct(String tourId) => 'app.audiogid.tour.$tourId';

  // Legacy/hardcoded products (if any)
  static const String fullCityAccess = 'full_city_access';
}
