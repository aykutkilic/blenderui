import 'package:blender_ui/blender_ui.dart';
import 'package:blender_ui_workbook/blender_ui_workbook.dart';
import 'package:blender_ui_workbook_example/src/workbook_runtime_controller.dart';
import 'package:blender_ui_workbook_example/src/workbook_runtime_settings.dart';
import 'package:blender_ui_workbook_example/src/workbook_shadow_file_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps optional runtime state outside the workbook session', () async {
    final document = WorkbookDocument(
      id: 'offline',
      title: 'Offline document',
      cells: <WorkbookCell>[
        WorkbookCell(id: 'cell', source: 'value = 1'),
      ],
    );
    final application = BlenderApplicationController<WorkbookDocument>(
      initialState: document,
    );
    final session = WorkbookSessionController(
      document: document,
      history: application.state,
    );
    final installer = JupyterRuntimeInstaller();
    final runtime = WorkbookRuntimeController(
      session: session,
      application: application,
      installer: installer,
      shadowFiles: WorkbookShadowFileManager(),
    );
    addTearDown(() {
      runtime.dispose();
      installer.dispose();
      session.dispose();
      application.dispose();
    });

    expect(runtime.settings.mode, WorkbookRuntimeMode.offline);
    expect(session.kernelState, WorkbookKernelState.disconnected);
    expect(runtime.workspace, isNull);

    runtime.updateRemoteToken('memory-only-token');
    await runtime.updateSettings(
      const WorkbookRuntimeSettings(
        mode: WorkbookRuntimeMode.offline,
        autoConnect: false,
      ),
    );
    await runtime.connect();

    expect(runtime.remoteToken, 'memory-only-token');
    expect(runtime.status, 'Offline — editing and file access are available');
    expect(session.document, same(document));
    expect(session.kernelState, WorkbookKernelState.disconnected);
  });
}
