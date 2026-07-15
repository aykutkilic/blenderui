import 'dart:math' as math;

import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// A deliberately small, orbitable scene used to make the showcase tangible.
class ShowcaseViewport extends StatefulWidget {
  const ShowcaseViewport({
    super.key,
    required this.selectedObject,
    required this.showGrid,
    required this.wireframe,
    this.sidebar,
    this.sidebarWidth = 240,
  });

  final String selectedObject;
  final bool showGrid;
  final bool wireframe;
  final Widget? sidebar;
  final double sidebarWidth;

  @override
  State<ShowcaseViewport> createState() => _ShowcaseViewportState();
}

class _ShowcaseViewportState extends State<ShowcaseViewport> {
  double _yaw = -.65;
  double _pitch = .58;
  double _distance = 12;

  void _orbit(DragUpdateDetails details) {
    setState(() {
      _yaw += details.delta.dx * .012;
      _pitch = (_pitch + details.delta.dy * .012).clamp(-1.3, 1.3);
    });
  }

  void _zoom(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    setState(() {
      _distance = (_distance + event.scrollDelta.dy * .012).clamp(6, 24);
    });
  }

  void _resetView() {
    setState(() {
      _yaw = -.65;
      _pitch = .58;
      _distance = 12;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = BlenderTheme.of(context).colors;
    final camera = _OrbitCamera(yaw: _yaw, pitch: _pitch, distance: _distance);
    final canvas = Listener(
      onPointerSignal: _zoom,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: _orbit,
        onDoubleTap: _resetView,
        child: ColoredBox(
          color: colors.panelBackground,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _ViewportScenePainter(
                      camera: camera,
                      showGrid: widget.showGrid,
                      wireframe: widget.wireframe,
                      colors: colors,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 10,
                child: _ViewportCaption(objectName: widget.selectedObject),
              ),
              Positioned(
                right: 12,
                top: 10,
                child: _OrientationGizmo(camera: camera, colors: colors),
              ),
              const Positioned(
                left: 12,
                bottom: 10,
                child: Text(
                  'Drag to orbit  •  Scroll to zoom  •  Double-click to reset',
                  style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (widget.sidebar == null) return canvas;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: canvas),
        SizedBox(width: widget.sidebarWidth, child: widget.sidebar),
      ],
    );
  }
}

class _ViewportCaption extends StatelessWidget {
  const _ViewportCaption({required this.objectName});

  final String objectName;

  @override
  Widget build(BuildContext context) {
    return Text(
      'User Perspective\n(1) Collection | $objectName',
      style: BlenderTheme.of(context).textTheme.body.copyWith(
        color: BlenderTheme.of(context).colors.foreground,
        height: 1.35,
      ),
    );
  }
}

class _OrientationGizmo extends StatelessWidget {
  const _OrientationGizmo({required this.camera, required this.colors});

  final _OrbitCamera camera;
  final BlenderColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 76,
      child: CustomPaint(
        painter: _OrientationGizmoPainter(camera: camera, colors: colors),
      ),
    );
  }
}

class _ViewportScenePainter extends CustomPainter {
  const _ViewportScenePainter({
    required this.camera,
    required this.showGrid,
    required this.wireframe,
    required this.colors,
  });

  final _OrbitCamera camera;
  final bool showGrid;
  final bool wireframe;
  final BlenderColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    final projection = _ViewportProjection(camera: camera, viewport: size);
    if (showGrid) _GridRenderer(colors).paint(canvas, projection);
    _CubeRenderer(colors, wireframe: wireframe).paint(canvas, projection);
    _WorldAxisRenderer(colors).paint(canvas, projection);
  }

  @override
  bool shouldRepaint(_ViewportScenePainter oldDelegate) =>
      oldDelegate.camera != camera ||
      oldDelegate.showGrid != showGrid ||
      oldDelegate.wireframe != wireframe ||
      oldDelegate.colors != colors;
}

