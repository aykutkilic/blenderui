part of '../editors.dart';

int _timelineLowerBound<T>(
  List<T> values,
  double frame,
  double Function(T value) frameOf,
) {
  var low = 0;
  var high = values.length;
  while (low < high) {
    final middle = low + ((high - low) >> 1);
    if (frameOf(values[middle]) < frame) {
      low = middle + 1;
    } else {
      high = middle;
    }
  }
  return low;
}

int _timelineUpperBound<T>(
  List<T> values,
  double frame,
  double Function(T value) frameOf,
) {
  var low = 0;
  var high = values.length;
  while (low < high) {
    final middle = low + ((high - low) >> 1);
    if (frameOf(values[middle]) <= frame) {
      low = middle + 1;
    } else {
      high = middle;
    }
  }
  return low;
}

/// Static Timeline layer: grid, ruler, channel separators, and keyframes.
///
/// It deliberately excludes the playhead, so advancing one frame does not
/// repaint or rescan animation data. Blender follows the same split through
/// its main-region and current-frame overlay draw callbacks.
class _BlenderTimelineStaticPainter extends CustomPainter {
  _BlenderTimelineStaticPainter({
    required this.renderData,
    required this.trackHeight,
    required this.scrubHeight,
    required this.colors,
    required this.textTheme,
    required this.visibleStart,
    required this.visibleEnd,
    required this.summaryOnly,
  }) : _linePaint = Paint()
         ..color = colors.borderSubtle.withValues(alpha: .52)
         ..strokeWidth = 1,
       _canvasPaint = Paint()..color = colors.canvas,
       _scrubPaint = Paint()..color = colors.surface;

  final _BlenderTimelineRenderData renderData;
  final double trackHeight;
  final double scrubHeight;
  final BlenderColorScheme colors;
  final BlenderTextTheme textTheme;
  final double visibleStart;
  final double visibleEnd;
  final bool summaryOnly;
  final Paint _linePaint;
  final Paint _canvasPaint;
  final Paint _scrubPaint;

  double _niceTickStep(double width) {
    final raw = (visibleEnd - visibleStart) / math.max(1, width / 90);
    final magnitude = math
        .pow(10, (math.log(raw) / math.ln10).floor())
        .toDouble();
    for (final multiplier in const <double>[1, 2, 3, 6, 10]) {
      final candidate = multiplier * magnitude;
      if (candidate >= raw) return candidate;
    }
    return 10 * magnitude;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final range = math.max(.0001, visibleEnd - visibleStart);
    canvas.drawRect(Offset.zero & size, _canvasPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, scrubHeight), _scrubPaint);

    // Batch the grid and separators into one draw rather than issuing a draw
    // call for every line.
    final gridPath = Path()
      ..moveTo(0, scrubHeight)
      ..lineTo(size.width, scrubHeight);
    final step = _niceTickStep(size.width);
    for (
      var frame = (visibleStart / step).ceil() * step;
      frame <= visibleEnd;
      frame += step
    ) {
      final x = (frame - visibleStart) / range * size.width;
      gridPath
        ..moveTo(x, 0)
        ..lineTo(x, size.height);
      final textPainter = TextPainter(
        text: TextSpan(
          text: frame.toStringAsFixed(0),
          style: textTheme.caption.copyWith(color: colors.foregroundMuted),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(x + 3, 6));
    }

    final rowCount = summaryOnly
        ? 1
        : math.min(
            renderData.tracks.length,
            math.max(0, ((size.height - scrubHeight) / trackHeight).ceil()),
          );
    for (var index = 0; index < rowCount; index++) {
      final y = scrubHeight + (index + 1) * trackHeight;
      gridPath
        ..moveTo(0, y)
        ..lineTo(size.width, y);
    }
    canvas.drawPath(gridPath, _linePaint);

    if (summaryOnly) {
      _drawSummaryKeys(canvas, size.width, range);
    } else {
      _drawTrackKeys(canvas, size, range, rowCount);
    }
  }

  void _drawSummaryKeys(Canvas canvas, double width, double range) {
    // Do not materialize a scene-wide Summary keylist. Blender asks each
    // prepared channel for the visible View2D range; doing the same bounds
    // memory and work to the keys that can affect this paint.
    final visibleFrames = <double>{};
    for (final track in renderData.tracks) {
      final keys = track.keyframes;
      final startIndex = _timelineLowerBound<BlenderTimelineKeyframe>(
        keys,
        visibleStart,
        (key) => key.frame,
      );
      final endIndex = _timelineUpperBound<BlenderTimelineKeyframe>(
        keys,
        visibleEnd,
        (key) => key.frame,
      );
      for (var index = startIndex; index < endIndex; index++) {
        visibleFrames.add(keys[index].frame);
      }
    }
    if (visibleFrames.isEmpty) return;
    final frames = visibleFrames.toList()..sort();

    final y = scrubHeight + trackHeight / 2;
    final path = Path();
    for (final frame in frames) {
      final x = (frame - visibleStart) / range * width;
      _addDiamond(path, x, y, 4);
    }
    canvas.drawPath(path, Paint()..color = colors.accent);
  }

