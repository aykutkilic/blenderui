part of '../non3d_editors.dart';

enum BlenderSequencerStripType {
  movie,
  image,
  sound,
  scene,
  color,
  effect,
  transition,
}

class BlenderSequencerStrip {
  const BlenderSequencerStrip({
    required this.id,
    required this.label,
    required this.start,
    required this.end,
    this.channel = 0,
    this.color,
    this.muted = false,
    this.locked = false,
    this.type = BlenderSequencerStripType.movie,
    this.source,
    this.showWaveform = false,
    this.showHandles = true,
  });

  final String id;
  final String label;
  final double start;
  final double end;
  final int channel;
  final Color? color;
  final bool muted;
  final bool locked;
  final BlenderSequencerStripType type;
  final String? source;
  final bool showWaveform;
  final bool showHandles;
}

@immutable
class BlenderSequencerMarker {
  const BlenderSequencerMarker({required this.frame, required this.label});

  final double frame;
  final String label;
}
