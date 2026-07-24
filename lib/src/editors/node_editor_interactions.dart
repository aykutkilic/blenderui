part of '../editors.dart';

/// Pointer and gesture policy for [_BlenderNodeEditorState].
///
/// Rendering and document composition stay in `node_editor_host.dart`; this
/// extension owns transient node, socket, canvas, and box-selection gestures.
extension _BlenderNodeEditorInteractions on _BlenderNodeEditorState {
  void _startNodeDrag(BlenderGraphNode node) {
    _updateInteractionState(() {
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
    _updateInteractionState(() => _draggedNodePosition = position);
  }

  void _finishNodeDrag() {
    final id = _draggedNodeId;
    final position = _draggedNodePosition;
    final node = id == null ? null : widget.model.nodeById(id);
    _updateInteractionState(_clearNodeDrag);
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

  void _cancelNodeDrag() => _updateInteractionState(_clearNodeDrag);

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
    _updateInteractionState(() {
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
    _updateInteractionState(() {
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
    _updateInteractionState(() => _socketDrag = null);
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
      _updateInteractionState(() => _boxSelectionCurrent = event.localPosition);
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
    if (_boxSelectionPointer == event.pointer) {
      _updateInteractionState(_clearBoxSelection);
    }
  }

  void _finishBoxSelection() {
    final start = _boxSelectionStart;
    final current = _boxSelectionCurrent;
    _updateInteractionState(_clearBoxSelection);
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
