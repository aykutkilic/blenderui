import 'dart:math' as math;

import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

import '../controllers/session_controller.dart';
import '../model/midi_scale.dart';
import '../model/project.dart';
import 'editor_shared.dart';

class DawPianoRollEditor extends StatefulWidget {
  const DawPianoRollEditor({
    super.key,
    required this.session,
    this.trackId,
    this.clipId,
    this.lowestPitch = 36,
    this.highestPitch = 84,
    this.basePixelsPerBeat = 42,
    this.baseRowHeight = 13,
  });

  final DawSessionController session;
  final String? trackId;
  final String? clipId;
  final int lowestPitch;
  final int highestPitch;
  final double basePixelsPerBeat;
  final double baseRowHeight;

  @override
  State<DawPianoRollEditor> createState() => _DawPianoRollEditorState();
}

class _DawPianoRollEditorState extends State<DawPianoRollEditor> {
  static int _noteSerial = 1;
  String? _dragNoteId;
  double _dragBeatOffset = 0;
  int _dragPitchOffset = 0;
  double _dragNoteStartBeat = 0;
  bool _resizingNote = false;
  DawMidiScaleFilter _scaleFilter = const DawMidiScaleFilter();

  double get _pixelsPerBeat =>
      widget.basePixelsPerBeat * widget.session.horizontalZoom;
  double get _rowHeight => widget.baseRowHeight * widget.session.verticalZoom;

