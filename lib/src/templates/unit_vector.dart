part of '../templates.dart';

class BlenderUnitVector extends StatefulWidget {
  const BlenderUnitVector({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 72,
  });

  final Offset value;
  final ValueChanged<Offset> onChanged;
  final double size;

  @override
  State<BlenderUnitVector> createState() => _BlenderUnitVectorState();
}

class _BlenderUnitVectorState extends State<BlenderUnitVector> {
  void _update(Offset local) {
    final x = (local.dx / widget.size * 2 - 1).clamp(-1, 1).toDouble();
    final y = (1 - local.dy / widget.size * 2).clamp(-1, 1).toDouble();
    widget.onChanged(Offset(x, y));
  }

  @override
  Widget build(BuildContext context) {
    final colors = BlenderTheme.of(context).colors;
    return GestureDetector(
      onTapDown: (details) => _update(details.localPosition),
      onPanUpdate: (details) => _update(details.localPosition),
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _BlenderUnitVectorPainter(value: widget.value, colors: colors),
      ),
    );
  }
}

class _BlenderUnitVectorPainter extends CustomPainter {
  _BlenderUnitVectorPainter({required this.value, required this.colors});

  final Offset value;
  final BlenderColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 3;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = colors.textField
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = colors.borderSubtle
        ..style = PaintingStyle.stroke,
    );
    final axis = Paint()
      ..color = colors.borderSubtle
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      axis,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      axis,
    );
    final point = Offset(
      center.dx + value.dx.clamp(-1, 1) * radius,
      center.dy - value.dy.clamp(-1, 1) * radius,
    );
    canvas.drawCircle(point, 5, Paint()..color = colors.accent);
    canvas.drawCircle(
      point,
      5,
      Paint()
        ..color = colors.foreground
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_BlenderUnitVectorPainter oldDelegate) {
    return value != oldDelegate.value || colors != oldDelegate.colors;
  }
}