  void _drawTrackKeys(Canvas canvas, Size size, double range, int rowCount) {
    final paths = <Color, Path>{};
    for (var trackIndex = 0; trackIndex < rowCount; trackIndex++) {
      final keys = renderData.tracks[trackIndex].keyframes;
      final startIndex = _timelineLowerBound<BlenderTimelineKeyframe>(
        keys,
        visibleStart,
        (key) => key.frame,
      );
      final endIndex = _timelineUpperBound<BlenderTimelineKeyframe>(
        keys,
        visibleEnd,
        (key) => key.frame,
      );
      final y = scrubHeight + trackIndex * trackHeight + trackHeight / 2;
      for (var keyIndex = startIndex; keyIndex < endIndex; keyIndex++) {
        final keyframe = keys[keyIndex];
        final x = (keyframe.frame - visibleStart) / range * size.width;
        final color = keyframe.color ?? colors.accent;
        _addDiamond(paths.putIfAbsent(color, Path.new), x, y, 5);
      }
    }
    for (final MapEntry(key: color, value: path) in paths.entries) {
      canvas.drawPath(path, Paint()..color = color);
    }
  }

  static void _addDiamond(Path path, double x, double y, double radius) {
    path
      ..moveTo(x - radius, y)
      ..lineTo(x, y - radius)
      ..lineTo(x + radius, y)
      ..lineTo(x, y + radius)
      ..close();
  }

  @override
  bool shouldRepaint(_BlenderTimelineStaticPainter oldDelegate) {
    return renderData != oldDelegate.renderData ||
        trackHeight != oldDelegate.trackHeight ||
        scrubHeight != oldDelegate.scrubHeight ||
        colors != oldDelegate.colors ||
        textTheme != oldDelegate.textTheme ||
        visibleStart != oldDelegate.visibleStart ||
        visibleEnd != oldDelegate.visibleEnd ||
        summaryOnly != oldDelegate.summaryOnly;
  }
}

/// Fast-changing Timeline overlay containing only the current-frame marker.
class _BlenderTimelinePlayheadPainter extends CustomPainter {
  _BlenderTimelinePlayheadPainter({
    required this.currentFrame,
    required this.currentFrameListenable,
    required this.colors,
    required this.textTheme,
    required this.visibleStart,
    required this.visibleEnd,
    required this.scrubHeight,
  }) : _playheadPaint = Paint()
         ..color = colors.accent
         ..strokeWidth = 2,
       _labelPainter = TextPainter(
         text: TextSpan(
           text: (currentFrameListenable?.value ?? currentFrame)
               .round()
               .toString(),
           style: textTheme.body.copyWith(color: colors.foreground),
         ),
         textDirection: TextDirection.ltr,
       )..layout(),
       super(repaint: currentFrameListenable);

  final double currentFrame;
  final ValueListenable<double>? currentFrameListenable;
  final BlenderColorScheme colors;
  final BlenderTextTheme textTheme;
  final double visibleStart;
  final double visibleEnd;
  final double scrubHeight;
  final Paint _playheadPaint;
  final TextPainter _labelPainter;

  double get _resolvedFrame => currentFrameListenable?.value ?? currentFrame;

  @override
  void paint(Canvas canvas, Size size) {
    final range = math.max(.0001, visibleEnd - visibleStart);
    final scale = scrubHeight / 28;
    final frame = _resolvedFrame;
    final x = (frame - visibleStart) / range * size.width;
    final label = frame.round().toString();
    if ((_labelPainter.text as TextSpan).text != label) {
      _labelPainter.text = TextSpan(
        text: label,
        style: textTheme.body.copyWith(color: colors.foreground),
      );
      _labelPainter.layout();
    }
    canvas.drawLine(
      Offset(x, scrubHeight - 1),
      Offset(x, size.height),
      _playheadPaint,
    );

    final boxWidth = math.max(24, _labelPainter.width + 8).toDouble();
    final box = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(x, (scrubHeight - 6 * scale) / 2),
        width: boxWidth,
        height: scrubHeight - 6 * scale,
      ),
      Radius.circular(3 * scale),
    );
    canvas.drawRRect(box, _playheadPaint);
    canvas.drawPath(
      Path()
        ..moveTo(x - 5 * scale, scrubHeight - 5 * scale)
        ..lineTo(x + 5 * scale, scrubHeight - 5 * scale)
        ..lineTo(x, scrubHeight + scale)
        ..close(),
      _playheadPaint,
    );
    _labelPainter.paint(canvas, Offset(x - _labelPainter.width / 2, 4 * scale));
  }

  @override
  bool shouldRepaint(_BlenderTimelinePlayheadPainter oldDelegate) {
    return currentFrameListenable != oldDelegate.currentFrameListenable ||
        (currentFrameListenable == null &&
            currentFrame != oldDelegate.currentFrame) ||
        scrubHeight != oldDelegate.scrubHeight ||
        colors != oldDelegate.colors ||
        textTheme != oldDelegate.textTheme ||
        visibleStart != oldDelegate.visibleStart ||
        visibleEnd != oldDelegate.visibleEnd;
  }
}
