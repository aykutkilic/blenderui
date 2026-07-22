part of 'arrangement_editor.dart';

class _DawArrangementPainter extends CustomPainter {
  _DawArrangementPainter({
    required this.project,
    required this.selection,
    required this.playhead,
    required this.pixelsPerBeat,
    required this.baseTrackHeight,
    required this.automationLaneHeight,
    required this.colors,
    required this.textTheme,
  });

  final DawProject project;
  final DawSelection selection;
  final double playhead;
  final double pixelsPerBeat;
  final double baseTrackHeight;
  final double automationLaneHeight;
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
      startY: 28,
    );
    if (project.loopEnabled) {
      final left = project.loopStartBeat * pixelsPerBeat;
      final right = project.loopEndBeat * pixelsPerBeat;
      canvas.drawRect(
        Rect.fromLTRB(left, 28, right, size.height),
        Paint()..color = colors.accent.withValues(alpha: .08),
      );
      canvas.drawRect(
        Rect.fromLTRB(left, 0, right, 4),
        Paint()..color = colors.accent,
      );
    }
    _paintRuler(canvas, size);
    var y = 28.0;
    for (final track in project.tracks) {
      final trackHeight = baseTrackHeight * track.heightScale;
      canvas.drawLine(
        Offset(0, y + trackHeight),
        Offset(size.width, y + trackHeight),
        Paint()..color = colors.borderSubtle,
      );
      for (final clip in track.clips) {
        _paintClip(canvas, clip, y, trackHeight);
      }
      y += trackHeight;
      if (track.automationExpanded) {
        for (final lane in track.automation) {
          _paintAutomationLane(canvas, lane, y, size.width);
          y += automationLaneHeight;
        }
      }
    }
    paintDawPlayhead(
      canvas,
      size,
      beat: playhead,
      pixelsPerBeat: pixelsPerBeat,
      color: colors.cursor,
    );
  }

  void _paintRuler(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, 28),
      Paint()..color = colors.panelHeader,
    );
    final bars =
        (size.width / (pixelsPerBeat * project.timeSignature.numerator)).ceil();
    for (var bar = 0; bar <= bars; bar++) {
      final x = bar * pixelsPerBeat * project.timeSignature.numerator;
      final painter = TextPainter(
        text: TextSpan(text: '${bar + 1}', style: textTheme.caption),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(x + 4, 7));
    }
  }

  void _paintClip(Canvas canvas, DawClip clip, double y, double trackHeight) {
    final rect = Rect.fromLTWH(
      clip.startBeat * pixelsPerBeat + 1,
      y + 4,
      math.max(4, clip.lengthBeats * pixelsPerBeat - 2),
      trackHeight - 8,
    );
    final selected = selection.clipId == clip.id;
    final baseColor = Color(clip.colorValue);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()
        ..color = clip.muted ? baseColor.withValues(alpha: .35) : baseColor,
    );
    canvas.drawLine(
      Offset(rect.right - 4, rect.top + 8),
      Offset(rect.right - 4, rect.bottom - 5),
      Paint()
        ..color = colors.foreground.withValues(alpha: selected ? .9 : .45)
        ..strokeWidth = 1,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 2 : 1
        ..color = selected ? colors.foreground : colors.border,
    );
    final painter = TextPainter(
      text: TextSpan(text: clip.name, style: textTheme.label),
      maxLines: 1,
      ellipsis: '…',
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: math.max(0, rect.width - 10));
    canvas.save();
    canvas.clipRect(rect);
    painter.paint(canvas, Offset(rect.left + 5, rect.top + 4));
    if (clip is DawAudioClip) _paintWaveform(canvas, clip, rect);
    if (clip is DawMidiClip) _paintMidiPreview(canvas, clip, rect);
    if (clip.looped) {
      final loopLabel = TextPainter(
        text: TextSpan(text: '↻', style: textTheme.label),
        textDirection: TextDirection.ltr,
      )..layout();
      loopLabel.paint(canvas, Offset(rect.right - 18, rect.top + 3));
    }
    canvas.restore();
  }

  void _paintAutomationLane(
    Canvas canvas,
    DawAutomationLane lane,
    double y,
    double width,
  ) {
    canvas.drawRect(
      Rect.fromLTWH(0, y, width, automationLaneHeight),
      Paint()..color = colors.surface.withValues(alpha: .42),
    );
    final points = List<DawAutomationPoint>.of(lane.points)
      ..sort((a, b) => a.beat.compareTo(b.beat));
    final path = Path();
    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final offset = Offset(
        point.beat * pixelsPerBeat,
        y + (1 - point.value) * automationLaneHeight,
      );
      if (index == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    final color = Color(lane.colorValue);
    canvas.drawPath(
      path,
      Paint()
        ..color = lane.enabled ? color : colors.foregroundDisabled
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    for (final point in points) {
      final selected = selection.automationPointId == point.id;
      canvas.drawCircle(
        Offset(
          point.beat * pixelsPerBeat,
          y + (1 - point.value) * automationLaneHeight,
        ),
        selected ? 5 : 3.5,
        Paint()..color = selected ? colors.foreground : color,
      );
    }
    canvas.drawLine(
      Offset(0, y + automationLaneHeight),
      Offset(width, y + automationLaneHeight),
      Paint()..color = colors.borderSubtle,
    );
  }

  void _paintWaveform(Canvas canvas, DawAudioClip clip, Rect rect) {
    final peaks = clip.waveform.peaks;
    if (peaks.isEmpty) return;
    final path = Path();
    final center = rect.center.dy + 4;
    for (var x = 0; x < rect.width.floor(); x++) {
      final index = (x / math.max(1, rect.width) * peaks.length).floor().clamp(
        0,
        peaks.length - 1,
      );
      final amplitude = peaks[index].abs() * (rect.height * .3);
      path.moveTo(rect.left + x, center - amplitude);
      path.lineTo(rect.left + x, center + amplitude);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xCC101418)
        ..strokeWidth = 1,
    );
  }

  void _paintMidiPreview(Canvas canvas, DawMidiClip clip, Rect rect) {
    if (clip.notes.isEmpty) return;
    final minPitch = clip.notes.map((note) => note.pitch).reduce(math.min);
    final maxPitch = clip.notes.map((note) => note.pitch).reduce(math.max);
    final pitchRange = math.max(1, maxPitch - minPitch + 1);
    final paint = Paint()..color = const Color(0xCC101418);
    for (final note in clip.notes) {
      final x = rect.left + note.startBeat / clip.lengthBeats * rect.width;
      final width = math.max(
        1.0,
        note.lengthBeats / clip.lengthBeats * rect.width,
      );
      final noteY =
          rect.bottom -
          3 -
          (note.pitch - minPitch + 1) / pitchRange * (rect.height - 18);
      canvas.drawRect(Rect.fromLTWH(x, noteY, width, 2), paint);
    }
  }

  @override
  bool shouldRepaint(_DawArrangementPainter oldDelegate) =>
      project != oldDelegate.project ||
      selection != oldDelegate.selection ||
      playhead != oldDelegate.playhead ||
      pixelsPerBeat != oldDelegate.pixelsPerBeat ||
      baseTrackHeight != oldDelegate.baseTrackHeight ||
      automationLaneHeight != oldDelegate.automationLaneHeight ||
      colors != oldDelegate.colors;
}
