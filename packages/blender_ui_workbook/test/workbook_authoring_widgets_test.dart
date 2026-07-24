import 'package:blender_ui/blender_ui.dart';
import 'package:blender_ui_workbook/blender_ui_workbook.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('code editor geometry and typography survive selection changes', (
    tester,
  ) async {
    final controller = WorkbookSessionController(
      document: WorkbookDocument(
        id: 'stable-editors',
        title: 'Stable editors',
        cells: <WorkbookCell>[
          WorkbookCell(id: 'first', source: 'def first():\n    return 1'),
          WorkbookCell(id: 'second', source: 'def second():\n    return 2'),
        ],
      ),
    );
    await tester.pumpWidget(_host(WorkbookView(controller: controller)));

    final firstFinder = find.byKey(const ValueKey<String>('first:null'));
    expect(firstFinder, findsOneWidget);
    expect(find.byType(WorkbookCodeEditor), findsNWidgets(2));
    final initialSize = tester.getSize(firstFinder);
    final initialStyle = tester
        .widget<WorkbookCodeEditor>(firstFinder)
        .textStyle;

    controller.selectCell('second');
    await tester.pump();

    expect(firstFinder, findsOneWidget);
    expect(find.byType(WorkbookCodeEditor), findsNWidgets(2));
    expect(tester.getSize(firstFinder), initialSize);
    expect(
      tester.widget<WorkbookCodeEditor>(firstFinder).textStyle,
      initialStyle,
    );
    controller.dispose();
  });

  testWidgets('renders GitHub-flavored Markdown and LaTeX without a kernel', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const SingleChildScrollView(
          child: WorkbookMarkdownPreview(
            source: r'''# Formula

| variable | value |
| --- | --- |
| energy | $E = mc^2$ |

$$
\int_0^1 x^2\,dx = \frac{1}{3}
$$''',
          ),
        ),
      ),
    );

    expect(find.text('Formula'), findsOneWidget);
    expect(find.text('variable'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _host(Widget child) => MaterialApp(
  home: BlenderTheme(
    child: Scaffold(body: SizedBox(width: 900, height: 700, child: child)),
  ),
);
