part of '../icons.dart';

bool _paintInputGlyph(BlenderGlyph glyph, _BlenderIconPaintContext icon) {
  final canvas = icon.canvas;
  final paint = icon.paint;
  final w = icon.size.width;
  final h = icon.size.height;
  final center = Offset(w / 2, h / 2);
  final path = Path();
  final color = icon.color;
  switch (glyph) {
    case BlenderGlyph.play:
      path.moveTo(w * .34, h * .2);
      path.lineTo(w * .74, center.dy);
      path.lineTo(w * .34, h * .8);
      path.close();
      canvas.drawPath(path, paint);
    case BlenderGlyph.pause:
      canvas.drawRect(Rect.fromLTWH(w * .28, h * .22, w * .15, h * .56), paint);
      canvas.drawRect(Rect.fromLTWH(w * .57, h * .22, w * .15, h * .56), paint);
    case BlenderGlyph.eye:
      path.moveTo(w * .12, center.dy);
      path.quadraticBezierTo(center.dx, h * .12, w * .88, center.dy);
      path.quadraticBezierTo(center.dx, h * .88, w * .12, center.dy);
      canvas.drawPath(path, paint);
      canvas.drawCircle(center, w * .13, paint);
    case BlenderGlyph.lock:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .2, h * .42, w * .6, h * .42),
          Radius.circular(w * .06),
        ),
        paint,
      );
      path.moveTo(w * .34, h * .42);
      path.arcToPoint(
        Offset(w * .66, h * .42),
        radius: Radius.circular(w * .16),
      );
      canvas.drawPath(path, paint);
    case BlenderGlyph.unlock:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .2, h * .42, w * .6, h * .42),
          Radius.circular(w * .06),
        ),
        paint,
      );
      path.moveTo(w * .34, h * .42);
      path.lineTo(w * .34, h * .3);
      path.arcToPoint(
        Offset(w * .72, h * .3),
        radius: Radius.circular(w * .19),
      );
      canvas.drawPath(path, paint);
    case BlenderGlyph.link:
      canvas.drawOval(Rect.fromLTWH(w * .1, h * .36, w * .48, h * .28), paint);
    case BlenderGlyph.internet:
    case BlenderGlyph.internetOffline:
      canvas.drawCircle(center, w * .34, paint);
      canvas.drawOval(
        Rect.fromCenter(center: center, width: w * .34, height: h * .68),
        paint,
      );
      canvas.drawLine(
        Offset(w * .16, center.dy),
        Offset(w * .84, center.dy),
        paint,
      );
    case BlenderGlyph.diskDrive:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .16, h * .22, w * .68, h * .56),
          Radius.circular(w * .05),
        ),
        paint,
      );
      canvas.drawLine(
        Offset(w * .25, h * .62),
        Offset(w * .75, h * .62),
        paint,
      );
    case BlenderGlyph.keyShift:
    case BlenderGlyph.keyControl:
    case BlenderGlyph.keyOption:
    case BlenderGlyph.keyCommand:
    case BlenderGlyph.keyWindows:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .12, h * .12, w * .76, h * .76),
          Radius.circular(w * .08),
        ),
        paint,
      );
      final keyText = switch (glyph) {
        BlenderGlyph.keyShift => '⇧',
        BlenderGlyph.keyControl => '⌃',
        BlenderGlyph.keyOption => '⌥',
        BlenderGlyph.keyCommand => '⌘',
        BlenderGlyph.keyWindows => '⊞',
        _ => '',
      };
      final keyPainter = TextPainter(
        text: TextSpan(
          text: keyText,
          style: TextStyle(color: color, fontSize: h * .55),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      keyPainter.paint(
        canvas,
        Offset((w - keyPainter.width) / 2, (h - keyPainter.height) / 2),
      );
    case BlenderGlyph.pointer:
      path.moveTo(w * .2, h * .16);
      path.lineTo(w * .72, h * .42);
      path.lineTo(w * .48, h * .5);
      path.lineTo(w * .4, h * .76);
      path.close();
      canvas.drawPath(path, paint);
      canvas.drawLine(Offset(w * .48, h * .5), Offset(w * .82, h * .82), paint);
      canvas.drawOval(Rect.fromLTWH(w * .42, h * .36, w * .48, h * .28), paint);
    case BlenderGlyph.mouseLeft:
    case BlenderGlyph.mouseRight:
    case BlenderGlyph.mouseMiddle:
    case BlenderGlyph.mouseLeftDrag:
    case BlenderGlyph.mouseRightDrag:
    case BlenderGlyph.mouseMiddleDrag:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .25, h * .12, w * .5, h * .7),
          Radius.circular(w * .14),
        ),
        paint,
      );
      canvas.drawLine(
        Offset(center.dx, h * .12),
        Offset(center.dx, h * .42),
        paint,
      );
      if (glyph == BlenderGlyph.mouseLeftDrag ||
          glyph == BlenderGlyph.mouseRightDrag ||
          glyph == BlenderGlyph.mouseMiddleDrag) {
        canvas.drawLine(
          Offset(w * .5, h * .86),
          Offset(w * .5, h * .98),
          paint,
        );
      }
    case BlenderGlyph.check:
      path.moveTo(w * .2, h * .52);
      path.lineTo(w * .42, h * .74);
      path.lineTo(w * .8, h * .28);
      canvas.drawPath(path, paint);
    case BlenderGlyph.radio:
      canvas.drawCircle(center, w * .34, paint);
      canvas.drawCircle(center, w * .14, paint);
    case BlenderGlyph.dragHandle:
    case BlenderGlyph.grip:
      for (final y in <double>[.3, .5, .7]) {
        canvas.drawCircle(Offset(w * .35, h * y), w * .06, paint);
        canvas.drawCircle(Offset(w * .65, h * y), w * .06, paint);
      }
    default:
      return false;
  }
  return true;
}
