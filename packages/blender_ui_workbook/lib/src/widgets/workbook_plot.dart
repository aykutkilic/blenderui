import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../plot/plot_controller.dart';
import '../plot/plot_model.dart';
import 'workbook_palette.dart';

part 'workbook_plot_specialized_painters.dart';
part 'workbook_plot_chrome.dart';

final class WorkbookPlot extends StatefulWidget {
  const WorkbookPlot({
    required this.spec,
    this.controller,
    this.height = 360,
    super.key,
  });

  final WorkbookPlotSpec spec;
  final WorkbookPlotController? controller;
  final double height;

  @override
  State<WorkbookPlot> createState() => _WorkbookPlotState();
}

final class _WorkbookPlotState extends State<WorkbookPlot> {
  late WorkbookPlotController _controller;
  late bool _ownsController;
  Offset? _lastPanPosition;
  String? _dragCursorId;
  String? _dragAxisId;
  String? _dragNodeId;
  final FocusNode _focusNode = FocusNode(debugLabel: 'Workbook plot');

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  @override
  void didUpdateWidget(covariant WorkbookPlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.spec != widget.spec) {
      _detachController();
      _attachController();
    }
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? WorkbookPlotController(widget.spec);
    _controller.addListener(_changed);
  }

  void _detachController() {
    _controller.removeListener(_changed);
    if (_ownsController) _controller.dispose();
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    _detachController();
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final range = _controller.xMaximum - _controller.xMinimum;
    final fine = HardwareKeyboard.instance.isShiftPressed;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        _controller.panX(-range * (fine ? 0.05 : 0.5));
      case LogicalKeyboardKey.arrowRight:
        _controller.panX(range * (fine ? 0.05 : 0.5));
      case LogicalKeyboardKey.arrowUp:
        _controller.zoomX(fine ? 1 / 1.4 : 0.2);
      case LogicalKeyboardKey.arrowDown:
        _controller.zoomX(fine ? 1.4 : 5);
      case LogicalKeyboardKey.escape:
        _controller.resetView();
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final palette = WorkbookPalette.of(context);
    final background = palette.canvas;
    final foreground = palette.foreground;
    final grid = foreground.withValues(alpha: 0.14);
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: SizedBox(
        height: widget.height,
        child: Material(
          color: background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _PlotHeader(
                controller: _controller,
                foreground: foreground,
                onReset: _controller.resetView,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.biggest;
                    return Listener(
                      onPointerSignal: (event) {
                        if (event is! PointerScrollEvent) return;
                        final plot = _plotRect(size);
                        if (!plot.contains(event.localPosition)) return;
                        final anchor = _screenToX(event.localPosition.dx, plot);
                        _controller.zoomX(
                          event.scrollDelta.dy > 0 ? 1.12 : 0.89,
                          anchor: anchor,
                        );
                      },
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _focusNode.requestFocus,
                        onSecondaryTapDown: (details) => _showPlotMenu(
                          context,
                          details,
                          plot: _plotRect(size),
                        ),
                        onDoubleTapDown: (details) {
                          final plot = _plotRect(size);
                          if (plot.contains(details.localPosition)) {
                            _controller.addCursor(
                              _screenToX(details.localPosition.dx, plot),
                            );
                          }
                        },
                        onPanStart: (details) {
                          final plot = _plotRect(size);
                          _lastPanPosition = details.localPosition;
                          _dragAxisId = details.localPosition.dx < plot.left
                              ? _controller.axes.firstOrNull?.id
                              : null;
                          _dragNodeId =
                              _controller.spec.kind == WorkbookPlotKind.sankey
                              ? _nearestNode(details.localPosition, plot)
                              : null;
                          _dragCursorId = _nearestCursor(
                            details.localPosition,
                            plot,
                          );
                        },
                        onPanUpdate: (details) {
                          final plot = _plotRect(size);
                          final previous = _lastPanPosition;
                          _lastPanPosition = details.localPosition;
                          if (previous == null) return;
                          if (_dragNodeId case final id?) {
                            _controller.moveNode(
                              id,
                              x:
                                  (details.localPosition.dx - plot.left) /
                                  plot.width,
                              y:
                                  (details.localPosition.dy - plot.top) /
                                  plot.height,
                            );
                            return;
                          }
                          if (_controller.spec.kind ==
                              WorkbookPlotKind.threeDimensional) {
                            _controller.rotateCamera(
                              yawDelta: details.delta.dx / 140,
                              pitchDelta: details.delta.dy / 140,
                            );
                            return;
                          }
                          if (_dragAxisId case final id?) {
                            final axis = _controller.axes
                                .where((item) => item.id == id)
                                .firstOrNull;
                            if (axis == null) return;
                            _controller.panAxis(
                              id,
                              details.delta.dy /
                                  plot.height *
                                  (axis.maximum - axis.minimum),
                            );
                            return;
                          }
                          if (_dragCursorId case final id?) {
                            final cursor = _controller.cursors
                                .where((item) => item.id == id)
                                .firstOrNull;
                            if (cursor == null) return;
                            final x = _screenToX(
                              details.localPosition.dx,
                              plot,
                            );
                            final width = cursor.x2 == null
                                ? null
                                : cursor.x2! - cursor.x;
                            _controller.moveCursor(
                              id,
                              x: x,
                              x2: width == null ? null : x + width,
                            );
                            return;
                          }
                          final delta =
                              -details.delta.dx /
                              plot.width *
                              (_controller.xMaximum - _controller.xMinimum);
                          _controller.panX(delta);
                        },
                        onPanEnd: (_) {
                          _lastPanPosition = null;
                          _dragCursorId = null;
                          _dragAxisId = null;
                          _dragNodeId = null;
                        },
                        child: CustomPaint(
                          painter: _WorkbookPlotPainter(
                            controller: _controller,
                            background: background,
                            foreground: foreground,
                            grid: grid,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPlotMenu(
    BuildContext context,
    TapDownDetails details, {
    required Rect plot,
  }) async {
    _focusNode.requestFocus();
    final renderBox = context.findRenderObject()! as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final position = renderBox.localToGlobal(details.localPosition);
    final palette = WorkbookPalette.of(context);
    final command = await showMenu<_PlotMenuCommand>(
      context: context,
      color: palette.raised,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: <PopupMenuEntry<_PlotMenuCommand>>[
        PopupMenuItem(
          value: _PlotMenuCommand.addCursor,
          child: Text(
            'Add vertical cursor',
            style: TextStyle(color: palette.foreground),
          ),
        ),
        PopupMenuItem(
          value: _PlotMenuCommand.addBand,
          child: Text(
            'Add band cursor',
            style: TextStyle(color: palette.foreground),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: _PlotMenuCommand.clearCursors,
          child: Text(
            'Clear cursors',
            style: TextStyle(color: palette.foreground),
          ),
        ),
        PopupMenuItem(
          value: _PlotMenuCommand.resetView,
          child: Text(
            'Reset view',
            style: TextStyle(color: palette.foreground),
          ),
        ),
      ],
    );
    if (!mounted || command == null) return;
    final x = _screenToX(details.localPosition.dx, plot);
    switch (command) {
      case _PlotMenuCommand.addCursor:
        _controller.addCursor(x);
      case _PlotMenuCommand.addBand:
        final width = (_controller.xMaximum - _controller.xMinimum) * 0.1;
        _controller.addCursor(x - width / 2, x2: x + width / 2);
      case _PlotMenuCommand.clearCursors:
        _controller.clearCursors();
      case _PlotMenuCommand.resetView:
        _controller.resetView();
    }
  }

  String? _nearestCursor(Offset position, Rect plot) {
    if (!plot.contains(position)) return null;
    String? nearest;
    var distance = 8.0;
    for (final cursor in _controller.cursors) {
      final dx = (_xToScreen(cursor.x, plot) - position.dx).abs();
      if (dx < distance) {
        distance = dx;
        nearest = cursor.id;
      }
    }
    return nearest;
  }

  String? _nearestNode(Offset position, Rect plot) {
    for (final node in _controller.nodes.reversed) {
      final rect = Rect.fromLTWH(
        plot.left + node.x * plot.width - 5,
        plot.top + node.y * plot.height - 5,
        28,
        node.height * plot.height + 10,
      );
      if (rect.contains(position)) return node.id;
    }
    return null;
  }

  double _screenToX(double dx, Rect plot) =>
      _controller.xMinimum +
      ((dx - plot.left) / plot.width).clamp(0.0, 1.0) *
          (_controller.xMaximum - _controller.xMinimum);

  double _xToScreen(double x, Rect plot) =>
      plot.left +
      (x - _controller.xMinimum) /
          (_controller.xMaximum - _controller.xMinimum) *
          plot.width;
}

enum _PlotMenuCommand { addCursor, addBand, clearCursors, resetView }

final class _WorkbookPlotPainter extends CustomPainter {
  const _WorkbookPlotPainter({
    required this.controller,
    required this.background,
    required this.foreground,
    required this.grid,
  });

  final WorkbookPlotController controller;
  final Color background;
  final Color foreground;
  final Color grid;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = _plotRect(size);
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    if (plot.width <= 0 || plot.height <= 0) return;
    _drawGrid(canvas, plot);
    canvas.save();
    canvas.clipRect(plot);
    if (controller.spec.kind == WorkbookPlotKind.stackedArea) {
      _drawStackedArea(canvas, plot);
    } else if (controller.spec.kind == WorkbookPlotKind.sankey) {
      _drawSankey(canvas, plot);
    } else {
      for (final series in controller.series.where((item) => item.visible)) {
        final axis =
            controller.axes
                .where((item) => item.id == series.axisId)
                .firstOrNull ??
            controller.axes.first;
        _drawSeries(canvas, plot, series, axis);
      }
    }
    _drawCursors(canvas, plot);
    canvas.restore();
    _drawAxes(canvas, plot);
  }

  void _drawGrid(Canvas canvas, Rect plot) {
    final paint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var index = 0; index <= 5; index += 1) {
      final x = plot.left + plot.width * index / 5;
      final y = plot.top + plot.height * index / 5;
      if (controller.spec.showGrid) {
        canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), paint);
        canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), paint);
      }
    }
    canvas.drawRect(
      plot,
      Paint()
        ..color = foreground.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawSeries(
    Canvas canvas,
    Rect plot,
    WorkbookPlotSeries series,
    WorkbookPlotAxis axis,
  ) {
    switch (controller.spec.kind) {
      case WorkbookPlotKind.oscilloscope || WorkbookPlotKind.line:
        _drawLine(canvas, plot, series, axis);
      case WorkbookPlotKind.scatter:
        _drawScatter(canvas, plot, series, axis);
      case WorkbookPlotKind.bar || WorkbookPlotKind.histogram:
        _drawBars(canvas, plot, series, axis);
      case WorkbookPlotKind.candlestick:
        _drawCandles(canvas, plot, series, axis);
      case WorkbookPlotKind.gantt:
        _drawGantt(canvas, plot, series, axis);
      case WorkbookPlotKind.waveform:
        _drawWaveform(canvas, plot, series, axis);
      case WorkbookPlotKind.threeDimensional:
        _drawThreeDimensional(canvas, plot, series, axis);
      case WorkbookPlotKind.xyMap:
        _drawXyMap(canvas, plot, series, axis);
      case WorkbookPlotKind.stackedArea || WorkbookPlotKind.sankey:
        break;
    }
  }

  void _drawBars(
    Canvas canvas,
    Rect plot,
    WorkbookPlotSeries series,
    WorkbookPlotAxis axis,
  ) {
    final visible = series.points
        .where(
          (point) =>
              point.x >= controller.xMinimum && point.x <= controller.xMaximum,
        )
        .toList();
    if (visible.isEmpty) return;
    final width = math.max(
      2.0,
      plot.width / math.max(visible.length, 1) * 0.65,
    );
    final zero = _point(plot, axis, 0, 0).dy.clamp(plot.top, plot.bottom);
    final paint = Paint()..color = series.color.withValues(alpha: 0.82);
    for (final point in visible) {
      final offset = _point(plot, axis, point.x, point.y);
      canvas.drawRect(
        Rect.fromLTRB(
          offset.dx - width / 2,
          math.min(zero, offset.dy),
          offset.dx + width / 2,
          math.max(zero, offset.dy),
        ),
        paint,
      );
    }
  }

  void _drawCandles(
    Canvas canvas,
    Rect plot,
    WorkbookPlotSeries series,
    WorkbookPlotAxis axis,
  ) {
    final width = math.max(
      3.0,
      plot.width / math.max(series.points.length, 1) * 0.55,
    );
    for (final point in series.points) {
      final open = point.open ?? point.y;
      final close = point.close ?? point.y;
      final high = point.high ?? math.max(open, close);
      final low = point.low ?? math.min(open, close);
      final x = _point(plot, axis, point.x, point.y).dx;
      final color = close >= open
          ? const Color(0xff10b981)
          : const Color(0xffef4444);
      final paint = Paint()
        ..color = color
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(x, _point(plot, axis, point.x, high).dy),
        Offset(x, _point(plot, axis, point.x, low).dy),
        paint,
      );
      canvas.drawRect(
        Rect.fromLTRB(
          x - width / 2,
          _point(plot, axis, point.x, math.max(open, close)).dy,
          x + width / 2,
          _point(plot, axis, point.x, math.min(open, close)).dy,
        ),
        paint,
      );
    }
  }

  void _drawGantt(
    Canvas canvas,
    Rect plot,
    WorkbookPlotSeries series,
    WorkbookPlotAxis axis,
  ) {
    final rowHeight = plot.height / math.max(series.points.length, 1);
    for (final (index, point) in series.points.indexed) {
      final start = _point(plot, axis, point.x, point.y).dx;
      final end = _point(plot, axis, point.z ?? point.x, point.y).dx;
      final top = plot.top + index * rowHeight + rowHeight * 0.2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            start,
            top,
            math.max(start + 2, end),
            top + rowHeight * 0.6,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = series.color,
      );
    }
  }

  void _drawCursors(Canvas canvas, Rect plot) {
    for (final cursor in controller.cursors) {
      final x = _x(plot, cursor.x);
      if (cursor.x2 case final x2?) {
        final right = _x(plot, x2);
        canvas.drawRect(
          Rect.fromLTRB(
            math.min(x, right),
            plot.top,
            math.max(x, right),
            plot.bottom,
          ),
          Paint()..color = cursor.color.withValues(alpha: 0.12),
        );
      }
      canvas.drawLine(
        Offset(x, plot.top),
        Offset(x, plot.bottom),
        Paint()
          ..color = cursor.color
          ..strokeWidth = 1.2,
      );
      _text(
        canvas,
        cursor.label ?? '',
        Offset(x + 3, plot.top + 3),
        cursor.color,
        10,
      );
    }
  }

  void _drawAxes(Canvas canvas, Rect plot) {
    final xRange = controller.xMaximum - controller.xMinimum;
    for (var index = 0; index <= 5; index += 1) {
      final value = controller.xMinimum + xRange * index / 5;
      _text(
        canvas,
        _number(value),
        Offset(plot.left + plot.width * index / 5 - 14, plot.bottom + 5),
        foreground,
        9,
      );
    }
    if (controller.axes case [final axis, ...]) {
      for (var index = 0; index <= 5; index += 1) {
        final value = axis.maximum - (axis.maximum - axis.minimum) * index / 5;
        _text(
          canvas,
          _number(value),
          Offset(4, plot.top + plot.height * index / 5 - 5),
          foreground,
          9,
        );
      }
      _text(
        canvas,
        '${axis.label}${axis.unit.isEmpty ? '' : ' (${axis.unit})'}',
        const Offset(4, 3),
        foreground,
        10,
      );
    }
  }

  Offset _point(Rect plot, WorkbookPlotAxis axis, double x, double y) {
    final axisRange = axis.maximum - axis.minimum;
    final normalized = axisRange == 0 ? 0.5 : (y - axis.minimum) / axisRange;
    final top = plot.top + axis.normalizedTop * plot.height;
    final bottom = plot.top + axis.normalizedBottom * plot.height;
    return Offset(_x(plot, x), bottom - normalized * (bottom - top));
  }

  double _x(Rect plot, double value) =>
      plot.left +
      (value - controller.xMinimum) /
          (controller.xMaximum - controller.xMinimum) *
          plot.width;

  static void _text(
    Canvas canvas,
    String text,
    Offset offset,
    Color color,
    double size,
  ) {
    final paragraph =
        (ui.ParagraphBuilder(ui.ParagraphStyle(fontSize: size, maxLines: 1))
              ..pushStyle(ui.TextStyle(color: color, fontSize: size))
              ..addText(text))
            .build()
          ..layout(const ui.ParagraphConstraints(width: 120));
    canvas.drawParagraph(paragraph, offset);
  }

  static String _number(double value) {
    final magnitude = value.abs();
    if (magnitude >= 10000 || (magnitude > 0 && magnitude < 0.001)) {
      return value.toStringAsExponential(1);
    }
    return value.toStringAsFixed(magnitude >= 100 ? 0 : 2);
  }

  @override
  bool shouldRepaint(covariant _WorkbookPlotPainter oldDelegate) => true;
}

Rect _plotRect(Size size) => Rect.fromLTRB(
  58,
  20,
  math.max(59, size.width - 16),
  math.max(21, size.height - 28),
);
