part of '../non3d_editors.dart';

const double _blenderGraphScrubHeight = 28;
const double _blenderGraphValueGutter = 38;

class _BlenderGraphCanvas extends StatefulWidget {
  const _BlenderGraphCanvas({
    required this.channels,
    required this.viewport,
    required this.currentFrame,
    required this.currentFrameListenable,
    required this.cursor,
    required this.markers,
    required this.selectedKeyframes,
    required this.activeChannelId,
    required this.onCurrentFrameChanged,
    required this.onSelectionChanged,
    required this.onKeyframeMoved,
    required this.contextMenuItems,
    required this.onContextMenuSelected,
    required this.showCursor,
    required this.showCursorFrame,
    required this.showHandles,
    required this.showOnlySelectedHandles,
    required this.showExtrapolation,
    required this.normalize,
    required this.frameRangeStart,
    required this.frameRangeEnd,
    required this.dataRevision,
  });

  final List<BlenderCurveChannel> channels;
  final BlenderGraphViewportController viewport;
  final double? currentFrame;
  final ValueListenable<double>? currentFrameListenable;
  final Offset cursor;
  final List<BlenderGraphMarker> markers;
  final Set<BlenderGraphKeyframeRef> selectedKeyframes;
  final String? activeChannelId;
  final ValueChanged<double>? onCurrentFrameChanged;
  final ValueChanged<Set<BlenderGraphKeyframeRef>>? onSelectionChanged;
  final ValueChanged<BlenderGraphKeyframeMove>? onKeyframeMoved;
  final List<BlenderMenuItem<String>>? contextMenuItems;
  final ValueChanged<String>? onContextMenuSelected;
  final bool showCursor;
  final bool showCursorFrame;
  final bool showHandles;
  final bool showOnlySelectedHandles;
  final bool showExtrapolation;
  final bool normalize;
  final double? frameRangeStart;
  final double? frameRangeEnd;
  final int dataRevision;

  @override
  State<_BlenderGraphCanvas> createState() => _BlenderGraphCanvasState();
}

class _BlenderGraphCanvasState extends State<_BlenderGraphCanvas> {
  Rect? _selectionRect;
  BlenderGraphKeyframeRef? _movingKey;
  BlenderGraphKeyframeRef? _pendingMovingKey;
  Offset? _pointerDown;
  Offset? _dragStart;
  Offset _dragDelta = Offset.zero;

  Offset _toScreen(Size size, double frame, double value) {
    final view = widget.viewport.value;
    final width = math.max(1, size.width - _blenderGraphValueGutter);
    final height = math.max(1, size.height - _blenderGraphScrubHeight);
    return Offset(
      _blenderGraphValueGutter +
          (frame - view.frameStart) / (view.frameEnd - view.frameStart) * width,
      _blenderGraphScrubHeight +
          (view.valueMax - value) / (view.valueMax - view.valueMin) * height,
    );
  }

  Offset _toGraph(Size size, Offset position) {
    final view = widget.viewport.value;
    final width = math.max(1, size.width - _blenderGraphValueGutter);
    final height = math.max(1, size.height - _blenderGraphScrubHeight);
    return Offset(
      view.frameStart +
          (position.dx - _blenderGraphValueGutter) /
              width *
              (view.frameEnd - view.frameStart),
      view.valueMax -
          (position.dy - _blenderGraphScrubHeight) /
              height *
              (view.valueMax - view.valueMin),
    );
  }

  BlenderGraphKeyframeRef? _hitKey(Size size, Offset position) {
    BlenderGraphKeyframeRef? best;
    var distance = 9.0;
    for (final channel in widget.channels) {
      if (!channel.visible) continue;
      for (final key in channel.resolvedKeyframes) {
        final candidate = _toScreen(size, key.frame, key.value);
        final nextDistance = (candidate - position).distance;
        if (nextDistance <= distance) {
          distance = nextDistance;
          best = BlenderGraphKeyframeRef(channel.id, key.id);
        }
      }
    }
    return best;
  }

  BlenderGraphKeyframe? _findKey(BlenderGraphKeyframeRef ref) {
    for (final channel in widget.channels) {
      if (channel.id != ref.channelId) continue;
      for (final key in channel.resolvedKeyframes) {
        if (key.id == ref.keyframeId) return key;
      }
    }
    return null;
  }

  void _selectAt(Size size, Offset position) {
    final hit = _hitKey(size, position);
    widget.onSelectionChanged?.call(
      hit == null
          ? <BlenderGraphKeyframeRef>{}
          : <BlenderGraphKeyframeRef>{hit},
    );
  }

