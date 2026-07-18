part of '../editors.dart';

class _BlenderTimelinePainter extends CustomPainter {
  _BlenderTimelinePainter({
    required this.model,
    required this.trackHeight,
    required this.colors,
    required this.textTheme,
  });

  final BlenderTimelineModel model;
  final double trackHeight;
  final BlenderColorScheme colors;
  final BlenderTextTheme textTheme;

  @override
  void paint(Canvas canvas, Size size) {
    final range = math.max(.0001, model.end - model.start);
    const headerHeight = 28.0;
    final linePaint = Paint()..color = colors.borderSubtle;
    final mutedPaint = Paint()..color = colors.foregroundMuted;
    canvas.drawLine(
      const Offset(0, headerHeight),
      Offset(size.width, headerHeight),
      linePaint,
    );
    for (
      var frame = model.start.ceilToDouble();
      frame <= model.end;
      frame += 10
    ) {
      final x = (frame - model.start) / range * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
      final textPainter = TextPainter(
        text: TextSpan(
          text: frame.toStringAsFixed(0),
          style: textTheme.caption.copyWith(color: colors.foregroundMuted),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(x + 2, 5));
    }
    for (var index = 0; index < model.tracks.length; index++) {
      final y = headerHeight + index * trackHeight;
      canvas.drawLine(
        Offset(0, y + trackHeight),
        Offset(size.width, y + trackHeight),
        linePaint,
      );
      final labelPainter = TextPainter(
        text: TextSpan(
          text: model.tracks[index].label,
          style: textTheme.caption.copyWith(color: colors.foreground),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 100);
      labelPainter.paint(canvas, Offset(6, y + 5));
      for (final keyframe in model.tracks[index].keyframes) {
        final x = (keyframe.frame - model.start) / range * size.width;
        final color = keyframe.color ?? colors.accent;
        final keyframePaint = Paint()..color = color;
        final points = <Offset>[
          Offset(x, y + trackHeight / 2),
          Offset(x + 5, y + trackHeight / 2 - 5),
          Offset(x + 10, y + trackHeight / 2),
          Offset(x + 5, y + trackHeight / 2 + 5),
        ];
        canvas.drawPath(Path()..addPolygon(points, true), keyframePaint);
      }
    }
    final cursorX = (model.currentFrame - model.start) / range * size.width;
    canvas.drawLine(
      Offset(cursorX, 0),
      Offset(cursorX, size.height),
      mutedPaint..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_BlenderTimelinePainter oldDelegate) {
    return model != oldDelegate.model ||
        trackHeight != oldDelegate.trackHeight ||
        colors != oldDelegate.colors;
  }
}
