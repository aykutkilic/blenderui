import 'dart:io';

import 'package:blender_ui_workbook/blender_ui_workbook.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final python = Platform.environment['WORKBOOK_LIVE_JUPYTER'];
  test(
    'starts Jupyter, executes Python, and receives rich plot MIME',
    () async {
      final workspace = await Directory.systemTemp.createTemp(
        'blenderui-jupyter-test-',
      );
      final helper = File('python/blenderui_workbook.py');
      await helper.copy('${workspace.path}/blenderui_workbook.py');
      final server = await JupyterServerProcess.start(
        JupyterServerConfiguration(
          workspacePath: workspace.path,
          pythonExecutable: python!,
        ),
      );
      final kernel = JupyterKernel(
        serverUri: server.baseUri,
        token: server.token,
      );
      try {
        await kernel.connect();
        final textResult = await kernel.execute('print("kernel-ready")');
        expect(textResult.succeeded, isTrue);
        expect(
          textResult.outputs.whereType<WorkbookStreamOutput>().single.text,
          contains('kernel-ready'),
        );

        final plotResult = await kernel.execute('''
from blenderui_workbook import xy
xy([0, 1, 2], [0, 1, 4], title="Live plot")
''');
        final display = plotResult.outputs
            .whereType<WorkbookDisplayOutput>()
            .firstWhere(
              (output) => output.data.containsKey(WorkbookPlotSpec.mimeType),
            );
        expect(
          display.data[WorkbookPlotSpec.mimeType],
          isA<Map<String, Object?>>(),
        );
      } finally {
        await kernel.dispose();
        await server.stop();
        await workspace.delete(recursive: true);
      }
    },
    skip: python == null
        ? 'Set WORKBOOK_LIVE_JUPYTER to a Python with jupyter_server.'
        : false,
    timeout: const Timeout(Duration(minutes: 1)),
  );
}
