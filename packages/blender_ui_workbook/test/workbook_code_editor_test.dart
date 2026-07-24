import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blender_ui_workbook/blender_ui_workbook.dart';

void main() {
  setUpAll(initializeWorkbookEditor);

  testWidgets(
    'attaching a CodeForge editor does not notify during the build phase',
    (tester) async {
      if (!isWorkbookEditorInitialized) return;
      final controller = CodeForgeController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            height: 200,
            child: WorkbookCodeEditor(controller: controller),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    },
  );
}
