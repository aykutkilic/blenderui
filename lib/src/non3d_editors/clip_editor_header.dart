part of '../non3d_editors.dart';

/// Host-owned mode and presentation state for the Movie Clip Editor header.
@immutable
class BlenderClipEditorHeaderState {
  const BlenderClipEditorHeaderState({
    this.mode = 'Tracking',
    this.view = 'Clip',
    this.proportionalEditing = false,
    this.lockSelection = false,
    this.gizmos = true,
    this.navigateGizmo = true,
    this.toolGizmos = true,
    this.overlays = true,
    this.show3dMarkers = true,
    this.showGrid = true,
    this.showAnnotations = true,
    this.showNames = false,
  });

  final String mode;
  final String view;
  final bool proportionalEditing;
  final bool lockSelection;
  final bool gizmos;
  final bool navigateGizmo;
  final bool toolGizmos;
  final bool overlays;
  final bool show3dMarkers;
  final bool showGrid;
  final bool showAnnotations;
  final bool showNames;

  BlenderClipEditorHeaderState copyWith({
    String? mode,
    String? view,
    bool? proportionalEditing,
    bool? lockSelection,
    bool? gizmos,
    bool? navigateGizmo,
    bool? toolGizmos,
    bool? overlays,
    bool? show3dMarkers,
    bool? showGrid,
    bool? showAnnotations,
    bool? showNames,
  }) => BlenderClipEditorHeaderState(
    mode: mode ?? this.mode,
    view: view ?? this.view,
    proportionalEditing: proportionalEditing ?? this.proportionalEditing,
    lockSelection: lockSelection ?? this.lockSelection,
    gizmos: gizmos ?? this.gizmos,
    navigateGizmo: navigateGizmo ?? this.navigateGizmo,
    toolGizmos: toolGizmos ?? this.toolGizmos,
    overlays: overlays ?? this.overlays,
    show3dMarkers: show3dMarkers ?? this.show3dMarkers,
    showGrid: showGrid ?? this.showGrid,
    showAnnotations: showAnnotations ?? this.showAnnotations,
    showNames: showNames ?? this.showNames,
  );
}

/// Source-shaped Movie Clip Editor header for Tracking and Mask modes.
class BlenderClipEditorHeader extends StatelessWidget {
  const BlenderClipEditorHeader({
    super.key,
    this.state = const BlenderClipEditorHeaderState(),
    this.onEditorTypeChanged,
    this.onStateChanged,
    this.onCommand,
    this.height = 30,
  });

  final BlenderClipEditorHeaderState state;
  final ValueChanged<BlenderEditorType>? onEditorTypeChanged;
  final ValueChanged<BlenderClipEditorHeaderState>? onStateChanged;
  final ValueChanged<String>? onCommand;
  final double height;

  bool get _masking => state.mode == 'Mask';
  bool get _graph => state.view == 'Graph';
  void _update(BlenderClipEditorHeaderState value) =>
      onStateChanged?.call(value);

