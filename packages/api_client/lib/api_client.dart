library api_client;

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';

part 'api/health_api.dart';

class ApiClient {
    // Scaffold stub for the client base
    Future<Response> invokeAPI(String path, String method, List<QueryParam> queryParams, Object? body, Map<String, String> headerParams, Map<String, String> formParams, String? contentType) async {
        throw UnimplementedError();
    }
}

final defaultApiClient = ApiClient();
class QueryParam {}
