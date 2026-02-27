import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/core/audio/providers.dart';
import 'package:mobile_flutter/core/audio/audio_handler.dart';
import 'package:mobile_flutter/data/repositories/entitlement_repository.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:mobile_flutter/data/services/analytics_service.dart';
import 'package:mobile_flutter/domain/entities/poi.dart';
import 'package:mobile_flutter/domain/entities/tour.dart';
import 'package:mobile_flutter/domain/entities/entitlement_grant.dart';

class AudioPlayerService {
  final AudioHandler _handler;
  final Ref _ref;

  AudioPlayerService(this._handler, this._ref);

  /// Loads a playlist for a tour using the provided TourItems.
  /// Handles entitlement checking (Preview vs Full).
  /// Uses narrations if available, falls back to transitionAudioUrl.
  Future<void> loadPlaylist({
    required String tourId,
    required List<TourItemEntity> items,
    required int initialIndex,
  }) async {
    print(
        '[DEBUG AUDIO] loadPlaylist called: tourId=$tourId, items=${items.length}, initialIndex=$initialIndex');

    // 1. Check entitlements
    final grantsStream = _ref.read(entitlementGrantsProvider);
    final grants = grantsStream.value ?? <EntitlementGrant>[];
    final pois = items.where((i) => i.poi != null).map((i) => i.poi!).toList();
    final hasAccess = grants.any((g) =>
        g.isActive &&
        ((g.scope == 'tour' && g.ref == tourId) ||
            (pois.isNotEmpty &&
                g.scope == 'city' &&
                g.ref == pois.first.citySlug) ||
            g.scope == 'all_access'));

    print('[DEBUG AUDIO] hasAccess=$hasAccess, grants=${grants.length}');

    // Check Kids Mode
    final settingsAsync = _ref.read(settingsRepositoryProvider);
    final kidsMode = settingsAsync.value?.getKidsModeEnabled() ?? false;

    final queue = <MediaItem>[];

    // 2. Build Queue
    for (final item in items) {
      final poi = item.poi;
      if (poi == null) continue;

      final narration = poi.narrations.isNotEmpty ? poi.narrations.first : null;
      String? audioUrl;

      print(
          '[DEBUG AUDIO] POI: ${poi.titleRu}, narrations=${poi.narrations.length}, transitionAudioUrl=${item.transitionAudioUrl}');

      // Audio selection logic:
      // 1. If has full access AND narration exists -> use narration
      // 2. If transitionAudioUrl exists -> use it (always available, it's tour content)
      // 3. If no access and previewAudioUrl exists -> use preview

      if (hasAccess && narration != null) {
        // Full access with narration
        if (kidsMode && narration.kidsUrl != null) {
          audioUrl = narration.kidsUrl;
        } else if (narration.localPath != null &&
            File(narration.localPath!).existsSync()) {
          audioUrl = Uri.file(narration.localPath!).toString();
        } else {
          audioUrl = narration.url;
        }
        print('[DEBUG AUDIO] Using narration: $audioUrl');
      } else if (item.transitionAudioUrl != null) {
        // Transition audio is always available (it's part of tour, not gated)
        audioUrl = item.transitionAudioUrl;
        print('[DEBUG AUDIO] Using transitionAudioUrl: $audioUrl');
      } else if (!hasAccess && poi.previewAudioUrl != null) {
        // Fallback to preview for restricted users
        audioUrl = poi.previewAudioUrl;
        print('[DEBUG AUDIO] Using previewAudioUrl: $audioUrl');
      }

      if (audioUrl != null) {
        queue.add(MediaItem(
          id: audioUrl,
          album: 'Tour',
          title: kidsMode ? '${poi.titleRu} (Для детей)' : poi.titleRu,
          artist: 'Audiogid',
          artUri:
              poi.media.isNotEmpty ? Uri.tryParse(poi.media.first.url) : null,
          extras: {
            'poiId': poi.id,
            'tourId': tourId,
            'isPreview': !hasAccess && (audioUrl == poi.previewAudioUrl),
          },
        ));
      } else {
        print('[DEBUG AUDIO] No audio URL for POI: ${poi.titleRu}');
      }
    }

    print('[DEBUG AUDIO] Queue built: ${queue.length} items');

    if (queue.isEmpty) {
      print('[DEBUG AUDIO] Queue is empty, returning');
      return;
    }

    await _handler.stop();
    await _handler.updateQueue(queue);
    print('[DEBUG AUDIO] Queue updated, starting playback');

    // 3. Find correct start index
    if (initialIndex >= 0 && initialIndex < items.length) {
      final startPoiId = items[initialIndex].poi?.id;
      if (startPoiId != null) {
        final indexInQueue =
            queue.indexWhere((item) => item.extras?['poiId'] == startPoiId);

        if (indexInQueue != -1) {
          await _handler.skipToQueueItem(indexInQueue);
          print('[DEBUG AUDIO] Skipped to queue item: $indexInQueue');
        } else {
          await _handler.skipToQueueItem(0);
        }
      } else {
        await _handler.skipToQueueItem(0);
      }
    } else {
      await _handler.skipToQueueItem(0);
    }

    // Auto-play
    await _handler.play();
    print('[DEBUG AUDIO] Play started');
    
    // Apply saved playback speed
    final savedSpeed = settingsAsync.value?.getPlaybackSpeed() ?? 1.0;
    if (savedSpeed != 1.0 && _handler is AudiogidAudioHandler) {
      await (_handler as AudiogidAudioHandler).setSpeed(savedSpeed);
    }
  }

  Future<void> play() => _handler.play();
  Future<void> pause() => _handler.pause();
  Future<void> stop() => _handler.stop();
  Future<void> skipToNext() => _handler.skipToNext();
  Future<void> skipToPrevious() => _handler.skipToPrevious();
  Future<void> seek(Duration position) => _handler.seek(position);

  void _initAnalytics() {
    _handler.mediaItem.listen((item) {
      if (item != null && item.extras != null) {
        final poiId = item.extras!['poiId'];
        final isPreview = item.extras!['isPreview'] == true;

        if (poiId != null) {
          _ref.read(analyticsServiceProvider).logEvent('poi_played', {
            'poi_id': poiId,
            'is_preview': isPreview,
            'tour_id': item.extras!['tourId'],
          });
          _ref.read(analyticsServiceProvider).logAudioPlay(poiId, item.title);
        }
      }
    });

    _handler.playbackState.listen((state) {
      if (state.processingState == AudioProcessingState.completed) {
        final item = _handler.mediaItem.value;
        if (item != null && item.extras != null) {
          final poiId = item.extras!['poiId'];
          if (poiId != null) {
            _ref.read(analyticsServiceProvider).logEvent('poi_completed', {
              'poi_id': poiId,
              'duration': item.duration?.inSeconds,
              'tour_id': item.extras!['tourId'],
            });
          }
        }
      }
    });
  }
}

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService(
    ref.watch(audioHandlerProvider),
    ref,
  );
  service._initAnalytics();
  return service;
});
