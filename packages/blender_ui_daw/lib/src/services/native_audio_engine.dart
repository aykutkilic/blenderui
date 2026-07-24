import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../model/project.dart';
import 'audio_engine.dart';
import 'project_codec.dart';

/// CoreAudio-facing control-plane adapter.
///
/// Native code owns device enumeration and the real-time engine. Dart retains
/// only serializable configuration and transport state.
class DawNativeAudioEngine extends ChangeNotifier implements DawAudioEngine {
  DawNativeAudioEngine({
    MethodChannel channel = const MethodChannel(
      'blender_ui_daw/native_audio_engine',
    ),
  }) : _channel = channel;

  final MethodChannel _channel;
  DawAudioEngineState _state = DawAudioEngineState.stopped;
  DawAudioEngineConfiguration? _configuration;
  final DawAudioMeterSnapshot _meters = DawAudioMeterSnapshot();
  double _renderProgress = 0;

  @override
  DawAudioEngineState get state => _state;
  @override
  DawAudioEngineConfiguration? get configuration => _configuration;
  @override
  DawAudioMeterSnapshot get meters => _meters;
  @override
  double get renderProgress => _renderProgress;

  @override
  Future<List<DawAudioDevice>> listDevices() async {
    final values = await _channel.invokeListMethod<Object?>('listDevices');
    return <DawAudioDevice>[
      for (final value in values ?? const <Object?>[])
        _deviceFromMap((value as Map).cast<String, Object?>()),
    ];
  }

  @override
  Future<void> start(DawAudioEngineConfiguration configuration) async {
    _state = DawAudioEngineState.starting;
    notifyListeners();
    try {
      await _channel.invokeMethod<void>('start', <String, Object?>{
        'deviceId': configuration.deviceId,
        'inputDeviceId': configuration.inputDeviceId,
        'sampleRate': configuration.sampleRate,
        'bufferFrames': configuration.bufferFrames,
      });
      _configuration = configuration;
      _state = DawAudioEngineState.running;
    } catch (_) {
      _state = DawAudioEngineState.failed;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<void> stop() async {
    await _channel.invokeMethod<void>('stop');
    _state = DawAudioEngineState.stopped;
    notifyListeners();
  }

  @override
  Future<void> synchronizeProject(DawProject project) =>
      _channel.invokeMethod<void>('synchronizeProject', <String, Object?>{
        // Keep this DTO versioned and complete. Native hosts must not infer a
        // graph from an identifier because that loses clips, routing, and FX.
        'project': const DawProjectCodec().encode(project),
      });

  @override
  Future<void> seek(double beat) =>
      _channel.invokeMethod<void>('seek', <String, Object?>{'beat': beat});

  @override
  Future<void> setPlaying(bool value) => _channel.invokeMethod<void>(
    'setPlaying',
    <String, Object?>{'playing': value},
  );

  @override
  Future<void> render(DawProject project, DawRenderRequest request) async {
    _state = DawAudioEngineState.rendering;
    _renderProgress = 0;
    notifyListeners();
    try {
      await _channel.invokeMethod<void>('render', <String, Object?>{
        'projectId': project.id,
        'outputPath': request.outputPath,
        'startBeat': request.startBeat,
        'endBeat': request.endBeat,
        'sampleRate': request.sampleRate,
        'bitDepth': request.bitDepth,
        'normalize': request.normalize,
      });
      _renderProgress = 1;
      _state = _configuration == null
          ? DawAudioEngineState.stopped
          : DawAudioEngineState.running;
    } catch (_) {
      _state = DawAudioEngineState.failed;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<void> cancelRender() async {
    await _channel.invokeMethod<void>('cancelRender');
    _renderProgress = 0;
    _state = _configuration == null
        ? DawAudioEngineState.stopped
        : DawAudioEngineState.running;
    notifyListeners();
  }

  DawAudioDevice _deviceFromMap(Map<String, Object?> map) => DawAudioDevice(
    id: map['id']! as String,
    name: map['name']! as String,
    inputChannels: (map['inputChannels'] as num?)?.toInt() ?? 0,
    outputChannels: (map['outputChannels'] as num?)?.toInt() ?? 0,
    defaultSampleRate: (map['defaultSampleRate'] as num?)?.toInt() ?? 48000,
  );
}
