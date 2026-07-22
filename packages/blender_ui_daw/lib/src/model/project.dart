import 'dart:math' as math;

enum DawTrackType { audio, midi, instrument, automation, bus, master }

enum DawAutomationInterpolation { hold, linear, smooth }

enum DawAutomationWriteMode { read, write, touch, latch }

enum DawClipResizeMode { trim, stretch }

class DawTimeSignature {
  const DawTimeSignature({this.numerator = 4, this.denominator = 4});

  final int numerator;
  final int denominator;
}

class DawTempoPoint {
  const DawTempoPoint({required this.beat, required this.bpm});

  final double beat;
  final double bpm;
}

class DawMidiNote {
  const DawMidiNote({
    required this.id,
    required this.pitch,
    required this.startBeat,
    required this.lengthBeats,
    this.velocity = .8,
    this.channel = 1,
    this.muted = false,
  });

  final String id;
  final int pitch;
  final double startBeat;
  final double lengthBeats;
  final double velocity;
  final int channel;
  final bool muted;

  double get endBeat => startBeat + lengthBeats;

  DawMidiNote copyWith({
    int? pitch,
    double? startBeat,
    double? lengthBeats,
    double? velocity,
    int? channel,
    bool? muted,
  }) => DawMidiNote(
    id: id,
    pitch: pitch ?? this.pitch,
    startBeat: startBeat ?? this.startBeat,
    lengthBeats: lengthBeats ?? this.lengthBeats,
    velocity: velocity ?? this.velocity,
    channel: channel ?? this.channel,
    muted: muted ?? this.muted,
  );
}

abstract class DawClip {
  const DawClip({
    required this.id,
    required this.name,
    required this.startBeat,
    required this.lengthBeats,
    this.offsetBeats = 0,
    this.colorValue = 0xFF4C78B8,
    this.muted = false,
    this.looped = false,
    this.sourceTempo = 120,
    this.playbackRate = 1,
  });

  final String id;
  final String name;
  final double startBeat;
  final double lengthBeats;
  final double offsetBeats;
  final int colorValue;
  final bool muted;
  final bool looped;
  final double sourceTempo;
  final double playbackRate;

  double get endBeat => startBeat + lengthBeats;

  DawClip moveTo(double beat);
  DawClip resize(double lengthBeats);
}

class DawMidiClip extends DawClip {
  const DawMidiClip({
    required super.id,
    required super.name,
    required super.startBeat,
    required super.lengthBeats,
    super.offsetBeats,
    super.colorValue = 0xFF5B8FD1,
    super.muted,
    super.looped,
    super.sourceTempo,
    super.playbackRate,
    this.notes = const <DawMidiNote>[],
  });

  final List<DawMidiNote> notes;

  DawMidiClip copyWith({
    String? id,
    String? name,
    double? startBeat,
    double? lengthBeats,
    double? offsetBeats,
    int? colorValue,
    List<DawMidiNote>? notes,
    bool? muted,
    bool? looped,
    double? sourceTempo,
    double? playbackRate,
  }) => DawMidiClip(
    id: id ?? this.id,
    name: name ?? this.name,
    startBeat: startBeat ?? this.startBeat,
    lengthBeats: math.max(.0625, lengthBeats ?? this.lengthBeats),
    offsetBeats: offsetBeats ?? this.offsetBeats,
    colorValue: colorValue ?? this.colorValue,
    muted: muted ?? this.muted,
    looped: looped ?? this.looped,
    sourceTempo: (sourceTempo ?? this.sourceTempo).clamp(20, 400).toDouble(),
    playbackRate: (playbackRate ?? this.playbackRate).clamp(.05, 20).toDouble(),
    notes: notes ?? this.notes,
  );

  @override
  DawMidiClip moveTo(double beat) => copyWith(startBeat: math.max(0, beat));

  @override
  DawMidiClip resize(double lengthBeats) => copyWith(lengthBeats: lengthBeats);
}

class DawWaveform {
  const DawWaveform({
    required this.peaks,
    this.sampleRate = 48000,
    this.channels = 2,
  });

