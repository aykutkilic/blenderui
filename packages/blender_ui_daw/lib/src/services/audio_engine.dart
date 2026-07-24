import 'dart:async';

import 'package:flutter/foundation.dart';

import '../model/project.dart';

enum DawAudioEngineState { stopped, starting, running, rendering, failed }

class DawAudioDevice {
  const DawAudioDevice({
    required this.id,
    required this.name,
    this.inputChannels = 0,
    this.outputChannels = 2,
    this.defaultSampleRate = 48000,
  });

  final String id;
  final String name;
  final int inputChannels;
  final int outputChannels;
  final int defaultSampleRate;
}

class DawAudioEngineConfiguration {
  const DawAudioEngineConfiguration({
    required this.deviceId,
    this.inputDeviceId,
    this.sampleRate = 48000,
    this.bufferFrames = 256,
  });

  final String deviceId;
  final String? inputDeviceId;
  final int sampleRate;
  final int bufferFrames;
}

class DawAudioMeterSnapshot {
  DawAudioMeterSnapshot({
    Map<String, double> trackPeaks = const <String, double>{},
    Map<String, double> devicePeaks = const <String, double>{},
    this.masterPeak = 0,
    this.cpuLoad = 0,
    this.xrunCount = 0,
  }) : trackPeaks = Map<String, double>.unmodifiable(trackPeaks),
       devicePeaks = Map<String, double>.unmodifiable(devicePeaks);

  final Map<String, double> trackPeaks;
  final Map<String, double> devicePeaks;
  final double masterPeak;
  final double cpuLoad;
  final int xrunCount;
}

class DawRenderRequest {
  const DawRenderRequest({
    required this.outputPath,
    required this.startBeat,
    required this.endBeat,
    this.sampleRate = 48000,
    this.bitDepth = 24,
    this.normalize = false,
  });

  final String outputPath;
  final double startBeat;
  final double endBeat;
  final int sampleRate;
  final int bitDepth;
  final bool normalize;
}

/// Real-time audio engine boundary used by DAW controllers and meters.
///
/// A production implementation owns its callback thread, DSP graph, media
/// decoding, and plug-in processing outside Flutter's UI isolate. All methods
/// here are control-plane operations and must never be called from an audio
/// callback.
abstract interface class DawAudioEngine implements Listenable {
  DawAudioEngineState get state;
  DawAudioEngineConfiguration? get configuration;
  DawAudioMeterSnapshot get meters;
  double get renderProgress;

  Future<List<DawAudioDevice>> listDevices();
  Future<void> start(DawAudioEngineConfiguration configuration);
  Future<void> stop();
  Future<void> synchronizeProject(DawProject project);
  Future<void> seek(double beat);
  Future<void> setPlaying(bool value);
  Future<void> render(DawProject project, DawRenderRequest request);
  Future<void> cancelRender();
}

/// Predictable control-plane engine used by the example and tests.
class DawInMemoryAudioEngine extends ChangeNotifier implements DawAudioEngine {
  DawAudioEngineState _state = DawAudioEngineState.stopped;
  DawAudioEngineConfiguration? _configuration;
  DawAudioMeterSnapshot _meters = DawAudioMeterSnapshot();
  double _renderProgress = 0;
  Timer? _renderTimer;
  bool _playing = false;
  double _beat = 0;
  DawProject? _project;

  @override
  DawAudioEngineState get state => _state;
  @override
  DawAudioEngineConfiguration? get configuration => _configuration;
  @override
  DawAudioMeterSnapshot get meters => _meters;
  @override
  double get renderProgress => _renderProgress;
  bool get playing => _playing;
  double get beat => _beat;
  DawProject? get project => _project;

  @override
  Future<List<DawAudioDevice>> listDevices() async => const <DawAudioDevice>[
    DawAudioDevice(
      id: 'system-default',
      name: 'System Default',
      inputChannels: 2,
    ),
    DawAudioDevice(
      id: 'built-in-output',
      name: 'Built-in Output',
      outputChannels: 2,
    ),
    DawAudioDevice(
      id: 'studio-interface',
      name: 'Studio USB Interface',
      inputChannels: 8,
      outputChannels: 8,
      defaultSampleRate: 96000,
    ),
  ];

  @override
  Future<void> start(DawAudioEngineConfiguration configuration) async {
    _state = DawAudioEngineState.starting;
    notifyListeners();
    _configuration = configuration;
    _state = DawAudioEngineState.running;
    notifyListeners();
  }

  @override
  Future<void> stop() async {
    _playing = false;
    _state = DawAudioEngineState.stopped;
    notifyListeners();
  }

  @override
  Future<void> synchronizeProject(DawProject project) async {
    _project = project;
    notifyListeners();
  }

  @override
  Future<void> seek(double beat) async {
    _beat = beat.clamp(0, _project?.lengthBeats ?? double.infinity).toDouble();
  }

  @override
  Future<void> setPlaying(bool value) async {
    _playing = value;
    notifyListeners();
  }

  @override
  Future<void> render(DawProject project, DawRenderRequest request) async {
    if (_state == DawAudioEngineState.rendering) return;
    _project = project;
    _renderProgress = 0;
    _state = DawAudioEngineState.rendering;
    notifyListeners();
    final duration = (request.endBeat - request.startBeat).abs();
    final step = (1 / (duration * 2).clamp(4, 100)).toDouble();
    _renderTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      _renderProgress = (_renderProgress + step).clamp(0, 1).toDouble();
      if (_renderProgress >= 1) {
        timer.cancel();
        _renderTimer = null;
        _state = _configuration == null
            ? DawAudioEngineState.stopped
            : DawAudioEngineState.running;
      }
      notifyListeners();
    });
  }

  @override
  Future<void> cancelRender() async {
    _renderTimer?.cancel();
    _renderTimer = null;
    _renderProgress = 0;
    _state = _configuration == null
        ? DawAudioEngineState.stopped
        : DawAudioEngineState.running;
    notifyListeners();
  }

  void updateMeters(DawAudioMeterSnapshot value) {
    _meters = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _renderTimer?.cancel();
    super.dispose();
  }
}
