import 'dart:io';

import 'package:blender_ui_workbook/blender_ui_workbook.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blender_ui_workbook_example/src/workbook_shadow_file_manager.dart';

void main() {
  test(
    'prepares current code cells and removes stale app-owned shadows',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'workbook-shadow-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final manager = WorkbookShadowFileManager(
        loadHelper: () async => '# workbook helper',
      );
      final code = WorkbookCell(id: 'code/cell', source: 'answer = 42');
      final markdown = WorkbookCell(
        id: 'notes',
        kind: WorkbookCellKind.markdown,
        source: '# Notes',
      );

      await manager.synchronize(
        workspace: directory,
        document: WorkbookDocument(
          id: 'first',
          title: 'First',
          cells: <WorkbookCell>[code, markdown],
        ),
      );

      final path = manager.pathFor(directory, code);
      expect(path, isNotNull);
      expect(await File(path!).readAsString(), 'answer = 42');
      expect(manager.pathFor(directory, markdown), isNull);
      expect(
        await File('${directory.path}/blenderui_workbook.py').readAsString(),
        '# workbook helper',
      );

      await manager.synchronize(
        workspace: directory,
        document: WorkbookDocument(
          id: 'second',
          title: 'Second',
          cells: <WorkbookCell>[markdown],
        ),
      );

      expect(manager.pathFor(directory, code), isNull);
      expect(await File(path).exists(), isFalse);
    },
  );
}
