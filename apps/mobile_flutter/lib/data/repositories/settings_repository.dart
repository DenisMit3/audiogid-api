import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_repository.g.dart';

class SettingsRepository {
  final SharedPreferences _prefs;
  static const _cityKey = 'selected_city_slug';
  static const _bgStartKey = 'bg_location_enabled';
  static const _tourProgressKey = 'tour_progress';
  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _locationPermissionAskedKey = 'location_permission_asked';

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
  Future<void> saveTourProgress(
      String tourId, int stepIndex, bool autoPlay) async {
    final jsonString =
        '$tourId|$stepIndex|$autoPlay|${DateTime.now().millisecondsSinceEpoch}';
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

  // Onboarding
  bool isOnboardingCompleted() {
    return _prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_onboardingCompletedKey, completed);
  }

  // Location Permission Asked
  bool isLocationPermissionAsked() {
    return _prefs.getBool(_locationPermissionAskedKey) ?? false;
  }

  Future<void> setLocationPermissionAsked(bool asked) async {
    await _prefs.setBool(_locationPermissionAskedKey, asked);
  }
}

@riverpod
Future<SettingsRepository> settingsRepository(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  return SettingsRepository(prefs);
}

@riverpod
class SelectedCity extends _$SelectedCity {
  @override
  Future<String?> build() async {
    final repo = await ref.watch(settingsRepositoryProvider.future);
    return repo.getSelectedCity();
  }

  Future<void> set(String slug) async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    await repo.setSelectedCity(slug);
    state = AsyncData(slug);
  }

  Future<void> clear() async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    await repo.clearSelectedCity();
    state = const AsyncData(null);
  }
}

@riverpod
class OnboardingCompleted extends _$OnboardingCompleted {
  @override
  Future<bool> build() async {
    final repo = await ref.watch(settingsRepositoryProvider.future);
    return repo.isOnboardingCompleted();
  }

  Future<void> complete() async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    await repo.setOnboardingCompleted(true);
    state = const AsyncData(true);
  }

  Future<void> reset() async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    await repo.setOnboardingCompleted(false);
    state = const AsyncData(false);
  }
}
