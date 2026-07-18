part of '../templates.dart';

/// A lightweight scrollbar matching Blender's narrow editor scroll thumb.
class BlenderScrollBar extends StatelessWidget {
  const BlenderScrollBar({
    super.key,
    required this.value,
    required this.viewportFraction,
    required this.onChanged,
    this.vertical = true,
    this.thickness = 10,
  });

  final double value;
  final double viewportFraction;
  final ValueChanged<double> onChanged;
  final bool vertical;
  final double thickness;

  void _setFromOffset(Offset offset, Size size) {
    final extent = vertical ? size.height : size.width;
    final thumb = extent * viewportFraction.clamp(.05, 1);
    final position = vertical ? offset.dy : offset.dx;
    final next = ((position - thumb / 2) / math.max(1, extent - thumb)).clamp(
      0,
      1,
    );
    onChanged(next.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : thickness,
          constraints.maxHeight.isFinite ? constraints.maxHeight : thickness,
        );
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => _setFromOffset(details.localPosition, size),
          onVerticalDragUpdate: vertical
              ? (details) => _setFromOffset(details.localPosition, size)
              : null,
          onHorizontalDragUpdate: vertical
              ? null
              : (details) => _setFromOffset(details.localPosition, size),
          child: CustomPaint(
            painter: _BlenderScrollBarPainter(
              value: value,
              viewportFraction: viewportFraction,
              vertical: vertical,
              colors: theme.colors,
              thickness: thickness,
            ),
          ),
        );
      },
    );
  }
}

class _BlenderScrollBarPainter extends CustomPainter {
  _BlenderScrollBarPainter({
    required this.value,
    required this.viewportFraction,
    required this.vertical,
    required this.colors,
    required this.thickness,
  });

  final double value;
  final double viewportFraction;
  final bool vertical;
  final BlenderColorScheme colors;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final extent = vertical ? size.height : size.width;
    final thumbExtent = extent * viewportFraction.clamp(.05, 1);
    final offset = (extent - thumbExtent) * value.clamp(0, 1);
    final rect = vertical
        ? Rect.fromLTWH(
            1,
            offset + 1,
            math.max(2, thickness - 2),
            math.max(8, thumbExtent - 2),
          )
        : Rect.fromLTWH(
            offset + 1,
            1,
            math.max(8, thumbExtent - 2),
            math.max(2, thickness - 2),
          );
    canvas.drawRect(
      rect,
      Paint()
        ..color = colors.button
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_BlenderScrollBarPainter oldDelegate) {
    return value != oldDelegate.value ||
        viewportFraction != oldDelegate.viewportFraction ||
        vertical != oldDelegate.vertical ||
        colors != oldDelegate.colors;
  }
}
