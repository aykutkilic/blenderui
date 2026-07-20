part of '../non3d_editors.dart';

/// Host-owned state for Graph and Drivers editor header controls.
@immutable
class BlenderGraphEditorHeaderState {
  const BlenderGraphEditorHeaderState({
    this.normalize = false,
    this.autoNormalize = false,
    this.ghostCurves = false,
    this.onlySelected = true,
    this.showHidden = true,
    this.onlyErrors = false,
    this.multiWordSearch = true,
    this.driverFallbackAsError = false,
    this.snapping = false,
    this.snapTarget = 'Frame',
    this.absoluteTime = false,
    this.proportionalEditing = false,
    this.proportionalMode = 'Connected',
    this.proportionalSize = 1,
  });

  final bool normalize;
  final bool autoNormalize;
  final bool ghostCurves;
  final bool onlySelected;
  final bool showHidden;
  final bool onlyErrors;
  final bool multiWordSearch;
  final bool driverFallbackAsError;
  final bool snapping;
  final String snapTarget;
  final bool absoluteTime;
  final bool proportionalEditing;
  final String proportionalMode;
  final double proportionalSize;

  BlenderGraphEditorHeaderState copyWith({
    bool? normalize,
    bool? autoNormalize,
    bool? ghostCurves,
    bool? onlySelected,
    bool? showHidden,
    bool? onlyErrors,
    bool? multiWordSearch,
    bool? driverFallbackAsError,
    bool? snapping,
    String? snapTarget,
    bool? absoluteTime,
    bool? proportionalEditing,
    String? proportionalMode,
    double? proportionalSize,
  }) => BlenderGraphEditorHeaderState(
    normalize: normalize ?? this.normalize,
    autoNormalize: autoNormalize ?? this.autoNormalize,
    ghostCurves: ghostCurves ?? this.ghostCurves,
    onlySelected: onlySelected ?? this.onlySelected,
    showHidden: showHidden ?? this.showHidden,
    onlyErrors: onlyErrors ?? this.onlyErrors,
    multiWordSearch: multiWordSearch ?? this.multiWordSearch,
    driverFallbackAsError: driverFallbackAsError ?? this.driverFallbackAsError,
    snapping: snapping ?? this.snapping,
    snapTarget: snapTarget ?? this.snapTarget,
    absoluteTime: absoluteTime ?? this.absoluteTime,
    proportionalEditing: proportionalEditing ?? this.proportionalEditing,
    proportionalMode: proportionalMode ?? this.proportionalMode,
    proportionalSize: proportionalSize ?? this.proportionalSize,
  );
}

/// Source-shaped header shared by Graph and Drivers editors.
class BlenderGraphEditorHeader extends StatelessWidget {
  const BlenderGraphEditorHeader({
    super.key,
    required this.editorType,
    this.state = const BlenderGraphEditorHeaderState(),
    this.onEditorTypeChanged,
    this.onStateChanged,
    this.onCommand,
    this.height = 30,
  }) : assert(
         editorType == BlenderEditorType.graphEditor ||
             editorType == BlenderEditorType.drivers,
         'BlenderGraphEditorHeader only supports Graph and Drivers editors.',
       );

  final BlenderEditorType editorType;
  final BlenderGraphEditorHeaderState state;
  final ValueChanged<BlenderEditorType>? onEditorTypeChanged;
  final ValueChanged<BlenderGraphEditorHeaderState>? onStateChanged;
  final ValueChanged<String>? onCommand;
  final double height;

  bool get _drivers => editorType == BlenderEditorType.drivers;

