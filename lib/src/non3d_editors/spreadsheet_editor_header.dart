part of '../non3d_editors.dart';

@immutable
class BlenderSpreadsheetEditorHeaderState {
  const BlenderSpreadsheetEditorHeaderState({
    this.onlySelected = false,
    this.useFilter = false,
  });

  final bool onlySelected;
  final bool useFilter;

  BlenderSpreadsheetEditorHeaderState copyWith({
    bool? onlySelected,
    bool? useFilter,
  }) => BlenderSpreadsheetEditorHeaderState(
    onlySelected: onlySelected ?? this.onlySelected,
    useFilter: useFilter ?? this.useFilter,
  );
}

/// Source-shaped Spreadsheet header with context-aware selection filtering.
class BlenderSpreadsheetEditorHeader extends StatelessWidget {
  const BlenderSpreadsheetEditorHeader({
    super.key,
    this.state = const BlenderSpreadsheetEditorHeaderState(),
    this.onEditorTypeChanged,
    this.onStateChanged,
    this.onCommand,
    this.selectionFilterAvailable = true,
    this.height = 30,
  });

  final BlenderSpreadsheetEditorHeaderState state;
  final ValueChanged<BlenderEditorType>? onEditorTypeChanged;
  final ValueChanged<BlenderSpreadsheetEditorHeaderState>? onStateChanged;
  final ValueChanged<String>? onCommand;
  final bool selectionFilterAvailable;
  final double height;

  void _update(BlenderSpreadsheetEditorHeaderState value) =>
      onStateChanged?.call(value);

  @override
  Widget build(BuildContext context) => BlenderAreaHeader(
    height: height,
    editorType: BlenderEditorType.spreadsheet,
    showEditorLabel: false,
    onEditorTypeChanged: onEditorTypeChanged,
    menuDescriptors: BlenderEditorMenuCatalog.build(
      const <String>['View'],
      menuItems: const <String, List<String>>{
        'View': <String>['Toolbar', 'Sidebar', 'Internal Attributes', 'Area'],
      },
      onSelected: onCommand,
    ),
    actions: <Widget>[
      BlenderIconButton(
        key: const ValueKey<String>('spreadsheet-only-selected-button'),
        glyph: BlenderGlyph.eye,
        selected: state.onlySelected,
        enabled: selectionFilterAvailable,
        onPressed: () =>
            _update(state.copyWith(onlySelected: !state.onlySelected)),
        tooltip: 'Only Selected',
      ),
      BlenderIconButton(
        key: const ValueKey<String>('spreadsheet-filter-button'),
        glyph: BlenderGlyph.filter,
        selected: state.useFilter,
        onPressed: () => _update(state.copyWith(useFilter: !state.useFilter)),
        tooltip: 'Use Filter',
      ),
      const BlenderIconButton(
        glyph: BlenderGlyph.more,
        tooltip: 'Editor options',
      ),
    ],
  );
}
