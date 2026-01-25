import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/city.dart';
import '../model/tour_snippet.dart';

class PublicApi {
  final String baseUrl;
  final http.Client _client;

  PublicApi(this.baseUrl, [http.Client? client]) : _client = client ?? http.Client();

  Future<List<City>> getCities() async {
    final response = await _client.get(Uri.parse('$baseUrl/public/cities'));
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => City.fromJson(e)).toList();
    }
    throw Exception('Failed to load cities');
  }

  Future<List<TourSnippet>> getCatalog(String city) async {
    final response = await _client.get(Uri.parse('$baseUrl/public/catalog?city=$city'));
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => TourSnippet.fromJson(e)).toList();
    }
    throw Exception('Failed to load catalog');
  }
}
