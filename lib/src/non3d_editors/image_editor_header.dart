part of '../non3d_editors.dart';

/// Modes exposed by Blender's Image Editor mode selector.
enum BlenderImageEditorMode { view, paint, mask, uv }

extension BlenderImageEditorModePresentation on BlenderImageEditorMode {
  String get label => switch (this) {
    BlenderImageEditorMode.view => 'View',
    BlenderImageEditorMode.paint => 'Paint',
    BlenderImageEditorMode.mask => 'Mask',
    BlenderImageEditorMode.uv => 'UV',
  };
}

/// Host-owned state for [BlenderImageEditorHeader].
///
/// Keeping the settings in one immutable value prevents application shells
/// from rebuilding Blender's header anatomy while still allowing every visible
/// control to participate in application state.
@immutable
class BlenderImageEditorHeaderState {
  const BlenderImageEditorHeaderState({
    this.mode = BlenderImageEditorMode.view,
    this.uvSelectionSync = false,
    this.uvSelectionMode = 'Vertex',
    this.uvIslandSelection = false,
    this.snapping = false,
    this.snapTarget = 'Vertex',
    this.snapBase = 'Median',
    this.snapMove = true,
    this.snapRotate = false,
    this.snapScale = false,
    this.proportionalEditing = false,
    this.proportionalConnected = true,
    this.proportionalFalloff = 'Smooth',
    this.pinned = false,
    this.gizmos = true,
    this.navigateGizmo = true,
    this.transformGizmo = true,
    this.overlays = true,
    this.showMetadata = true,
    this.showGrid = true,
  });

  final BlenderImageEditorMode mode;
  final bool uvSelectionSync;
  final String uvSelectionMode;
  final bool uvIslandSelection;
  final bool snapping;
  final String snapTarget;
  final String snapBase;
  final bool snapMove;
  final bool snapRotate;
  final bool snapScale;
  final bool proportionalEditing;
  final bool proportionalConnected;
  final String proportionalFalloff;
  final bool pinned;
  final bool gizmos;
  final bool navigateGizmo;
  final bool transformGizmo;
  final bool overlays;
  final bool showMetadata;
  final bool showGrid;

  BlenderImageEditorHeaderState copyWith({
    BlenderImageEditorMode? mode,
    bool? uvSelectionSync,
    String? uvSelectionMode,
    bool? uvIslandSelection,
    bool? snapping,
    String? snapTarget,
    String? snapBase,
    bool? snapMove,
    bool? snapRotate,
    bool? snapScale,
    bool? proportionalEditing,
    bool? proportionalConnected,
    String? proportionalFalloff,
    bool? pinned,
    bool? gizmos,
    bool? navigateGizmo,
    bool? transformGizmo,
    bool? overlays,
    bool? showMetadata,
    bool? showGrid,
  }) => BlenderImageEditorHeaderState(
    mode: mode ?? this.mode,
    uvSelectionSync: uvSelectionSync ?? this.uvSelectionSync,
    uvSelectionMode: uvSelectionMode ?? this.uvSelectionMode,
    uvIslandSelection: uvIslandSelection ?? this.uvIslandSelection,
    snapping: snapping ?? this.snapping,
    snapTarget: snapTarget ?? this.snapTarget,
    snapBase: snapBase ?? this.snapBase,
    snapMove: snapMove ?? this.snapMove,
    snapRotate: snapRotate ?? this.snapRotate,
    snapScale: snapScale ?? this.snapScale,
    proportionalEditing: proportionalEditing ?? this.proportionalEditing,
    proportionalConnected: proportionalConnected ?? this.proportionalConnected,
    proportionalFalloff: proportionalFalloff ?? this.proportionalFalloff,
    pinned: pinned ?? this.pinned,
    gizmos: gizmos ?? this.gizmos,
    navigateGizmo: navigateGizmo ?? this.navigateGizmo,
    transformGizmo: transformGizmo ?? this.transformGizmo,
    overlays: overlays ?? this.overlays,
    showMetadata: showMetadata ?? this.showMetadata,
    showGrid: showGrid ?? this.showGrid,
  );
}

/// Source-shaped shared header for Blender's Image and UV editors.
///
/// Menu taxonomy follows `scripts/startup/bl_ui/space_image.py`. Commands and
/// persistent values remain host-owned through [onCommand] and
/// [onStateChanged].
class BlenderImageEditorHeader extends StatelessWidget {
  const BlenderImageEditorHeader({
    super.key,
    required this.editorType,
    this.state = const BlenderImageEditorHeaderState(),
    this.onEditorTypeChanged,
    this.onStateChanged,
    this.onCommand,
    this.hasImage = true,
    this.imageDirty = false,
    this.showRender = false,
    this.imageIsSequence = false,
    this.imagePacked = false,
    this.imageHasPath = true,
    this.hasImageClipboard = true,
    this.height = 30,
  }) : assert(
         editorType == BlenderEditorType.imageEditor ||
             editorType == BlenderEditorType.uvEditor,
         'BlenderImageEditorHeader only supports Image and UV editors.',
       );

