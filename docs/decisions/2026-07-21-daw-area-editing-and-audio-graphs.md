# DAW editor areas, destructive editing, and audio graphs

Date: 2026-07-21

## Context

The first DAW composition placed fixed widgets in dock areas. That used the
docking layout but missed Blender's more important rule: every area owns an
editor type that the user can change from its header. Audio editing also needs
track-height and time-scale control, non-destructive clip timing, inline
automation, constrained MIDI editing, audio-device selection, and two views of
the same effect chain.

## Decision

- Give every DAW dock area a `BlenderEditorAreaController<DawEditorView>` and a
  header selector. Persist editor choice through `BlenderEditorSessionService`.
- Defer initial editor-area persistence by one microtask. Dock layouts create
  controllers inside `LayoutBuilder`; notifying the session synchronously
  there incorrectly dirtied `BlenderEditorSessionScope` during build.
- Store clip offset, source tempo, playback rate, loop state, per-track height,
  automation expansion, and master effects in the portable project model.
- Treat trim and stretch as distinct editing modes. Stretch preserves source
  material and derives playback rate from the old and new durations.
- Project automation lanes directly into the arrangement. The dedicated
  automation editor and expanded lanes mutate the same points.
- Keep scale selection as piano-editor presentation/edit policy. It filters the
  visible notes and snaps created or dragged pitches without destructively
  deleting out-of-scale notes.
- Keep device discovery and engine restarts in `DawAudioDeviceController` so
  Preferences is backend-independent.
- Make the ordered `DawPluginSlot` list the canonical DSP chain for tracks and
  master. The horizontal effect rack and node graph are synchronized
  projections; graphical connections reorder devices rather than creating a
  second, divergent graph model.
- Keep native DSP and device enumeration behind `DawAudioEngine` and
  `DawPluginHost`. Flutter owns control-plane state and editing only.

## Consequences

Users can turn any retained area into Arrangement, Piano Roll, Wave,
Automation, Mixer, browser/rack, Effect Chain, or Audio Routing without
rebuilding the workspace. Project saves retain non-destructive timing,
expanded lane state, track sizes, and master processing.

The in-memory engine exposes a deterministic device catalog for tests. Production
hosts supply the real device catalog and restart behavior through the same
controller. Arbitrary parallel DSP graphs are intentionally not modeled yet;
the current graph editor is a clean visual editor for serial track/master
chains and can be extended later with sends, buses, and typed split/merge nodes.

## Implementation experience

- Running nested-package tests from the repository root used the root package
  map and produced false "package not found" failures. Each Flutter package is
  resolved and tested from its own directory.
- The widget suite exposed the synchronous editor-session notification and a
  narrow clip-property row overflow; both were fixed at their reusable source
  instead of hidden in the example.
- Arrangement painting was separated into a part file and plug-in mutations
  into a controller extension so interaction, rendering, and DSP-chain commands
  remain independently reviewable.
