part of '../showcase_app.dart';

extension _ShowcaseEditorSurfaces on _ShowcaseAppState {
  List<BlenderGraphChannelNode> get _graphChannelTree =>
      <BlenderGraphChannelNode>[
        BlenderGraphChannelNode(
          id: 'cube-object',
          label: 'Cube',
          kind: BlenderGraphChannelKind.object,
          expanded: !_collapsedGraphNodes.contains('cube-object'),
          children: <BlenderGraphChannelNode>[
            BlenderGraphChannelNode(
              id: 'cube-action',
              label: 'CubeAction',
              kind: BlenderGraphChannelKind.action,
              expanded: !_collapsedGraphNodes.contains('cube-action'),
              children: <BlenderGraphChannelNode>[
                BlenderGraphChannelNode(
                  id: 'location-group',
                  label: 'Location',
                  kind: BlenderGraphChannelKind.group,
                  color: const Color(0xFF3A9A3A),
                  expanded: !_collapsedGraphNodes.contains('location-group'),
                  children: <BlenderGraphChannelNode>[
                    for (final curve in _graphCurves)
                      BlenderGraphChannelNode(
                        id: curve.id,
                        label: curve.label,
                        kind: BlenderGraphChannelKind.curve,
                        curveId: curve.id,
                        color: curve.color,
                        selected: curve.id == _activeGraphChannel,
                        visible: curve.visible,
                        muted: curve.muted,
                        locked: curve.locked,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ];

  BlenderCurveChannel get _activeGraphCurve => _graphCurves.firstWhere(
    (curve) => curve.id == _activeGraphChannel,
    orElse: () => _graphCurves.first,
  );

  void _selectGraphChannel(String id) {
    _update(() {
      _activeGraphChannel = id;
      _graphCurves = <BlenderCurveChannel>[
        for (final curve in _graphCurves)
          curve.copyWith(selected: curve.id == id, active: curve.id == id),
      ];
    });
  }

  void _moveGraphKeyframe(BlenderGraphKeyframeMove move) {
    _update(() {
      _graphCurves = <BlenderCurveChannel>[
        for (final curve in _graphCurves)
          curve.id == move.keyframe.channelId
              ? curve.copyWith(
                  keyframes: <BlenderGraphKeyframe>[
                    for (final key in curve.resolvedKeyframes)
                      key.id == move.keyframe.keyframeId
                          ? key.copyWith(frame: move.frame, value: move.value)
                          : key,
                  ],
                )
              : curve,
      ];
    });
  }

  void _applyGraphChannelAction(BlenderGraphChannelAction action) {
    if (action.type == BlenderGraphChannelActionType.toggleExpanded) {
      _update(() {
        _collapsedGraphNodes = <String>{..._collapsedGraphNodes};
        if (!_collapsedGraphNodes.remove(action.nodeId)) {
          _collapsedGraphNodes.add(action.nodeId);
        }
      });
      return;
    }
    _update(() {
      _graphCurves = <BlenderCurveChannel>[
        for (final curve in _graphCurves)
          curve.id == action.nodeId
              ? switch (action.type) {
                  BlenderGraphChannelActionType.toggleVisible => curve.copyWith(
                    visible: !curve.visible,
                  ),
                  BlenderGraphChannelActionType.toggleMuted => curve.copyWith(
                    muted: !curve.muted,
                  ),
                  BlenderGraphChannelActionType.toggleLocked => curve.copyWith(
                    locked: !curve.locked,
                  ),
                  BlenderGraphChannelActionType.toggleExpanded => curve,
                }
              : curve,
      ];
    });
  }

  Widget _buildMainEditorSurface() {
    final surface = switch (_mainEditorType) {
      BlenderEditorType.view3d => BlenderRegion(
        title: null,
        child: ShowcaseViewport(
          selectedObject: _selectedObject,
          showGrid: _showGrid,
          wireframe: _view3dHeaderState.shading == 'Wireframe',
          toolShelf: _buildLeftSidebar(floating: true),
          selectionMode: _selectionMode,
          onSelectionModeChanged: (value) =>
              _update(() => _selectionMode = value),
          onStatus: _setStatus,
        ),
      ),
      BlenderEditorType.imageEditor => BlenderImageEditor(
        label: 'Image Editor',
        toolShelf: BlenderImageEditorToolShelf(
          mode: _imageHeaderState.mode,
          selectedIndex: _imageToolIndex,
          onChanged: (value) => _update(() => _imageToolIndex = value),
          onOptionSelected: (option) => _setStatus(option.label),
        ),
        sidebar: const BlenderImageEditorSidebar(),
        assetShelf: _imageHeaderState.mode == BlenderImageEditorMode.paint
            ? BlenderAssetShelf(
                title: 'Brush Assets',
                assets: const <BlenderAssetTile>[
                  BlenderAssetTile(id: 'draw', label: 'Draw'),
                  BlenderAssetTile(id: 'soften', label: 'Soften'),
                  BlenderAssetTile(id: 'smear', label: 'Smear'),
                  BlenderAssetTile(id: 'clone', label: 'Clone'),
                ],
                onSelected: (asset) => _setStatus('Brush: ${asset.label}'),
              )
            : null,
      ),
      BlenderEditorType.uvEditor => BlenderUVEditor(
        points: const <BlenderUVPoint>[
          BlenderUVPoint(id: 'a', position: Offset(.18, .2)),
          BlenderUVPoint(id: 'b', position: Offset(.78, .2)),
          BlenderUVPoint(id: 'c', position: Offset(.78, .78)),
          BlenderUVPoint(id: 'd', position: Offset(.18, .78)),
        ],
        edges: const <BlenderUVEdge>[
          BlenderUVEdge(from: 0, to: 1),
          BlenderUVEdge(from: 1, to: 2),
          BlenderUVEdge(from: 2, to: 3),
          BlenderUVEdge(from: 3, to: 0),
        ],
        toolShelf: BlenderImageEditorToolShelf(
          mode: BlenderImageEditorMode.uv,
          selectedIndex: _imageToolIndex,
          onChanged: (value) => _update(() => _imageToolIndex = value),
          onOptionSelected: (option) => _setStatus(option.label),
        ),
        sidebar: const BlenderImageEditorSidebar(uvEditor: true),
      ),
      BlenderEditorType.timeline => BlenderTimeline(
        model: _timelineModel,
        onCurrentFrameChanged: _playback.seek,
        currentFrameListenable: _playback,
      ),
      BlenderEditorType.dopeSheet => BlenderDopeSheetEditor(
        model: _timelineModel,
        onCurrentFrameChanged: _playback.seek,
        currentFrameListenable: _playback,
      ),
      BlenderEditorType.graphEditor => BlenderCurveEditor(
        channels: _graphCurves,
        channelTree: _graphChannelTree,
        viewportController: _graphViewport,
        currentFrame: _frame,
        currentFrameListenable: _playback,
        cursor: _graphCursor,
        frameRangeStart: 1,
        frameRangeEnd: 120,
        markers: const <BlenderGraphMarker>[
          BlenderGraphMarker(frame: 1, label: 'Start'),
          BlenderGraphMarker(frame: 120, label: 'End'),
        ],
        selectedKeyframes: _selectedGraphKeys,
        activeChannelId: _activeGraphChannel,
        onCurrentFrameChanged: _playback.seek,
        onSelectionChanged: (value) =>
            _update(() => _selectedGraphKeys = value),
        onKeyframeMoved: _moveGraphKeyframe,
        onChannelSelected: _selectGraphChannel,
        onChannelAction: _applyGraphChannelAction,
        contextMenuItems: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'copy', label: 'Copy'),
          BlenderMenuItem<String>(value: 'paste', label: 'Paste'),
          BlenderMenuItem<String>(value: 'insert', label: 'Insert Keyframe'),
          BlenderMenuItem<String>(value: 'handle', label: 'Handle Type'),
          BlenderMenuItem<String>(
            value: 'interpolation',
            label: 'Interpolation Mode',
          ),
          BlenderMenuItem<String>(value: 'delete', label: 'Delete'),
        ],
        onContextMenuSelected: _setStatus,
        normalize: _graphHeaderState.normalize,
        sidebar: BlenderGraphEditorSidebar(
          cursor: _graphCursor,
          onCursorChanged: (value) => _update(() => _graphCursor = value),
          activeChannel: _activeGraphCurve,
          modifiers: const <String>['Cycles'],
          onCommand: _setStatus,
        ),
        footer: BlenderAnimationPlaybackFooter(
          state: _animationHeaderState,
          onStateChanged: (value) =>
              _update(() => _animationHeaderState = value),
          playing: _playback.playing,
          onFirst: _playback.jumpToStart,
          onPrevious: _playback.stepBackward,
          onPlay: _playback.togglePlaying,
          onNext: _playback.stepForward,
          onLast: _playback.jumpToEnd,
          onRecord: () => _setStatus('Record toggled'),
          frame: _frame,
          frameMax: 120,
          onFrameChanged: _playback.seek,
          keyPrefix: 'graph-playback',
        ),
      ),
      BlenderEditorType.nlaEditor => BlenderNLAEditor(
        strips: _sequenceStrips,
        start: 1,
        end: 120,
        currentFrame: _frame,
        onCurrentFrameChanged: _playback.seek,
        footer: _buildNlaPlaybackFooter(),
      ),
      BlenderEditorType.drivers => BlenderCurveEditor(
        channels: const <BlenderCurveChannel>[
          BlenderCurveChannel(
            id: 'driver',
            label: 'Driver / Value',
            keyframes: <BlenderGraphKeyframe>[
              BlenderGraphKeyframe(id: 'driver-0', frame: -1, value: -.5),
              BlenderGraphKeyframe(id: 'driver-1', frame: 0, value: 0),
              BlenderGraphKeyframe(id: 'driver-2', frame: 1, value: .8),
            ],
            color: Color(0xFFFFB74D),
            active: true,
          ),
        ],
        viewportController: _driverViewport,
        cursor: const Offset(0, 0),
        showCursorFrame: true,
        activeChannelId: 'driver',
        sidebar: const BlenderGraphEditorSidebar(drivers: true),
      ),
      BlenderEditorType.sequencer ||
      BlenderEditorType.videoEditing => BlenderVideoSequencerEditor(
        title: null,
        strips: _sequenceStrips,
        start: 1,
        end: 120,
        currentFrame: _frame,
        onCurrentFrameChanged: _playback.seek,
      ),
      BlenderEditorType.clipEditor => const BlenderClipEditor(
        markers: <BlenderClipMarker>[
          BlenderClipMarker(id: 'track-a', position: Offset(120, 90)),
          BlenderClipMarker(id: 'track-b', position: Offset(260, 140)),
          BlenderClipMarker(id: 'track-c', position: Offset(410, 70)),
        ],
        maskSidebar: BlenderMaskProperties(),
        sidebar: BlenderClipEditorSidebar(),
      ),
      BlenderEditorType.pythonConsole => BlenderConsoleEditor(
        lines: _consoleLines,
        history: const <String>['bpy.context.scene', 'print("Hello")'],
        title: null,
        onCommand: (command) => _setStatus('Ran: $command'),
      ),
      BlenderEditorType.infoEditor => const BlenderInfoEditor(
        title: null,
        reports: <BlenderInfoReport>[
          BlenderInfoReport(
            id: 'saved',
            message: 'Saved showcase.blend',
            level: BlenderNoticeLevel.success,
            timestamp: 'Now',
          ),
          BlenderInfoReport(
            id: 'preview',
            message: '3D viewport is represented by a lightweight 2D preview',
            level: BlenderNoticeLevel.info,
            timestamp: 'Now',
          ),
        ],
      ),
      BlenderEditorType.textEditor => const BlenderTextEditor(
        title: null,
        text: '# Blender UI text editor\nprint("Hello from Flutter")',
        sidebar: BlenderTextEditorSidebar(),
        footer: BlenderTextEditorFooter(line: 2, column: 28),
      ),
      BlenderEditorType.project => const BlenderProjectEditor(),
      BlenderEditorType.spreadsheet => BlenderSpreadsheetEditor(
        columns: _spreadsheetColumns,
        rows: _spreadsheetRows,
        showOnlySelected: _spreadsheetHeaderState.onlySelected,
        useFilter: _spreadsheetHeaderState.useFilter,
        title: null,
      ),
      BlenderEditorType.outliner => BlenderOutliner<String>(
        roots: _outlinerRoots,
        selectedId: _selectedObject.toLowerCase(),
        displayMode: _outlinerDisplayMode,
        onDisplayModeChanged: (mode) =>
            _update(() => _outlinerDisplayMode = mode),
        filterController: _mainOutlinerSearchController,
        syncSelection: _outlinerSyncSelection,
        onSyncSelectionChanged: (value) =>
            _update(() => _outlinerSyncSelection = value),
        libraryOverrideViewMode: _outlinerOverrideViewMode,
        onLibraryOverrideViewModeChanged: (value) =>
            _update(() => _outlinerOverrideViewMode = value),
        useIdFilter: _outlinerUseIdFilter,
        onIdFilterChanged: (value) =>
            _update(() => _outlinerUseIdFilter = value),
        idFilterType: _outlinerIdFilterType,
        onIdFilterTypeChanged: (value) =>
            _update(() => _outlinerIdFilterType = value),
        onNewCollection: () => _setStatus('New collection'),
        onPurgeUnusedData: () => _setStatus('Purge unused data'),
        hasActiveKeyingSet: _outlinerHasKeyingSet,
        activeKeyingSet: _outlinerKeyingSet,
        onKeyingSetChanged: (value) =>
            _update(() => _outlinerKeyingSet = value),
        onKeyingSetAdd: () => _setStatus('Added selected to keying set'),
        onKeyingSetRemove: () => _setStatus('Removed selected from keying set'),
        onKeyframeInsert: () => _setStatus('Inserted keyframe'),
        onKeyframeDelete: () => _setStatus('Deleted keyframe'),
        onSelected: (node) {
          if (node.value != null) _setStatus('Selected ${node.value}');
        },
        contextMenuTitleBuilder: (node) => node.label,
        contextMenuItemsBuilder: (node) => BlenderContextMenuCatalog.outliner(
          isAsset: node.id.contains('asset'),
        ),
        onContextMenuSelected: (node, action) =>
            _setStatus('$action: ${node.label}'),
      ),
      BlenderEditorType.properties => BlenderPropertiesEditor(
        groups: _propertyGroups,
      ),
      BlenderEditorType.preferences => BlenderPreferencesEditor(
        categories: _preferenceCategories,
        categoryGroups: _preferenceCategoryGroups,
        selectedCategory: _preferenceCategory,
        onCategoryChanged: (value) =>
            _update(() => _preferenceCategory = value),
        sections: _preferenceSections,
      ),
      BlenderEditorType.fileBrowser => _buildFileBrowserSurface(),
      BlenderEditorType.assetBrowser => _buildAssetBrowserSurface(),
      BlenderEditorType.shaderEditor ||
      BlenderEditorType.geometryNodeEditor ||
      BlenderEditorType.compositor ||
      BlenderEditorType.textureNodeEditor => BlenderNodeEditor(
        model: _nodeGraph,
        title: null,
        showGrid: _nodeOverlays,
        wireColors: _nodeWireColors,
        toolbar: BlenderNodeToolShelf(
          key: const ValueKey<String>('node-editor-tool-shelf'),
          selectedIndex: _nodeToolIndex,
          onChanged: (value) {
            _update(() => _nodeToolIndex = value);
            _setStatus(
              'Node tool: ${BlenderNodeToolShelf.tools[value].tooltip}',
            );
          },
          onOptionSelected: (option) =>
              _setStatus('Node tool: ${option.label}'),
        ),
        sidebar: BlenderNodeEditorSidebar(
          geometryNodeEditor:
              _mainEditorType == BlenderEditorType.geometryNodeEditor,
          compositor: _mainEditorType == BlenderEditorType.compositor,
          activeNode: _selectedNodeId == null
              ? _nodeGraph.nodes.where((node) => node.active).firstOrNull
              : _nodeGraph.nodeById(_selectedNodeId!),
          treeName: _mainEditorType == BlenderEditorType.geometryNodeEditor
              ? 'Scatter Pebbles'
              : 'Node Group',
          showNamedAttributes: _nodeShowNamedAttributes,
          showTimings: _nodeShowTimings,
        ),
        onNodeSelected: _selectNode,
        selectedNodeIds: <String>{
          for (final node in _nodeGraph.nodes)
            if (node.selected) node.id,
        },
        onNodeSelectionChanged: _selectNodes,
        onNodesMoved: _moveNodes,
        linkCutting: _nodeToolIndex == 2,
        onLinksCut: _cutNodeLinks,
        snapIncrement: _nodeSnap ? 20 : null,
        onNodeCollapseChanged: (node, collapsed) {
          final target = _mainEditorType == BlenderEditorType.geometryNodeEditor
              ? _geometryNodes
              : _nodes;
          final index = target.indexWhere(
            (candidate) => candidate.id == node.id,
          );
          if (index == -1) return;
          _update(() => target[index] = node.copyWith(collapsed: collapsed));
        },
        onSocketPressed: (node, socket, output) => _setStatus(
          '${output ? 'Output' : 'Input'}: ${node.title} / ${socket.label}',
        ),
        onLinkCreated: _connectNodeSockets,
        contextMenuItemsBuilder: (_) => BlenderContextMenuCatalog.node(),
        onContextMenuSelected: _handleNodeContextCommand,
      ),
    };
    final contextTitle = switch (_mainEditorType) {
      BlenderEditorType.view3d => 'Object',
      BlenderEditorType.outliner => 'Outliner',
      BlenderEditorType.fileBrowser => 'Files',
      BlenderEditorType.assetBrowser => 'Assets',
      BlenderEditorType.shaderEditor ||
      BlenderEditorType.geometryNodeEditor ||
      BlenderEditorType.compositor ||
      BlenderEditorType.textureNodeEditor => 'Node',
      BlenderEditorType.properties => 'Property',
      _ => _mainEditorType.label,
    };
    final contextItems = switch (_mainEditorType) {
      BlenderEditorType.view3d => BlenderContextMenuCatalog.object(),
      BlenderEditorType.outliner => BlenderContextMenuCatalog.outliner(),
      BlenderEditorType.fileBrowser ||
      BlenderEditorType.assetBrowser => BlenderContextMenuCatalog.fileBrowser(),
      BlenderEditorType.shaderEditor ||
      BlenderEditorType.geometryNodeEditor ||
      BlenderEditorType.compositor ||
      BlenderEditorType.textureNodeEditor => BlenderContextMenuCatalog.node(),
      BlenderEditorType.properties => BlenderContextMenuCatalog.property(),
      _ => BlenderContextMenuCatalog.area(),
    };
    return BlenderContextMenu<String>(
      title: contextTitle,
      items: contextItems,
      onSelected: _setStatus,
      child: surface,
    );
  }

  Widget _buildRightTopArea() {
    if (_rightTopEditorType != BlenderEditorType.outliner) {
      return _buildSwappableSidebarArea(
        editorType: _rightTopEditorType,
        onChanged: _rightTopEditorArea.select,
      );
    }
    return BlenderOutliner<String>(
      title: 'Scene Collection',
      roots: _outlinerRoots,
      selectedId: _selectedObject.toLowerCase(),
      editorType: _rightTopEditorType,
      onEditorTypeChanged: _rightTopEditorArea.select,
      displayMode: _outlinerDisplayMode,
      onDisplayModeChanged: (mode) =>
          _update(() => _outlinerDisplayMode = mode),
      syncSelection: _outlinerSyncSelection,
      onSyncSelectionChanged: (value) =>
          _update(() => _outlinerSyncSelection = value),
      libraryOverrideViewMode: _outlinerOverrideViewMode,
      onLibraryOverrideViewModeChanged: (value) =>
          _update(() => _outlinerOverrideViewMode = value),
      useIdFilter: _outlinerUseIdFilter,
      onIdFilterChanged: (value) => _update(() => _outlinerUseIdFilter = value),
      idFilterType: _outlinerIdFilterType,
      onIdFilterTypeChanged: (value) =>
          _update(() => _outlinerIdFilterType = value),
      onNewCollection: () => _setStatus('New collection'),
      onPurgeUnusedData: () => _setStatus('Purge unused data'),
      hasActiveKeyingSet: _outlinerHasKeyingSet,
      activeKeyingSet: _outlinerKeyingSet,
      onKeyingSetChanged: (value) => _update(() => _outlinerKeyingSet = value),
      onKeyingSetAdd: () => _setStatus('Added selected to keying set'),
      onKeyingSetRemove: () => _setStatus('Removed selected from keying set'),
      onKeyframeInsert: () => _setStatus('Inserted keyframe'),
      onKeyframeDelete: () => _setStatus('Deleted keyframe'),
      showVisibility: true,
      showLock: true,
      filterController: _outlinerSearchController,
      onSelected: (node) {
        _update(() => _selectedObject = node.value ?? node.label);
        _application.editorSession.selectOutlinerItem(
          'showcase',
          node.value ?? node.label,
        );
        _setStatus('Selected ${node.label}');
      },
      contextMenuTitleBuilder: (node) => node.label,
      contextMenuItemsBuilder: (node) => BlenderContextMenuCatalog.outliner(
        isAsset: node.id.contains('asset'),
      ),
      onContextMenuSelected: (node, action) =>
          _setStatus('$action: ${node.label}'),
      onVisibilityChanged: (node) =>
          _setStatus('${node.visible ? 'Hide' : 'Show'} ${node.label}'),
      onLockChanged: (node) =>
          _setStatus('${node.locked ? 'Unlock' : 'Lock'} ${node.label}'),
    );
  }

  Widget _buildRightBottomArea() {
    if (_rightBottomEditorType == BlenderEditorType.properties) {
      return _buildPropertiesColumn();
    }
    return _buildSwappableSidebarArea(
      editorType: _rightBottomEditorType,
      onChanged: _rightBottomEditorArea.select,
    );
  }

  Widget _buildSwappableSidebarArea({
    required BlenderEditorType editorType,
    required ValueChanged<BlenderEditorType> onChanged,
  }) {
    return BlenderEditorFrame(
      child: Column(
        children: <Widget>[
          BlenderAreaHeader(
            height: 30,
            editorType: editorType,
            showEditorLabel: false,
            onEditorTypeChanged: onChanged,
            menuDescriptors: BlenderEditorMenuCatalog.build(<String>[
              'View',
            ], onSelected: _setStatus),
            actions: const <Widget>[
              BlenderIconButton(
                glyph: BlenderGlyph.more,
                tooltip: 'Editor options',
              ),
            ],
          ),
          Expanded(
            child: BlenderRegion(
              title: editorType.label,
              child: Center(
                child: Text(
                  '${editorType.label} assigned to this area',
                  style: BlenderTheme.of(context).textTheme.caption,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
