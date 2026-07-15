import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'icon_source.dart';
import 'theme.dart';

enum BlenderGlyph {
  menu,
  close,
  chevronDown,
  chevronUp,
  chevronRight,
  panelDisclosureDown,
  panelDisclosureRight,
  plus,
  minus,
  search,
  settings,
  preferences,
  arrowLeftRight,
  preset,
  folder,
  play,
  pause,
  eye,
  lock,
  unlock,
  link,
  internet,
  internetOffline,
  diskDrive,
  keyShift,
  keyControl,
  keyOption,
  keyCommand,
  keyWindows,
  mouseLeft,
  mouseRight,
  mouseMiddle,
  mouseLeftDrag,
  mouseRightDrag,
  mouseMiddleDrag,
  pointer,
  selectBox,
  selectExtend,
  selectSubtract,
  selectDifference,
  selectIntersect,
  check,
  radio,
  dragHandle,
  cube,
  image,
  texture,
  uv,
  node,
  timeline,
  sequence,
  action,
  movie,
  text,
  console,
  outliner,
  properties,
  spreadsheet,
  collection,
  object,
  camera,
  light,
  material,
  modifier,
  scene,
  world,
  render,
  output,
  tool,
  transform,
  rotate,
  scale,
  pan,
  zoom,
  deleteIcon,
  duplicate,
  record,
  stepBack,
  stepForward,
  snap,
  pin,
  filter,
  sort,
  sortDescending,
  sortAlphabetically,
  grip,
  refresh,
  maximize,
  minimize,
  split,
  more,
  color,
  eyedropper,
  linkBroken,
  keyframe,
  warning,
  warningFilled,
  info,
  statusInfo,
  error,
  errorFilled,
  checkCircle,
  home,
  file,
  fileBlend,
  fileBackup,
  save,
  open,
  export,
  grid,
  wireframe,
}

