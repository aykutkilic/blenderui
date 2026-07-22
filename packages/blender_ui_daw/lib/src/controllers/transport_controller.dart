import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/audio_engine.dart';
import 'session_controller.dart';

/// Tempo-aware transport that advances BlenderUI's shared playback state and
/// mirrors play/seek commands to an optional real-time audio engine.
class DawTransportController extends ChangeNotifier {
  DawTransportController({
    required this.session,
    this.audioEngine,
    this.tickRate = const Duration(milliseconds: 16),
  });

  final DawSessionController session;
  final DawAudioEngine? audioEngine;
  final Duration tickRate;
  Timer? _timer;
  DateTime? _lastTick;

  bool get playing => session.playback.playing;
  bool get recording => session.playback.recording;

  void togglePlay() => playing ? stop() : play();

  void play() {
    if (playing) return;
    session.playback.setPlaying(true);
    unawaited(audioEngine?.setPlaying(true));
    _lastTick = DateTime.now();
    _timer = Timer.periodic(tickRate, (_) => _tick());
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _lastTick = null;
    session.playback.setPlaying(false);
    unawaited(audioEngine?.setPlaying(false));
    notifyListeners();
  }

  void toggleRecord() {
    session.playback.toggleRecording();
    notifyListeners();
  }

  void _tick() {
    final now = DateTime.now();
    final last = _lastTick ?? now;
    _lastTick = now;
    final seconds =
        now.difference(last).inMicroseconds / Duration.microsecondsPerSecond;
    final project = session.project;
    final beat = session.playback.currentFrame;
    var next = beat + seconds * project.tempoAt(beat) / 60;
    if (project.loopEnabled && next >= project.loopEndBeat) {
      next = project.loopStartBeat + (next - project.loopEndBeat);
    } else if (next >= project.lengthBeats) {
      session.playback.seek(project.lengthBeats);
      stop();
      return;
    }
    session.playback.seek(next);
    unawaited(audioEngine?.seek(next));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
