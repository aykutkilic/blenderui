import 'dart:convert';

import '../model/project.dart';

/// Versioned, deterministic JSON codec for portable DAW project state.
///
/// Audio media and plug-in binaries remain external. The project stores source
/// paths, editor waveform peaks, routing metadata, and plug-in identities so a
/// host can relink media and restore native state separately.
class DawProjectCodec extends Codec<DawProject, String> {
  const DawProjectCodec();

  static const int currentVersion = 2;

  @override
  Converter<String, DawProject> get decoder => const _DawProjectDecoder();

  @override
  Converter<DawProject, String> get encoder => const _DawProjectEncoder();
}

class DawProjectFormatException implements Exception {
  const DawProjectFormatException(this.message);

  final String message;

  @override
  String toString() => 'DawProjectFormatException: $message';
}

class _DawProjectEncoder extends Converter<DawProject, String> {
  const _DawProjectEncoder();

  @override
  String convert(DawProject input) => jsonEncode(<String, Object?>{
    'format': 'blender_ui_daw_project',
    'version': DawProjectCodec.currentVersion,
    'project': _projectToJson(input),
  });
}

class _DawProjectDecoder extends Converter<String, DawProject> {
  const _DawProjectDecoder();

  @override
  DawProject convert(String input) {
    Object? value;
    try {
      value = jsonDecode(input);
    } on FormatException catch (error) {
      throw DawProjectFormatException('Invalid JSON: ${error.message}');
    }
    final root = _map(value, 'root');
    if (root['format'] != 'blender_ui_daw_project') {
      throw const DawProjectFormatException('Unsupported project format');
    }
    final version = _integer(root['version'], 'version');
    if (version < 1 || version > DawProjectCodec.currentVersion) {
      throw DawProjectFormatException('Unsupported project version $version');
    }
    return _projectFromJson(_map(root['project'], 'project'));
  }
}

Map<String, Object?> _projectToJson(DawProject project) => <String, Object?>{
  'id': project.id,
  'name': project.name,
  'lengthBeats': project.lengthBeats,
  'sampleRate': project.sampleRate,
  'timeSignature': <String, Object?>{
    'numerator': project.timeSignature.numerator,
    'denominator': project.timeSignature.denominator,
  },
  'tempoMap': <Object?>[
    for (final point in project.tempoMap)
      <String, Object?>{'beat': point.beat, 'bpm': point.bpm},
  ],
  'loop': <String, Object?>{
    'enabled': project.loopEnabled,
    'startBeat': project.loopStartBeat,
    'endBeat': project.loopEndBeat,
  },
  'tracks': <Object?>[for (final track in project.tracks) _trackToJson(track)],
  'master': _trackToJson(project.master),
};

Map<String, Object?> _trackToJson(DawTrack track) => <String, Object?>{
  'id': track.id,
  'name': track.name,
  'type': track.type.name,
  'color': track.colorValue,
  'volume': track.volume,
  'pan': track.pan,
  'muted': track.muted,
  'solo': track.solo,
  'armed': track.armed,
  'collapsed': track.collapsed,
  'heightScale': track.heightScale,
  'automationExpanded': track.automationExpanded,
  'clips': <Object?>[for (final clip in track.clips) _clipToJson(clip)],
  'automation': <Object?>[
    for (final lane in track.automation)
      <String, Object?>{
        'id': lane.id,
        'name': lane.name,
        'parameterId': lane.parameterId,
        'enabled': lane.enabled,
        'color': lane.colorValue,
        'points': <Object?>[
          for (final point in lane.points)
            <String, Object?>{
              'id': point.id,
              'beat': point.beat,
              'value': point.value,
              'interpolation': point.interpolation.name,
            },
        ],
      },
  ],
  'plugins': <Object?>[
    for (final slot in track.plugins)
      <String, Object?>{
        'id': slot.id,
        'pluginId': slot.pluginId,
        'name': slot.name,
        'enabled': slot.enabled,
        'wet': slot.wet,
        'parameters': slot.parameters,
        'state': slot.state,
      },
  ],
};

Map<String, Object?> _clipToJson(DawClip clip) => <String, Object?>{
  'kind': clip is DawAudioClip ? 'audio' : 'midi',
  'id': clip.id,
  'name': clip.name,
  'startBeat': clip.startBeat,
  'lengthBeats': clip.lengthBeats,
  'offsetBeats': clip.offsetBeats,
  'color': clip.colorValue,
  'muted': clip.muted,
  'looped': clip.looped,
  'sourceTempo': clip.sourceTempo,
  'playbackRate': clip.playbackRate,
  if (clip is DawMidiClip)
    'notes': <Object?>[
      for (final note in clip.notes)
        <String, Object?>{
          'id': note.id,
          'pitch': note.pitch,
          'startBeat': note.startBeat,
          'lengthBeats': note.lengthBeats,
          'velocity': note.velocity,
          'channel': note.channel,
          'muted': note.muted,
        },
    ],
  if (clip is DawAudioClip) ...<String, Object?>{
    'sourcePath': clip.sourcePath,
    'waveform': <String, Object?>{
      'peaks': clip.waveform.peaks,
      'sampleRate': clip.waveform.sampleRate,
      'channels': clip.waveform.channels,
    },
    'gain': clip.gain,
    'fadeInBeats': clip.fadeInBeats,
    'fadeOutBeats': clip.fadeOutBeats,
    'reversed': clip.reversed,
  },
};

