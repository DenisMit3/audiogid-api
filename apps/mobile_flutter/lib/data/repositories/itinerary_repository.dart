import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'itinerary_repository.g.dart';

class ItineraryRepository {
  final SharedPreferences _prefs;
  static const _key = 'custom_itinerary_ids';

  ItineraryRepository(this._prefs);

  List<String> getItineraryIds() {
    return _prefs.getStringList(_key) ?? [];
  }

  Future<void> addToItinerary(String id) async {
    final list = getItineraryIds();
    if (!list.contains(id)) {
      list.add(id);
      await _prefs.setStringList(_key, list);
    }
  }

  Future<void> removeFromItinerary(String id) async {
    final list = getItineraryIds();
    list.remove(id);
    await _prefs.setStringList(_key, list);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = getItineraryIds();
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    await _prefs.setStringList(_key, list);
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}

@riverpod
Future<ItineraryRepository> itineraryRepository(ItineraryRepositoryRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  return ItineraryRepository(prefs);
}

@riverpod
class ItineraryIds extends _$ItineraryIds {
  @override
  Future<List<String>> build() async {
    final repo = await ref.watch(itineraryRepositoryProvider.future);
    return repo.getItineraryIds();
  }

  Future<void> add(String id) async {
    final repo = await ref.read(itineraryRepositoryProvider.future);
    await repo.addToItinerary(id);
    state = AsyncData(repo.getItineraryIds());
  }

  Future<void> remove(String id) async {
    final repo = await ref.read(itineraryRepositoryProvider.future);
    await repo.removeFromItinerary(id);
    state = AsyncData(repo.getItineraryIds());
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final repo = await ref.read(itineraryRepositoryProvider.future);
    await repo.reorder(oldIndex, newIndex);
    state = AsyncData(repo.getItineraryIds());
  }
  
  Future<void> clear() async {
    final repo = await ref.read(itineraryRepositoryProvider.future);
    await repo.clear();
    state = const AsyncData([]);
  }
}
