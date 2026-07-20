part of '../non3d_editors.dart';

class BlenderCurveChannel {
  const BlenderCurveChannel({
    required this.id,
    required this.label,
    required this.points,
    this.color,
  });

  final String id;
  final String label;
  final List<Offset> points;
  final Color? color;
}

/// A 2D Graph Editor surface with channels, grid, and normalized curves.
class BlenderCurveEditor extends StatelessWidget {
  const BlenderCurveEditor({
    super.key,
    required this.channels,
    this.sidebar,
    this.sidebarWidth = 240,
    this.footer,
    this.title,
  });

  final List<BlenderCurveChannel> channels;
  final Widget? sidebar;
  final double sidebarWidth;
  final Widget? footer;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final canvas = BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: CustomPaint(
        painter: _BlenderCurveEditorPainter(
          channels: channels,
          colors: theme.colors,
          textTheme: theme.textTheme,
        ),
        child: const SizedBox.expand(),
      ),
    );
    final content = sidebar == null
        ? canvas
        : Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(child: canvas),
              SizedBox(width: sidebarWidth, child: sidebar),
            ],
          );
    if (footer == null) return content;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: content),
        footer!,
      ],
    );
  }
}

class _BlenderCurveEditorPainter extends CustomPainter {
  _BlenderCurveEditorPainter({
    required this.channels,
    required this.colors,
    required this.textTheme,
  });

  final List<BlenderCurveChannel> channels;
  final BlenderColorScheme colors;
  final BlenderTextTheme textTheme;

  @override
  void paint(Canvas canvas, Size size) {
    final gutter = math.min(126, size.width * .25).toDouble();
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.canvas);
    final grid = Paint()
      ..color = colors.borderSubtle
      ..strokeWidth = 1;
    for (var i = 1; i < 10; i++) {
      final x = gutter + (size.width - gutter) * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var i = 1; i < 8; i++) {
      final y = (size.height * i / 8).toDouble();
      canvas.drawLine(Offset(gutter, y), Offset(size.width, y), grid);
    }
    canvas.drawRect(
      Rect.fromLTWH(0, 0, gutter, size.height),
      Paint()..color = colors.surface,
    );
    final rowHeight = channels.isEmpty
        ? size.height
        : math.max(22, size.height / channels.length).toDouble();
    for (var index = 0; index < channels.length; index++) {
      final channel = channels[index];
      final y = index * rowHeight;
      final label = TextPainter(
        text: TextSpan(
          text: channel.label,
          style: textTheme.caption.copyWith(color: colors.foreground),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: gutter - 10);
      label.paint(canvas, Offset(6, y + 5));
      if (channel.points.length < 2) continue;
      final path = Path();
      for (
        var pointIndex = 0;
        pointIndex < channel.points.length;
        pointIndex++
      ) {
        final point = channel.points[pointIndex];
        final x =
            gutter + point.dx.clamp(0, 1).toDouble() * (size.width - gutter);
        final pointY = y + (1 - point.dy.clamp(0, 1).toDouble()) * rowHeight;
        if (pointIndex == 0) {
          path.moveTo(x, pointY);
        } else {
          path.lineTo(x, pointY);
        }
        canvas.drawCircle(
          Offset(x, pointY),
          3,
          Paint()..color = channel.color ?? colors.accent,
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = channel.color ?? colors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_BlenderCurveEditorPainter oldDelegate) {
    return channels != oldDelegate.channels || colors != oldDelegate.colors;
  }
}
