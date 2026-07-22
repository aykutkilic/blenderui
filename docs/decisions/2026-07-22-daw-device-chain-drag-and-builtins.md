# DAW device-chain drag, built-ins, and compact metering

Date: 2026-07-22

## Context

The plug-in browser and effect chain previously behaved as separate lists. A
device could only be appended through a dropdown, device cards consumed too
much space, and the example catalog contained pretend third-party products.
The intended interaction is a device browser feeding an ordered, Ableton-like
rack while preserving BlenderUI's reusable editor-area architecture.

## Decision

- `BlenderListView` exposes an optional typed row-wrapper hook. It retains one
  implementation of selection, activation, context menus, semantics, density,
  and disabled styling while allowing domain packages to add drag behavior.
- `DawPluginDragPayload` is the sole browser-to-chain transfer type. Only
  descriptors whose host reports `loadable` become drag sources.
- The chain owns explicit insertion targets before, between, and after devices.
  A drop is transactional: instantiate through `DawPluginHost` first, then add
  the returned instance to project state at the requested index. A failed load
  cannot create an orphan project slot.
- Every card owns a compact on/off control and a repaint-isolated peak meter.
  Meter values prefer per-device peaks and fall back to track/master peaks from
  `DawAudioEngine`; the UI never invents activity. The on/off control updates
  project state and the host's native bypass together.
- Six library-owned descriptors define Auto Filter, EQ Eight, Compressor,
  Dynamics Compressor, Delay, and Reverb. The deterministic host provides
  stable parameter models. The macOS bridge creates corresponding real Apple
  `AVAudioUnit` processors (EQ, dynamics, multiband dynamics, delay, reverb).
- Removing a chain slot also removes its hosted instance. Project ordering and
  host lifetime therefore remain synchronized at the editor boundary.

## Native-host boundary

Audio Unit and internal processors can be instantiated today. VST3 bundles are
still discovery-only because this checkout has neither the Steinberg VST3 SDK
nor an isolated plug-in helper. They remain visible with an unavailable reason
but cannot be dragged or appended. Enabling them before real instantiation and
crash isolation exist would falsely claim host support.

Creating an `AVAudioUnit` is separate from connecting it into the real-time
track graph. The native engine remains responsible for graph rebuilds, render
thread ownership, latency compensation, per-device bypass, and per-device tap
metering; Flutter only performs control-plane edits.

## Validation and experience

- A widget test drags Auto Filter from the shared browser row to the first
  insertion seam and verifies both host instance and project slot.
- Host tests verify the six built-ins and EQ Eight's eight-band parameter model.
- The first macOS compile found that `AVAudioUnitDynamicsProcessor` does not
  exist in AVFoundation. The implementation now constructs Apple's Dynamics
  Processor and Multiband Compressor through `AVAudioUnitEffect` component
  descriptions, and the macOS debug build succeeds.
- Formatting initially failed inside the restricted sandbox because Flutter's
  wrapper updates shared SDK metadata. Approved SDK access was used; no project
  architecture was changed to work around the tool environment.
