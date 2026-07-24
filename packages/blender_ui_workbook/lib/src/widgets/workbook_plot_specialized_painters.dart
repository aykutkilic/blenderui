part of 'workbook_plot.dart';

extension _SpecializedPlotPainters on _WorkbookPlotPainter {
  void _drawLine(
    Canvas canvas,
    Rect plot,
    WorkbookPlotSeries series,
    WorkbookPlotAxis axis,
  ) {
    if (series.points.isEmpty) return;
    final path = Path();
    var started = false;
    for (final point in series.points) {
      if (point.x < controller.xMinimum || point.x > controller.xMaximum)
        continue;
      final offset = _point(plot, axis, point.x, point.y);
      if (!started) {
        path.moveTo(offset.dx, offset.dy);
        started = true;
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    if (!started) return;
    if (series.fill || controller.spec.kind == WorkbookPlotKind.stackedArea) {
      final fill = Path.from(path)
        ..lineTo(plot.right, plot.bottom)
        ..lineTo(plot.left, plot.bottom)
        ..close();
      canvas.drawPath(
        fill,
        Paint()..color = series.color.withValues(alpha: 0.18),
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = series.color
        ..strokeWidth = series.lineWidth
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawScatter(
    Canvas canvas,
    Rect plot,
    WorkbookPlotSeries series,
    WorkbookPlotAxis axis,
  ) {
    final paint = Paint()..color = series.color;
    for (final point in series.points) {
      if (point.x < controller.xMinimum || point.x > controller.xMaximum)
        continue;
      canvas.drawCircle(_point(plot, axis, point.x, point.y), 3, paint);
    }
  }

  void _drawWaveform(
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
    final path = Path();
    for (final (index, point) in visible.indexed) {
      final offset = _point(plot, axis, point.x, point.y);
      index == 0
          ? path.moveTo(offset.dx, offset.dy)
          : path.lineTo(offset.dx, offset.dy);
    }
    for (final point in visible.reversed) {
      final offset = _point(plot, axis, point.x, -point.y);
      path.lineTo(offset.dx, offset.dy);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()..color = series.color.withValues(alpha: 0.72),
    );
  }

  void _drawStackedArea(Canvas canvas, Rect plot) {
    final series = controller.series.where((item) => item.visible).toList();
    if (series.isEmpty) return;
    final length = series
        .map((item) => item.points.length)
        .fold<int>(0, math.max);
    if (length == 0) return;
    final totals = List<double>.filled(length, 0);
    for (final item in series) {
      for (var index = 0; index < item.points.length; index += 1) {
        totals[index] += item.points[index].y;
      }
    }
    final maximum = math.max(
      1.0,
      totals.fold<double>(0, (value, item) => math.max(value, item)),
    );
    final cumulative = List<double>.filled(length, 0);
    for (final item in series) {
      if (item.points.isEmpty) continue;
      final path = Path();
      for (final (index, point) in item.points.indexed) {
        final top = cumulative[index] + point.y;
        final offset = Offset(
          _x(plot, point.x),
          plot.bottom - top / maximum * plot.height,
        );
        index == 0
            ? path.moveTo(offset.dx, offset.dy)
            : path.lineTo(offset.dx, offset.dy);
      }
      for (final entry in item.points.indexed.toList().reversed) {
        final index = entry.$1;
        final point = entry.$2;
        path.lineTo(
          _x(plot, point.x),
          plot.bottom - cumulative[index] / maximum * plot.height,
        );
        cumulative[index] += point.y;
      }
      path.close();
      canvas.drawPath(path, Paint()..color = item.color.withValues(alpha: 0.8));
      canvas.drawPath(
        path,
        Paint()
          ..color = foreground.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke,
      );
    }
  }

  void _drawThreeDimensional(
    Canvas canvas,
    Rect plot,
    WorkbookPlotSeries series,
    WorkbookPlotAxis axis,
  ) {
    if (series.points.isEmpty) return;
    final yaw = controller.cameraYaw;
    final pitch = controller.cameraPitch;
    final cosYaw = math.cos(yaw);
    final sinYaw = math.sin(yaw);
    final cosPitch = math.cos(pitch);
    final sinPitch = math.sin(pitch);
    final axisRange = axis.maximum - axis.minimum;
    Offset project(WorkbookPlotPoint point) {
      final x =
          ((point.x - controller.xMinimum) /
                  (controller.xMaximum - controller.xMinimum)) *
              2 -
          1;
      final depth = point.y.clamp(-1.0, 1.0);
      final rawZ = point.z ?? point.y;
      final z = axisRange == 0
          ? 0.0
          : ((rawZ - axis.minimum) / axisRange) * 2 - 1;
      final rotatedX = x * cosYaw - depth * sinYaw;
      final rotatedDepth = x * sinYaw + depth * cosYaw;
      final rotatedZ = z * cosPitch - rotatedDepth * sinPitch;
      return Offset(
        plot.center.dx + rotatedX * plot.width * 0.34,
        plot.center.dy - rotatedZ * plot.height * 0.38,
      );
    }

    final path = Path();
    for (final (index, point) in series.points.indexed) {
      final offset = project(point);
      index == 0
          ? path.moveTo(offset.dx, offset.dy)
          : path.lineTo(offset.dx, offset.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = series.color
        ..strokeWidth = series.lineWidth
        ..style = PaintingStyle.stroke,
    );
    for (final point in series.points) {
      canvas.drawCircle(project(point), 1.8, Paint()..color = series.color);
    }
  }

  void _drawXyMap(
    Canvas canvas,
    Rect plot,
    WorkbookPlotSeries series,
    WorkbookPlotAxis latitudeAxis,
  ) {
    if (series.points.isEmpty) return;
    canvas.drawRect(
      plot,
      Paint()..color = const Color(0xff16202a).withValues(alpha: 0.62),
    );
    final path = Path();
    for (final (index, point) in series.points.indexed) {
      var offset = _point(plot, latitudeAxis, point.x, point.y);
      if (controller.spec.isometric) {
        final local = offset - plot.center;
        offset =
            plot.center +
            Offset((local.dx - local.dy) * 0.72, (local.dx + local.dy) * 0.36);
      }
      index == 0
          ? path.moveTo(offset.dx, offset.dy)
          : path.lineTo(offset.dx, offset.dy);
      if (index == series.points.length - 1) {
        canvas.drawCircle(offset, 5, Paint()..color = series.color);
        canvas.drawCircle(
          offset,
          9,
          Paint()
            ..color = series.color.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = series.color
        ..strokeWidth = math.max(2, series.lineWidth)
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawSankey(Canvas canvas, Rect plot) {
    final nodes = controller.nodes;
    if (nodes.isEmpty) {
      _WorkbookPlotPainter._text(
        canvas,
        'Sankey requires nodes and links',
        plot.center,
        foreground,
        11,
      );
      return;
    }
    const nodeWidth = 18.0;
    final sourceOffsets = <String, double>{};
    for (final link in controller.spec.links) {
      final source = nodes
          .where((node) => node.id == link.sourceId)
          .firstOrNull;
      final target = nodes
          .where((node) => node.id == link.targetId)
          .firstOrNull;
      if (source == null || target == null) continue;
      final width = math.max(2.0, link.weight * plot.height);
      final consumed = sourceOffsets[source.id] ?? 0;
      sourceOffsets[source.id] = consumed + width / plot.height;
      final start = Offset(
        plot.left + source.x * plot.width + nodeWidth,
        plot.top + (source.y + consumed) * plot.height + width / 2,
      );
      final end = Offset(
        plot.left + target.x * plot.width,
        plot.top + (target.y + target.height / 2) * plot.height,
      );
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          (start.dx + end.dx) / 2,
          start.dy,
          (start.dx + end.dx) / 2,
          end.dy,
          end.dx,
          end.dy,
        );
      canvas.drawPath(
        path,
        Paint()
          ..color = link.color.withValues(alpha: 0.48)
          ..strokeWidth = width
          ..style = PaintingStyle.stroke,
      );
    }
    for (final node in nodes) {
      final rect = Rect.fromLTWH(
        plot.left + node.x * plot.width,
        plot.top + node.y * plot.height,
        nodeWidth,
        math.max(8, node.height * plot.height),
      );
      canvas.drawRect(
        rect,
        Paint()..color = node.color.withValues(alpha: 0.85),
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = foreground
          ..style = PaintingStyle.stroke,
      );
      _WorkbookPlotPainter._text(
        canvas,
        node.label,
        Offset(rect.center.dx - 30, rect.top - 14),
        foreground,
        10,
      );
    }
  }
}
