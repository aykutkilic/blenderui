# Native audio, plug-in, and MIDI discovery

Date: 2026-07-22

## Context

The DAW example originally used deterministic plug-in and audio-device fixtures.
That kept tests portable but prevented the macOS application from presenting
the Audio Units, VST3 bundles, CoreAudio devices, and CoreMIDI controllers that
are already installed on the user's computer.

## Decision

- Select native host adapters in the macOS executable and retain deterministic
  hosts for tests and non-macOS examples.
- Enumerate Audio Units with AudioToolbox and instantiate them with
  `AVAudioUnit`. Expose real AU parameters, normalized parameter writes, and
  portable full-state blobs through the existing `DawPluginHost` contract.
- Recursively discover system and user VST3 bundles, reading bundle and
  `moduleinfo.json` metadata when available. Mark them as discovery-only until
  an isolated Steinberg VST3 SDK host is implemented; do not pretend that
  finding a bundle is equivalent to safely loading it.
- Enumerate CoreAudio devices and channel counts through HAL properties, and
  apply independent input/output device and buffer-size selection to a native
  `AVAudioEngine`.
- Enumerate CoreMIDI sources and destinations with their display name,
  manufacturer, model, online state, and direction.
- Run plug-in scanning on a user-initiated background queue and publish the
  completed catalog on the main queue.
- Disable the example runner's App Sandbox. Arbitrary installed plug-in bundle
  discovery and hosting conflicts with a generic sandboxed executable. A
  production product should move third-party loading into separately signed,
  restricted scanner and DSP processes before distribution.

## Consequences

The macOS example now starts with the real native catalogs. Audio Units can be
loaded and edited in the plug-in rack and track/master chains. VST3 instruments
and effects are visible with an explicit “Discovery only” state and cannot
trigger an unsafe or fake load operation. Audio and MIDI Preferences reflect
the endpoints reported by CoreAudio and CoreMIDI.

The current native engine is still a control-plane proof rather than a complete
recording/rendering graph: transport synchronization and offline rendering need
the future DSP engine. VST3 execution requires the VST3 SDK bridge, validation,
crash isolation, and plug-in process lifecycle.

## Implementation experience

- The local machine contains a large `/Library/Audio/Plug-Ins/VST3` catalog,
  including nested vendor directories, so scanning was made recursive and skips
  package descendants after locating each bundle.
- No VST3 SDK checkout was present locally. This ruled out a responsible VST3
  loader in this change and led to explicit capability metadata instead.
- `AudioComponentFindNext` in the installed SDK requires a wildcard
  `AudioComponentDescription` pointer rather than `nil`.
- A first widget run exposed initialization ordering: Preferences captures the
  plug-in host, so native hosts must be created before the application service.
- Non-macOS test hosts already contain their catalog and should not schedule an
  asynchronous startup scan; doing so left a synthetic timer pending in widget
  tests.
