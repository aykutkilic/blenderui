import 'package:flutter/foundation.dart';

enum DawPluginFormat { vst3, audioUnit, clap, internal }

enum DawPluginCategory { instrument, effect, analyzer, utility }

const List<DawPluginDescriptor> dawBuiltinPluginCatalog = <DawPluginDescriptor>[
  DawPluginDescriptor(
    id: 'internal:auto-filter',
    name: 'Auto Filter',
    vendor: 'BlenderUI Audio',
    format: DawPluginFormat.internal,
    category: DawPluginCategory.effect,
    path: 'internal://auto-filter',
  ),
  DawPluginDescriptor(
    id: 'internal:eq-eight',
    name: 'EQ Eight',
    vendor: 'BlenderUI Audio',
    format: DawPluginFormat.internal,
    category: DawPluginCategory.effect,
    path: 'internal://eq-eight',
  ),
  DawPluginDescriptor(
    id: 'internal:compressor',
    name: 'Compressor',
    vendor: 'BlenderUI Audio',
    format: DawPluginFormat.internal,
    category: DawPluginCategory.effect,
    path: 'internal://compressor',
  ),
  DawPluginDescriptor(
    id: 'internal:dynamics-compressor',
    name: 'Dynamics Compressor',
    vendor: 'BlenderUI Audio',
    format: DawPluginFormat.internal,
    category: DawPluginCategory.effect,
    path: 'internal://dynamics-compressor',
  ),
  DawPluginDescriptor(
    id: 'internal:delay',
    name: 'Delay',
    vendor: 'BlenderUI Audio',
    format: DawPluginFormat.internal,
    category: DawPluginCategory.effect,
    path: 'internal://delay',
  ),
  DawPluginDescriptor(
    id: 'internal:reverb',
    name: 'Reverb',
    vendor: 'BlenderUI Audio',
    format: DawPluginFormat.internal,
    category: DawPluginCategory.effect,
    path: 'internal://reverb',
  ),
];

class DawPluginDescriptor {
  const DawPluginDescriptor({
    required this.id,
    required this.name,
    required this.vendor,
    required this.format,
    required this.category,
    required this.path,
    this.audioInputs = 2,
    this.audioOutputs = 2,
    this.midiInput = false,
    this.midiOutput = false,
    this.loadable = true,
    this.unavailableReason,
  });

  final String id;
  final String name;
  final String vendor;
  final DawPluginFormat format;
  final DawPluginCategory category;
  final String path;
  final int audioInputs;
  final int audioOutputs;
  final bool midiInput;
  final bool midiOutput;
  final bool loadable;
  final String? unavailableReason;
}

class DawPluginParameter {
  const DawPluginParameter({
    required this.id,
    required this.name,
    required this.value,
    this.unit = '',
    this.automatable = true,
  });

  final String id;
  final String name;
  final double value;
  final String unit;
  final bool automatable;
}

class DawPluginInstance {
  DawPluginInstance({
    required this.instanceId,
    required this.descriptor,
    List<DawPluginParameter> parameters = const <DawPluginParameter>[],
    this.enabled = true,
  }) : parameters = List<DawPluginParameter>.unmodifiable(parameters);

  final String instanceId;
  final DawPluginDescriptor descriptor;
  final List<DawPluginParameter> parameters;
  final bool enabled;
}

/// Host boundary for VST3 and other native plug-in formats.
///
/// The UI package never loads foreign machine code on Flutter's UI isolate.
/// Desktop hosts implement this contract using an isolated native audio engine
/// and expose scan/load/state operations to the Dart presentation layer.
abstract interface class DawPluginHost implements Listenable {
  List<DawPluginDescriptor> get catalog;
  List<DawPluginInstance> get instances;
  bool get scanning;

  Future<List<DawPluginDescriptor>> scan(List<String> searchPaths);
  Future<DawPluginInstance> instantiate(String pluginId);
  Future<void> remove(String instanceId);
  Future<void> setEnabled(String instanceId, bool enabled);
  Future<void> setParameter(
    String instanceId,
    String parameterId,
    double value,
  );
  Future<Uint8List> saveState(String instanceId);
  Future<void> restoreState(String instanceId, Uint8List state);
}

/// Deterministic host used by examples and tests. Production applications can
/// replace it with a native VST3 bridge without changing any editor widgets.
class DawInMemoryPluginHost extends ChangeNotifier implements DawPluginHost {
  DawInMemoryPluginHost({
    List<DawPluginDescriptor> catalog = dawBuiltinPluginCatalog,
  }) : _catalog = List<DawPluginDescriptor>.of(catalog);

