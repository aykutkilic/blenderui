part of '../icons.dart';

bool _paintDataTypesGlyph(BlenderGlyph glyph, _BlenderIconPaintContext icon) {
  final canvas = icon.canvas;
  final paint = icon.paint;
  final w = icon.size.width;
  final h = icon.size.height;
  final center = Offset(w / 2, h / 2);
  final path = Path();
  switch (glyph) {
    case BlenderGlyph.outliner:
      for (var i = 0; i < 3; i++) {
        final y = h * (.25 + i * .25);
        canvas.drawLine(Offset(w * .18, y), Offset(w * .8, y), paint);
        canvas.drawCircle(Offset(w * .12, y), w * .03, paint);
      }
    case BlenderGlyph.properties:
      for (final y in <double>[.3, .68]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * .15, h * (y - .11), w * .7, h * .22),
            Radius.circular(w * .1),
          ),
          paint,
        );
      }
    case BlenderGlyph.spreadsheet:
      canvas.drawRect(Rect.fromLTWH(w * .12, h * .15, w * .76, h * .7), paint);
      for (var i = 1; i < 3; i++) {
        canvas.drawLine(
          Offset(w * (.12 + i * .25), h * .15),
          Offset(w * (.12 + i * .25), h * .85),
          paint,
        );
        canvas.drawLine(
          Offset(w * .12, h * (.15 + i * .23)),
          Offset(w * .88, h * (.15 + i * .23)),
          paint,
        );
      }
    case BlenderGlyph.collection:
      path.moveTo(w * .12, h * .3);
      path.lineTo(w * .42, h * .3);
      path.lineTo(w * .5, h * .4);
      path.lineTo(w * .88, h * .4);
      path.lineTo(w * .8, h * .78);
      path.lineTo(w * .18, h * .78);
      path.close();
      canvas.drawPath(path, paint);
      canvas.drawLine(Offset(w * .28, h * .48), Offset(w * .7, h * .48), paint);
    case BlenderGlyph.object:
      canvas.drawCircle(center, w * .28, paint);
      canvas.drawRect(Rect.fromLTWH(w * .36, h * .36, w * .28, h * .28), paint);
    case BlenderGlyph.mesh:
      path.moveTo(center.dx, h * .14);
      path.lineTo(w * .82, h * .32);
      path.lineTo(w * .82, h * .68);
      path.lineTo(center.dx, h * .86);
      path.lineTo(w * .18, h * .68);
      path.lineTo(w * .18, h * .32);
      path.close();
      canvas.drawPath(path, paint);
      canvas.drawLine(
        Offset(center.dx, h * .14),
        Offset(center.dx, h * .5),
        paint,
      );
      canvas.drawLine(
        Offset(w * .18, h * .32),
        Offset(center.dx, h * .5),
        paint,
      );
      canvas.drawLine(
        Offset(w * .82, h * .32),
        Offset(center.dx, h * .5),
        paint,
      );
    case BlenderGlyph.curve:
      path.moveTo(w * .16, h * .74);
      path.cubicTo(w * .28, h * .16, w * .68, h * .84, w * .84, h * .26);
      canvas.drawPath(path, paint);
      canvas.drawCircle(Offset(w * .16, h * .74), w * .08, paint);
      canvas.drawCircle(Offset(w * .84, h * .26), w * .08, paint);
    case BlenderGlyph.lattice:
      canvas.drawRect(Rect.fromLTWH(w * .16, h * .16, w * .68, h * .68), paint);
      for (var index = 1; index < 3; index++) {
        final offset = w * (.16 + index * .226);
        canvas.drawLine(
          Offset(offset, h * .16),
          Offset(offset, h * .84),
          paint,
        );
        canvas.drawLine(
          Offset(w * .16, offset),
          Offset(w * .84, offset),
          paint,
        );
      }
    case BlenderGlyph.curves:
      for (var strand = 0; strand < 3; strand++) {
        final y = h * (.28 + strand * .22);
        path.moveTo(w * .16, y);
        path.cubicTo(w * .36, y - h * .12, w * .62, y + h * .12, w * .84, y);
        canvas.drawPath(path, paint);
      }
    case BlenderGlyph.pointcloud:
      for (final point in const <Offset>[
        Offset(.25, .34),
        Offset(.52, .22),
        Offset(.75, .4),
        Offset(.36, .68),
        Offset(.68, .76),
      ]) {
        canvas.drawCircle(Offset(w * point.dx, h * point.dy), w * .08, paint);
      }
    case BlenderGlyph.speaker:
      canvas.drawCircle(center, w * .27, paint);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: w * .42),
        -math.pi * .35,
        math.pi * .7,
        false,
        paint,
      );
      canvas.drawLine(Offset(w * .5, h * .68), Offset(w * .5, h * .86), paint);
    case BlenderGlyph.volume:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .16, h * .18, w * .68, h * .64),
          Radius.circular(w * .06),
        ),
        paint,
      );
      canvas.drawLine(Offset(w * .3, h * .36), Offset(w * .7, h * .36), paint);
      canvas.drawLine(Offset(w * .3, h * .64), Offset(w * .7, h * .64), paint);
    case BlenderGlyph.empty:
      canvas.drawLine(
        Offset(w * .16, h * .16),
        Offset(w * .84, h * .84),
        paint,
      );
      canvas.drawLine(
        Offset(w * .84, h * .16),
        Offset(w * .16, h * .84),
        paint,
      );
      canvas.drawCircle(center, w * .1, paint);
    case BlenderGlyph.lightprobe:
      canvas.drawCircle(center, w * .28, paint);
      canvas.drawLine(Offset(w * .5, h * .08), Offset(w * .5, h * .24), paint);
      canvas.drawLine(Offset(w * .5, h * .76), Offset(w * .5, h * .92), paint);
      canvas.drawLine(Offset(w * .08, h * .5), Offset(w * .24, h * .5), paint);
      canvas.drawLine(Offset(w * .76, h * .5), Offset(w * .92, h * .5), paint);
    case BlenderGlyph.greasepencil:
      path.moveTo(w * .2, h * .78);
      path.cubicTo(w * .18, h * .48, w * .3, h * .18, w * .52, h * .22);
      path.cubicTo(w * .74, h * .26, w * .82, h * .52, w * .78, h * .8);
      canvas.drawPath(path, paint);
      canvas.drawLine(
        Offset(w * .28, h * .62),
        Offset(w * .72, h * .62),
        paint,
      );
    case BlenderGlyph.metaball:
      canvas.drawCircle(center, w * .28, paint);
      canvas.drawCircle(Offset(w * .7, h * .32), w * .16, paint);
      canvas.drawCircle(Offset(w * .3, h * .68), w * .12, paint);
    case BlenderGlyph.armature:
      canvas.drawCircle(Offset(w * .5, h * .2), w * .1, paint);
      canvas.drawLine(Offset(w * .5, h * .3), Offset(w * .5, h * .65), paint);
      canvas.drawLine(Offset(w * .5, h * .38), Offset(w * .25, h * .55), paint);
      canvas.drawLine(Offset(w * .5, h * .38), Offset(w * .75, h * .55), paint);
      canvas.drawLine(Offset(w * .5, h * .65), Offset(w * .3, h * .86), paint);
      canvas.drawLine(Offset(w * .5, h * .65), Offset(w * .7, h * .86), paint);
    case BlenderGlyph.bone:
      canvas.drawCircle(Offset(w * .28, h * .24), w * .13, paint);
      canvas.drawCircle(Offset(w * .72, h * .76), w * .13, paint);
      path.moveTo(w * .34, h * .3);
      path.lineTo(w * .66, h * .7);
      canvas.drawPath(path, paint);
    case BlenderGlyph.shaderfx:
      canvas.drawRect(Rect.fromLTWH(w * .14, h * .18, w * .72, h * .64), paint);
      canvas.drawLine(
        Offset(w * .28, h * .36),
        Offset(w * .72, h * .36),
        paint,
      );
      canvas.drawLine(
        Offset(w * .28, h * .64),
        Offset(w * .62, h * .64),
        paint,
      );
    default:
      return false;
  }
  return true;
}
