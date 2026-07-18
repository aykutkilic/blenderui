part of '../showcase_app.dart';

extension _ShowcaseEditorSurfaces on _ShowcaseAppState {
  Widget _buildMainEditorSurface() {
    final surface = switch (_mainEditorType) {
      BlenderEditorType.view3d => BlenderRegion(
        title: null,
        child: ShowcaseViewport(
          selectedObject: _selectedObject,
          showGrid: _showGrid,
          wireframe: _wireframe,
          sidebar: const BlenderViewportSidebar(),
        ),
      ),
      BlenderEditorType.imageEditor => const BlenderImageEditor(
        label: 'Image Editor',
        sidebar: BlenderImageEditorSidebar(),
      ),
      BlenderEditorType.uvEditor => const BlenderUVEditor(
        points: <BlenderUVPoint>[
          BlenderUVPoint(id: 'a', position: Offset(.18, .2)),
          BlenderUVPoint(id: 'b', position: Offset(.78, .2)),
          BlenderUVPoint(id: 'c', position: Offset(.78, .78)),
          BlenderUVPoint(id: 'd', position: Offset(.18, .78)),
        ],
        edges: <BlenderUVEdge>[
          BlenderUVEdge(from: 0, to: 1),
          BlenderUVEdge(from: 1, to: 2),
          BlenderUVEdge(from: 2, to: 3),
          BlenderUVEdge(from: 3, to: 0),
        ],
        sidebar: BlenderImageEditorSidebar(uvEditor: true),
      ),
      BlenderEditorType.timeline => BlenderTimeline(
        model: _timelineModel,
        onCurrentFrameChanged: (value) => _update(() => _frame = value),
      ),
      BlenderEditorType.dopeSheet => BlenderDopeSheetEditor(
        model: _timelineModel,
        onCurrentFrameChanged: (value) => _update(() => _frame = value),
      ),
      BlenderEditorType.graphEditor => const BlenderCurveEditor(
        channels: <BlenderCurveChannel>[
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
      ),
      BlenderEditorType.sequencer ||
      BlenderEditorType.videoEditing => BlenderVideoSequencerEditor(
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
        onCommand: (command) => _setStatus('Ran: $command'),
      ),
      BlenderEditorType.infoEditor => const BlenderInfoEditor(
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
        text: '# Blender UI text editor\nprint("Hello from Flutter")',
        sidebar: BlenderTextEditorSidebar(),
      ),
      BlenderEditorType.project => const BlenderProjectEditor(),
      BlenderEditorType.spreadsheet => BlenderSpreadsheetEditor(
        columns: _spreadsheetColumns,
        rows: _spreadsheetRows,
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
        onPathSelected: (index) => _setStatus('Path segment $index'),
      ),
      BlenderEditorType.assetBrowser => BlenderFileBrowser(
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
        onPathSelected: (index) => _setStatus('Asset path segment $index'),
      ),
      BlenderEditorType.shaderEditor ||
      BlenderEditorType.geometryNodeEditor ||
      BlenderEditorType.compositor ||
      BlenderEditorType.textureNodeEditor => BlenderNodeEditor(
        model: _nodeGraph,
        sidebar: BlenderNodeEditorSidebar(
          geometryNodeEditor:
              _mainEditorType == BlenderEditorType.geometryNodeEditor,
          compositor: _mainEditorType == BlenderEditorType.compositor,
        ),
        onNodeSelected: (node) => _setStatus('Selected node ${node.title}'),
        onNodeMoved: _moveNode,
      ),
    };
    return BlenderContextMenu<String>(
      items: const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Duplicate', label: 'Duplicate'),
        BlenderMenuItem<String>(value: 'Delete', label: 'Delete'),
        BlenderMenuItem<String>(value: 'Frame', label: 'Frame Selected'),
      ],
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
            menuDescriptors: _editorMenuDescriptors(<String>['View']),
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
