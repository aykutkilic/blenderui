part of '../non3d_editors.dart';

/// Host-owned view and presentation state for the Sequencer header.
@immutable
class BlenderSequencerEditorHeaderState {
  const BlenderSequencerEditorHeaderState({
    this.viewType = 'Sequencer & Preview',
    this.displayMode = 'Image',
    this.previewChannels = 'All Channels',
    this.scene = 'Scene',
    this.overlapMode = 'Overwrite',
    this.snapping = false,
    this.snapTarget = 'Frame',
    this.gizmos = true,
    this.navigateGizmo = true,
    this.toolGizmos = true,
    this.overlays = true,
    this.grid = true,
    this.cache = true,
  });

  final String viewType;
  final String displayMode;
  final String previewChannels;
  final String scene;
  final String overlapMode;
  final bool snapping;
  final String snapTarget;
  final bool gizmos;
  final bool navigateGizmo;
  final bool toolGizmos;
  final bool overlays;
  final bool grid;
  final bool cache;

  BlenderSequencerEditorHeaderState copyWith({
    String? viewType,
    String? displayMode,
    String? previewChannels,
    String? scene,
    String? overlapMode,
    bool? snapping,
    String? snapTarget,
    bool? gizmos,
    bool? navigateGizmo,
    bool? toolGizmos,
    bool? overlays,
    bool? grid,
    bool? cache,
  }) => BlenderSequencerEditorHeaderState(
    viewType: viewType ?? this.viewType,
    displayMode: displayMode ?? this.displayMode,
    previewChannels: previewChannels ?? this.previewChannels,
    scene: scene ?? this.scene,
    overlapMode: overlapMode ?? this.overlapMode,
    snapping: snapping ?? this.snapping,
    snapTarget: snapTarget ?? this.snapTarget,
    gizmos: gizmos ?? this.gizmos,
    navigateGizmo: navigateGizmo ?? this.navigateGizmo,
    toolGizmos: toolGizmos ?? this.toolGizmos,
    overlays: overlays ?? this.overlays,
    grid: grid ?? this.grid,
    cache: cache ?? this.cache,
  );
}

/// Source-shaped header shared by Sequencer and Video Editing editor entries.
class BlenderSequencerEditorHeader extends StatelessWidget {
  const BlenderSequencerEditorHeader({
    super.key,
    required this.editorType,
    this.state = const BlenderSequencerEditorHeaderState(),
    this.onEditorTypeChanged,
    this.onStateChanged,
    this.onCommand,
    this.height = 30,
  }) : assert(
         editorType == BlenderEditorType.sequencer ||
             editorType == BlenderEditorType.videoEditing,
         'BlenderSequencerEditorHeader supports Sequencer and Video Editing.',
       );

  final BlenderEditorType editorType;
  final BlenderSequencerEditorHeaderState state;
  final ValueChanged<BlenderEditorType>? onEditorTypeChanged;
  final ValueChanged<BlenderSequencerEditorHeaderState>? onStateChanged;
  final ValueChanged<String>? onCommand;
  final double height;

