part of '../editors.dart';

typedef BlenderNodeSocketCallback =
    void Function(
      BlenderGraphNode node,
      BlenderNodeSocketDefinition socket,
      bool output,
    );

typedef BlenderNodeConnectionValidator =
    bool Function(
      BlenderNodeGraphModel model,
      BlenderNodeSocketReference first,
      BlenderNodeSocketReference second,
    );

typedef BlenderNodeBodyBuilder =
    Widget Function(BuildContext context, BlenderGraphNode node);

/// Renderer-independent, host-controlled node graph editor.
///
/// The editor owns canvas mechanics and node presentation. The application
/// owns the graph document, operator execution, selection policy, undo, and
/// evaluation, matching Blender's separation between `SpaceNode` and a node
/// tree data-block.
class BlenderNodeEditor extends StatefulWidget {
  const BlenderNodeEditor({
    super.key,
    required this.model,
    this.onNodeSelected,
    this.selectedNodeIds,
    this.onNodeSelectionChanged,
    this.onNodeMoved,
    this.onNodesMoved,
    this.onNodeCollapseChanged,
    this.onSocketPressed,
    this.onLinkCreated,
    this.canConnectSockets,
    this.onCanvasPressed,
    this.contextMenuItemsBuilder,
    this.onContextMenuSelected,
    this.nodeBodyBuilder,
    this.sidebar,
    this.sidebarWidth = 230,
    this.toolbar,
    this.title = 'Node Editor',
    this.canvasSize = const Size(2400, 1400),
    this.showGrid = true,
    this.showLinks = true,
    this.wireColors = true,
    this.minScale = .25,
    this.maxScale = 3,
    this.viewportOverscan = 180,
    this.boxSelection = true,
    this.linkCutting = false,
    this.onLinksCut,
    this.snapIncrement,
    this.transformationController,
  });

  final BlenderNodeGraphModel model;
  final ValueChanged<BlenderGraphNode>? onNodeSelected;
  final Set<String>? selectedNodeIds;
  final ValueChanged<Set<String>>? onNodeSelectionChanged;
  final void Function(BlenderGraphNode node, Offset position)? onNodeMoved;
  final ValueChanged<Map<BlenderGraphNode, Offset>>? onNodesMoved;
  final void Function(BlenderGraphNode node, bool collapsed)?
  onNodeCollapseChanged;
  final BlenderNodeSocketCallback? onSocketPressed;
  final ValueChanged<BlenderGraphLink>? onLinkCreated;
  final BlenderNodeConnectionValidator? canConnectSockets;
  final ValueChanged<Offset>? onCanvasPressed;
  final List<BlenderMenuItem<String>> Function(BlenderGraphNode)?
  contextMenuItemsBuilder;
  final void Function(BlenderGraphNode, String)? onContextMenuSelected;
  final BlenderNodeBodyBuilder? nodeBodyBuilder;
  final Widget? sidebar;
  final double sidebarWidth;
  final Widget? toolbar;
  final String? title;
  final Size canvasSize;
  final bool showGrid;
  final bool showLinks;
  final bool wireColors;
  final double minScale;
  final double maxScale;
  final double viewportOverscan;
  final bool boxSelection;
  final bool linkCutting;
  final void Function(Offset start, Offset end)? onLinksCut;
  final double? snapIncrement;
  final TransformationController? transformationController;

  @override
  State<BlenderNodeEditor> createState() => _BlenderNodeEditorState();
}

class _BlenderNodeEditorState extends State<BlenderNodeEditor> {
  final GlobalKey _viewportKey = GlobalKey();
  late final FocusNode _focusNode;
  late final TransformationController _internalTransformationController;
  String? _draggedNodeId;
  Offset? _draggedNodeOrigin;
  Offset? _draggedNodePosition;
  _BlenderSocketDrag? _socketDrag;
  int? _canvasPanPointer;
  Offset? _lastCanvasPanPosition;
  int? _boxSelectionPointer;
  Offset? _boxSelectionStart;
  Offset? _boxSelectionCurrent;
  final Set<int> _nodePointers = <int>{};
  bool _extendSelectionModifier = false;
  bool _toggleSelectionModifier = false;

