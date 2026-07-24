import 'dart:math' as math;

import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

import '../controllers/session_controller.dart';
import '../controllers/selection.dart';
import '../model/project.dart';
import 'clip_properties_bar.dart';
import 'editor_shared.dart';

part 'arrangement_painter.dart';

class DawArrangementEditor extends StatefulWidget {
  const DawArrangementEditor({
    super.key,
    required this.session,
    this.trackHeaderWidth = 190,
    this.baseTrackHeight = 54,
    this.basePixelsPerBeat = 24,
  });

  final DawSessionController session;
  final double trackHeaderWidth;
  final double baseTrackHeight;
  final double basePixelsPerBeat;

  @override
  State<DawArrangementEditor> createState() => _DawArrangementEditorState();
}

class _DawArrangementEditorState extends State<DawArrangementEditor> {
  static int _automationPointSerial = 1;
  String? _dragTrackId;
  String? _dragClipId;
  double _dragOffsetBeats = 0;
  double _dragClipStartBeat = 0;
  bool _resizingClip = false;
  String? _dragAutomationLaneId;
  String? _dragAutomationPointId;

  double get _baseTrackHeight =>
      widget.baseTrackHeight * widget.session.verticalZoom;
  double get _automationLaneHeight => 42 * widget.session.verticalZoom;
  double get _pixelsPerBeat =>
      widget.basePixelsPerBeat * widget.session.horizontalZoom;

  double _mainTrackHeight(DawTrack track) =>
      _baseTrackHeight * track.heightScale;

