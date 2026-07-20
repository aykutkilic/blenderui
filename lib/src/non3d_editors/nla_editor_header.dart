part of '../non3d_editors.dart';

/// Host-owned filter and snapping state for [BlenderNlaEditorHeader].
@immutable
class BlenderNlaEditorHeaderState {
  const BlenderNlaEditorHeaderState({
    this.onlySelected = true,
    this.showHidden = false,
    this.showMissing = false,
    this.onlyErrors = false,
    this.snapping = false,
    this.snapTarget = 'Frame',
    this.absoluteTime = false,
  });

  final bool onlySelected;
  final bool showHidden;
  final bool showMissing;
  final bool onlyErrors;
  final bool snapping;
  final String snapTarget;
  final bool absoluteTime;

  BlenderNlaEditorHeaderState copyWith({
    bool? onlySelected,
    bool? showHidden,
    bool? showMissing,
    bool? onlyErrors,
    bool? snapping,
    String? snapTarget,
    bool? absoluteTime,
  }) => BlenderNlaEditorHeaderState(
    onlySelected: onlySelected ?? this.onlySelected,
    showHidden: showHidden ?? this.showHidden,
    showMissing: showMissing ?? this.showMissing,
    onlyErrors: onlyErrors ?? this.onlyErrors,
    snapping: snapping ?? this.snapping,
    snapTarget: snapTarget ?? this.snapTarget,
    absoluteTime: absoluteTime ?? this.absoluteTime,
  );
}

/// Source-shaped Nonlinear Animation editor header.
class BlenderNlaEditorHeader extends StatelessWidget {
  const BlenderNlaEditorHeader({
    super.key,
    this.state = const BlenderNlaEditorHeaderState(),
    this.onEditorTypeChanged,
    this.onStateChanged,
    this.onCommand,
    this.fCurveSearchController,
    this.collectionSearchController,
    this.showMarkers = true,
    this.height = 30,
  });

  final BlenderNlaEditorHeaderState state;
  final ValueChanged<BlenderEditorType>? onEditorTypeChanged;
  final ValueChanged<BlenderNlaEditorHeaderState>? onStateChanged;
  final ValueChanged<String>? onCommand;
  final TextEditingController? fCurveSearchController;
  final TextEditingController? collectionSearchController;
  final bool showMarkers;
  final double height;

