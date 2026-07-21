part of '../showcase_app.dart';

extension _ShowcaseBottomGraphEditor on _ShowcaseAppState {
  Widget _buildBottomEditor() {
    if (_templateMode != _ShowcaseTemplateMode.general) {
      return _buildGreasePencilDopeSheetArea();
    }
    final selectorItems = <BlenderMenuItem<int>>[
      const BlenderMenuItem<int>(value: 0, label: 'Timeline'),
      const BlenderMenuItem<int>(value: 1, label: 'Action'),
      const BlenderMenuItem<int>(value: 2, label: 'Shader Editor'),
      const BlenderMenuItem<int>(value: 3, label: 'Spreadsheet'),
      if (_workspaceIndex == 10)
        const BlenderMenuItem<int>(value: 4, label: 'Keymap'),
      if (_workspaceIndex == 10)
        const BlenderMenuItem<int>(value: 5, label: 'UI Catalog'),
    ];
    final selectorGlyph = switch (_bottomTab) {
      0 => BlenderGlyph.timeline,
      1 => BlenderGlyph.action,
      2 => BlenderGlyph.node,
      3 => BlenderGlyph.spreadsheet,
      4 => BlenderGlyph.keyCommand,
      _ => BlenderGlyph.settings,
    };
    final selector = BlenderPopover(
      key: const ValueKey<String>('bottom-editor-selector'),
      child: IgnorePointer(
        child: BlenderButton(
          label: '',
          leading: BlenderIcon(selectorGlyph, size: 16),
          trailing: const BlenderIcon(BlenderGlyph.chevronDown, size: 9),
          variant: BlenderButtonVariant.toolbar,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          onPressed: () {},
        ),
      ),
      popover: (context, close) => BlenderMenu<int>(
        items: selectorItems,
        onSelected: (item) {
          _update(() => _bottomTab = item.value);
          close();
        },
      ),
    );
    final header = _bottomTab <= 1
        ? BlenderPlaybackBuilder(
            controller: _playback,
            builder: (context, playback, child) => BlenderDopeSheetEditorHeader(
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
              editorSelectorWidth: 44,
              onStateChanged: (value) =>
                  _update(() => _animationHeaderState = value),
              onCommand: _setStatus,
              actionValue: _activeAction,
              actionItems: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'CubeAction',
                  label: 'CubeAction',
                ),
                BlenderMenuItem<String>(
                  value: 'CameraAction',
                  label: 'CameraAction',
                ),
              ],
              onActionChanged: (value) => _update(() => _activeAction = value),
              onActionNew: () => _setStatus('New Action'),
              onActionUnlink: () => _setStatus('Unlink Action'),
              actionUserCount: 1,
              playing: _playback.playing,
              onFirst: _playback.jumpToStart,
              onPrevious: _playback.stepBackward,
              onPlay: _playback.togglePlaying,
              onNext: _playback.stepForward,
              onLast: _playback.jumpToEnd,
              onRecord: () => _setStatus('Record toggled'),
              onTimeBackward: _playback.stepBackward,
              onTimeForward: _playback.stepForward,
              frame: _frame,
              frameMax: 120,
              rangeStart: 1,
              rangeEnd: 120,
              onFrameChanged: _playback.seek,
            ),
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
        onCurrentFrameChanged: _playback.seek,
        currentFrameListenable: _playback,
      ),
      1 => BlenderDopeSheetEditor(
        title: 'Action',
        model: _actionModel,
        onCurrentFrameChanged: _playback.seek,
        currentFrameListenable: _playback,
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
        bindings: _application.commandBindings,
        commands: _application.commands,
        onImport: () => _setStatus('Import Key Configuration'),
        onExport: (_) => _setStatus('Exported Key Configuration'),
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
