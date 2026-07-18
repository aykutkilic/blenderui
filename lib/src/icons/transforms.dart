part of '../icons.dart';

bool _paintTransformsGlyph(BlenderGlyph glyph, _BlenderIconPaintContext icon) {
  final canvas = icon.canvas;
  final paint = icon.paint;
  final w = icon.size.width;
  final h = icon.size.height;
  final center = Offset(w / 2, h / 2);
  final path = Path();
  switch (glyph) {
    case BlenderGlyph.tool:
      // A compact wrench/screwdriver mark for the Properties Tool tab.
      path.moveTo(w * .18, h * .18);
      path.lineTo(w * .36, h * .18);
      path.lineTo(w * .29, h * .3);
      path.lineTo(w * .38, h * .39);
      path.lineTo(w * .5, h * .32);
      path.lineTo(w * .5, h * .5);
      path.lineTo(w * .4, h * .55);
      path.close();
      canvas.drawPath(path, paint);
      canvas.drawLine(Offset(w * .42, h * .42), Offset(w * .8, h * .8), paint);
      canvas.drawCircle(Offset(w * .8, h * .8), w * .08, paint);
    case BlenderGlyph.transform:
      canvas.drawLine(Offset(w * .5, h * .12), Offset(w * .5, h * .88), paint);
      canvas.drawLine(Offset(w * .12, h * .5), Offset(w * .88, h * .5), paint);
      canvas.drawCircle(center, w * .14, paint);
    case BlenderGlyph.rotate:
      path.arcTo(
        Rect.fromLTWH(w * .18, h * .18, w * .64, h * .64),
        -.7,
        4.8,
        false,
      );
      canvas.drawPath(path, paint);
      path.moveTo(w * .72, h * .22);
      path.lineTo(w * .8, h * .42);
      path.lineTo(w * .6, h * .36);
      canvas.drawPath(path, paint);
    case BlenderGlyph.scale:
      canvas.drawLine(Offset(w * .5, h * .15), Offset(w * .5, h * .85), paint);
      canvas.drawLine(Offset(w * .15, h * .5), Offset(w * .85, h * .5), paint);
      path.moveTo(w * .5, h * .15);
      path.lineTo(w * .42, h * .27);
      path.moveTo(w * .5, h * .15);
      path.lineTo(w * .58, h * .27);
      path.moveTo(w * .85, h * .5);
      path.lineTo(w * .73, h * .42);
      path.moveTo(w * .85, h * .5);
      path.lineTo(w * .73, h * .58);
      canvas.drawPath(path, paint);
    case BlenderGlyph.pan:
      canvas.drawCircle(center, w * .24, paint);
      canvas.drawLine(Offset(w * .5, h * .12), Offset(w * .5, h * .3), paint);
      canvas.drawLine(Offset(w * .12, h * .5), Offset(w * .3, h * .5), paint);
      canvas.drawLine(Offset(w * .7, h * .5), Offset(w * .88, h * .5), paint);
      canvas.drawLine(Offset(w * .5, h * .7), Offset(w * .5, h * .88), paint);
    case BlenderGlyph.zoom:
      canvas.drawCircle(Offset(w * .4, h * .4), w * .25, paint);
      canvas.drawLine(
        Offset(w * .58, h * .58),
        Offset(w * .84, h * .84),
        paint,
      );
      canvas.drawLine(Offset(w * .28, h * .4), Offset(w * .52, h * .4), paint);
      canvas.drawLine(Offset(w * .4, h * .28), Offset(w * .4, h * .52), paint);
    default:
      return false;
  }
  return true;
}
