import 'package:dio/dio.dart';
import '../../domain/entities/helper.dart';
import '../../domain/repositories/helper_repository.dart';

class HelperRepositoryImpl implements HelperRepository {
  final Dio _dio;
  final String? _citySlug;

  HelperRepositoryImpl(this._dio, this._citySlug);

  @override
  Future<List<Helper>> getHelpers(double lat, double lon, double radiusKm) async {
    // Current requirement is to fetch by city (Comment 3)
    // "fetch to /public/helpers using the current city"
    // ignoring lat/lon/radius for the API call if it's city based,
    // or passing them as query params if supported.
    // Comment says "honor radius/filters".
    // If API supports lat/lon/radius, we pass it. If API is just city based, we filter locally?
    // Using city as primary filter per comment 3 replacement text.
    return getAllHelpers();
  }

  @override
  Future<List<Helper>> getAllHelpers() async {
    if (_citySlug == null) {
      return [];
    }
    
    try {
      final response = await _dio.get(
        '/public/helpers', 
        queryParameters: {
          'city': _citySlug, 
          // 'type': optional category logic handled by caller or here? 
          // Comment says "optional category". But getHelpers doesn't take category.
          // We fetch all for city and filter in UI/Provider (as seen in nearby_screen).
        }
      );

      if (response.statusCode == 200) {
        final List data = response.data as List;
        return data.map((json) => _fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      // Ensure errors propagate?
      // Or return empty on optional data failure?
      // Comment says "ensure errors/loading propagate to the UI".
      // So we rethrow.
      rethrow;
    }
  }

  Helper _fromJson(Map<String, dynamic> json) {
    return Helper(
      id: json['id'] as String,
      title: json['title'] as String,
      type: _parseType(json['type'] as String?),
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      address: json['address'] as String?,
      metadata: json['metadata'] ?? {},
    );
  }

  HelperType _parseType(String? type) {
    switch (type) {
      case 'toilet': return HelperType.toilet;
      case 'cafe': return HelperType.cafe;
      case 'drinking_water': 
      case 'water': return HelperType.drinkingWater;
      default: return HelperType.other;
    }
  }
}
