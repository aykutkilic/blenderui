import 'dart:io';

import 'package:blender_ui_workbook_example/src/workbook_runtime_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults to offline and persists non-secret runtime choices', () async {
    final directory = await Directory.systemTemp.createTemp(
      'workbook-settings',
    );
    addTearDown(() => directory.delete(recursive: true));
    final store = WorkbookRuntimeSettingsStore(
      File('${directory.path}/runtime.json'),
    );

    expect((await store.load()).mode, WorkbookRuntimeMode.offline);
    const settings = WorkbookRuntimeSettings(
      mode: WorkbookRuntimeMode.custom,
      autoConnect: true,
      pythonExecutable: '/opt/python',
    );
    await store.save(settings);

    final restored = await store.load();
    expect(restored.mode, WorkbookRuntimeMode.custom);
    expect(restored.autoConnect, isTrue);
    expect(restored.pythonExecutable, '/opt/python');
    expect(await store.file.readAsString(), isNot(contains('token')));
  });
}
