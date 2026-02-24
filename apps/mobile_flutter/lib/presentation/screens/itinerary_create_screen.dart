import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/data/repositories/itinerary_repository.dart';
import 'package:mobile_flutter/data/repositories/poi_repository.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:mobile_flutter/core/api/device_id_provider.dart';
import 'package:mobile_flutter/presentation/widgets/common/common.dart';
import 'package:mobile_flutter/domain/entities/poi.dart';
import 'package:share_plus/share_plus.dart';

class ItineraryCreateScreen extends ConsumerStatefulWidget {
  const ItineraryCreateScreen({super.key});

  @override
  ConsumerState<ItineraryCreateScreen> createState() =>
      _ItineraryCreateScreenState();
}

class _ItineraryCreateScreenState extends ConsumerState<ItineraryCreateScreen> {
  final TextEditingController _titleController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itineraryIdsAsync = ref.watch(itineraryIdsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сохранение маршрута'),
      ),
      body: itineraryIdsAsync.when(
        data: (ids) {
          if (ids.isEmpty) {
            return const Center(child: Text('Маршрут пуст'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Название маршрута',
                    hintText: 'Например: Прогулка по центру',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Poi>>(
                  future: ref.read(poiRepositoryProvider).getPoisByIds(ids),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError)
                      return ErrorStateWidget.generic(error: snapshot.error);

                    final pois = snapshot.data ?? [];
                    // Sync order with ids
                    final orderedPois = ids
                        .map((id) => pois.firstWhere((p) => p.id == id,
                            orElse: () => pois.first))
                        .toList();

                    return ReorderableListView.builder(
                      itemCount: orderedPois.length,
                      onReorder: (oldIndex, newIndex) {
                        ref
                            .read(itineraryIdsProvider.notifier)
                            .reorder(oldIndex, newIndex);
                        setState(() {}); // Rebuild to refresh list
                      },
                      itemBuilder: (context, index) {
                        final poi = orderedPois[index];
                        // Just a simple tile, assuming editing order implies knowledge of content
                        return ListTile(
                          key: ValueKey(poi.id),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              image: poi.media.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(poi.media.first.url),
                                      fit: BoxFit.cover)
                                  : null,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          title: Text(poi.titleRu),
                          trailing: const Icon(Icons.drag_handle),
                        );
                      },
                    );
                  },
                ),
              ),
              SafeAreaWrapper(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSaving ? null : () => _saveItinerary(ids),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Сохранить'),
                    ),
                  ),
                ),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => ErrorStateWidget.generic(error: e),
      ),
    );
  }

  Future<void> _saveItinerary(List<String> poiIds) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Введите название маршрута')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final citySlug = ref.read(selectedCityProvider).value;
      final deviceId = await ref.read(deviceIdProvider.future);

      if (citySlug == null) throw Exception("City not selected");

      final repo = await ref.read(itineraryRepositoryProvider.future);
      final result = await repo.createItinerary(
          title: title,
          citySlug: citySlug,
          poiIds: poiIds,
          deviceAnonId: deviceId ?? 'unknown');

      if (!mounted) return;

      final id = result['id'];
      final shareUrl =
          "https://audiogid.app/itinerary/$id"; // TODO: Use dynamic links or config

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Маршрут создан!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text('Ваш маршрут "$title" успешно сохранен.'),
              const SizedBox(height: 16),
              const Text('Поделитесь ссылкой с друзьями:'),
              SelectableText(shareUrl,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Share.share('Мой маршрут "$title": $shareUrl');
              },
              child: const Text('Поделиться'),
            ),
            TextButton(
              onPressed: () {
                // Clear local?
                // ref.read(itineraryIdsProvider.notifier).clear();
                // Don't clear automatically maybe? Let user decide.
                context.pop(); // Close dialog
                context.pop(); // Close screen
              },
              child: const Text('Готово'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
