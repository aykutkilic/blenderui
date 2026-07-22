# BlenderUI DAW example

A desktop DAW composition demonstrating `blender_ui` together with the
`blender_ui_daw` extension package.

The Song, Mix, and Edit workspaces share one retained project/session state and
compose arrangement, piano-roll, waveform, automation, mixer, and plug-in
surfaces. Every dock area has a header editor selector. The arrangement supports
time zoom, draggable track heights, clip trim/stretch and loop editing, plus
expanded automation lanes. Piano Roll supports note timing/length edits,
snapping, and scale filtering. Devices can be dragged from Plugin Browser onto
precise Effect Chain insertion seams; cards expose compact bypass, VU, wet, and
hosted-parameter controls. Effect Chain and Audio Routing edit the same track
or master processing order, and Preferences can reconfigure the selected
audio device, sample rate, and buffer size.

Runtime shortcuts include Space for playback, R for recording,
Cmd+S for save, Delete for the active selection, and Cmd+, for Preferences.

Run on macOS with:

```sh
flutter run -d macos
```

On macOS the example discovers installed Audio Units and VST3 bundles, native
CoreAudio devices, and CoreMIDI endpoints. Audio Units are loadable through
`AVAudioUnit`. Auto Filter, EQ Eight, Compressor, Dynamics Compressor, Delay,
and Reverb are backed by native Apple processors. VST3 entries are marked
discovery-only until an isolated
Steinberg-SDK host is added. Non-macOS builds retain the deterministic catalog.

The macOS example disables App Sandbox so it can inspect installed plug-in
locations. A distributable host should move scanning and DSP into separately
signed, restricted helper processes.
