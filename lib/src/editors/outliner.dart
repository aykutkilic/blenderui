part of '../editors.dart';

class _BlenderTreeGuidePainter extends CustomPainter {
  const _BlenderTreeGuidePainter({
    required this.indent,
    required this.depth,
    required this.ancestorHasNext,
    required this.isLast,
    required this.color,
  });

  final double indent;
  final int depth;
  final List<bool> ancestorHasNext;
  final bool isLast;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final centerY = size.height / 2;
    for (var level = 0; level < depth; level++) {
      final x = level * indent + indent / 2;
      final continues =
          level < ancestorHasNext.length && ancestorHasNext[level];
      if (continues)
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    final currentX = depth * indent + indent / 2;
    const linePadding = 5.0;
    canvas.drawLine(
      Offset(currentX, linePadding),
      Offset(currentX, isLast ? centerY : size.height - linePadding),
      paint,
    );
    canvas.drawLine(
      Offset(currentX, centerY),
      Offset(currentX + indent / 2, centerY),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BlenderTreeGuidePainter oldDelegate) =>
      indent != oldDelegate.indent ||
      depth != oldDelegate.depth ||
      ancestorHasNext != oldDelegate.ancestorHasNext ||
      isLast != oldDelegate.isLast ||
      color != oldDelegate.color;
}

class _BlenderTreeAlternatingRowsPainter extends CustomPainter {
  const _BlenderTreeAlternatingRowsPainter({required this.rowHeight});

