import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/core/audio/providers.dart';
import 'package:mobile_flutter/core/audio/audio_handler.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
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
                  return Column(
                    children: [
                      // Main controls row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous, size: 40),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              audioHandler.skipToPrevious();
                            },
                            tooltip: 'Предыдущий',
                          ),
                          const SizedBox(width: 8),
                          // Rewind 15 seconds
                          IconButton(
                            icon: const Icon(Icons.replay_10, size: 36),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              final current = state?.position ?? Duration.zero;
                              final newPos = current - const Duration(seconds: 15);
                              audioHandler.seek(newPos < Duration.zero ? Duration.zero : newPos);
                            },
                            tooltip: '-15 сек',
                          ),
                          const SizedBox(width: 8),
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
                          const SizedBox(width: 8),
                          // Forward 15 seconds
                          IconButton(
                            icon: const Icon(Icons.forward_10, size: 36),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              final current = state?.position ?? Duration.zero;
                              audioHandler.seek(current + const Duration(seconds: 15));
                            },
                            tooltip: '+15 сек',
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.skip_next, size: 40),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              audioHandler.skipToNext();
                            },
                            tooltip: 'Следующий',
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Speed and Sleep Timer row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SpeedControlButton(audioHandler: audioHandler as AudiogidAudioHandler, ref: ref),
                  const SizedBox(width: 16),
                  _SleepTimerButton(audioHandler: audioHandler),
                ],
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
                  ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                  : const SizedBox(width: 24),
              title: Text('${speed}x'),
              subtitle: _getSpeedLabel(speed),
              onTap: () async {
                HapticFeedback.selectionClick();
                await audioHandler.setSpeed(speed);
                // Save to settings
                final settings = await ref.read(settingsRepositoryProvider.future);
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
              ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
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
              leading: (_remainingMinutes != null && minutes > 0 && 
                       (minutes == _timerOptions.firstWhere((m) => m >= (_remainingMinutes ?? 0), orElse: () => 0)))
                  ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                  : (minutes == 0 && _remainingMinutes == null)
                      ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
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