DawProject _projectFromJson(Map<String, Object?> json) {
  final signature = _map(json['timeSignature'], 'timeSignature');
  final loop = _map(json['loop'], 'loop');
  return DawProject(
    id: _string(json['id'], 'project.id'),
    name: _string(json['name'], 'project.name'),
    lengthBeats: _readJsonNumber(json['lengthBeats'], 'project.lengthBeats'),
    sampleRate: _integer(json['sampleRate'], 'project.sampleRate'),
    timeSignature: DawTimeSignature(
      numerator: _integer(signature['numerator'], 'timeSignature.numerator'),
      denominator: _integer(
        signature['denominator'],
        'timeSignature.denominator',
      ),
    ),
    tempoMap: <DawTempoPoint>[
      for (final value in _list(json['tempoMap'], 'tempoMap'))
        _tempoFromJson(_map(value, 'tempoMap item')),
    ],
    loopEnabled: _boolean(loop['enabled'], 'loop.enabled'),
    loopStartBeat: _readJsonNumber(loop['startBeat'], 'loop.startBeat'),
    loopEndBeat: _readJsonNumber(loop['endBeat'], 'loop.endBeat'),
    tracks: <DawTrack>[
      for (final value in _list(json['tracks'], 'tracks'))
        _trackFromJson(_map(value, 'track')),
    ],
    master: json['master'] == null
        ? DawTrack(
            id: 'master',
            name: 'Master',
            type: DawTrackType.audio,
            colorValue: 0xFF8C8C8C,
          )
        : _trackFromJson(_map(json['master'], 'master')),
  );
}

DawTempoPoint _tempoFromJson(Map<String, Object?> json) => DawTempoPoint(
  beat: _readJsonNumber(json['beat'], 'tempo.beat'),
  bpm: _readJsonNumber(json['bpm'], 'tempo.bpm'),
);

DawTrack _trackFromJson(Map<String, Object?> json) => DawTrack(
  id: _string(json['id'], 'track.id'),
  name: _string(json['name'], 'track.name'),
  type: _enumValue(DawTrackType.values, json['type'], 'track.type'),
  colorValue: _integer(json['color'], 'track.color'),
  volume: _readJsonNumber(json['volume'], 'track.volume'),
  pan: _readJsonNumber(json['pan'], 'track.pan'),
  muted: _boolean(json['muted'], 'track.muted'),
  solo: _boolean(json['solo'], 'track.solo'),
  armed: _boolean(json['armed'], 'track.armed'),
  collapsed: _boolean(json['collapsed'], 'track.collapsed'),
  heightScale: _readJsonNumber(json['heightScale'], 'track.heightScale'),
  automationExpanded: _boolean(
    json['automationExpanded'],
    'track.automationExpanded',
  ),
  clips: <DawClip>[
    for (final value in _list(json['clips'], 'track.clips'))
      _clipFromJson(_map(value, 'clip')),
  ],
  automation: <DawAutomationLane>[
    for (final value in _list(json['automation'], 'track.automation'))
      _automationFromJson(_map(value, 'automation lane')),
  ],
  plugins: <DawPluginSlot>[
    for (final value in _list(json['plugins'], 'track.plugins'))
      _pluginSlotFromJson(_map(value, 'plugin slot')),
  ],
);

DawClip _clipFromJson(Map<String, Object?> json) {
  final shared = (
    id: _string(json['id'], 'clip.id'),
    name: _string(json['name'], 'clip.name'),
    start: _readJsonNumber(json['startBeat'], 'clip.startBeat'),
    length: _readJsonNumber(json['lengthBeats'], 'clip.lengthBeats'),
    offset: _readJsonNumber(json['offsetBeats'], 'clip.offsetBeats'),
    color: _integer(json['color'], 'clip.color'),
    muted: _boolean(json['muted'], 'clip.muted'),
    looped: _boolean(json['looped'], 'clip.looped'),
    sourceTempo: _readJsonNumber(json['sourceTempo'], 'clip.sourceTempo'),
    playbackRate: _readJsonNumber(json['playbackRate'], 'clip.playbackRate'),
  );
  switch (_string(json['kind'], 'clip.kind')) {
    case 'midi':
      return DawMidiClip(
        id: shared.id,
        name: shared.name,
        startBeat: shared.start,
        lengthBeats: shared.length,
        offsetBeats: shared.offset,
        colorValue: shared.color,
        muted: shared.muted,
        looped: shared.looped,
        sourceTempo: shared.sourceTempo,
        playbackRate: shared.playbackRate,
        notes: <DawMidiNote>[
          for (final value in _list(json['notes'], 'clip.notes'))
            _noteFromJson(_map(value, 'note')),
        ],
      );
    case 'audio':
      final waveform = _map(json['waveform'], 'clip.waveform');
      return DawAudioClip(
        id: shared.id,
        name: shared.name,
        startBeat: shared.start,
        lengthBeats: shared.length,
        offsetBeats: shared.offset,
        colorValue: shared.color,
        muted: shared.muted,
        looped: shared.looped,
        sourceTempo: shared.sourceTempo,
        playbackRate: shared.playbackRate,
        sourcePath: _string(json['sourcePath'], 'clip.sourcePath'),
        waveform: DawWaveform(
          peaks: <double>[
            for (final peak in _list(waveform['peaks'], 'waveform.peaks'))
              _readJsonNumber(peak, 'waveform peak'),
          ],
          sampleRate: _integer(waveform['sampleRate'], 'waveform.sampleRate'),
          channels: _integer(waveform['channels'], 'waveform.channels'),
        ),
        gain: _readJsonNumber(json['gain'], 'clip.gain'),
        fadeInBeats: _readJsonNumber(json['fadeInBeats'], 'clip.fadeInBeats'),
        fadeOutBeats: _readJsonNumber(
          json['fadeOutBeats'],
          'clip.fadeOutBeats',
        ),
        reversed: _boolean(json['reversed'], 'clip.reversed'),
      );
    default:
      throw DawProjectFormatException('Unknown clip kind ${json['kind']}');
  }
}