  bool get _sequencerView => state.viewType != 'Preview';
  bool get _preview => state.viewType != 'Sequencer';
  void _update(BlenderSequencerEditorHeaderState value) =>
      onStateChanged?.call(value);

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      'View',
      'Select',
      if (_sequencerView) 'Marker',
      if (_sequencerView) 'Add',
      'Strip',
      if (_preview) 'Image',
    ];
    return BlenderAreaHeader(
      height: height,
      editorType: editorType,
      showEditorLabel: false,
      onEditorTypeChanged: onEditorTypeChanged,
      actionsScrollable: true,
      leading: <Widget>[
        SizedBox(
          width: 132,
          child: BlenderDropdown<String>(
            key: const ValueKey<String>('sequencer-view-type'),
            value: state.viewType,
            compact: true,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Sequencer', label: 'Sequencer'),
              BlenderMenuItem<String>(value: 'Preview', label: 'Preview'),
              BlenderMenuItem<String>(
                value: 'Sequencer & Preview',
                label: 'Sequencer & Preview',
              ),
            ],
            onChanged: (value) => _update(state.copyWith(viewType: value)),
          ),
        ),
      ],
      menuDescriptors: BlenderEditorMenuCatalog.build(
        labels,
        menuItems: _menuItems,
        onSelected: onCommand,
      ),
      actions: <Widget>[
        if (_sequencerView) ..._sequencerControls(),
        ..._snappingControls(context),
        if (_preview) ..._previewControls(context),
        ..._overlayControls(context),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }

  List<Widget> _sequencerControls() => <Widget>[
    SizedBox(
      width: 92,
      child: BlenderDropdown<String>(
        key: const ValueKey<String>('sequencer-scene-selector'),
        value: state.scene,
        compact: true,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Scene', label: 'Scene'),
          BlenderMenuItem<String>(
            value: 'Preview Scene',
            label: 'Preview Scene',
          ),
        ],
        onChanged: (value) => _update(state.copyWith(scene: value)),
      ),
    ),
    SizedBox(
      width: 92,
      child: BlenderDropdown<String>(
        key: const ValueKey<String>('sequencer-overlap-mode'),
        value: state.overlapMode,
        compact: true,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Overwrite', label: 'Overwrite'),
          BlenderMenuItem<String>(value: 'Expand', label: 'Expand'),
          BlenderMenuItem<String>(value: 'Shuffle', label: 'Shuffle'),
        ],
        onChanged: (value) => _update(state.copyWith(overlapMode: value)),
      ),
    ),
  ];

  List<Widget> _snappingControls(BuildContext context) => <Widget>[
    BlenderIconButton(
      key: const ValueKey<String>('sequencer-snapping-toggle-button'),
      glyph: BlenderGlyph.snap,
      selected: state.snapping,
      onPressed: () => _update(state.copyWith(snapping: !state.snapping)),
      tooltip: 'Toggle Sequencer snapping',
    ),
    BlenderPopover(
      child: BlenderIconButton(
        key: const ValueKey<String>('sequencer-snapping-button'),
        glyph: BlenderGlyph.chevronDown,
        selected: state.snapping,
        tooltip: 'Sequencer snapping settings',
      ),
      popover: (context, close) =>
          BlenderPopoverPanel.settings('Snapping', <Widget>[
            Text('Snap To', style: BlenderTheme.of(context).textTheme.caption),
            BlenderSegmentedControl<String>(
              value: state.snapTarget,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
                BlenderMenuItem<String>(value: 'Second', label: 'Second'),
                BlenderMenuItem<String>(value: 'Marker', label: 'Marker'),
              ],
              onChanged: (value) => _update(state.copyWith(snapTarget: value)),
            ),
            BlenderCheckbox(
              value: state.snapping,
              label: 'Use Snapping',
              onChanged: (value) => _update(state.copyWith(snapping: value)),
            ),
          ]),
    ),
  ];

  List<Widget> _previewControls(BuildContext context) => <Widget>[
    SizedBox(
      width: 72,
      child: BlenderDropdown<String>(
        key: const ValueKey<String>('sequencer-display-mode'),
        value: state.displayMode,
        compact: true,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Image', label: 'Image'),
          BlenderMenuItem<String>(value: 'Waveform', label: 'Waveform'),
        ],
        onChanged: (value) => _update(state.copyWith(displayMode: value)),
      ),
    ),
    SizedBox(
      width: 72,
      child: BlenderDropdown<String>(
        key: const ValueKey<String>('sequencer-preview-channels'),
        value: state.previewChannels,
        compact: true,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'All Channels', label: 'All Channels'),
          BlenderMenuItem<String>(value: 'RGB', label: 'RGB'),
          BlenderMenuItem<String>(value: 'Alpha', label: 'Alpha'),
        ],
        onChanged: (value) => _update(state.copyWith(previewChannels: value)),
      ),
    ),
    BlenderIconButton(
      key: const ValueKey<String>('sequencer-gizmo-toggle-button'),
      glyph: BlenderGlyph.gizmo,
      selected: state.gizmos,
      onPressed: () => _update(state.copyWith(gizmos: !state.gizmos)),
      tooltip: 'Toggle Sequencer gizmos',
    ),
    BlenderPopover(
      child: BlenderIconButton(
        key: const ValueKey<String>('sequencer-gizmo-button'),
        glyph: BlenderGlyph.chevronDown,
        selected: state.gizmos,
        tooltip: 'Sequencer gizmo settings',
      ),
      popover: (context, close) =>
          BlenderPopoverPanel.settings('Gizmos', <Widget>[
            BlenderCheckbox(
              value: state.gizmos,
              label: 'Show Gizmos',
              onChanged: (value) => _update(state.copyWith(gizmos: value)),
            ),
            BlenderCheckbox(
              value: state.navigateGizmo,
              label: 'Navigate',
              onChanged: (value) =>
                  _update(state.copyWith(navigateGizmo: value)),
            ),
            BlenderCheckbox(
              value: state.toolGizmos,
              label: 'Active Tools',
              onChanged: (value) => _update(state.copyWith(toolGizmos: value)),
            ),
          ]),
    ),
  ];

  List<Widget> _overlayControls(BuildContext context) => <Widget>[
    BlenderIconButton(
      key: const ValueKey<String>('sequencer-overlay-toggle-button'),
      glyph: BlenderGlyph.overlay,
      selected: state.overlays,
      onPressed: () => _update(state.copyWith(overlays: !state.overlays)),
      tooltip: 'Toggle Sequencer overlays',
    ),
    BlenderPopover(
      child: BlenderIconButton(
        key: const ValueKey<String>('sequencer-overlay-button'),
        glyph: BlenderGlyph.chevronDown,
        selected: state.overlays,
        tooltip: 'Sequencer overlay settings',
      ),
      popover: (context, close) =>
          BlenderPopoverPanel.settings('Overlays', <Widget>[
            BlenderCheckbox(
              value: state.overlays,
              label: 'Show Overlays',
              onChanged: (value) => _update(state.copyWith(overlays: value)),
            ),
            BlenderCheckbox(
              value: state.grid,
              label: 'Grid',
              onChanged: (value) => _update(state.copyWith(grid: value)),
            ),
            BlenderCheckbox(
              value: state.cache,
              label: 'Cache',
              onChanged: (value) => _update(state.copyWith(cache: value)),
            ),
            const BlenderSeparator(),
            Text('Strips', style: BlenderTheme.of(context).textTheme.caption),
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
                onChanged: (_) => onCommand?.call('$label overlay'),
              ),
            const BlenderSeparator(),
            Text(
              'Preview Overlays',
              style: BlenderTheme.of(context).textTheme.caption,
            ),
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
                onChanged: (_) => onCommand?.call('$label overlay'),
              ),
          ]),
    ),
  ];
}
