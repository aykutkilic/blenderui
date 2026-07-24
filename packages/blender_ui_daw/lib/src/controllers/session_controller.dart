import 'dart:math' as math;

import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/foundation.dart';

import '../model/project.dart';
import 'selection.dart';

/// Reusable DAW editing session backed by BlenderUI's bounded history and
/// high-frequency playback controller.
class DawSessionController extends ChangeNotifier {
  DawSessionController({
    required DawProject initialProject,
    BlenderHistoryStore<DawProject>? history,
    BlenderPlaybackController? playback,
    this.historyLimit = 100,
  }) : history =
           history ??
           BlenderHistoryStore<DawProject>(
             initialProject,
             historyLimit: historyLimit,
           ),
       playback =
           playback ??
           BlenderPlaybackController(
             initialFrame: 0,
             rangeStart: 0,
             rangeEnd: initialProject.lengthBeats,
           ),
       _ownsHistory = history == null,
       _ownsPlayback = playback == null {
    this.history.addListener(_relayProjectChange);
    this.playback.addListener(_relayPlaybackChange);
  }

  final int historyLimit;
  final BlenderHistoryStore<DawProject> history;
  final BlenderPlaybackController playback;
  final bool _ownsHistory;
  final bool _ownsPlayback;

  /// Emits only when the serializable project document has changed.
  ///
  /// Hosts should persist and synchronize audio graphs from this stream, never
  /// from the broad [ChangeNotifier] used to rebuild editor widgets.
  final ChangeNotifier projectChanges = ChangeNotifier();

  /// Emits selection-only changes.
  final ChangeNotifier selectionChanges = ChangeNotifier();

  /// Emits transient editor configuration changes such as zoom and snapping.
  final ChangeNotifier viewChanges = ChangeNotifier();

  /// Emits high-frequency transport updates.
  final ChangeNotifier playbackChanges = ChangeNotifier();

  DawSelection _selection = DawSelection();
  double _horizontalZoom = 1;
  double _verticalZoom = 1;
  double _snapBeats = .25;
  DawAutomationWriteMode _automationWriteMode = DawAutomationWriteMode.read;
  DawClipResizeMode _clipResizeMode = DawClipResizeMode.trim;
  int _entitySerial = 1;
  var _transactionDepth = 0;
  var _notificationPending = false;

  DawProject get project => history.value;
  DawSelection get selection => _selection;
  double get horizontalZoom => _horizontalZoom;
  double get verticalZoom => _verticalZoom;
  double get snapBeats => _snapBeats;
  DawAutomationWriteMode get automationWriteMode => _automationWriteMode;
  DawClipResizeMode get clipResizeMode => _clipResizeMode;
  bool get canUndo => history.canUndo;
  bool get canRedo => history.canRedo;

  DawTrack? get selectedTrack => _trackById(_selection.trackId);
  DawClip? get selectedClip {
    final id = _selection.clipId;
    if (id == null) return null;
    for (final track in project.tracks) {
      for (final clip in track.clips) {
        if (clip.id == id) return clip;
      }
    }
    return null;
  }

  void _relayProjectChange() {
    projectChanges.notifyListeners();
    _markChanged();
  }

  void _relayPlaybackChange() {
    playbackChanges.notifyListeners();
    _markChanged();
  }

  void _markChanged() {
    if (_transactionDepth > 0) {
      _notificationPending = true;
      return;
    }
    notifyListeners();
  }

  void _transaction(void Function() action) {
    _transactionDepth++;
    try {
      action();
    } finally {
      _transactionDepth--;
      if (_transactionDepth == 0 && _notificationPending) {
        _notificationPending = false;
        notifyListeners();
      }
    }
  }

  double snap(double beat) =>
      _snapBeats <= 0 ? beat : (beat / _snapBeats).round() * _snapBeats;

  void setSnap(double value) {
    if (_snapBeats == value) return;
    _snapBeats = math.max(0, value);
    viewChanges.notifyListeners();
    _markChanged();
  }

  void setZoom({double? horizontal, double? vertical}) {
    final nextHorizontal = (horizontal ?? _horizontalZoom)
        .clamp(.25, 16)
        .toDouble();
    final nextVertical = (vertical ?? _verticalZoom).clamp(.5, 4).toDouble();
    if (_horizontalZoom == nextHorizontal && _verticalZoom == nextVertical)
      return;
    _horizontalZoom = nextHorizontal;
    _verticalZoom = nextVertical;
    viewChanges.notifyListeners();
    _markChanged();
  }

