part of '../non3d_editors.dart';

class BlenderSpreadsheetColumn {
  const BlenderSpreadsheetColumn({
    required this.id,
    required this.label,
    this.width = 120,
  });

  final String id;
  final String label;
  final double width;
}

class BlenderSpreadsheetRow {
  const BlenderSpreadsheetRow({required this.id, required this.values});

  final String id;
  final List<String> values;
}

class BlenderSpreadsheetEditor extends StatelessWidget {
  const BlenderSpreadsheetEditor({
    super.key,
    required this.columns,
    required this.rows,
    this.showOnlySelected = false,
    this.useFilter = false,
    this.title = 'Spreadsheet',
  });

  final List<BlenderSpreadsheetColumn> columns;
  final List<BlenderSpreadsheetRow> rows;
  final bool showOnlySelected;
  final bool useFilter;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    Widget row(List<Widget> cells, {Color? color}) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          border: Border(bottom: BorderSide(color: theme.colors.editorBorder)),
        ),
        child: Row(children: cells),
      );
    }

    Widget cell(String text, double width, {bool header = false}) {
      return SizedBox(
        width: width,
        height: theme.density.rowHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Align(
            alignment: Alignment.centerLeft,
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
    }

    final grid = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: columns.fold<double>(0, (sum, column) => sum + column.width),
        child: Column(
          children: <Widget>[
            row([
              for (final column in columns)
                cell(column.label, column.width, header: true),
            ], color: theme.colors.panelHeader),
            Expanded(
              child: ListView.builder(
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final data = rows[index];
                  return row([
                    for (
                      var columnIndex = 0;
                      columnIndex < columns.length;
                      columnIndex++
                    )
                      cell(
                        columnIndex < data.values.length
                            ? data.values[columnIndex]
                            : '',
                        columns[columnIndex].width,
                      ),
                  ], color: index.isEven ? theme.colors.surface : null);
                },
              ),
            ),
          ],
        ),
      ),
    );
    return BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.panelHeader,
                border: Border(
                  bottom: BorderSide(color: theme.colors.editorBorder),
                ),
              ),
              child: Row(
                children: <Widget>[
                  BlenderIconButton(
                    glyph: BlenderGlyph.filter,
                    selected: useFilter,
                    tooltip: 'Use Filter',
                    onPressed: _spreadsheetNoop,
                    size: 26,
                  ),
                  BlenderCheckbox(
                    value: showOnlySelected,
                    label: 'Only Selected',
                    onChanged: _spreadsheetNoopBool,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Internal Attributes: hidden',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.caption.copyWith(
                          color: theme.colors.foregroundMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
          ),
          Expanded(child: grid),
        ],
      ),
    );
  }
}

void _spreadsheetNoop() {}

void _spreadsheetNoopBool(bool _) {}
