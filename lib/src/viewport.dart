import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'services.dart';
import 'theme.dart';
import 'controls.dart';
import 'icons.dart';

@immutable
class BlenderViewportState {
  const BlenderViewportState({
    this.yaw = 0,
    this.pitch = 0,
    this.distance = 10,
    this.pan = Offset.zero,
  });

  final double yaw;
  final double pitch;
  final double distance;
  final Offset pan;

  BlenderViewportState copyWith({
    double? yaw,
    double? pitch,
    double? distance,
    Offset? pan,
  }) => BlenderViewportState(
    yaw: yaw ?? this.yaw,
    pitch: pitch ?? this.pitch,
    distance: distance ?? this.distance,
    pan: pan ?? this.pan,
  );

  @override
  bool operator ==(Object other) =>
      other is BlenderViewportState &&
      other.yaw == yaw &&
      other.pitch == pitch &&
      other.distance == distance &&
      other.pan == pan;

  @override
  int get hashCode => Object.hash(yaw, pitch, distance, pan);
}

/// Reusable navigation state for a viewport whose renderer remains host-owned.
class BlenderViewportController extends ChangeNotifier
    implements BlenderServiceDisposable {
  BlenderViewportController({
    BlenderViewportState initialState = const BlenderViewportState(),
    this.minPitch = -1.3,
    this.maxPitch = 1.3,
    this.minDistance = 1,
    this.maxDistance = 100,
    this.orbitSensitivity = .012,
    this.zoomSensitivity = .012,
    this.panSensitivity = 1,
  }) : _initialState = initialState,
       _state = initialState;

  final BlenderViewportState _initialState;
  final double minPitch;
  final double maxPitch;
  final double minDistance;
  final double maxDistance;
  final double orbitSensitivity;
  final double zoomSensitivity;
  final double panSensitivity;
  BlenderViewportState _state;

  BlenderViewportState get state => _state;

  void orbitBy(Offset delta) {
    value = _state.copyWith(
      yaw: _state.yaw + delta.dx * orbitSensitivity,
      pitch: (_state.pitch + delta.dy * orbitSensitivity)
          .clamp(minPitch, maxPitch)
          .toDouble(),
    );
  }

  void zoomBy(double delta) {
    value = _state.copyWith(
      distance: (_state.distance + delta * zoomSensitivity)
          .clamp(minDistance, maxDistance)
          .toDouble(),
    );
  }

  void panBy(Offset delta) {
    value = _state.copyWith(pan: _state.pan + delta * panSensitivity);
  }

  void reset() => value = _initialState;

  set value(BlenderViewportState next) {
    if (_state == next) return;
    _state = next;
    notifyListeners();
  }
}

typedef BlenderViewportSceneBuilder =
    Widget Function(BuildContext context, BlenderViewportState state);

/// Viewport interaction and overlay frame around an application-owned scene.
class BlenderViewportShell extends StatelessWidget {
  const BlenderViewportShell({
    super.key,
    required this.controller,
    required this.sceneBuilder,
    this.caption,
    this.gizmoBuilder,
    this.footer,
    this.overlays = const <Widget>[],
    this.sidebar,
    this.sidebarWidth = 240,
    this.background,
    this.orbitEnabled = true,
    this.zoomEnabled = true,
    this.resetEnabled = true,
    this.gizmoTop = 10,
    this.gizmoRight = 12,
  });

  final BlenderViewportController controller;
  final BlenderViewportSceneBuilder sceneBuilder;
  final Widget? caption;
  final BlenderViewportSceneBuilder? gizmoBuilder;
  final Widget? footer;
  final List<Widget> overlays;
  final Widget? sidebar;
  final double sidebarWidth;
  final Color? background;
  final bool orbitEnabled;
  final bool zoomEnabled;
  final bool resetEnabled;
  final double gizmoTop;
  final double gizmoRight;

  @override
  Widget build(BuildContext context) {
    final viewport = AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Listener(
        onPointerSignal: zoomEnabled
            ? (event) {
                if (event is PointerScrollEvent) {
                  controller.zoomBy(event.scrollDelta.dy);
                }
              }
            : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: orbitEnabled
              ? (details) => controller.orbitBy(details.delta)
              : null,
          onDoubleTap: resetEnabled ? controller.reset : null,
          child: ColoredBox(
            color:
                background ?? BlenderTheme.of(context).colors.panelBackground,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: RepaintBoundary(
                    child: sceneBuilder(context, controller.state),
                  ),
                ),
                if (caption != null)
                  Positioned(left: 12, top: 10, child: caption!),
                if (gizmoBuilder != null)
                  Positioned(
                    right: gizmoRight,
                    top: gizmoTop,
                    child: gizmoBuilder!(context, controller.state),
                  ),
                ...overlays,
                if (footer != null)
                  Positioned(left: 12, bottom: 10, child: footer!),
              ],
            ),
          ),
        ),
      ),
    );
    final sidebar = this.sidebar;
    if (sidebar == null) return viewport;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: viewport),
        SizedBox(width: sidebarWidth, child: sidebar),
      ],
    );
  }
}

