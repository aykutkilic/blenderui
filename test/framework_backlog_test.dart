import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: BlenderTheme(child: child),
);

class _TrackingStorage implements BlenderPersistentStorage {
  final Map<String, String> values = <String, String>{};
  int reads = 0;
  int writes = 0;

  @override
  Future<String?> read(String key) async {
    reads++;
    return values[key];
  }

  @override
  Future<void> remove(String key) async => values.remove(key);

  @override
  Future<void> write(String key, String value) async {
    writes++;
    values[key] = value;
  }
}

class _TrackingEditorSessionService extends BlenderEditorSessionService {
  int disposals = 0;

  @override
  void dispose() {
    disposals++;
    super.dispose();
  }
}

void main() {
  test(
    'persistence coordinator memoizes restore and coalesces writes',
    () async {
      final storage = _TrackingStorage()..values['settings'] = 'restored';
      var current = 'initial';
      final coordinator = BlenderPersistenceCoordinator(
        storage: storage,
        storageKey: 'settings',
        serialize: () => current,
      );

      expect(
        await coordinator.restore((raw) {
          current = raw;
          return true;
        }),
        isTrue,
      );
      expect(await coordinator.restore((_) => false), isTrue);
      expect(storage.reads, 1);

      current = 'updated';
      coordinator
        ..scheduleWrite()
        ..scheduleWrite();
      await Future<void>.delayed(Duration.zero);
      expect(storage.writes, 1);
      expect(storage.values['settings'], 'updated');
      expect(coordinator.lastError, isNull);
    },
  );

  test('application controller delegates adopted service disposal', () {
    final editorSession = _TrackingEditorSessionService();
    final controller = BlenderApplicationController<int>(
      initialState: 0,
      editorSession: editorSession,
    );

    controller.dispose();
    expect(controller.services.isDisposed, isTrue);
    expect(editorSession.disposals, 1);
    controller.dispose();
    expect(editorSession.disposals, 1);
  });

  test(
    'editor area restores, persists, and falls back through one controller',
    () {
      final session = BlenderEditorSessionService()
        ..selectView(
          workspaceId: 'workspace',
          areaId: 'main',
          viewId: BlenderEditorType.timeline.name,
        );
      final controller = BlenderEditorAreaController<BlenderEditorType>(
        session: session,
        workspaceId: 'workspace',
        areaId: 'main',
        initialValue: BlenderEditorType.view3d,
        codec: blenderEditorTypeViewCodec,
        availableValues: BlenderEditorType.values,
      );

      expect(controller.value, BlenderEditorType.timeline);
      expect(controller.select(BlenderEditorType.graphEditor), isTrue);
      expect(
        session.viewForArea(workspaceId: 'workspace', areaId: 'main'),
        BlenderEditorType.graphEditor.name,
      );
      controller.setAvailableValues(const <BlenderEditorType>[
        BlenderEditorType.view3d,
      ], fallback: BlenderEditorType.view3d);
      expect(controller.value, BlenderEditorType.view3d);
    },
  );

  test('graph operations preserve node data and remove incident links', () {
    const node = BlenderGraphNode(
      id: 'a',
      title: 'A',
      position: Offset.zero,
      size: Size(120, 80),
      outputs: <BlenderNodeSocketDefinition>[
        BlenderNodeSocketDefinition(id: 'out', label: 'Out'),
      ],
    );
    const model = BlenderNodeGraphModel(
      nodes: <BlenderGraphNode>[
        node,
        BlenderGraphNode(
          id: 'b',
          title: 'B',
          position: Offset(10, 10),
          size: Size(120, 80),
        ),
      ],
      links: <BlenderGraphLink>[BlenderGraphLink(from: 'a', to: 'b')],
    );

    final moved = model.moveNode('a', const Offset(40, 50));
    expect(moved.nodes.first.position, const Offset(40, 50));
    expect(moved.nodes.first.outputs, same(node.outputs));
    expect(moved.removeNode('a').links, isEmpty);
  });

  test('jobs and reports have deterministic observable lifecycles', () async {
    final jobs = BlenderJobService();
    var canceled = false;
    jobs.register(
      BlenderJob(
        id: 'preview',
        name: 'Preview',
        progress: .2,
        onCancel: () => canceled = true,
      ),
    );
    jobs.reportProgress('preview', .7, remainingTime: '00:02');
    expect(jobs.jobs.single.progress, .7);
    expect(await jobs.cancel('preview'), isTrue);
    expect(canceled, isTrue);
    expect(jobs.jobs.single.state, BlenderJobState.cancelRequested);

    final reports = BlenderReportService(historyLimit: 2)
      ..report('first')
      ..report('second')
      ..report('third');
    expect(reports.reports.map((report) => report.message), <String>[
      'second',
      'third',
    ]);
  });

  testWidgets('command metadata drives pointer actions and descriptor menus', (
    tester,
  ) async {
    var executions = 0;
    final commands = BlenderCommandRegistry()
      ..register(
        BlenderCommand(
          id: 'document.save',
          label: 'Save Document',
          shortcut: 'Ctrl S',
          execute: () => executions++,
        ),
      );
    await tester.pumpWidget(
      _harness(
        BlenderCommandButton(commandId: 'document.save', commands: commands),
      ),
    );
    expect(find.text('Save Document'), findsOneWidget);
    await tester.tap(find.text('Save Document'));
    await tester.pump();
    expect(executions, 1);
  });

  testWidgets('property factory options reach their public controls', (
    tester,
  ) async {
    final number = BlenderPropertyFactory.number(
      'factor',
      'Factor',
      .5,
      min: 0,
      max: 1,
      showSteppers: false,
    );
    final choice = BlenderPropertyFactory.choice<int>(
      'mode',
      'Mode',
      1,
      const <BlenderMenuItem<int>>[
        BlenderMenuItem<int>(value: 1, label: 'One'),
      ],
    );
    final panel = BlenderPropertyFactory.panel(
      'advanced',
      'Advanced',
      enabled: false,
      expanded: true,
      properties: <BlenderPropertyDescriptor<dynamic>>[number, choice],
    );
    expect(panel.enabled, isFalse);
    expect(panel.initiallyExpanded, isTrue);

    await tester.pumpWidget(_harness(Builder(builder: number.buildEditor)));
    final field = tester.widget<BlenderNumberField>(
      find.byType(BlenderNumberField),
    );
    expect(field.showSteppers, isFalse);
  });

  testWidgets('both top-bar overflow policies keep fixed context controls', (
    tester,
  ) async {
    for (final overflow in BlenderApplicationTopBarOverflow.values) {
      await tester.pumpWidget(
        _harness(
          SizedBox(
            width: 320,
            child: BlenderApplicationTopBar<String, int>(
              overflow: overflow,
              menus: const <BlenderApplicationMenu<String>>[],
              workspaces: const <BlenderApplicationWorkspace<int>>[
                BlenderApplicationWorkspace<int>(value: 0, label: 'Layout'),
                BlenderApplicationWorkspace<int>(value: 1, label: 'Modeling'),
                BlenderApplicationWorkspace<int>(value: 2, label: 'Sculpting'),
              ],
              activeWorkspace: 0,
              onWorkspaceSelected: (_) {},
              contextControls: const <Widget>[Text('Scene')],
            ),
          ),
        ),
      );
      expect(find.text('Scene'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  test('viewport controller clamps navigation and resets atomically', () {
    final controller = BlenderViewportController(
      initialState: const BlenderViewportState(distance: 10),
      minDistance: 5,
      maxDistance: 15,
    );
    controller.zoomBy(10000);
    expect(controller.state.distance, 15);
    controller.orbitBy(const Offset(10, 10));
    expect(controller.state.yaw, isNot(0));
    controller.reset();
    expect(controller.state, const BlenderViewportState(distance: 10));
  });
}
