import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'controls.dart';
import 'docking_model.dart';
import 'layout.dart';
import 'theme.dart';

part 'docking/area_edge_options.dart';

typedef BlenderDockAreaBuilder<T> =
    Widget Function(BuildContext context, BlenderDockAreaNode<T> area);

/// Renders a resizable editor tree with Blender-style corner split/dock zones.
class BlenderDockingWorkspace<T> extends StatefulWidget {
  const BlenderDockingWorkspace({
    super.key,
    required this.controller,
    required this.areaBuilder,
    this.cloneValue,
    this.minimumAreaExtent = 52,
    this.cornerExtent = 14,
  });

  final BlenderDockingController<T> controller;
  final BlenderDockAreaBuilder<T> areaBuilder;
  final T Function(T value)? cloneValue;
  final double minimumAreaExtent;
  final double cornerExtent;

  @override
  State<BlenderDockingWorkspace<T>> createState() =>
      _BlenderDockingWorkspaceState<T>();
}

class _BlenderDockingWorkspaceState<T>
    extends State<BlenderDockingWorkspace<T>> {
  final GlobalKey _workspaceKey = GlobalKey();
  final Map<String, GlobalKey> _areaKeys = <String, GlobalKey>{};
  _DockDragPreview? _preview;
  _DockEdgeSelection<T>? _activeEdge;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTreeChanged);
  }

  @override
  void didUpdateWidget(BlenderDockingWorkspace<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_handleTreeChanged);
    widget.controller.addListener(_handleTreeChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTreeChanged);
    super.dispose();
  }

  void _handleTreeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _workspaceKey,
      clipBehavior: Clip.hardEdge,
      children: <Widget>[
        Positioned.fill(child: _buildNode(widget.controller.root)),
        if (_preview != null)
          Positioned.fill(
            child: IgnorePointer(
              child: _DockPreviewOverlay(preview: _preview!),
            ),
          ),
      ],
    );
  }

  Widget _buildNode(BlenderDockNode<T> node) {
    if (node is BlenderDockSplitNode<T>) {
      return BlenderSplitter(
        key: ValueKey<String>(node.id),
        direction: node.direction,
        initialFraction: node.fraction,
        onFractionChanged: (value) =>
            widget.controller.setSplitFraction(node.id, value),
        dividerKey: ValueKey<String>('dock-divider-${node.id}'),
        onDividerSecondaryTapDown: (details) =>
            _showAreaOptions(context, node, details.globalPosition),
        first: _buildNode(node.first),
        second: _buildNode(node.second),
      );
    }
    final area = node as BlenderDockAreaNode<T>;
    final areaKey = _areaKeys.putIfAbsent(area.id, GlobalKey.new);
    return ClipRect(
      key: areaKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layoutWidth = math.max(
            constraints.maxWidth,
            widget.minimumAreaExtent,
          );
          final layoutHeight = math.max(
            constraints.maxHeight,
            widget.minimumAreaExtent,
          );
          return OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: layoutWidth,
            maxWidth: layoutWidth,
            minHeight: layoutHeight,
            maxHeight: layoutHeight,
            child: SizedBox(
              width: layoutWidth,
              height: layoutHeight,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  widget.areaBuilder(context, area),
                  for (final corner in BlenderDockCorner.values)
                    _positionCornerHandle(area.id, corner),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _positionCornerHandle(String areaId, BlenderDockCorner corner) {
    final top =
        corner == BlenderDockCorner.topLeft ||
        corner == BlenderDockCorner.topRight;
    final left =
        corner == BlenderDockCorner.topLeft ||
        corner == BlenderDockCorner.bottomLeft;
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      width: widget.cornerExtent,
      height: widget.cornerExtent,
      child: _DockCornerHandle(
        corner: corner,
        onStart: (position) => _startDrag(areaId, corner, position),
        onUpdate: _updateDrag,
        onEnd: _endDrag,
        onCancel: _cancelDrag,
      ),
    );
  }

  void _startDrag(
    String sourceAreaId,
    BlenderDockCorner corner,
    Offset globalPosition,
  ) {
    setState(() {
      _preview = _DockDragPreview.pending(
        sourceAreaId: sourceAreaId,
        corner: corner,
        startGlobal: globalPosition,
      );
    });
  }

  void _updateDrag(Offset globalPosition) {
    final current = _preview;
    if (current == null) return;
    if ((globalPosition - current.startGlobal).distance < 20) return;
    final sourceGlobal = _globalAreaRect(current.sourceAreaId);
    if (sourceGlobal == null) return;

    if (sourceGlobal.contains(globalPosition)) {
      final delta = globalPosition - current.startGlobal;
      final direction = delta.dx.abs() > delta.dy.abs()
          ? BlenderSplitDirection.horizontal
          : BlenderSplitDirection.vertical;
      final extent = direction == BlenderSplitDirection.horizontal
          ? sourceGlobal.width
          : sourceGlobal.height;
      if (extent < widget.minimumAreaExtent * 2) return;
      final rawFraction = direction == BlenderSplitDirection.horizontal
          ? (globalPosition.dx - sourceGlobal.left) / sourceGlobal.width
          : (globalPosition.dy - sourceGlobal.top) / sourceGlobal.height;
      final minimumFraction = widget.minimumAreaExtent / extent;
      final fraction = rawFraction
          .clamp(minimumFraction, 1 - minimumFraction)
          .toDouble();
      setState(() {
        _preview = current.asSplit(
          pointer: _workspaceLocal(globalPosition),
          sourceRect: _workspaceRect(sourceGlobal),
          direction: direction,
          fraction: _snapCenter(fraction),
        );
      });
      return;
    }

    final targetEntry = _areaKeys.entries
        .cast<MapEntry<String, GlobalKey>?>()
        .firstWhere((entry) {
          if (entry == null || entry.key == current.sourceAreaId) return false;
          return _globalAreaRect(entry.key)?.contains(globalPosition) ?? false;
        }, orElse: () => null);
    if (targetEntry == null) {
      setState(() => _preview = current.asPending(globalPosition));
      return;
    }
    final targetGlobal = _globalAreaRect(targetEntry.key)!;
    final local = Offset(
      (globalPosition.dx - targetGlobal.left) / targetGlobal.width,
      (globalPosition.dy - targetGlobal.top) / targetGlobal.height,
    );
    final target = _dockTarget(local, targetGlobal.size);
    final factor = _dockFactor(local, target, targetGlobal.size);
    final targetLocal = _workspaceRect(targetGlobal);
    setState(() {
      _preview = current.asDock(
        pointer: _workspaceLocal(globalPosition),
        sourceRect: _workspaceRect(sourceGlobal),
        targetAreaId: targetEntry.key,
        targetRect: targetLocal,
        destinationRect: _destinationRect(targetLocal, target, factor),
        target: target,
        factor: factor,
      );
    });
  }

  void _endDrag() {
    final preview = _preview;
    if (preview == null) return;
    setState(() => _preview = null);
    if (preview.mode == _DockPreviewMode.split &&
        preview.direction != null &&
        preview.fraction != null) {
      final source = _findArea(widget.controller.root, preview.sourceAreaId);
      if (source == null) return;
      final newFirst = preview.direction == BlenderSplitDirection.horizontal
          ? preview.corner == BlenderDockCorner.topLeft ||
                preview.corner == BlenderDockCorner.bottomLeft
          : preview.corner == BlenderDockCorner.topLeft ||
                preview.corner == BlenderDockCorner.topRight;
      widget.controller.splitArea(
        areaId: source.id,
        direction: preview.direction!,
        fraction: preview.fraction!,
        newValue: widget.cloneValue?.call(source.value) ?? source.value,
        newAreaFirst: newFirst,
      );
      return;
    }
    if (preview.mode == _DockPreviewMode.dock &&
        preview.targetAreaId != null &&
        preview.target != BlenderDockTarget.none) {
      widget.controller.dockArea(
        sourceAreaId: preview.sourceAreaId,
        targetAreaId: preview.targetAreaId!,
        target: preview.target,
        factor: preview.factor ?? .5,
      );
    }
  }

  void _cancelDrag() {
    if (_preview != null && mounted) setState(() => _preview = null);
  }

  BlenderDockAreaNode<T>? _findArea(BlenderDockNode<T> node, String id) {
    if (node is BlenderDockAreaNode<T>) return node.id == id ? node : null;
    final split = node as BlenderDockSplitNode<T>;
    return _findArea(split.first, id) ?? _findArea(split.second, id);
  }

  Rect? _globalAreaRect(String id) {
    final box = _areaKeys[id]?.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Offset _workspaceLocal(Offset global) {
    final box = _workspaceKey.currentContext!.findRenderObject()! as RenderBox;
    return box.globalToLocal(global);
  }

  Rect _workspaceRect(Rect global) =>
      _workspaceLocal(global.topLeft) & global.size;

  double _snapCenter(double fraction) {
    if (fraction >= .48 && fraction <= .52) return .5;
    return fraction;
  }

  BlenderDockTarget _dockTarget(Offset local, Size size) {
    if (local.dx > .4 && local.dx < .6 && local.dy > .4 && local.dy < .6) {
      return BlenderDockTarget.center;
    }
    if (size.width < widget.minimumAreaExtent * 6) {
      return local.dy < .5 ? BlenderDockTarget.top : BlenderDockTarget.bottom;
    }
    if (size.height < widget.minimumAreaExtent * 6) {
      return local.dx < .5 ? BlenderDockTarget.left : BlenderDockTarget.right;
    }
    final horizontalDistance = (local.dx - .5).abs();
    final verticalDistance = (local.dy - .5).abs();
    if (horizontalDistance > verticalDistance) {
      return local.dx < .5 ? BlenderDockTarget.left : BlenderDockTarget.right;
    }
    return local.dy < .5 ? BlenderDockTarget.top : BlenderDockTarget.bottom;
  }

  double _dockFactor(Offset local, BlenderDockTarget target, Size size) {
    final raw = switch (target) {
      BlenderDockTarget.left => local.dx,
      BlenderDockTarget.right => 1 - local.dx,
      BlenderDockTarget.top => local.dy,
      BlenderDockTarget.bottom => 1 - local.dy,
      BlenderDockTarget.center || BlenderDockTarget.none => .5,
    };
    final extent =
        target == BlenderDockTarget.left || target == BlenderDockTarget.right
        ? size.width
        : size.height;
    final minimum = math.min(.45, widget.minimumAreaExtent / extent);
    return raw.clamp(minimum, 1 - minimum).toDouble();
  }

  Rect _destinationRect(Rect rect, BlenderDockTarget target, double factor) {
    return switch (target) {
      BlenderDockTarget.left => Rect.fromLTWH(
        rect.left,
        rect.top,
        rect.width * factor,
        rect.height,
      ),
      BlenderDockTarget.right => Rect.fromLTWH(
        rect.right - rect.width * factor,
        rect.top,
        rect.width * factor,
        rect.height,
      ),
      BlenderDockTarget.top => Rect.fromLTWH(
        rect.left,
        rect.top,
        rect.width,
        rect.height * factor,
      ),
      BlenderDockTarget.bottom => Rect.fromLTWH(
        rect.left,
        rect.bottom - rect.height * factor,
        rect.width,
        rect.height * factor,
      ),
      BlenderDockTarget.center || BlenderDockTarget.none => rect,
    };
  }
}

class _DockCornerHandle extends StatefulWidget {
  const _DockCornerHandle({
    required this.corner,
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
    required this.onCancel,
  });

  final BlenderDockCorner corner;
  final ValueChanged<Offset> onStart;
  final ValueChanged<Offset> onUpdate;
  final VoidCallback onEnd;
  final VoidCallback onCancel;

  @override
  State<_DockCornerHandle> createState() => _DockCornerHandleState();
}

class _DockCornerHandleState extends State<_DockCornerHandle> {
  bool _hovered = false;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Split or dock area from ${widget.corner.name} corner',
      child: MouseRegion(
        cursor: _dragging
            ? SystemMouseCursors.grabbing
            : SystemMouseCursors.grab,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) {
          if (!_dragging) setState(() => _hovered = false);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            setState(() => _dragging = true);
            widget.onStart(details.globalPosition);
          },
          onPanUpdate: (details) => widget.onUpdate(details.globalPosition),
          onPanEnd: (_) {
            setState(() {
              _dragging = false;
              _hovered = false;
            });
            widget.onEnd();
          },
          onPanCancel: () {
            setState(() {
              _dragging = false;
              _hovered = false;
            });
            widget.onCancel();
          },
          child: CustomPaint(
            painter: _DockCornerPainter(
              corner: widget.corner,
              visible: _hovered || _dragging,
              color: BlenderTheme.of(context).colors.foregroundMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _DockCornerPainter extends CustomPainter {
  const _DockCornerPainter({
    required this.corner,
    required this.visible,
    required this.color,
  });

  final BlenderDockCorner corner;
  final bool visible;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) return;
    final paint = Paint()
      ..color = color.withAlpha(150)
      ..strokeWidth = 1;
    final fromLeft =
        corner == BlenderDockCorner.topLeft ||
        corner == BlenderDockCorner.bottomLeft;
    final fromTop =
        corner == BlenderDockCorner.topLeft ||
        corner == BlenderDockCorner.topRight;
    for (var inset = 3.0; inset <= 9; inset += 3) {
      final x1 = fromLeft ? 0.0 : size.width;
      final y1 = fromTop ? inset : size.height - inset;
      final x2 = fromLeft ? inset : size.width - inset;
      final y2 = fromTop ? 0.0 : size.height;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(_DockCornerPainter oldDelegate) =>
      oldDelegate.corner != corner ||
      oldDelegate.visible != visible ||
      oldDelegate.color != color;
}

enum _DockPreviewMode { pending, split, dock }

class _DockDragPreview {
  const _DockDragPreview({
    required this.mode,
    required this.sourceAreaId,
    required this.corner,
    required this.startGlobal,
    required this.pointer,
    required this.target,
    this.sourceRect,
    this.targetAreaId,
    this.targetRect,
    this.destinationRect,
    this.direction,
    this.fraction,
    this.factor,
  });

  factory _DockDragPreview.pending({
    required String sourceAreaId,
    required BlenderDockCorner corner,
    required Offset startGlobal,
  }) => _DockDragPreview(
    mode: _DockPreviewMode.pending,
    sourceAreaId: sourceAreaId,
    corner: corner,
    startGlobal: startGlobal,
    pointer: Offset.zero,
    target: BlenderDockTarget.none,
  );

  final _DockPreviewMode mode;
  final String sourceAreaId;
  final BlenderDockCorner corner;
  final Offset startGlobal;
  final Offset pointer;
  final BlenderDockTarget target;
  final Rect? sourceRect;
  final String? targetAreaId;
  final Rect? targetRect;
  final Rect? destinationRect;
  final BlenderSplitDirection? direction;
  final double? fraction;
  final double? factor;

  _DockDragPreview asPending(Offset globalPointer) => _DockDragPreview(
    mode: _DockPreviewMode.pending,
    sourceAreaId: sourceAreaId,
    corner: corner,
    startGlobal: startGlobal,
    pointer: globalPointer,
    target: BlenderDockTarget.none,
  );

  _DockDragPreview asSplit({
    required Offset pointer,
    required Rect sourceRect,
    required BlenderSplitDirection direction,
    required double fraction,
  }) => _DockDragPreview(
    mode: _DockPreviewMode.split,
    sourceAreaId: sourceAreaId,
    corner: corner,
    startGlobal: startGlobal,
    pointer: pointer,
    target: BlenderDockTarget.none,
    sourceRect: sourceRect,
    direction: direction,
    fraction: fraction,
  );

  _DockDragPreview asDock({
    required Offset pointer,
    required Rect sourceRect,
    required String targetAreaId,
    required Rect targetRect,
    required Rect destinationRect,
    required BlenderDockTarget target,
    required double factor,
  }) => _DockDragPreview(
    mode: _DockPreviewMode.dock,
    sourceAreaId: sourceAreaId,
    corner: corner,
    startGlobal: startGlobal,
    pointer: pointer,
    target: target,
    sourceRect: sourceRect,
    targetAreaId: targetAreaId,
    targetRect: targetRect,
    destinationRect: destinationRect,
    factor: factor,
  );
}

class _DockPreviewOverlay extends StatelessWidget {
  const _DockPreviewOverlay({required this.preview});

  final _DockDragPreview preview;

  @override
  Widget build(BuildContext context) {
    if (preview.mode == _DockPreviewMode.pending) {
      return const SizedBox.expand();
    }
    final theme = BlenderTheme.of(context);
    return Stack(
      children: <Widget>[
        if (preview.mode == _DockPreviewMode.dock && preview.sourceRect != null)
          Positioned.fromRect(
            rect: preview.sourceRect!,
            child: const ColoredBox(color: Color(0x8F000000)),
          ),
        if (preview.mode == _DockPreviewMode.split &&
            preview.sourceRect != null)
          Positioned.fromRect(
            rect: preview.sourceRect!,
            child: CustomPaint(
              painter: _SplitPreviewPainter(
                direction: preview.direction!,
                fraction: preview.fraction!,
                border: theme.colors.editorBorder,
              ),
            ),
          ),
        if (preview.mode == _DockPreviewMode.dock &&
            preview.destinationRect != null)
          Positioned.fromRect(
            rect: preview.destinationRect!,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),
                border: Border.all(color: const Color(0x66FFFFFF)),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        Positioned(
          left: preview.pointer.dx + 12,
          top: preview.pointer.dy + 12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.menuBackground,
              border: Border.all(color: theme.colors.editorOutlineActive),
              borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                preview.mode == _DockPreviewMode.split
                    ? 'Split Area'
                    : preview.target == BlenderDockTarget.center
                    ? 'Replace this area'
                    : 'Move area here',
                style: theme.textTheme.caption,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SplitPreviewPainter extends CustomPainter {
  const _SplitPreviewPainter({
    required this.direction,
    required this.fraction,
    required this.border,
  });

  final BlenderSplitDirection direction;
  final double fraction;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = const Color(0x1AFFFFFF);
    final outline = Paint()
      ..color = const Color(0x66FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final separator = Paint()
      ..color = border
      ..strokeWidth = 2;
    canvas.drawRect(Offset.zero & size, fill);
    canvas.drawRect(Offset.zero & size, outline);
    if (direction == BlenderSplitDirection.horizontal) {
      final x = size.width * fraction;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), separator);
    } else {
      final y = size.height * fraction;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), separator);
    }
  }

  @override
  bool shouldRepaint(_SplitPreviewPainter oldDelegate) =>
      oldDelegate.direction != direction ||
      oldDelegate.fraction != fraction ||
      oldDelegate.border != border;
}