  void setAutomationWriteMode(DawAutomationWriteMode value) {
    if (_automationWriteMode == value) return;
    _automationWriteMode = value;
    viewChanges.notifyListeners();
    _markChanged();
  }

  void setClipResizeMode(DawClipResizeMode value) {
    if (_clipResizeMode == value) return;
    _clipResizeMode = value;
    viewChanges.notifyListeners();
    _markChanged();
  }

  void selectTrack(String id, {bool clearClip = true}) {
    _selection = _selection.copyWith(
      trackId: id,
      clearClip: clearClip,
      clearNotes: true,
    );
    _notifySelectionChanged();
  }

  void selectClip(String trackId, String clipId) {
    _selection = DawSelection(trackId: trackId, clipId: clipId);
    _notifySelectionChanged();
  }

  void selectNotes(Set<String> ids) {
    _selection = _selection.copyWith(noteIds: Set.unmodifiable(ids));
    _notifySelectionChanged();
  }

  void selectAutomation(String trackId, String laneId, {String? pointId}) {
    _selection = DawSelection(
      trackId: trackId,
      automationLaneId: laneId,
      automationPointId: pointId,
    );
    _notifySelectionChanged();
  }

  void _notifySelectionChanged() {
    selectionChanges.notifyListeners();
    notifyListeners();
  }

  void commit(DawProject next) {
    if (identical(next, project)) return;
    _transaction(() {
      history.replace(next);
      playback.setRange(0, next.lengthBeats);
    });
  }

  void updateTrack(String trackId, DawTrack Function(DawTrack track) update) {
    if (trackId == project.master.id) {
      commit(project.copyWith(master: update(project.master)));
      return;
    }
    commit(
      project.copyWith(
        tracks: <DawTrack>[
          for (final track in project.tracks)
            if (track.id == trackId) update(track) else track,
        ],
      ),
    );
  }

  void addTrack(DawTrack track, {int? index}) {
    final tracks = List<DawTrack>.of(project.tracks);
    tracks.insert((index ?? tracks.length).clamp(0, tracks.length), track);
    commit(project.copyWith(tracks: tracks));
    selectTrack(track.id);
  }

  void removeTrack(String trackId) {
    final selectionCleared = _selection.trackId == trackId;
    if (selectionCleared) _selection = DawSelection();
    commit(
      project.copyWith(
        tracks: project.tracks.where((track) => track.id != trackId).toList(),
      ),
    );
    if (selectionCleared) selectionChanges.notifyListeners();
  }

  void addClip(String trackId, DawClip clip) {
    updateTrack(
      trackId,
      (track) => track.copyWith(clips: <DawClip>[...track.clips, clip]),
    );
    selectClip(trackId, clip.id);
  }

  void moveClip(String trackId, String clipId, double startBeat) {
    updateTrack(
      trackId,
      (track) => track.copyWith(
        clips: <DawClip>[
          for (final clip in track.clips)
            if (clip.id == clipId) clip.moveTo(snap(startBeat)) else clip,
        ],
      ),
    );
  }

  void resizeClip(String trackId, String clipId, double lengthBeats) {
    final nextLength = math.max(_snapBeats, snap(lengthBeats));
    updateTrack(
      trackId,
      (track) => track.copyWith(
        clips: <DawClip>[
          for (final clip in track.clips)
            if (clip.id == clipId)
              _clipResizeMode == DawClipResizeMode.stretch
                  ? _copyClip(
                      clip,
                      lengthBeats: nextLength,
                      playbackRate:
                          clip.playbackRate * clip.lengthBeats / nextLength,
                    )
                  : clip.resize(nextLength)
            else
              clip,
        ],
      ),
    );
  }

