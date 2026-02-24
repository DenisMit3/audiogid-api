import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/core/audio/providers.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/services.dart';

class AudioPlayerScreen extends ConsumerWidget {
  const AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<MediaItem?>(
        stream: audioHandler.mediaItem,
        builder: (context, snapshot) {
          final mediaItem = snapshot.data;
          if (mediaItem == null)
            return const Center(child: Text("Nothing playing"));

          return Column(
            children: [
              // Cover Art
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: mediaItem.artUri != null
                        ? CachedNetworkImage(
                            imageUrl: mediaItem.artUri!.toString(),
                            fit: BoxFit.contain,
                            placeholder: (context, url) =>
                                const Icon(Icons.music_note, size: 120),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.music_note, size: 120),
                          )
                        : const Icon(Icons.music_note, size: 120),
                  ),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Text(mediaItem.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(mediaItem.artist ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Progress Bar
              StreamBuilder<Duration>(
                stream: Stream.periodic(const Duration(milliseconds: 200),
                    (_) => _currentPosition(audioHandler)),
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final total = mediaItem.duration ?? Duration.zero;

                  // We need duration from somewhere. mediaItem.duration might be null if not set.
                  // just_audio updates mediaItem duration usually.
                  // Or we rely on playbackState.bufferedPosition?

                  return Column(
                    children: [
                      Slider(
                        value: position.inMilliseconds.toDouble().clamp(
                            0,
                            (total.inMilliseconds > 0
                                ? total.inMilliseconds.toDouble()
                                : position.inMilliseconds.toDouble() + 1000)),
                        max: (total.inMilliseconds > 0
                            ? total.inMilliseconds.toDouble()
                            : position.inMilliseconds.toDouble() + 1000),
                        onChangeStart: (_) => HapticFeedback.selectionClick(),
                        onChanged: (value) {
                          audioHandler
                              .seek(Duration(milliseconds: value.toInt()));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(position)),
                            Text(_formatDuration(total)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Controls
              StreamBuilder<PlaybackState>(
                stream: audioHandler.playbackState,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final playing = state?.playing ?? false;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous, size: 48),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          audioHandler.skipToPrevious();
                        },
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        icon: Icon(
                            playing
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            size: 64),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          playing ? audioHandler.pause() : audioHandler.play();
                        },
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        icon: const Icon(Icons.skip_next, size: 48),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          audioHandler.skipToNext();
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),
            ],
          );
        },
      ),
    );
  }

  Duration _currentPosition(AudioHandler handler) {
    final state = handler.playbackState.value;
    if (state == null) return Duration.zero;
    if (!state.playing) return state.position;

    final loops = DateTime.now().difference(state.updateTime).inMilliseconds;
    // simple extrapolation
    return state.position +
        Duration(milliseconds: (loops * state.speed).toInt());
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
