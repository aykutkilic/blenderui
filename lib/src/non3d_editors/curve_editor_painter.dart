part of '../non3d_editors.dart';

double _graphNiceStep(double span, double pixels, double targetPixels) {
  final raw = span / math.max(1, pixels / targetPixels);
  final magnitude = math
      .pow(10, (math.log(raw) / math.ln10).floor())
      .toDouble();
  for (final multiplier in const <double>[1, 2, 5, 10]) {
    final candidate = magnitude * multiplier;
    if (candidate >= raw) return candidate;
  }
  return magnitude * 10;
}

class _BlenderGraphPainter extends CustomPainter {
  _BlenderGraphPainter({
    required this.channels,
    required this.viewport,
    required this.cursor,
    required this.markers,
    required this.selectedKeyframes,
    required this.activeChannelId,
    required this.movingKeyframe,
    required this.movingDelta,
    required this.showCursor,
    required this.showCursorFrame,
    required this.showHandles,
    required this.showOnlySelectedHandles,
    required this.showExtrapolation,
    required this.normalize,
    required this.frameRangeStart,
    required this.frameRangeEnd,
    required this.colors,
    required this.textTheme,
    required this.dataRevision,
  }) : super(repaint: viewport);

  final List<BlenderCurveChannel> channels;
  final BlenderGraphViewportController viewport;
  final Offset cursor;
  final List<BlenderGraphMarker> markers;
  final Set<BlenderGraphKeyframeRef> selectedKeyframes;
  final String? activeChannelId;
  final BlenderGraphKeyframeRef? movingKeyframe;
  final Offset movingDelta;
  final bool showCursor;
  final bool showCursorFrame;
  final bool showHandles;
  final bool showOnlySelectedHandles;
  final bool showExtrapolation;
  final bool normalize;
  final double? frameRangeStart;
  final double? frameRangeEnd;
  final BlenderColorScheme colors;
  final BlenderTextTheme textTheme;
  final int dataRevision;

  Rect _plot(Size size) => Rect.fromLTRB(
    _blenderGraphValueGutter,
    _blenderGraphScrubHeight,
    size.width,
    size.height,
  );

