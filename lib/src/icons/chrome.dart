part of '../icons.dart';

bool _paintChromeGlyph(BlenderGlyph glyph, _BlenderIconPaintContext icon) {
  final canvas = icon.canvas;
  final paint = icon.paint;
  final w = icon.size.width;
  final h = icon.size.height;
  final center = Offset(w / 2, h / 2);
  final path = Path();
  switch (glyph) {
    case BlenderGlyph.menu:
      for (final y in <double>[.25, .5, .75]) {
        canvas.drawLine(Offset(w * .18, h * y), Offset(w * .82, h * y), paint);
      }
    case BlenderGlyph.close:
      canvas.drawLine(
        Offset(w * .22, h * .22),
        Offset(w * .78, h * .78),
        paint,
      );
      canvas.drawLine(
        Offset(w * .78, h * .22),
        Offset(w * .22, h * .78),
        paint,
      );
    case BlenderGlyph.chevronDown:
      path.moveTo(w * .22, h * .38);
      path.lineTo(center.dx, h * .64);
      path.lineTo(w * .78, h * .38);
      canvas.drawPath(path, paint);
    case BlenderGlyph.chevronUp:
      path.moveTo(w * .22, h * .62);
      path.lineTo(center.dx, h * .36);
      path.lineTo(w * .78, h * .62);
      canvas.drawPath(path, paint);
    case BlenderGlyph.chevronRight:
      path.moveTo(w * .38, h * .22);
      path.lineTo(w * .64, center.dy);
      path.lineTo(w * .38, h * .78);
      canvas.drawPath(path, paint);
    case BlenderGlyph.panelDisclosureDown:
      path.moveTo(w * .28, h * .38);
      path.lineTo(center.dx, h * .62);
      path.lineTo(w * .72, h * .38);
      canvas.drawPath(path, paint);
    case BlenderGlyph.panelDisclosureRight:
      path.moveTo(w * .38, h * .28);
      path.lineTo(w * .62, center.dy);
      path.lineTo(w * .38, h * .72);
      canvas.drawPath(path, paint);
    case BlenderGlyph.plus:
      canvas.drawLine(
        Offset(w * .22, center.dy),
        Offset(w * .78, center.dy),
        paint,
      );
      canvas.drawLine(
        Offset(center.dx, h * .22),
        Offset(center.dx, h * .78),
        paint,
      );
    case BlenderGlyph.minus:
      canvas.drawLine(
        Offset(w * .22, center.dy),
        Offset(w * .78, center.dy),
        paint,
      );
    case BlenderGlyph.search:
      canvas.drawCircle(Offset(w * .43, h * .43), w * .24, paint);
      canvas.drawLine(Offset(w * .6, h * .6), Offset(w * .82, h * .82), paint);
    case BlenderGlyph.settings:
    case BlenderGlyph.preferences:
      canvas.drawCircle(center, w * .22, paint);
      for (var i = 0; i < 8; i++) {
        final angle = i * math.pi / 4;
        final from = Offset(
          center.dx + math.cos(angle) * w * .32,
          center.dy + math.sin(angle) * h * .32,
        );
        final to = Offset(
          center.dx + math.cos(angle) * w * .43,
          center.dy + math.sin(angle) * h * .43,
        );
        canvas.drawLine(from, to, paint);
      }
    case BlenderGlyph.arrowLeftRight:
      canvas.drawLine(
        Offset(w * .18, h * .35),
        Offset(w * .82, h * .35),
        paint,
      );
      canvas.drawLine(Offset(w * .18, h * .35), Offset(w * .32, h * .2), paint);
      canvas.drawLine(Offset(w * .18, h * .35), Offset(w * .32, h * .5), paint);
      canvas.drawLine(
        Offset(w * .82, h * .65),
        Offset(w * .18, h * .65),
        paint,
      );
      canvas.drawLine(Offset(w * .82, h * .65), Offset(w * .68, h * .5), paint);
      canvas.drawLine(Offset(w * .82, h * .65), Offset(w * .68, h * .8), paint);
    case BlenderGlyph.preset:
      for (final entry in <({double y, double start, double end, double knob})>[
        (y: .25, start: .16, end: .84, knob: .58),
        (y: .5, start: .16, end: .84, knob: .35),
        (y: .75, start: .16, end: .84, knob: .68),
      ]) {
        canvas.drawLine(
          Offset(w * entry.start, h * entry.y),
          Offset(w * entry.end, h * entry.y),
          paint,
        );
        canvas.drawCircle(Offset(w * entry.knob, h * entry.y), w * .1, paint);
      }
    case BlenderGlyph.folder:
      path.moveTo(w * .14, h * .3);
      path.lineTo(w * .42, h * .3);
      path.lineTo(w * .5, h * .4);
      path.lineTo(w * .86, h * .4);
      path.lineTo(w * .8, h * .78);
      path.lineTo(w * .18, h * .78);
      path.close();
      canvas.drawPath(path, paint);
    default:
      return false;
  }
  return true;
}
