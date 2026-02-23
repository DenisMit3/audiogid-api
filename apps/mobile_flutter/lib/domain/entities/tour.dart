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
  });
}

class TourItemEntity {
  final String id;
  final String tourId;
  final String poiId;
  final int orderIndex;
  final Poi? poi;

  TourItemEntity({
    required this.id,
    required this.tourId,
    required this.poiId,
    required this.orderIndex,
    this.poi,
  });
}
