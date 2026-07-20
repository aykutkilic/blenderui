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

  test(
    'node graph validates exact socket endpoints and preserves metadata',
    () {
      const model = BlenderNodeGraphModel(
        nodes: <BlenderGraphNode>[
          BlenderGraphNode(
            id: 'source',
            title: 'Source',
            position: Offset.zero,
            outputs: <BlenderNodeSocketDefinition>[
              BlenderNodeSocketDefinition(
                id: 'geometry',
                label: 'Geometry',
                dataType: BlenderNodeSocketDataType.geometry,
              ),
            ],
          ),
          BlenderGraphNode(
            id: 'target',
            title: 'Target',
            position: Offset(200, 0),
            inputs: <BlenderNodeSocketDefinition>[
              BlenderNodeSocketDefinition(
                id: 'geometry',
                label: 'Geometry',
                dataType: BlenderNodeSocketDataType.geometry,
              ),
            ],
          ),
        ],
        links: <BlenderGraphLink>[
          BlenderGraphLink(
            from: 'source',
            fromSocket: 'geometry',
            to: 'target',
            toSocket: 'geometry',
          ),
        ],
      );

      expect(model.validate(), isEmpty);
      expect(model.bounds, const Rect.fromLTWH(0, 0, 350, 90));
      expect(model.selectNode('target').nodes.last.active, isTrue);
      expect(
        model
            .copyWith(
              links: const <BlenderGraphLink>[
                BlenderGraphLink(
                  from: 'source',
                  fromSocket: 'missing',
                  to: 'target',
                  toSocket: 'geometry',
                ),
              ],
            )
            .validate(),
        contains('Missing output socket: source.missing'),
      );
    },
  );

  test('typed socket connections normalize direction and replace inputs', () {
    const geometryOutput = BlenderNodeSocketReference(
      nodeId: 'source',
      socketId: 'geometry',
      output: true,
    );
    const secondOutput = BlenderNodeSocketReference(
      nodeId: 'second',
      socketId: 'geometry',
      output: true,
    );
    const geometryInput = BlenderNodeSocketReference(
      nodeId: 'target',
      socketId: 'geometry',
      output: false,
    );
    const floatInput = BlenderNodeSocketReference(
      nodeId: 'target',
      socketId: 'factor',
      output: false,
    );
    const model = BlenderNodeGraphModel(
      nodes: <BlenderGraphNode>[
        BlenderGraphNode(
          id: 'source',
          title: 'Source',
          position: Offset.zero,
          outputs: <BlenderNodeSocketDefinition>[
            BlenderNodeSocketDefinition(
              id: 'geometry',
              label: 'Geometry',
              dataType: BlenderNodeSocketDataType.geometry,
            ),
          ],
        ),
        BlenderGraphNode(
          id: 'second',
          title: 'Second',
          position: Offset.zero,
          outputs: <BlenderNodeSocketDefinition>[
            BlenderNodeSocketDefinition(
              id: 'geometry',
              label: 'Geometry',
              dataType: BlenderNodeSocketDataType.geometry,
            ),
          ],
        ),
        BlenderGraphNode(
          id: 'target',
          title: 'Target',
          position: Offset.zero,
          inputs: <BlenderNodeSocketDefinition>[
            BlenderNodeSocketDefinition(
              id: 'geometry',
              label: 'Geometry',
              dataType: BlenderNodeSocketDataType.geometry,
            ),
            BlenderNodeSocketDefinition(
              id: 'factor',
              label: 'Factor',
              dataType: BlenderNodeSocketDataType.floatingPoint,
            ),
          ],
        ),
      ],
    );

    final first = model.connectSockets(geometryInput, geometryOutput);
    expect(first.links.single.from, 'source');
    expect(first.links.single.toSocket, 'geometry');
    final replaced = first.connectSockets(secondOutput, geometryInput);
    expect(replaced.links, hasLength(1));
    expect(replaced.links.single.from, 'second');
    expect(replaced.connectSockets(geometryOutput, floatInput), same(replaced));
  });

  test('geometry node menu catalog preserves source nested categories', () {
    final add = BlenderNodeEditorMenuCatalog.geometryAdd();
    final curve = add.singleWhere((item) => item.label == 'Curve');
    final read = curve.submenu!.singleWhere((item) => item.label == 'Read');

    expect(
      add.map((item) => item.label),
      containsAll(<String>[
        'Input',
        'Output',
        'Attribute',
        'Geometry',
        'Curve',
        'Instances',
        'Mesh',
        'Simulation',
        'Utilities',
        'Group',
        'Layout',
      ]),
    );
    expect(
      read.submenu!.map((item) => item.label),
      containsAll(<String>[
        'Curve Handle Positions',
        'Curve Length',
        'Spline Resolution',
      ]),
    );
  });

  testWidgets('node editor composes grid, frames, reroutes, and socket links', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 700,
          height: 420,
          child: BlenderNodeEditor(
            title: null,
            model: BlenderNodeGraphModel(
              nodes: <BlenderGraphNode>[
                BlenderGraphNode(
                  id: 'frame',
                  title: 'Geometry Flow',
                  position: Offset(10, 10),
                  size: Size(600, 300),
                  kind: BlenderGraphNodeKind.frame,
                ),
                BlenderGraphNode(
                  id: 'input',
                  title: 'Group Input',
                  position: Offset(40, 80),
                  outputs: <BlenderNodeSocketDefinition>[
                    BlenderNodeSocketDefinition(
                      id: 'geometry',
                      label: 'Geometry',
                      dataType: BlenderNodeSocketDataType.geometry,
                      connected: true,
                    ),
                  ],
                ),
                BlenderGraphNode(
                  id: 'reroute',
                  title: 'Reroute',
                  position: Offset(260, 110),
                  kind: BlenderGraphNodeKind.reroute,
                  outputs: <BlenderNodeSocketDefinition>[
                    BlenderNodeSocketDefinition(
                      id: 'out',
                      label: '',
                      dataType: BlenderNodeSocketDataType.geometry,
                    ),
                  ],
                ),
              ],
              links: <BlenderGraphLink>[
                BlenderGraphLink(
                  from: 'input',
                  fromSocket: 'geometry',
                  to: 'reroute',
                  toSocket: 'in',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('node-editor-grid')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('node-editor-links')),
      findsOneWidget,
    );
    expect(find.text('Geometry Flow'), findsOneWidget);
    expect(find.text('Group Input'), findsOneWidget);
    expect(find.text('Geometry'), findsOneWidget);
  });

  testWidgets('node editor creates a typed link by dragging socket handles', (
    tester,
  ) async {
    BlenderGraphLink? created;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 620,
          height: 300,
          child: BlenderNodeEditor(
            title: null,
            model: const BlenderNodeGraphModel(
              nodes: <BlenderGraphNode>[
                BlenderGraphNode(
                  id: 'source',
                  title: 'Source',
                  position: Offset(30, 40),
                  outputs: <BlenderNodeSocketDefinition>[
                    BlenderNodeSocketDefinition(
                      id: 'geometry',
                      label: 'Geometry',
                      dataType: BlenderNodeSocketDataType.geometry,
                    ),
                  ],
                ),
                BlenderGraphNode(
                  id: 'target',
                  title: 'Target',
                  position: Offset(300, 40),
                  inputs: <BlenderNodeSocketDefinition>[
                    BlenderNodeSocketDefinition(
                      id: 'geometry',
                      label: 'Geometry',
                      dataType: BlenderNodeSocketDataType.geometry,
                    ),
                  ],
                ),
              ],
            ),
            onLinkCreated: (link) => created = link,
          ),
        ),
      ),
    );

    Finder handle(String key) => find
        .descendant(
          of: find.byKey(ValueKey<String>(key)),
          matching: find.byType(GestureDetector),
        )
        .first;
    final source = handle('node-socket-source-geometry-true');
    final target = handle('node-socket-target-geometry-false');
    final gesture = await tester.startGesture(tester.getCenter(source));
    await gesture.moveTo(
      tester.getCenter(target),
      timeStamp: const Duration(milliseconds: 100),
    );
    await tester.pump();
    expect(
      find.byKey(const ValueKey<String>('node-editor-link-preview')),
      findsOneWidget,
    );
    await gesture.up();
    await tester.pump();

    expect(created?.from, 'source');
    expect(created?.fromSocket, 'geometry');
    expect(created?.to, 'target');
    expect(created?.toSocket, 'geometry');
  });

  testWidgets('node editor culls nodes outside the transformed viewport', (
    tester,
  ) async {
    final controller = TransformationController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 400,
          height: 240,
          child: BlenderNodeEditor(
            title: null,
            viewportOverscan: 0,
            transformationController: controller,
            model: const BlenderNodeGraphModel(
              nodes: <BlenderGraphNode>[
                BlenderGraphNode(
                  id: 'near',
                  title: 'Near',
                  position: Offset(20, 20),
                ),
                BlenderGraphNode(
                  id: 'far',
                  title: 'Far',
                  position: Offset(1800, 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Near'), findsOneWidget);
    expect(find.text('Far'), findsNothing);
    controller.value = Matrix4.translationValues(-1700, 0, 0);
    await tester.pump();
    expect(find.text('Near'), findsNothing);
    expect(find.text('Far'), findsOneWidget);
  });

  testWidgets('node movement commits once after transient drag updates', (
    tester,
  ) async {
    var commits = 0;
    Offset? committedPosition;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 420,
          height: 240,
          child: BlenderNodeEditor(
            title: null,
            model: const BlenderNodeGraphModel(
              nodes: <BlenderGraphNode>[
                BlenderGraphNode(
                  id: 'move',
                  title: 'Move me',
                  position: Offset(30, 30),
                ),
              ],
            ),
            onNodeMoved: (_, position) {
              commits++;
              committedPosition = position;
            },
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Move me')),
    );
    await gesture.moveBy(const Offset(15, 10));
    await tester.pump();
    await gesture.moveBy(const Offset(10, 5));
    await tester.pump();
    expect(commits, 0);
    await gesture.up();
    await tester.pump();
    expect(commits, 1);
    expect(committedPosition, const Offset(55, 45));
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