  void editClip(
    String trackId,
    String clipId, {
    double? startBeat,
    double? lengthBeats,
    double? offsetBeats,
    double? sourceTempo,
    double? playbackRate,
    bool? looped,
  }) {
    updateTrack(
      trackId,
      (track) => track.copyWith(
        clips: <DawClip>[
          for (final clip in track.clips)
            if (clip.id == clipId)
              _copyClip(
                clip,
                startBeat: startBeat == null ? null : snap(startBeat),
                lengthBeats: lengthBeats == null
                    ? null
                    : math.max(_snapBeats, snap(lengthBeats)),
                offsetBeats: offsetBeats == null
                    ? null
                    : math.max(0, offsetBeats),
                sourceTempo: sourceTempo,
                playbackRate: playbackRate,
                looped: looped,
              )
            else
              clip,
        ],
      ),
    );
  }

  DawClip _copyClip(
    DawClip clip, {
    double? startBeat,
    double? lengthBeats,
    double? offsetBeats,
    double? sourceTempo,
    double? playbackRate,
    bool? looped,
  }) => switch (clip) {
    DawMidiClip value => value.copyWith(
      startBeat: startBeat,
      lengthBeats: lengthBeats,
      offsetBeats: offsetBeats,
      sourceTempo: sourceTempo,
      playbackRate: playbackRate,
      looped: looped,
    ),
    DawAudioClip value => value.copyWith(
      startBeat: startBeat,
      lengthBeats: lengthBeats,
      offsetBeats: offsetBeats,
      sourceTempo: sourceTempo,
      playbackRate: playbackRate,
      looped: looped,
    ),
    _ => throw StateError('Unsupported clip type ${clip.runtimeType}'),
  };

  void duplicateSelectedClip() {
    final track = selectedTrack;
    final clip = selectedClip;
    if (track == null || clip == null) return;
    final id = '${clip.id}-copy-${_entitySerial++}';
    final copy = switch (clip) {
      DawMidiClip value => value.copyWith(
        id: id,
        name: '${value.name} Copy',
        startBeat: snap(value.endBeat),
      ),
      DawAudioClip value => value.copyWith(
        id: id,
        name: '${value.name} Copy',
        startBeat: snap(value.endBeat),
      ),
      _ => throw StateError('Unsupported clip type ${clip.runtimeType}'),
    };
    addClip(track.id, copy);
  }

  void splitSelectedClip([double? projectBeat]) {
    final track = selectedTrack;
    final clip = selectedClip;
    if (track == null || clip == null) return;
    final split = snap(projectBeat ?? playback.currentFrame) - clip.startBeat;
    if (split <= 0 || split >= clip.lengthBeats) return;
    final suffix = _entitySerial++;
    final left = _clipSegment(clip, clip.id, 0, split);
    final right = _clipSegment(
      clip,
      '${clip.id}-split-$suffix',
      split,
      clip.lengthBeats - split,
    );
    updateTrack(
      track.id,
      (value) => value.copyWith(
        clips: <DawClip>[
          for (final candidate in value.clips)
            if (candidate.id == clip.id) ...<DawClip>[left, right] else
              candidate,
        ],
      ),
    );
    selectClip(track.id, right.id);
  }

  DawClip _clipSegment(
    DawClip clip,
    String id,
    double localStart,
    double length,
  ) => switch (clip) {
    DawMidiClip value => value.copyWith(
      id: id,
      startBeat: value.startBeat + localStart,
      lengthBeats: length,
      offsetBeats: value.offsetBeats + localStart,
      notes: <DawMidiNote>[
        for (final note in value.notes)
          if (note.endBeat > localStart && note.startBeat < localStart + length)
            note.copyWith(
              startBeat: math.max(0, note.startBeat - localStart),
              lengthBeats:
                  math.min(note.endBeat, localStart + length) -
                  math.max(note.startBeat, localStart),
            ),
      ],
    ),
    DawAudioClip value => value.copyWith(
      id: id,
      startBeat: value.startBeat + localStart,
      lengthBeats: length,
      offsetBeats: value.offsetBeats + localStart,
    ),
    _ => throw StateError('Unsupported clip type ${clip.runtimeType}'),
  };

