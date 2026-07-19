part of '../showcase_app.dart';

extension _ShowcaseAnimationSequencerHeaders on _ShowcaseAppState {
  BlenderAreaHeader _buildAnimationEditorHeader(BlenderEditorType type) {
    final timeline = type == BlenderEditorType.timeline;
    final menuLabels = timeline
        ? const <String>['View', 'Marker']
        : const <String>[
            'View',
            'Select',
            'Marker',
            'Channel',
            'Key',
            'Action',
          ];
    final menuItems = <String, List<String>>{
      'View': _animationViewMenuItems(
        timeline: timeline,
      ).map((item) => item.label).toList(),
      'Marker': _animationMarkerMenuItems().map((item) => item.label).toList(),
      if (!timeline) ...<String, List<String>>{
        'Select': _animationSelectMenuItems()
            .map((item) => item.label)
            .toList(),
        'Channel': _animationChannelMenuItems()
            .map((item) => item.label)
            .toList(),
        'Key': _animationKeyMenuItems().map((item) => item.label).toList(),
        'Action': _animationActionMenuItems()
            .map((item) => item.label)
            .toList(),
      },
    };
    return BlenderAreaHeader(
      height: 30,
      editorType: type,
      showEditorLabel: false,
      onEditorTypeChanged: _mainEditorArea.select,
      actionsScrollable: true,
      leading: <Widget>[
        if (!timeline)
          SizedBox(
            width: 220,
            child: BlenderActionSelector<String>(
              key: const ValueKey<String>('main-animation-action-selector'),
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
      menuDescriptors: _editorMenuDescriptors(menuLabels, menuItems: menuItems),
      actions: <Widget>[
        if (timeline) ...<Widget>[
          BlenderPopover(
            child: const BlenderButton(
              key: ValueKey<String>('main-animation-playback-button'),
              label: 'Playback',
              variant: BlenderButtonVariant.topBar,
            ),
            popover: (context, close) => _buildAnimationPlaybackPopover(),
          ),
          BlenderPopover(
            child: BlenderIconButton(
              key: const ValueKey<String>('main-animation-autokey-button'),
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
            onPrevious: () =>
                _update(() => _frame = (_frame - 1).clamp(1, 120).toDouble()),
            onPlay: () => _update(() => _playing = !_playing),
            onNext: () =>
                _update(() => _frame = (_frame + 1).clamp(1, 120).toDouble()),
            onLast: () => _update(() => _frame = 120),
            onRecord: () => _setStatus('Record toggled'),
          ),
          BlenderTimeJumpControls(
            key: const ValueKey<String>('main-animation-time-jump-controls'),
            onBackward: () =>
                _update(() => _frame = (_frame - 1).clamp(1, 120).toDouble()),
            onForward: () =>
                _update(() => _frame = (_frame + 1).clamp(1, 120).toDouble()),
            popover: (context, close) => _buildAnimationTimeJumpPopover(),
          ),
          SizedBox(
            width: 92,
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
              key: const ValueKey<String>('main-animation-playhead-snap'),
              glyph: BlenderGlyph.snap,
              selected: _animationPlayheadSnap,
              tooltip: 'Playhead snapping',
              size: 24,
            ),
            popover: (context, close) =>
                _buildAnimationPlayheadSnappingPopover(),
          ),
        ] else ...<Widget>[
          BlenderPopover(
            child: const BlenderIconButton(
              key: ValueKey<String>('main-animation-filters-button'),
              glyph: BlenderGlyph.filter,
              tooltip: 'Animation filters',
              size: 24,
            ),
            popover: (context, close) => _buildAnimationFiltersPopover(),
          ),
          BlenderPopover(
            child: BlenderIconButton(
              key: const ValueKey<String>('main-animation-snapping-button'),
              glyph: BlenderGlyph.snap,
              selected: _animationPlayheadSnap,
              tooltip: 'Animation snapping',
              size: 24,
            ),
            popover: (context, close) => _buildAnimationSnappingPopover(),
          ),
          BlenderPopover(
            child: BlenderIconButton(
              key: const ValueKey<String>('main-animation-proportional-button'),
              glyph: BlenderGlyph.transform,
              selected: _animationProportional,
              tooltip: 'Proportional editing',
              size: 24,
            ),
            popover: (context, close) => _buildProportionalEditingPopover(),
          ),
        ],
        BlenderPopover(
          child: BlenderIconButton(
            key: ValueKey<String>(
              timeline
                  ? 'main-animation-overlay-button'
                  : 'main-animation-dope-overlay-button',
            ),
            glyph: BlenderGlyph.overlay,
            selected: _animationOverlays,
            tooltip: 'Animation overlays',
            size: 24,
          ),
          popover: (context, close) => _buildAnimationOverlayPopover(),
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }

  List<BlenderMenuItem<String>> _sequencerViewMenuItems({
    required bool sequencerView,
    required bool preview,
  }) => <BlenderMenuItem<String>>[
    const BlenderMenuItem<String>(
      value: 'Show Region Toolbar',
      label: 'Show Region Toolbar',
    ),
    const BlenderMenuItem<String>(
      value: 'Show Region UI',
      label: 'Show Region UI',
    ),
    const BlenderMenuItem<String>(
      value: 'Show Tool Header',
      label: 'Show Tool Header',
    ),
    if (sequencerView)
      const BlenderMenuItem<String>(
        value: 'Show Region HUD',
        label: 'Show Region HUD',
      ),
    if (sequencerView)
      const BlenderMenuItem<String>(
        value: 'Show Region Channels',
        label: 'Show Region Channels',
      ),
    const BlenderMenuItem<String>(
      value: 'Playback Controls',
      label: 'Playback Controls',
    ),
    if (preview)
      const BlenderMenuItem<String>(
        value: 'Preview During Transform',
        label: 'Preview During Transform',
      ),
    const BlenderMenuItem<String>(value: 'Refresh All', label: 'Refresh All'),
    const BlenderMenuItem<String>(
      value: 'Frame Selected',
      label: 'Frame Selected',
    ),
    if (sequencerView) ...<BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(value: 'View All', label: 'View All'),
      const BlenderMenuItem<String>(
        value: 'Frame Preview Range',
        label: 'Frame Preview Range',
      ),
      const BlenderMenuItem<String>(value: 'View Frame', label: 'View Frame'),
      const BlenderMenuItem<String>(value: 'Clamp View', label: 'Clamp View'),
    ],
    if (preview) ...<BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(
        value: 'Fit Preview in Window',
        label: 'Fit Preview in Window',
      ),
      const BlenderMenuItem<String>(
        value: 'Preview Zoom',
        label: 'Preview Zoom',
      ),
      const BlenderMenuItem<String>(value: 'Auto Zoom', label: 'Auto Zoom'),
      const BlenderMenuItem<String>(value: 'Proxy', label: 'Proxy'),
    ],
    const BlenderMenuItem<String>(value: 'Show Seconds', label: 'Show Seconds'),
    if (sequencerView) ...<BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(
        value: 'Show Markers',
        label: 'Show Markers',
      ),
      const BlenderMenuItem<String>(
        value: 'Show Locked Time',
        label: 'Show Locked Time',
      ),
      const BlenderMenuItem<String>(value: 'Navigation', label: 'Navigation'),
      const BlenderMenuItem<String>(value: 'Range', label: 'Range'),
    ],
    const BlenderMenuItem<String>(
      value: 'Render Still Preview',
      label: 'Render Still Preview',
    ),
    const BlenderMenuItem<String>(
      value: 'Render Sequence Preview',
      label: 'Render Sequence Preview',
    ),
    const BlenderMenuItem<String>(
      value: 'Export Subtitles',
      label: 'Export Subtitles',
    ),
    const BlenderMenuItem<String>(
      value: 'Toggle Sequencer/Preview',
      label: 'Toggle Sequencer/Preview',
    ),
    const BlenderMenuItem<String>(value: 'Area', label: 'Area'),
  ];

  List<BlenderMenuItem<String>> _sequencerSelectMenuItems({
    required bool sequencerView,
    required bool preview,
  }) => <BlenderMenuItem<String>>[
    const BlenderMenuItem<String>(value: 'All', label: 'All'),
    const BlenderMenuItem<String>(value: 'None', label: 'None'),
    const BlenderMenuItem<String>(value: 'Invert', label: 'Invert'),
    const BlenderMenuItem<String>(value: 'Box Select', label: 'Box Select'),
    if (sequencerView)
      const BlenderMenuItem<String>(
        value: 'Box Select (Include Handles)',
        label: 'Box Select (Include Handles)',
      ),
    if (sequencerView) ...<BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(value: 'More', label: 'More'),
      const BlenderMenuItem<String>(value: 'Less', label: 'Less'),
    ],
    const BlenderMenuItem<String>(
      value: 'Select All by Type',
      label: 'Select All by Type',
    ),
    const BlenderMenuItem<String>(
      value: 'Select Grouped',
      label: 'Select Grouped',
    ),
    if (sequencerView) ...<BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(
        value: 'Select Linked',
        label: 'Select Linked',
      ),
      const BlenderMenuItem<String>(
        value: 'Side of Frame',
        label: 'Side of Frame',
      ),
      const BlenderMenuItem<String>(value: 'Handle', label: 'Handle'),
      const BlenderMenuItem<String>(value: 'Channel', label: 'Channel'),
    ],
  ];

  List<BlenderMenuItem<String>> _sequencerAddMenuItems() =>
      const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Search...', label: 'Search...'),
        BlenderMenuItem<String>(value: 'Scene', label: 'Scene'),
        BlenderMenuItem<String>(value: 'Clip', label: 'Clip'),
        BlenderMenuItem<String>(value: 'Mask', label: 'Mask'),
        BlenderMenuItem<String>(value: 'Movie...', label: 'Movie...'),
        BlenderMenuItem<String>(value: 'Sound...', label: 'Sound...'),
        BlenderMenuItem<String>(
          value: 'Image/Sequence...',
          label: 'Image/Sequence...',
        ),
        BlenderMenuItem<String>(value: 'Color', label: 'Color'),
        BlenderMenuItem<String>(value: 'Text', label: 'Text'),
        BlenderMenuItem<String>(
          value: 'Adjustment Layer',
          label: 'Adjustment Layer',
        ),
        BlenderMenuItem<String>(value: 'Compositor', label: 'Compositor'),
        BlenderMenuItem<String>(value: 'Scene Strip', label: 'Scene Strip'),
        BlenderMenuItem<String>(value: 'Transition', label: 'Transition'),
        BlenderMenuItem<String>(value: 'Wipe', label: 'Wipe'),
        BlenderMenuItem<String>(value: 'Glow', label: 'Glow'),
        BlenderMenuItem<String>(value: 'Transform', label: 'Transform'),
        BlenderMenuItem<String>(value: 'Speed', label: 'Speed'),
      ];

