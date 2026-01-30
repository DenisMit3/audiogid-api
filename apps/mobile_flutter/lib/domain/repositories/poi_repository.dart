import '../entities/poi.dart';

abstract class PoiRepository {
  Stream<Poi?> watchPoi(String id);
  Future<void> syncPoi(String id, String citySlug);
  Future<void> syncPoisForCity(String citySlug);
  Future<void> toggleFavorite(String id);
  Stream<List<Poi>> watchFavorites();
  Stream<List<Poi>> watchPoisForCity(String citySlug);
}