  /// Interleaved normalized peak amplitudes used for editor rendering.
  final List<double> peaks;
  final int sampleRate;
  final int channels;
}

class DawAudioClip extends DawClip {
  const DawAudioClip({
    required super.id,
    required super.name,
    required super.startBeat,
    required super.lengthBeats,
    required this.sourcePath,
    required this.waveform,
    super.offsetBeats,
    super.colorValue = 0xFF4F9B73,
    super.muted,
    super.looped,
    super.sourceTempo,
    super.playbackRate,
    this.gain = 1,
    this.fadeInBeats = 0,
    this.fadeOutBeats = 0,
    this.reversed = false,
  });

  final String sourcePath;
  final DawWaveform waveform;
  final double gain;
  final double fadeInBeats;
  final double fadeOutBeats;
  final bool reversed;

  DawAudioClip copyWith({
    String? id,
    String? name,
    double? startBeat,
    double? lengthBeats,
    double? offsetBeats,
    int? colorValue,
    double? gain,
    double? fadeInBeats,
    double? fadeOutBeats,
    bool? reversed,
    bool? muted,
    bool? looped,
    double? sourceTempo,
    double? playbackRate,
  }) => DawAudioClip(
    id: id ?? this.id,
    name: name ?? this.name,
    startBeat: startBeat ?? this.startBeat,
    lengthBeats: math.max(.0625, lengthBeats ?? this.lengthBeats),
    sourcePath: sourcePath,
    waveform: waveform,
    offsetBeats: offsetBeats ?? this.offsetBeats,
    colorValue: colorValue ?? this.colorValue,
    muted: muted ?? this.muted,
    looped: looped ?? this.looped,
    sourceTempo: (sourceTempo ?? this.sourceTempo).clamp(20, 400).toDouble(),
    playbackRate: (playbackRate ?? this.playbackRate).clamp(.05, 20).toDouble(),
    gain: gain ?? this.gain,
    fadeInBeats: fadeInBeats ?? this.fadeInBeats,
    fadeOutBeats: fadeOutBeats ?? this.fadeOutBeats,
    reversed: reversed ?? this.reversed,
  );

  @override
  DawAudioClip moveTo(double beat) => copyWith(startBeat: math.max(0, beat));

  @override
  DawAudioClip resize(double lengthBeats) => copyWith(lengthBeats: lengthBeats);
}

class DawAutomationPoint {
  const DawAutomationPoint({
    required this.id,
    required this.beat,
    required this.value,
    this.interpolation = DawAutomationInterpolation.smooth,
  });

  final String id;
  final double beat;
  final double value;
  final DawAutomationInterpolation interpolation;

  DawAutomationPoint copyWith({double? beat, double? value}) =>
      DawAutomationPoint(
        id: id,
        beat: beat ?? this.beat,
        value: (value ?? this.value).clamp(0, 1).toDouble(),
        interpolation: interpolation,
      );
}

class DawAutomationLane {
  const DawAutomationLane({
    required this.id,
    required this.name,
    required this.parameterId,
    this.points = const <DawAutomationPoint>[],
    this.enabled = true,
    this.colorValue = 0xFFE7A33E,
  });

  final String id;
  final String name;
  final String parameterId;
  final List<DawAutomationPoint> points;
  final bool enabled;
  final int colorValue;

  DawAutomationLane copyWith({
    List<DawAutomationPoint>? points,
    bool? enabled,
  }) => DawAutomationLane(
    id: id,
    name: name,
    parameterId: parameterId,
    points: points ?? this.points,
    enabled: enabled ?? this.enabled,
    colorValue: colorValue,
  );
}

class DawPluginSlot {
  const DawPluginSlot({
    required this.id,
    required this.pluginId,
    required this.name,
    this.enabled = true,
    this.wet = 1,
  });

  final String id;
  final String pluginId;
  final String name;
  final bool enabled;
  final double wet;

  DawPluginSlot copyWith({bool? enabled, double? wet}) => DawPluginSlot(
    id: id,
    pluginId: pluginId,
    name: name,
    enabled: enabled ?? this.enabled,
    wet: (wet ?? this.wet).clamp(0, 1).toDouble(),
  );
}

