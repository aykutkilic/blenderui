part of '../controls.dart';

class BlenderSlider extends StatelessWidget {
  const BlenderSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.enabled = true,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final bool enabled;

  double _valueForWidth(double width, double localX) {
    final raw = min + (max - min) * (localX / math.max(1, width));
    final clamped = raw.clamp(min, max).toDouble();
    if (divisions == null || divisions == 0) return clamped;
    final step = (max - min) / divisions!;
    return ((clamped - min) / step).round() * step + min;
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final active = enabled && onChanged != null;
    final step = (max - min) / 20;
    final increasedValue = (value + step).clamp(min, max).toStringAsFixed(2);
    final decreasedValue = (value - step).clamp(min, max).toStringAsFixed(2);
    void update(double width, double x) {
      if (active) onChanged!(_valueForWidth(width, x));
    }

    return Semantics(
      slider: true,
      enabled: active,
      value: value.toStringAsFixed(2),
      increasedValue: increasedValue,
      decreasedValue: decreasedValue,
      onIncrease: active
          ? () => onChanged!(double.parse(increasedValue))
          : null,
      onDecrease: active
          ? () => onChanged!(double.parse(decreasedValue))
          : null,
      child: SizedBox(
        height: 28,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: active
                  ? (details) =>
                        update(constraints.maxWidth, details.localPosition.dx)
                  : null,
              onHorizontalDragUpdate: active
                  ? (details) =>
                        update(constraints.maxWidth, details.localPosition.dx)
                  : null,
              child: CustomPaint(
                painter: _BlenderSliderPainter(
                  value: value,
                  min: min,
                  max: max,
                  active: active,
                  colors: theme.colors,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BlenderSliderPainter extends CustomPainter {
  _BlenderSliderPainter({
    required this.value,
    required this.min,
    required this.max,
    required this.active,
    required this.colors,
  });

  final double value;
  final double min;
  final double max;
  final bool active;
  final BlenderColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    final trackY = size.height / 2;
    const left = 7.0;
    final right = math.max(left, size.width - 7);
    final fraction = ((value - min) / (max - min)).clamp(0.0, 1.0).toDouble();
    final thumbX = left + (right - left) * fraction;
    final track = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = active ? colors.borderSubtle : colors.border;
    canvas.drawLine(Offset(left, trackY), Offset(right, trackY), track);
    track.color = active ? colors.accent : colors.foregroundDisabled;
    canvas.drawLine(Offset(left, trackY), Offset(thumbX, trackY), track);
    canvas.drawCircle(Offset(thumbX, trackY), 6, Paint()..color = track.color);
  }

  @override
  bool shouldRepaint(_BlenderSliderPainter oldDelegate) {
    return value != oldDelegate.value ||
        active != oldDelegate.active ||
        colors != oldDelegate.colors;
  }
}
