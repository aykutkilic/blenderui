import 'dart:io';

import 'package:blender_ui_workbook/blender_ui_workbook.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final basePython = Platform.environment['WORKBOOK_INSTALL_BASE_PYTHON'];

  test(
    'creates and installs a complete managed Jupyter runtime',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'blenderui-managed-jupyter-',
      );
      addTearDown(() async {
        if (await directory.exists()) await directory.delete(recursive: true);
      });
      final runtimeDirectory = '${directory.path}/runtime';
      final installer = JupyterRuntimeInstaller();
      addTearDown(installer.dispose);

      final python = await installer.install(
        basePythonExecutable: basePython!,
        runtimeDirectory: runtimeDirectory,
      );

      expect(File(python).existsSync(), isTrue);
      expect(installer.state, JupyterRuntimeInstallState.ready);
      expect((await installer.inspect(python)).available, isTrue);
    },
    skip: basePython == null
        ? 'Set WORKBOOK_INSTALL_BASE_PYTHON to exercise package installation.'
        : false,
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
