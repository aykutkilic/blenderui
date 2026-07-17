import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'services.dart';
import 'theme.dart';

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
                    right: 12,
                    top: 10,
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