  List<BlenderMenuItem<String>> _sequencerStripMenuItems({
    required bool sequencerView,
    required bool preview,
  }) => <BlenderMenuItem<String>>[
    const BlenderMenuItem<String>(value: 'Transform', label: 'Transform'),
    if (preview) ...<BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(value: 'Mirror', label: 'Mirror'),
      const BlenderMenuItem<String>(value: 'Copy', label: 'Copy'),
      const BlenderMenuItem<String>(value: 'Paste', label: 'Paste'),
      const BlenderMenuItem<String>(value: 'Duplicate', label: 'Duplicate'),
      const BlenderMenuItem<String>(value: 'Animation', label: 'Animation'),
      const BlenderMenuItem<String>(value: 'Show/Hide', label: 'Show/Hide'),
      const BlenderMenuItem<String>(value: 'Text', label: 'Text'),
    ],
    if (sequencerView) ...<BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(value: 'Retiming', label: 'Retiming'),
      const BlenderMenuItem<String>(value: 'Split', label: 'Split'),
      const BlenderMenuItem<String>(value: 'Hold Split', label: 'Hold Split'),
      const BlenderMenuItem<String>(
        value: 'Duplicate Linked',
        label: 'Duplicate Linked',
      ),
      const BlenderMenuItem<String>(value: 'Modifiers', label: 'Modifiers'),
      const BlenderMenuItem<String>(value: 'Meta', label: 'Meta'),
      const BlenderMenuItem<String>(value: 'Color Tag', label: 'Color Tag'),
      const BlenderMenuItem<String>(value: 'Lock/Mute', label: 'Lock/Mute'),
      const BlenderMenuItem<String>(value: 'Connect', label: 'Connect'),
      const BlenderMenuItem<String>(value: 'Input', label: 'Input'),
    ],
    const BlenderMenuItem<String>(
      value: 'Ripple Delete',
      label: 'Ripple Delete',
    ),
    const BlenderMenuItem<String>(value: 'Delete', label: 'Delete'),
  ];

  List<BlenderMenuItem<String>> _sequencerImageMenuItems() =>
      const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Transform', label: 'Transform'),
        BlenderMenuItem<String>(value: 'Clear', label: 'Clear'),
        BlenderMenuItem<String>(value: 'Apply', label: 'Apply'),
        BlenderMenuItem<String>(value: 'Scale To Fit', label: 'Scale To Fit'),
        BlenderMenuItem<String>(value: 'Scale to Fill', label: 'Scale to Fill'),
        BlenderMenuItem<String>(
          value: 'Stretch To Fill',
          label: 'Stretch To Fill',
        ),
      ];

  Widget _buildSequencerSnappingPopover() {
    return BlenderPopoverPanel.settings('Snapping', <Widget>[
      const Text('Snap To'),
      BlenderSegmentedControl<String>(
        value: 'Frame',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
          BlenderMenuItem<String>(value: 'Second', label: 'Second'),
          BlenderMenuItem<String>(value: 'Marker', label: 'Marker'),
        ],
        onChanged: (value) => _setStatus('Sequencer snap target $value'),
      ),
      BlenderCheckbox(
        value: _sequencerSnap,
        label: 'Use Snapping',
        onChanged: (value) => _update(() => _sequencerSnap = value),
      ),
    ]);
  }

  Widget _buildSequencerGizmoPopover() {
    return BlenderPopoverPanel.settings('Gizmos', <Widget>[
      BlenderCheckbox(
        value: _sequencerGizmos,
        label: 'Show Gizmos',
        onChanged: (value) => _update(() => _sequencerGizmos = value),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Navigate',
        onChanged: (value) => _setStatus('Sequencer navigate gizmo toggled'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Active Tools',
        onChanged: (value) => _setStatus('Sequencer tool gizmo toggled'),
      ),
    ]);
  }

  Widget _buildSequencerOverlayPopover() {
    return BlenderPopoverPanel.settings('Overlays', <Widget>[
      BlenderCheckbox(
        value: _sequencerOverlays,
        label: 'Show Overlays',
        onChanged: (value) => _update(() => _sequencerOverlays = value),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Grid',
        onChanged: (value) => _setStatus('Sequencer grid toggled'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Cache',
        onChanged: (value) => _setStatus('Sequencer cache overlay toggled'),
      ),
      const BlenderSeparator(),
      const Text('Strips'),
      for (final label in const <String>[
        'Name',
        'Source',
        'Duration',
        'Animation Curves',
        'Color Tags',
        'Offsets',
        'Retiming',
      ])
        BlenderCheckbox(
          value: true,
          label: label,
          onChanged: (value) => _setStatus('$label overlay toggled'),
        ),
      const BlenderSeparator(),
      const Text('Preview Overlays'),
      for (final label in const <String>[
        'Frame Overlay',
        'Metadata',
        'Annotations',
        'Cursor',
        'Safe Areas',
        'Guides',
      ])
        BlenderCheckbox(
          value: true,
          label: label,
          onChanged: (value) => _setStatus('$label preview overlay toggled'),
        ),
    ]);
  }

  BlenderAreaHeader _buildSequencerEditorHeader(BlenderEditorType type) {
    final sequencerView = _sequencerViewType != 'Preview';
    final preview = _sequencerViewType != 'Sequencer';
    final menus = <String>[
      'View',
      'Select',
      if (sequencerView) 'Marker',
      if (sequencerView) 'Add',
      'Strip',
      if (preview) 'Image',
    ];
    final menuItems = <String, List<String>>{
      'View': _sequencerViewMenuItems(
        sequencerView: sequencerView,
        preview: preview,
      ).map((item) => item.label).toList(),
      'Select': _sequencerSelectMenuItems(
        sequencerView: sequencerView,
        preview: preview,
      ).map((item) => item.label).toList(),
      'Marker': _animationMarkerMenuItems().map((item) => item.label).toList(),
      'Add': _sequencerAddMenuItems().map((item) => item.label).toList(),
      'Strip': _sequencerStripMenuItems(
        sequencerView: sequencerView,
        preview: preview,
      ).map((item) => item.label).toList(),
      'Image': _sequencerImageMenuItems().map((item) => item.label).toList(),
    };
    return BlenderAreaHeader(
      height: 30,
      editorType: type,
      showEditorLabel: false,
      onEditorTypeChanged: _mainEditorArea.select,
      actionsScrollable: true,
      leading: <Widget>[
        SizedBox(
          width: 132,
          child: BlenderDropdown<String>(
            key: const ValueKey<String>('sequencer-view-type'),
            value: _sequencerViewType,
            compact: true,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Sequencer', label: 'Sequencer'),
              BlenderMenuItem<String>(value: 'Preview', label: 'Preview'),
              BlenderMenuItem<String>(
                value: 'Sequencer & Preview',
                label: 'Sequencer & Preview',
              ),
            ],
            onChanged: (value) => _update(() => _sequencerViewType = value),
          ),
        ),
      ],
      menuDescriptors: _editorMenuDescriptors(menus, menuItems: menuItems),
      actions: <Widget>[
        if (sequencerView)
          SizedBox(
            width: 92,
            child: BlenderDropdown<String>(
              key: const ValueKey<String>('sequencer-scene-selector'),
              value: 'Scene',
              compact: true,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'Scene', label: 'Scene'),
                BlenderMenuItem<String>(
                  value: 'Preview Scene',
                  label: 'Preview Scene',
                ),
              ],
              onChanged: (value) => _setStatus('Sequencer scene $value'),
            ),
          ),
        if (sequencerView)
          SizedBox(
            width: 92,
            child: BlenderDropdown<String>(
              key: const ValueKey<String>('sequencer-overlap-mode'),
              value: _sequencerOverlapMode,
              compact: true,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'Overwrite', label: 'Overwrite'),
                BlenderMenuItem<String>(value: 'Expand', label: 'Expand'),
                BlenderMenuItem<String>(value: 'Shuffle', label: 'Shuffle'),
              ],
              onChanged: (value) =>
                  _update(() => _sequencerOverlapMode = value),
            ),
          ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('sequencer-snapping-button'),
            glyph: BlenderGlyph.snap,
            selected: _sequencerSnap,
            tooltip: 'Sequencer snapping',
          ),
          popover: (context, close) => _buildSequencerSnappingPopover(),
        ),
        if (preview) ...<Widget>[
          SizedBox(
            width: 72,
            child: BlenderDropdown<String>(
              key: const ValueKey<String>('sequencer-display-mode'),
              value: _sequencerDisplayMode,
              compact: true,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'Image', label: 'Image'),
                BlenderMenuItem<String>(value: 'Waveform', label: 'Waveform'),
              ],
              onChanged: (value) =>
                  _update(() => _sequencerDisplayMode = value),
            ),
          ),
          const SizedBox(
            width: 72,
            child: BlenderDropdown<String>(
              key: ValueKey<String>('sequencer-preview-channels'),
              value: 'All Channels',
              compact: true,
              items: <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'All Channels',
                  label: 'All Channels',
                ),
                BlenderMenuItem<String>(value: 'RGB', label: 'RGB'),
                BlenderMenuItem<String>(value: 'Alpha', label: 'Alpha'),
              ],
              onChanged: null,
            ),
          ),
          BlenderPopover(
            child: BlenderIconButton(
              key: const ValueKey<String>('sequencer-gizmo-button'),
              glyph: BlenderGlyph.gizmo,
              selected: _sequencerGizmos,
              tooltip: 'Sequencer gizmos',
            ),
            popover: (context, close) => _buildSequencerGizmoPopover(),
          ),
        ],
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('sequencer-overlay-button'),
            glyph: BlenderGlyph.overlay,
            selected: _sequencerOverlays,
            tooltip: 'Sequencer overlays',
          ),
          popover: (context, close) => _buildSequencerOverlayPopover(),
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }
}
