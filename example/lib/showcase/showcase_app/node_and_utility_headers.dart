part of '../showcase_app.dart';

extension _ShowcaseNodeUtilityHeaders on _ShowcaseAppState {
  Widget _buildNodeEditorHeader(BlenderEditorType type) {
    final dataBlock = switch (type) {
      BlenderEditorType.geometryNodeEditor =>
        _nodeTreeContext == 'Tool' ? 'Tool Group' : 'Modifier Group',
      BlenderEditorType.compositor =>
        _nodeTreeContext == 'Sequencer' ? 'Compositor Strip' : 'Scene Nodes',
      BlenderEditorType.textureNodeEditor => 'Texture Nodes',
      _ => 'Material Nodes',
    };
    return BlenderNodeEditorHeader(
      editorType: type,
      treeContext: _nodeTreeContext,
      dataBlock: dataBlock,
      onEditorTypeChanged: _mainEditorArea.select,
      onTreeContextChanged: (value) => _update(() {
        _nodeTreeContext = value;
      }),
      onDataBlockChanged: (value) => _setStatus('Node tree: $value'),
      onCommand: _handleNodeEditorCommand,
      pinned: _nodePinned,
      onPinnedChanged: (value) => _update(() => _nodePinned = value),
      snapping: _nodeSnap,
      onSnappingChanged: (value) => _update(() => _nodeSnap = value),
      overlays: _nodeOverlays,
      onOverlaysChanged: (value) => _update(() => _nodeOverlays = value),
      wireColors: _nodeWireColors,
      onWireColorsChanged: (value) => _update(() => _nodeWireColors = value),
      showNamedAttributes: _nodeShowNamedAttributes,
      onShowNamedAttributesChanged: (value) =>
          _update(() => _nodeShowNamedAttributes = value),
      showTimings: _nodeShowTimings,
      onShowTimingsChanged: (value) => _update(() => _nodeShowTimings = value),
      showBackdrop: _nodeShowBackdrop,
      onShowBackdropChanged: (value) =>
          _update(() => _nodeShowBackdrop = value),
      gizmos: _nodeGizmos,
      onGizmosChanged: (value) => _update(() => _nodeGizmos = value),
    );
  }

  BlenderUtilityEditorHeader _buildUtilityEditorHeader(
    BlenderEditorType type,
  ) => BlenderUtilityEditorHeader(
    editorType: type,
    onEditorTypeChanged: _mainEditorArea.select,
    outlinerDataApi: _outlinerDisplayMode == BlenderOutlinerDisplayMode.dataApi,
    menuDescriptors: type == BlenderEditorType.preferences
        ? _editorHeaderPresets[type]!.menuDescriptors(_application.commands)
        : null,
    onCommand: _setStatus,
  );
}
