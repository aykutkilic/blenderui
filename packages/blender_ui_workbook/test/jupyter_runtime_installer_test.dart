import 'dart:io';

import 'package:blender_ui_workbook/blender_ui_workbook.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reports an unavailable Python without throwing', () async {
    final installer = JupyterRuntimeInstaller();
    addTearDown(installer.dispose);

    final result = await installer.inspect(
      '/definitely/missing/blenderui-workbook-python',
    );

    expect(result.available, isFalse);
    expect(installer.state, JupyterRuntimeInstallState.unavailable);
    expect(installer.detail, contains('Python could not start'));
  });

  test('derives the managed interpreter for the host platform', () {
    final executable = JupyterRuntimeInstaller.managedPythonExecutable(
      '/support/runtime',
    );
    expect(
      executable,
      Platform.isWindows
          ? r'/support/runtime\Scripts\python.exe'
          : '/support/runtime/bin/python',
    );
  });
}
