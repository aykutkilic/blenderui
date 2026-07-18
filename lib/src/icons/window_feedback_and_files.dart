part of '../icons.dart';

bool _paintWindowFeedbackAndFilesGlyph(
  BlenderGlyph glyph,
  _BlenderIconPaintContext icon,
) {
  final canvas = icon.canvas;
  final paint = icon.paint;
  final w = icon.size.width;
  final h = icon.size.height;
  final center = Offset(w / 2, h / 2);
  final path = Path();
  switch (glyph) {
    case BlenderGlyph.refresh:
    case BlenderGlyph.sync:
      canvas.drawArc(
        Rect.fromLTWH(w * .18, h * .18, w * .64, h * .64),
        -.8,
        4.8,
        false,
        paint,
      );
      path.moveTo(w * .72, h * .18);
      path.lineTo(w * .84, h * .2);
      path.lineTo(w * .78, h * .34);
      canvas.drawPath(path, paint);
    case BlenderGlyph.maximize:
      canvas.drawLine(
        Offset(w * .18, h * .36),
        Offset(w * .18, h * .18),
        paint,
      );
      canvas.drawLine(
        Offset(w * .18, h * .18),
        Offset(w * .36, h * .18),
        paint,
      );
      canvas.drawLine(
        Offset(w * .64, h * .18),
        Offset(w * .82, h * .18),
        paint,
      );
      canvas.drawLine(
        Offset(w * .82, h * .18),
        Offset(w * .82, h * .36),
        paint,
      );
      canvas.drawLine(
        Offset(w * .18, h * .64),
        Offset(w * .18, h * .82),
        paint,
      );
      canvas.drawLine(
        Offset(w * .18, h * .82),
        Offset(w * .36, h * .82),
        paint,
      );
      canvas.drawLine(
        Offset(w * .64, h * .82),
        Offset(w * .82, h * .82),
        paint,
      );
      canvas.drawLine(
        Offset(w * .82, h * .82),
        Offset(w * .82, h * .64),
        paint,
      );
    case BlenderGlyph.minimize:
      canvas.drawLine(Offset(w * .2, h * .65), Offset(w * .8, h * .65), paint);
    case BlenderGlyph.split:
      canvas.drawRect(Rect.fromLTWH(w * .14, h * .2, w * .32, h * .6), paint);
      canvas.drawRect(Rect.fromLTWH(w * .54, h * .2, w * .32, h * .6), paint);
    case BlenderGlyph.more:
      for (final x in <double>[.28, .5, .72]) {
        canvas.drawCircle(Offset(w * x, center.dy), w * .07, paint);
      }
    case BlenderGlyph.color:
      canvas.drawCircle(Offset(w * .34, h * .38), w * .2, paint);
      canvas.drawCircle(Offset(w * .66, h * .38), w * .2, paint);
      canvas.drawCircle(Offset(w * .5, h * .68), w * .2, paint);
    case BlenderGlyph.eyedropper:
      canvas.drawLine(
        Offset(w * .28, h * .72),
        Offset(w * .72, h * .28),
        paint,
      );
      canvas.drawLine(
        Offset(w * .22, h * .78),
        Offset(w * .42, h * .78),
        paint,
      );
      canvas.drawLine(
        Offset(w * .62, h * .22),
        Offset(w * .78, h * .38),
        paint,
      );
    case BlenderGlyph.linkBroken:
      canvas.drawLine(Offset(w * .2, h * .7), Offset(w * .42, h * .48), paint);
      canvas.drawLine(Offset(w * .58, h * .52), Offset(w * .8, h * .3), paint);
      canvas.drawLine(Offset(w * .42, h * .3), Offset(w * .7, h * .58), paint);
    case BlenderGlyph.keyframe:
      path.moveTo(center.dx, h * .16);
      path.lineTo(w * .84, center.dy);
      path.lineTo(center.dx, h * .84);
      path.lineTo(w * .16, center.dy);
      path.close();
      canvas.drawPath(path, paint);
    case BlenderGlyph.warning:
    case BlenderGlyph.warningFilled:
      path.moveTo(center.dx, h * .14);
      path.lineTo(w * .86, h * .82);
      path.lineTo(w * .14, h * .82);
      path.close();
      canvas.drawPath(path, paint);
      canvas.drawLine(
        Offset(center.dx, h * .34),
        Offset(center.dx, h * .6),
        paint,
      );
      canvas.drawCircle(Offset(center.dx, h * .7), w * .03, paint);
    case BlenderGlyph.info:
    case BlenderGlyph.statusInfo:
      canvas.drawCircle(center, w * .34, paint);
      canvas.drawLine(
        Offset(center.dx, h * .42),
        Offset(center.dx, h * .68),
        paint,
      );
      canvas.drawCircle(Offset(center.dx, h * .3), w * .03, paint);
    case BlenderGlyph.error:
    case BlenderGlyph.errorFilled:
      canvas.drawCircle(center, w * .34, paint);
      canvas.drawLine(
        Offset(w * .34, h * .34),
        Offset(w * .66, h * .66),
        paint,
      );
      canvas.drawLine(
        Offset(w * .66, h * .34),
        Offset(w * .34, h * .66),
        paint,
      );
    case BlenderGlyph.checkCircle:
      canvas.drawCircle(center, w * .34, paint);
      path.moveTo(w * .28, h * .5);
      path.lineTo(w * .44, h * .66);
      path.lineTo(w * .74, h * .34);
      canvas.drawPath(path, paint);
    case BlenderGlyph.home:
      path.moveTo(w * .14, h * .46);
      path.lineTo(center.dx, h * .18);
      path.lineTo(w * .86, h * .46);
      path.lineTo(w * .76, h * .46);
      path.lineTo(w * .76, h * .82);
      path.lineTo(w * .24, h * .82);
      path.lineTo(w * .24, h * .46);
      path.close();
      canvas.drawPath(path, paint);
    case BlenderGlyph.file:
    case BlenderGlyph.fileBlend:
    case BlenderGlyph.fileBackup:
      path.moveTo(w * .24, h * .14);
      path.lineTo(w * .62, h * .14);
      path.lineTo(w * .78, h * .3);
      path.lineTo(w * .78, h * .86);
      path.lineTo(w * .24, h * .86);
      path.close();
      canvas.drawPath(path, paint);
      canvas.drawLine(Offset(w * .62, h * .14), Offset(w * .62, h * .3), paint);
      canvas.drawLine(Offset(w * .62, h * .3), Offset(w * .78, h * .3), paint);
    case BlenderGlyph.save:
      canvas.drawRect(Rect.fromLTWH(w * .18, h * .16, w * .64, h * .68), paint);
      canvas.drawRect(Rect.fromLTWH(w * .32, h * .2, w * .36, h * .2), paint);
      canvas.drawRect(Rect.fromLTWH(w * .3, h * .58, w * .4, h * .26), paint);
    case BlenderGlyph.open:
      path.moveTo(w * .14, h * .3);
      path.lineTo(w * .42, h * .3);
      path.lineTo(w * .5, h * .4);
      path.lineTo(w * .86, h * .4);
      path.lineTo(w * .78, h * .8);
      path.lineTo(w * .18, h * .8);
      path.close();
      canvas.drawPath(path, paint);
    case BlenderGlyph.export:
      canvas.drawRect(Rect.fromLTWH(w * .18, h * .18, w * .64, h * .64), paint);
      canvas.drawLine(Offset(w * .5, h * .72), Offset(w * .5, h * .28), paint);
      path.moveTo(w * .3, h * .42);
      path.lineTo(w * .5, h * .22);
      path.lineTo(w * .7, h * .42);
      canvas.drawPath(path, paint);
    case BlenderGlyph.grid:
      for (var i = 1; i < 3; i++) {
        canvas.drawLine(
          Offset(w * i / 3, h * .14),
          Offset(w * i / 3, h * .86),
          paint,
        );
        canvas.drawLine(
          Offset(w * .14, h * i / 3),
          Offset(w * .86, h * i / 3),
          paint,
        );
      }
      canvas.drawRect(Rect.fromLTWH(w * .14, h * .14, w * .72, h * .72), paint);
    case BlenderGlyph.wireframe:
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
    default:
      return false;
  }
  return true;
}
