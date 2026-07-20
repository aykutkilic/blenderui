part of '../editors.dart';

/// Host-owned View3D mode, transform, overlay, and shading state.
@immutable
class BlenderView3dEditorHeaderState {
  const BlenderView3dEditorHeaderState({
    this.mode = 'Object Mode',
    this.transformOrientation = 'Global',
    this.transformPivot = 'Median Point',
    this.snapping = false,
    this.proportionalEditing = false,
    this.objectVisibility = true,
    this.gizmos = true,
    this.navigateGizmo = true,
    this.toolGizmos = true,
    this.overlays = true,
    this.floor = true,
    this.relationshipLines = true,
    this.textInfo = true,
    this.xray = false,
    this.shading = 'Solid',
    this.cavity = true,
    this.outline = true,
  });

  final String mode;
  final String transformOrientation;
  final String transformPivot;
  final bool snapping;
  final bool proportionalEditing;
  final bool objectVisibility;
  final bool gizmos;
  final bool navigateGizmo;
  final bool toolGizmos;
  final bool overlays;
  final bool floor;
  final bool relationshipLines;
  final bool textInfo;
  final bool xray;
  final String shading;
  final bool cavity;
  final bool outline;

  BlenderView3dEditorHeaderState copyWith({
    String? mode,
    String? transformOrientation,
    String? transformPivot,
    bool? snapping,
    bool? proportionalEditing,
    bool? objectVisibility,
    bool? gizmos,
    bool? navigateGizmo,
    bool? toolGizmos,
    bool? overlays,
    bool? floor,
    bool? relationshipLines,
    bool? textInfo,
    bool? xray,
    String? shading,
    bool? cavity,
    bool? outline,
  }) => BlenderView3dEditorHeaderState(
    mode: mode ?? this.mode,
    transformOrientation: transformOrientation ?? this.transformOrientation,
    transformPivot: transformPivot ?? this.transformPivot,
    snapping: snapping ?? this.snapping,
    proportionalEditing: proportionalEditing ?? this.proportionalEditing,
    objectVisibility: objectVisibility ?? this.objectVisibility,
    gizmos: gizmos ?? this.gizmos,
    navigateGizmo: navigateGizmo ?? this.navigateGizmo,
    toolGizmos: toolGizmos ?? this.toolGizmos,
    overlays: overlays ?? this.overlays,
    floor: floor ?? this.floor,
    relationshipLines: relationshipLines ?? this.relationshipLines,
    textInfo: textInfo ?? this.textInfo,
    xray: xray ?? this.xray,
    shading: shading ?? this.shading,
    cavity: cavity ?? this.cavity,
    outline: outline ?? this.outline,
  );
}

/// Source-shaped Object Mode View3D header.
class BlenderView3dEditorHeader extends StatelessWidget {
  const BlenderView3dEditorHeader({
    super.key,
    this.state = const BlenderView3dEditorHeaderState(),
    this.onEditorTypeChanged,
    this.onStateChanged,
    this.onCommand,
    this.height = 30,
  });

  final BlenderView3dEditorHeaderState state;
  final ValueChanged<BlenderEditorType>? onEditorTypeChanged;
  final ValueChanged<BlenderView3dEditorHeaderState>? onStateChanged;
  final ValueChanged<String>? onCommand;
  final double height;

  void _update(BlenderView3dEditorHeaderState value) =>
      onStateChanged?.call(value);

