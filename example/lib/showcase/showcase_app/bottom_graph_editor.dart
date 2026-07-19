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
    return Column(
      children: <Widget>[
        BlenderToolbar(
          height: 30,
          scrollable: true,
          children: <Widget>[
            BlenderIconButton(
              glyph: _bottomTab == 1
                  ? BlenderGlyph.action
                  : BlenderGlyph.timeline,
              tooltip: _bottomTab == 1 ? 'Action editor' : 'Timeline editor',
              size: 24,
            ),
            BlenderMenuButton<int>(
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
            ),
            if (_bottomTab <= 1) ...<Widget>[
              BlenderMenuButton<String>(
                key: const ValueKey<String>('animation-view-menu'),
                label: 'View',
                items: _animationViewMenuItems(timeline: _bottomTab == 0),
                onSelected: _setStatus,
              ),
              BlenderMenuButton<String>(
                key: const ValueKey<String>('animation-marker-menu'),
                label: 'Marker',
                items: _animationMarkerMenuItems(),
                onSelected: _setStatus,
              ),
              if (_bottomTab == 1) ...<Widget>[
                BlenderMenuButton<String>(
                  key: const ValueKey<String>('animation-select-menu'),
                  label: 'Select',
                  items: _animationSelectMenuItems(),
                  onSelected: _setStatus,
                ),
                BlenderMenuButton<String>(
                  key: const ValueKey<String>('animation-channel-menu'),
                  label: 'Channel',
                  items: _animationChannelMenuItems(),
                  onSelected: _setStatus,
                ),
                BlenderMenuButton<String>(
                  key: const ValueKey<String>('animation-key-menu'),
                  label: 'Key',
                  items: _animationKeyMenuItems(),
                  onSelected: _setStatus,
                ),
                BlenderMenuButton<String>(
                  key: const ValueKey<String>('animation-action-menu'),
                  label: 'Action',
                  items: _animationActionMenuItems(),
                  onSelected: _setStatus,
                ),
              ],
            ],
            if (_bottomTab == 1) ...<Widget>[
              BlenderPopover(
                child: const BlenderIconButton(
                  key: ValueKey<String>('animation-filters-button'),
                  glyph: BlenderGlyph.filter,
                  tooltip: 'Animation filters',
                  size: 24,
                ),
                popover: (context, close) => _buildAnimationFiltersPopover(),
              ),
              BlenderPopover(
                child: BlenderIconButton(
                  key: const ValueKey<String>('animation-snapping-button'),
                  glyph: BlenderGlyph.snap,
                  selected: _animationPlayheadSnap,
                  tooltip: 'Animation snapping',
                  size: 24,
                ),
                popover: (context, close) => _buildAnimationSnappingPopover(),
              ),
            ],
            if (_bottomTab == 1) ...<Widget>[
              BlenderPopover(
                child: BlenderIconButton(
                  key: const ValueKey<String>('animation-proportional-button'),
                  glyph: BlenderGlyph.transform,
                  selected: _animationProportional,
                  tooltip: 'Proportional editing',
                  size: 24,
                ),
                popover: (context, close) => _buildProportionalEditingPopover(),
              ),
              SizedBox(
                width: 220,
                child: BlenderActionSelector<String>(
                  value: _activeAction,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(
                      value: 'CubeAction',
                      label: 'CubeAction',
                    ),
                    BlenderMenuItem<String>(
                      value: 'CameraAction',
                      label: 'CameraAction',
                    ),
                  ],
                  onChanged: (value) => _update(() => _activeAction = value),
                  onNew: () => _setStatus('New Action'),
                  onUnlink: () => _setStatus('Unlink Action'),
                  userCount: 1,
                ),
              ),
            ],
            if (_bottomTab == 0) ...<Widget>[
              BlenderPopover(
                child: const BlenderButton(
                  key: ValueKey<String>('animation-playback-button'),
                  label: 'Playback',
                  variant: BlenderButtonVariant.topBar,
                ),
                popover: (context, close) => _buildAnimationPlaybackPopover(),
              ),
              BlenderPopover(
                child: BlenderIconButton(
                  key: const ValueKey<String>('animation-autokey-button'),
                  glyph: BlenderGlyph.keyframe,
                  selected: _animationAutoKeying,
                  tooltip: 'Auto Keying',
                  size: 24,
                ),
                popover: (context, close) => _buildAnimationAutoKeyingPopover(),
              ),
              BlenderPlaybackControls(
                playing: _playing,
                onFirst: () => _update(() => _frame = 1),
                onPrevious: () => _update(
                  () => _frame = (_frame - 1).clamp(1, 120).toDouble(),
                ),
                onPlay: () => _update(() => _playing = !_playing),
                onNext: () => _update(
                  () => _frame = (_frame + 1).clamp(1, 120).toDouble(),
                ),
                onLast: () => _update(() => _frame = 120),
                onRecord: () => _setStatus('Record toggled'),
              ),
              BlenderTimeJumpControls(
                key: const ValueKey<String>('animation-time-jump-controls'),
                onBackward: () => _update(
                  () => _frame = (_frame - 1).clamp(1, 120).toDouble(),
                ),
                onForward: () => _update(
                  () => _frame = (_frame + 1).clamp(1, 120).toDouble(),
                ),
                popover: (context, close) => _buildAnimationTimeJumpPopover(),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 110,
                child: BlenderNumberField(
                  value: _frame,
                  min: 1,
                  max: 120,
                  step: 1,
                  decimalDigits: 0,
                  onChanged: (value) => _update(() => _frame = value),
                ),
              ),
              BlenderPopover(
                child: BlenderIconButton(
                  key: const ValueKey<String>(
                    'animation-playhead-snapping-button',
                  ),
                  glyph: BlenderGlyph.snap,
                  selected: _animationPlayheadSnap,
                  tooltip: 'Playhead snapping',
                  size: 24,
                ),
                popover: (context, close) =>
                    _buildAnimationPlayheadSnappingPopover(),
              ),
            ],
            if (_bottomTab <= 1)
              BlenderPopover(
                child: BlenderIconButton(
                  key: const ValueKey<String>('animation-overlay-button'),
                  glyph: BlenderGlyph.overlay,
                  selected: _animationOverlays,
                  tooltip: 'Animation overlays',
                  size: 24,
                ),
                popover: (context, close) => _buildAnimationOverlayPopover(),
              ),
            const SizedBox(width: 6),
            AnimatedBuilder(
              animation: _application.status,
              builder: (context, _) =>
                  Text(_application.status.message?.text ?? 'Ready'),
            ),
          ],
        ),
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
        onNodeMoved: _moveNode,
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

  List<BlenderMenuItem<String>> _graphViewMenuItems({
    required bool drivers,
  }) => <BlenderMenuItem<String>>[
    const BlenderMenuItem<String>(
      value: 'Show Region UI',
      label: 'Show Region UI',
    ),
    const BlenderMenuItem<String>(
      value: 'Show Region HUD',
      label: 'Show Region HUD',
    ),
    const BlenderMenuItem<String>(
      value: 'Show Region Channels',
      label: 'Show Region Channels',
    ),
    if (!drivers)
      const BlenderMenuItem<String>(
        value: 'Playback Controls',
        label: 'Playback Controls',
      ),
    const BlenderMenuItem<String>(
      value: 'View Selected',
      label: 'View Selected',
    ),
    const BlenderMenuItem<String>(value: 'View All', label: 'View All'),
    const BlenderMenuItem<String>(value: 'Local View', label: 'Local View'),
    const BlenderMenuItem<String>(
      value: 'Frame Scene Range',
      label: 'Frame Scene Range',
    ),
    const BlenderMenuItem<String>(value: 'View Frame', label: 'View Frame'),
    const BlenderMenuItem<String>(
      value: 'Realtime Update',
      label: 'Realtime Update',
    ),
    const BlenderMenuItem<String>(value: 'Show Sliders', label: 'Show Sliders'),
    const BlenderMenuItem<String>(
      value: 'Auto Merge Keyframes',
      label: 'Auto Merge Keyframes',
    ),
    const BlenderMenuItem<String>(
      value: 'Auto Lock Translation Axis',
      label: 'Auto Lock Translation Axis',
    ),
    if (!drivers)
      const BlenderMenuItem<String>(
        value: 'Show Markers',
        label: 'Show Markers',
      ),
    const BlenderMenuItem<String>(value: 'Show Cursor', label: 'Show Cursor'),
    const BlenderMenuItem<String>(value: 'Show Seconds', label: 'Show Seconds'),
    const BlenderMenuItem<String>(
      value: 'Show Locked Time',
      label: 'Show Locked Time',
    ),
    const BlenderMenuItem<String>(
      value: 'Show Extrapolation',
      label: 'Show Extrapolation',
    ),
    const BlenderMenuItem<String>(value: 'Show Handles', label: 'Show Handles'),
    const BlenderMenuItem<String>(
      value: 'Only Selected Keyframe Handles',
      label: 'Only Selected Keyframe Handles',
    ),
    const BlenderMenuItem<String>(
      value: 'Set Preview Range',
      label: 'Set Preview Range',
    ),
    const BlenderMenuItem<String>(
      value: 'Clear Preview Range',
      label: 'Clear Preview Range',
    ),
    const BlenderMenuItem<String>(
      value: 'Toggle Dope Sheet',
      label: 'Toggle Dope Sheet',
    ),
    const BlenderMenuItem<String>(value: 'Area', label: 'Area'),
  ];

  List<BlenderMenuItem<String>> _graphSelectMenuItems() =>
      const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'All', label: 'All'),
        BlenderMenuItem<String>(value: 'None', label: 'None'),
        BlenderMenuItem<String>(value: 'Invert', label: 'Invert'),
        BlenderMenuItem<String>(
          value: 'Box Select (Include Handles)',
          label: 'Box Select (Include Handles)',
        ),
        BlenderMenuItem<String>(
          value: 'Box Select (Axis Range)',
          label: 'Box Select (Axis Range)',
        ),
        BlenderMenuItem<String>(value: 'Box Select', label: 'Box Select'),
        BlenderMenuItem<String>(value: 'Circle Select', label: 'Circle Select'),
        BlenderMenuItem<String>(value: 'Lasso Select', label: 'Lasso Select'),
        BlenderMenuItem<String>(value: 'More', label: 'More'),
        BlenderMenuItem<String>(value: 'Less', label: 'Less'),
        BlenderMenuItem<String>(value: 'Select Linked', label: 'Select Linked'),
        BlenderMenuItem<String>(
          value: 'Columns on Selected Keys',
          label: 'Columns on Selected Keys',
        ),
        BlenderMenuItem<String>(
          value: 'Column on Current Frame',
          label: 'Column on Current Frame',
        ),
        BlenderMenuItem<String>(
          value: 'Before Current Frame',
          label: 'Before Current Frame',
        ),
        BlenderMenuItem<String>(
          value: 'After Current Frame',
          label: 'After Current Frame',
        ),
        BlenderMenuItem<String>(
          value: 'Select Handles',
          label: 'Select Handles',
        ),
        BlenderMenuItem<String>(value: 'Select Key', label: 'Select Key'),
      ];

  List<BlenderMenuItem<String>> _graphChannelMenuItems({
    required bool drivers,
  }) => <BlenderMenuItem<String>>[
    const BlenderMenuItem<String>(
      value: 'Delete Channels',
      label: 'Delete Channels',
    ),
    if (drivers)
      const BlenderMenuItem<String>(
        value: 'Delete Invalid Drivers',
        label: 'Delete Invalid Drivers',
      ),
    const BlenderMenuItem<String>(
      value: 'Group Channels',
      label: 'Group Channels',
    ),
    const BlenderMenuItem<String>(
      value: 'Ungroup Channels',
      label: 'Ungroup Channels',
    ),
    const BlenderMenuItem<String>(
      value: 'Toggle Channel Setting',
      label: 'Toggle Channel Setting',
    ),
    const BlenderMenuItem<String>(
      value: 'Enable Channel Setting',
      label: 'Enable Channel Setting',
    ),
    const BlenderMenuItem<String>(
      value: 'Disable Channel Setting',
      label: 'Disable Channel Setting',
    ),
    const BlenderMenuItem<String>(
      value: 'Toggle Editable',
      label: 'Toggle Editable',
    ),
    const BlenderMenuItem<String>(
      value: 'Extrapolation Mode',
      label: 'Extrapolation Mode',
    ),
    const BlenderMenuItem<String>(
      value: 'Add F-Curve Modifier',
      label: 'Add F-Curve Modifier',
    ),
    const BlenderMenuItem<String>(
      value: 'Delete F-Curve Modifiers',
      label: 'Delete F-Curve Modifiers',
    ),
    const BlenderMenuItem<String>(
      value: 'Hide Selected Curves',
      label: 'Hide Selected Curves',
    ),
    const BlenderMenuItem<String>(
      value: 'Hide Unselected Curves',
      label: 'Hide Unselected Curves',
    ),
    const BlenderMenuItem<String>(value: 'Reveal', label: 'Reveal'),
    const BlenderMenuItem<String>(
      value: 'Expand Channels',
      label: 'Expand Channels',
    ),
    const BlenderMenuItem<String>(
      value: 'Collapse Channels',
      label: 'Collapse Channels',
    ),
    const BlenderMenuItem<String>(
      value: 'Move Channels',
      label: 'Move Channels',
    ),
    const BlenderMenuItem<String>(
      value: 'Keys to Samples',
      label: 'Keys to Samples',
    ),
    const BlenderMenuItem<String>(
      value: 'Samples to Keys',
      label: 'Samples to Keys',
    ),
    const BlenderMenuItem<String>(
      value: 'Sound to Samples',
      label: 'Sound to Samples',
    ),
    const BlenderMenuItem<String>(
      value: 'Bake Channels',
      label: 'Bake Channels',
    ),
    const BlenderMenuItem<String>(
      value: 'Discontinuity (Euler) Filter',
      label: 'Discontinuity (Euler) Filter',
    ),
    const BlenderMenuItem<String>(
      value: 'View Selected Channels',
      label: 'View Selected Channels',
    ),
  ];

  List<BlenderMenuItem<String>> _graphKeyMenuItems() =>
      const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Transform', label: 'Transform'),
        BlenderMenuItem<String>(value: 'Snap', label: 'Snap'),
        BlenderMenuItem<String>(value: 'Mirror', label: 'Mirror'),
        BlenderMenuItem<String>(
          value: 'Jump to Selected',
          label: 'Jump to Selected',
        ),
        BlenderMenuItem<String>(value: 'Copy', label: 'Copy'),
        BlenderMenuItem<String>(value: 'Paste', label: 'Paste'),
        BlenderMenuItem<String>(value: 'Paste Flipped', label: 'Paste Flipped'),
        BlenderMenuItem<String>(value: 'Insert', label: 'Insert'),
        BlenderMenuItem<String>(value: 'Duplicate', label: 'Duplicate'),
        BlenderMenuItem<String>(value: 'Handle Type', label: 'Handle Type'),
        BlenderMenuItem<String>(
          value: 'Interpolation Mode',
          label: 'Interpolation Mode',
        ),
        BlenderMenuItem<String>(value: 'Easing Type', label: 'Easing Type'),
        BlenderMenuItem<String>(value: 'Density', label: 'Density'),
        BlenderMenuItem<String>(value: 'Blend', label: 'Blend'),
        BlenderMenuItem<String>(value: 'Smooth', label: 'Smooth'),
        BlenderMenuItem<String>(value: 'Delete', label: 'Delete'),
      ];

  Widget _buildGraphFiltersPopover({required bool drivers}) {
    return BlenderPopoverPanel.settings('Filters', <Widget>[
      BlenderCheckbox(
        value: true,
        label: 'Only Selected',
        onChanged: (value) => _setStatus('Graph selected-only filter toggled'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Show Hidden',
        onChanged: (value) => _setStatus('Graph hidden filter toggled'),
      ),
      BlenderCheckbox(
        value: false,
        label: 'Only Errors',
        onChanged: (value) => _setStatus('Graph error filter toggled'),
      ),
      const BlenderSeparator(),
      const Text('Search Filters'),
      BlenderCheckbox(
        value: true,
        label: 'Multi-Word Match Search',
        onChanged: (value) => _setStatus('Graph search filter toggled'),
      ),
      if (drivers)
        BlenderCheckbox(
          value: false,
          label: 'Driver Fallback as Error',
          onChanged: (value) => _setStatus('Driver fallback filter toggled'),
        ),
    ]);
  }

  Widget _buildGraphSnappingPopover({required bool drivers}) {
    return BlenderPopoverPanel.settings('Snapping', <Widget>[
      const Text('Snap To'),
      BlenderDropdown<String>(
        value: drivers ? 'Absolute Time' : 'Frame',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
          BlenderMenuItem<String>(value: 'Second', label: 'Second'),
          BlenderMenuItem<String>(value: 'Marker', label: 'Marker'),
          BlenderMenuItem<String>(
            value: 'Absolute Time',
            label: 'Absolute Time',
          ),
        ],
        onChanged: (value) => _setStatus('Graph snap target $value'),
      ),
      if (drivers)
        BlenderCheckbox(
          value: false,
          label: 'Absolute Time',
          onChanged: (value) => _setStatus('Driver absolute snap toggled'),
        ),
    ]);
  }

  Widget _buildGraphProportionalPopover() {
    return BlenderPopoverPanel.settings('Proportional Editing', <Widget>[
      BlenderDropdown<String>(
        value: 'Connected',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Connected', label: 'Connected'),
          BlenderMenuItem<String>(value: 'Projected', label: 'Projected'),
        ],
        onChanged: (value) => _setStatus('Graph proportional falloff $value'),
      ),
      const SizedBox(height: 6),
      BlenderNumberField(
        value: 1,
        min: 0,
        max: 10,
        step: .1,
        label: 'Size',
        onChanged: (_) {},
      ),
    ]);
  }

  BlenderAreaHeader _buildGraphEditorHeader(BlenderEditorType type) {
    final drivers = type == BlenderEditorType.drivers;
    final menus = <String>[
      'View',
      'Select',
      if (!drivers) 'Marker',
      'Channel',
      'Key',
    ];
    final menuItems = <String, List<String>>{
      'View': _graphViewMenuItems(
        drivers: drivers,
      ).map((item) => item.label).toList(),
      'Select': _graphSelectMenuItems().map((item) => item.label).toList(),
      'Channel': _graphChannelMenuItems(
        drivers: drivers,
      ).map((item) => item.label).toList(),
      'Key': _graphKeyMenuItems().map((item) => item.label).toList(),
      if (!drivers)
        'Marker': _animationMarkerMenuItems()
            .map((item) => item.label)
            .toList(),
    };
    return BlenderAreaHeader(
      height: 30,
      editorType: type,
      showEditorLabel: false,
      onEditorTypeChanged: _mainEditorArea.select,
      actionsScrollable: true,
      menuDescriptors: _editorMenuDescriptors(menus, menuItems: menuItems),
      actions: <Widget>[
        BlenderIconButton(
          key: const ValueKey<String>('graph-normalize-button'),
          glyph: BlenderGlyph.scale,
          selected: _graphNormalize,
          onPressed: () => _update(() => _graphNormalize = !_graphNormalize),
          tooltip: 'Normalize F-Curves',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('graph-auto-normalize-button'),
          glyph: BlenderGlyph.refresh,
          selected: _graphAutoNormalize,
          onPressed: () =>
              _update(() => _graphAutoNormalize = !_graphAutoNormalize),
          tooltip: 'Auto Normalize',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('graph-ghost-curves-button'),
          glyph: BlenderGlyph.keyframe,
          selected: _graphGhostCurves,
          onPressed: () =>
              _update(() => _graphGhostCurves = !_graphGhostCurves),
          tooltip: _graphGhostCurves
              ? 'Clear Ghost Curves'
              : 'Create Ghost Curves',
        ),
        BlenderPopover(
          child: const BlenderIconButton(
            key: ValueKey<String>('graph-filters-button'),
            glyph: BlenderGlyph.filter,
            tooltip: 'Graph filters',
          ),
          popover: (context, close) =>
              _buildGraphFiltersPopover(drivers: drivers),
        ),
        const BlenderIconButton(
          key: ValueKey<String>('graph-pivot-button'),
          glyph: BlenderGlyph.transform,
          tooltip: 'Pivot Point',
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('graph-snapping-button'),
            glyph: BlenderGlyph.snap,
            selected: _graphSnap,
            tooltip: 'Graph snapping',
          ),
          popover: (context, close) =>
              _buildGraphSnappingPopover(drivers: drivers),
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('graph-proportional-button'),
            glyph: BlenderGlyph.transform,
            selected: _graphProportional,
            tooltip: 'Graph proportional editing',
          ),
          popover: (context, close) => _buildGraphProportionalPopover(),
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }
}
