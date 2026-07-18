part of '../templates.dart';

/// A normalized curve editor for falloff, animation, and mapping properties.
class BlenderCurveMapping extends StatefulWidget {
  const BlenderCurveMapping({
    super.key,
    required this.points,
    required this.onChanged,
    this.height = 160,
  });

  final List<Offset> points;
  final ValueChanged<List<Offset>> onChanged;
  final double height;

  @override
  State<BlenderCurveMapping> createState() => _BlenderCurveMappingState();
}

class _BlenderCurveMappingState extends State<BlenderCurveMapping> {
  int _selected = 0;

  int _nearest(Offset point) {
    var index = 0;
    var distance = double.infinity;
    for (var i = 0; i < widget.points.length; i++) {
      final next = (widget.points[i] - point).distance;
      if (next < distance) {
        index = i;
        distance = next;
      }
    }
    return index;
  }

  Offset _normalize(Offset point, Size size) {
    return Offset(
      (point.dx / math.max(1, size.width)).clamp(0, 1),
      (1 - point.dy / math.max(1, size.height)).clamp(0, 1),
    );
  }

  void _move(Offset local, Size size) {
    if (widget.points.isEmpty) return;
    final next = widget.points.toList();
    next[_selected] = _normalize(local, size);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = BlenderTheme.of(context).colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, widget.height);
        return GestureDetector(
          onTapDown: (details) {
            final normalized = _normalize(details.localPosition, size);
            if (widget.points.isNotEmpty) {
              setState(() => _selected = _nearest(normalized));
            }
          },
          onPanUpdate: (details) => _move(details.localPosition, size),
          child: SizedBox(
            height: widget.height,
            child: CustomPaint(
              painter: _BlenderCurveMappingPainter(
                points: widget.points,
                selected: _selected,
                colors: colors,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BlenderCurveMappingPainter extends CustomPainter {
  _BlenderCurveMappingPainter({
    required this.points,
    required this.selected,
    required this.colors,
  });

  final List<Offset> points;
  final int selected;
  final BlenderColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = colors.textField;
    canvas.drawRect(Offset.zero & size, background);
    final grid = Paint()
      ..color = colors.borderSubtle
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      final y = size.height * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final normalized = [
      for (final point in points)
        Offset(
          point.dx.clamp(0, 1) * size.width,
          (1 - point.dy.clamp(0, 1)) * size.height,
        ),
    ];
    if (normalized.length > 1) {
      final path = Path()..moveTo(normalized.first.dx, normalized.first.dy);
      for (var i = 1; i < normalized.length; i++) {
        path.lineTo(normalized[i].dx, normalized[i].dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = colors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    for (var i = 0; i < normalized.length; i++) {
      canvas.drawCircle(
        normalized[i],
        i == selected ? 5 : 4,
        Paint()..color = i == selected ? colors.focus : colors.foreground,
      );
    }
  }

  @override
  bool shouldRepaint(_BlenderCurveMappingPainter oldDelegate) {
    return points != oldDelegate.points ||
        selected != oldDelegate.selected ||
        colors != oldDelegate.colors;
  }
}
