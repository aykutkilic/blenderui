# DAW extension boundary and native Preferences delivery

Date: 2026-07-21

## Context

The DAW example needs domain editors and services that are reusable by audio
applications but do not belong in BlenderUI's general desktop UI package. It
also exposed a macOS lifecycle edge case: AppKit owns the standard `Cmd+,`
menu equivalent, so a generated `Preferences…` item without an action consumes
the shortcut before Flutter can dispatch its runtime keymap. When the action
was forwarded, presenting a route from that native callback still needed an
explicit Flutter frame.

## Decision

- Keep general controls, docking, workspaces, history, commands, keymaps,
  Preferences presentation, and playback primitives in `blender_ui`.
- Keep DAW project models, editing controllers, plug-in host boundaries, and
  audio-specific editors in the sibling `blender_ui_daw` package.
- Keep portable JSON and storage orchestration free of `dart:io`; executable
  hosts provide filesystem, database, or cloud stores behind `DawProjectStore`.
- Keep real-time audio and third-party binary loading behind control-plane
  interfaces. `DawNativePluginHost` serializes VST3/AU/CLAP discovery,
  instances, parameters, and opaque state over a method channel, while native
  code owns isolation and DSP.
- Keep `examples/daw` composition-only: it supplies fixtures, workspace layouts,
  commands, platform-runner glue, and host implementations.
- Connect the macOS application menu to a thin lifecycle method-channel adapter
  in each executable runner. AppKit-specific XIB and Swift code cannot live in
  a pure Flutter UI package.
- Make `BlenderPreferencesService.show` request the immediate visual update.
  This presentation invariant belongs to the shared service, not individual
  example callbacks.
- Allow `BlenderDropdown` to fill bounded property rows and size naturally in
  unbounded, horizontally scrollable editor headers.

## Consequences

`Cmd+,` now opens the DAW Preferences surface without waiting for hover,
resize, or another state change. Other applications using the shared service
inherit the same frame behavior. The platform runner remains intentionally
small, while the command binding and visual presentation remain reusable.

The DAW extension is a UI and host-contract package. Native plug-in code must
run behind its host interface and outside Flutter's UI isolate; the example's
deterministic in-memory host is not presented as an audio-processing engine.
