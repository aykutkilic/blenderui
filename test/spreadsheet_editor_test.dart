import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const columns = <BlenderSpreadsheetColumn>[
    BlenderSpreadsheetColumn(id: 'name', label: 'Name', width: 180),
    BlenderSpreadsheetColumn(
      id: 'value',
      label: 'Value',
      width: 180,
      numeric: true,
    ),
  ];
  const rows = <BlenderSpreadsheetRow>[
    BlenderSpreadsheetRow(
      id: '0',
      values: <String>['Cube', '1.0'],
      selected: true,
    ),
    BlenderSpreadsheetRow(id: '1', values: <String>['Sphere', '2.0']),
  ];

  Widget harness(Widget child) =>
      BlenderApp(home: SizedBox(width: 320, height: 220, child: child));

  testWidgets('filters source rows without owning geometry data', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        const BlenderSpreadsheetEditor(
          columns: columns,
          rows: rows,
          showOnlySelected: true,
          useFilter: true,
          filterQuery: 'cube',
        ),
      ),
    );

    expect(find.text('Cube'), findsOneWidget);
    expect(find.text('Sphere'), findsNothing);
    expect(find.text('Index'), findsOneWidget);
  });

  testWidgets('reports source-owned sort and row selection requests', (
    tester,
  ) async {
    String? columnId;
    BlenderSpreadsheetSortDirection? direction;
    String? selectedRowId;
    await tester.pumpWidget(
      harness(
        BlenderSpreadsheetEditor(
          columns: columns,
          rows: rows,
          sortColumnId: 'name',
          onSortChanged: (id, value) {
            columnId = id;
            direction = value;
          },
          onRowSelected: (row) => selectedRowId = row.id,
        ),
      ),
    );

    await tester.tap(find.text('Name'));
    await tester.tap(find.text('Sphere'));

    expect(columnId, 'name');
    expect(direction, BlenderSpreadsheetSortDirection.descending);
    expect(selectedRowId, '1');
  });

  testWidgets('accepts host-owned horizontal and vertical scroll state', (
    tester,
  ) async {
    final horizontal = ScrollController();
    final vertical = ScrollController();
    addTearDown(horizontal.dispose);
    addTearDown(vertical.dispose);

    await tester.pumpWidget(
      harness(
        BlenderSpreadsheetEditor(
          columns: const <BlenderSpreadsheetColumn>[
            BlenderSpreadsheetColumn(id: 'a', label: 'A', width: 400),
            BlenderSpreadsheetColumn(id: 'b', label: 'B', width: 400),
          ],
          rows: List<BlenderSpreadsheetRow>.generate(
            30,
            (index) => BlenderSpreadsheetRow(
              id: '$index',
              values: <String>['Row $index', '$index'],
            ),
          ),
          horizontalController: horizontal,
          verticalController: vertical,
        ),
      ),
    );

    horizontal.jumpTo(80);
    vertical.jumpTo(60);
    await tester.pump();

    expect(horizontal.offset, 80);
    expect(vertical.offset, 60);
  });
}
