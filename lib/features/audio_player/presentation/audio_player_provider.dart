import 'package:assignment/utils/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../utils/logger_helper.dart';

enum AudioState { stopped, playing, paused, completed, error, loading }

class AudioPlayerProvider with ChangeNotifier {
  late PaletteGenerator _paletteGenerator;
  late AudioPlayer audioPlayer;
  Duration? _totalDuration = Duration.zero;
  Duration _position = Duration.zero;
  AudioState _audioState = AudioState.completed;
  bool _isLoading = false;
  String? _songName;
  String? _artistName;
  String? _songThumbnail;
  String? _artistDp;
  String? _songId;

  Color? _bgColor = Colors.black;

  AudioPlayerProvider() {
    audioPlayer = AudioPlayer();

    audioPlayer.onDurationChanged.listen((updatedDuration) {
      _totalDuration = updatedDuration;
      notifyListeners();
    });

    audioPlayer.onPositionChanged.listen((updatedPosition) {
      _position = updatedPosition;
      notifyListeners();
    });

    audioPlayer.onPlayerStateChanged.listen((playerState) {
      if (playerState == PlayerState.stopped) {
        _audioState = AudioState.stopped;
      } else if (playerState == PlayerState.playing) {
        _audioState = AudioState.playing;
      } else if (playerState == PlayerState.paused) {
        _audioState = AudioState.paused;
      }
      notifyListeners();
    });

    audioPlayer.onPlayerComplete.listen((event) {
      _audioState = AudioState.completed;
      notifyListeners();
    });
  }

  Duration? get totalDuration => _totalDuration;
  Duration get position => _position;
  AudioState get audioState => _audioState;
  bool get isLoading => _isLoading;
  String? get songName => _songName;
  String? get artistName => _artistName;
  String? get artistDp => _artistDp;
  String? get songThumnbail => _songThumbnail;
  String? get songId => _songId;
  Color? get bgColor => _bgColor;

  void playAgain() {
    audioPlayer.seek(Duration.zero);
  }

  Future<void> playAudio(
      {required String url,
      required String? songName,
      required String? songThumbnail,
      required String? artistDp,
      required String? songId,
      required String? artistName}) async {
    try {
      _songId = songId;
      _isLoading = true;
      _songName = songName;
      _artistName = artistName;
      _songThumbnail = songThumbnail;
      _artistDp = artistDp;

      _paletteGenerator = await PaletteGenerator.fromImageProvider(
        NetworkImage(songThumbnail!),
        size: const Size(200, 100), // Adjust size as needed for better accuracy
      );

      showToast(toastMsg: 'Playing $songName..');

      _bgColor = _paletteGenerator.dominantColor!.color;

      notifyListeners();

      await audioPlayer.play(UrlSource(url));
    } catch (error) {
      LoggerHelper.showErrorLog(text: 'Error playing audio: : $error');
      _audioState = AudioState.error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<Duration> getPositionStream() {
    return audioPlayer.onPositionChanged;
  }

  void pauseAudio() {
    if (audioState == AudioState.playing) {
      audioPlayer.pause();
      _audioState = AudioState.paused;
      notifyListeners();
    }
  }

  double getVolume() {
    return audioPlayer.volume;
  }

  void changeVolume(double volume) {
    audioPlayer.setVolume(volume);
  }

  void resumeAudio() {
    audioPlayer.resume();
    _audioState = AudioState.playing;
    notifyListeners();
  }

  void stopAudio() {
    audioPlayer.stop();
    _audioState = AudioState.stopped;
    notifyListeners();
  }

  void seekAudio(Duration durationToSeek) {
    audioPlayer.seek(durationToSeek);
  }

  void dispose() {
    audioPlayer.dispose();
  }
}
