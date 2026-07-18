part of '../non3d_editors.dart';

class BlenderSequencerStrip {
  const BlenderSequencerStrip({
    required this.id,
    required this.label,
    required this.start,
    required this.end,
    this.channel = 0,
    this.color,
    this.muted = false,
  });

  final String id;
  final String label;
  final double start;
  final double end;
  final int channel;
  final Color? color;
  final bool muted;
}