DawMidiNote _noteFromJson(Map<String, Object?> json) => DawMidiNote(
  id: _string(json['id'], 'note.id'),
  pitch: _integer(json['pitch'], 'note.pitch'),
  startBeat: _readJsonNumber(json['startBeat'], 'note.startBeat'),
  lengthBeats: _readJsonNumber(json['lengthBeats'], 'note.lengthBeats'),
  velocity: _readJsonNumber(json['velocity'], 'note.velocity'),
  channel: _integer(json['channel'], 'note.channel'),
  muted: _boolean(json['muted'], 'note.muted'),
);

DawAutomationLane _automationFromJson(Map<String, Object?> json) =>
    DawAutomationLane(
      id: _string(json['id'], 'automation.id'),
      name: _string(json['name'], 'automation.name'),
      parameterId: _string(json['parameterId'], 'automation.parameterId'),
      enabled: _boolean(json['enabled'], 'automation.enabled'),
      colorValue: _integer(json['color'], 'automation.color'),
      points: <DawAutomationPoint>[
        for (final value in _list(json['points'], 'automation.points'))
          _automationPointFromJson(_map(value, 'automation point')),
      ],
    );

DawAutomationPoint _automationPointFromJson(Map<String, Object?> json) =>
    DawAutomationPoint(
      id: _string(json['id'], 'automation point.id'),
      beat: _readJsonNumber(json['beat'], 'automation point.beat'),
      value: _readJsonNumber(json['value'], 'automation point.value'),
      interpolation: _enumValue(
        DawAutomationInterpolation.values,
        json['interpolation'],
        'automation point.interpolation',
      ),
    );

DawPluginSlot _pluginSlotFromJson(Map<String, Object?> json) => DawPluginSlot(
  id: _string(json['id'], 'plugin.id'),
  pluginId: _string(json['pluginId'], 'plugin.pluginId'),
  name: _string(json['name'], 'plugin.name'),
  enabled: _boolean(json['enabled'], 'plugin.enabled'),
  wet: _readJsonNumber(json['wet'], 'plugin.wet'),
  parameters: <String, double>{
    for (final entry in _mapOrEmpty(json['parameters']).entries)
      entry.key: _readJsonNumber(entry.value, 'plugin.parameters.${entry.key}'),
  },
  state: <int>[
    for (final value in _listOrEmpty(json['state']))
      _integer(value, 'plugin.state'),
  ],
);

Map<String, Object?> _map(Object? value, String name) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) return value.cast<String, Object?>();
  throw DawProjectFormatException('$name must be an object');
}

List<Object?> _list(Object? value, String name) {
  if (value is List) return value.cast<Object?>();
  throw DawProjectFormatException('$name must be an array');
}

Map<String, Object?> _mapOrEmpty(Object? value) => value == null
    ? const <String, Object?>{}
    : _map(value, 'plugin.parameters');

List<Object?> _listOrEmpty(Object? value) =>
    value == null ? const <Object?>[] : _list(value, 'plugin.state');

String _string(Object? value, String name) {
  if (value is String) return value;
  throw DawProjectFormatException('$name must be a string');
}

double _readJsonNumber(Object? value, String name) {
  if (value is num) return value.toDouble();
  throw DawProjectFormatException('$name must be a number');
}

int _integer(Object? value, String name) {
  if (value is int) return value;
  throw DawProjectFormatException('$name must be an integer');
}

bool _boolean(Object? value, String name) {
  if (value is bool) return value;
  throw DawProjectFormatException('$name must be a boolean');
}

T _enumValue<T extends Enum>(List<T> values, Object? value, String name) {
  final encoded = _string(value, name);
  for (final candidate in values) {
    if (candidate.name == encoded) return candidate;
  }
  throw DawProjectFormatException('$name has unknown value $encoded');
}