  final List<DawPluginDescriptor> _catalog;
  final List<DawPluginInstance> _instances = <DawPluginInstance>[];
  bool _scanning = false;

  @override
  List<DawPluginDescriptor> get catalog => List.unmodifiable(_catalog);
  @override
  List<DawPluginInstance> get instances => List.unmodifiable(_instances);
  @override
  bool get scanning => _scanning;

  @override
  Future<List<DawPluginDescriptor>> scan(List<String> searchPaths) async {
    _scanning = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _scanning = false;
    notifyListeners();
    return catalog;
  }

  @override
  Future<DawPluginInstance> instantiate(String pluginId) async {
    final descriptor = _catalog.firstWhere((item) => item.id == pluginId);
    final instance = DawPluginInstance(
      instanceId: '$pluginId-${_instances.length + 1}',
      descriptor: descriptor,
      parameters: _parametersFor(descriptor.id),
    );
    _instances.add(instance);
    notifyListeners();
    return instance;
  }

  List<DawPluginParameter> _parametersFor(String id) => switch (id) {
    'internal:auto-filter' => const <DawPluginParameter>[
      DawPluginParameter(
        id: 'frequency',
        name: 'Frequency',
        value: .62,
        unit: 'Hz',
      ),
      DawPluginParameter(
        id: 'resonance',
        name: 'Resonance',
        value: .2,
        unit: 'Q',
      ),
    ],
    'internal:eq-eight' => <DawPluginParameter>[
      for (var band = 1; band <= 8; band++)
        DawPluginParameter(
          id: 'band-$band',
          name: 'Band $band',
          value: .5,
          unit: 'dB',
        ),
    ],
    'internal:compressor' ||
    'internal:dynamics-compressor' => const <DawPluginParameter>[
      DawPluginParameter(
        id: 'threshold',
        name: 'Threshold',
        value: .65,
        unit: 'dB',
      ),
      DawPluginParameter(id: 'ratio', name: 'Ratio', value: .35),
      DawPluginParameter(id: 'attack', name: 'Attack', value: .2, unit: 'ms'),
      DawPluginParameter(
        id: 'release',
        name: 'Release',
        value: .45,
        unit: 'ms',
      ),
    ],
    'internal:delay' => const <DawPluginParameter>[
      DawPluginParameter(id: 'time', name: 'Time', value: .35, unit: 'ms'),
      DawPluginParameter(
        id: 'feedback',
        name: 'Feedback',
        value: .3,
        unit: '%',
      ),
      DawPluginParameter(id: 'mix', name: 'Mix', value: .35, unit: '%'),
    ],
    'internal:reverb' => const <DawPluginParameter>[
      DawPluginParameter(id: 'size', name: 'Size', value: .55),
      DawPluginParameter(id: 'decay', name: 'Decay', value: .45, unit: 's'),
      DawPluginParameter(id: 'mix', name: 'Mix', value: .3, unit: '%'),
    ],
    _ => const <DawPluginParameter>[
      DawPluginParameter(id: 'mix', name: 'Mix', value: 1),
      DawPluginParameter(id: 'gain', name: 'Gain', value: .5, unit: 'dB'),
    ],
  };

  @override
  Future<void> remove(String instanceId) async {
    _instances.removeWhere((item) => item.instanceId == instanceId);
    notifyListeners();
  }

  @override
  Future<void> setEnabled(String instanceId, bool enabled) async {
    final index = _instances.indexWhere(
      (item) => item.instanceId == instanceId,
    );
    if (index < 0) return;
    final instance = _instances[index];
    _instances[index] = DawPluginInstance(
      instanceId: instance.instanceId,
      descriptor: instance.descriptor,
      parameters: instance.parameters,
      enabled: enabled,
    );
    notifyListeners();
  }

  @override
  Future<void> setParameter(
    String instanceId,
    String parameterId,
    double value,
  ) async {
    final index = _instances.indexWhere(
      (item) => item.instanceId == instanceId,
    );
    if (index < 0) return;
    final instance = _instances[index];
    _instances[index] = DawPluginInstance(
      instanceId: instance.instanceId,
      descriptor: instance.descriptor,
      enabled: instance.enabled,
      parameters: <DawPluginParameter>[
        for (final parameter in instance.parameters)
          if (parameter.id == parameterId)
            DawPluginParameter(
              id: parameter.id,
              name: parameter.name,
              value: value.clamp(0, 1).toDouble(),
              unit: parameter.unit,
              automatable: parameter.automatable,
            )
          else
            parameter,
      ],
    );
    notifyListeners();
  }

  @override
  Future<Uint8List> saveState(String instanceId) async => Uint8List(0);

  @override
  Future<void> restoreState(String instanceId, Uint8List state) async {}
}
