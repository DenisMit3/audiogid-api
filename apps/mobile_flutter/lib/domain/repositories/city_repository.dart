import '../entities/city.dart';

abstract class CityRepository {
  Stream<List<City>> watchCities();
  Future<void> syncCities();
}