const Map<BlenderGlyph, String> _blenderIconFileNames = <BlenderGlyph, String>{
  BlenderGlyph.menu: 'menu_panel.svg',
  BlenderGlyph.close: 'x.svg',
  BlenderGlyph.chevronDown: 'disclosure_tri_down.svg',
  BlenderGlyph.chevronUp: 'tria_up.svg',
  BlenderGlyph.chevronRight: 'disclosure_tri_right.svg',
  BlenderGlyph.panelDisclosureDown: 'downarrow_hlt.svg',
  BlenderGlyph.panelDisclosureRight: 'rightarrow.svg',
  BlenderGlyph.plus: 'add.svg',
  BlenderGlyph.minus: 'remove.svg',
  BlenderGlyph.search: 'viewzoom.svg',
  BlenderGlyph.settings: 'settings.svg',
  BlenderGlyph.preferences: 'preferences.svg',
  BlenderGlyph.arrowLeftRight: 'arrow_leftright.svg',
  BlenderGlyph.preset: 'preset.svg',
  BlenderGlyph.folder: 'file_folder.svg',
  BlenderGlyph.play: 'play.svg',
  BlenderGlyph.pause: 'pause.svg',
  BlenderGlyph.eye: 'restrict_view_on.svg',
  BlenderGlyph.lock: 'locked.svg',
  BlenderGlyph.unlock: 'decorate_unlocked.svg',
  BlenderGlyph.link: 'linked.svg',
  BlenderGlyph.internet: 'internet.svg',
  BlenderGlyph.internetOffline: 'internet_offline.svg',
  BlenderGlyph.diskDrive: 'disk_drive.svg',
  BlenderGlyph.keyShift: 'key_shift.svg',
  BlenderGlyph.keyControl: 'key_control.svg',
  BlenderGlyph.keyOption: 'key_option.svg',
  BlenderGlyph.keyCommand: 'key_command.svg',
  BlenderGlyph.keyWindows: 'key_windows.svg',
  BlenderGlyph.mouseLeft: 'mouse_lmb.svg',
  BlenderGlyph.mouseRight: 'mouse_rmb.svg',
  BlenderGlyph.mouseMiddle: 'mouse_mmb.svg',
  BlenderGlyph.mouseLeftDrag: 'mouse_lmb_drag.svg',
  BlenderGlyph.mouseRightDrag: 'mouse_rmb_drag.svg',
  BlenderGlyph.mouseMiddleDrag: 'mouse_mmb_drag.svg',
  BlenderGlyph.pointer: 'action_tweak.svg',
  BlenderGlyph.selectBox: 'select_set.svg',
  BlenderGlyph.selectExtend: 'select_extend.svg',
  BlenderGlyph.selectSubtract: 'select_subtract.svg',
  BlenderGlyph.selectDifference: 'select_difference.svg',
  BlenderGlyph.selectIntersect: 'select_intersect.svg',
  BlenderGlyph.check: 'checkmark.svg',
  BlenderGlyph.radio: 'radiobut_on.svg',
  BlenderGlyph.dragHandle: 'grip.svg',
  BlenderGlyph.cube: 'cube.svg',
  BlenderGlyph.image: 'image.svg',
  BlenderGlyph.texture: 'texture.svg',
  BlenderGlyph.uv: 'uv.svg',
  BlenderGlyph.node: 'node.svg',
  BlenderGlyph.timeline: 'time.svg',
  BlenderGlyph.sequence: 'sequence.svg',
  BlenderGlyph.action: 'action.svg',
  BlenderGlyph.movie: 'file_movie.svg',
  BlenderGlyph.text: 'text.svg',
  BlenderGlyph.console: 'console.svg',
  BlenderGlyph.outliner: 'outliner.svg',
  BlenderGlyph.properties: 'properties.svg',
  BlenderGlyph.spreadsheet: 'spreadsheet.svg',
  BlenderGlyph.collection: 'outliner_collection.svg',
  BlenderGlyph.object: 'object_data.svg',
  BlenderGlyph.camera: 'camera_data.svg',
  BlenderGlyph.light: 'light.svg',
  BlenderGlyph.material: 'material.svg',
  BlenderGlyph.modifier: 'modifier.svg',
  BlenderGlyph.scene: 'scene.svg',
  BlenderGlyph.world: 'world.svg',
  BlenderGlyph.render: 'render_still.svg',
  BlenderGlyph.output: 'output.svg',
  BlenderGlyph.tool: 'tool_settings.svg',
  BlenderGlyph.transform: 'empty_arrows.svg',
  BlenderGlyph.rotate: 'gesture_rotate.svg',
  BlenderGlyph.scale: 'gesture_zoom.svg',
  BlenderGlyph.pan: 'view_pan.svg',
  BlenderGlyph.zoom: 'view_zoom.svg',
  BlenderGlyph.deleteIcon: 'trash.svg',
  BlenderGlyph.duplicate: 'duplicate.svg',
  BlenderGlyph.record: 'record_on.svg',
  BlenderGlyph.stepBack: 'frame_prev.svg',
  BlenderGlyph.stepForward: 'frame_next.svg',
  BlenderGlyph.snap: 'snap_on.svg',
  BlenderGlyph.pin: 'pinned.svg',
  BlenderGlyph.filter: 'filter.svg',
  BlenderGlyph.sort: 'sort_asc.svg',
  BlenderGlyph.sortDescending: 'sort_desc.svg',
  BlenderGlyph.sortAlphabetically: 'sortalpha.svg',
  BlenderGlyph.grip: 'grip.svg',
  BlenderGlyph.refresh: 'file_refresh.svg',
  BlenderGlyph.maximize: 'fullscreen_enter.svg',
  BlenderGlyph.minimize: 'fullscreen_exit.svg',
  BlenderGlyph.split: 'split_horizontal.svg',
  BlenderGlyph.more: 'three_dots.svg',
  BlenderGlyph.color: 'color.svg',
  BlenderGlyph.eyedropper: 'eyedropper.svg',
  BlenderGlyph.linkBroken: 'unlinked.svg',
  BlenderGlyph.keyframe: 'keyframe.svg',
  BlenderGlyph.warning: 'warning_large.svg',
  BlenderGlyph.warningFilled: 'status_warning_filled.svg',
  BlenderGlyph.info: 'info.svg',
  BlenderGlyph.statusInfo: 'status_info.svg',
  BlenderGlyph.error: 'error.svg',
  BlenderGlyph.errorFilled: 'status_error_filled.svg',
  BlenderGlyph.home: 'home.svg',
  BlenderGlyph.file: 'file_blank.svg',
  BlenderGlyph.fileBlend: 'file_blend.svg',
  BlenderGlyph.fileBackup: 'file_backup.svg',
  BlenderGlyph.save: 'file_tick.svg',
  BlenderGlyph.open: 'file.svg',
  BlenderGlyph.export: 'export.svg',
  BlenderGlyph.grid: 'grid.svg',
  BlenderGlyph.wireframe: 'shading_wire.svg',
};