class DawTrack {
  const DawTrack({
    required this.id,
    required this.name,
    required this.type,
    this.clips = const <DawClip>[],
    this.automation = const <DawAutomationLane>[],
    this.plugins = const <DawPluginSlot>[],
    this.colorValue = 0xFF5B8FD1,
    this.volume = .8,
    this.pan = 0,
    this.muted = false,
    this.solo = false,
    this.armed = false,
    this.collapsed = false,
    this.heightScale = 1,
    this.automationExpanded = false,
  });

  final String id;
  final String name;
  final DawTrackType type;
  final List<DawClip> clips;
  final List<DawAutomationLane> automation;
  final List<DawPluginSlot> plugins;
  final int colorValue;
  final double volume;
  final double pan;
  final bool muted;
  final bool solo;
  final bool armed;
  final bool collapsed;
  final double heightScale;
  final bool automationExpanded;

  DawTrack copyWith({
    List<DawClip>? clips,
    List<DawAutomationLane>? automation,
    List<DawPluginSlot>? plugins,
    double? volume,
    double? pan,
    bool? muted,
    bool? solo,
    bool? armed,
    bool? collapsed,
    double? heightScale,
    bool? automationExpanded,
  }) => DawTrack(
    id: id,
    name: name,
    type: type,
    clips: clips ?? this.clips,
    automation: automation ?? this.automation,
    plugins: plugins ?? this.plugins,
    colorValue: colorValue,
    volume: (volume ?? this.volume).clamp(0, 1).toDouble(),
    pan: (pan ?? this.pan).clamp(-1, 1).toDouble(),
    muted: muted ?? this.muted,
    solo: solo ?? this.solo,
    armed: armed ?? this.armed,
    collapsed: collapsed ?? this.collapsed,
    heightScale: (heightScale ?? this.heightScale).clamp(.55, 4).toDouble(),
    automationExpanded: automationExpanded ?? this.automationExpanded,
  );
}

class DawProject {
  const DawProject({
    required this.id,
    required this.name,
    required this.tracks,
    this.lengthBeats = 128,
    this.tempoMap = const <DawTempoPoint>[DawTempoPoint(beat: 0, bpm: 120)],
    this.timeSignature = const DawTimeSignature(),
    this.sampleRate = 48000,
    this.loopEnabled = false,
    this.loopStartBeat = 0,
    this.loopEndBeat = 16,
    this.master = const DawTrack(
      id: 'master',
      name: 'Master',
      type: DawTrackType.audio,
      colorValue: 0xFF8C8C8C,
    ),
  });

  final String id;
  final String name;
  final List<DawTrack> tracks;
  final double lengthBeats;
  final List<DawTempoPoint> tempoMap;
  final DawTimeSignature timeSignature;
  final int sampleRate;
  final bool loopEnabled;
  final double loopStartBeat;
  final double loopEndBeat;
  final DawTrack master;

  double tempoAt(double beat) {
    var tempo = tempoMap.firstOrNull?.bpm ?? 120;
    for (final point in tempoMap) {
      if (point.beat > beat) break;
      tempo = point.bpm;
    }
    return tempo;
  }

  DawProject copyWith({
    String? name,
    List<DawTrack>? tracks,
    double? lengthBeats,
    List<DawTempoPoint>? tempoMap,
    DawTimeSignature? timeSignature,
    int? sampleRate,
    bool? loopEnabled,
    double? loopStartBeat,
    double? loopEndBeat,
    DawTrack? master,
  }) => DawProject(
    id: id,
    name: name ?? this.name,
    tracks: tracks ?? this.tracks,
    lengthBeats: lengthBeats ?? this.lengthBeats,
    tempoMap: tempoMap ?? this.tempoMap,
    timeSignature: timeSignature ?? this.timeSignature,
    sampleRate: sampleRate ?? this.sampleRate,
    loopEnabled: loopEnabled ?? this.loopEnabled,
    loopStartBeat: loopStartBeat ?? this.loopStartBeat,
    loopEndBeat: loopEndBeat ?? this.loopEndBeat,
    master: master ?? this.master,
  );
}
