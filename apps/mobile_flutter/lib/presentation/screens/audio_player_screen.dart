import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:mobile_flutter/core/audio/audio_handler.dart';
import 'package:mobile_flutter/core/audio/providers.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:mobile_flutter/design_system/styles/gradients.dart';
import 'package:mobile_flutter/design_system/tokens/colors.dart';
import 'package:mobile_flutter/design_system/tokens/motion.dart';
import 'package:mobile_flutter/design_system/tokens/radius.dart';
import 'package:mobile_flutter/design_system/tokens/spacing.dart';

class AudioPlayerScreen extends ConsumerWidget {
  const AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: StreamBuilder<MediaItem?>(
          stream: audioHandler.mediaItem,
          builder: (context, snapshot) {
            final mediaItem = snapshot.data;
            if (mediaItem == null) {
              return const Center(
                child: Text(
                  'Сейчас ничего не играет',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            final isPreview = mediaItem.extras?['isPreview'] == true;

            return Column(
              children: [
                // Drag handle + close
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.glassBorder,
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Свернуть плеер',
                      ),
                    ],
                  ),
                ),

                // Cover + gradient background
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Hero(
                      tag: 'player_art_${mediaItem.id}',
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppRadius.card),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 32,
                              offset: Offset(0, 16),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppRadius.card),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (mediaItem.artUri != null)
                                CachedNetworkImage(
                                  imageUrl: mediaItem.artUri!.toString(),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: AppColors.bgSecondary,
                                    child: const Icon(
                                      Icons.music_note,
                                      color: AppColors.accentPrimary,
                                      size: 72,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: AppColors.bgSecondary,
                                    child: const Icon(
                                      Icons.music_note,
                                      color: AppColors.accentPrimary,
                                      size: 72,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  color: AppColors.bgSecondary,
                                  child: const Icon(
                                    Icons.music_note,
                                    color: AppColors.accentPrimary,
                                    size: 72,
                                  ),
                                ),
                              // Bottom gradient overlay for text legibility
                              Container(
                                decoration:
                                    AppGradients.imageOverlay.createShader(
                                  const Rect.fromLTWH(0, 0, 0, 0),
                                ) is Shader
                                    ? null
                                    : BoxDecoration(
                                        gradient: AppGradients.imageOverlay,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom sheet-style controls
                _PlayerBottomSheet(
                  mediaItem: mediaItem,
                  audioHandler: audioHandler,
                  ref: ref,
                ),
              ],
            );
          },
        ),
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

class _PlayerBottomSheet extends ConsumerWidget {
  final MediaItem mediaItem;
  final AudioHandler audioHandler;
  final WidgetRef ref;

  const _PlayerBottomSheet({
    required this.mediaItem,
    required this.audioHandler,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.bottomSheet),
        ),
        border: const Border(
          top: BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: AppSpacing.lg + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title & subtitle
          Hero(
            tag: 'player_title_${mediaItem.id}',
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  Text(
                    mediaItem.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    alignment: WrapAlignment.center,
                    children: [
                      if (mediaItem.extras?['isPreview'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentPrimary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.preview_outlined,
                                size: 14,
                                color: AppColors.accentPrimary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Превью',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (mediaItem.title.contains('(Для детей)'))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.child_care,
                                size: 14,
                                color: AppColors.warning,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Детская версия',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (mediaItem.artist != null && mediaItem.artist!.isNotEmpty)
            Text(
              mediaItem.artist!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),

          const SizedBox(height: AppSpacing.lg),

          // Progress bar + time
          StreamBuilder<Duration>(
            stream: Stream.periodic(
              const Duration(milliseconds: 200),
              (_) => _currentPosition(audioHandler),
            ),
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final total = mediaItem.duration ?? Duration.zero;

              final max = total.inMilliseconds > 0
                  ? total.inMilliseconds.toDouble()
                  : (position.inMilliseconds.toDouble() + 1000);

              final value = position.inMilliseconds
                  .toDouble()
                  .clamp(0, max);

              return Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 8),
                    ),
                    child: Slider(
                      value: value,
                      max: max,
                      onChangeStart: (_) =>
                          HapticFeedback.selectionClick(),
                      onChanged: (v) {
                        audioHandler.seek(
                          Duration(milliseconds: v.toInt()),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        Text(
                          _formatDuration(total),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // Main controls row
          StreamBuilder<PlaybackState>(
            stream: audioHandler.playbackState,
            builder: (context, snapshot) {
              final state = snapshot.data;
              final playing = state?.playing ?? false;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded, size: 32),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      audioHandler.skipToPrevious();
                    },
                    tooltip: 'Предыдущая точка',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: const Icon(Icons.replay_10_rounded, size: 28),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      final current = state?.position ?? Duration.zero;
                      final newPos =
                          current - const Duration(seconds: 15);
                      audioHandler.seek(
                        newPos < Duration.zero ? Duration.zero : newPos,
                      );
                    },
                    tooltip: '-15 сек',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  TweenAnimationBuilder<double>(
                    duration: AppDurations.fast,
                    tween: Tween<double>(begin: 0.9, end: 1.0),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        playing
                            ? audioHandler.pause()
                            : audioHandler.play();
                      },
                      borderRadius:
                          BorderRadius.circular(AppRadius.fab),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: AppGradients.primaryButton,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: const Icon(Icons.forward_10_rounded, size: 28),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      final current = state?.position ?? Duration.zero;
                      audioHandler.seek(
                        current + const Duration(seconds: 15),
                      );
                    },
                    tooltip: '+15 сек',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded, size: 32),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      audioHandler.skipToNext();
                    },
                    tooltip: 'Следующая точка',
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Speed & sleep timer row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SpeedControlButton(
                audioHandler: audioHandler as AudiogidAudioHandler,
                ref: ref,
              ),
              const SizedBox(width: AppSpacing.md),
              _SleepTimerButton(audioHandler: audioHandler),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpeedControlButton extends StatelessWidget {
  final AudiogidAudioHandler audioHandler;
  final WidgetRef ref;

  const _SpeedControlButton({
    required this.audioHandler,
    required this.ref,
  });

  static const List<double> _speeds = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: audioHandler.speedStream,
      initialData: audioHandler.speed,
      builder: (context, snapshot) {
        final currentSpeed = snapshot.data ?? 1.0;

        return Semantics(
          label: 'Скорость воспроизведения ${currentSpeed}x',
          button: true,
          child: OutlinedButton(
            onPressed: () => _showSpeedPicker(context, currentSpeed),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.speed, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${currentSpeed}x',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSpeedPicker(BuildContext context, double currentSpeed) {
    HapticFeedback.selectionClick();

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Скорость воспроизведения',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ..._speeds.map((speed) => ListTile(
                  leading: speed == currentSpeed
                      ? Icon(Icons.check,
                          color: Theme.of(ctx).colorScheme.primary)
                      : const SizedBox(width: 24),
                  title: Text('${speed}x'),
                  subtitle: _getSpeedLabel(speed),
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    await audioHandler.setSpeed(speed);
                    // Save to settings
                    final settings =
                        await ref.read(settingsRepositoryProvider.future);
                    await settings.setPlaybackSpeed(speed);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget? _getSpeedLabel(double speed) {
    switch (speed) {
      case 0.75:
        return const Text('Медленнее', style: TextStyle(color: Colors.grey));
      case 1.0:
        return const Text('Обычная', style: TextStyle(color: Colors.grey));
      case 1.25:
        return const Text('Чуть быстрее', style: TextStyle(color: Colors.grey));
      case 1.5:
        return const Text('Быстрее', style: TextStyle(color: Colors.grey));
      case 2.0:
        return const Text('Очень быстро', style: TextStyle(color: Colors.grey));
      default:
        return null;
    }
  }
}

class _SleepTimerButton extends StatefulWidget {
  final AudioHandler audioHandler;

  const _SleepTimerButton({required this.audioHandler});

  @override
  State<_SleepTimerButton> createState() => _SleepTimerButtonState();
}

class _SleepTimerButtonState extends State<_SleepTimerButton> {
  static const List<int> _timerOptions = [0, 5, 10, 15, 30, 45, 60]; // minutes

  int? _remainingMinutes;
  DateTime? _timerEndTime;

  @override
  void dispose() {
    super.dispose();
  }

  void _startTimer(int minutes) {
    if (minutes == 0) {
      setState(() {
        _remainingMinutes = null;
        _timerEndTime = null;
      });
      return;
    }

    setState(() {
      _remainingMinutes = minutes;
      _timerEndTime = DateTime.now().add(Duration(minutes: minutes));
    });

    _scheduleStop();
  }

  void _scheduleStop() {
    if (_timerEndTime == null) return;

    final remaining = _timerEndTime!.difference(DateTime.now());
    if (remaining.isNegative) {
      widget.audioHandler.pause();
      setState(() {
        _remainingMinutes = null;
        _timerEndTime = null;
      });
      return;
    }

    Future.delayed(const Duration(seconds: 30), () {
      if (!mounted) return;
      if (_timerEndTime == null) return;

      final now = DateTime.now();
      if (now.isAfter(_timerEndTime!)) {
        widget.audioHandler.pause();
        setState(() {
          _remainingMinutes = null;
          _timerEndTime = null;
        });
      } else {
        setState(() {
          _remainingMinutes = _timerEndTime!.difference(now).inMinutes + 1;
        });
        _scheduleStop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _remainingMinutes != null;

    return Semantics(
      label: isActive
          ? 'Таймер сна: $_remainingMinutes мин'
          : 'Таймер сна выключен',
      button: true,
      child: OutlinedButton(
        onPressed: () => _showTimerPicker(context),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          side: isActive
              ? BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.bedtime : Icons.bedtime_outlined,
              size: 20,
              color: isActive ? Theme.of(context).colorScheme.primary : null,
            ),
            const SizedBox(width: 8),
            Text(
              isActive ? '$_remainingMinutes мин' : 'Сон',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isActive ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimerPicker(BuildContext context) {
    HapticFeedback.selectionClick();

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Таймер сна',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Воспроизведение остановится через выбранное время',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            ..._timerOptions.map((minutes) => ListTile(
                  leading: (_remainingMinutes != null &&
                          minutes > 0 &&
                          (minutes ==
                              _timerOptions.firstWhere(
                                  (m) => m >= (_remainingMinutes ?? 0),
                                  orElse: () => 0)))
                      ? Icon(Icons.check,
                          color: Theme.of(ctx).colorScheme.primary)
                      : (minutes == 0 && _remainingMinutes == null)
                          ? Icon(Icons.check,
                              color: Theme.of(ctx).colorScheme.primary)
                          : const SizedBox(width: 24),
                  title: Text(minutes == 0 ? 'Выключить' : '$minutes мин'),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _startTimer(minutes);
                    Navigator.pop(ctx);
                    if (minutes > 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Таймер сна: $minutes мин'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
