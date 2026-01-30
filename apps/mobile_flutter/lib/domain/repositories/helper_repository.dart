import '../entities/helper.dart';

abstract class HelperRepository {
  Future<List<Helper>> getHelpers(double lat, double lon, double radiusKm);
  Future<List<Helper>> getAllHelpers();
}