class _GridRenderer {
  const _GridRenderer(this.colors);

  final BlenderColorScheme colors;

  void paint(Canvas canvas, _ViewportProjection projection) {
    for (var value = -8; value <= 8; value++) {
      final major = value == 0;
      final gridPaint = Paint()
        ..color = major
            ? colors.foregroundMuted.withAlpha(70)
            : colors.foregroundMuted.withAlpha(32)
        ..strokeWidth = major ? 1.2 : 1;
      _line(
        canvas,
        projection,
        _Vec3(value.toDouble(), -8, 0),
        _Vec3(value.toDouble(), 8, 0),
        value == 0 ? colors.axisY.withAlpha(165) : gridPaint.color,
        gridPaint.strokeWidth,
      );
      _line(
        canvas,
        projection,
        _Vec3(-8, value.toDouble(), 0),
        _Vec3(8, value.toDouble(), 0),
        value == 0 ? colors.axisX.withAlpha(165) : gridPaint.color,
        gridPaint.strokeWidth,
      );
    }
  }
}

class _CubeRenderer {
  const _CubeRenderer(this.colors, {required this.wireframe});

  final BlenderColorScheme colors;
  final bool wireframe;

  static const List<_Vec3> _vertices = <_Vec3>[
    _Vec3(-1, -1, 0),
    _Vec3(1, -1, 0),
    _Vec3(1, 1, 0),
    _Vec3(-1, 1, 0),
    _Vec3(-1, -1, 2),
    _Vec3(1, -1, 2),
    _Vec3(1, 1, 2),
    _Vec3(-1, 1, 2),
  ];

  static const List<List<int>> _faces = <List<int>>[
    <int>[0, 1, 2, 3],
    <int>[4, 7, 6, 5],
    <int>[0, 4, 5, 1],
    <int>[1, 5, 6, 2],
    <int>[2, 6, 7, 3],
    <int>[3, 7, 4, 0],
  ];

  void paint(Canvas canvas, _ViewportProjection projection) {
    final projected = <_ProjectedPoint>[
      for (final vertex in _vertices) projection.project(vertex),
    ];
    final faces = <_ProjectedFace>[
      for (var index = 0; index < _faces.length; index++)
        _ProjectedFace(
          index: index,
          points: <_ProjectedPoint>[
            for (final vertex in _faces[index]) projected[vertex],
          ],
        ),
    ]..sort((a, b) => b.depth.compareTo(a.depth));

    for (final face in faces) {
      final path = Path()
        ..moveTo(face.points.first.point.dx, face.points.first.point.dy);
      for (final point in face.points.skip(1)) {
        path.lineTo(point.point.dx, point.point.dy);
      }
      path.close();
      if (!wireframe) {
        final shade = <Color>[
          const Color(0xFF56585A),
          const Color(0xFFA4A6A8),
          const Color(0xFF6B6D6F),
          const Color(0xFF77797B),
          const Color(0xFF606264),
          const Color(0xFF858789),
        ][face.index];
        canvas.drawPath(path, Paint()..color = shade);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = wireframe ? colors.accentHover : colors.foregroundMuted
          ..style = PaintingStyle.stroke
          ..strokeWidth = wireframe ? 1.5 : 1,
      );
    }

    final center = projection.project(const _Vec3(0, 0, 1)).point;
    canvas.drawCircle(
      center,
      5,
      Paint()
        ..color = colors.axisW
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      center - const Offset(8, 0),
      center + const Offset(8, 0),
      Paint()..color = colors.axisW,
    );
    canvas.drawLine(
      center - const Offset(0, 8),
      center + const Offset(0, 8),
      Paint()..color = colors.axisW,
    );
  }
}

class _WorldAxisRenderer {
  const _WorldAxisRenderer(this.colors);

  final BlenderColorScheme colors;

