part of '../docking.dart';

extension _DockAreaEdgeOptions<T> on _BlenderDockingWorkspaceState<T> {
  Future<void> _showAreaOptions(
    BuildContext context,
    BlenderDockSplitNode<T> split,
    Offset globalPosition,
  ) async {
    final edge = _resolveEdgeSelection(split, globalPosition);
    if (edge == null) return;
    _activeEdge = edge;
    try {
      await showBlenderContextMenu<String>(
        context: context,
        globalPosition: globalPosition,
        title: 'Area Options',
        items: BlenderContextMenuCatalog.areaEdge(
          dividerAxis: split.direction == BlenderSplitDirection.horizontal
              ? Axis.vertical
              : Axis.horizontal,
        ),
        onSelected: _executeAreaOption,
      );
    } finally {
      _activeEdge = null;
    }
  }

  _DockEdgeSelection<T>? _resolveEdgeSelection(
    BlenderDockSplitNode<T> split,
    Offset globalPosition,
  ) {
    final first = _areaAlongEdge(
      split.first,
      globalPosition,
      split.direction,
      firstSide: true,
    );
    final second = _areaAlongEdge(
      split.second,
      globalPosition,
      split.direction,
      firstSide: false,
    );
    if (first == null || second == null) return null;
    return _DockEdgeSelection<T>(
      direction: split.direction,
      first: first,
      second: second,
    );
  }

  BlenderDockAreaNode<T>? _areaAlongEdge(
    BlenderDockNode<T> node,
    Offset globalPosition,
    BlenderSplitDirection direction, {
    required bool firstSide,
  }) {
    final candidates = <BlenderDockAreaNode<T>>[];
    void collect(BlenderDockNode<T> current) {
      if (current is BlenderDockAreaNode<T>) {
        candidates.add(current);
        return;
      }
      final split = current as BlenderDockSplitNode<T>;
      collect(split.first);
      collect(split.second);
    }

    collect(node);
    BlenderDockAreaNode<T>? best;
    var bestDistance = double.infinity;
    for (final area in candidates) {
      final rect = _globalAreaRect(area.id);
      if (rect == null) continue;
      final crossesPointer = direction == BlenderSplitDirection.horizontal
          ? globalPosition.dy >= rect.top && globalPosition.dy <= rect.bottom
          : globalPosition.dx >= rect.left && globalPosition.dx <= rect.right;
      if (!crossesPointer) continue;
      final edge = direction == BlenderSplitDirection.horizontal
          ? (firstSide ? rect.right : rect.left)
          : (firstSide ? rect.bottom : rect.top);
      final pointer = direction == BlenderSplitDirection.horizontal
          ? globalPosition.dx
          : globalPosition.dy;
      final distance = (pointer - edge).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        best = area;
      }
    }
    return best;
  }

  void _executeAreaOption(String action) {
    final edge = _activeEdge;
    if (edge == null) return;
    switch (action) {
      case BlenderContextActionIds.splitVertical:
        _splitFromEdge(edge, BlenderSplitDirection.horizontal);
        return;
      case BlenderContextActionIds.splitHorizontal:
        _splitFromEdge(edge, BlenderSplitDirection.vertical);
        return;
      case BlenderContextActionIds.joinRight:
        widget.controller.joinAreas(
          retainedAreaId: edge.first.id,
          removedAreaId: edge.second.id,
        );
        return;
      case BlenderContextActionIds.joinLeft:
        widget.controller.joinAreas(
          retainedAreaId: edge.second.id,
          removedAreaId: edge.first.id,
        );
        return;
      case BlenderContextActionIds.joinUp:
        widget.controller.joinAreas(
          retainedAreaId: edge.second.id,
          removedAreaId: edge.first.id,
        );
        return;
      case BlenderContextActionIds.joinDown:
        widget.controller.joinAreas(
          retainedAreaId: edge.first.id,
          removedAreaId: edge.second.id,
        );
        return;
      case BlenderContextActionIds.swapAreas:
        widget.controller.swapAreaValues(
          firstAreaId: edge.first.id,
          secondAreaId: edge.second.id,
        );
        return;
    }
  }

  void _splitFromEdge(
    _DockEdgeSelection<T> edge,
    BlenderSplitDirection direction,
  ) {
    // screen_area_edge_from_cursor() selects the area on the right of a
    // vertical edge and the area above a horizontal edge.
    final source = edge.direction == BlenderSplitDirection.horizontal
        ? edge.second
        : edge.first;
    final rect = _globalAreaRect(source.id);
    final extent = direction == BlenderSplitDirection.horizontal
        ? rect?.width
        : rect?.height;
    if (extent == null || extent < widget.minimumAreaExtent * 2) return;
    widget.controller.splitArea(
      areaId: source.id,
      direction: direction,
      fraction: .5,
      newValue: widget.cloneValue?.call(source.value) ?? source.value,
      newAreaFirst: false,
    );
  }
}

class _DockEdgeSelection<T> {
  const _DockEdgeSelection({
    required this.direction,
    required this.first,
    required this.second,
  });

  final BlenderSplitDirection direction;
  final BlenderDockAreaNode<T> first;
  final BlenderDockAreaNode<T> second;
}