  double _trackBlockHeight(DawTrack track) =>
      _mainTrackHeight(track) +
      (track.automationExpanded
          ? track.automation.length * _automationLaneHeight
          : 0);

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.session,
    builder: (context, _) {
      final project = widget.session.project;
      return BlenderEditorFrame(
        child: Column(
          children: <Widget>[
            DawEditorHeader(
              title: 'Arrangement',
              menus: const <String>['View', 'Select', 'Add', 'Pattern'],
              actions: <Widget>[
                BlenderDropdown<double>(
                  value: widget.session.snapBeats,
                  compact: true,
                  selectedLabel: 'Snap',
                  items: const <BlenderMenuItem<double>>[
                    BlenderMenuItem(value: 1, label: 'Beat'),
                    BlenderMenuItem(value: .5, label: '1/2 Beat'),
                    BlenderMenuItem(value: .25, label: '1/4 Beat'),
                    BlenderMenuItem(value: .125, label: '1/8 Beat'),
                  ],
                  onChanged: widget.session.setSnap,
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.split,
                  tooltip: 'Split Clip at Playhead',
                  onPressed: widget.session.selection.clipId == null
                      ? null
                      : widget.session.splitSelectedClip,
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.duplicate,
                  tooltip: 'Duplicate Clip',
                  onPressed: widget.session.selection.clipId == null
                      ? null
                      : widget.session.duplicateSelectedClip,
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.minus,
                  tooltip: 'Zoom Out',
                  onPressed: () => widget.session.setZoom(
                    horizontal: widget.session.horizontalZoom / 1.25,
                  ),
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.plus,
                  tooltip: 'Zoom In',
                  onPressed: () => widget.session.setZoom(
                    horizontal: widget.session.horizontalZoom * 1.25,
                  ),
                ),
              ],
            ),
            DawClipPropertiesBar(session: widget.session),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final viewportWidth = math.max(
                    1.0,
                    constraints.maxWidth - widget.trackHeaderWidth,
                  );
                  final contentWidth = math.max(
                    viewportWidth,
                    project.lengthBeats * _pixelsPerBeat,
                  );
                  final height =
                      28 +
                      project.tracks.fold<double>(
                        0,
                        (height, track) => height + _trackBlockHeight(track),
                      );
                  return SingleChildScrollView(
                    child: SizedBox(
                      height: height,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: widget.trackHeaderWidth,
                            child: _buildTrackHeaders(project),
                          ),
                          SizedBox(
                            width: viewportWidth,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapDown: (details) =>
                                    _handleTap(details.localPosition, project),
                                onDoubleTapDown: (details) => _handleDoubleTap(
                                  details.localPosition,
                                  project,
                                ),
                                onPanStart: (details) =>
                                    _beginDrag(details.localPosition, project),
                                onPanUpdate: (details) =>
                                    _updateDrag(details.localPosition),
                                onPanEnd: (_) => _endDrag(),
                                child: SizedBox(
                                  key: const ValueKey<String>(
                                    'daw-arrangement-canvas',
                                  ),
                                  width: contentWidth,
                                  height: height,
                                  child: CustomPaint(
                                    painter: _DawArrangementPainter(
                                      project: project,
                                      selection: widget.session.selection,
                                      playhead:
                                          widget.session.playback.currentFrame,
                                      pixelsPerBeat: _pixelsPerBeat,
                                      baseTrackHeight: _baseTrackHeight,
                                      automationLaneHeight:
                                          _automationLaneHeight,
                                      colors: BlenderTheme.of(context).colors,
                                      textTheme: BlenderTheme.of(
                                        context,
                                      ).textTheme,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );

  Widget _buildTrackHeaders(DawProject project) {
    final theme = BlenderTheme.of(context);
    return Column(
      children: <Widget>[
        Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          alignment: Alignment.centerLeft,
          color: theme.colors.panelHeader,
          child: Text('Tracks', style: theme.textTheme.caption),
        ),
        for (final track in project.tracks) _buildTrackHeaderBlock(track),
      ],
    );
  }

  Widget _buildTrackHeaderBlock(DawTrack track) {
    final theme = BlenderTheme.of(context);
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.session.selectTrack(track.id),
              child: Container(
                height: _mainTrackHeight(track),
                padding: const EdgeInsets.symmetric(horizontal: 7),
                decoration: BoxDecoration(
                  color: widget.session.selection.trackId == track.id
                      ? theme.colors.selection
                      : theme.colors.panelBackground,
                  border: Border(
                    bottom: BorderSide(color: theme.colors.borderSubtle),
                    right: BorderSide(color: theme.colors.border),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Container(width: 4, color: Color(track.colorValue)),
                    const SizedBox(width: 5),
                    if (track.automation.isNotEmpty)
                      BlenderIconButton(
                        glyph: track.automationExpanded
                            ? BlenderGlyph.chevronDown
                            : BlenderGlyph.chevronRight,
                        tooltip: 'Show Automation',
                        size: 20,
                        onPressed: () =>
                            widget.session.toggleTrackAutomation(track.id),
                      ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            track.name,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.label,
                          ),
                          Text(
                            track.type.name.toUpperCase(),
                            style: theme.textTheme.caption.copyWith(
                              color: theme.colors.foregroundMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _trackToggle(
                      'M',
                      track.muted,
                      () => widget.session.toggleTrackMute(track.id),
                    ),
                    _trackToggle(
                      'S',
                      track.solo,
                      () => widget.session.toggleTrackSolo(track.id),
                    ),
                    _trackToggle(
                      'R',
                      track.armed,
                      () => widget.session.toggleTrackArm(track.id),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 6,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeRow,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (details) =>
                      widget.session.setTrackHeightScale(
                        track.id,
                        track.heightScale + details.delta.dy / _baseTrackHeight,
                      ),
                ),
              ),
            ),
          ],
        ),
        if (track.automationExpanded)
          for (final lane in track.automation)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.session.selectAutomation(track.id, lane.id),
              child: Container(
                height: _automationLaneHeight,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: widget.session.selection.automationLaneId == lane.id
                      ? theme.colors.selection
                      : theme.colors.surface,
                  border: Border(
                    right: BorderSide(color: theme.colors.border),
                    bottom: BorderSide(color: theme.colors.borderSubtle),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 5,
                      height: 20,
                      color: Color(lane.colorValue),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        lane.name,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.caption,
                      ),
                    ),
                    BlenderCheckbox(
                      value: lane.enabled,
                      onChanged: (value) => widget.session.updateTrack(
                        track.id,
                        (track) => track.copyWith(
                          automation: <DawAutomationLane>[
                            for (final item in track.automation)
                              if (item.id == lane.id)
                                item.copyWith(enabled: value)
                              else
                                item,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _trackToggle(String label, bool selected, VoidCallback onPressed) =>
      BlenderButton(
        label: label,
        width: 22,
        selected: selected,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      );

  ({DawTrack track, DawClip clip})? _hitClip(
    Offset position,
    DawProject project,
  ) {
    if (position.dy < 28) return null;
    var y = 28.0;
    DawTrack? track;
    for (final candidate in project.tracks) {
      final mainHeight = _mainTrackHeight(candidate);
      if (position.dy >= y && position.dy < y + mainHeight) {
        track = candidate;
        break;
      }
      y += _trackBlockHeight(candidate);
    }
    if (track == null) return null;
    final beat = dawBeatForX(position.dx, _pixelsPerBeat);
    for (final clip in track.clips.reversed) {
      if (beat >= clip.startBeat && beat <= clip.endBeat) {
        return (track: track, clip: clip);
      }
    }
    return null;
  }

  void _handleTap(Offset position, DawProject project) {
    final automation = _hitAutomation(position, project);
    if (automation != null) {
      widget.session.selectAutomation(
        automation.track.id,
        automation.lane.id,
        pointId: automation.point?.id,
      );
      return;
    }
    final hit = _hitClip(position, project);
    if (hit != null) {
      widget.session.selectClip(hit.track.id, hit.clip.id);
    } else {
      widget.session.playback.seek(dawBeatForX(position.dx, _pixelsPerBeat));
    }
  }

  void _handleDoubleTap(Offset position, DawProject project) {
    final automation = _hitAutomation(position, project);
    if (automation == null) return;
    widget.session.addAutomationPoint(
      automation.track.id,
      automation.lane.id,
      DawAutomationPoint(
        id: 'arrangement-point-${_automationPointSerial++}',
        beat: widget.session.snap(dawBeatForX(position.dx, _pixelsPerBeat)),
        value: automation.value,
      ),
    );
  }

  void _beginDrag(Offset position, DawProject project) {
    final automation = _hitAutomation(position, project);
    if (automation?.point != null) {
      _dragTrackId = automation!.track.id;
      _dragAutomationLaneId = automation.lane.id;
      _dragAutomationPointId = automation.point!.id;
      widget.session.selectAutomation(
        automation.track.id,
        automation.lane.id,
        pointId: automation.point!.id,
      );
      return;
    }
    final hit = _hitClip(position, project);
    if (hit == null) return;
    _dragTrackId = hit.track.id;
    _dragClipId = hit.clip.id;
    _dragClipStartBeat = hit.clip.startBeat;
    final rightEdge = hit.clip.endBeat * _pixelsPerBeat;
    _resizingClip = (rightEdge - position.dx).abs() <= 7;
    _dragOffsetBeats =
        dawBeatForX(position.dx, _pixelsPerBeat) - hit.clip.startBeat;
    widget.session.selectClip(hit.track.id, hit.clip.id);
  }

  void _updateDrag(Offset position) {
    final automationPointId = _dragAutomationPointId;
    final automationLaneId = _dragAutomationLaneId;
    final automationTrackId = _dragTrackId;
    if (automationPointId != null &&
        automationLaneId != null &&
        automationTrackId != null) {
      final lane = _automationLaneAt(position, widget.session.project);
      widget.session.updateAutomationPoint(
        automationTrackId,
        automationLaneId,
        automationPointId,
        beat: dawBeatForX(position.dx, _pixelsPerBeat),
        value: lane?.value ?? .5,
      );
      return;
    }
    final trackId = _dragTrackId;
    final clipId = _dragClipId;
    if (trackId == null || clipId == null) return;
    if (_resizingClip) {
      widget.session.resizeClip(
        trackId,
        clipId,
        dawBeatForX(position.dx, _pixelsPerBeat) - _dragClipStartBeat,
      );
    } else {
      widget.session.moveClip(
        trackId,
        clipId,
        dawBeatForX(position.dx, _pixelsPerBeat) - _dragOffsetBeats,
      );
    }
  }

  void _endDrag() {
    _dragTrackId = null;
    _dragClipId = null;
    _resizingClip = false;
    _dragAutomationLaneId = null;
    _dragAutomationPointId = null;
  }

  ({DawTrack track, DawAutomationLane lane, double value})? _automationLaneAt(
    Offset position,
    DawProject project,
  ) {
    var y = 28.0;
    for (final track in project.tracks) {
      y += _mainTrackHeight(track);
      if (track.automationExpanded) {
        for (final lane in track.automation) {
          if (position.dy >= y && position.dy < y + _automationLaneHeight) {
            return (
              track: track,
              lane: lane,
              value:
                  1 - ((position.dy - y) / _automationLaneHeight).clamp(0, 1),
            );
          }
          y += _automationLaneHeight;
        }
      }
    }
    return null;
  }

  ({
    DawTrack track,
    DawAutomationLane lane,
    DawAutomationPoint? point,
    double value,
  })?
  _hitAutomation(Offset position, DawProject project) {
    final laneHit = _automationLaneAt(position, project);
    if (laneHit == null) return null;
    DawAutomationPoint? point;
    var distance = 10.0;
    for (final candidate in laneHit.lane.points) {
      final candidateDistance = (candidate.beat * _pixelsPerBeat - position.dx)
          .abs();
      if (candidateDistance < distance) {
        point = candidate;
        distance = candidateDistance;
      }
    }
    return (
      track: laneHit.track,
      lane: laneHit.lane,
      point: point,
      value: laneHit.value,
    );
  }
}
