import 'poi.dart';

class Tour {
  final String id;
  final String citySlug;
  final String titleRu;
  final String? descriptionRu;
  final String? coverImage;
  final int? durationMinutes;
  final String? transportType;
  final double? distanceKm;
  final String? tourType;
  final List<TourItemEntity>? items;
  final double? priceAmount;
  final String priceCurrency;
  final bool isFree;
  final double? avgRating;
  final int ratingCount;

  Tour({
    required this.id,
    required this.citySlug,
    required this.titleRu,
    this.descriptionRu,
    this.coverImage,
    this.durationMinutes,
    this.transportType,
    this.distanceKm,
    this.tourType,
    this.items,
    this.priceAmount,
    this.priceCurrency = 'RUB',
    this.isFree = false,
    this.avgRating,
    this.ratingCount = 0,
  });
}

class TourItemEntity {
  final String id;
  final String tourId;
  final String poiId;
  final int orderIndex;
  final double? overrideLat;
  final double? overrideLon;
  final String? transitionTextRu;
  final String? transitionAudioUrl;
  final Poi? poi;

  // Computed: use override if set, otherwise use POI coordinates
  double? get effectiveLat => overrideLat ?? poi?.lat;
  double? get effectiveLon => overrideLon ?? poi?.lon;

  TourItemEntity({
    required this.id,
    required this.tourId,
    required this.poiId,
    required this.orderIndex,
    this.overrideLat,
    this.overrideLon,
    this.transitionTextRu,
    this.transitionAudioUrl,
    this.poi,
  });
}
