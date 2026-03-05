import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/audio/providers.dart';
import 'package:mobile_flutter/design_system/tokens/colors.dart';
import 'package:mobile_flutter/design_system/tokens/radius.dart';
import 'package:mobile_flutter/design_system/tokens/motion.dart';
import 'package:mobile_flutter/design_system/styles/gradients.dart';
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

        final isPreview = mediaItem.extras?['isPreview'] == true;

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
                  HapticFeedback.lightImpact();
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

                        return ClipRRect(
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            backgroundColor: AppColors.bgPrimary,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.accentPrimary,
                            ),
                            minHeight: 2,
                          ),
                        );
                      },
                    ),
                    // Content
                    SizedBox(
                      height: 72,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            // Album art with Hero
                            Hero(
                              tag: 'player_art_${mediaItem.id}',
                              child: Material(
                                color: Colors.transparent,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: mediaItem.artUri != null
                                        ? CachedNetworkImage(
                                            imageUrl: mediaItem.artUri!.toString(),
                                            fit: BoxFit.cover,
                                            memCacheWidth: 200,
                                            placeholder: (_, __) => Container(
                                              color: AppColors.bgPrimary,
                                              child: const Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppColors.accentPrimary,
                                                ),
                                              ),
                                            ),
                                            errorWidget: (_, __, ___) => Container(
                                              color: AppColors.bgPrimary,
                                              child: const Icon(
                                                Icons.music_note,
                                                color: AppColors.accentPrimary,
                                                size: 32,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: AppColors.bgPrimary,
                                            child: const Icon(
                                              Icons.music_note,
                                              color: AppColors.accentPrimary,
                                              size: 32,
                                            ),
                                          ),
                                  ),
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Hero(
                                          tag: 'player_title_${mediaItem.id}',
                                          child: Material(
                                            color: Colors.transparent,
                                            child: Text(
                                              mediaItem.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (isPreview) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentPrimary
                                                .withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.xs),
                                          ),
                                          child: const Text(
                                            'Превью',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.accentPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (mediaItem.artist != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      mediaItem.artist!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                    padding: EdgeInsets.all(12.0),
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

                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      playing
                                          ? audioHandler.pause()
                                          : audioHandler.play();
                                    },
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                    child: Container(
                                      width: 44,
                                      height: 44,
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
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 4),
                            // Close button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  audioHandler.stop();
                                },
                                borderRadius: BorderRadius.circular(AppRadius.xs),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.close,
                                    color: AppColors.textTertiary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
