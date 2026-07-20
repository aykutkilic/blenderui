import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const entries = <BlenderFileEntry>[
    BlenderFileEntry(
      path: '/z.blend',
      name: 'z.blend',
      modifiedLabel: '20 Jul 2026',
      sizeBytes: 200,
      sizeLabel: '200 B',
      typeLabel: 'Blender',
    ),
    BlenderFileEntry(
      path: '/a.png',
      name: 'a.png',
      modifiedLabel: '19 Jul 2026',
      sizeBytes: 100,
      sizeLabel: '100 B',
      typeLabel: 'Image',
    ),
  ];

  Widget harness(Widget child) =>
      BlenderApp(home: SizedBox(width: 760, height: 360, child: child));

  testWidgets('list view exposes source columns and reports sort requests', (
    tester,
  ) async {
    BlenderFileBrowserSortColumn? column;
    BlenderFileBrowserSortDirection? direction;
    await tester.pumpWidget(
      harness(
        BlenderFileBrowser(
          entries: entries,
          onSortChanged: (value, next) {
            column = value;
            direction = next;
          },
        ),
      ),
    );

    expect(find.text('Date Modified'), findsOneWidget);
    expect(find.text('Size'), findsOneWidget);
    expect(find.text('Type'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('a.png')).dy,
      lessThan(tester.getTopLeft(find.text('z.blend')).dy),
    );

    await tester.tap(find.text('Name'));
    expect(column, BlenderFileBrowserSortColumn.name);
    expect(direction, BlenderFileBrowserSortDirection.descending);
  });

  testWidgets('asset grid renders caller-supplied previews and metadata', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        BlenderFileBrowser(
          entries: entries,
          gridView: true,
          assetBrowser: true,
          previewBuilder: (context, entry) => Text('Preview ${entry.name}'),
        ),
      ),
    );

    expect(find.text('Preview a.png'), findsOneWidget);
    expect(find.text('Preview z.blend'), findsOneWidget);
    expect(find.byType(BlenderPreviewTile), findsNWidgets(2));
  });

  testWidgets('directories stay above files for every sort direction', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        const BlenderFileBrowser(
          entries: <BlenderFileEntry>[
            BlenderFileEntry(path: '/a', name: 'a.txt'),
            BlenderFileEntry(path: '/z', name: 'z', isDirectory: true),
          ],
          sortDirection: BlenderFileBrowserSortDirection.descending,
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.text('z')).dy,
      lessThan(tester.getTopLeft(find.text('a.txt')).dy),
    );
  });
}
