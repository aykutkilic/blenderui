import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'plot_model.dart';

final class WorkbookPlotController extends ChangeNotifier {
  WorkbookPlotController(WorkbookPlotSpec spec)
    : _spec = spec,
      _xMinimum = spec.xMinimum,
      _xMaximum = spec.xMaximum,
      _axes = spec.axes,
      _series = spec.series,
      _cursors = spec.cursors,
      _nodes = spec.nodes;

  final WorkbookPlotSpec _spec;
  double _xMinimum;
  double _xMaximum;
  List<WorkbookPlotAxis> _axes;
  List<WorkbookPlotSeries> _series;
  List<WorkbookPlotCursor> _cursors;
  List<WorkbookPlotNode> _nodes;
  double _cameraYaw = 0.65;
  double _cameraPitch = 0.32;
  var _cursorSequence = 0;

  WorkbookPlotSpec get spec => _spec;
  double get xMinimum => _xMinimum;
  double get xMaximum => _xMaximum;
  List<WorkbookPlotAxis> get axes => List.unmodifiable(_axes);
  List<WorkbookPlotSeries> get series => List.unmodifiable(_series);
  List<WorkbookPlotCursor> get cursors => List.unmodifiable(_cursors);
  List<WorkbookPlotNode> get nodes => List.unmodifiable(_nodes);
  double get cameraYaw => _cameraYaw;
  double get cameraPitch => _cameraPitch;

  void resetView() {
    _xMinimum = _spec.xMinimum;
    _xMaximum = _spec.xMaximum;
    _axes = _spec.axes;
    _nodes = _spec.nodes;
    _cameraYaw = 0.65;
    _cameraPitch = 0.32;
    notifyListeners();
  }

  void panX(double delta) {
    _xMinimum += delta;
    _xMaximum += delta;
    notifyListeners();
  }

  void zoomX(double factor, {double? anchor}) {
    if (!factor.isFinite || factor <= 0) return;
    final pivot = anchor ?? (_xMinimum + _xMaximum) / 2;
    final minimum = pivot - (pivot - _xMinimum) * factor;
    final maximum = pivot + (_xMaximum - pivot) * factor;
    if ((maximum - minimum).abs() < 1e-12) return;
    _xMinimum = minimum;
    _xMaximum = maximum;
    notifyListeners();
  }

  void updateAxisRange(String axisId, double minimum, double maximum) {
    if (!minimum.isFinite || !maximum.isFinite || minimum == maximum) return;
    _axes = <WorkbookPlotAxis>[
      for (final axis in _axes)
        if (axis.id == axisId)
          axis.copyWith(minimum: minimum, maximum: maximum)
        else
          axis,
    ];
    notifyListeners();
  }

  void panAxis(String axisId, double delta) {
    WorkbookPlotAxis? axis;
    for (final item in _axes) {
      if (item.id == axisId) {
        axis = item;
        break;
      }
    }
    if (axis == null) return;
    updateAxisRange(axisId, axis.minimum + delta, axis.maximum + delta);
  }

  void setSeriesVisible(String seriesId, bool visible) {
    _series = <WorkbookPlotSeries>[
      for (final item in _series)
        item.id == seriesId ? item.copyWith(visible: visible) : item,
    ];
    notifyListeners();
  }

  String addCursor(double x, {double? x2}) {
    _cursorSequence += 1;
    final id =
        'cursor-${DateTime.now().microsecondsSinceEpoch}-$_cursorSequence';
    _cursors = <WorkbookPlotCursor>[
      ..._cursors,
      WorkbookPlotCursor(
        id: id,
        x: x,
        x2: x2,
        kind: x2 == null
            ? WorkbookPlotCursorKind.vertical
            : WorkbookPlotCursorKind.band,
        color: const Color(0xffef4444),
        label: '${_cursors.length + 1}',
      ),
    ];
    notifyListeners();
    return id;
  }

  void moveCursor(String cursorId, {required double x, double? x2}) {
    _cursors = <WorkbookPlotCursor>[
      for (final cursor in _cursors)
        cursor.id == cursorId ? cursor.copyWith(x: x, x2: x2) : cursor,
    ];
    notifyListeners();
  }

  void removeCursor(String cursorId) {
    _cursors = <WorkbookPlotCursor>[
      for (final cursor in _cursors)
        if (cursor.id != cursorId) cursor,
    ];
    notifyListeners();
  }

  void clearCursors() {
    if (_cursors.isEmpty) return;
    _cursors = const <WorkbookPlotCursor>[];
    notifyListeners();
  }

  void moveNode(String nodeId, {required double x, required double y}) {
    _nodes = <WorkbookPlotNode>[
      for (final node in _nodes)
        node.id == nodeId
            ? node.copyWith(x: x.clamp(0.0, 1.0), y: y.clamp(0.0, 1.0))
            : node,
    ];
    notifyListeners();
  }

  void rotateCamera({required double yawDelta, required double pitchDelta}) {
    _cameraYaw += yawDelta;
    _cameraPitch = (_cameraPitch + pitchDelta).clamp(-1.2, 1.2);
    notifyListeners();
  }
}