  @override
  Widget build(BuildContext context) {
    final densityScale = BlenderTheme.of(context).density.controlHeight / 20;
    return BlenderAreaHeader(
      height: height,
      editorType: BlenderEditorType.view3d,
      showEditorLabel: false,
      onEditorTypeChanged: onEditorTypeChanged,
      actionsScrollable: true,
      leading: <Widget>[
        SizedBox(
          width: 96 * densityScale,
          child: BlenderDropdown<String>(
            key: const ValueKey<String>('viewport-mode'),
            value: state.mode,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Object Mode',
                label: 'Object Mode',
              ),
              BlenderMenuItem<String>(value: 'Edit Mode', label: 'Edit Mode'),
              BlenderMenuItem<String>(
                value: 'Sculpt Mode',
                label: 'Sculpt Mode',
              ),
            ],
            onChanged: (value) {
              _update(state.copyWith(mode: value));
              onCommand?.call('$value selected');
            },
          ),
        ),
      ],
      menuDescriptors: BlenderEditorMenuCatalog.build(
        const <String>['View', 'Select', 'Add', 'Object'],
        menuItems: _menuItems,
        onSelected: onCommand,
      ),
      actions: <Widget>[
        SizedBox(
          // Blender keeps the orientation name readable beside its icon and
          // disclosure affordance at enlarged UI scales.
          width: 104 * densityScale,
          child: BlenderDropdown<String>(
            key: const ValueKey<String>('viewport-transform-orientation'),
            value: state.transformOrientation,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Global',
                label: 'Global',
                icon: BlenderIcon(BlenderGlyph.transform, size: 18),
              ),
              BlenderMenuItem<String>(value: 'Local', label: 'Local'),
              BlenderMenuItem<String>(value: 'Normal', label: 'Normal'),
              BlenderMenuItem<String>(value: 'View', label: 'View'),
              BlenderMenuItem<String>(value: 'Cursor', label: 'Cursor'),
            ],
            onChanged: (value) =>
                _update(state.copyWith(transformOrientation: value)),
          ),
        ),
        BlenderIconButton(
          key: const ValueKey<String>('viewport-transform-pivot'),
          glyph: BlenderGlyph.transform,
          selected: state.transformPivot == 'Median Point',
          onPressed: () => _update(
            state.copyWith(
              transformPivot: state.transformPivot == 'Median Point'
                  ? 'Individual Origins'
                  : 'Median Point',
            ),
          ),
          tooltip: 'Pivot Point: ${state.transformPivot}',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('viewport-snap'),
          glyph: BlenderGlyph.snap,
          selected: state.snapping,
          onPressed: () => _update(state.copyWith(snapping: !state.snapping)),
          tooltip: 'Snap',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('viewport-proportional-editing'),
          glyph: BlenderGlyph.transform,
          selected: state.proportionalEditing,
          onPressed: () => _update(
            state.copyWith(proportionalEditing: !state.proportionalEditing),
          ),
          tooltip: 'Proportional Editing',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('viewport-object-visibility'),
          glyph: BlenderGlyph.eye,
          selected: state.objectVisibility,
          onPressed: () => _update(
            state.copyWith(objectVisibility: !state.objectVisibility),
          ),
          tooltip: 'Object visibility',
        ),
        ..._gizmoControls(context),
        ..._overlayControls(context),
        BlenderIconButton(
          key: const ValueKey<String>('viewport-xray'),
          glyph: BlenderGlyph.xray,
          selected: state.xray,
          onPressed: () => _update(state.copyWith(xray: !state.xray)),
          tooltip: 'X-Ray',
        ),
        for (final shading in const <String>[
          'Wireframe',
          'Solid',
          'Material Preview',
          'Rendered',
        ])
          BlenderIconButton(
            key: ValueKey<String>(
              'viewport-shading-${shading.toLowerCase().replaceAll(' ', '-')}',
            ),
            glyph: switch (shading) {
              'Wireframe' => BlenderGlyph.wireframe,
              'Solid' => BlenderGlyph.solid,
              'Material Preview' => BlenderGlyph.materialPreview,
              _ => BlenderGlyph.rendered,
            },
            selected: state.shading == shading,
            onPressed: () => _update(state.copyWith(shading: shading)),
            tooltip: shading,
          ),
        BlenderPopover(
          child: const BlenderIconButton(
            key: ValueKey<String>('viewport-shading-options'),
            glyph: BlenderGlyph.settings,
            tooltip: 'Viewport shading options',
          ),
          popover: (context, close) => _shadingPopover(context),
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Area options',
        ),
      ],
    );
  }

  List<Widget> _gizmoControls(BuildContext context) => <Widget>[
    BlenderIconButton(
      key: const ValueKey<String>('viewport-gizmo-toggle'),
      glyph: BlenderGlyph.gizmo,
      selected: state.gizmos,
      onPressed: () => _update(state.copyWith(gizmos: !state.gizmos)),
      tooltip: 'Toggle gizmos',
    ),
    BlenderPopover(
      child: BlenderIconButton(
        key: const ValueKey<String>('viewport-gizmo'),
        glyph: BlenderGlyph.chevronDown,
        selected: state.gizmos,
        tooltip: 'Gizmo Display',
      ),
      popover: (context, close) =>
          BlenderPopoverPanel.settings('Gizmo Display', <Widget>[
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
          ], width: 240),
    ),
  ];

  List<Widget> _overlayControls(BuildContext context) => <Widget>[
    BlenderIconButton(
      key: const ValueKey<String>('viewport-overlays-toggle'),
      glyph: BlenderGlyph.overlay,
      selected: state.overlays,
      onPressed: () => _update(state.copyWith(overlays: !state.overlays)),
      tooltip: 'Toggle overlays',
    ),
    BlenderPopover(
      child: BlenderIconButton(
        key: const ValueKey<String>('viewport-overlays'),
        glyph: BlenderGlyph.chevronDown,
        selected: state.overlays,
        tooltip: 'Overlay settings',
      ),
      popover: (context, close) =>
          BlenderPopoverPanel.settings('Overlays', <Widget>[
            BlenderCheckbox(
              value: state.overlays,
              label: 'Show Overlays',
              onChanged: (value) => _update(state.copyWith(overlays: value)),
            ),
            BlenderCheckbox(
              value: state.floor,
              label: 'Floor',
              onChanged: (value) => _update(state.copyWith(floor: value)),
            ),
            BlenderCheckbox(
              value: state.relationshipLines,
              label: 'Relationship Lines',
              onChanged: (value) =>
                  _update(state.copyWith(relationshipLines: value)),
            ),
            BlenderCheckbox(
              value: state.textInfo,
              label: 'Text Info',
              onChanged: (value) => _update(state.copyWith(textInfo: value)),
            ),
          ], width: 240),
    ),
  ];

  Widget _shadingPopover(BuildContext context) =>
      BlenderPopoverPanel.settings('Shading', <Widget>[
        BlenderDropdown<String>(
          value: state.shading,
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(value: 'Wireframe', label: 'Wireframe'),
            BlenderMenuItem<String>(value: 'Solid', label: 'Solid'),
            BlenderMenuItem<String>(
              value: 'Material Preview',
              label: 'Material Preview',
            ),
            BlenderMenuItem<String>(value: 'Rendered', label: 'Rendered'),
          ],
          onChanged: (value) => _update(state.copyWith(shading: value)),
        ),
        BlenderCheckbox(
          value: state.xray,
          label: 'X-Ray',
          onChanged: (value) => _update(state.copyWith(xray: value)),
        ),
        BlenderCheckbox(
          value: state.cavity,
          label: 'Cavity',
          onChanged: (value) => _update(state.copyWith(cavity: value)),
        ),
        BlenderCheckbox(
          value: state.outline,
          label: 'Outline',
          onChanged: (value) => _update(state.copyWith(outline: value)),
        ),
      ], width: 240);

  static const Map<String, List<String>> _menuItems = <String, List<String>>{
    'View': <String>[
      'Toolbar',
      'Sidebar',
      'Tool Header',
      'Asset Shelf',
      'HUD',
      'Camera',
      'Viewpoint',
      'Navigation',
      'Align View',
      'Frame Selected',
      'Frame All',
      'Local View',
      'View Regions',
      'Playback',
      'Area',
    ],
    'Select': <String>[
      'All',
      'None',
      'Invert',
      'Box Select',
      'Circle Select',
      'Lasso Select',
      'Select Pattern',
      'Select Grouped',
      'Select Linked',
      'Select by Type',
      'Select Active Camera',
      'Mirror Selection',
      'Random',
      'More/Less',
    ],
    'Add': <String>[
      'Mesh',
      'Curve',
      'Surface',
      'Metaball',
      'Text',
      'Volume',
      'Grease Pencil',
      'Armature',
      'Lattice',
      'Empty',
      'Image',
      'Light',
      'Light Probe',
      'Camera',
      'Speaker',
      'Force Field',
      'Collection Instance',
    ],
    'Object': <String>[
      'Transform',
      'Set Origin',
      'Mirror',
      'Clear',
      'Apply',
      'Snap',
      'Duplicate Objects',
      'Duplicate Linked',
      'Join',
      'Parent',
      'Constraints',
      'Track',
      'Links/Transfer Data',
      'Shade Auto Smooth',
      'Animation',
      'Rigid Body',
      'Quick Effects',
      'Convert',
      'Show/Hide',
      'Delete',
    ],
  };
}
