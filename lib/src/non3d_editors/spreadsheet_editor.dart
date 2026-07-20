part of '../non3d_editors.dart';

class BlenderSpreadsheetColumn {
  const BlenderSpreadsheetColumn({
    required this.id,
    required this.label,
    this.width = 120,
    this.numeric = false,
  });

  final String id;
  final String label;
  final double width;

  /// Aligns data to the trailing edge, matching Blender's numeric columns.
  final bool numeric;
}

class BlenderSpreadsheetRow {
  const BlenderSpreadsheetRow({
    required this.id,
    required this.values,
    this.selected = false,
  });

  final String id;
  final List<String> values;

  /// Whether the source geometry/component currently selects this row.
  final bool selected;
}

typedef BlenderSpreadsheetRowFilter =
    bool Function(BlenderSpreadsheetRow row, String query);

/// Sort direction requested from a Spreadsheet column header.
enum BlenderSpreadsheetSortDirection { ascending, descending }

/// Reusable Spreadsheet table with hostable filter, sort and scroll state.
///
/// A single horizontal viewport contains both the column header and the data
/// rows, so their offsets cannot drift. The vertical controller is exposed for
/// hosts that synchronize the table with an adjacent data-set or statistics
/// region. Filtering and sorting are presentation callbacks; geometry access
/// and data extraction remain caller-owned.
class BlenderSpreadsheetEditor extends StatefulWidget {
  const BlenderSpreadsheetEditor({
    super.key,
    required this.columns,
    required this.rows,
    this.showOnlySelected = false,
    this.useFilter = false,
    this.filterQuery = '',
    this.rowFilter,
    this.sortColumnId,
    this.sortDirection = BlenderSpreadsheetSortDirection.ascending,
    this.onSortChanged,
    this.onRowSelected,
    this.horizontalController,
    this.verticalController,
    this.showRowNumbers = true,
    this.rowNumberWidth = 54,
    this.title = 'Spreadsheet',
  });

  final List<BlenderSpreadsheetColumn> columns;
  final List<BlenderSpreadsheetRow> rows;
  final bool showOnlySelected;
  final bool useFilter;
  final String filterQuery;
  final BlenderSpreadsheetRowFilter? rowFilter;
  final String? sortColumnId;
  final BlenderSpreadsheetSortDirection sortDirection;
  final void Function(
    String columnId,
    BlenderSpreadsheetSortDirection direction,
  )?
  onSortChanged;
  final ValueChanged<BlenderSpreadsheetRow>? onRowSelected;
  final ScrollController? horizontalController;
  final ScrollController? verticalController;
  final bool showRowNumbers;
  final double rowNumberWidth;
  final String? title;

  @override
  State<BlenderSpreadsheetEditor> createState() =>
      _BlenderSpreadsheetEditorState();
}

class _BlenderSpreadsheetEditorState extends State<BlenderSpreadsheetEditor> {
  ScrollController? _ownedHorizontalController;
  ScrollController? _ownedVerticalController;

  ScrollController get _horizontalController =>
      widget.horizontalController ??
      (_ownedHorizontalController ??= ScrollController());

  ScrollController get _verticalController =>
      widget.verticalController ??
      (_ownedVerticalController ??= ScrollController());

