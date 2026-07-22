import 'package:blender_ui_daw/blender_ui_daw.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const project = DawProject(
    id: 'portable',
    name: 'Portable Project',
    lengthBeats: 64,
    sampleRate: 96000,
    tempoMap: <DawTempoPoint>[
      DawTempoPoint(beat: 0, bpm: 120),
      DawTempoPoint(beat: 32, bpm: 128),
    ],
    loopEnabled: true,
    loopStartBeat: 8,
    loopEndBeat: 24,
    tracks: <DawTrack>[
      DawTrack(
        id: 'audio',
        name: 'Audio',
        type: DawTrackType.audio,
        clips: <DawClip>[
          DawAudioClip(
            id: 'take',
            name: 'Take',
            startBeat: 4,
            lengthBeats: 8,
            sourcePath: 'Audio/take.wav',
            waveform: DawWaveform(peaks: <double>[.2, -.7, .4]),
            gain: .8,
          ),
        ],
        automation: <DawAutomationLane>[
          DawAutomationLane(
            id: 'volume',
            name: 'Volume',
            parameterId: 'track.volume',
            points: <DawAutomationPoint>[
              DawAutomationPoint(id: 'p1', beat: 0, value: .5),
            ],
          ),
        ],
        plugins: <DawPluginSlot>[
          DawPluginSlot(id: 'eq', pluginId: 'eq.vst3', name: 'EQ'),
        ],
      ),
    ],
    master: DawTrack(
      id: 'master',
      name: 'Master',
      type: DawTrackType.audio,
      plugins: <DawPluginSlot>[
        DawPluginSlot(id: 'limiter', pluginId: 'limiter', name: 'Limiter'),
      ],
    ),
  );

  test('project codec round-trips all portable state', () {
    const codec = DawProjectCodec();
    final decoded = codec.decode(codec.encode(project));

    expect(decoded.name, project.name);
    expect(decoded.sampleRate, 96000);
    expect(decoded.tempoAt(40), 128);
    expect(decoded.loopEnabled, isTrue);
    expect(decoded.master.plugins.single.name, 'Limiter');
    final track = decoded.tracks.single;
    expect(track.plugins.single.pluginId, 'eq.vst3');
    expect(track.automation.single.points.single.value, .5);
    final clip = track.clips.single as DawAudioClip;
    expect(clip.sourcePath, 'Audio/take.wav');
    expect(clip.waveform.peaks, <double>[.2, -.7, .4]);
  });

  test('persistence controller saves and loads through host storage', () async {
    final store = DawMemoryProjectStore();
    final persistence = DawProjectPersistenceController(store: store);
    addTearDown(persistence.dispose);

    await persistence.save(project, location: 'song.buidaw');
    expect(persistence.state, DawProjectPersistenceState.saved);
    expect(store.documents, contains('song.buidaw'));

    final loaded = await persistence.load('song.buidaw');
    expect(loaded.id, project.id);
    expect(persistence.state, DawProjectPersistenceState.idle);
  });

  test('audio engine exposes asynchronous control-plane state', () async {
    final engine = DawInMemoryAudioEngine();
    addTearDown(engine.dispose);
    final devices = await engine.listDevices();
    expect(devices, isNotEmpty);

    await engine.start(
      const DawAudioEngineConfiguration(deviceId: 'system-default'),
    );
    await engine.synchronizeProject(project);
    await engine.seek(12);
    await engine.setPlaying(true);

    expect(engine.state, DawAudioEngineState.running);
    expect(engine.project?.id, project.id);
    expect(engine.beat, 12);
    expect(engine.playing, isTrue);
  });

  test(
    'audio device controller discovers and reconfigures the engine',
    () async {
      final engine = DawInMemoryAudioEngine();
      final controller = DawAudioDeviceController(engine: engine);
      addTearDown(controller.dispose);
      addTearDown(engine.dispose);

      await controller.initialize(preferredSampleRate: 44100);
      expect(controller.devices.first.name, 'System Default');
      expect(controller.devices, hasLength(3));
      expect(controller.configuration?.sampleRate, 44100);

      await controller.setBufferFrames(128);
      expect(controller.configuration?.bufferFrames, 128);
      expect(engine.state, DawAudioEngineState.running);

      await controller.selectDevice('studio-interface');
      expect(controller.configuration?.deviceId, 'studio-interface');
      await controller.selectInputDevice('studio-interface');
      expect(controller.configuration?.inputDeviceId, 'studio-interface');
    },
  );

  test('native plug-in adapter decodes VST3 catalog and instances', () async {
    const channel = MethodChannel('test/native_plugin_host');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'scan') {
        return <Object?>[_pluginDescriptorJson];
      }
      if (call.method == 'instantiate') {
        return <String, Object?>{
          'instanceId': 'synth-1',
          'descriptor': _pluginDescriptorJson,
          'enabled': true,
          'parameters': <Object?>[
            <String, Object?>{
              'id': 'cutoff',
              'name': 'Cutoff',
              'value': .7,
              'automatable': true,
            },
          ],
        };
      }
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    final host = DawNativePluginHost(channel: channel);
    addTearDown(host.dispose);

    final catalog = await host.scan(const <String>['/VST3']);
    expect(catalog.single.format, DawPluginFormat.vst3);
    expect(catalog.single.loadable, isFalse);
    final instance = await host.instantiate('synth');
    expect(instance.parameters.single.name, 'Cutoff');
    expect(host.instances.single.instanceId, 'synth-1');
  });

  test(
    'native audio adapter decodes devices and forwards configuration',
    () async {
      const channel = MethodChannel('test/native_audio_engine');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      MethodCall? startCall;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'listDevices') {
          return <Object?>[
            <String, Object?>{
              'id': 'coreaudio:usb',
              'name': 'USB Interface',
              'inputChannels': 4,
              'outputChannels': 6,
              'defaultSampleRate': 96000,
            },
          ];
        }
        if (call.method == 'start') startCall = call;
        return null;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      final engine = DawNativeAudioEngine(channel: channel);
      addTearDown(engine.dispose);

      final devices = await engine.listDevices();
      expect(devices.single.outputChannels, 6);
      await engine.start(
        const DawAudioEngineConfiguration(
          deviceId: 'coreaudio:usb',
          inputDeviceId: 'coreaudio:usb',
          sampleRate: 96000,
          bufferFrames: 128,
        ),
      );
      expect(startCall?.method, 'start');
      expect(
        (startCall?.arguments as Map<Object?, Object?>)['inputDeviceId'],
        'coreaudio:usb',
      );
      expect(engine.state, DawAudioEngineState.running);
    },
  );

  test(
    'native MIDI catalog separates CoreMIDI sources and destinations',
    () async {
      const channel = MethodChannel('test/native_midi_devices');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        channel,
        (call) async => <Object?>[
          <String, Object?>{
            'id': '1',
            'name': 'Keyboard',
            'direction': 'input',
            'manufacturer': 'Controller Co',
          },
          <String, Object?>{
            'id': '2',
            'name': 'External Synth',
            'direction': 'output',
          },
        ],
      );
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      final devices = DawNativeMidiDeviceService(channel: channel);
      addTearDown(devices.dispose);

      await devices.refresh();
      expect(devices.inputs.single.name, 'Keyboard');
      expect(devices.outputs.single.name, 'External Synth');
      expect(devices.error, isNull);
    },
  );
}

const Map<String, Object?> _pluginDescriptorJson = <String, Object?>{
  'id': 'synth',
  'name': 'Synth',
  'vendor': 'Example Audio',
  'format': 'vst3',
  'category': 'instrument',
  'path': '/VST3/Synth.vst3',
  'audioInputs': 0,
  'audioOutputs': 2,
  'midiInput': true,
  'midiOutput': false,
  'loadable': false,
  'unavailableReason': 'Discovery only',
};
