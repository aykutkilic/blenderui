part of '../showcase_app.dart';

extension _ShowcaseEditorSurfaces on _ShowcaseAppState {
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
        onCurrentFrameChanged: (value) => _update(() => _frame = value),
      ),
      BlenderEditorType.dopeSheet => BlenderDopeSheetEditor(
        model: _timelineModel,
        onCurrentFrameChanged: (value) => _update(() => _frame = value),
      ),
      BlenderEditorType.graphEditor => BlenderCurveEditor(
        channels: const <BlenderCurveChannel>[
          BlenderCurveChannel(
            id: 'location-x',
            label: 'Cube / Location X',
            points: <Offset>[
              Offset(0, .2),
              Offset(.35, .7),
              Offset(.7, .35),
              Offset(1, .8),
            ],
            color: Color(0xFFFF3352),
          ),
          BlenderCurveChannel(
            id: 'location-y',
            label: 'Cube / Location Y',
            points: <Offset>[
              Offset(0, .6),
              Offset(.35, .2),
              Offset(.7, .75),
              Offset(1, .4),
            ],
            color: Color(0xFF8BDC00),
          ),
        ],
        sidebar: const BlenderGraphEditorSidebar(),
        footer: BlenderAnimationPlaybackFooter(
          state: _animationHeaderState,
          onStateChanged: (value) =>
              _update(() => _animationHeaderState = value),
          playing: _playing,
          onFirst: () => _update(() => _frame = 1),
          onPrevious: () =>
              _update(() => _frame = (_frame - 1).clamp(1, 120).toDouble()),
          onPlay: () => _update(() => _playing = !_playing),
          onNext: () =>
              _update(() => _frame = (_frame + 1).clamp(1, 120).toDouble()),
          onLast: () => _update(() => _frame = 120),
          onRecord: () => _setStatus('Record toggled'),
          frame: _frame,
          frameMax: 120,
          onFrameChanged: (value) => _update(() => _frame = value),
          keyPrefix: 'graph-playback',
        ),
      ),
      BlenderEditorType.nlaEditor => BlenderNLAEditor(
        strips: _sequenceStrips,
        start: 1,
        end: 120,
        currentFrame: _frame,
        onCurrentFrameChanged: (value) => _update(() => _frame = value),
        footer: _buildNlaPlaybackFooter(),
      ),
      BlenderEditorType.drivers => const BlenderCurveEditor(
        channels: <BlenderCurveChannel>[
          BlenderCurveChannel(
            id: 'driver',
            label: 'Driver / Value',
            points: <Offset>[Offset(0, .25), Offset(.45, .6), Offset(1, .4)],
            color: Color(0xFFFFB74D),
          ),
        ],
        sidebar: BlenderGraphEditorSidebar(drivers: true),
      ),
      BlenderEditorType.sequencer ||
      BlenderEditorType.videoEditing => BlenderVideoSequencerEditor(
        title: null,
        strips: _sequenceStrips,
        start: 1,
        end: 120,
        currentFrame: _frame,
        onCurrentFrameChanged: (value) => _update(() => _frame = value),
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
      BlenderEditorType.fileBrowser => BlenderFileBrowser(
        title: null,
        entries: const <BlenderFileEntry>[
          BlenderFileEntry(
            path: '/showcase/assets',
            name: 'assets',
            isDirectory: true,
            detail: 'Folder',
          ),
          BlenderFileEntry(
            path: '/showcase/scene.blend',
            name: 'scene.blend',
            detail: '2.4 MB',
          ),
          BlenderFileEntry(
            path: '/showcase/materials.blend',
            name: 'materials.blend',
            detail: '840 KB',
          ),
          BlenderFileEntry(
            path: '/showcase/readme.txt',
            name: 'readme.txt',
            detail: 'Text file',
          ),
        ],
        searchController: _fileSearchController,
        sidebar: const BlenderFileBrowserSidebar(),
        onBack: () => _setStatus('Back'),
        onForward: () => _setStatus('Forward'),
        onParent: () => _setStatus('Parent directory'),
        onRefresh: () => _setStatus('Refreshed'),
        onNewFolder: () => _setStatus('New folder'),
        pathSegments: const <String>['/', 'showcase'],
        selectedPath: _selectedFile,
        gridView: _fileGrid,
        onGridViewChanged: (value) => _update(() => _fileGrid = value),
        onSelected: (entry) => _update(() => _selectedFile = entry.path),
        onOpen: (entry) => _setStatus('Opened ${entry.name}'),
        contextMenuItemsBuilder: (_) => BlenderContextMenuCatalog.fileBrowser(),
        onContextMenuSelected: (entry, action) =>
            _setStatus('$action: ${entry.name}'),
        onPathSelected: (index) => _setStatus('Path segment $index'),
      ),
      BlenderEditorType.assetBrowser => BlenderFileBrowser(
        title: null,
        entries: const <BlenderFileEntry>[
          BlenderFileEntry(
            path: '/showcase/assets',
            name: 'assets',
            isDirectory: true,
            detail: 'Asset Library',
          ),
          BlenderFileEntry(
            path: '/showcase/assets/cube.blend',
            name: 'cube.blend',
            detail: 'Object Asset',
          ),
          BlenderFileEntry(
            path: '/showcase/assets/materials.blend',
            name: 'materials.blend',
            detail: 'Material Asset',
          ),
        ],
        searchController: _fileSearchController,
        onBack: () => _setStatus('Back'),
        onForward: () => _setStatus('Forward'),
        onParent: () => _setStatus('Parent directory'),
        onRefresh: () => _setStatus('Refreshed'),
        onNewFolder: () => _setStatus('New folder'),
        sidebar: BlenderFileBrowserSidebar(
          assetBrowser: true,
          assetCatalog: BlenderFileAssetCatalogPanel(
            libraryValue: 'Local',
            libraryItems: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Local', label: 'Local'),
              BlenderMenuItem<String>(value: 'Essentials', label: 'Essentials'),
            ],
            catalogRoots: const <BlenderTreeNode<String>>[
              BlenderTreeNode<String>(
                id: 'environment',
                label: 'Environment',
                icon: BlenderGlyph.collection,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'studio',
                    label: 'Studio Lighting',
                    icon: BlenderGlyph.folder,
                    value: 'studio',
                  ),
                  BlenderTreeNode<String>(
                    id: 'outdoor',
                    label: 'Outdoor',
                    icon: BlenderGlyph.folder,
                    value: 'outdoor',
                  ),
                ],
              ),
            ],
            onLibraryChanged: (value) => _setStatus('Library: $value'),
            onRefresh: () => _setStatus('Refresh asset library'),
            onBundleInstall: () => _setStatus('Install asset bundle'),
            onNewCatalog: (node) =>
                _setStatus('New catalog under ${node.label}'),
            onCatalogContextMenuSelected: (node, action) =>
                _setStatus('$action catalog: ${node.label}'),
            onSelected: (node) => _setStatus('Catalog: ${node.label}'),
          ),
        ),
        assetBrowser: true,
        pathSegments: const <String>['/', 'assets'],
        selectedPath: _selectedFile,
        gridView: true,
        onSelected: (entry) => _update(() => _selectedFile = entry.path),
        onOpen: (entry) => _setStatus('Opened ${entry.name}'),
        contextMenuItemsBuilder: (_) => BlenderContextMenuCatalog.fileBrowser(),
        onContextMenuSelected: (entry, action) =>
            _setStatus('$action asset: ${entry.name}'),
        onPathSelected: (index) => _setStatus('Asset path segment $index'),
      ),
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