  TransformationController get _transformationController =>
      widget.transformationController ?? _internalTransformationController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'BlenderNodeEditor');
    _internalTransformationController = TransformationController();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _internalTransformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final editor = widget.sidebar == null
        ? _buildCanvas(context, theme)
        : Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(child: _buildCanvas(context, theme)),
              SizedBox(
                width: widget.sidebarWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colors.surface,
                    border: Border(
                      left: BorderSide(color: theme.colors.editorBorder),
                    ),
                  ),
                  child: widget.sidebar,
                ),
              ),
            ],
          );
    return BlenderPanel(
      title: widget.title,
      padding: EdgeInsets.zero,
      child: editor,
    );
  }

  Widget _buildCanvas(BuildContext context, BlenderThemeData theme) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleSelectionKeyEvent,
      child: ClipRect(
        key: _viewportKey,
        child: ColoredBox(
          color: theme.colors.canvas,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewportSize = constraints.biggest;
              return Stack(
                children: <Widget>[
                  if (widget.showGrid)
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: _transformationController,
                          builder: (context, _) => CustomPaint(
                            key: const ValueKey<String>('node-editor-grid'),
                            painter: _BlenderNodeGridPainter(
                              minorColor: theme.colors.borderSubtle.withAlpha(
                                70,
                              ),
                              majorColor: theme.colors.borderSubtle.withAlpha(
                                150,
                              ),
                              scale: _transformationController.value
                                  .getMaxScaleOnAxis(),
                              translation: Offset(
                                _transformationController.value.storage[12],
                                _transformationController.value.storage[13],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: Listener(
                      onPointerDown: _handleCanvasPointerDown,
                      onPointerMove: _handleCanvasPointerMove,
                      onPointerUp: _handleCanvasPointerUp,
                      onPointerCancel: _handleCanvasPointerCancel,
                      onPointerSignal: _handleCanvasPointerSignal,
                      child: AnimatedBuilder(
                        animation: _transformationController,
                        builder: (context, _) => OverflowBox(
                          alignment: Alignment.topLeft,
                          minWidth: 0,
                          minHeight: 0,
                          maxWidth: double.infinity,
                          maxHeight: double.infinity,
                          child: Transform(
                            alignment: Alignment.topLeft,
                            transform: _transformationController.value,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapUp: widget.onCanvasPressed == null
                                  ? null
                                  : (details) => widget.onCanvasPressed!(
                                      details.localPosition,
                                    ),
                              child: SizedBox(
                                width: widget.canvasSize.width,
                                height: widget.canvasSize.height,
                                child: _buildDocument(
                                  context,
                                  theme,
                                  viewportSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.toolbar != null)
                    Positioned(left: 8, top: 8, child: widget.toolbar!),
                  if (_boxSelectionStart case final start?)
                    if (_boxSelectionCurrent case final current?)
                      Positioned.fromRect(
                        rect: Rect.fromPoints(start, current),
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colors.selection.withAlpha(38),
                              border: Border.all(color: theme.colors.accent),
                            ),
                          ),
                        ),
                      ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDocument(
    BuildContext context,
    BlenderThemeData theme,
    Size viewportSize,
  ) {
    final visibleRect = _visibleGraphRect(
      viewportSize,
    ).inflate(widget.viewportOverscan);
    final positions = _transientNodePositions();
    final visibleNodes = widget.model.nodes
        .where((node) {
          final position = positions[node.id] ?? node.position;
          return visibleRect.overlaps(position & node.visibleSize);
        })
        .toList(growable: false);
    final socketDrag = _socketDrag;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        for (final node in visibleNodes)
          if (node.kind == BlenderGraphNodeKind.frame)
            _positionedNode(context, node, positions[node.id] ?? node.position),
        if (widget.showLinks)
          Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: CustomPaint(
                  key: const ValueKey<String>('node-editor-links'),
                  painter: _BlenderGraphPainter(
                    model: widget.model,
                    theme: theme,
                    wireColors: widget.wireColors,
                    visibleRect: visibleRect,
                    nodePositions: positions,
                  ),
                ),
              ),
            ),
          ),
        if (socketDrag != null)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                key: const ValueKey<String>('node-editor-link-preview'),
                painter: _BlenderConnectionPreviewPainter(
                  start: _socketPosition(socketDrag.source, positions),
                  end: socketDrag.candidate == null
                      ? socketDrag.pointer
                      : _socketPosition(socketDrag.candidate!, positions),
                  color: _socketColor(socketDrag.source, theme),
                  snapped: socketDrag.candidate != null,
                ),
              ),
            ),
          ),
        for (final node in visibleNodes)
          if (node.kind != BlenderGraphNodeKind.frame)
            _positionedNode(context, node, positions[node.id] ?? node.position),
      ],
    );
  }

  Rect _visibleGraphRect(Size viewportSize) {
    if (viewportSize.isEmpty) return Offset.zero & widget.canvasSize;
    final inverse = Matrix4.inverted(_transformationController.value);
    return MatrixUtils.transformRect(inverse, Offset.zero & viewportSize);
  }

  Map<String, Offset> _transientNodePositions() {
    final id = _draggedNodeId;
    final origin = _draggedNodeOrigin;
    final position = _draggedNodePosition;
    if (id == null || origin == null || position == null) {
      return const <String, Offset>{};
    }
    final delta = position - origin;
    final dragged = widget.model.nodeById(id);
    final selected = _selectedNodeIds;
    return <String, Offset>{
      id: position,
      for (final node in widget.model.nodes)
        if ((dragged?.kind == BlenderGraphNodeKind.frame &&
                node.parentId == id) ||
            (selected.contains(id) && selected.contains(node.id)))
          node.id: node.position + delta,
    };
  }

  Widget _positionedNode(
    BuildContext context,
    BlenderGraphNode node,
    Offset position,
  ) {
    return Positioned(
      key: ValueKey<String>('node-editor-node-${node.id}'),
      left: position.dx,
      top: position.dy,
      width: node.visibleSize.width,
      height: node.visibleSize.height,
      child: RepaintBoundary(child: _buildNode(context, node, position)),
    );
  }

  Widget _buildNode(
    BuildContext context,
    BlenderGraphNode node,
    Offset position,
  ) {
    final displayedNode = node.copyWith(
      position: position,
      selected: widget.selectedNodeIds?.contains(node.id) ?? node.selected,
    );
    final movementEnabled =
        widget.onNodeMoved != null || widget.onNodesMoved != null;
    Widget child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      dragStartBehavior: DragStartBehavior.down,
      onPanStart: !movementEnabled ? null : (_) => _startNodeDrag(node),
      onPanUpdate: !movementEnabled ? null : _updateNodeDrag,
      onPanEnd: !movementEnabled ? null : (_) => _finishNodeDrag(),
      onPanCancel: !movementEnabled ? null : _cancelNodeDrag,
      child: switch (node.kind) {
        BlenderGraphNodeKind.frame => _BlenderFrameNode(node: displayedNode),
        BlenderGraphNodeKind.reroute => _BlenderRerouteNode(
          node: displayedNode,
          onSocketPressed: widget.onSocketPressed,
          onSocketDragStart: widget.onLinkCreated == null
              ? null
              : _startSocketDrag,
          onSocketDragUpdate: _updateSocketDrag,
          onSocketDragEnd: _finishSocketDrag,
          highlightedSocket: _socketDrag?.candidate,
        ),
        BlenderGraphNodeKind.standard => _BlenderStandardNode(
          node: displayedNode,
          body: widget.nodeBodyBuilder?.call(context, node),
          onSocketPressed: widget.onSocketPressed,
          model: widget.model,
          onSocketDragStart: widget.onLinkCreated == null
              ? null
              : _startSocketDrag,
          onSocketDragUpdate: _updateSocketDrag,
          onSocketDragEnd: _finishSocketDrag,
          highlightedSocket: _socketDrag?.candidate,
          onCollapseChanged: widget.onNodeCollapseChanged,
        ),
      },
    );
    child = Listener(
      onPointerDown: (event) {
        _nodePointers.add(event.pointer);
        if (event.buttons == kPrimaryMouseButton) _selectNode(node);
      },
      onPointerUp: (event) => _nodePointers.remove(event.pointer),
      onPointerCancel: (event) => _nodePointers.remove(event.pointer),
      child: child,
    );
    final contextItems = widget.contextMenuItemsBuilder?.call(node);
    if (contextItems != null && contextItems.isNotEmpty) {
      child = BlenderContextMenu<String>(
        title: node.title,
        items: contextItems,
        onContextRequested: (_) => _selectNode(node),
        onSelected: (action) =>
            widget.onContextMenuSelected?.call(node, action),
        child: child,
      );
    }
    return child;
  }

  void _startNodeDrag(BlenderGraphNode node) {
    setState(() {
      _draggedNodeId = node.id;
      _draggedNodeOrigin = node.position;
      _draggedNodePosition = node.position;
    });
  }

  void _updateNodeDrag(DragUpdateDetails details) {
    final current = _draggedNodePosition;
    if (current == null) return;
    final scale = _transformationController.value.getMaxScaleOnAxis();
    var position = current + details.delta / scale;
    final snap = widget.snapIncrement;
    if (snap != null && snap > 0) {
      position = Offset(
        (position.dx / snap).round() * snap,
        (position.dy / snap).round() * snap,
      );
    }
    setState(() => _draggedNodePosition = position);
  }

  void _finishNodeDrag() {
    final id = _draggedNodeId;
    final position = _draggedNodePosition;
    final node = id == null ? null : widget.model.nodeById(id);
    setState(_clearNodeDrag);
    if (node != null && position != null && position != node.position) {
      final delta = position - node.position;
      final moved = <BlenderGraphNode, Offset>{
        node: position,
        for (final candidate in widget.model.nodes)
          if (candidate.id != node.id &&
              (candidate.parentId == node.id ||
                  (_selectedNodeIds.contains(node.id) &&
                      _selectedNodeIds.contains(candidate.id))))
            candidate: candidate.position + delta,
      };
      if (widget.onNodesMoved case final callback?) {
        callback(Map<BlenderGraphNode, Offset>.unmodifiable(moved));
      } else {
        for (final entry in moved.entries) {
          widget.onNodeMoved?.call(entry.key, entry.value);
        }
      }
    }
  }

  void _cancelNodeDrag() => setState(_clearNodeDrag);

  void _clearNodeDrag() {
    _draggedNodeId = null;
    _draggedNodeOrigin = null;
    _draggedNodePosition = null;
  }

  void _startSocketDrag(
    BlenderGraphNode node,
    BlenderNodeSocketDefinition socket,
    bool output,
    DragStartDetails details,
  ) {
    final reference = BlenderNodeSocketReference(
      nodeId: node.id,
      socketId: socket.id,
      output: output,
    );
    setState(() {
      _socketDrag = _BlenderSocketDrag(
        source: reference,
        pointer: _scenePosition(details.globalPosition),
      );
    });
  }

  void _updateSocketDrag(DragUpdateDetails details) {
    final drag = _socketDrag;
    if (drag == null) return;
    final pointer = _scenePosition(details.globalPosition);
    final candidate = _nearestCompatibleSocket(drag.source, pointer);
    setState(() {
      _socketDrag = drag.copyWith(
        pointer: pointer,
        candidate: candidate,
        clearCandidate: candidate == null,
      );
    });
  }

  void _finishSocketDrag(DragEndDetails details) {
    final drag = _socketDrag;
    final candidate = drag == null
        ? null
        : _nearestCompatibleSocket(
            drag.source,
            _scenePosition(details.globalPosition),
          );
    setState(() => _socketDrag = null);
    if (drag == null || candidate == null) return;
    final link = widget.model.linkForSockets(drag.source, candidate);
    if (link != null) widget.onLinkCreated?.call(link);
  }

  Offset _scenePosition(Offset globalPosition) {
    final box = _viewportKey.currentContext?.findRenderObject();
    if (box is! RenderBox) return globalPosition;
    return _transformationController.toScene(box.globalToLocal(globalPosition));
  }

  BlenderNodeSocketReference? _nearestCompatibleSocket(
    BlenderNodeSocketReference source,
    Offset pointer,
  ) {
    BlenderNodeSocketReference? nearest;
    var nearestDistance =
        20 / _transformationController.value.getMaxScaleOnAxis();
    final positions = _transientNodePositions();
    for (final node in widget.model.nodes) {
      final sockets = source.output ? node.inputs : node.outputs;
      for (final socket in sockets) {
        final candidate = BlenderNodeSocketReference(
          nodeId: node.id,
          socketId: socket.id,
          output: !source.output,
        );
        if (!widget.model.canConnectSockets(source, candidate)) continue;
        if (widget.canConnectSockets?.call(widget.model, source, candidate) ==
            false) {
          continue;
        }
        final distance =
            (_socketPosition(candidate, positions) - pointer).distance;
        if (distance <= nearestDistance) {
          nearest = candidate;
          nearestDistance = distance;
        }
      }
    }
    return nearest;
  }

  Offset _socketPosition(
    BlenderNodeSocketReference reference,
    Map<String, Offset> positions,
  ) {
    final node = widget.model.nodeById(reference.nodeId)!;
    return _BlenderNodeGeometry.socketPosition(
      node,
      reference.socketId,
      output: reference.output,
      position: positions[node.id],
    );
  }

  Color _socketColor(
    BlenderNodeSocketReference reference,
    BlenderThemeData theme,
  ) => _nodeSocketColor(widget.model.socketByReference(reference)!, theme);

  void _handleCanvasPointerDown(PointerDownEvent event) {
    if ((event.buttons & kMiddleMouseButton) != 0) {
      _canvasPanPointer = event.pointer;
      _lastCanvasPanPosition = event.localPosition;
      return;
    }
    if (((widget.linkCutting && widget.onLinksCut != null) ||
            (widget.boxSelection && widget.onNodeSelectionChanged != null)) &&
        event.buttons == kPrimaryMouseButton &&
        !_nodePointers.contains(event.pointer)) {
      _boxSelectionPointer = event.pointer;
      _boxSelectionStart = event.localPosition;
      _boxSelectionCurrent = event.localPosition;
    }
  }

  void _handleCanvasPointerMove(PointerMoveEvent event) {
    if (_boxSelectionPointer == event.pointer) {
      setState(() => _boxSelectionCurrent = event.localPosition);
      return;
    }
    if (_canvasPanPointer != event.pointer ||
        (event.buttons & kMiddleMouseButton) == 0) {
      return;
    }
    final previous = _lastCanvasPanPosition;
    _lastCanvasPanPosition = event.localPosition;
    if (previous == null) return;
    final delta = event.localPosition - previous;
    _transformationController.value = Matrix4.translationValues(
      delta.dx,
      delta.dy,
      0,
    )..multiply(_transformationController.value);
  }

  void _handleCanvasPointerUp(PointerUpEvent event) {
    if (_canvasPanPointer == event.pointer) {
      _canvasPanPointer = null;
      _lastCanvasPanPosition = null;
    }
    if (_boxSelectionPointer == event.pointer) _finishBoxSelection();
  }

  void _handleCanvasPointerCancel(PointerCancelEvent event) {
    if (_canvasPanPointer == event.pointer) {
      _canvasPanPointer = null;
      _lastCanvasPanPosition = null;
    }
    if (_boxSelectionPointer == event.pointer) setState(_clearBoxSelection);
  }

  void _finishBoxSelection() {
    final start = _boxSelectionStart;
    final current = _boxSelectionCurrent;
    setState(_clearBoxSelection);
    if (start == null || current == null || (current - start).distance < 3) {
      if (!widget.linkCutting) {
        widget.onNodeSelectionChanged?.call(const <String>{});
      }
      return;
    }
    final sceneStart = _transformationController.toScene(start);
    final sceneEnd = _transformationController.toScene(current);
    if (widget.linkCutting) {
      widget.onLinksCut?.call(sceneStart, sceneEnd);
      return;
    }
    final sceneRect = Rect.fromPoints(sceneStart, sceneEnd);
    final pressed = HardwareKeyboard.instance.logicalKeysPressed;
    final extend =
        _extendSelectionModifier ||
        pressed.contains(LogicalKeyboardKey.shiftLeft) ||
        pressed.contains(LogicalKeyboardKey.shiftRight);
    final next = extend ? <String>{..._selectedNodeIds} : <String>{};
    for (final node in widget.model.nodes) {
      if (sceneRect.overlaps(node.position & node.visibleSize)) {
        next.add(node.id);
      }
    }
    widget.onNodeSelectionChanged?.call(Set<String>.unmodifiable(next));
  }

  void _clearBoxSelection() {
    _boxSelectionPointer = null;
    _boxSelectionStart = null;
    _boxSelectionCurrent = null;
  }

  void _handleCanvasPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final current = _transformationController.value;
    final currentScale = current.getMaxScaleOnAxis();
    final requestedScale = currentScale * math.exp(-event.scrollDelta.dy / 500);
    final targetScale = requestedScale
        .clamp(widget.minScale, widget.maxScale)
        .toDouble();
    final factor = targetScale / currentScale;
    if (factor == 1) return;
    final focalPoint = event.localPosition;
    _transformationController.value = Matrix4.identity()
      ..translateByDouble(focalPoint.dx, focalPoint.dy, 0, 1)
      ..scaleByDouble(factor, factor, 1, 1)
      ..translateByDouble(-focalPoint.dx, -focalPoint.dy, 0, 1)
      ..multiply(current);
  }
}

class _BlenderSocketDrag {
  const _BlenderSocketDrag({
    required this.source,
    required this.pointer,
    this.candidate,
  });

  final BlenderNodeSocketReference source;
  final Offset pointer;
  final BlenderNodeSocketReference? candidate;

  _BlenderSocketDrag copyWith({
    Offset? pointer,
    BlenderNodeSocketReference? candidate,
    bool clearCandidate = false,
  }) => _BlenderSocketDrag(
    source: source,
    pointer: pointer ?? this.pointer,
    candidate: clearCandidate ? null : candidate ?? this.candidate,
  );
}
