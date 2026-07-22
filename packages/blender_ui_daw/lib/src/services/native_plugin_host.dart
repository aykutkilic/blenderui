import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'plugin_host.dart';

/// Method-channel adapter for an out-of-process or native VST3/AU/CLAP host.
///
/// The native side owns binary discovery, validation, process isolation, DSP,
/// and editor windows. This adapter deliberately exposes only serializable
/// control-plane data to Flutter.
class DawNativePluginHost extends ChangeNotifier implements DawPluginHost {
  DawNativePluginHost({
    MethodChannel channel = const MethodChannel(
      'blender_ui_daw/native_plugin_host',
    ),
  }) : _channel = channel {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  final MethodChannel _channel;
  List<DawPluginDescriptor> _catalog = const <DawPluginDescriptor>[];
  List<DawPluginInstance> _instances = const <DawPluginInstance>[];
  bool _scanning = false;

  @override
  List<DawPluginDescriptor> get catalog => _catalog;
  @override
  List<DawPluginInstance> get instances => _instances;
  @override
  bool get scanning => _scanning;

  @override
  Future<List<DawPluginDescriptor>> scan(List<String> searchPaths) async {
    _scanning = true;
    notifyListeners();
    try {
      final values = await _channel.invokeListMethod<Object?>(
        'scan',
        <String, Object?>{'searchPaths': searchPaths},
      );
      _catalog = List<DawPluginDescriptor>.unmodifiable(
        (values ?? const <Object?>[]).map(_descriptorFromValue),
      );
      return _catalog;
    } finally {
      _scanning = false;
      notifyListeners();
    }
  }

  @override
  Future<DawPluginInstance> instantiate(String pluginId) async {
    final value = await _channel.invokeMethod<Object?>(
      'instantiate',
      <String, Object?>{'pluginId': pluginId},
    );
    final instance = _instanceFromValue(value);
    _instances = List<DawPluginInstance>.unmodifiable(<DawPluginInstance>[
      ..._instances.where((item) => item.instanceId != instance.instanceId),
      instance,
    ]);
    notifyListeners();
    return instance;
  }

  @override
  Future<void> remove(String instanceId) async {
    await _channel.invokeMethod<void>('remove', <String, Object?>{
      'instanceId': instanceId,
    });
    _instances = List<DawPluginInstance>.unmodifiable(
      _instances.where((item) => item.instanceId != instanceId),
    );
    notifyListeners();
  }

  @override
  Future<void> setEnabled(String instanceId, bool enabled) async {
    await _channel.invokeMethod<void>('setEnabled', <String, Object?>{
      'instanceId': instanceId,
      'enabled': enabled,
    });
    _instances = List<DawPluginInstance>.unmodifiable(<DawPluginInstance>[
      for (final instance in _instances)
        if (instance.instanceId == instanceId)
          DawPluginInstance(
            instanceId: instance.instanceId,
            descriptor: instance.descriptor,
            parameters: instance.parameters,
            enabled: enabled,
          )
        else
          instance,
    ]);
    notifyListeners();
  }

  @override
  Future<void> setParameter(
    String instanceId,
    String parameterId,
    double value,
  ) async {
    await _channel.invokeMethod<void>('setParameter', <String, Object?>{
      'instanceId': instanceId,
      'parameterId': parameterId,
      'value': value.clamp(0, 1),
    });
  }

  @override
  Future<Uint8List> saveState(String instanceId) async =>
      await _channel.invokeMethod<Uint8List>('saveState', <String, Object?>{
        'instanceId': instanceId,
      }) ??
      Uint8List(0);

  @override
  Future<void> restoreState(String instanceId, Uint8List state) =>
      _channel.invokeMethod<void>('restoreState', <String, Object?>{
        'instanceId': instanceId,
        'state': state,
      });

  Future<void> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'catalogChanged':
        final values = _list(call.arguments);
        _catalog = List<DawPluginDescriptor>.unmodifiable(
          values.map(_descriptorFromValue),
        );
      case 'instanceChanged':
        final instance = _instanceFromValue(call.arguments);
        _instances = List<DawPluginInstance>.unmodifiable(<DawPluginInstance>[
          for (final item in _instances)
            if (item.instanceId != instance.instanceId) item,
          instance,
        ]);
      case 'scanStateChanged':
        _scanning = call.arguments == true;
      default:
        return;
    }
    notifyListeners();
  }

  DawPluginDescriptor _descriptorFromValue(Object? value) {
    final map = _map(value);
    return DawPluginDescriptor(
      id: _string(map, 'id'),
      name: _string(map, 'name'),
      vendor: _string(map, 'vendor'),
      format: _enum(DawPluginFormat.values, _string(map, 'format')),
      category: _enum(DawPluginCategory.values, _string(map, 'category')),
      path: _string(map, 'path'),
      audioInputs: _integer(map, 'audioInputs', fallback: 2),
      audioOutputs: _integer(map, 'audioOutputs', fallback: 2),
      midiInput: map['midiInput'] == true,
      midiOutput: map['midiOutput'] == true,
      loadable: map['loadable'] != false,
      unavailableReason: map['unavailableReason'] as String?,
    );
  }

  DawPluginInstance _instanceFromValue(Object? value) {
    final map = _map(value);
    return DawPluginInstance(
      instanceId: _string(map, 'instanceId'),
      descriptor: _descriptorFromValue(map['descriptor']),
      enabled: map['enabled'] != false,
      parameters: <DawPluginParameter>[
        for (final value in _list(map['parameters']))
          _parameterFromValue(value),
      ],
    );
  }

  DawPluginParameter _parameterFromValue(Object? value) {
    final map = _map(value);
    return DawPluginParameter(
      id: _string(map, 'id'),
      name: _string(map, 'name'),
      value: (map['value'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? '',
      automatable: map['automatable'] != false,
    );
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    super.dispose();
  }
}

Map<String, Object?> _map(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) return value.cast<String, Object?>();
  throw const FormatException('Native plug-in host returned a non-map value');
}

List<Object?> _list(Object? value) =>
    value is List ? value.cast<Object?>() : const <Object?>[];

String _string(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is String) return value;
  throw FormatException('Native plug-in host omitted $key');
}

int _integer(Map<String, Object?> map, String key, {required int fallback}) =>
    (map[key] as num?)?.toInt() ?? fallback;

T _enum<T extends Enum>(List<T> values, String name) =>
    values.firstWhere((value) => value.name == name);
