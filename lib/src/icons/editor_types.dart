part of '../icons.dart';

bool _paintEditorTypesGlyph(BlenderGlyph glyph, _BlenderIconPaintContext icon) {
  final canvas = icon.canvas;
  final paint = icon.paint;
  final w = icon.size.width;
  final h = icon.size.height;
  final center = Offset(w / 2, h / 2);
  final path = Path();
  final color = icon.color;
  switch (glyph) {
    case BlenderGlyph.cube:
      path.moveTo(center.dx, h * .12);
      path.lineTo(w * .8, h * .3);
      path.lineTo(w * .8, h * .68);
      path.lineTo(center.dx, h * .88);
      path.lineTo(w * .2, h * .68);
      path.lineTo(w * .2, h * .3);
      path.close();
      canvas.drawPath(path, paint);
      canvas.drawLine(
        Offset(center.dx, h * .12),
        Offset(center.dx, h * .5),
        paint,
      );
      canvas.drawLine(Offset(w * .2, h * .3), Offset(center.dx, h * .5), paint);
      canvas.drawLine(Offset(w * .8, h * .3), Offset(center.dx, h * .5), paint);
    case BlenderGlyph.image:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .12, h * .2, w * .76, h * .6),
          Radius.circular(w * .04),
        ),
        paint,
      );
      canvas.drawCircle(Offset(w * .68, h * .38), w * .08, paint);
      path.moveTo(w * .18, h * .7);
      path.lineTo(w * .4, h * .48);
      path.lineTo(w * .56, h * .62);
      path.lineTo(w * .7, h * .5);
      path.lineTo(w * .84, h * .7);
      canvas.drawPath(path, paint);
    case BlenderGlyph.assetManager:
    case BlenderGlyph.texture:
      canvas.drawRect(Rect.fromLTWH(w * .16, h * .16, w * .68, h * .68), paint);
      for (var i = 1; i < 3; i++) {
        canvas.drawLine(
          Offset(w * (.16 + i * .227), h * .16),
          Offset(w * (.16 + i * .227), h * .84),
          paint,
        );
        canvas.drawLine(
          Offset(w * .16, h * (.16 + i * .227)),
          Offset(w * .84, h * (.16 + i * .227)),
          paint,
        );
      }
    case BlenderGlyph.uv:
      for (var i = 1; i < 3; i++) {
        canvas.drawLine(
          Offset(w * i / 3, h * .15),
          Offset(w * i / 3, h * .85),
          paint,
        );
        canvas.drawLine(
          Offset(w * .15, h * i / 3),
          Offset(w * .85, h * i / 3),
          paint,
        );
      }
      canvas.drawRect(Rect.fromLTWH(w * .15, h * .15, w * .7, h * .7), paint);
    case BlenderGlyph.node:
      for (var i = 0; i < 3; i++) {
        final y = h * (.2 + i * .25);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * .12, y, w * .52, h * .13),
            Radius.circular(w * .03),
          ),
          paint,
        );
        canvas.drawCircle(Offset(w * .78, y + h * .065), w * .05, paint);
      }
    case BlenderGlyph.timeline:
      canvas.drawLine(Offset(w * .12, h * .7), Offset(w * .88, h * .7), paint);
      for (var i = 0; i < 4; i++) {
        final x = w * (.2 + i * .2);
        canvas.drawLine(Offset(x, h * .55), Offset(x, h * .85), paint);
      }
      canvas.drawLine(Offset(w * .5, h * .2), Offset(w * .5, h * .8), paint);
    case BlenderGlyph.sequence:
      for (var i = 0; i < 3; i++) {
        canvas.drawRect(
          Rect.fromLTWH(w * (.12 + i * .25), h * .28, w * .2, h * .42),
          paint,
        );
      }
    case BlenderGlyph.action:
      canvas.drawCircle(center, w * .3, paint);
      canvas.drawLine(
        Offset(w * .22, h * .72),
        Offset(w * .48, h * .46),
        paint,
      );
      canvas.drawLine(
        Offset(w * .48, h * .46),
        Offset(w * .78, h * .28),
        paint,
      );
    case BlenderGlyph.movie:
      canvas.drawRect(Rect.fromLTWH(w * .16, h * .2, w * .68, h * .6), paint);
      for (final y in <double>[.27, .73]) {
        canvas.drawLine(Offset(w * .2, h * y), Offset(w * .8, h * y), paint);
      }
    case BlenderGlyph.text:
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'T',
          style: TextStyle(color: color, fontSize: h * .78),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset((w - textPainter.width) / 2, h * .08));
    case BlenderGlyph.console:
      path.moveTo(w * .18, h * .3);
      path.lineTo(w * .4, center.dy);
      path.lineTo(w * .18, h * .7);
      canvas.drawPath(path, paint);
      canvas.drawLine(Offset(w * .48, h * .7), Offset(w * .82, h * .7), paint);
    case BlenderGlyph.selectBox:
      const dashCount = 3;
      for (var index = 0; index < dashCount; index++) {
        final t = index / dashCount;
        canvas.drawLine(
          Offset(w * (.18 + t * .64), h * .16),
          Offset(w * (.18 + (t + .55) / dashCount * .64), h * .16),
          paint,
        );
        canvas.drawLine(
          Offset(w * (.18 + t * .64), h * .84),
          Offset(w * (.18 + (t + .55) / dashCount * .64), h * .84),
          paint,
        );
      }
      canvas.drawLine(
        Offset(w * .16, h * .16),
        Offset(w * .16, h * .84),
        paint,
      );
      canvas.drawLine(
        Offset(w * .84, h * .16),
        Offset(w * .84, h * .84),
        paint,
      );
      path.moveTo(w * .4, h * .35);
      path.lineTo(w * .4, h * .7);
      path.lineTo(w * .68, h * .58);
      path.close();
      canvas.drawPath(path, paint);
    case BlenderGlyph.selectExtend:
      canvas.drawRect(Rect.fromLTWH(w * .2, h * .34, w * .42, h * .48), paint);
      canvas.drawRect(Rect.fromLTWH(w * .42, h * .16, w * .42, h * .48), paint);
    case BlenderGlyph.selectSubtract:
      canvas.drawRect(Rect.fromLTWH(w * .38, h * .16, w * .46, h * .48), paint);
      canvas.drawLine(Offset(w * .2, h * .34), Offset(w * .62, h * .34), paint);
      canvas.drawLine(Offset(w * .2, h * .34), Offset(w * .2, h * .82), paint);
      canvas.drawLine(Offset(w * .2, h * .82), Offset(w * .62, h * .82), paint);
    case BlenderGlyph.selectDifference:
      canvas.drawRect(Rect.fromLTWH(w * .16, h * .34, w * .46, h * .48), paint);
      canvas.drawRect(Rect.fromLTWH(w * .38, h * .16, w * .46, h * .48), paint);
    case BlenderGlyph.selectIntersect:
      canvas.drawRect(Rect.fromLTWH(w * .34, h * .34, w * .32, h * .32), paint);
      canvas.drawLine(Offset(w * .2, h * .16), Offset(w * .8, h * .16), paint);
      canvas.drawLine(Offset(w * .2, h * .84), Offset(w * .8, h * .84), paint);
    default:
      return false;
  }
  return true;
}
