import '../entities/tour.dart';

abstract class TourRepository {
  Stream<List<Tour>> watchTours(String citySlug);
  Stream<Tour?> watchTour(String id);
  Future<void> syncTours(String citySlug);
  Future<void> syncTourDetail(String id, String citySlug);
}
