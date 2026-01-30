import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/audio/providers.dart';
import 'package:flutter/services.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);

    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        if (mediaItem == null) return const SizedBox.shrink();

        return Dismissible(
          key: const Key('mini_player'),
          direction: DismissDirection.down,
          onDismissed: (_) {
            HapticFeedback.lightImpact();
            audioHandler.stop();
          },
          child: Material(
            elevation: 8,
            color: Theme.of(context).cardColor,
            child: InkWell(
              onTap: () {
                 context.push('/player');
              },
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    if (mediaItem.artUri != null)
                      AspectRatio(
                        aspectRatio: 1,
                        child: CachedNetworkImage(
                          imageUrl: mediaItem.artUri!.toString(),
                          fit: BoxFit.cover,
                          memCacheWidth: 200, // Small for mini player
                          errorWidget: (_, __, ___) => const Icon(Icons.music_note),
                        ),
                      )
                    else
                      const AspectRatio(
                        aspectRatio: 1,
                        child: Icon(Icons.music_note),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mediaItem.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          if (mediaItem.artist != null)
                            Text(
                              mediaItem.artist!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    StreamBuilder<PlaybackState>(
                      stream: audioHandler.playbackState,
                      builder: (context, snapshot) {
                        final playbackState = snapshot.data;
                        final processingState = playbackState?.processingState;
                        final playing = playbackState?.playing ?? false;
                        
                        if (processingState == AudioProcessingState.loading ||
                            processingState == AudioProcessingState.buffering) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: SizedBox(
                                width: 24, height: 24, child: CircularProgressIndicator()),
                          );
                        }

                        return IconButton(
                          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                          onPressed: () {
                             HapticFeedback.selectionClick();
                             playing ? audioHandler.pause() : audioHandler.play();
                          },
                        );
                      },
                    ),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                           HapticFeedback.selectionClick();
                           audioHandler.stop();
                        },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
