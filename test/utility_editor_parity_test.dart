import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget harness(Widget child) =>
      BlenderApp(home: SizedBox(width: 640, height: 320, child: child));

  testWidgets('Text footer reports cursor, syntax, and insert mode', (
    tester,
  ) async {
    var overwrite = false;
    await tester.pumpWidget(
      harness(
        StatefulBuilder(
          builder: (context, setState) => BlenderTextEditor(
            title: null,
            text: 'print("Hello")',
            footer: BlenderTextEditorFooter(
              line: 4,
              column: 12,
              selectionCharacters: 3,
              syntax: 'Python',
              overwrite: overwrite,
              onOverwriteChanged: (value) => setState(() => overwrite = value),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Ln 4, Col 12'), findsOneWidget);
    expect(find.text('3 selected'), findsOneWidget);
    await tester.tap(find.text('INS'));
    await tester.pump();
    expect(find.text('OVR'), findsOneWidget);
  });

  testWidgets('Console walks caller-owned command history', (tester) async {
    await tester.pumpWidget(
      harness(
        const BlenderConsoleEditor(
          title: null,
          history: <String>['first()', 'second()'],
        ),
      ),
    );

    await tester.tap(find.byType(EditableText));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      'second()',
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      'first()',
    );
  });

  testWidgets('Info filters severity and reports selected row IDs', (
    tester,
  ) async {
    Set<String>? selected;
    await tester.pumpWidget(
      harness(
        BlenderInfoEditor(
          title: null,
          reports: const <BlenderInfoReport>[
            BlenderInfoReport(
              id: 'info',
              message: 'Information',
              level: BlenderNoticeLevel.info,
            ),
            BlenderInfoReport(
              id: 'error',
              message: 'Failure',
              level: BlenderNoticeLevel.error,
            ),
          ],
          visibleLevels: const <BlenderNoticeLevel>{BlenderNoticeLevel.error},
          onSelectionChanged: (value) => selected = value,
        ),
      ),
    );

    expect(find.text('Information'), findsNothing);
    await tester.tap(find.text('Failure'));
    expect(selected, <String>{'error'});
  });

  testWidgets('shared Annotation settings emit immutable replacement state', (
    tester,
  ) async {
    var state = const BlenderAnnotationSettings();
    await tester.pumpWidget(
      harness(
        StatefulBuilder(
          builder: (context, setState) => BlenderAnnotationSettingsPanel(
            expanded: true,
            state: state,
            onChanged: (value) => setState(() => state = value),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Annotation'));
    await tester.pump();
    expect(state.visible, isFalse);
    expect(find.text('Main'), findsOneWidget);
  });
}