  @override
  Widget build(BuildContext context) {
    final labels = _masking
        ? const <String>['View', 'Select', 'Clip', 'Add', 'Mask']
        : _graph
        ? const <String>['View', 'Select']
        : const <String>['View', 'Select', 'Clip', 'Track', 'Reconstruction'];
    return BlenderAreaHeader(
      height: height,
      editorType: BlenderEditorType.clipEditor,
      showEditorLabel: false,
      onEditorTypeChanged: onEditorTypeChanged,
      actionsScrollable: true,
      leading: <Widget>[
        SizedBox(
          width: 82,
          child: BlenderDropdown<String>(
            key: const ValueKey<String>('clip-mode-selector'),
            value: state.mode,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Tracking', label: 'Tracking'),
              BlenderMenuItem<String>(value: 'Mask', label: 'Mask'),
            ],
            onChanged: (value) => _update(state.copyWith(mode: value)),
          ),
        ),
        if (!_masking)
          SizedBox(
            width: 82,
            child: BlenderDropdown<String>(
              key: const ValueKey<String>('clip-view-selector'),
              value: state.view,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'Clip', label: 'Clip'),
                BlenderMenuItem<String>(value: 'Graph', label: 'Graph'),
                BlenderMenuItem<String>(
                  value: 'Dope Sheet',
                  label: 'Dope Sheet',
                ),
              ],
              onChanged: (value) => _update(state.copyWith(view: value)),
            ),
          ),
      ],
      menuDescriptors: BlenderEditorMenuCatalog.build(
        labels,
        menuItems: _menuItems,
        onSelected: onCommand,
      ),
      actions: <Widget>[
        if (_masking)
          BlenderIconButton(
            key: const ValueKey<String>('clip-proportional-button'),
            glyph: BlenderGlyph.transform,
            selected: state.proportionalEditing,
            onPressed: () => _update(
              state.copyWith(proportionalEditing: !state.proportionalEditing),
            ),
            tooltip: 'Proportional editing',
          ),
        BlenderIconButton(
          key: const ValueKey<String>('clip-lock-button'),
          glyph: BlenderGlyph.lock,
          selected: state.lockSelection,
          onPressed: () =>
              _update(state.copyWith(lockSelection: !state.lockSelection)),
          tooltip: 'Lock selection',
        ),
        ..._gizmoControls(context),
        ..._overlayControls(context),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }

  List<Widget> _gizmoControls(BuildContext context) => <Widget>[
    BlenderIconButton(
      key: const ValueKey<String>('clip-gizmo-toggle-button'),
      glyph: BlenderGlyph.gizmo,
      selected: state.gizmos,
      onPressed: () => _update(state.copyWith(gizmos: !state.gizmos)),
      tooltip: 'Toggle clip gizmos',
    ),
    BlenderPopover(
      child: BlenderIconButton(
        key: const ValueKey<String>('clip-gizmo-button'),
        glyph: BlenderGlyph.chevronDown,
        selected: state.gizmos,
        tooltip: 'Clip gizmo settings',
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
              label: 'Navigate Gizmo',
              onChanged: (value) =>
                  _update(state.copyWith(navigateGizmo: value)),
            ),
            BlenderCheckbox(
              value: state.toolGizmos,
              label: 'Tool Gizmos',
              onChanged: (value) => _update(state.copyWith(toolGizmos: value)),
            ),
          ]),
    ),
  ];

  List<Widget> _overlayControls(BuildContext context) => <Widget>[
    BlenderIconButton(
      key: const ValueKey<String>('clip-overlay-toggle-button'),
      glyph: BlenderGlyph.overlay,
      selected: state.overlays,
      onPressed: () => _update(state.copyWith(overlays: !state.overlays)),
      tooltip: 'Toggle clip overlays',
    ),
    BlenderPopover(
      child: BlenderIconButton(
        key: const ValueKey<String>('clip-overlay-button'),
        glyph: BlenderGlyph.chevronDown,
        selected: state.overlays,
        tooltip: 'Clip overlay settings',
      ),
      popover: (context, close) =>
          BlenderPopoverPanel.settings('Overlays', <Widget>[
            BlenderCheckbox(
              value: state.overlays,
              label: 'Show Overlays',
              onChanged: (value) => _update(state.copyWith(overlays: value)),
            ),
            BlenderCheckbox(
              value: state.show3dMarkers,
              label: '3D Markers',
              onChanged: (value) =>
                  _update(state.copyWith(show3dMarkers: value)),
            ),
            BlenderCheckbox(
              value: state.showGrid,
              label: 'Grid',
              onChanged: (value) => _update(state.copyWith(showGrid: value)),
            ),
            BlenderCheckbox(
              value: state.showAnnotations,
              label: 'Annotation',
              onChanged: (value) =>
                  _update(state.copyWith(showAnnotations: value)),
            ),
            BlenderCheckbox(
              value: state.showNames,
              label: 'Names',
              onChanged: (value) => _update(state.copyWith(showNames: value)),
            ),
          ]),
    ),
  ];

  Map<String, List<String>> get _menuItems => const <String, List<String>>{
    'View': <String>[
      'Toolbar',
      'Sidebar',
      'View All',
      'View Selected',
      'Zoom In',
      'Zoom Out',
      'Area',
    ],
    'Select': <String>[
      'All',
      'None',
      'Invert',
      'Box Select',
      'Circle Select',
      'Lasso Select',
      'Select Grouped',
    ],
    'Clip': <String>[
      'Open Clip',
      'Reload',
      'Set Scene Frames',
      'Prefetch',
      'Refine',
    ],
    'Track': <String>[
      'Track Motion',
      'Clear Track Path',
      'Refine Markers',
      'Solve Camera Motion',
      'Clean Tracks',
    ],
    'Reconstruction': <String>[
      'Set Floor',
      'Set Wall',
      'Set Origin',
      'Apply Solution Scale',
    ],
    'Add': <String>['Add Marker', 'Add Plane Track', 'Add Mask'],
    'Mask': <String>[
      'New Mask',
      'New Layer',
      'Duplicate Layer',
      'Delete Layer',
    ],
  };
}
