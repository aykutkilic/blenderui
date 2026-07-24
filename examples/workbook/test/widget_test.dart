import 'package:blender_ui/blender_ui.dart';
import 'package:blender_ui_workbook/blender_ui_workbook.dart';
import 'package:blender_ui_workbook_example/src/workbook_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(initializeWorkbookEditor);

  testWidgets('opens the workbook shell before a runtime is connected', (
    tester,
  ) async {
    await tester.pumpWidget(const WorkbookExampleApp(startRuntime: false));
    await tester.pump();

    expect(find.text('Math and AI Workbook'), findsWidgets);
    expect(
      find.text('Offline — editing and file access are available'),
      findsOneWidget,
    );
    expect(find.text('Kernel: disconnected'), findsOneWidget);
    expect(find.text('Jupyter could not start'), findsNothing);
  });

  testWidgets('opens shared configuration from Edit Preferences', (
    tester,
  ) async {
    await tester.pumpWidget(const WorkbookExampleApp(startRuntime: false));
    await tester.tap(find.text('Edit'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('Preferences…'), findsOneWidget);
    await tester.tap(find.text('Preferences…'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 180));

    expect(find.text('Workbook Preferences'), findsWidgets);
    expect(find.text('Python and Jupyter'), findsOneWidget);
    expect(find.text('Offline (edit and read files)'), findsOneWidget);
    expect(find.text('Interface'), findsOneWidget);
    expect(find.text('Themes'), findsOneWidget);
    expect(find.text('Keymap'), findsOneWidget);
  });

  testWidgets('scopes BlenderUI state, keymap, and docked workspaces', (
    tester,
  ) async {
    await tester.pumpWidget(const WorkbookExampleApp(startRuntime: false));
    await tester.pump();
    final context = tester.element(find.byType(WorkbookView));

    final workspaces =
        BlenderServiceScope.read<BlenderWorkspaceService<String>>(context);
    final bindings = BlenderServiceScope.read<BlenderCommandBindings>(context);
    final editorSession = BlenderServiceScope.read<BlenderEditorSessionService>(
      context,
    );

    expect(workspaces.workspaces, hasLength(3));
    expect(
      BlenderServiceScope.maybeRead<BlenderInterfacePreferencesService>(
        context,
      ),
      isNotNull,
    );
    expect(
      BlenderServiceScope.maybeRead<BlenderThemeService>(context),
      isNotNull,
    );
    expect(
      bindings.bindings.any(
        (binding) => binding.commandId == 'workbook.file.open',
      ),
      isTrue,
    );
    expect(
      editorSession.viewForArea(
        workspaceId: 'workbook',
        areaId: 'workbook-main',
      ),
      'workbook',
    );
    expect(
      BlenderStateScope.read<WorkbookDocument>(context),
      isA<BlenderHistoryStore<WorkbookDocument>>(),
    );

    workspaces.selectWorkspace('scripting');
    await tester.pump();
    expect(find.text('Document Outline'), findsOneWidget);
    expect(find.byType(BlenderDockingWorkspace<String>), findsOneWidget);
  });
}