  final double rowHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x04FFFFFF);
    for (var row = 1; row * rowHeight < size.height; row += 2) {
      canvas.drawRect(
        Rect.fromLTWH(0, row * rowHeight, size.width, rowHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BlenderTreeAlternatingRowsPainter oldDelegate) =>
      oldDelegate.rowHeight != rowHeight;
}

class BlenderOutliner<T> extends StatelessWidget {
  const BlenderOutliner({
    super.key,
    required this.roots,
    this.selectedId,
    this.onSelected,
    this.showVisibility = false,
    this.showLock = false,
    this.onVisibilityChanged,
    this.onLockChanged,
    this.title = 'Outliner',
    this.headerActions,
    this.filterController,
    this.onFilterChanged,
    this.filterPlaceholder = 'Search',
    this.displayMode = BlenderOutlinerDisplayMode.viewLayer,
    this.onDisplayModeChanged,
    this.syncSelection = true,
    this.onSyncSelectionChanged,
    this.libraryOverrideViewMode = 'Hierarchies',
    this.onLibraryOverrideViewModeChanged,
    this.useIdFilter = false,
    this.onIdFilterChanged,
    this.idFilterType = 'All',
    this.idFilterTypes = const <String>[
      'All',
      'Actions',
      'Armatures',
      'Cameras',
      'Collections',
      'Materials',
      'Meshes',
      'Objects',
      'Scenes',
      'Worlds',
    ],
    this.onIdFilterTypeChanged,
    this.onNewCollection,
    this.onPurgeUnusedData,
    this.hasActiveKeyingSet = false,
    this.activeKeyingSet = 'Location',
    this.keyingSets = const <String>['Location', 'Rotation', 'Scale'],
    this.onKeyingSetChanged,
    this.onKeyingSetAdd,
    this.onKeyingSetRemove,
    this.onKeyframeInsert,
    this.onKeyframeDelete,
    this.editorType = BlenderEditorType.outliner,
    this.onEditorTypeChanged,
    this.expandedIds,
    this.onExpandedChanged,
  });

  final List<BlenderTreeNode<T>> roots;
  final String? selectedId;
  final ValueChanged<BlenderTreeNode<T>>? onSelected;
  final bool showVisibility;
  final bool showLock;
  final ValueChanged<BlenderTreeNode<T>>? onVisibilityChanged;
  final ValueChanged<BlenderTreeNode<T>>? onLockChanged;
  final String title;
  final List<Widget>? headerActions;
  final TextEditingController? filterController;
  final ValueChanged<String>? onFilterChanged;
  final String filterPlaceholder;
  final BlenderOutlinerDisplayMode displayMode;
  final ValueChanged<BlenderOutlinerDisplayMode>? onDisplayModeChanged;
  final bool syncSelection;
  final ValueChanged<bool>? onSyncSelectionChanged;
  final String libraryOverrideViewMode;
  final ValueChanged<String>? onLibraryOverrideViewModeChanged;
  final bool useIdFilter;
  final ValueChanged<bool>? onIdFilterChanged;
  final String idFilterType;
  final List<String> idFilterTypes;
  final ValueChanged<String>? onIdFilterTypeChanged;
  final VoidCallback? onNewCollection;
  final VoidCallback? onPurgeUnusedData;
  final bool hasActiveKeyingSet;
  final String activeKeyingSet;
  final List<String> keyingSets;
  final ValueChanged<String>? onKeyingSetChanged;
  final VoidCallback? onKeyingSetAdd;
  final VoidCallback? onKeyingSetRemove;
  final VoidCallback? onKeyframeInsert;
  final VoidCallback? onKeyframeDelete;

  /// The editor assigned to this area. Keeping this separate from
  /// [displayMode] mirrors Blender: the first control chooses the area editor,
  /// while the second chooses how the Outliner represents its data.
  final BlenderEditorType editorType;
  final ValueChanged<BlenderEditorType>? onEditorTypeChanged;
  final Set<String>? expandedIds;
  final ValueChanged<Set<String>>? onExpandedChanged;

  List<Widget> _buildSourceHeaderControls() {
    final controls = <Widget>[];
    switch (displayMode) {
      case BlenderOutlinerDisplayMode.videoSequencer:
        controls.add(
          BlenderIconButton(
            glyph: BlenderGlyph.sync,
            selected: syncSelection,
            onPressed: onSyncSelectionChanged == null
                ? null
                : () => onSyncSelectionChanged!(!syncSelection),
            tooltip: 'Sync Selection',
            size: 24,
          ),
        );
      case BlenderOutlinerDisplayMode.scenes:
      case BlenderOutlinerDisplayMode.viewLayer:
      case BlenderOutlinerDisplayMode.libraryOverrides:
        controls.add(const _BlenderOutlinerFilterMenu());
      case BlenderOutlinerDisplayMode.blenderFile:
      case BlenderOutlinerDisplayMode.unusedData:
        controls.add(
          BlenderIconButton(
            glyph: BlenderGlyph.filter,
            selected: useIdFilter,
            onPressed: onIdFilterChanged == null
                ? null
                : () => onIdFilterChanged!(!useIdFilter),
            tooltip: 'Filter ID Types',
            size: 24,
          ),
        );
        controls.add(
          SizedBox(
            width: 86,
            child: BlenderDropdown<String>(
              value: idFilterType,
              items: <BlenderMenuItem<String>>[
                for (final type in idFilterTypes)
                  BlenderMenuItem<String>(value: type, label: type),
              ],
              compact: true,
              enabled: useIdFilter,
              onChanged: onIdFilterTypeChanged ?? (_) {},
            ),
          ),
        );
      case BlenderOutlinerDisplayMode.dataApi:
        controls.add(
          BlenderIconButton(
            glyph: BlenderGlyph.plus,
            onPressed: onKeyingSetAdd,
            tooltip: 'Add Selected to Keying Set',
            size: 24,
          ),
        );
        controls.add(
          BlenderIconButton(
            glyph: BlenderGlyph.minus,
            onPressed: onKeyingSetRemove,
            tooltip: 'Remove Selected from Keying Set',
            size: 24,
          ),
        );
        if (hasActiveKeyingSet) {
          controls.add(
            SizedBox(
              width: 92,
              child: BlenderDropdown<String>(
                value: activeKeyingSet,
                items: <BlenderMenuItem<String>>[
                  for (final keyingSet in keyingSets)
                    BlenderMenuItem<String>(value: keyingSet, label: keyingSet),
                ],
                compact: true,
                onChanged: onKeyingSetChanged ?? (_) {},
              ),
            ),
          );
          controls.add(
            BlenderIconButton(
              glyph: BlenderGlyph.keyframe,
              onPressed: onKeyframeInsert,
              tooltip: 'Insert Keyframe',
              size: 24,
            ),
          );
          controls.add(
            BlenderIconButton(
              glyph: BlenderGlyph.keyframe,
              onPressed: onKeyframeDelete,
              tooltip: 'Delete Keyframe',
              size: 24,
            ),
          );
        } else {
          controls.add(const Text('No Keying Set Active'));
        }
    }
    if (displayMode == BlenderOutlinerDisplayMode.libraryOverrides) {
      controls.insert(
        0,
        SizedBox(
          width: 92,
          child: BlenderDropdown<String>(
            value: libraryOverrideViewMode,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Hierarchies',
                label: 'Hierarchies',
              ),
              BlenderMenuItem<String>(value: 'Properties', label: 'Properties'),
            ],
            compact: true,
            onChanged: onLibraryOverrideViewModeChanged ?? (_) {},
          ),
        ),
      );
    }
    if (displayMode == BlenderOutlinerDisplayMode.viewLayer) {
      controls.add(
        BlenderIconButton(
          glyph: BlenderGlyph.plus,
          onPressed: onNewCollection,
          tooltip: 'Add collection',
          size: 24,
        ),
      );
    } else if (displayMode == BlenderOutlinerDisplayMode.unusedData) {
      controls.add(
        BlenderButton(
          label: 'Purge',
          variant: BlenderButtonVariant.toolbar,
          onPressed: onPurgeUnusedData,
        ),
      );
    }
    return controls;
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderEditorFrame(
      backgroundColor: theme.colors.surface,
      child: Column(
        children: <Widget>[
          BlenderToolbar(
            height: 30,
            scrollable: true,
            children: <Widget>[
              BlenderEditorTypeSelector(
                value: editorType,
                compact: true,
                width: 42,
                onChanged: onEditorTypeChanged,
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 42,
                child: BlenderDropdown<BlenderOutlinerDisplayMode>(
                  value: displayMode,
                  compact: true,
                  items: <BlenderMenuItem<BlenderOutlinerDisplayMode>>[
                    for (final mode in BlenderOutlinerDisplayMode.values)
                      BlenderMenuItem<BlenderOutlinerDisplayMode>(
                        value: mode,
                        label: BlenderOutlinerDisplayModePresentation.of(
                          mode,
                        ).label,
                        icon: BlenderIcon(
                          BlenderOutlinerDisplayModePresentation.of(mode).glyph,
                          size: 16,
                        ),
                      ),
                  ],
                  onChanged: onDisplayModeChanged ?? (_) {},
                ),
              ),
              if (filterController != null &&
                  !(displayMode ==
                          BlenderOutlinerDisplayMode.libraryOverrides &&
                      libraryOverrideViewMode == 'Hierarchies'))
                SizedBox(
                  width: 108,
                  child: BlenderSearchField(
                    controller: filterController!,
                    onChanged: onFilterChanged,
                    placeholder: filterPlaceholder,
                  ),
                ),
              ...?headerActions,
              ..._buildSourceHeaderControls(),
            ],
          ),
          Expanded(
            child: BlenderTree<T>(
              roots: roots,
              selectedId: selectedId,
              onSelected: onSelected,
              showVisibility: showVisibility,
              showLock: showLock,
              onVisibilityChanged: onVisibilityChanged,
              onLockChanged: onLockChanged,
              expandedIds: expandedIds,
              onExpandedChanged: onExpandedChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlenderOutlinerFilterMenu extends StatelessWidget {
  const _BlenderOutlinerFilterMenu();

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPopover(
      targetAnchor: Alignment.bottomRight,
      followerAnchor: Alignment.topRight,
      child: const BlenderIconButton(
        glyph: BlenderGlyph.filter,
        tooltip: 'Filter options',
        size: 28,
      ),
      popover: (context, close) {
        var sortAlphabetically = true;
        var syncSelection = true;
        var showModeColumn = true;
        var collections = true;
        var objects = true;
        var objectContents = true;
        var objectChildren = true;
        var meshes = true;
        var lights = true;
        var cameras = true;
        var empties = true;
        Widget option(String label, bool value, ValueChanged<bool> onChanged) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: BlenderCheckbox(
              value: value,
              label: label,
              onChanged: onChanged,
            ),
          );
        }

        return StatefulBuilder(
          builder: (context, setState) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350, maxHeight: 590),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.menuBackground,
                border: Border.all(color: theme.colors.borderSubtle),
                borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x99000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Restriction Toggles',
                      style: theme.textTheme.body.copyWith(
                        color: theme.colors.foregroundMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: const <Widget>[
                        BlenderIconButton(
                          glyph: BlenderGlyph.check,
                          selected: true,
                          size: 28,
                        ),
                        BlenderIconButton(
                          glyph: BlenderGlyph.pointer,
                          size: 28,
                        ),
                        BlenderIconButton(
                          glyph: BlenderGlyph.eye,
                          selected: true,
                          size: 28,
                        ),
                        BlenderIconButton(glyph: BlenderGlyph.lock, size: 28),
                      ],
                    ),
                    const SizedBox(height: 12),
                    option(
                      'Sort Alphabetically',
                      sortAlphabetically,
                      (value) => setState(() => sortAlphabetically = value),
                    ),
                    option(
                      'Sync Selection',
                      syncSelection,
                      (value) => setState(() => syncSelection = value),
                    ),
                    option(
                      'Show Mode Column',
                      showModeColumn,
                      (value) => setState(() => showModeColumn = value),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Filter',
                      style: theme.textTheme.body.copyWith(
                        color: theme.colors.foregroundMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    option(
                      'Collections',
                      collections,
                      (value) => setState(() => collections = value),
                    ),
                    option(
                      'Objects',
                      objects,
                      (value) => setState(() => objects = value),
                    ),
                    option(
                      'Object Contents',
                      objectContents,
                      (value) => setState(() => objectContents = value),
                    ),
                    option(
                      'Object Children',
                      objectChildren,
                      (value) => setState(() => objectChildren = value),
                    ),
                    option(
                      'Meshes',
                      meshes,
                      (value) => setState(() => meshes = value),
                    ),
                    option(
                      'Lights',
                      lights,
                      (value) => setState(() => lights = value),
                    ),
                    option(
                      'Cameras',
                      cameras,
                      (value) => setState(() => cameras = value),
                    ),
                    option(
                      'Empties',
                      empties,
                      (value) => setState(() => empties = value),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
