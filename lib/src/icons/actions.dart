part of '../icons.dart';

bool _paintActionsGlyph(BlenderGlyph glyph, _BlenderIconPaintContext icon) {
  final canvas = icon.canvas;
  final paint = icon.paint;
  final w = icon.size.width;
  final h = icon.size.height;
  final center = Offset(w / 2, h / 2);
  final path = Path();
  final color = icon.color;
  switch (glyph) {
    case BlenderGlyph.deleteIcon:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .24, h * .28, w * .52, h * .56),
          Radius.circular(w * .03),
        ),
        paint,
      );
      canvas.drawLine(Offset(w * .18, h * .2), Offset(w * .82, h * .2), paint);
      canvas.drawLine(
        Offset(w * .38, h * .14),
        Offset(w * .62, h * .14),
        paint,
      );
    case BlenderGlyph.duplicate:
      canvas.drawRect(Rect.fromLTWH(w * .22, h * .28, w * .48, h * .48), paint);
      canvas.drawRect(Rect.fromLTWH(w * .36, h * .14, w * .48, h * .48), paint);
    case BlenderGlyph.record:
      canvas.drawCircle(center, w * .28, paint);
      canvas.drawCircle(center, w * .1, paint);
    case BlenderGlyph.undo:
      canvas.drawArc(
        Rect.fromLTWH(w * .2, h * .2, w * .6, h * .58),
        math.pi * .25,
        math.pi * 1.45,
        false,
        paint,
      );
      path.moveTo(w * .22, h * .42);
      path.lineTo(w * .22, h * .2);
      path.lineTo(w * .44, h * .3);
      canvas.drawPath(path, paint);
    case BlenderGlyph.redo:
      canvas.drawArc(
        Rect.fromLTWH(w * .2, h * .2, w * .6, h * .58),
        math.pi * .5,
        -math.pi * 1.45,
        false,
        paint,
      );
      path.moveTo(w * .78, h * .42);
      path.lineTo(w * .78, h * .2);
      path.lineTo(w * .56, h * .3);
      canvas.drawPath(path, paint);
    case BlenderGlyph.stepBack:
      canvas.drawLine(Offset(w * .2, h * .2), Offset(w * .2, h * .8), paint);
      path.moveTo(w * .72, h * .2);
      path.lineTo(w * .34, center.dy);
      path.lineTo(w * .72, h * .8);
      path.close();
      canvas.drawPath(path, paint);
    case BlenderGlyph.stepForward:
      canvas.drawLine(Offset(w * .8, h * .2), Offset(w * .8, h * .8), paint);
      path.moveTo(w * .28, h * .2);
      path.lineTo(w * .66, center.dy);
      path.lineTo(w * .28, h * .8);
      path.close();
      canvas.drawPath(path, paint);
    case BlenderGlyph.snap:
      canvas.drawArc(
        Rect.fromLTWH(w * .22, h * .16, w * .56, h * .6),
        math.pi,
        math.pi,
        false,
        paint,
      );
      canvas.drawLine(
        Offset(w * .22, h * .46),
        Offset(w * .22, h * .72),
        paint,
      );
      canvas.drawLine(
        Offset(w * .78, h * .46),
        Offset(w * .78, h * .72),
        paint,
      );
      canvas.drawLine(
        Offset(w * .22, h * .72),
        Offset(w * .78, h * .72),
        paint,
      );
    case BlenderGlyph.pin:
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-math.pi / 4);
      canvas.translate(-center.dx, -center.dy);
      path.moveTo(w * .3, h * .2);
      path.lineTo(w * .7, h * .2);
      path.lineTo(w * .62, h * .5);
      path.lineTo(w * .5, h * .62);
      path.lineTo(w * .38, h * .5);
      path.close();
      canvas.drawPath(path, paint);
      canvas.drawLine(Offset(w * .5, h * .62), Offset(w * .5, h * .88), paint);
      canvas.restore();
    case BlenderGlyph.filter:
      path.moveTo(w * .14, h * .2);
      path.lineTo(w * .86, h * .2);
      path.lineTo(w * .58, h * .5);
      path.lineTo(w * .58, h * .82);
      path.lineTo(w * .42, h * .72);
      path.lineTo(w * .42, h * .5);
      path.close();
      canvas.drawPath(path, paint);
    case BlenderGlyph.sort:
      canvas.drawLine(Offset(w * .2, h * .25), Offset(w * .8, h * .25), paint);
      canvas.drawLine(Offset(w * .2, h * .5), Offset(w * .65, h * .5), paint);
      canvas.drawLine(Offset(w * .2, h * .75), Offset(w * .5, h * .75), paint);
    case BlenderGlyph.sortDescending:
      canvas.drawLine(Offset(w * .2, h * .25), Offset(w * .5, h * .25), paint);
      canvas.drawLine(Offset(w * .2, h * .5), Offset(w * .65, h * .5), paint);
      canvas.drawLine(Offset(w * .2, h * .75), Offset(w * .8, h * .75), paint);
    case BlenderGlyph.sortAlphabetically:
      final sortTextPainter = TextPainter(
        text: TextSpan(
          text: 'A',
          style: TextStyle(color: color, fontSize: h * .48),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      sortTextPainter.paint(canvas, Offset(w * .08, h * .02));
      final sortZPainter = TextPainter(
        text: TextSpan(
          text: 'Z',
          style: TextStyle(color: color, fontSize: h * .42),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      sortZPainter.paint(canvas, Offset(w * .5, h * .5));
    default:
      return false;
  }
  return true;
}
