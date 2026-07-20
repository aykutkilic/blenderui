part of '../showcase_app.dart';

extension _ShowcaseBottomGraphEditor on _ShowcaseAppState {
  Widget _buildBottomEditor() {
    final bottomLabel = switch (_bottomTab) {
      0 => 'Timeline',
      1 => 'Action',
      2 => 'Shader Editor',
      3 => 'Spreadsheet',
      4 => 'Keymap',
      _ => 'UI Catalog',
    };
    final selector = BlenderMenuButton<int>(
      label: bottomLabel,
      items: const <BlenderMenuItem<int>>[
        BlenderMenuItem<int>(value: 0, label: 'Timeline'),
        BlenderMenuItem<int>(value: 1, label: 'Action'),
        BlenderMenuItem<int>(value: 2, label: 'Shader Editor'),
        BlenderMenuItem<int>(value: 3, label: 'Spreadsheet'),
        BlenderMenuItem<int>(value: 4, label: 'Keymap'),
        BlenderMenuItem<int>(value: 5, label: 'UI Catalog'),
      ],
      onSelected: (value) => _update(() => _bottomTab = value),
    );
    final header = _bottomTab <= 1
        ? BlenderDopeSheetEditorHeader(
            editorType: _bottomTab == 0
                ? BlenderEditorType.timeline
                : BlenderEditorType.dopeSheet,
            state: _animationHeaderState,
            keyPrefix: 'animation',
            playheadSnapKey: const ValueKey<String>(
              'animation-playhead-snapping-button',
            ),
            overlayKey: const ValueKey<String>('animation-overlay-button'),
            editorSelector: selector,
            editorSelectorWidth: 132,
            onStateChanged: (value) =>
                _update(() => _animationHeaderState = value),
            onCommand: _setStatus,
            actionValue: _activeAction,
            actionItems: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'CubeAction', label: 'CubeAction'),
              BlenderMenuItem<String>(
                value: 'CameraAction',
                label: 'CameraAction',
              ),
            ],
            onActionChanged: (value) => _update(() => _activeAction = value),
            onActionNew: () => _setStatus('New Action'),
            onActionUnlink: () => _setStatus('Unlink Action'),
            actionUserCount: 1,
            playing: _playing,
            onFirst: () => _update(() => _frame = 1),
            onPrevious: () =>
                _update(() => _frame = (_frame - 1).clamp(1, 120).toDouble()),
            onPlay: () => _update(() => _playing = !_playing),
            onNext: () =>
                _update(() => _frame = (_frame + 1).clamp(1, 120).toDouble()),
            onLast: () => _update(() => _frame = 120),
            onRecord: () => _setStatus('Record toggled'),
            onTimeBackward: () =>
                _update(() => _frame = (_frame - 1).clamp(1, 120).toDouble()),
            onTimeForward: () =>
                _update(() => _frame = (_frame + 1).clamp(1, 120).toDouble()),
            frame: _frame,
            frameMax: 120,
            onFrameChanged: (value) => _update(() => _frame = value),
          )
        : BlenderToolbar(
            height: 30,
            scrollable: true,
            children: <Widget>[
              SizedBox(width: 132, child: selector),
              const SizedBox(width: 6),
              AnimatedBuilder(
                animation: _application.status,
                builder: (context, _) =>
                    Text(_application.status.message?.text ?? 'Ready'),
              ),
            ],
          );
    return Column(
      children: <Widget>[
        header,
        Expanded(child: _buildBottomContent()),
      ],
    );
  }

  Widget _buildBottomContent() {
    return switch (_bottomTab) {
      0 => BlenderTimeline(
        title: null,
        model: _timelineModel,
        onCurrentFrameChanged: (value) => _update(() => _frame = value),
      ),
      1 => BlenderDopeSheetEditor(
        title: 'Action',
        model: _actionModel,
        onCurrentFrameChanged: (value) => _update(() => _frame = value),
      ),
      2 => BlenderNodeEditor(
        model: _nodeGraph,
        onNodeSelected: (node) => _setStatus('Selected node ${node.title}'),
        selectedNodeIds: <String>{
          for (final node in _nodeGraph.nodes)
            if (node.selected) node.id,
        },
        onNodeSelectionChanged: _selectNodes,
        onNodesMoved: _moveNodes,
        onLinksCut: _cutNodeLinks,
        onLinkCreated: _connectNodeSockets,
        contextMenuItemsBuilder: (_) => BlenderContextMenuCatalog.node(),
        onContextMenuSelected: (node, action) =>
            _setStatus('$action: ${node.title}'),
      ),
      3 => BlenderSpreadsheetEditor(
        columns: _spreadsheetColumns,
        rows: _spreadsheetRows,
      ),
      4 => BlenderKeymapEditor(
        searchController: _keymapSearchController,
        selectedId: _selectedShortcut,
        entries: const <BlenderKeymapEntry>[
          BlenderKeymapEntry(
            id: 'move',
            action: 'Move',
            shortcut: 'G',
            category: '3D View',
          ),
          BlenderKeymapEntry(
            id: 'rotate',
            action: 'Rotate',
            shortcut: 'R',
            category: '3D View',
          ),
          BlenderKeymapEntry(
            id: 'save',
            action: 'Save Mainfile',
            shortcut: 'Ctrl+S',
            category: 'Window',
          ),
        ],
        onSelected: (entry) {
          _update(() => _selectedShortcut = entry.id);
          _setStatus('Selected ${entry.action}');
        },
      ),
      _ => _buildControlGallery(),
    };
  }

  BlenderGraphEditorHeader _buildGraphEditorHeader(BlenderEditorType type) {
    return BlenderGraphEditorHeader(
      editorType: type,
      state: _graphHeaderState,
      onEditorTypeChanged: _mainEditorArea.select,
      onStateChanged: (value) => _update(() => _graphHeaderState = value),
      onCommand: _setStatus,
    );
  }
}