/// The compact selection-operation strip shown below Blender's 3D header.
class BlenderViewportSelectionModeBar extends StatelessWidget {
  const BlenderViewportSelectionModeBar({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    const modes = <(String, BlenderGlyph, String)>[
      ('Set', BlenderGlyph.selectBox, 'Set Selection'),
      ('Extend', BlenderGlyph.selectExtend, 'Extend Selection'),
      ('Subtract', BlenderGlyph.selectSubtract, 'Subtract Selection'),
      ('Difference', BlenderGlyph.selectDifference, 'Difference Selection'),
      ('Intersect', BlenderGlyph.selectIntersect, 'Intersect Selection'),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.surface.withAlpha(244),
        border: Border.all(color: theme.colors.editorBorder),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final mode in modes)
            BlenderIconButton(
              key: ValueKey<String>(
                'viewport-selection-${mode.$1.toLowerCase()}',
              ),
              glyph: mode.$2,
              selected: value == mode.$1,
              onPressed: () => onChanged(mode.$1),
              tooltip: mode.$3,
              size: 30,
            ),
        ],
      ),
    );
  }
}

/// Blender-shaped navigation buttons that sit below the axis gizmo.
class BlenderViewportNavigationControls extends StatelessWidget {
  const BlenderViewportNavigationControls({
    super.key,
    required this.onZoom,
    required this.onCamera,
    required this.onPerspective,
  });

  final VoidCallback onZoom;
  final VoidCallback onCamera;
  final VoidCallback onPerspective;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      _ViewportRoundButton(
        glyph: BlenderGlyph.zoom,
        tooltip: 'Zoom in/out in the view',
        onPressed: onZoom,
      ),
      const SizedBox(height: 4),
      _ViewportRoundButton(
        glyph: BlenderGlyph.camera,
        tooltip: 'Toggle camera view',
        onPressed: onCamera,
      ),
      const SizedBox(height: 4),
      _ViewportRoundButton(
        glyph: BlenderGlyph.grid,
        tooltip: 'Toggle perspective/orthographic',
        onPressed: onPerspective,
      ),
    ],
  );
}

/// Renderer-independent axis gizmo driven by the viewport's orbit angles.
class BlenderViewportOrientationGizmo extends StatelessWidget {
  const BlenderViewportOrientationGizmo({
    super.key,
    required this.yaw,
    required this.pitch,
    this.size = 76,
  });

  final double yaw;
  final double pitch;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _ViewportOrientationGizmoPainter(
        yaw: yaw,
        pitch: pitch,
        colors: BlenderTheme.of(context).colors,
      ),
    ),
  );
}

class _ViewportOrientationGizmoPainter extends CustomPainter {
  const _ViewportOrientationGizmoPainter({
    required this.yaw,
    required this.pitch,
    required this.colors,
  });

  final double yaw;
  final double pitch;
  final BlenderColorScheme colors;

  Offset _rotate(double x, double y, double z) {
    final cy = math.cos(yaw);
    final sy = math.sin(yaw);
    final cp = math.cos(pitch);
    final sp = math.sin(pitch);
    final rotatedX = cy * x - sy * y;
    final rotatedY = sy * x + cy * y;
    return Offset(rotatedX, cp * z - sp * rotatedY);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (final axis in <(Offset, Color, String)>[
      (_rotate(1, 0, 0), colors.axisX, 'X'),
      (_rotate(0, 1, 0), colors.axisY, 'Y'),
      (_rotate(0, 0, 1), colors.axisZ, 'Z'),
    ]) {
      final end =
          center + Offset(axis.$1.dx, -axis.$1.dy) * (size.width * .355);
      canvas.drawLine(
        center,
        end,
        Paint()
          ..color = axis.$2
          ..strokeWidth = 2,
      );
      canvas.drawCircle(end, size.width * .132, Paint()..color = axis.$2);
      final label = TextPainter(
        text: TextSpan(
          text: axis.$3,
          style: TextStyle(
            color: const Color(0xFF151515),
            fontSize: size.width * .145,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, end - Offset(label.width / 2, label.height / 2));
    }
  }

  @override
  bool shouldRepaint(_ViewportOrientationGizmoPainter oldDelegate) =>
      oldDelegate.yaw != yaw ||
      oldDelegate.pitch != pitch ||
      oldDelegate.colors != colors;
}

class _ViewportRoundButton extends StatelessWidget {
  const _ViewportRoundButton({
    required this.glyph,
    required this.tooltip,
    required this.onPressed,
  });

  final BlenderGlyph glyph;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderTooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.surface.withAlpha(218),
            shape: BoxShape.circle,
          ),
          child: SizedBox.square(
            dimension: 34,
            child: Center(child: BlenderIcon(glyph, size: 20)),
          ),
        ),
      ),
    );
  }
}

class BlenderViewportSidebarTab {
  const BlenderViewportSidebarTab({required this.id, required this.label});

  final String id;
  final String label;
}

/// Vertical N-panel category tabs. Selecting the active tab collapses the
/// panel, matching the region toggle used by Blender's 3D viewport.
class BlenderViewportSidebarRail extends StatelessWidget {
  const BlenderViewportSidebarRail({
    super.key,
    required this.tabs,
    required this.selected,
    required this.expanded,
    required this.onSelected,
  });

  final List<BlenderViewportSidebarTab> tabs;
  final String selected;
  final bool expanded;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final tab in tabs)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: GestureDetector(
              key: ValueKey<String>('viewport-sidebar-tab-${tab.id}'),
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(tab.id),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: expanded && selected == tab.id
                      ? theme.colors.panelBackground
                      : theme.colors.surface.withAlpha(246),
                  border: Border.all(color: theme.colors.editorBorder),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(5),
                  ),
                ),
                child: SizedBox(
                  width: 29,
                  height: 78,
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Text(tab.label, style: theme.textTheme.body),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
