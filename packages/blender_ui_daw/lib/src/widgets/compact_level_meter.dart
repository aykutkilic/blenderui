import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

/// Allocation-free compact peak meter suitable for every device-chain card.
///
/// [level] is linear amplitude in the 0–1 range. Painting is isolated so
/// high-rate meter updates do not repaint the device controls around it.
class DawCompactLevelMeter extends StatelessWidget {
  const DawCompactLevelMeter({
    super.key,
    required this.level,
    this.width = 5,
    this.height = 24,
  });

  final double level;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      size: Size(width, height),
      painter: _CompactLevelMeterPainter(
        level: level.clamp(0, 1).toDouble(),
        background: BlenderTheme.of(context).colors.canvas,
      ),
    ),
  );
}

class _CompactLevelMeterPainter extends CustomPainter {
  const _CompactLevelMeterPainter({
    required this.level,
    required this.background,
  });

  final double level;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(1)),
      Paint()..color = background,
    );
    if (level <= 0) return;
    final filled = Rect.fromLTRB(
      0,
      size.height * (1 - level),
      size.width,
      size.height,
    );
    canvas.save();
    canvas.clipRect(filled);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: <Color>[
            Color(0xFF40D64A),
            Color(0xFF82E14C),
            Color(0xFFF2C94C),
            Color(0xFFF05A4F),
          ],
          stops: <double>[0, .68, .86, 1],
        ).createShader(rect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CompactLevelMeterPainter oldDelegate) =>
      oldDelegate.level != level || oldDelegate.background != background;
}
