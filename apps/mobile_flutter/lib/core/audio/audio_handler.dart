import 'package:audio_session/audio_session.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

// Implementation of AudioHandler using just_audio
class AudiogidAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  AudiogidAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    // Handle interruptions
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _player.setVolume(0.5);
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            _player.pause();
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _player.setVolume(1.0);
            break;
          case AudioInterruptionType.pause:
            _player.play();
            break;
          case AudioInterruptionType.unknown:
            break;
        }
      }
    });

    session.becomingNoisyEventStream.listen((_) {
      _player.pause();
    });

    // Propagate playback state from just_audio to audio_service
    _player.playbackEventStream.listen(_broadcastState);
    // Determine when to skip to next
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  // Define play/pause/etc
  @override
  Future<void> play() async {
    if (_player.audioSource == null && queue.value.isNotEmpty) {
      // Fallback to first item if nothing loaded
      final item = queue.value.first;
      mediaItem.add(item);
      await _player.setAudioSource(AudioSource.uri(Uri.parse(item.id)));
    }
    await _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _skip(1);

  @override
  Future<void> skipToPrevious() => _skip(-1);

  Future<void> _skip(int offset) async {
    final currentItem = this.mediaItem.value;
    final currentQueue = this.queue.value;
    if (currentItem == null || currentQueue.isEmpty) return;

    final index = currentQueue.indexOf(currentItem);
    if (index == -1) return;

    final newIndex = index + offset;
    if (newIndex >= 0 && newIndex < currentQueue.length) {
      final nextItem = currentQueue[newIndex];
      // Update media item immediately for UI responsiveness
      this.mediaItem.add(nextItem);
      // Prepare and play
      try {
        await _player.setAudioSource(AudioSource.uri(Uri.parse(nextItem.id)));
        await _player.play();
      } catch (e) {
        // Handle error, maybe skip to next?
        print('Error playing audio: $e');
      }
    } else {
      // End of playlist
      await stop();
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    final item = queue.value[index];
    mediaItem.add(item);
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(item.id)));
      await _player.play();
    } catch (e) {
      print("Error playing item at index $index: $e");
    }
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    await super.updateQueue(queue);
    // If queue is updated and we are playing, make sure we sync?
    // For now simple.
  }

  // Custom method to start a specific track
  Future<void> playMediaItem(MediaItem item) async {
    this.mediaItem.add(item);
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(item.id)));
      await _player.play();
    } catch (e) {
      print('Error playing media item: $e');
    }
  }

  void _broadcastState(PlaybackEvent event) {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex:
          queue.value?.indexWhere((item) => item.id == mediaItem.value?.id),
    ));
  }
}