  void _finishDrag(Size size) {
    final moving = _movingKey;
    if (moving != null && _dragDelta != Offset.zero) {
      final key = _findKey(moving);
      if (key != null) {
        final start = _toScreen(size, key.frame, key.value);
        final graph = _toGraph(size, start + _dragDelta);
        widget.onKeyframeMoved?.call(
          BlenderGraphKeyframeMove(
            keyframe: moving,
            frame: graph.dx,
            value: graph.dy,
          ),
        );
      }
    } else if (_selectionRect case final rect?) {
      final selected = <BlenderGraphKeyframeRef>{};
      for (final channel in widget.channels) {
        if (!channel.visible) continue;
        for (final key in channel.resolvedKeyframes) {
          if (rect.contains(_toScreen(size, key.frame, key.value))) {
            selected.add(BlenderGraphKeyframeRef(channel.id, key.id));
          }
        }
      }
      widget.onSelectionChanged?.call(selected);
    }
    setState(() {
      _movingKey = null;
      _pendingMovingKey = null;
      _pointerDown = null;
      _dragStart = null;
      _dragDelta = Offset.zero;
      _selectionRect = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Listener(
          onPointerSignal: (event) {
            if (event is! PointerScrollEvent) return;
            final factor = math.exp(event.scrollDelta.dy * .0015);
            widget.viewport.zoom(
              frameFactor: factor,
              valueFactor: factor,
              frameAnchor:
                  ((event.localPosition.dx - _blenderGraphValueGutter) /
                          math.max(1, size.width - _blenderGraphValueGutter))
                      .clamp(0, 1),
              valueAnchor:
                  (1 -
                          (event.localPosition.dy - _blenderGraphScrubHeight) /
                              math.max(
                                1,
                                size.height - _blenderGraphScrubHeight,
                              ))
                      .clamp(0, 1),
            );
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (details) {
              _pointerDown = details.localPosition;
              _pendingMovingKey = _hitKey(size, details.localPosition);
            },
            onTapUp: (details) {
              if (details.localPosition.dy <= _blenderGraphScrubHeight) {
                widget.onCurrentFrameChanged?.call(
                  _toGraph(size, details.localPosition).dx,
                );
              } else {
                _selectAt(size, details.localPosition);
              }
            },
            onPanStart: (details) {
              // onPanStart arrives after touch slop; retain the exact pointer
              // down location so compact keyframe targets remain draggable.
              final start = _pointerDown ?? details.localPosition;
              final hit = _pendingMovingKey;
              setState(() {
                _dragStart = start;
                _movingKey = hit;
                _selectionRect = hit == null
                    ? Rect.fromPoints(start, start)
                    : null;
              });
            },
            onPanUpdate: (details) {
              final start = _dragStart;
              if (start == null) return;
              setState(() {
                _dragDelta = details.localPosition - start;
                if (_movingKey == null) {
                  _selectionRect = Rect.fromPoints(
                    start,
                    details.localPosition,
                  );
                }
              });
            },
            onPanEnd: (_) => _finishDrag(size),
            onPanCancel: () => _finishDrag(size),
            onSecondaryTapDown: widget.contextMenuItems == null
                ? null
                : (details) => showBlenderContextMenu<String>(
                    context: context,
                    globalPosition: details.globalPosition,
                    items: widget.contextMenuItems!,
                    title: 'F-Curve',
                    onSelected: widget.onContextMenuSelected,
                  ),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                RepaintBoundary(
                  child: CustomPaint(
                    key: const ValueKey<String>('graph-static-canvas'),
                    painter: _BlenderGraphPainter(
                      channels: widget.channels,
                      viewport: widget.viewport,
                      cursor: widget.cursor,
                      markers: widget.markers,
                      selectedKeyframes: widget.selectedKeyframes,
                      activeChannelId: widget.activeChannelId,
                      movingKeyframe: _movingKey,
                      movingDelta: _dragDelta,
                      showCursor: widget.showCursor,
                      showCursorFrame: widget.showCursorFrame,
                      showHandles: widget.showHandles,
                      showOnlySelectedHandles: widget.showOnlySelectedHandles,
                      showExtrapolation: widget.showExtrapolation,
                      normalize: widget.normalize,
                      frameRangeStart: widget.frameRangeStart,
                      frameRangeEnd: widget.frameRangeEnd,
                      colors: theme.colors,
                      textTheme: theme.textTheme,
                      dataRevision: widget.dataRevision,
                    ),
                    isComplex: true,
                  ),
                ),
                RepaintBoundary(
                  child: CustomPaint(
                    key: const ValueKey<String>('graph-overlay-canvas'),
                    painter: _BlenderGraphOverlayPainter(
                      viewport: widget.viewport,
                      currentFrame: widget.currentFrame,
                      currentFrameListenable: widget.currentFrameListenable,
                      selectionRect: _selectionRect,
                      colors: theme.colors,
                      textTheme: theme.textTheme,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