  @override
  void didUpdateWidget(covariant BlenderSpreadsheetEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.horizontalController == null &&
        widget.horizontalController != null) {
      _ownedHorizontalController?.dispose();
      _ownedHorizontalController = null;
    }
    if (oldWidget.verticalController == null &&
        widget.verticalController != null) {
      _ownedVerticalController?.dispose();
      _ownedVerticalController = null;
    }
  }

  @override
  void dispose() {
    _ownedHorizontalController?.dispose();
    _ownedVerticalController?.dispose();
    super.dispose();
  }

  bool _matchesFilter(BlenderSpreadsheetRow row) {
    if (widget.showOnlySelected && !row.selected) return false;
    if (!widget.useFilter) return true;
    final query = widget.filterQuery.trim().toLowerCase();
    if (widget.rowFilter case final filter?) return filter(row, query);
    if (query.isEmpty) return true;
    return row.id.toLowerCase().contains(query) ||
        row.values.any((value) => value.toLowerCase().contains(query));
  }

  List<BlenderSpreadsheetRow> get _visibleRows =>
      widget.rows.where(_matchesFilter).toList(growable: false);

  void _requestSort(BlenderSpreadsheetColumn column) {
    final next =
        widget.sortColumnId == column.id &&
            widget.sortDirection == BlenderSpreadsheetSortDirection.ascending
        ? BlenderSpreadsheetSortDirection.descending
        : BlenderSpreadsheetSortDirection.ascending;
    widget.onSortChanged?.call(column.id, next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final visibleRows = _visibleRows;
    final contentWidth =
        widget.columns.fold<double>(0, (sum, column) => sum + column.width) +
        (widget.showRowNumbers ? widget.rowNumberWidth : 0);

    Widget cell(
      String text,
      double width, {
      bool header = false,
      bool numeric = false,
    }) => SizedBox(
      width: width,
      height: theme.density.rowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Align(
          alignment: numeric ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: (header ? theme.textTheme.heading : theme.textTheme.label)
                .copyWith(
                  color: header
                      ? theme.colors.foreground
                      : theme.colors.foregroundMuted,
                ),
          ),
        ),
      ),
    );

    Widget dataRow(
      List<Widget> cells, {
      required int index,
      BlenderSpreadsheetRow? data,
      bool header = false,
    }) {
      final child = DecoratedBox(
        decoration: BoxDecoration(
          color: header
              ? theme.colors.panelHeader
              : index.isEven
              ? theme.colors.surface
              : null,
          border: Border(bottom: BorderSide(color: theme.colors.editorBorder)),
        ),
        child: Row(children: cells),
      );
      if (data == null || widget.onRowSelected == null) return child;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onRowSelected!(data),
        child: child,
      );
    }

    final table = LayoutBuilder(
      builder: (context, constraints) => BlenderScrollbar(
        controller: _horizontalController,
        child: SingleChildScrollView(
          controller: _horizontalController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: math.max(contentWidth, constraints.maxWidth),
            child: Column(
              children: <Widget>[
                dataRow(
                  <Widget>[
                    if (widget.showRowNumbers)
                      cell('Index', widget.rowNumberWidth, header: true),
                    for (final column in widget.columns)
                      SizedBox(
                        width: column.width,
                        height: theme.density.rowHeight,
                        child: BlenderButton(
                          label: column.label,
                          variant: BlenderButtonVariant.toolbar,
                          onPressed: widget.onSortChanged == null
                              ? null
                              : () => _requestSort(column),
                          trailing: widget.sortColumnId == column.id
                              ? BlenderIcon(
                                  widget.sortDirection ==
                                          BlenderSpreadsheetSortDirection
                                              .ascending
                                      ? BlenderGlyph.chevronUp
                                      : BlenderGlyph.chevronDown,
                                  size: 12,
                                )
                              : null,
                        ),
                      ),
                  ],
                  index: 0,
                  header: true,
                ),
                Expanded(
                  child: BlenderScrollbar(
                    controller: _verticalController,
                    child: ListView.builder(
                      controller: _verticalController,
                      itemCount: visibleRows.length,
                      itemBuilder: (context, index) {
                        final data = visibleRows[index];
                        return dataRow(
                          <Widget>[
                            if (widget.showRowNumbers)
                              cell(
                                data.id,
                                widget.rowNumberWidth,
                                numeric: true,
                              ),
                            for (
                              var columnIndex = 0;
                              columnIndex < widget.columns.length;
                              columnIndex++
                            )
                              cell(
                                columnIndex < data.values.length
                                    ? data.values[columnIndex]
                                    : '',
                                widget.columns[columnIndex].width,
                                numeric: widget.columns[columnIndex].numeric,
                              ),
                          ],
                          index: index,
                          data: data,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.title == null) return table;
    return BlenderPanel(
      title: widget.title!,
      padding: EdgeInsets.zero,
      child: table,
    );
  }
}