  void paint(Canvas canvas, _ViewportProjection projection) {
    const origin = _Vec3(0, 0, 1);
    _line(canvas, projection, origin, const _Vec3(3, 0, 1), colors.axisX, 2);
    _line(canvas, projection, origin, const _Vec3(0, 3, 1), colors.axisY, 2);
    _line(canvas, projection, origin, const _Vec3(0, 0, 4), colors.axisZ, 2);
  }
}

void _line(
  Canvas canvas,
  _ViewportProjection projection,
  _Vec3 from,
  _Vec3 to,
  Color color,
  double width,
) {
  canvas.drawLine(
    projection.project(from).point,
    projection.project(to).point,
    Paint()
      ..color = color
      ..strokeWidth = width,
  );
}

class _OrientationGizmoPainter extends CustomPainter {
  const _OrientationGizmoPainter({required this.camera, required this.colors});

  final _OrbitCamera camera;
  final BlenderColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (final axis in <(_Vec3, Color, String)>[
      (const _Vec3(1, 0, 0), colors.axisX, 'X'),
      (const _Vec3(0, 1, 0), colors.axisY, 'Y'),
      (const _Vec3(0, 0, 1), colors.axisZ, 'Z'),
    ]) {
      final rotated = camera.rotate(axis.$1);
      final end = center + Offset(rotated.x, -rotated.y) * 27;
      final axisPaint = Paint()
        ..color = axis.$2
        ..strokeWidth = 2;
      canvas.drawLine(center, end, axisPaint);
      canvas.drawCircle(end, 10, Paint()..color = axis.$2);
      final label = TextPainter(
        text: TextSpan(
          text: axis.$3,
          style: const TextStyle(color: Color(0xFF151515), fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, end - Offset(label.width / 2, label.height / 2));
    }
  }

  @override
  bool shouldRepaint(_OrientationGizmoPainter oldDelegate) =>
      oldDelegate.camera != camera || oldDelegate.colors != colors;
}

class _ViewportProjection {
  const _ViewportProjection({required this.camera, required this.viewport});

  final _OrbitCamera camera;
  final Size viewport;

  _ProjectedPoint project(_Vec3 point) {
    final rotated = camera.rotate(point - const _Vec3(0, 0, 1));
    final depth = math.max(.5, camera.distance + rotated.z);
    final focal = math.min(viewport.width, viewport.height) * .9;
    return _ProjectedPoint(
      point: Offset(
        viewport.width / 2 + rotated.x * focal / depth,
        viewport.height / 2 - rotated.y * focal / depth,
      ),
      depth: depth,
    );
  }
}

class _OrbitCamera {
  const _OrbitCamera({
    required this.yaw,
    required this.pitch,
    required this.distance,
  });

  final double yaw;
  final double pitch;
  final double distance;

  _Vec3 rotate(_Vec3 point) {
    final cy = math.cos(yaw);
    final sy = math.sin(yaw);
    final cp = math.cos(pitch);
    final sp = math.sin(pitch);
    final x = cy * point.x - sy * point.y;
    final y = sy * point.x + cy * point.y;
    return _Vec3(x, cp * point.z - sp * y, sp * point.z + cp * y);
  }

  @override
  bool operator ==(Object other) =>
      other is _OrbitCamera &&
      other.yaw == yaw &&
      other.pitch == pitch &&
      other.distance == distance;

  @override
  int get hashCode => Object.hash(yaw, pitch, distance);
}

class _ProjectedPoint {
  const _ProjectedPoint({required this.point, required this.depth});

  final Offset point;
  final double depth;
}

class _ProjectedFace {
  const _ProjectedFace({required this.index, required this.points});

  final int index;
  final List<_ProjectedPoint> points;

  double get depth =>
      points.fold<double>(0, (sum, point) => sum + point.depth) / points.length;
}

class _Vec3 {
  const _Vec3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  _Vec3 operator -(_Vec3 other) => _Vec3(x - other.x, y - other.y, z - other.z);
}