  void deleteSelection() {
    final trackId = _selection.trackId;
    if (trackId == null) return;
    if (_selection.noteIds.isNotEmpty) {
      final clipId = _selection.clipId;
      if (clipId == null) return;
      updateTrack(
        trackId,
        (track) => track.copyWith(
          clips: <DawClip>[
            for (final clip in track.clips)
              if (clip.id == clipId && clip is DawMidiClip)
                clip.copyWith(
                  notes: clip.notes
                      .where((note) => !_selection.noteIds.contains(note.id))
                      .toList(),
                )
              else
                clip,
          ],
        ),
      );
      _selection = _selection.copyWith(clearNotes: true);
      selectionChanges.notifyListeners();
      return;
    }
    final laneId = _selection.automationLaneId;
    final pointId = _selection.automationPointId;
    if (laneId != null && pointId != null) {
      updateTrack(
        trackId,
        (track) => track.copyWith(
          automation: <DawAutomationLane>[
            for (final lane in track.automation)
              if (lane.id == laneId)
                lane.copyWith(
                  points: lane.points
                      .where((point) => point.id != pointId)
                      .toList(),
                )
              else
                lane,
          ],
        ),
      );
      selectAutomation(trackId, laneId);
      return;
    }
    final clipId = _selection.clipId;
    if (clipId == null) return;
    updateTrack(
      trackId,
      (track) => track.copyWith(
        clips: track.clips.where((clip) => clip.id != clipId).toList(),
      ),
    );
    _selection = _selection.copyWith(clearClip: true);
    selectionChanges.notifyListeners();
  }

  void addMidiNote(String trackId, String clipId, DawMidiNote note) {
    updateTrack(trackId, (track) {
      return track.copyWith(
        clips: <DawClip>[
          for (final clip in track.clips)
            if (clip.id == clipId && clip is DawMidiClip)
              clip.copyWith(notes: <DawMidiNote>[...clip.notes, note])
            else
              clip,
        ],
      );
    });
  }

  void updateAudioClip(
    String clipId,
    DawAudioClip Function(DawAudioClip clip) update,
  ) {
    for (final track in project.tracks) {
      if (track.clips.any(
        (clip) => clip.id == clipId && clip is DawAudioClip,
      )) {
        updateTrack(
          track.id,
          (value) => value.copyWith(
            clips: <DawClip>[
              for (final clip in value.clips)
                if (clip.id == clipId && clip is DawAudioClip)
                  update(clip)
                else
                  clip,
            ],
          ),
        );
        return;
      }
    }
  }

  void normalizeAudioClip(String clipId) => updateAudioClip(clipId, (clip) {
    final peak = clip.waveform.peaks.fold<double>(
      0,
      (value, sample) => math.max(value, sample.abs()),
    );
    return clip.copyWith(gain: peak <= .000001 ? 1 : 1 / peak);
  });

  void toggleAudioClipReverse(String clipId) => updateAudioClip(
    clipId,
    (clip) => clip.copyWith(reversed: !clip.reversed),
  );

  void setAudioClipFades(
    String clipId, {
    double? fadeInBeats,
    double? fadeOutBeats,
  }) => updateAudioClip(
    clipId,
    (clip) =>
        clip.copyWith(fadeInBeats: fadeInBeats, fadeOutBeats: fadeOutBeats),
  );

  void moveMidiNote(
    String trackId,
    String clipId,
    String noteId, {
    required double startBeat,
    required int pitch,
  }) {
    updateTrack(trackId, (track) {
      return track.copyWith(
        clips: <DawClip>[
          for (final clip in track.clips)
            if (clip.id == clipId && clip is DawMidiClip)
              clip.copyWith(
                notes: <DawMidiNote>[
                  for (final note in clip.notes)
                    if (note.id == noteId)
                      note.copyWith(
                        startBeat: math.max(0, snap(startBeat)),
                        pitch: pitch.clamp(0, 127),
                      )
                    else
                      note,
                ],
              )
            else
              clip,
        ],
      );
    });
  }

  void resizeMidiNote(
    String trackId,
    String clipId,
    String noteId,
    double lengthBeats,
  ) => _updateMidiNote(
    trackId,
    clipId,
    noteId,
    (note) =>
        note.copyWith(lengthBeats: math.max(_snapBeats, snap(lengthBeats))),
  );

  void setMidiNoteVelocity(
    String trackId,
    String clipId,
    String noteId,
    double velocity,
  ) => _updateMidiNote(
    trackId,
    clipId,
    noteId,
    (note) => note.copyWith(velocity: velocity.clamp(0, 1)),
  );

