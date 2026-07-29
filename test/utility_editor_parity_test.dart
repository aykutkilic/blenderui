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

  testWidgets('Text editor supports caller-owned editing state', (
    tester,
  ) async {
    final firstController = TextEditingController(text: 'first\nsecond');
    final secondController = TextEditingController(text: 'replacement');
    final firstFocusNode = FocusNode();
    final secondFocusNode = FocusNode();
    addTearDown(firstController.dispose);
    addTearDown(secondController.dispose);
    addTearDown(firstFocusNode.dispose);
    addTearDown(secondFocusNode.dispose);

    await tester.pumpWidget(
      harness(
        BlenderTextEditor(
          title: null,
          controller: firstController,
          focusNode: firstFocusNode,
        ),
      ),
    );

    var editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.controller, same(firstController));
    expect(editable.focusNode, same(firstFocusNode));
    firstController.value = const TextEditingValue(
      text: 'first\nsecond\nthird',
      selection: TextSelection(baseOffset: 6, extentOffset: 12),
    );
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    expect(
      firstController.selection.textInside(firstController.text),
      'second',
    );

    await tester.pumpWidget(
      harness(
        BlenderTextEditor(
          title: null,
          controller: secondController,
          focusNode: secondFocusNode,
        ),
      ),
    );
    editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.controller, same(secondController));
    expect(editable.focusNode, same(secondFocusNode));

    await tester.pumpWidget(harness(const SizedBox.shrink()));
    firstController.text = 'caller still owns first';
    secondController.text = 'caller still owns second';
    expect(firstController.text, 'caller still owns first');
    expect(secondController.text, 'caller still owns second');
  });

  testWidgets('Text editor keeps a long line gutter bounded and scrollable', (
    tester,
  ) async {
    final controller = TextEditingController(
      text: List<String>.generate(
        200,
        (index) => 'line ${index + 1}',
      ).join('\n'),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 420,
          height: 120,
          child: BlenderTextEditor(title: null, controller: controller),
        ),
      ),
    );
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(EditableText), const Offset(0, -500));
    await tester.pump();
    expect(tester.takeException(), isNull);
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
