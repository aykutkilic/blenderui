part of '../icons.dart';

bool _paintViewportGlyph(BlenderGlyph glyph, _BlenderIconPaintContext icon) {
  final canvas = icon.canvas;
  final paint = icon.paint;
  final w = icon.size.width;
  final h = icon.size.height;
  final center = Offset(w / 2, h / 2);
  final path = Path();
  final color = icon.color;
  switch (glyph) {
    case BlenderGlyph.viewLayer:
      for (var index = 0; index < 3; index++) {
        final y = h * (.24 + index * .26);
        canvas.drawLine(
          Offset(w * (.18 + index * .08), y),
          Offset(w * .82, y),
          paint,
        );
      }
    case BlenderGlyph.camera:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .12, h * .31, w * .58, h * .43),
          Radius.circular(w * .06),
        ),
        paint,
      );
      path.moveTo(w * .7, h * .4);
      path.lineTo(w * .88, h * .3);
      path.lineTo(w * .88, h * .72);
      path.lineTo(w * .7, h * .62);
      path.close();
      canvas.drawPath(path, paint);
      canvas.drawLine(Offset(w * .26, h * .3), Offset(w * .38, h * .18), paint);
    case BlenderGlyph.light:
      canvas.drawCircle(Offset(center.dx, h * .4), w * .22, paint);
      canvas.drawLine(
        Offset(w * .38, h * .66),
        Offset(w * .62, h * .66),
        paint,
      );
      canvas.drawLine(
        Offset(w * .42, h * .76),
        Offset(w * .58, h * .76),
        paint,
      );
    case BlenderGlyph.material:
      canvas.drawCircle(center, w * .3, paint);
      canvas.drawCircle(center, w * .1, paint);
      canvas.drawLine(
        Offset(w * .28, h * .72),
        Offset(w * .72, h * .28),
        paint,
      );
    case BlenderGlyph.gizmo:
      canvas.drawCircle(center, w * .28, paint);
      canvas.drawLine(
        Offset(center.dx, h * .18),
        Offset(center.dx, h * .82),
        paint,
      );
      canvas.drawLine(
        Offset(w * .18, center.dy),
        Offset(w * .82, center.dy),
        paint,
      );
      canvas.drawLine(
        Offset(w * .32, h * .68),
        Offset(w * .68, h * .32),
        paint,
      );
    case BlenderGlyph.overlay:
      canvas.drawRect(Rect.fromLTWH(w * .18, h * .24, w * .48, h * .48), paint);
      canvas.drawRect(Rect.fromLTWH(w * .34, h * .4, w * .48, h * .48), paint);
    case BlenderGlyph.xray:
      canvas.drawRect(Rect.fromLTWH(w * .18, h * .18, w * .64, h * .64), paint);
      canvas.drawLine(
        Offset(w * .24, h * .76),
        Offset(w * .76, h * .24),
        paint,
      );
    case BlenderGlyph.solid:
      canvas.drawCircle(center, w * .32, paint);
    case BlenderGlyph.materialPreview:
      canvas.drawCircle(center, w * .32, paint);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: w * .32),
        -math.pi / 2,
        math.pi,
        false,
        paint,
      );
    case BlenderGlyph.rendered:
      canvas.drawCircle(center, w * .32, paint);
      canvas.drawLine(
        Offset(w * .22, h * .72),
        Offset(w * .78, h * .28),
        paint,
      );
    case BlenderGlyph.modifier:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .22, h * .22, w * .56, h * .56),
          Radius.circular(w * .08),
        ),
        paint,
      );
      canvas.drawLine(Offset(w * .32, h * .5), Offset(w * .68, h * .5), paint);
    case BlenderGlyph.physics:
      canvas.drawCircle(center, w * .25, paint);
      for (var index = 0; index < 8; index++) {
        final angle = index * math.pi / 4;
        canvas.drawLine(
          Offset(
            center.dx + math.cos(angle) * w * .34,
            center.dy + math.sin(angle) * h * .34,
          ),
          Offset(
            center.dx + math.cos(angle) * w * .46,
            center.dy + math.sin(angle) * h * .46,
          ),
          paint,
        );
      }
    case BlenderGlyph.scene:
      // Blender's Scene datablock reads as a small group of objects, not a
      // target reticle. Keep the three distinct marks at compact sizes.
      final fill = Paint()..color = color;
      canvas.drawCircle(Offset(w * .32, h * .3), w * .11, fill);
      canvas.drawCircle(Offset(w * .7, h * .62), w * .14, fill);
      path.moveTo(w * .24, h * .75);
      path.lineTo(w * .49, h * .37);
      path.lineTo(w * .78, h * .76);
      path.close();
      canvas.drawPath(path, paint);
    case BlenderGlyph.world:
      canvas.drawCircle(center, w * .34, paint);
      canvas.drawOval(Rect.fromLTWH(w * .3, h * .16, w * .4, h * .68), paint);
      canvas.drawLine(Offset(w * .16, h * .5), Offset(w * .84, h * .5), paint);
    case BlenderGlyph.render:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .18, h * .28, w * .64, h * .44),
          Radius.circular(w * .04),
        ),
        paint,
      );
      canvas.drawCircle(center, w * .14, paint);
      canvas.drawLine(Offset(w * .28, h * .2), Offset(w * .42, h * .28), paint);
    case BlenderGlyph.output:
      canvas.drawRect(Rect.fromLTWH(w * .14, h * .26, w * .5, h * .48), paint);
      canvas.drawLine(
        Offset(w * .48, center.dy),
        Offset(w * .86, center.dy),
        paint,
      );
      path.moveTo(w * .68, h * .3);
      path.lineTo(w * .86, center.dy);
      path.lineTo(w * .68, h * .7);
      canvas.drawPath(path, paint);
    default:
      return false;
  }
  return true;
}
