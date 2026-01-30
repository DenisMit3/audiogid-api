import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString('device_anon_id');
    
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString('device_anon_id', deviceId);
    }

    options.headers['X-Device-Anon-ID'] = deviceId;
    // Add other auth headers if needed (e.g. Bearer token)
    
    handler.next(options);
  }
}