class BlenderIcon extends StatelessWidget {
  const BlenderIcon(this.glyph, {super.key, this.size, this.color});

  final BlenderGlyph glyph;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconTheme = BlenderTheme.of(context).iconTheme;
    final effectiveSize = size ?? iconTheme.size;
    final effectiveColor =
        color ??
        iconTheme.color ??
        DefaultTextStyle.of(context).style.color ??
        const Color(0xFFE6E6E6);
    final sourceFileName = _blenderIconFileNames[glyph];
    if (sourceFileName != null) {
      final sourcePath = BlenderIconSource.pathFor(sourceFileName);
      if (sourcePath != null) {
        final sourceIcon = BlenderIconSource.buildIcon(
          path: sourcePath,
          size: effectiveSize,
          color: effectiveColor,
        );
        if (sourceIcon != null) {
          return sourceIcon;
        }
      }
    }
    return CustomPaint(
      size: Size.square(effectiveSize),
      painter: _BlenderIconPainter(glyph, effectiveColor),
    );
  }
}

class _BlenderIconPainter extends CustomPainter {
  _BlenderIconPainter(this.glyph, this.color);

  final BlenderGlyph glyph;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = math.max(1, size.shortestSide * .12);
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final path = Path();

    switch (glyph) {
      case BlenderGlyph.menu:
        for (final y in <double>[.25, .5, .75]) {
          canvas.drawLine(
            Offset(w * .18, h * y),
            Offset(w * .82, h * y),
            paint,
          );
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
        path.moveTo(w * .2, h * .36);
        path.lineTo(center.dx, h * .66);
        path.lineTo(w * .8, h * .36);
        canvas.drawPath(path, paint);
      case BlenderGlyph.panelDisclosureRight:
        path.moveTo(w * .36, h * .2);
        path.lineTo(w * .66, center.dy);
        path.lineTo(w * .36, h * .8);
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
        canvas.drawLine(
          Offset(w * .6, h * .6),
          Offset(w * .82, h * .82),
          paint,
        );
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
        canvas.drawLine(
          Offset(w * .18, h * .35),
          Offset(w * .32, h * .2),
          paint,
        );
        canvas.drawLine(
          Offset(w * .18, h * .35),
          Offset(w * .32, h * .5),
          paint,
        );
        canvas.drawLine(
          Offset(w * .82, h * .65),
          Offset(w * .18, h * .65),
          paint,
        );
        canvas.drawLine(
          Offset(w * .82, h * .65),
          Offset(w * .68, h * .5),
          paint,
        );
        canvas.drawLine(
          Offset(w * .82, h * .65),
          Offset(w * .68, h * .8),
          paint,
        );
      case BlenderGlyph.preset:
        for (final entry
            in <({double y, double start, double end, double knob})>[
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
      case BlenderGlyph.play:
        path.moveTo(w * .34, h * .2);
        path.lineTo(w * .74, center.dy);
        path.lineTo(w * .34, h * .8);
        path.close();
        canvas.drawPath(path, paint);
      case BlenderGlyph.pause:
        canvas.drawRect(
          Rect.fromLTWH(w * .28, h * .22, w * .15, h * .56),
          paint,
        );
        canvas.drawRect(
          Rect.fromLTWH(w * .57, h * .22, w * .15, h * .56),
          paint,
        );
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
        canvas.drawOval(
          Rect.fromLTWH(w * .1, h * .36, w * .48, h * .28),
          paint,
        );
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
        canvas.drawLine(
          Offset(w * .48, h * .5),
          Offset(w * .82, h * .82),
          paint,
        );
        canvas.drawOval(
          Rect.fromLTWH(w * .42, h * .36, w * .48, h * .28),
          paint,
        );
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
        canvas.drawLine(
          Offset(w * .2, h * .3),
          Offset(center.dx, h * .5),
          paint,
        );
        canvas.drawLine(
          Offset(w * .8, h * .3),
          Offset(center.dx, h * .5),
          paint,
        );
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
      case BlenderGlyph.texture:
        canvas.drawRect(
          Rect.fromLTWH(w * .16, h * .16, w * .68, h * .68),
          paint,
        );
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
        canvas.drawLine(
          Offset(w * .12, h * .7),
          Offset(w * .88, h * .7),
          paint,
        );
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
        canvas.drawLine(
          Offset(w * .48, h * .7),
          Offset(w * .82, h * .7),
          paint,
        );
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
        canvas.drawRect(
          Rect.fromLTWH(w * .2, h * .34, w * .42, h * .48),
          paint,
        );
        canvas.drawRect(
          Rect.fromLTWH(w * .42, h * .16, w * .42, h * .48),
          paint,
        );
      case BlenderGlyph.selectSubtract:
        canvas.drawRect(
          Rect.fromLTWH(w * .38, h * .16, w * .46, h * .48),
          paint,
        );
        canvas.drawLine(
          Offset(w * .2, h * .34),
          Offset(w * .62, h * .34),
          paint,
        );
        canvas.drawLine(
          Offset(w * .2, h * .34),
          Offset(w * .2, h * .82),
          paint,
        );
        canvas.drawLine(
          Offset(w * .2, h * .82),
          Offset(w * .62, h * .82),
          paint,
        );
      case BlenderGlyph.selectDifference:
        canvas.drawRect(
          Rect.fromLTWH(w * .16, h * .34, w * .46, h * .48),
          paint,
        );
        canvas.drawRect(
          Rect.fromLTWH(w * .38, h * .16, w * .46, h * .48),
          paint,
        );
      case BlenderGlyph.selectIntersect:
        canvas.drawRect(
          Rect.fromLTWH(w * .34, h * .34, w * .32, h * .32),
          paint,
        );
        canvas.drawLine(
          Offset(w * .2, h * .16),
          Offset(w * .8, h * .16),
          paint,
        );
        canvas.drawLine(
          Offset(w * .2, h * .84),
          Offset(w * .8, h * .84),
          paint,
        );
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
        canvas.drawRect(
          Rect.fromLTWH(w * .12, h * .15, w * .76, h * .7),
          paint,
        );
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
        canvas.drawLine(
          Offset(w * .28, h * .48),
          Offset(w * .7, h * .48),
          paint,
        );
      case BlenderGlyph.object:
        canvas.drawCircle(center, w * .28, paint);
        canvas.drawRect(
          Rect.fromLTWH(w * .36, h * .36, w * .28, h * .28),
          paint,
        );
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
        canvas.drawLine(
          Offset(w * .26, h * .3),
          Offset(w * .38, h * .18),
          paint,
        );
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
      case BlenderGlyph.modifier:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * .22, h * .22, w * .56, h * .56),
            Radius.circular(w * .08),
          ),
          paint,
        );
        canvas.drawLine(
          Offset(w * .32, h * .5),
          Offset(w * .68, h * .5),
          paint,
        );
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
        canvas.drawLine(
          Offset(w * .16, h * .5),
          Offset(w * .84, h * .5),
          paint,
        );
      case BlenderGlyph.render:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * .18, h * .28, w * .64, h * .44),
            Radius.circular(w * .04),
          ),
          paint,
        );
        canvas.drawCircle(center, w * .14, paint);
        canvas.drawLine(
          Offset(w * .28, h * .2),
          Offset(w * .42, h * .28),
          paint,
        );
      case BlenderGlyph.output:
        canvas.drawRect(
          Rect.fromLTWH(w * .14, h * .26, w * .5, h * .48),
          paint,
        );
        canvas.drawLine(
          Offset(w * .48, center.dy),
          Offset(w * .86, center.dy),
          paint,
        );
        path.moveTo(w * .68, h * .3);
        path.lineTo(w * .86, center.dy);
        path.lineTo(w * .68, h * .7);
        canvas.drawPath(path, paint);
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
        canvas.drawLine(
          Offset(w * .42, h * .42),
          Offset(w * .8, h * .8),
          paint,
        );
        canvas.drawCircle(Offset(w * .8, h * .8), w * .08, paint);
      case BlenderGlyph.transform:
        canvas.drawLine(
          Offset(w * .5, h * .12),
          Offset(w * .5, h * .88),
          paint,
        );
        canvas.drawLine(
          Offset(w * .12, h * .5),
          Offset(w * .88, h * .5),
          paint,
        );
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
        canvas.drawLine(
          Offset(w * .5, h * .15),
          Offset(w * .5, h * .85),
          paint,
        );
        canvas.drawLine(
          Offset(w * .15, h * .5),
          Offset(w * .85, h * .5),
          paint,
        );
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
        canvas.drawLine(
          Offset(w * .28, h * .4),
          Offset(w * .52, h * .4),
          paint,
        );
        canvas.drawLine(
          Offset(w * .4, h * .28),
          Offset(w * .4, h * .52),
          paint,
        );
      case BlenderGlyph.deleteIcon:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * .24, h * .28, w * .52, h * .56),
            Radius.circular(w * .03),
          ),
          paint,
        );
        canvas.drawLine(
          Offset(w * .18, h * .2),
          Offset(w * .82, h * .2),
          paint,
        );
        canvas.drawLine(
          Offset(w * .38, h * .14),
          Offset(w * .62, h * .14),
          paint,
        );
      case BlenderGlyph.duplicate:
        canvas.drawRect(
          Rect.fromLTWH(w * .22, h * .28, w * .48, h * .48),
          paint,
        );
        canvas.drawRect(
          Rect.fromLTWH(w * .36, h * .14, w * .48, h * .48),
          paint,
        );
      case BlenderGlyph.record:
        canvas.drawCircle(center, w * .28, paint);
        canvas.drawCircle(center, w * .1, paint);
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
        canvas.drawLine(
          Offset(w * .5, h * .62),
          Offset(w * .5, h * .88),
          paint,
        );
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
        canvas.drawLine(
          Offset(w * .2, h * .25),
          Offset(w * .8, h * .25),
          paint,
        );
        canvas.drawLine(Offset(w * .2, h * .5), Offset(w * .65, h * .5), paint);
        canvas.drawLine(
          Offset(w * .2, h * .75),
          Offset(w * .5, h * .75),
          paint,
        );
      case BlenderGlyph.sortDescending:
        canvas.drawLine(
          Offset(w * .2, h * .25),
          Offset(w * .5, h * .25),
          paint,
        );
        canvas.drawLine(Offset(w * .2, h * .5), Offset(w * .65, h * .5), paint);
        canvas.drawLine(
          Offset(w * .2, h * .75),
          Offset(w * .8, h * .75),
          paint,
        );
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
      case BlenderGlyph.refresh:
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
        canvas.drawLine(
          Offset(w * .2, h * .65),
          Offset(w * .8, h * .65),
          paint,
        );
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
        canvas.drawLine(
          Offset(w * .2, h * .7),
          Offset(w * .42, h * .48),
          paint,
        );
        canvas.drawLine(
          Offset(w * .58, h * .52),
          Offset(w * .8, h * .3),
          paint,
        );
        canvas.drawLine(
          Offset(w * .42, h * .3),
          Offset(w * .7, h * .58),
          paint,
        );
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
        canvas.drawLine(
          Offset(w * .62, h * .14),
          Offset(w * .62, h * .3),
          paint,
        );
        canvas.drawLine(
          Offset(w * .62, h * .3),
          Offset(w * .78, h * .3),
          paint,
        );
      case BlenderGlyph.save:
        canvas.drawRect(
          Rect.fromLTWH(w * .18, h * .16, w * .64, h * .68),
          paint,
        );
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
        canvas.drawRect(
          Rect.fromLTWH(w * .18, h * .18, w * .64, h * .64),
          paint,
        );
        canvas.drawLine(
          Offset(w * .5, h * .72),
          Offset(w * .5, h * .28),
          paint,
        );
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
        canvas.drawRect(
          Rect.fromLTWH(w * .14, h * .14, w * .72, h * .72),
          paint,
        );
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
    }
  }

  @override
  bool shouldRepaint(_BlenderIconPainter oldDelegate) {
    return glyph != oldDelegate.glyph || color != oldDelegate.color;
  }
}
