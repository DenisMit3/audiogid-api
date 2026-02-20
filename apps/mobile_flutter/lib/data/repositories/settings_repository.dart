import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

part 'settings_repository.g.dart';

// #region agent log
void _debugLog(String location, String message, Map<String, dynamic> data) {
  try {
    final logFile = File('/data/data/app.audiogid.mobile_flutter/files/debug.log');
    final entry = jsonEncode({
      'sessionId': '03cf79',
      'location': location,
      'message': message,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    logFile.writeAsStringSync('$entry\n', mode: FileMode.append, flush: true);
  } catch (e) {
    debugPrint('DEBUG_LOG_ERROR: $e');
  }
}
// #endregion

class SettingsRepository {
  final SharedPreferences _prefs;
  static const _cityKey = 'selected_city_slug';
  static const _bgStartKey = 'bg_location_enabled';
  static const _tourProgressKey = 'tour_progress';

  SettingsRepository(this._prefs);

  String? getSelectedCity() {
    return _prefs.getString(_cityKey);
  }

  Future<void> setSelectedCity(String slug) async {
    await _prefs.setString(_cityKey, slug);
  }

  Future<void> clearSelectedCity() async {
    await _prefs.remove(_cityKey);
  }

  // Background Location
  bool getBackgroundLocationEnabled() {
    return _prefs.getBool(_bgStartKey) ?? false;
  }

  Future<void> setBackgroundLocationEnabled(bool enabled) async {
    await _prefs.setBool(_bgStartKey, enabled);
  }

  static const _kidsModeKey = 'kids_mode_enabled';

  bool getKidsModeEnabled() {
    return _prefs.getBool(_kidsModeKey) ?? false;
  }

  Future<void> setKidsModeEnabled(bool enabled) async {
    await _prefs.setBool(_kidsModeKey, enabled);
  }

  // Tour Progress
  Future<void> saveTourProgress(String tourId, int stepIndex, bool autoPlay) async {
    final jsonString = '$tourId|$stepIndex|$autoPlay|${DateTime.now().millisecondsSinceEpoch}';
    await _prefs.setString(_tourProgressKey, jsonString);
  }

  Map<String, dynamic>? getTourProgress() {
    final str = _prefs.getString(_tourProgressKey);
    if (str == null) return null;
    final parts = str.split('|');
    if (parts.length != 4) return null;
    return {
      'tourId': parts[0],
      'stepIndex': int.tryParse(parts[1]) ?? 0,
      'isAutoPlayEnabled': parts[2] == 'true',
      'timestamp': int.tryParse(parts[3]) ?? 0,
    };
  }

  Future<void> clearTourProgress() async {
    await _prefs.remove(_tourProgressKey);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

@riverpod
Future<SettingsRepository> settingsRepository(Ref ref) async {
  // #region agent log
  _debugLog('settings_repository.dart:settingsRepository:start', 'H2: settingsRepository started', {});
  // #endregion
  
  final prefs = await SharedPreferences.getInstance();
  
  // #region agent log
  _debugLog('settings_repository.dart:settingsRepository:done', 'H2: SharedPreferences obtained', {});
  // #endregion
  
  return SettingsRepository(prefs);
}

@riverpod
class SelectedCity extends _$SelectedCity {
  SettingsRepository? _repo;
  
  @override
  Future<String?> build() async {
    // #region agent log
    _debugLog('settings_repository.dart:SelectedCity:build:start', 'H1: SelectedCity.build started', {});
    // #endregion
    
    _repo = await ref.watch(settingsRepositoryProvider.future);
    final city = _repo!.getSelectedCity();
    
    // #region agent log
    _debugLog('settings_repository.dart:SelectedCity:build:done', 'H1: SelectedCity.build done', {'city': city});
    // #endregion
    
    return city;
  }

  Future<void> set(String slug) async {
    // #region agent log
    _debugLog('settings_repository.dart:SelectedCity:set:start', 'H16: set() started', {'slug': slug, '_repo': _repo != null});
    // #endregion
    
    final SettingsRepository repo;
    if (_repo != null) {
      repo = _repo!;
      // #region agent log
      _debugLog('settings_repository.dart:SelectedCity:set:using_cached', 'H16: Using cached repo', {});
      // #endregion
    } else {
      // #region agent log
      _debugLog('settings_repository.dart:SelectedCity:set:fetching_repo', 'H16: Fetching repo from provider', {});
      // #endregion
      repo = await ref.read(settingsRepositoryProvider.future);
      // #region agent log
      _debugLog('settings_repository.dart:SelectedCity:set:got_repo', 'H16: Got repo from provider', {});
      // #endregion
    }
    
    // #region agent log
    _debugLog('settings_repository.dart:SelectedCity:set:before_save', 'H16: Before setSelectedCity', {});
    // #endregion
    
    await repo.setSelectedCity(slug);
    
    // #region agent log
    _debugLog('settings_repository.dart:SelectedCity:set:after_save', 'H16: After setSelectedCity, setting state', {});
    // #endregion
    
    state = AsyncData(slug);
    
    // #region agent log
    _debugLog('settings_repository.dart:SelectedCity:set:done', 'H16: set() completed', {});
    // #endregion
  }

  Future<void> clear() async {
    final SettingsRepository repo;
    if (_repo != null) {
      repo = _repo!;
    } else {
      repo = await ref.read(settingsRepositoryProvider.future);
    }
    await repo.clearSelectedCity();
    state = const AsyncData(null);
  }
}
