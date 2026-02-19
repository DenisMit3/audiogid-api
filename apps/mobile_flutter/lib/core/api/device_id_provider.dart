import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'device_id_provider.g.dart';

@riverpod
Future<String> deviceId(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'device_anon_id';
  var id = prefs.getString(key);
  if (id == null) {
    id = const Uuid().v4();
    await prefs.setString(key, id);
  }
  return id;
}
