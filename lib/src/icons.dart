import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'theme.dart';

part 'icons/chrome.dart';
part 'icons/input.dart';
part 'icons/editor_types.dart';
part 'icons/data_types.dart';
part 'icons/viewport.dart';
part 'icons/transforms.dart';
part 'icons/actions.dart';
part 'icons/window_feedback_and_files.dart';

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
  assetManager,
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
  mesh,
  curve,
  curves,
  pointcloud,
  speaker,
  volume,
  empty,
  lightprobe,
  greasepencil,
  lattice,
  metaball,
  armature,
  bone,
  shaderfx,
  viewLayer,
  camera,
  light,
  material,
  gizmo,
  overlay,
  xray,
  solid,
  materialPreview,
  rendered,
  modifier,
  physics,
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
  undo,
  redo,
  snap,
  pin,
  filter,
  sort,
  sortDescending,
  sortAlphabetically,
  grip,
  refresh,
  sync,
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
    final icon = _BlenderIconPaintContext(canvas, size, color);
    if (_paintChromeGlyph(glyph, icon)) return;
    if (_paintInputGlyph(glyph, icon)) return;
    if (_paintEditorTypesGlyph(glyph, icon)) return;
    if (_paintDataTypesGlyph(glyph, icon)) return;
    if (_paintViewportGlyph(glyph, icon)) return;
    if (_paintTransformsGlyph(glyph, icon)) return;
    if (_paintActionsGlyph(glyph, icon)) return;
    if (_paintWindowFeedbackAndFilesGlyph(glyph, icon)) return;
  }

  @override
  bool shouldRepaint(_BlenderIconPainter oldDelegate) {
    return glyph != oldDelegate.glyph || color != oldDelegate.color;
  }
}

class _BlenderIconPaintContext {
  _BlenderIconPaintContext(this.canvas, this.size, this.color)
    : paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = math.max(1, size.shortestSide * .12);

  final Canvas canvas;
  final Size size;
  final Color color;
  final Paint paint;
}
