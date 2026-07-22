import 'dart:math' as math;

import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

import '../controllers/session_controller.dart';
import '../model/project.dart';
import 'editor_shared.dart';

class DawAutomationEditor extends StatefulWidget {
  const DawAutomationEditor({
    super.key,
    required this.session,
    this.trackId,
    this.laneId,
    this.basePixelsPerBeat = 28,
  });

  final DawSessionController session;
  final String? trackId;
  final String? laneId;
  final double basePixelsPerBeat;

  @override
  State<DawAutomationEditor> createState() => _DawAutomationEditorState();
}

class _DawAutomationEditorState extends State<DawAutomationEditor> {
  static int _pointSerial = 1;
  String? _dragPointId;

  ({DawTrack track, DawAutomationLane lane})? get _target {
    final trackId = widget.trackId ?? widget.session.selection.trackId;
    final laneId = widget.laneId ?? widget.session.selection.automationLaneId;
    for (final track in widget.session.project.tracks) {
      if (trackId != null && track.id != trackId) continue;
      for (final lane in track.automation) {
        if (laneId == null || lane.id == laneId)
          return (track: track, lane: lane);
      }
    }
    return null;
  }

  double get _pixelsPerBeat =>
      widget.basePixelsPerBeat * widget.session.horizontalZoom;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.session,
    builder: (context, _) {
      final target = _target;
      return BlenderEditorFrame(
        child: Column(
          children: <Widget>[
            DawEditorHeader(
              title: 'Automation',
              menus: const <String>['View', 'Select', 'Point', 'Curve'],
              actions: <Widget>[
                BlenderButton(
                  label: target?.lane.name ?? 'No Automation Lane',
                  enabled: target != null,
                  onPressed: null,
                ),
                for (final mode in DawAutomationWriteMode.values)
                  BlenderButton(
                    label: _modeLabel(mode),
                    selected: widget.session.automationWriteMode == mode,
                    onPressed: () =>
                        widget.session.setAutomationWriteMode(mode),
                  ),
              ],
            ),
            Expanded(
              child: target == null
                  ? const Center(child: Text('Select a track with automation'))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final width = math.max(
                          constraints.maxWidth,
                          widget.session.project.lengthBeats * _pixelsPerBeat,
                        );
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: GestureDetector(
                            key: const ValueKey<String>(
                              'daw-automation-canvas',
                            ),
                            behavior: HitTestBehavior.opaque,
                            onDoubleTapDown: (details) => _addPoint(
                              details.localPosition,
                              constraints.maxHeight,
                              target,
                            ),
                            onTapDown: (details) => _selectPoint(
                              details.localPosition,
                              constraints.maxHeight,
                              target,
                            ),
                            onPanStart: (details) => _beginDrag(
                              details.localPosition,
                              constraints.maxHeight,
                              target,
                            ),
                            onPanUpdate: (details) => _updateDrag(
                              details.localPosition,
                              constraints.maxHeight,
                              target,
                            ),
                            onPanEnd: (_) => _dragPointId = null,
                            child: SizedBox(
                              width: width,
                              height: constraints.maxHeight,
                              child: CustomPaint(
                                painter: _DawAutomationPainter(
                                  project: widget.session.project,
                                  lane: target.lane,
                                  selectedPointId: widget
                                      .session
                                      .selection
                                      .automationPointId,
                                  playhead:
                                      widget.session.playback.currentFrame,
                                  pixelsPerBeat: _pixelsPerBeat,
                                  colors: BlenderTheme.of(context).colors,
                                  textTheme: BlenderTheme.of(context).textTheme,
                                ),
                              ),
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

  DawAutomationPoint? _hitPoint(
    Offset position,
    double height,
    DawAutomationLane lane,
  ) {
    for (final point in lane.points) {
      final center = Offset(
        point.beat * _pixelsPerBeat,
        24 + (1 - point.value) * math.max(1, height - 24),
      );
      if ((center - position).distance <= 9) return point;
    }
    return null;
  }

  String _modeLabel(DawAutomationWriteMode mode) => switch (mode) {
    DawAutomationWriteMode.read => 'Read',
    DawAutomationWriteMode.write => 'Write',
    DawAutomationWriteMode.touch => 'Touch',
    DawAutomationWriteMode.latch => 'Latch',
  };

  void _addPoint(
    Offset position,
    double height,
    ({DawTrack track, DawAutomationLane lane}) target,
  ) {
    widget.session.addAutomationPoint(
      target.track.id,
      target.lane.id,
      DawAutomationPoint(
        id: 'automation-point-${_pointSerial++}',
        beat: widget.session.snap(dawBeatForX(position.dx, _pixelsPerBeat)),
        value: 1 - ((position.dy - 24) / math.max(1, height - 24)).clamp(0, 1),
      ),
    );
  }

  void _selectPoint(
    Offset position,
    double height,
    ({DawTrack track, DawAutomationLane lane}) target,
  ) {
    final point = _hitPoint(position, height, target.lane);
    widget.session.selectAutomation(
      target.track.id,
      target.lane.id,
      pointId: point?.id,
    );
  }

  void _beginDrag(
    Offset position,
    double height,
    ({DawTrack track, DawAutomationLane lane}) target,
  ) {
    final point = _hitPoint(position, height, target.lane);
    _dragPointId = point?.id;
    if (point != null) {
      widget.session.selectAutomation(
        target.track.id,
        target.lane.id,
        pointId: point.id,
      );
    }
  }

  void _updateDrag(
    Offset position,
    double height,
    ({DawTrack track, DawAutomationLane lane}) target,
  ) {
    final pointId = _dragPointId;
    if (pointId == null) return;
    widget.session.updateAutomationPoint(
      target.track.id,
      target.lane.id,
      pointId,
      beat: dawBeatForX(position.dx, _pixelsPerBeat),
      value: 1 - ((position.dy - 24) / math.max(1, height - 24)).clamp(0, 1),
    );
  }
}

class _DawAutomationPainter extends CustomPainter {
  const _DawAutomationPainter({
    required this.project,
    required this.lane,
    required this.selectedPointId,
    required this.playhead,
    required this.pixelsPerBeat,
    required this.colors,
    required this.textTheme,
  });

  final DawProject project;
  final DawAutomationLane lane;
  final String? selectedPointId;
  final double playhead;
  final double pixelsPerBeat;
  final BlenderColorScheme colors;
  final BlenderTextTheme textTheme;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.canvas);
    paintDawTimeGrid(
      canvas,
      size,
      pixelsPerBeat: pixelsPerBeat,
      beatsPerBar: project.timeSignature.numerator,
      colors: colors,
      startY: 24,
    );
    for (var i = 0; i <= 4; i++) {
      final y = 24 + (size.height - 24) * i / 4;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()..color = colors.borderSubtle.withValues(alpha: .5),
      );
    }
    final sorted = List<DawAutomationPoint>.of(lane.points)
      ..sort((a, b) => a.beat.compareTo(b.beat));
    final path = Path();
    for (var index = 0; index < sorted.length; index++) {
      final point = sorted[index];
      final offset = Offset(
        point.beat * pixelsPerBeat,
        24 + (1 - point.value) * (size.height - 24),
      );
      if (index == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else if (point.interpolation == DawAutomationInterpolation.hold) {
        final previous = sorted[index - 1];
        path.lineTo(offset.dx, 24 + (1 - previous.value) * (size.height - 24));
        path.lineTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    final color = Color(lane.colorValue);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    for (final point in sorted) {
      final offset = Offset(
        point.beat * pixelsPerBeat,
        24 + (1 - point.value) * (size.height - 24),
      );
      canvas.drawCircle(
        offset,
        point.id == selectedPointId ? 6 : 4,
        Paint()
          ..color = point.id == selectedPointId ? colors.foreground : color,
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, 24),
      Paint()..color = colors.panelHeader,
    );
    paintDawPlayhead(
      canvas,
      size,
      beat: playhead,
      pixelsPerBeat: pixelsPerBeat,
      color: colors.cursor,
    );
  }

  @override
  bool shouldRepaint(_DawAutomationPainter oldDelegate) =>
      project != oldDelegate.project ||
      lane != oldDelegate.lane ||
      selectedPointId != oldDelegate.selectedPointId ||
      playhead != oldDelegate.playhead ||
      pixelsPerBeat != oldDelegate.pixelsPerBeat ||
      colors != oldDelegate.colors;
}