  Offset _screen(Size size, double frame, double value) {
    final view = viewport.value;
    final plot = _plot(size);
    return Offset(
      plot.left +
          (frame - view.frameStart) /
              (view.frameEnd - view.frameStart) *
              plot.width,
      plot.top +
          (view.valueMax - value) /
              (view.valueMax - view.valueMin) *
              plot.height,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final plot = _plot(size);
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.canvas);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, _blenderGraphScrubHeight),
      Paint()..color = colors.surface,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, plot.top, _blenderGraphValueGutter, plot.height),
      Paint()..color = colors.surface,
    );
    _drawGrid(canvas, size);
    _drawFrameRange(canvas, size);
    if (normalize) _drawNormalizationBounds(canvas, size);
    _drawCursor(canvas, size);
    _drawMarkers(canvas, size);

    canvas.save();
    canvas.clipRect(plot);
    final visible = channels.where((channel) => channel.visible).toList();
    for (final selectedPass in const <bool>[false, true]) {
      for (final channel in visible) {
        final emphasized =
            channel.selected || channel.active || channel.id == activeChannelId;
        if (emphasized != selectedPass) continue;
        _drawChannel(canvas, size, channel, emphasized);
      }
    }
    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Size size) {
    final view = viewport.value;
    final plot = _plot(size);
    final gridPath = Path();
    final xStep = _graphNiceStep(
      view.frameEnd - view.frameStart,
      plot.width,
      92,
    );
    for (
      var frame = (view.frameStart / xStep).ceil() * xStep;
      frame <= view.frameEnd;
      frame += xStep
    ) {
      final x = _screen(size, frame, view.valueMin).dx;
      gridPath
        ..moveTo(x, 0)
        ..lineTo(x, size.height);
      _label(
        canvas,
        frame.toStringAsFixed(xStep < 1 ? 2 : 0),
        Offset(x + 4, 7),
      );
    }
    final yStep = _graphNiceStep(
      view.valueMax - view.valueMin,
      plot.height,
      78,
    );
    for (
      var value = (view.valueMin / yStep).ceil() * yStep;
      value <= view.valueMax;
      value += yStep
    ) {
      final y = _screen(size, view.frameStart, value).dy;
      gridPath
        ..moveTo(plot.left, y)
        ..lineTo(size.width, y);
      _label(
        canvas,
        value.toStringAsFixed(
          yStep < .1
              ? 3
              : yStep < 1
              ? 2
              : 0,
        ),
        Offset(3, y - 7),
        maxWidth: _blenderGraphValueGutter - 6,
      );
    }
    canvas.drawPath(
      gridPath,
      Paint()
        ..color = colors.borderSubtle.withValues(alpha: .70)
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(plot.left, 0),
      Offset(plot.left, size.height),
      Paint()..color = colors.border,
    );
  }

  void _label(Canvas canvas, String value, Offset offset, {double? maxWidth}) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: textTheme.caption.copyWith(color: colors.foregroundMuted),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth ?? double.infinity);
    painter.paint(canvas, offset);
  }

  void _drawNormalizationBounds(Canvas canvas, Size size) {
    final plot = _plot(size);
    final top = _screen(size, 0, 1).dy;
    final bottom = _screen(size, 0, -1).dy;
    final shade = Paint()..color = colors.surface.withValues(alpha: .42);
    if (top > plot.top) {
      canvas.drawRect(
        Rect.fromLTRB(plot.left, plot.top, plot.right, top),
        shade,
      );
    }
    if (bottom < plot.bottom) {
      canvas.drawRect(
        Rect.fromLTRB(plot.left, bottom, plot.right, plot.bottom),
        shade,
      );
    }
  }

  void _drawCursor(Canvas canvas, Size size) {
    if (!showCursor) return;
    final y = _screen(size, cursor.dx, cursor.dy).dy;
    canvas.drawLine(
      Offset(_blenderGraphValueGutter, y),
      Offset(size.width, y),
      Paint()
        ..color = colors.focus.withValues(alpha: .48)
        ..strokeWidth = 1.5,
    );
    if (showCursorFrame) {
      final x = _screen(size, cursor.dx, cursor.dy).dx;
      canvas.drawLine(
        Offset(x, _blenderGraphScrubHeight),
        Offset(x, size.height),
        Paint()
          ..color = colors.focus.withValues(alpha: .48)
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawFrameRange(Canvas canvas, Size size) {
    final start = frameRangeStart;
    final end = frameRangeEnd;
    if (start == null || end == null || start >= end) return;
    final plot = _plot(size);
    final left = _screen(size, start, 0).dx;
    final right = _screen(size, end, 0).dx;
    final shade = Paint()..color = colors.surface.withValues(alpha: .38);
    if (left > plot.left) {
      canvas.drawRect(Rect.fromLTRB(plot.left, plot.top, left, plot.bottom), shade);
    }
    if (right < plot.right) {
      canvas.drawRect(Rect.fromLTRB(right, plot.top, plot.right, plot.bottom), shade);
    }
  }

  void _drawMarkers(Canvas canvas, Size size) {
    final view = viewport.value;
    for (final marker in markers) {
      if (marker.frame < view.frameStart || marker.frame > view.frameEnd) {
        continue;
      }
      final x = _screen(size, marker.frame, view.valueMin).dx;
      final path = Path()
        ..moveTo(x, size.height - 13)
        ..lineTo(x - 5, size.height - 4)
        ..lineTo(x + 5, size.height - 4)
        ..close();
      canvas.drawPath(path, Paint()..color = colors.foregroundMuted);
      _label(canvas, marker.label, Offset(x + 7, size.height - 18));
    }
  }

  int _lowerBound(List<BlenderGraphKeyframe> keys, double frame) {
    var low = 0;
    var high = keys.length;
    while (low < high) {
      final middle = (low + high) >> 1;
      if (keys[middle].frame < frame) {
        low = middle + 1;
      } else {
        high = middle;
      }
    }
    return low;
  }

  double Function(double) _valueMapper(List<BlenderGraphKeyframe> keys) {
    if (!normalize || keys.isEmpty) return (value) => value;
    var minimum = double.infinity;
    var maximum = double.negativeInfinity;
    for (final key in keys) {
      minimum = math.min(minimum, key.value);
      maximum = math.max(maximum, key.value);
    }
    final range = math.max(.000001, maximum - minimum);
    return (value) => ((value - minimum) / range) * 2 - 1;
  }

  void _drawChannel(
    Canvas canvas,
    Size size,
    BlenderCurveChannel channel,
    bool emphasized,
  ) {
    final keys = channel.resolvedKeyframes;
    if (keys.isEmpty) return;
    final view = viewport.value;
    final firstVisible = _lowerBound(keys, view.frameStart);
    final afterVisible = _lowerBound(keys, view.frameEnd);
    final first = math.max(0, firstVisible - 1);
    final last = math.min(keys.length - 1, afterVisible);
    final mapValue = _valueMapper(keys);
    Offset point(int index) {
      final key = keys[index];
      final base = _screen(size, key.frame, mapValue(key.value));
      return movingKeyframe == BlenderGraphKeyframeRef(channel.id, key.id)
          ? base + movingDelta
          : base;
    }

    final curvePath = Path();
    if (showExtrapolation && first == 0 && view.frameStart < keys.first.frame) {
      final firstPoint = point(0);
      if (channel.extrapolation == BlenderGraphExtrapolation.linear &&
          keys.length > 1) {
        final nextPoint = point(1);
        final dx = math.max(.0001, nextPoint.dx - firstPoint.dx);
        final slope = (nextPoint.dy - firstPoint.dy) / dx;
        curvePath.moveTo(
          _blenderGraphValueGutter,
          firstPoint.dy - slope * (firstPoint.dx - _blenderGraphValueGutter),
        );
      } else {
        curvePath.moveTo(_blenderGraphValueGutter, firstPoint.dy);
      }
      curvePath.lineTo(firstPoint.dx, firstPoint.dy);
    } else {
      curvePath.moveTo(point(first).dx, point(first).dy);
    }
    for (var index = first; index < last; index++) {
      final current = keys[index];
      final a = point(index);
      final b = point(index + 1);
      switch (current.interpolation) {
        case BlenderGraphInterpolation.constant:
          curvePath
            ..lineTo(b.dx, a.dy)
            ..lineTo(b.dx, b.dy);
        case BlenderGraphInterpolation.linear:
          curvePath.lineTo(b.dx, b.dy);
        case BlenderGraphInterpolation.bezier:
          final right = _rightHandle(keys, index, mapValue, size, point);
          final left = _leftHandle(keys, index + 1, mapValue, size, point);
          curvePath.cubicTo(right.dx, right.dy, left.dx, left.dy, b.dx, b.dy);
      }
    }
    if (showExtrapolation && last == keys.length - 1 && view.frameEnd > keys.last.frame) {
      final lastPoint = point(last);
      if (channel.extrapolation == BlenderGraphExtrapolation.linear &&
          keys.length > 1) {
        final previous = point(last - 1);
        final dx = math.max(.0001, lastPoint.dx - previous.dx);
        final slope = (lastPoint.dy - previous.dy) / dx;
        curvePath.lineTo(
          size.width,
          lastPoint.dy + slope * (size.width - lastPoint.dx),
        );
      } else {
        curvePath.lineTo(size.width, lastPoint.dy);
      }
    }
    final color = channel.muted
        ? colors.foregroundDisabled
        : channel.color ?? colors.accent;
    final curvePaint = Paint()
      ..color = color.withValues(alpha: emphasized ? 1 : .58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = emphasized ? 2.5 : 1.25;
    if (channel.locked) {
      _drawDashedPath(canvas, curvePath, curvePaint, dash: 8, gap: 5);
    } else {
      canvas.drawPath(curvePath, curvePaint);
    }
    _drawControls(
      canvas,
      size,
      channel,
      keys,
      point,
      mapValue,
      color,
      firstVisible: firstVisible,
      afterVisible: afterVisible,
    );
  }

  Offset _rightHandle(
    List<BlenderGraphKeyframe> keys,
    int index,
    double Function(double) mapValue,
    Size size,
    Offset Function(int) point,
  ) {
    final explicit = keys[index].rightHandle;
    if (explicit != null) {
      return _screen(size, explicit.dx, mapValue(explicit.dy));
    }
    final previous = point(math.max(0, index - 1));
    final next = point(math.min(keys.length - 1, index + 1));
    return point(index) + (next - previous) / 6;
  }

  Offset _leftHandle(
    List<BlenderGraphKeyframe> keys,
    int index,
    double Function(double) mapValue,
    Size size,
    Offset Function(int) point,
  ) {
    final explicit = keys[index].leftHandle;
    if (explicit != null) {
      return _screen(size, explicit.dx, mapValue(explicit.dy));
    }
    final previous = point(math.max(0, index - 1));
    final next = point(math.min(keys.length - 1, index + 1));
    return point(index) - (next - previous) / 6;
  }

  void _drawControls(
    Canvas canvas,
    Size size,
    BlenderCurveChannel channel,
    List<BlenderGraphKeyframe> keys,
    Offset Function(int) point,
    double Function(double) mapValue,
    Color curveColor,
    {required int firstVisible,
    required int afterVisible,}
  ) {
    final active = channel.id == activeChannelId || channel.active;
    Offset? lastDrawn;
    for (
      var index = firstVisible;
      index < math.min(afterVisible + 1, keys.length);
      index++
    ) {
      final key = keys[index];
      final ref = BlenderGraphKeyframeRef(channel.id, key.id);
      final selected = key.selected || selectedKeyframes.contains(ref);
      final center = point(index);
      final dense = lastDrawn != null && (center - lastDrawn).distance < 3;
      if (dense && !selected) continue;
      lastDrawn = center;
      final drawHandles =
          showHandles &&
          key.interpolation == BlenderGraphInterpolation.bezier &&
          (!showOnlySelectedHandles || selected) &&
          (selected || active);
      if (drawHandles) {
        final left = _leftHandle(keys, index, mapValue, size, point);
        final right = _rightHandle(keys, index, mapValue, size, point);
        final handlePaint = Paint()
          ..color = selected
              ? colors.foreground
              : colors.foregroundMuted.withValues(alpha: .7)
          ..strokeWidth = 1;
        canvas.drawLine(left, center, handlePaint);
        canvas.drawLine(center, right, handlePaint);
        canvas.drawCircle(left, 3, handlePaint);
        canvas.drawCircle(right, 3, handlePaint);
      }
      canvas.drawCircle(
        center,
        selected ? 4.5 : 3.5,
        Paint()..color = selected ? colors.foreground : colors.canvas,
      );
      canvas.drawCircle(
        center,
        selected ? 4.5 : 3.5,
        Paint()
          ..color = active && selected ? colors.focus : curveColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = selected ? 2 : 1.25,
      );
    }
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dash,
    required double gap,
  }) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            math.min(distance + dash, metric.length),
          ),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_BlenderGraphPainter oldDelegate) =>
      channels != oldDelegate.channels ||
      selectedKeyframes != oldDelegate.selectedKeyframes ||
      activeChannelId != oldDelegate.activeChannelId ||
      movingKeyframe != oldDelegate.movingKeyframe ||
      movingDelta != oldDelegate.movingDelta ||
      cursor != oldDelegate.cursor ||
      markers != oldDelegate.markers ||
      showCursor != oldDelegate.showCursor ||
      showCursorFrame != oldDelegate.showCursorFrame ||
      showHandles != oldDelegate.showHandles ||
      showOnlySelectedHandles != oldDelegate.showOnlySelectedHandles ||
      showExtrapolation != oldDelegate.showExtrapolation ||
      normalize != oldDelegate.normalize ||
      frameRangeStart != oldDelegate.frameRangeStart ||
      frameRangeEnd != oldDelegate.frameRangeEnd ||
      colors != oldDelegate.colors ||
      textTheme != oldDelegate.textTheme ||
      dataRevision != oldDelegate.dataRevision ||
      viewport != oldDelegate.viewport;
}

