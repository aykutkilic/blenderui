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

  testWidgets('cell run controls follow the active interface theme', (
    tester,
  ) async {
    final controller = WorkbookSessionController(
      document: WorkbookDocument(
        id: 'theme-controls',
        title: 'Theme controls',
        cells: <WorkbookCell>[WorkbookCell(id: 'cell', source: '1 + 1')],
      ),
    );
    final themeKey = GlobalKey<_ThemeSwitchHostState>();
    await tester.pumpWidget(
      _ThemeSwitchHost(
        key: themeKey,
        child: WorkbookView(controller: controller),
      ),
    );

    final runButton = find.byType(IconButton).first;
    final darkForeground = tester.widget<IconButton>(runButton).color;
    themeKey.currentState!.useLightTheme = true;
    await tester.pump();
    final lightForeground = tester.widget<IconButton>(runButton).color;

    expect(darkForeground, isNot(equals(lightForeground)));
    controller.dispose();
  });
}

Widget _host(Widget child) => MaterialApp(
  home: BlenderTheme(
    child: Scaffold(body: SizedBox(width: 900, height: 700, child: child)),
  ),
);

final class _ThemeSwitchHost extends StatefulWidget {
  const _ThemeSwitchHost({required this.child, super.key});

  final Widget child;

  @override
  State<_ThemeSwitchHost> createState() => _ThemeSwitchHostState();
}

final class _ThemeSwitchHostState extends State<_ThemeSwitchHost> {
  bool _useLightTheme = false;

  set useLightTheme(bool value) {
    if (_useLightTheme == value) return;
    setState(() => _useLightTheme = value);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: BlenderTheme(
      data: _useLightTheme ? BlenderThemeData.light : BlenderThemeData.dark,
      child: Scaffold(
        body: SizedBox(width: 900, height: 700, child: widget.child),
      ),
    ),
  );
}