  ({DawTrack track, DawMidiClip clip})? get _target {
    final trackId = widget.trackId ?? widget.session.selection.trackId;
    final clipId = widget.clipId ?? widget.session.selection.clipId;
    for (final track in widget.session.project.tracks) {
      if (trackId != null && track.id != trackId) continue;
      for (final clip in track.clips) {
        if (clip is DawMidiClip && (clipId == null || clip.id == clipId)) {
          return (track: track, clip: clip);
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.session,
    builder: (context, _) {
      final target = _target;
      return BlenderEditorFrame(
        child: Column(
          children: <Widget>[
            DawEditorHeader(
              title: 'Piano Roll',
              menus: const <String>['View', 'Select', 'Note', 'Scale'],
              actions: <Widget>[
                BlenderButton(
                  label: target?.clip.name ?? 'No MIDI Clip',
                  enabled: target != null,
                  onPressed: null,
                ),
                SizedBox(
                  width: 52,
                  child: BlenderDropdown<int>(
                    value: _scaleFilter.rootPitchClass,
                    items: <BlenderMenuItem<int>>[
                      for (var pitchClass = 0; pitchClass < 12; pitchClass++)
                        BlenderMenuItem<int>(
                          value: pitchClass,
                          label: DawMidiScaleFilter.pitchClassNames[pitchClass],
                        ),
                    ],
                    onChanged: (value) => setState(() {
                      _scaleFilter = _scaleFilter.copyWith(
                        rootPitchClass: value,
                      );
                    }),
                  ),
                ),
                SizedBox(
                  width: 136,
                  child: BlenderDropdown<DawScaleKind>(
                    value: _scaleFilter.scale,
                    items: <BlenderMenuItem<DawScaleKind>>[
                      for (final scale in DawScaleKind.values)
                        BlenderMenuItem<DawScaleKind>(
                          value: scale,
                          label: scale.label,
                        ),
                    ],
                    onChanged: (value) => setState(() {
                      _scaleFilter = _scaleFilter.copyWith(scale: value);
                    }),
                  ),
                ),
                BlenderCheckbox(
                  value: _scaleFilter.enabled,
                  label: 'Scale Filter',
                  onChanged: (value) => setState(() {
                    _scaleFilter = _scaleFilter.copyWith(enabled: value);
                  }),
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.minus,
                  onPressed: () => widget.session.setZoom(
                    horizontal: widget.session.horizontalZoom / 1.2,
                  ),
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.plus,
                  onPressed: () => widget.session.setZoom(
                    horizontal: widget.session.horizontalZoom * 1.2,
                  ),
                ),
              ],
            ),
            Expanded(
              child: target == null
                  ? const Center(
                      child: Text('Select a MIDI clip in Arrangement'),
                    )
                  : _buildEditor(target),
            ),
          ],
        ),
      );
    },
  );

  Widget _buildEditor(({DawTrack track, DawMidiClip clip}) target) {
    const keyboardWidth = 68.0;
    const rulerHeight = 24.0;
    const velocityHeight = 72.0;
    final noteHeight =
        (widget.highestPitch - widget.lowestPitch + 1) * _rowHeight;
    final contentWidth = math.max(
      900.0,
      target.clip.lengthBeats * _pixelsPerBeat,
    );
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: SizedBox(
          height: rulerHeight + noteHeight + velocityHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: keyboardWidth,
                height: rulerHeight + noteHeight,
                child: CustomPaint(
                  painter: _DawPianoKeyboardPainter(
                    lowestPitch: widget.lowestPitch,
                    highestPitch: widget.highestPitch,
                    rowHeight: _rowHeight,
                    rulerHeight: rulerHeight,
                    colors: BlenderTheme.of(context).colors,
                    textTheme: BlenderTheme.of(context).textTheme,
                    scaleFilter: _scaleFilter,
                  ),
                ),
              ),
              SizedBox(
                width: math.max(1, constraints.maxWidth - keyboardWidth),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onDoubleTapDown: (details) =>
                        _addNote(details.localPosition, target),
                    onTapDown: (details) =>
                        _selectNote(details.localPosition, target),
                    onPanStart: (details) =>
                        _beginNoteDrag(details.localPosition, target),
                    onPanUpdate: (details) =>
                        _updateNoteDrag(details.localPosition, target),
                    onPanEnd: (_) {
                      _dragNoteId = null;
                      _resizingNote = false;
                    },
                    child: SizedBox(
                      key: const ValueKey<String>('daw-piano-roll-canvas'),
                      width: contentWidth,
                      height: rulerHeight + noteHeight + velocityHeight,
                      child: CustomPaint(
                        painter: _DawPianoRollPainter(
                          clip: target.clip,
                          selectedNoteIds: widget.session.selection.noteIds,
                          lowestPitch: widget.lowestPitch,
                          highestPitch: widget.highestPitch,
                          rowHeight: _rowHeight,
                          rulerHeight: rulerHeight,
                          velocityHeight: velocityHeight,
                          pixelsPerBeat: _pixelsPerBeat,
                          playhead:
                              widget.session.playback.currentFrame -
                              target.clip.startBeat,
                          colors: BlenderTheme.of(context).colors,
                          textTheme: BlenderTheme.of(context).textTheme,
                          scaleFilter: _scaleFilter,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DawMidiNote? _hitNote(
    Offset position,
    DawMidiClip clip, {
    double rulerHeight = 24,
  }) {
    if (position.dy < rulerHeight) return null;
    final pitch =
        widget.highestPitch -
        ((position.dy - rulerHeight) / _rowHeight).floor();
    final beat = dawBeatForX(position.dx, _pixelsPerBeat);
    for (final note in clip.notes.reversed) {
      if (!_scaleFilter.contains(note.pitch)) continue;
      if (note.pitch == pitch && beat >= note.startBeat && beat <= note.endBeat)
        return note;
    }
    return null;
  }

  void _selectNote(
    Offset position,
    ({DawTrack track, DawMidiClip clip}) target,
  ) {
    final note = _hitNote(position, target.clip);
    widget.session.selectNotes(
      note == null ? const <String>{} : <String>{note.id},
    );
  }

  void _addNote(Offset position, ({DawTrack track, DawMidiClip clip}) target) {
    final beat = widget.session.snap(dawBeatForX(position.dx, _pixelsPerBeat));
    final rawPitch =
        (widget.highestPitch - ((position.dy - 24) / _rowHeight).floor()).clamp(
          0,
          127,
        );
    final pitch = _scaleFilter.snapPitch(rawPitch);
    final note = DawMidiNote(
      id: 'note-${_noteSerial++}',
      pitch: pitch,
      startBeat: beat,
      lengthBeats: math.max(widget.session.snapBeats, .25),
    );
    widget.session.addMidiNote(target.track.id, target.clip.id, note);
    widget.session.selectNotes(<String>{note.id});
  }

  void _beginNoteDrag(
    Offset position,
    ({DawTrack track, DawMidiClip clip}) target,
  ) {
    final note = _hitNote(position, target.clip);
    if (note == null) return;
    _dragNoteId = note.id;
    _dragNoteStartBeat = note.startBeat;
    _resizingNote = (note.endBeat * _pixelsPerBeat - position.dx).abs() <= 6;
    _dragBeatOffset = dawBeatForX(position.dx, _pixelsPerBeat) - note.startBeat;
    final pointerPitch =
        widget.highestPitch - ((position.dy - 24) / _rowHeight).floor();
    _dragPitchOffset = pointerPitch - note.pitch;
    widget.session.selectNotes(<String>{note.id});
  }

  void _updateNoteDrag(
    Offset position,
    ({DawTrack track, DawMidiClip clip}) target,
  ) {
    final noteId = _dragNoteId;
    if (noteId == null) return;
    if (_resizingNote) {
      widget.session.resizeMidiNote(
        target.track.id,
        target.clip.id,
        noteId,
        dawBeatForX(position.dx, _pixelsPerBeat) - _dragNoteStartBeat,
      );
      return;
    }
    final pointerPitch =
        widget.highestPitch - ((position.dy - 24) / _rowHeight).floor();
    widget.session.moveMidiNote(
      target.track.id,
      target.clip.id,
      noteId,
      startBeat: dawBeatForX(position.dx, _pixelsPerBeat) - _dragBeatOffset,
      pitch: _scaleFilter.snapPitch(pointerPitch - _dragPitchOffset),
    );
  }
}

class _DawPianoKeyboardPainter extends CustomPainter {
  const _DawPianoKeyboardPainter({
    required this.lowestPitch,
    required this.highestPitch,
    required this.rowHeight,
    required this.rulerHeight,
    required this.colors,
    required this.textTheme,
    required this.scaleFilter,
  });

  final int lowestPitch;
  final int highestPitch;
  final double rowHeight;
  final double rulerHeight;
  final BlenderColorScheme colors;
  final BlenderTextTheme textTheme;
  final DawMidiScaleFilter scaleFilter;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = colors.panelBackground,
    );
    for (var pitch = highestPitch; pitch >= lowestPitch; pitch--) {
      final index = highestPitch - pitch;
      final y = rulerHeight + index * rowHeight;
      final black = const <int>{1, 3, 6, 8, 10}.contains(pitch % 12);
      canvas.drawRect(
        Rect.fromLTWH(0, y, black ? size.width * .65 : size.width, rowHeight),
        Paint()
          ..color = black ? const Color(0xFF181818) : const Color(0xFFD2D2D2),
      );
      if (!scaleFilter.contains(pitch)) {
        canvas.drawRect(
          Rect.fromLTWH(0, y, size.width, rowHeight),
          Paint()..color = const Color(0x66000000),
        );
      }
      canvas.drawLine(
        Offset(0, y + rowHeight),
        Offset(size.width, y + rowHeight),
        Paint()..color = colors.border,
      );
      if (pitch % 12 == 0) {
        final label = TextPainter(
          text: TextSpan(
            text: 'C${pitch ~/ 12 - 1}',
            style: textTheme.caption.copyWith(color: const Color(0xFF222222)),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        label.paint(canvas, Offset(size.width - label.width - 4, y + 1));
      }
    }
  }

  @override
  bool shouldRepaint(_DawPianoKeyboardPainter oldDelegate) =>
      rowHeight != oldDelegate.rowHeight ||
      scaleFilter != oldDelegate.scaleFilter ||
      colors != oldDelegate.colors;
}

class _DawPianoRollPainter extends CustomPainter {
  const _DawPianoRollPainter({
    required this.clip,
    required this.selectedNoteIds,
    required this.lowestPitch,
    required this.highestPitch,
    required this.rowHeight,
    required this.rulerHeight,
    required this.velocityHeight,
    required this.pixelsPerBeat,
    required this.playhead,
    required this.colors,
    required this.textTheme,
    required this.scaleFilter,
  });

  final DawMidiClip clip;
  final Set<String> selectedNoteIds;
  final int lowestPitch;
  final int highestPitch;
  final double rowHeight;
  final double rulerHeight;
  final double velocityHeight;
  final double pixelsPerBeat;
  final double playhead;
  final BlenderColorScheme colors;
  final BlenderTextTheme textTheme;
  final DawMidiScaleFilter scaleFilter;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.canvas);
    final noteBottom = size.height - velocityHeight;
    for (var pitch = highestPitch; pitch >= lowestPitch; pitch--) {
      final y = rulerHeight + (highestPitch - pitch) * rowHeight;
      if (const <int>{1, 3, 6, 8, 10}.contains(pitch % 12)) {
        canvas.drawRect(
          Rect.fromLTWH(0, y, size.width, rowHeight),
          Paint()..color = colors.surface.withValues(alpha: .55),
        );
      }
      if (!scaleFilter.contains(pitch)) {
        canvas.drawRect(
          Rect.fromLTWH(0, y, size.width, rowHeight),
          Paint()..color = colors.canvas.withValues(alpha: .72),
        );
      }
      canvas.drawLine(
        Offset(0, y + rowHeight),
        Offset(size.width, y + rowHeight),
        Paint()..color = colors.borderSubtle.withValues(alpha: .45),
      );
    }
    paintDawTimeGrid(
      canvas,
      Size(size.width, noteBottom),
      pixelsPerBeat: pixelsPerBeat,
      beatsPerBar: 4,
      colors: colors,
      startY: rulerHeight,
      subdivision: .25,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, rulerHeight),
      Paint()..color = colors.panelHeader,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, noteBottom, size.width, velocityHeight),
      Paint()..color = colors.panelBackground,
    );
    for (final note in clip.notes) {
      if (note.pitch < lowestPitch || note.pitch > highestPitch) continue;
      if (!scaleFilter.contains(note.pitch)) continue;
      final rect = Rect.fromLTWH(
        note.startBeat * pixelsPerBeat + 1,
        rulerHeight + (highestPitch - note.pitch) * rowHeight + 1,
        math.max(3, note.lengthBeats * pixelsPerBeat - 2),
        rowHeight - 2,
      );
      final selected = selectedNoteIds.contains(note.id);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        Paint()..color = selected ? colors.accent : Color(clip.colorValue),
      );
      canvas.drawRect(
        Rect.fromLTWH(
          note.startBeat * pixelsPerBeat + 2,
          size.height - 4 - velocityHeight * note.velocity,
          math.max(2, note.lengthBeats * pixelsPerBeat - 4),
          velocityHeight * note.velocity,
        ),
        Paint()..color = selected ? colors.accent : Color(clip.colorValue),
      );
    }
    paintDawPlayhead(
      canvas,
      size,
      beat: playhead,
      pixelsPerBeat: pixelsPerBeat,
      color: colors.cursor,
    );
  }

  @override
  bool shouldRepaint(_DawPianoRollPainter oldDelegate) =>
      clip != oldDelegate.clip ||
      selectedNoteIds != oldDelegate.selectedNoteIds ||
      rowHeight != oldDelegate.rowHeight ||
      pixelsPerBeat != oldDelegate.pixelsPerBeat ||
      playhead != oldDelegate.playhead ||
      scaleFilter != oldDelegate.scaleFilter ||
      colors != oldDelegate.colors;
}