class _BlenderGraphOverlayPainter extends CustomPainter {
  _BlenderGraphOverlayPainter({
    required this.viewport,
    required this.currentFrame,
    required this.currentFrameListenable,
    required this.selectionRect,
    required this.colors,
    required this.textTheme,
  }) : super(
         repaint: Listenable.merge(<Listenable>[
           viewport,
           if (currentFrameListenable != null) currentFrameListenable,
         ]),
       );

  final BlenderGraphViewportController viewport;
  final double? currentFrame;
  final ValueListenable<double>? currentFrameListenable;
  final Rect? selectionRect;
  final BlenderColorScheme colors;
  final BlenderTextTheme textTheme;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = currentFrameListenable?.value ?? currentFrame;
    if (frame != null) {
      final view = viewport.value;
      final x =
          _blenderGraphValueGutter +
          (frame - view.frameStart) /
              (view.frameEnd - view.frameStart) *
              (size.width - _blenderGraphValueGutter);
      final paint = Paint()
        ..color = colors.focus
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(x, _blenderGraphScrubHeight - 1),
        Offset(x, size.height),
        paint,
      );
      final text = TextPainter(
        text: TextSpan(
          text: frame.round().toString(),
          style: textTheme.body.copyWith(color: colors.foreground),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final width = math.max(24, text.width + 8).toDouble();
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, 12), width: width, height: 22),
          const Radius.circular(3),
        ),
        paint,
      );
      text.paint(canvas, Offset(x - text.width / 2, 4));
    }
    if (selectionRect case final rect?) {
      canvas.drawRect(
        rect,
        Paint()..color = colors.selection.withValues(alpha: .18),
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = colors.focus
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_BlenderGraphOverlayPainter oldDelegate) =>
      viewport != oldDelegate.viewport ||
      currentFrameListenable != oldDelegate.currentFrameListenable ||
      (currentFrameListenable == null &&
          currentFrame != oldDelegate.currentFrame) ||
      selectionRect != oldDelegate.selectionRect ||
      colors != oldDelegate.colors ||
      textTheme != oldDelegate.textTheme;
}
