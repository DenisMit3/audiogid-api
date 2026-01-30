import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/core/audio/providers.dart';
import 'package:mobile_flutter/data/repositories/entitlement_repository.dart';
import 'package:mobile_flutter/domain/entities/poi.dart';

class AudioPlayerService {
  final AudioHandler _handler;
  final Ref _ref;

  AudioPlayerService(this._handler, this._ref);

  /// Loads a playlist for a tour using the provided POIs.
  /// Handles entitlement checking (Preview vs Full).
  Future<void> loadPlaylist({
    required String tourId,
    required List<Poi> pois,
    required int initialIndex,
  }) async {
    // 1. Check entitlements
    final grants = await _ref.read(entitlementGrantsProvider.future);
    final hasAccess = grants.any((g) =>
        g.isActive &&
        ((g.scope == 'tour' && g.ref == tourId) || 
         (pois.isNotEmpty && g.scope == 'city' && g.ref == pois.first.citySlug) ||
         g.scope == 'all_access'));

    final queue = <MediaItem>[];
    
    // 2. Build Queue
    for (final poi in pois) {
      final narration = poi.narrations.isNotEmpty ? poi.narrations.first : null;
      String? audioUrl;

      // Gating Logic
      if (hasAccess) {
        // Full access: prioritize local file
        if (narration != null) {
          if (narration.localPath != null && File(narration.localPath!).existsSync()) {
            audioUrl = Uri.file(narration.localPath!).toString();
          } else {
            audioUrl = narration.url;
          }
        }
      } else {
        // Restricted: Use preview if available
        if (poi.previewAudioUrl != null) {
          audioUrl = poi.previewAudioUrl;
        }
      }

      if (audioUrl != null) {
        queue.add(MediaItem(
          id: audioUrl,
          album: 'Tour',
          title: poi.titleRu,
          artist: 'Audiogid',
          artUri: poi.media.isNotEmpty ? Uri.tryParse(poi.media.first.url) : null,
          extras: {
            'poiId': poi.id,
            'tourId': tourId,
            'isPreview': !hasAccess && (audioUrl == poi.previewAudioUrl),
          },
        ));
      }
    }

    if (queue.isEmpty) return;

    await _handler.stop();
    await _handler.updateQueue(queue);

    // 3. Find correct start index
    if (initialIndex >= 0 && initialIndex < pois.length) {
      final startPoiId = pois[initialIndex].id;
      final indexInQueue = queue.indexWhere((item) => item.extras?['poiId'] == startPoiId);
      
      if (indexInQueue != -1) {
        await _handler.skipToQueueItem(indexInQueue);
      } else {
        // Fallback to first if filtered out
        await _handler.skipToQueueItem(0);
      }
    } else {
      await _handler.skipToQueueItem(0);
    }
  }

  Future<void> play() => _handler.play();
  Future<void> pause() => _handler.pause();
  Future<void> stop() => _handler.stop();
  Future<void> skipToNext() => _handler.skipToNext();
  Future<void> skipToPrevious() => _handler.skipToPrevious();
  Future<void> seek(Duration position) => _handler.seek(position);
}

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  return AudioPlayerService(
    ref.watch(audioHandlerProvider),
    ref,
  );
});
