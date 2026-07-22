import 'package:flutter/foundation.dart';

import '../services/audio_engine.dart';

/// Owns audio-device discovery and safe engine reconfiguration.
///
/// Applications can place the same controller in Preferences, status bars, or
/// setup flows without coupling those surfaces to a particular audio backend.
class DawAudioDeviceController extends ChangeNotifier {
  DawAudioDeviceController({required this.engine});

  final DawAudioEngine engine;
  List<DawAudioDevice> _devices = const <DawAudioDevice>[];
  bool _busy = false;
  Object? _error;

  List<DawAudioDevice> get devices => _devices;
  bool get busy => _busy;
  Object? get error => _error;
  DawAudioEngineConfiguration? get configuration => engine.configuration;

  Future<void> initialize({int preferredSampleRate = 48000}) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      _devices = await engine.listDevices();
      if (_devices.isNotEmpty) {
        final device = _devices.firstWhere(
          (candidate) => candidate.outputChannels > 0,
          orElse: () => _devices.first,
        );
        await engine.start(
          DawAudioEngineConfiguration(
            deviceId: device.id,
            sampleRate: preferredSampleRate,
          ),
        );
      }
    } catch (error) {
      _error = error;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> selectDevice(String deviceId) =>
      _reconfigure(deviceId: deviceId);

  Future<void> selectInputDevice(String deviceId) =>
      _reconfigure(inputDeviceId: deviceId);

  Future<void> setSampleRate(int sampleRate) =>
      _reconfigure(sampleRate: sampleRate);

  Future<void> setBufferFrames(int bufferFrames) =>
      _reconfigure(bufferFrames: bufferFrames);

  Future<void> refreshDevices() async {
    _busy = true;
    notifyListeners();
    try {
      _devices = await engine.listDevices();
      _error = null;
    } catch (error) {
      _error = error;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> _reconfigure({
    String? deviceId,
    String? inputDeviceId,
    int? sampleRate,
    int? bufferFrames,
  }) async {
    final current = configuration;
    final fallbackDevice = _devices.isEmpty ? null : _devices.first.id;
    final nextDevice = deviceId ?? current?.deviceId ?? fallbackDevice;
    if (nextDevice == null) return;
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      if (engine.state != DawAudioEngineState.stopped) await engine.stop();
      await engine.start(
        DawAudioEngineConfiguration(
          deviceId: nextDevice,
          inputDeviceId: inputDeviceId ?? current?.inputDeviceId,
          sampleRate: sampleRate ?? current?.sampleRate ?? 48000,
          bufferFrames: bufferFrames ?? current?.bufferFrames ?? 256,
        ),
      );
    } catch (error) {
      _error = error;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
