part of '../blender_ui_test.dart';

void registerLightTopBarMenusUseBlenderThemetopbarTests() {
  testWidgets('light top-bar menus use Blender ThemeTopBar background', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: BlenderTheme(
          data: BlenderThemeData.light,
          child: BlenderMenuButton<String>(
            label: 'View',
            variant: BlenderButtonVariant.topBar,
            items: <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'frame', label: 'Frame Selected'),
            ],
          ),
        ),
      ),
    );

    final surface = tester.widget<AnimatedContainer>(
      find
          .ancestor(
            of: find.text('View'),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    expect(
      (surface.decoration as BoxDecoration).color,
      const BlenderColorScheme.light().topBar,
    );
  });

  testWidgets('header scroll surfaces hide automatic desktop scrollbars', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(
            platform: TargetPlatform.macOS,
          ),
          child: const SizedBox(
            width: 120,
            height: 30,
            child: BlenderToolbar(
              scrollable: true,
              children: <Widget>[SizedBox(width: 100), SizedBox(width: 100)],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(RawScrollbar), findsNothing);
  });

  testWidgets('segmented controls leave only the group gap between buttons', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 120,
          child: BlenderSegmentedControl<String>(
            value: 'Set',
            items: <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Set', label: 'Set'),
              BlenderMenuItem<String>(value: 'Add', label: 'Add'),
            ],
            onChanged: _ignoreString,
          ),
        ),
      ),
    );

    final animatedButtons = find.descendant(
      of: find.byType(BlenderSegmentedControl<String>),
      matching: find.byType(AnimatedContainer),
    );
    expect(animatedButtons, findsNWidgets(2));
    for (final element in animatedButtons.evaluate()) {
      final decoration = (element.widget as AnimatedContainer).decoration;
      expect((decoration! as BoxDecoration).border, isNull);
    }
  });

  testWidgets('boolean properties keep checkbox and label in value column', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 400,
          height: 180,
          child: BlenderPropertiesEditor(
            groups: <BlenderPropertyGroup>[
              BlenderPropertyGroup(
                id: 'format',
                title: 'Format',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyDescriptor<double>(
                    id: 'resolution',
                    label: 'Resolution X',
                    value: 1920,
                    editorBuilder: (context, value, onChanged) =>
                        const SizedBox(height: 20),
                  ),
                  BlenderPropertyDescriptor<bool>(
                    id: 'render-region',
                    label: 'Render Region',
                    value: false,
                    editorBuilder: (context, value, onChanged) =>
                        BlenderCheckbox(value: value, onChanged: onChanged),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    final numericLabel = tester.getRect(find.text('Resolution X'));
    final booleanLabel = tester.getRect(find.text('Render Region'));
    final checkbox = tester.getRect(find.byType(BlenderCheckbox));

    expect(numericLabel.right, lessThan(checkbox.left));
    expect(booleanLabel.left, greaterThanOrEqualTo(checkbox.right));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Properties search filters labels and preserves collapsed state',
    (tester) async {
      final search = TextEditingController();
      addTearDown(search.dispose);
      await tester.pumpWidget(
        _harness(
          SizedBox(
            width: 400,
            height: 260,
            child: BlenderPropertiesEditor(
              searchController: search,
              groups: <BlenderPropertyGroup>[
                BlenderPropertyGroup(
                  id: 'format',
                  title: 'Format',
                  initiallyExpanded: false,
                  properties: <BlenderPropertyDescriptor<dynamic>>[
                    BlenderPropertyDescriptor<int>(
                      id: 'resolution-x',
                      label: 'Resolution X',
                      value: 1920,
                      editorBuilder: (context, value, onChanged) =>
                          const SizedBox(height: 20),
                    ),
                    BlenderPropertyDescriptor<int>(
                      id: 'frame-rate',
                      label: 'Frame Rate',
                      value: 24,
                      editorBuilder: (context, value, onChanged) =>
                          const SizedBox(height: 20),
                    ),
                  ],
                ),
                BlenderPropertyGroup(
                  id: 'output',
                  title: 'Output',
                  initiallyExpanded: false,
                  properties: <BlenderPropertyDescriptor<dynamic>>[
                    BlenderPropertyDescriptor<String>(
                      id: 'file-format',
                      label: 'File Format',
                      value: 'PNG',
                      editorBuilder: (context, value, onChanged) =>
                          const SizedBox(height: 20),
                    ),
                    BlenderPropertyDescriptor<String>(
                      id: 'color',
                      label: 'Color',
                      value: 'RGBA',
                      editorBuilder: (context, value, onChanged) =>
                          const SizedBox(height: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      search.text = 'frame';
      await tester.pumpAndSettle();
      expect(find.text('Format'), findsOneWidget);
      expect(find.text('Frame Rate'), findsOneWidget);
      expect(find.text('Resolution X'), findsNothing);
      expect(find.text('Output'), findsNothing);

      search.text = 'output';
      await tester.pumpAndSettle();
      expect(find.text('Format'), findsNothing);
      expect(find.text('Output'), findsOneWidget);
      expect(find.text('File Format'), findsOneWidget);
      expect(find.text('Color'), findsOneWidget);

      search.clear();
      await tester.pumpAndSettle();
      expect(find.text('Format'), findsOneWidget);
      expect(find.text('Output'), findsOneWidget);
      expect(find.text('Frame Rate'), findsNothing);
      expect(find.text('File Format'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('nested Properties panels follow parent search and expansion', (
    tester,
  ) async {
    final search = TextEditingController();
    addTearDown(search.dispose);
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 400,
          height: 300,
          child: BlenderPropertiesEditor(
            searchController: search,
            groups: const <BlenderPropertyGroup>[
              BlenderPropertyGroup(
                id: 'transform',
                title: 'Transform',
                properties: <BlenderPropertyDescriptor<dynamic>>[],
                children: <BlenderPropertyGroup>[
                  BlenderPropertyGroup(
                    id: 'delta-transform',
                    title: 'Delta Transform',
                    initiallyExpanded: false,
                    properties: <BlenderPropertyDescriptor<dynamic>>[
                      BlenderPropertyDescriptor<double>(
                        id: 'delta-location-x',
                        label: 'Delta Location X',
                        value: 0,
                        editorBuilder: _emptyDoubleEditor,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Transform'), findsOneWidget);
    expect(find.text('Delta Transform'), findsOneWidget);
    expect(find.text('Delta Location X'), findsNothing);

    search.text = 'Delta Location';
    await tester.pumpAndSettle();
    expect(find.text('Transform'), findsOneWidget);
    expect(find.text('Delta Transform'), findsOneWidget);
    expect(find.text('Delta Location X'), findsOneWidget);

    search.clear();
    await tester.pumpAndSettle();
    expect(find.text('Delta Location X'), findsNothing);
  });

  testWidgets('property panel grips move and commit stable group order', (
    tester,
  ) async {
    List<String>? committedOrder;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 400,
          height: 260,
          child: BlenderPropertiesEditor(
            groups: const <BlenderPropertyGroup>[
              BlenderPropertyGroup(
                id: 'first',
                title: 'First',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[],
              ),
              BlenderPropertyGroup(
                id: 'second',
                title: 'Second',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[],
              ),
              BlenderPropertyGroup(
                id: 'third',
                title: 'Third',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[],
              ),
            ],
            onGroupOrderChanged: (order) => committedOrder = order,
          ),
        ),
      ),
    );

    final firstHandle = find.byKey(
      const ValueKey<String>('property-group-handle-first'),
    );
    final thirdHandle = find.byKey(
      const ValueKey<String>('property-group-handle-third'),
    );
    final gesture = await tester.startGesture(tester.getCenter(firstHandle));
    await tester.pump();
    await gesture.moveTo(tester.getCenter(thirdHandle) + const Offset(0, 12));
    await tester.pump(const Duration(milliseconds: 500));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(committedOrder, <String>['second', 'first', 'third']);
    expect(
      tester.getTopLeft(find.text('Second')).dy,
      lessThan(tester.getTopLeft(find.text('First')).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('expanded property panel proxy retains its measured height', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 400,
          height: 300,
          child: BlenderPropertiesEditor(
            groups: <BlenderPropertyGroup>[
              BlenderPropertyGroup(
                id: 'first',
                title: 'First',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyDescriptor<int>(
                    id: 'tall-control',
                    label: 'Tall Control',
                    value: 1,
                    editorBuilder: (context, value, onChanged) =>
                        const SizedBox(height: 56),
                  ),
                ],
              ),
              const BlenderPropertyGroup(
                id: 'second',
                title: 'Second',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('First'));
    await tester.pumpAndSettle();

    const panelKey = ValueKey<String>('property-group-first');
    const handleKey = ValueKey<String>('property-group-handle-first');
    final measuredHeight = tester.getRect(find.byKey(panelKey)).height;
    expect(measuredHeight, greaterThan(80));

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(handleKey)),
    );
    await tester.pump();

    expect(find.byKey(panelKey), findsOneWidget);
    expect(
      tester.getRect(find.byKey(panelKey)).height,
      closeTo(measuredHeight, 0.01),
    );

    await gesture.moveTo(
      tester.getCenter(
            find.byKey(const ValueKey<String>('property-group-handle-second')),
          ) +
          const Offset(0, 12),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      tester.getRect(find.byKey(panelKey)).height,
      closeTo(measuredHeight, 0.01),
    );

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('docking controller splits, collapses, and replaces area content', () {
    final controller = BlenderDockingController<String>(
      root: const BlenderDockAreaNode<String>(id: 'main', value: 'viewport'),
    );

    final newAreaId = controller.splitArea(
      areaId: 'main',
      direction: BlenderSplitDirection.horizontal,
      fraction: .4,
      newValue: 'viewport-copy',
      newAreaFirst: false,
    );
    expect(newAreaId, isNotNull);
    expect(controller.root, isA<BlenderDockSplitNode<String>>());

    expect(
      controller.dockArea(
        sourceAreaId: newAreaId!,
        targetAreaId: 'main',
        target: BlenderDockTarget.center,
      ),
      isTrue,
    );
    expect(controller.root, isA<BlenderDockAreaNode<String>>());
    expect(
      (controller.root as BlenderDockAreaNode<String>).value,
      'viewport-copy',
    );
    controller.dispose();
  });

  test('workspace service retains and resets each workspace layout', () {
    final service = BlenderWorkspaceService<String>(
      workspaces: const <BlenderWorkspaceDefinition<String>>[
        BlenderWorkspaceDefinition<String>(
          id: 'authoring',
          layout: BlenderDockAreaNode<String>(
            id: 'authoring-main',
            value: 'page-editor',
          ),
        ),
        BlenderWorkspaceDefinition<String>(
          id: 'data',
          layout: BlenderDockAreaNode<String>(
            id: 'data-main',
            value: 'dictionary-browser',
          ),
        ),
      ],
    );

    service.activeController.splitArea(
      areaId: 'authoring-main',
      direction: BlenderSplitDirection.horizontal,
      fraction: .35,
      newValue: 'properties',
      newAreaFirst: false,
    );
    expect(service.activeController.root, isA<BlenderDockSplitNode<String>>());

    service.selectWorkspace('data');
    expect(service.activeWorkspaceId, 'data');
    expect(service.activeController.root, isA<BlenderDockAreaNode<String>>());

    service.selectWorkspace('authoring');
    expect(service.activeController.root, isA<BlenderDockSplitNode<String>>());
    service.resetWorkspace('authoring');
    expect(service.activeController.root, isA<BlenderDockAreaNode<String>>());
    expect(
      (service.activeController.root as BlenderDockAreaNode<String>).value,
      'page-editor',
    );
    service.dispose();
  });

  test(
    'workspace service restores active workspace and dock layouts',
    () async {
      final storage = _WorkspaceMemoryStorage();
      final persistence = BlenderWorkspacePersistence<String>(
        storage: storage,
        storageKey: 'test.workspace-session',
        valueCodec: const BlenderWorkspaceValueCodec<String>(
          toJson: _workspaceStringToJson,
          fromJson: _workspaceStringFromJson,
        ),
      );
      final first = _persistentWorkspaceService(persistence);
      first.activeController.splitArea(
        areaId: 'folders-outliner',
        direction: BlenderSplitDirection.horizontal,
        fraction: .35,
        newValue: 'properties',
        newAreaFirst: false,
      );
      first.selectWorkspace('authoring');
      first.activeController.replaceAreaValue(
        areaId: 'authoring-page',
        value: 'level-editor',
      );
      await first.flush();
      first.dispose();

      final restored = _persistentWorkspaceService(persistence);
      expect(await restored.restore(), isTrue);
      expect(restored.activeWorkspaceId, 'authoring');
      expect(
        restored.controllerFor('folders').root,
        isA<BlenderDockSplitNode<String>>(),
      );
      expect(
        (restored.controllerFor('authoring').root
                as BlenderDockAreaNode<String>)
            .value,
        'level-editor',
      );
      restored.dispose();
    },
  );

  test('workspace service restores application workspace state', () async {
    final storage = _WorkspaceMemoryStorage();
    final persistence = BlenderWorkspacePersistence<String>(
      storage: storage,
      storageKey: 'test.workspace-state-session',
      valueCodec: const BlenderWorkspaceValueCodec<String>(
        toJson: _workspaceStringToJson,
        fromJson: _workspaceStringFromJson,
      ),
    );
    final selectedFolder = BlenderWorkspaceState<String?>(
      value: null,
      codec: const BlenderWorkspaceValueCodec<String?>(
        toJson: _workspaceNullableStringToJson,
        fromJson: _workspaceNullableStringFromJson,
      ),
    );
    final first = _persistentWorkspaceService(
      persistence,
      sessionState: selectedFolder,
    );
    selectedFolder.value = 'temmuz-2025';
    await first.flush();
    first.dispose();
    selectedFolder.dispose();

    final restoredFolder = BlenderWorkspaceState<String?>(
      value: null,
      codec: const BlenderWorkspaceValueCodec<String?>(
        toJson: _workspaceNullableStringToJson,
        fromJson: _workspaceNullableStringFromJson,
      ),
    );
    final restored = _persistentWorkspaceService(
      persistence,
      sessionState: restoredFolder,
    );
    expect(await restored.restore(), isTrue);
    expect(restoredFolder.value, 'temmuz-2025');
    restored.dispose();
    restoredFolder.dispose();
  });

  test('workspace service ignores a malformed persisted session', () async {
    final storage = _WorkspaceMemoryStorage()
      ..values['test.workspace-session'] = '{not json';
    final service = _persistentWorkspaceService(
      BlenderWorkspacePersistence<String>(
        storage: storage,
        storageKey: 'test.workspace-session',
        valueCodec: const BlenderWorkspaceValueCodec<String>(
          toJson: _workspaceStringToJson,
          fromJson: _workspaceStringFromJson,
        ),
      ),
    );

    expect(await service.restore(), isFalse);
    expect(service.activeWorkspaceId, 'folders');
    expect(service.activeController.root, isA<BlenderDockAreaNode<String>>());
    expect(service.lastPersistenceError, isNotNull);
    service.dispose();
  });
}