  void _updateMidiNote(
    String trackId,
    String clipId,
    String noteId,
    DawMidiNote Function(DawMidiNote note) update,
  ) {
    updateTrack(
      trackId,
      (track) => track.copyWith(
        clips: <DawClip>[
          for (final clip in track.clips)
            if (clip.id == clipId && clip is DawMidiClip)
              clip.copyWith(
                notes: <DawMidiNote>[
                  for (final note in clip.notes)
                    if (note.id == noteId) update(note) else note,
                ],
              )
            else
              clip,
        ],
      ),
    );
  }

  void addAutomationPoint(
    String trackId,
    String laneId,
    DawAutomationPoint point,
  ) {
    updateTrack(
      trackId,
      (track) => track.copyWith(
        automation: <DawAutomationLane>[
          for (final lane in track.automation)
            if (lane.id == laneId)
              lane.copyWith(
                points: <DawAutomationPoint>[...lane.points, point]
                  ..sort((a, b) => a.beat.compareTo(b.beat)),
              )
            else
              lane,
        ],
      ),
    );
    selectAutomation(trackId, laneId, pointId: point.id);
  }

  void updateAutomationPoint(
    String trackId,
    String laneId,
    String pointId, {
    required double beat,
    required double value,
  }) {
    updateTrack(
      trackId,
      (track) => track.copyWith(
        automation: <DawAutomationLane>[
          for (final lane in track.automation)
            if (lane.id == laneId)
              lane.copyWith(
                points: <DawAutomationPoint>[
                  for (final point in lane.points)
                    if (point.id == pointId)
                      point.copyWith(
                        beat: math.max(0, snap(beat)),
                        value: value,
                      )
                    else
                      point,
                ]..sort((a, b) => a.beat.compareTo(b.beat)),
              )
            else
              lane,
        ],
      ),
    );
  }

  void setTrackVolume(String trackId, double value) =>
      updateTrack(trackId, (track) => track.copyWith(volume: value));
  void setTrackPan(String trackId, double value) =>
      updateTrack(trackId, (track) => track.copyWith(pan: value));
  void toggleTrackMute(String trackId) =>
      updateTrack(trackId, (track) => track.copyWith(muted: !track.muted));
  void toggleTrackSolo(String trackId) =>
      updateTrack(trackId, (track) => track.copyWith(solo: !track.solo));
  void toggleTrackArm(String trackId) =>
      updateTrack(trackId, (track) => track.copyWith(armed: !track.armed));
  void setTrackHeightScale(String trackId, double value) =>
      updateTrack(trackId, (track) => track.copyWith(heightScale: value));
  void toggleTrackAutomation(String trackId) => updateTrack(
    trackId,
    (track) => track.copyWith(automationExpanded: !track.automationExpanded),
  );

  void setLoop({required bool enabled, double? startBeat, double? endBeat}) {
    final start = math.max(0, startBeat ?? project.loopStartBeat).toDouble();
    final end = math.max(start + _snapBeats, endBeat ?? project.loopEndBeat);
    commit(
      project.copyWith(
        loopEnabled: enabled,
        loopStartBeat: snap(start),
        loopEndBeat: snap(end),
      ),
    );
  }

  void setTempo(double bpm, {double beat = 0}) {
    final point = DawTempoPoint(
      beat: math.max(0, beat),
      bpm: bpm.clamp(20, 400),
    );
    final points = <DawTempoPoint>[
      for (final candidate in project.tempoMap)
        if ((candidate.beat - point.beat).abs() > .0001) candidate,
      point,
    ]..sort((a, b) => a.beat.compareTo(b.beat));
    commit(project.copyWith(tempoMap: points));
  }

  void undo() => history.undo();
  void redo() => history.redo();

  DawTrack? _trackById(String? id) {
    if (id == null) return null;
    for (final track in project.tracks) {
      if (track.id == id) return track;
    }
    return null;
  }

  @override
  void dispose() {
    history.removeListener(_relayProjectChange);
    playback.removeListener(_relayPlaybackChange);
    projectChanges.dispose();
    selectionChanges.dispose();
    viewChanges.dispose();
    playbackChanges.dispose();
    if (_ownsHistory) history.dispose();
    if (_ownsPlayback) playback.dispose();
    super.dispose();
  }
}
