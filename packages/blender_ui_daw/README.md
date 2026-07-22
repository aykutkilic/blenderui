# blender_ui_daw

Reusable digital-audio-workstation models, controllers, host boundaries, and
editor widgets built on `blender_ui`.

The package currently provides:

- switchable Blender-style editor areas for arrangement, piano-roll, waveform,
  automation, mixer, plug-ins, effect chains, and audio-routing graphs;
- immutable project, track, clip, note, and automation models;
- undoable trim/stretch, offset, loop, track-height, inline automation, and
  scale-aware MIDI editing with tempo-aware transport;
- audio-device discovery and engine reconfiguration controls;
- native CoreAudio and CoreMIDI catalog adapters;
- searchable, draggable plug-in browser and ordered device-chain widgets;
- compact engine-backed device meters and bypass controls;
- built-in Auto Filter, EQ Eight, Compressor, Dynamics Compressor, Delay, and
  Reverb descriptors with native macOS Audio Unit implementations; and
- a replaceable `DawPluginHost` boundary for VST3, Audio Unit, CLAP, or internal
  plug-in engines.

Native plug-in binaries must not be loaded on Flutter's UI isolate. Production
apps implement `DawPluginHost` with an isolated native audio engine. The
included `DawInMemoryPluginHost` supplies the same built-in catalog with
deterministic parameter models for examples, tests, and unsupported platforms.

On macOS, `DawNativePluginHost` can discover and instantiate Audio Units,
including instruments, effects, parameters, and state. The example runner also
discovers installed VST3 bundles, but intentionally marks them discovery-only:
executing VST3 requires an isolated host built against the Steinberg SDK.

```dart
final session = DawSessionController(initialProject: project);

DawArrangementEditor(session: session);
DawEffectChainEditor(
  session: session,
  host: pluginHost,
  audioEngine: audioEngine,
);
DawAudioGraphEditor(session: session, host: pluginHost);
```

See `../../examples/daw` for a complete multi-workspace composition.