  void _update(BlenderNlaEditorHeaderState value) =>
      onStateChanged?.call(value);

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      'View',
      'Select',
      if (showMarkers) 'Marker',
      'Add',
      'Track',
      'Strip',
    ];
    return BlenderAreaHeader(
      height: height,
      editorType: BlenderEditorType.nlaEditor,
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
          key: const ValueKey<String>('nla-only-selected-button'),
          glyph: BlenderGlyph.object,
          selected: state.onlySelected,
          onPressed: () =>
              _update(state.copyWith(onlySelected: !state.onlySelected)),
          tooltip: 'Only Selected',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('nla-show-hidden-button'),
          glyph: BlenderGlyph.eye,
          selected: state.showHidden,
          onPressed: () =>
              _update(state.copyWith(showHidden: !state.showHidden)),
          tooltip: 'Show Hidden',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('nla-show-missing-button'),
          glyph: BlenderGlyph.warning,
          selected: state.showMissing,
          onPressed: () =>
              _update(state.copyWith(showMissing: !state.showMissing)),
          tooltip: 'Show Missing',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('nla-only-errors-button'),
          glyph: BlenderGlyph.error,
          selected: state.onlyErrors,
          onPressed: () =>
              _update(state.copyWith(onlyErrors: !state.onlyErrors)),
          tooltip: 'Only Errors',
        ),
        BlenderPopover(
          child: const BlenderIconButton(
            key: ValueKey<String>('nla-filters-button'),
            glyph: BlenderGlyph.filter,
            tooltip: 'NLA filters',
          ),
          popover: (context, close) => _filtersPopover(context),
        ),
        BlenderIconButton(
          key: const ValueKey<String>('nla-snapping-toggle-button'),
          glyph: BlenderGlyph.snap,
          selected: state.snapping,
          onPressed: () => _update(state.copyWith(snapping: !state.snapping)),
          tooltip: 'Toggle NLA snapping',
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('nla-snapping-button'),
            glyph: BlenderGlyph.chevronDown,
            selected: state.snapping,
            tooltip: 'NLA snapping settings',
          ),
          popover: (context, close) => _snappingPopover(context),
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }

  Widget _filtersPopover(BuildContext context) => BlenderPopoverPanel.settings(
    'Filters',
    <Widget>[
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
        value: state.showMissing,
        label: 'Show Missing',
        onChanged: (value) => _update(state.copyWith(showMissing: value)),
      ),
      BlenderCheckbox(
        value: state.onlyErrors,
        label: 'Only Errors',
        onChanged: (value) => _update(state.copyWith(onlyErrors: value)),
      ),
      const BlenderSeparator(),
      if (fCurveSearchController != null)
        BlenderPropertyRow(
          label: 'F-Curve Name',
          editor: BlenderTextField(
            controller: fCurveSearchController!,
            placeholder: 'Search F-Curves',
          ),
        ),
      if (collectionSearchController != null)
        BlenderPropertyRow(
          label: 'Collection',
          editor: BlenderTextField(
            controller: collectionSearchController!,
            placeholder: 'Search Collections',
          ),
        ),
      if (fCurveSearchController != null || collectionSearchController != null)
        const BlenderSeparator(),
      Text('Filter by Type', style: BlenderTheme.of(context).textTheme.caption),
      for (final label in const <String>[
        'Scenes',
        'Node Trees',
        'Armatures',
        'Cameras',
        'Grease Pencil Objects',
        'Lights',
        'Meshes',
        'Curves',
        'Lattices',
        'Metaballs',
        'Volumes',
        'Worlds',
        'Particles',
        'Speakers',
        'Materials',
        'Textures',
        'Shape Keys',
        'Movie Clips',
      ])
        BlenderCheckbox(
          value: true,
          label: label,
          onChanged: (_) => onCommand?.call('Filter $label'),
        ),
      const BlenderSeparator(),
      BlenderCheckbox(
        value: true,
        label: 'Transforms',
        onChanged: (_) => onCommand?.call('Filter Transforms'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Modifiers',
        onChanged: (_) => onCommand?.call('Filter Modifiers'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Use Data-Block Sort',
        onChanged: (_) => onCommand?.call('Use Data-Block Sort'),
      ),
    ],
  );

  Widget _snappingPopover(BuildContext context) =>
      BlenderPopoverPanel.settings('Snapping', <Widget>[
        Text('Snap To', style: BlenderTheme.of(context).textTheme.caption),
        BlenderDropdown<String>(
          value: state.snapTarget,
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
            BlenderMenuItem<String>(value: 'Second', label: 'Second'),
            BlenderMenuItem<String>(value: 'Marker', label: 'Marker'),
          ],
          onChanged: (value) => _update(state.copyWith(snapTarget: value)),
        ),
        BlenderCheckbox(
          value: state.absoluteTime,
          label: 'Absolute Time',
          onChanged: (value) => _update(state.copyWith(absoluteTime: value)),
        ),
      ]);

  Map<String, List<String>> get _menuItems => <String, List<String>>{
    'View': const <String>[
      'Sidebar',
      'HUD',
      'Channels',
      'Playback Controls',
      'View Selected',
      'View All',
      'Frame Scene Range',
      'View Frame',
      'Realtime Update',
      'Show Strip Curves',
      'Show Markers',
      'Show Local Markers',
      'Show Seconds',
      'Show Locked Time',
      'Set Preview Range',
      'Clear Preview Range',
      'Set NLA Preview Range',
      'Area',
    ],
    'Select': const <String>[
      'All',
      'None',
      'Invert',
      'Box Select',
      'Box Select (Axis Range)',
      'Before Current Frame',
      'After Current Frame',
    ],
    'Marker': const <String>[
      'Jump to Previous Marker',
      'Jump to Next Marker',
      'Add Marker',
      'Duplicate Marker',
      'Delete Marker',
      'Rename Marker',
    ],
    'Add': const <String>['Action', 'Transition', 'Sound', 'Selected Objects'],
    'Track': const <String>[
      'Add',
      'Add Above Selected',
      'Move',
      'Clean Empty',
      'Delete',
    ],
    'Strip': const <String>[
      'Transform',
      'Snap',
      'Duplicate',
      'Linked Duplicate',
      'Make Meta',
      'Remove Meta',
      'Split',
      'Mute',
      'Bake Action',
      'Apply Scale',
      'Delete',
    ],
  };
}