  void _update(BlenderGraphEditorHeaderState value) =>
      onStateChanged?.call(value);

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      'View',
      'Select',
      if (!_drivers) 'Marker',
      'Channel',
      'Key',
    ];
    return BlenderAreaHeader(
      height: height,
      editorType: editorType,
      showEditorLabel: false,
      onEditorTypeChanged: onEditorTypeChanged,
      actionsScrollable: true,
      menuDescriptors: BlenderEditorMenuCatalog.build(
        labels,
        menuItems: _menuItems,
        onSelected: onCommand,
      ),
      actions: <Widget>[
        BlenderIconButton(
          key: const ValueKey<String>('graph-normalize-button'),
          glyph: BlenderGlyph.scale,
          selected: state.normalize,
          onPressed: () => _update(state.copyWith(normalize: !state.normalize)),
          tooltip: 'Normalize F-Curves',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('graph-auto-normalize-button'),
          glyph: BlenderGlyph.refresh,
          selected: state.autoNormalize,
          enabled: state.normalize,
          onPressed: () =>
              _update(state.copyWith(autoNormalize: !state.autoNormalize)),
          tooltip: 'Auto Normalize',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('graph-ghost-curves-button'),
          glyph: state.ghostCurves ? BlenderGlyph.close : BlenderGlyph.keyframe,
          selected: state.ghostCurves,
          onPressed: () =>
              _update(state.copyWith(ghostCurves: !state.ghostCurves)),
          tooltip: state.ghostCurves
              ? 'Clear Ghost Curves'
              : 'Create Ghost Curves',
        ),
        BlenderPopover(
          child: const BlenderIconButton(
            key: ValueKey<String>('graph-filters-button'),
            glyph: BlenderGlyph.filter,
            tooltip: 'Graph filters',
          ),
          popover: (context, close) => _filtersPopover(context),
        ),
        const BlenderIconButton(
          key: ValueKey<String>('graph-pivot-button'),
          glyph: BlenderGlyph.transform,
          tooltip: 'Pivot Point',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('graph-snapping-toggle-button'),
          glyph: BlenderGlyph.snap,
          selected: state.snapping,
          onPressed: () => _update(state.copyWith(snapping: !state.snapping)),
          tooltip: 'Toggle graph snapping',
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('graph-snapping-button'),
            glyph: BlenderGlyph.chevronDown,
            selected: state.snapping,
            tooltip: 'Graph snapping settings',
          ),
          popover: (context, close) => _snappingPopover(context),
        ),
        BlenderIconButton(
          key: const ValueKey<String>('graph-proportional-toggle-button'),
          glyph: BlenderGlyph.transform,
          selected: state.proportionalEditing,
          onPressed: () => _update(
            state.copyWith(proportionalEditing: !state.proportionalEditing),
          ),
          tooltip: 'Toggle graph proportional editing',
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('graph-proportional-button'),
            glyph: BlenderGlyph.chevronDown,
            selected: state.proportionalEditing,
            tooltip: 'Graph proportional editing settings',
          ),
          popover: (context, close) => _proportionalPopover(context),
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }

  Widget _filtersPopover(BuildContext context) =>
      BlenderPopoverPanel.settings('Filters', <Widget>[
        BlenderCheckbox(
          value: state.onlySelected,
          label: 'Only Selected',
          onChanged: (value) => _update(state.copyWith(onlySelected: value)),
        ),
        BlenderCheckbox(
          value: state.showHidden,
          label: 'Show Hidden',
          onChanged: (value) => _update(state.copyWith(showHidden: value)),
        ),
        BlenderCheckbox(
          value: state.onlyErrors,
          label: 'Only Errors',
          onChanged: (value) => _update(state.copyWith(onlyErrors: value)),
        ),
        const BlenderSeparator(),
        Text(
          'Search Filters',
          style: BlenderTheme.of(context).textTheme.caption,
        ),
        BlenderCheckbox(
          value: state.multiWordSearch,
          label: 'Multi-Word Match Search',
          onChanged: (value) => _update(state.copyWith(multiWordSearch: value)),
        ),
        if (_drivers)
          BlenderCheckbox(
            value: state.driverFallbackAsError,
            label: 'Driver Fallback as Error',
            onChanged: (value) =>
                _update(state.copyWith(driverFallbackAsError: value)),
          ),
      ]);

  Widget _snappingPopover(BuildContext context) =>
      BlenderPopoverPanel.settings('Snapping', <Widget>[
        Text('Snap To', style: BlenderTheme.of(context).textTheme.caption),
        BlenderDropdown<String>(
          value: state.snapTarget,
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
            BlenderMenuItem<String>(value: 'Second', label: 'Second'),
            BlenderMenuItem<String>(value: 'Marker', label: 'Marker'),
            BlenderMenuItem<String>(
              value: 'Absolute Time',
              label: 'Absolute Time',
            ),
          ],
          onChanged: (value) => _update(state.copyWith(snapTarget: value)),
        ),
        if (_drivers)
          BlenderCheckbox(
            value: state.absoluteTime,
            label: 'Absolute Time',
            onChanged: (value) => _update(state.copyWith(absoluteTime: value)),
          ),
      ]);

  Widget _proportionalPopover(BuildContext context) =>
      BlenderPopoverPanel.settings('Proportional Editing', <Widget>[
        BlenderDropdown<String>(
          value: state.proportionalMode,
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(value: 'Connected', label: 'Connected'),
            BlenderMenuItem<String>(value: 'Projected', label: 'Projected'),
          ],
          onChanged: (value) =>
              _update(state.copyWith(proportionalMode: value)),
        ),
        const SizedBox(height: 6),
        BlenderNumberField(
          value: state.proportionalSize,
          min: 0,
          max: 10,
          step: .1,
          label: 'Size',
          onChanged: (value) =>
              _update(state.copyWith(proportionalSize: value)),
        ),
      ]);

  Map<String, List<String>> get _menuItems => <String, List<String>>{
    'View': <String>[
      'Show Region UI',
      'Show Region HUD',
      'Show Region Channels',
      if (!_drivers) 'Playback Controls',
      'View Selected',
      'View All',
      'Local View',
      'Frame Scene Range',
      'View Frame',
      'Realtime Update',
      'Show Sliders',
      'Auto Merge Keyframes',
      'Auto Lock Translation Axis',
      if (!_drivers) 'Show Markers',
      'Show Cursor',
      'Show Seconds',
      'Show Locked Time',
      'Show Extrapolation',
      'Show Handles',
      'Only Selected Keyframe Handles',
      'Set Preview Range',
      'Clear Preview Range',
      'Toggle Dope Sheet',
      'Area',
    ],
    'Select': const <String>[
      'All',
      'None',
      'Invert',
      'Box Select (Include Handles)',
      'Box Select (Axis Range)',
      'Box Select',
      'Circle Select',
      'Lasso Select',
      'More',
      'Less',
      'Select Linked',
      'Columns on Selected Keys',
      'Column on Current Frame',
      'Before Current Frame',
      'After Current Frame',
      'Select Handles',
      'Select Key',
    ],
    'Marker': const <String>[
      'Jump to Previous Marker',
      'Jump to Next Marker',
      'Add Marker',
      'Duplicate Marker',
      'Delete Marker',
      'Rename Marker',
    ],
    'Channel': <String>[
      'Delete Channels',
      if (_drivers) 'Delete Invalid Drivers',
      'Group Channels',
      'Ungroup Channels',
      'Toggle Channel Setting',
      'Enable Channel Setting',
      'Disable Channel Setting',
      'Toggle Editable',
      'Extrapolation Mode',
      'Add F-Curve Modifier',
      'Delete F-Curve Modifiers',
      'Hide Selected Curves',
      'Hide Unselected Curves',
      'Reveal',
      'Expand Channels',
      'Collapse Channels',
      'Move Channels',
      'Keys to Samples',
      'Samples to Keys',
      'Sound to Samples',
      'Bake Channels',
      'Discontinuity (Euler) Filter',
      'View Selected Channels',
    ],
    'Key': const <String>[
      'Transform',
      'Snap',
      'Mirror',
      'Jump to Selected',
      'Copy',
      'Paste',
      'Paste Flipped',
      'Insert',
      'Duplicate',
      'Handle Type',
      'Interpolation Mode',
      'Easing Type',
      'Density',
      'Blend',
      'Smooth',
      'Delete',
    ],
  };
}
