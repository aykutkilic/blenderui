part of '../showcase_app.dart';

extension _ShowcaseNodeDocumentInteractions on _ShowcaseAppState {
  List<BlenderGraphNode> get _activeNodeDocument =>
      _mainEditorType == BlenderEditorType.geometryNodeEditor
      ? _geometryNodes
      : _nodes;

  List<BlenderGraphLink> get _activeNodeLinks =>
      _mainEditorType == BlenderEditorType.geometryNodeEditor
      ? _geometryLinks
      : _nodeLinks;

  void _replaceActiveNodeDocument(BlenderNodeGraphModel model) {
    _activeNodeDocument
      ..clear()
      ..addAll(model.nodes);
    _activeNodeLinks
      ..clear()
      ..addAll(model.links);
  }

  void _connectNodeSockets(BlenderGraphLink link) {
    final current = _nodeGraph;
    final output = BlenderNodeSocketReference(
      nodeId: link.from,
      socketId: link.fromSocket!,
      output: true,
    );
    final input = BlenderNodeSocketReference(
      nodeId: link.to,
      socketId: link.toSocket!,
      output: false,
    );
    final updated = current.connectSockets(output, input);
    if (identical(updated, current)) return;
    _update(() => _replaceActiveNodeDocument(updated));
    final source = updated.nodeById(link.from)?.title ?? link.from;
    final target = updated.nodeById(link.to)?.title ?? link.to;
    _setStatus('Connected $source to $target');
  }

  void _moveNodes(Map<BlenderGraphNode, Offset> positions) {
    _update(() {
      _replaceActiveNodeDocument(
        _nodeGraph.moveNodes(<String, Offset>{
          for (final entry in positions.entries) entry.key.id: entry.value,
        }),
      );
    });
  }

  void _selectNodes(Set<String> ids) {
    final activeId = ids.contains(_selectedNodeId)
        ? _selectedNodeId
        : ids.lastOrNull;
    _update(() {
      _selectedNodeId = activeId;
      _replaceActiveNodeDocument(
        _nodeGraph.selectNodes(ids, activeId: activeId),
      );
    });
  }

  void _cutNodeLinks(Offset start, Offset end) {
    final updated = _nodeGraph.cutLinks(start, end);
    if (identical(updated, _nodeGraph)) return;
    _update(() => _replaceActiveNodeDocument(updated));
    _setStatus('Cut node links');
  }

  String _duplicateNodeId(BlenderGraphNode node) {
    var index = 1;
    var candidate = '${node.id}_copy';
    while (_nodeGraph.nodeById(candidate) != null) {
      index++;
      candidate = '${node.id}_copy_$index';
    }
    return candidate;
  }

  void _selectNode(BlenderGraphNode node) {
    _update(() {
      _selectedNodeId = node.id;
      _replaceActiveNodeDocument(_nodeGraph.selectNode(node.id));
    });
    _setStatus('Selected node ${node.title}');
  }

  void _handleNodeEditorCommand(String command) {
    final current = _nodeGraph;
    final updated = switch (command) {
      'select.all' => current.selectAll(),
      'select.none' => current.clearSelection(),
      'select.invert' => current.invertSelection(),
      'node.duplicate' => current.duplicateSelectedNodes(
        idBuilder: _duplicateNodeId,
      ),
      'node.delete' || 'node.delete-reconnect' => current.removeSelectedNodes(),
      _ => current,
    };
    if (!identical(updated, current)) {
      _update(() {
        _replaceActiveNodeDocument(updated);
        if (command.startsWith('node.delete')) _selectedNodeId = null;
      });
    }
    _setStatus('Node command: $command');
  }

  void _handleNodeContextCommand(BlenderGraphNode node, String command) {
    if (command == BlenderContextActionIds.delete) {
      _update(() {
        _replaceActiveNodeDocument(_nodeGraph.removeNode(node.id));
        if (_selectedNodeId == node.id) _selectedNodeId = null;
      });
    }
    _setStatus('$command: ${node.title}');
  }
}