  final BlenderEditorType editorType;
  final BlenderImageEditorHeaderState state;
  final ValueChanged<BlenderEditorType>? onEditorTypeChanged;
  final ValueChanged<BlenderImageEditorHeaderState>? onStateChanged;
  final ValueChanged<String>? onCommand;
  final bool hasImage;
  final bool imageDirty;
  final bool showRender;
  final bool imageIsSequence;
  final bool imagePacked;
  final bool imageHasPath;
  final bool hasImageClipboard;
  final double height;

  bool get _uvEditor => editorType == BlenderEditorType.uvEditor;

  void _update(BlenderImageEditorHeaderState value) =>
      onStateChanged?.call(value);

  @override
  Widget build(BuildContext context) {
    final menus = <String>[
      'View',
      if (_uvEditor) 'Select',
      'Image',
      if (_uvEditor) 'UV',
    ];
    return BlenderAreaHeader(
      height: height,
      editorType: editorType,
      showEditorLabel: false,
      onEditorTypeChanged: onEditorTypeChanged,
      actionsScrollable: true,
      leading: <Widget>[
        if (!_uvEditor)
          SizedBox(
            width: 82,
            child: BlenderDropdown<BlenderImageEditorMode>(
              key: const ValueKey<String>('image-display-source'),
              value: state.mode == BlenderImageEditorMode.uv
                  ? BlenderImageEditorMode.view
                  : state.mode,
              items: const <BlenderMenuItem<BlenderImageEditorMode>>[
                BlenderMenuItem<BlenderImageEditorMode>(
                  value: BlenderImageEditorMode.view,
                  label: 'View',
                ),
                BlenderMenuItem<BlenderImageEditorMode>(
                  value: BlenderImageEditorMode.paint,
                  label: 'Paint',
                ),
                BlenderMenuItem<BlenderImageEditorMode>(
                  value: BlenderImageEditorMode.mask,
                  label: 'Mask',
                ),
              ],
              onChanged: (value) {
                _update(state.copyWith(mode: value));
                onCommand?.call(value.label);
              },
            ),
          ),
        if (_uvEditor) ..._uvLeadingControls(),
      ],
      menuDescriptors: BlenderEditorMenuCatalog.build(
        menus,
        menuDescriptors: _menuDescriptors(),
        onSelected: onCommand,
      ),
      actions: <Widget>[
        if (_uvEditor) ..._transformControls(context),
        BlenderIconButton(
          key: const ValueKey<String>('image-pin-button'),
          glyph: BlenderGlyph.pin,
          selected: state.pinned,
          onPressed: showRender
              ? null
              : () => _update(state.copyWith(pinned: !state.pinned)),
          tooltip: 'Pin image',
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

  List<Widget> _uvLeadingControls() => <Widget>[
    BlenderIconButton(
      key: const ValueKey<String>('image-uv-sync-button'),
      glyph: BlenderGlyph.link,
      selected: state.uvSelectionSync,
      onPressed: () =>
          _update(state.copyWith(uvSelectionSync: !state.uvSelectionSync)),
      tooltip: 'UV selection sync',
    ),
    SizedBox(
      width: 76,
      child: BlenderDropdown<String>(
        key: const ValueKey<String>('image-uv-selection-mode'),
        value: state.uvSelectionMode,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Vertex', label: 'Vertex'),
          BlenderMenuItem<String>(value: 'Edge', label: 'Edge'),
          BlenderMenuItem<String>(value: 'Face', label: 'Face'),
        ],
        onChanged: (value) => _update(state.copyWith(uvSelectionMode: value)),
      ),
    ),
    BlenderIconButton(
      key: const ValueKey<String>('image-uv-island-mode'),
      glyph: BlenderGlyph.uv,
      selected: state.uvIslandSelection,
      onPressed: () =>
          _update(state.copyWith(uvIslandSelection: !state.uvIslandSelection)),
      tooltip: 'UV island selection',
    ),
  ];

  List<Widget> _transformControls(BuildContext context) => <Widget>[
    BlenderIconButton(
      key: const ValueKey<String>('image-snap-toggle-button'),
      glyph: BlenderGlyph.snap,
      selected: state.snapping,
      onPressed: () => _update(state.copyWith(snapping: !state.snapping)),
      tooltip: 'Toggle UV snapping',
    ),
    BlenderPopover(
      child: BlenderIconButton(
        key: const ValueKey<String>('image-snap-button'),
        glyph: BlenderGlyph.chevronDown,
        selected: state.snapping,
        tooltip: 'UV snapping settings',
      ),
      popover: (context, close) => BlenderPopoverPanel.settings(
        'Snapping',
        <Widget>[
          Text(
            'Snap Target',
            style: BlenderTheme.of(context).textTheme.caption,
          ),
          BlenderDropdown<String>(
            value: state.snapTarget,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Vertex', label: 'Vertex'),
              BlenderMenuItem<String>(value: 'Edge', label: 'Edge'),
              BlenderMenuItem<String>(value: 'Face', label: 'Face'),
              BlenderMenuItem<String>(value: 'Increment', label: 'Increment'),
            ],
            onChanged: (value) => _update(state.copyWith(snapTarget: value)),
          ),
          const SizedBox(height: 6),
          Text('Snap Base', style: BlenderTheme.of(context).textTheme.caption),
          BlenderDropdown<String>(
            value: state.snapBase,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Median', label: 'Median'),
              BlenderMenuItem<String>(value: 'Closest', label: 'Closest'),
              BlenderMenuItem<String>(value: 'Active', label: 'Active'),
            ],
            onChanged: (value) => _update(state.copyWith(snapBase: value)),
          ),
          const SizedBox(height: 6),
          BlenderCheckbox(
            value: state.snapMove,
            label: 'Move',
            onChanged: (value) => _update(state.copyWith(snapMove: value)),
          ),
          BlenderCheckbox(
            value: state.snapRotate,
            label: 'Rotate',
            onChanged: (value) => _update(state.copyWith(snapRotate: value)),
          ),
          BlenderCheckbox(
            value: state.snapScale,
            label: 'Scale',
            onChanged: (value) => _update(state.copyWith(snapScale: value)),
          ),
        ],
      ),
    ),
    BlenderIconButton(
      key: const ValueKey<String>('image-proportional-toggle-button'),
      glyph: BlenderGlyph.transform,
      selected: state.proportionalEditing,
      onPressed: () => _update(
        state.copyWith(proportionalEditing: !state.proportionalEditing),
      ),
      tooltip: 'Toggle proportional editing',
    ),
    BlenderPopover(
      child: BlenderIconButton(
        key: const ValueKey<String>('image-proportional-button'),
        glyph: BlenderGlyph.chevronDown,
        selected: state.proportionalEditing,
        tooltip: 'Proportional editing settings',
      ),
      popover: (context, close) =>
          BlenderPopoverPanel.settings('Proportional Editing', <Widget>[
            BlenderCheckbox(
              value: state.proportionalConnected,
              label: 'Connected',
              onChanged: (value) =>
                  _update(state.copyWith(proportionalConnected: value)),
            ),
            Text('Falloff', style: BlenderTheme.of(context).textTheme.caption),
            BlenderDropdown<String>(
              value: state.proportionalFalloff,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'Smooth', label: 'Smooth'),
                BlenderMenuItem<String>(value: 'Sphere', label: 'Sphere'),
                BlenderMenuItem<String>(value: 'Sharp', label: 'Sharp'),
              ],
              onChanged: (value) =>
                  _update(state.copyWith(proportionalFalloff: value)),
            ),
          ]),
    ),
  ];

  List<Widget> _gizmoControls(BuildContext context) => <Widget>[
    BlenderIconButton(
      key: const ValueKey<String>('image-gizmo-toggle-button'),
      glyph: BlenderGlyph.gizmo,
      selected: state.gizmos,
      onPressed: () => _update(state.copyWith(gizmos: !state.gizmos)),
      tooltip: 'Toggle image gizmos',
    ),
    BlenderPopover(
      child: BlenderIconButton(
        key: const ValueKey<String>('image-gizmo-button'),
        glyph: BlenderGlyph.chevronDown,
        selected: state.gizmos,
        tooltip: 'Image gizmo settings',
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
              value: state.transformGizmo,
              label: 'Transform Gizmo',
              onChanged: (value) =>
                  _update(state.copyWith(transformGizmo: value)),
            ),
          ]),
    ),
  ];

  List<Widget> _overlayControls(BuildContext context) => <Widget>[
    BlenderIconButton(
      key: const ValueKey<String>('image-overlay-toggle-button'),
      glyph: BlenderGlyph.overlay,
      selected: state.overlays,
      onPressed: () => _update(state.copyWith(overlays: !state.overlays)),
      tooltip: 'Toggle image overlays',
    ),
    BlenderPopover(
      child: BlenderIconButton(
        key: const ValueKey<String>('image-overlay-button'),
        glyph: BlenderGlyph.chevronDown,
        selected: state.overlays,
        tooltip: 'Image overlay settings',
      ),
      popover: (context, close) =>
          BlenderPopoverPanel.settings('Overlays', <Widget>[
            BlenderCheckbox(
              value: state.overlays,
              label: 'Show Overlays',
              onChanged: (value) => _update(state.copyWith(overlays: value)),
            ),
            BlenderCheckbox(
              value: state.showMetadata,
              label: 'Image Metadata',
              onChanged: (value) =>
                  _update(state.copyWith(showMetadata: value)),
            ),
            BlenderCheckbox(
              value: state.showGrid,
              label: 'Grid',
              onChanged: (value) => _update(state.copyWith(showGrid: value)),
            ),
          ]),
    ),
  ];
}
