import 'dart:math' as math;

import 'package:blender_ui/blender_ui.dart';
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
    this.toolShelf,
    this.selectionMode = 'Set',
    this.onSelectionModeChanged,
    this.onStatus,
  });

  final String selectedObject;
  final bool showGrid;
  final bool wireframe;
  final Widget? sidebar;
  final double sidebarWidth;
  final Widget? toolShelf;
  final String selectionMode;
  final ValueChanged<String>? onSelectionModeChanged;
  final ValueChanged<String>? onStatus;

  @override
  State<ShowcaseViewport> createState() => _ShowcaseViewportState();
}

class _ShowcaseViewportState extends State<ShowcaseViewport> {
  late final BlenderViewportController _controller;
  bool _sidebarExpanded = true;
  String _sidebarCategory = 'Item';

  @override
  void initState() {
    super.initState();
    _controller = BlenderViewportController(
      initialState: const BlenderViewportState(
        yaw: -.65,
        pitch: .58,
        distance: 12,
      ),
      minDistance: 6,
      maxDistance: 24,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = BlenderTheme.of(context).colors;
    const sidebarTabs = <BlenderViewportSidebarTab>[
      BlenderViewportSidebarTab(id: 'Item', label: 'Item'),
      BlenderViewportSidebarTab(id: 'Tool', label: 'Tool'),
      BlenderViewportSidebarTab(id: 'View', label: 'View'),
      BlenderViewportSidebarTab(id: 'Animation', label: 'Animation'),
    ];
    return BlenderViewportShell(
      controller: _controller,
      background: colors.panelBackground,
      gizmoTop: 42,
      sidebar: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BlenderViewportSidebarRail(
            tabs: sidebarTabs,
            selected: _sidebarCategory,
            expanded: _sidebarExpanded,
            onSelected: (category) => setState(() {
              if (_sidebarExpanded && _sidebarCategory == category) {
                _sidebarExpanded = false;
              } else {
                _sidebarCategory = category;
                _sidebarExpanded = true;
              }
            }),
          ),
          if (_sidebarExpanded)
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.panelBackground,
                  border: Border(left: BorderSide(color: colors.editorBorder)),
                ),
                child: BlenderViewportSidebar(category: _sidebarCategory),
              ),
            ),
        ],
      ),
      sidebarWidth: _sidebarExpanded ? widget.sidebarWidth : 30,
      caption: _ViewportCaption(objectName: widget.selectedObject),
      footer: const Text(
        'Drag to orbit  •  Scroll to zoom  •  Double-click to reset',
        style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 11),
      ),
      overlays: <Widget>[
        Positioned(
          left: 6,
          top: 6,
          child: BlenderViewportSelectionModeBar(
            value: widget.selectionMode,
            onChanged: widget.onSelectionModeChanged ?? (_) {},
          ),
        ),
        if (widget.toolShelf != null)
          Positioned(left: 6, top: 44, bottom: 6, child: widget.toolShelf!),
        Positioned(
          right: 14,
          top: 124,
          child: BlenderViewportNavigationControls(
            onZoom: () {
              _controller.zoomBy(-90);
              widget.onStatus?.call('Viewport zoom');
            },
            onCamera: () => widget.onStatus?.call('Camera view toggled'),
            onPerspective: () => widget.onStatus?.call('Perspective toggled'),
          ),
        ),
        Positioned(
          right: 8,
          top: 6,
          child: BlenderButton(
            label: 'Options',
            variant: BlenderButtonVariant.toolbar,
            onPressed: () => widget.onStatus?.call('Viewport options'),
          ),
        ),
      ],
      sceneBuilder: (context, state) {
        final camera = _OrbitCamera(
          yaw: state.yaw,
          pitch: state.pitch,
          distance: state.distance,
        );
        return CustomPaint(
          painter: _ViewportScenePainter(
            camera: camera,
            showGrid: widget.showGrid,
            wireframe: widget.wireframe,
            colors: colors,
          ),
        );
      },
      gizmoBuilder: (context, state) =>
          BlenderViewportOrientationGizmo(yaw: state.yaw, pitch: state.pitch),
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
