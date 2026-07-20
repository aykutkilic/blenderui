part of '../editors.dart';

extension _BlenderNodeEditorSelection on _BlenderNodeEditorState {
  Set<String> get _selectedNodeIds =>
      widget.selectedNodeIds ??
      {
        for (final node in widget.model.nodes)
          if (node.selected) node.id,
      };

  KeyEventResult _handleSelectionKeyEvent(FocusNode node, KeyEvent event) {
    final pressed = event is! KeyUpEvent;
    if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
        event.logicalKey == LogicalKeyboardKey.shiftRight) {
      _extendSelectionModifier = pressed;
    }
    if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
        event.logicalKey == LogicalKeyboardKey.controlRight ||
        event.logicalKey == LogicalKeyboardKey.metaLeft ||
        event.logicalKey == LogicalKeyboardKey.metaRight) {
      _toggleSelectionModifier = pressed;
    }
    return KeyEventResult.ignored;
  }

  void _selectNode(BlenderGraphNode node) {
    _focusNode.requestFocus();
    widget.onNodeSelected?.call(node);
    if (widget.onNodeSelectionChanged == null) return;
    final pressed = HardwareKeyboard.instance.logicalKeysPressed;
    final extend =
        _extendSelectionModifier ||
        pressed.contains(LogicalKeyboardKey.shiftLeft) ||
        pressed.contains(LogicalKeyboardKey.shiftRight);
    final toggle =
        _toggleSelectionModifier ||
        pressed.contains(LogicalKeyboardKey.controlLeft) ||
        pressed.contains(LogicalKeyboardKey.controlRight) ||
        pressed.contains(LogicalKeyboardKey.metaLeft) ||
        pressed.contains(LogicalKeyboardKey.metaRight);
    final next = <String>{..._selectedNodeIds};
    if (toggle) {
      if (!next.remove(node.id)) next.add(node.id);
    } else if (extend) {
      next.add(node.id);
    } else {
      next
        ..clear()
        ..add(node.id);
    }
    widget.onNodeSelectionChanged!(Set<String>.unmodifiable(next));
  }
}
