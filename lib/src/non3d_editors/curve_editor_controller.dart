part of '../non3d_editors.dart';

@immutable
class BlenderGraphViewport {
  const BlenderGraphViewport({
    this.frameStart = 0,
    this.frameEnd = 120,
    this.valueMin = -1,
    this.valueMax = 1,
  }) : assert(frameStart < frameEnd),
       assert(valueMin < valueMax);

  final double frameStart;
  final double frameEnd;
  final double valueMin;
  final double valueMax;

  BlenderGraphViewport copyWith({
    double? frameStart,
    double? frameEnd,
    double? valueMin,
    double? valueMax,
  }) => BlenderGraphViewport(
    frameStart: frameStart ?? this.frameStart,
    frameEnd: frameEnd ?? this.frameEnd,
    valueMin: valueMin ?? this.valueMin,
    valueMax: valueMax ?? this.valueMax,
  );
}

/// View2D-like navigation state for a Graph Editor window region.
class BlenderGraphViewportController
    extends ValueNotifier<BlenderGraphViewport> {
  BlenderGraphViewportController([super.value = const BlenderGraphViewport()]);

  void setView(BlenderGraphViewport next) {
    if (next.frameStart == value.frameStart &&
        next.frameEnd == value.frameEnd &&
        next.valueMin == value.valueMin &&
        next.valueMax == value.valueMax) {
      return;
    }
    value = next;
  }

  void pan({double frames = 0, double values = 0}) => setView(
    BlenderGraphViewport(
      frameStart: value.frameStart + frames,
      frameEnd: value.frameEnd + frames,
      valueMin: value.valueMin + values,
      valueMax: value.valueMax + values,
    ),
  );

  void zoom({
    required double frameFactor,
    required double valueFactor,
    double frameAnchor = .5,
    double valueAnchor = .5,
  }) {
    final frameSpan = value.frameEnd - value.frameStart;
    final valueSpan = value.valueMax - value.valueMin;
    final frameCenter = value.frameStart + frameSpan * frameAnchor;
    final valueCenter = value.valueMin + valueSpan * valueAnchor;
    final nextFrameSpan = (frameSpan * frameFactor).clamp(.001, 1e9);
    final nextValueSpan = (valueSpan * valueFactor).clamp(.000001, 1e9);
    setView(
      BlenderGraphViewport(
        frameStart: frameCenter - nextFrameSpan * frameAnchor,
        frameEnd: frameCenter + nextFrameSpan * (1 - frameAnchor),
        valueMin: valueCenter - nextValueSpan * valueAnchor,
        valueMax: valueCenter + nextValueSpan * (1 - valueAnchor),
      ),
    );
  }

  void frameAll(
    Iterable<BlenderCurveChannel> channels, {
    double padding = .08,
  }) {
    final keys = channels.expand((channel) => channel.resolvedKeyframes);
    if (keys.isEmpty) return;
    var minFrame = double.infinity;
    var maxFrame = double.negativeInfinity;
    var minValue = double.infinity;
    var maxValue = double.negativeInfinity;
    for (final key in keys) {
      minFrame = math.min(minFrame, key.frame);
      maxFrame = math.max(maxFrame, key.frame);
      minValue = math.min(minValue, key.value);
      maxValue = math.max(maxValue, key.value);
    }
    final frameSpan = math.max(1, maxFrame - minFrame);
    final valueSpan = math.max(.01, maxValue - minValue);
    setView(
      BlenderGraphViewport(
        frameStart: minFrame - frameSpan * padding,
        frameEnd: maxFrame + frameSpan * padding,
        valueMin: minValue - valueSpan * padding,
        valueMax: maxValue + valueSpan * padding,
      ),
    );
  }
}
