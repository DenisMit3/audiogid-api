import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/audio/providers.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
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
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.bgSecondary,
              border: Border(
                top: BorderSide(color: AppColors.glassBorder, width: 1),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  context.push('/player');
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress bar
                    StreamBuilder<Duration>(
                      stream: AudioService.position,
                      builder: (context, posSnapshot) {
                        final position = posSnapshot.data ?? Duration.zero;
                        final duration = mediaItem.duration ?? Duration.zero;
                        final progress = duration.inMilliseconds > 0
                            ? position.inMilliseconds / duration.inMilliseconds
                            : 0.0;

                        return LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: AppColors.bgPrimary,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accentPrimary,
                          ),
                          minHeight: 2,
                        );
                      },
                    ),
                    // Content
                    SizedBox(
                      height: 64,
                      child: Row(
                        children: [
                          // Album art
                          if (mediaItem.artUri != null)
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(0),
                              ),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: CachedNetworkImage(
                                  imageUrl: mediaItem.artUri!.toString(),
                                  fit: BoxFit.cover,
                                  memCacheWidth: 200,
                                  errorWidget: (_, __, ___) => Container(
                                    color: AppColors.bgPrimary,
                                    child: const Icon(
                                      Icons.music_note,
                                      color: AppColors.accentPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                color: AppColors.bgPrimary,
                                child: const Icon(
                                  Icons.music_note,
                                  color: AppColors.accentPrimary,
                                ),
                              ),
                            ),
                          const SizedBox(width: 12),
                          // Title and artist
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mediaItem.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (mediaItem.artist != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    mediaItem.artist!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Play/Pause button
                          StreamBuilder<PlaybackState>(
                            stream: audioHandler.playbackState,
                            builder: (context, snapshot) {
                              final playbackState = snapshot.data;
                              final processingState =
                                  playbackState?.processingState;
                              final playing = playbackState?.playing ?? false;

                              if (processingState ==
                                      AudioProcessingState.loading ||
                                  processingState ==
                                      AudioProcessingState.buffering) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.accentPrimary,
                                    ),
                                  ),
                                );
                              }

                              return IconButton(
                                icon: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: AppGradients.primaryButton,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Icon(
                                    playing ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  playing
                                      ? audioHandler.pause()
                                      : audioHandler.play();
                                },
                              );
                            },
                          ),
                          // Close button
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              audioHandler.stop();
                            },
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
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
