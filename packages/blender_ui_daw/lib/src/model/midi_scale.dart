enum DawScaleKind {
  chromatic('Chromatic', <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]),
  major('Major', <int>[0, 2, 4, 5, 7, 9, 11]),
  naturalMinor('Natural Minor', <int>[0, 2, 3, 5, 7, 8, 10]),
  harmonicMinor('Harmonic Minor', <int>[0, 2, 3, 5, 7, 8, 11]),
  majorPentatonic('Major Pentatonic', <int>[0, 2, 4, 7, 9]),
  minorPentatonic('Minor Pentatonic', <int>[0, 3, 5, 7, 10]),
  blues('Blues', <int>[0, 3, 5, 6, 7, 10]);

  const DawScaleKind(this.label, this.intervals);
  final String label;
  final List<int> intervals;
}

class DawMidiScaleFilter {
  const DawMidiScaleFilter({
    this.rootPitchClass = 0,
    this.scale = DawScaleKind.chromatic,
    this.enabled = false,
  });

  static const List<String> pitchClassNames = <String>[
    'C',
    'C♯',
    'D',
    'D♯',
    'E',
    'F',
    'F♯',
    'G',
    'G♯',
    'A',
    'A♯',
    'B',
  ];

  final int rootPitchClass;
  final DawScaleKind scale;
  final bool enabled;

  bool contains(int pitch) {
    if (!enabled || scale == DawScaleKind.chromatic) return true;
    return scale.intervals.contains((pitch - rootPitchClass) % 12);
  }

  int snapPitch(int pitch) {
    final clamped = pitch.clamp(0, 127);
    if (contains(clamped)) return clamped;
    for (var distance = 1; distance < 12; distance++) {
      final down = clamped - distance;
      if (down >= 0 && contains(down)) return down;
      final up = clamped + distance;
      if (up <= 127 && contains(up)) return up;
    }
    return clamped;
  }

  DawMidiScaleFilter copyWith({
    int? rootPitchClass,
    DawScaleKind? scale,
    bool? enabled,
  }) => DawMidiScaleFilter(
    rootPitchClass: (rootPitchClass ?? this.rootPitchClass) % 12,
    scale: scale ?? this.scale,
    enabled: enabled ?? this.enabled,
  );
}
