import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum DawMidiEndpointDirection { input, output }

class DawMidiEndpoint {
  const DawMidiEndpoint({
    required this.id,
    required this.name,
    required this.direction,
    this.manufacturer = '',
    this.model = '',
    this.online = true,
  });

  final String id;
  final String name;
  final DawMidiEndpointDirection direction;
  final String manufacturer;
  final String model;
  final bool online;
}

/// Observable CoreMIDI endpoint catalog used by Preferences and routing UIs.
class DawNativeMidiDeviceService extends ChangeNotifier {
  DawNativeMidiDeviceService({
    MethodChannel channel = const MethodChannel(
      'blender_ui_daw/native_midi_devices',
    ),
  }) : _channel = channel;

  final MethodChannel _channel;
  List<DawMidiEndpoint> _inputs = const <DawMidiEndpoint>[];
  List<DawMidiEndpoint> _outputs = const <DawMidiEndpoint>[];
  bool _scanning = false;
  Object? _error;

  List<DawMidiEndpoint> get inputs => _inputs;
  List<DawMidiEndpoint> get outputs => _outputs;
  bool get scanning => _scanning;
  Object? get error => _error;

  Future<void> refresh() async {
    _scanning = true;
    _error = null;
    notifyListeners();
    try {
      final values = await _channel.invokeListMethod<Object?>('listEndpoints');
      final endpoints = <DawMidiEndpoint>[
        for (final value in values ?? const <Object?>[])
          _fromMap((value as Map).cast<String, Object?>()),
      ];
      _inputs = List<DawMidiEndpoint>.unmodifiable(
        endpoints.where(
          (endpoint) => endpoint.direction == DawMidiEndpointDirection.input,
        ),
      );
      _outputs = List<DawMidiEndpoint>.unmodifiable(
        endpoints.where(
          (endpoint) => endpoint.direction == DawMidiEndpointDirection.output,
        ),
      );
    } catch (error) {
      _error = error;
    } finally {
      _scanning = false;
      notifyListeners();
    }
  }

  DawMidiEndpoint _fromMap(Map<String, Object?> map) => DawMidiEndpoint(
    id: map['id']! as String,
    name: map['name']! as String,
    direction: map['direction'] == 'output'
        ? DawMidiEndpointDirection.output
        : DawMidiEndpointDirection.input,
    manufacturer: map['manufacturer'] as String? ?? '',
    model: map['model'] as String? ?? '',
    online: map['online'] != false,
  );
}
