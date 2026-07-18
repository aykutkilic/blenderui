part of '../blender_ui_test.dart';

void registerWorkspaceServiceClearsADurableSessionAfterTests() {
  test(
    'workspace service clears a durable session after pending writes',
    () async {
      final storage = _WorkspaceMemoryStorage();
      final persistence = BlenderWorkspacePersistence<String>(
        storage: storage,
        storageKey: 'test.clear-workspace-session',
        valueCodec: const BlenderWorkspaceValueCodec<String>(
          toJson: _workspaceStringToJson,
          fromJson: _workspaceStringFromJson,
        ),
      );
      final service = _persistentWorkspaceService(persistence);
      service.activeController.splitArea(
        areaId: 'folders-outliner',
        direction: BlenderSplitDirection.horizontal,
        fraction: .4,
        newValue: 'properties',
        newAreaFirst: false,
      );
      await service.clearPersistedSession();
      service.dispose();

      final restored = _persistentWorkspaceService(persistence);
      expect(await restored.restore(), isFalse);
      expect(
        restored.controllerFor('folders').root,
        isA<BlenderDockAreaNode<String>>(),
      );
      restored.dispose();
    },
  );

  testWidgets('workspace shell restores a durable session on startup', (
    tester,
  ) async {
    final storage = _WorkspaceMemoryStorage();
    final persistence = BlenderWorkspacePersistence<String>(
      storage: storage,
      storageKey: 'test.shell-workspace-session',
      valueCodec: const BlenderWorkspaceValueCodec<String>(
        toJson: _workspaceStringToJson,
        fromJson: _workspaceStringFromJson,
      ),
    );
    final saved = _persistentWorkspaceService(persistence);
    saved.selectWorkspace('authoring');
    saved.activeController.replaceAreaValue(
      areaId: 'authoring-page',
      value: 'restored-level-editor',
    );
    await saved.flush();
    saved.dispose();

    final application = BlenderApplicationController<Object?>(
      initialState: null,
      workspaceService: _persistentWorkspaceService(persistence),
    );
    addTearDown(application.dispose);
    await tester.pumpWidget(
      BlenderWorkspaceShell<Object?>(
        controller: application,
        areaBuilder: (context, area) => Text(area.value),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('restored-level-editor'), findsOneWidget);
  });

  test('application controller adopts a multi-workspace service', () {
    final workspaces = BlenderWorkspaceService<String>(
      workspaces: const <BlenderWorkspaceDefinition<String>>[
        BlenderWorkspaceDefinition<String>(
          id: 'folders',
          layout: BlenderDockAreaNode<String>(id: 'folders', value: 'outliner'),
        ),
        BlenderWorkspaceDefinition<String>(
          id: 'authoring',
          layout: BlenderDockAreaNode<String>(id: 'authoring', value: 'editor'),
        ),
      ],
    );
    final application = BlenderApplicationController<Object?>(
      initialState: null,
      workspaceService: workspaces,
    );

    expect(application.workspaces, same(workspaces));
    application.workspaces.selectWorkspace('authoring');
    expect(application.docking, same(workspaces.activeController));
    application.dispose();
  });

  testWidgets('workspace host swaps to the selected retained layout', (
    tester,
  ) async {
    final service = BlenderWorkspaceService<String>(
      workspaces: const <BlenderWorkspaceDefinition<String>>[
        BlenderWorkspaceDefinition<String>(
          id: 'folders',
          layout: BlenderDockAreaNode<String>(
            id: 'folders-main',
            value: 'folder outliner',
          ),
        ),
        BlenderWorkspaceDefinition<String>(
          id: 'authoring',
          layout: BlenderDockAreaNode<String>(
            id: 'authoring-main',
            value: 'page editor',
          ),
        ),
      ],
    );
    addTearDown(service.dispose);

    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 400,
          height: 240,
          child: BlenderWorkspaceHost<String>(
            service: service,
            areaBuilder: (context, area) => Text(area.value),
          ),
        ),
      ),
    );
    expect(find.text('folder outliner'), findsOneWidget);

    service.selectWorkspace('authoring');
    await tester.pump();
    expect(find.text('page editor'), findsOneWidget);
  });

  testWidgets('workspace screen host retains visited editor state', (
    tester,
  ) async {
    Widget host(String activeWorkspace) => _harness(
      SizedBox(
        width: 400,
        height: 240,
        child: BlenderWorkspaceScreenHost<String>(
          activeWorkspaceId: activeWorkspace,
          screens: <BlenderWorkspaceScreen<String>>[
            BlenderWorkspaceScreen<String>(
              id: 'folders',
              builder: (_) => const _RetainedWorkspaceProbe(label: 'Folders'),
            ),
            BlenderWorkspaceScreen<String>(
              id: 'dictionaries',
              builder: (_) =>
                  const _RetainedWorkspaceProbe(label: 'Dictionaries'),
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(host('folders'));
    await tester.tap(find.byKey(const ValueKey<String>('Folders-increment')));
    await tester.pump();
    expect(find.text('Folders: 1'), findsOneWidget);

    await tester.pumpWidget(host('dictionaries'));
    expect(find.text('Dictionaries: 0'), findsOneWidget);
    await tester.pumpWidget(host('folders'));
    expect(find.text('Folders: 1'), findsOneWidget);
  });

  test('docking controller replaces an editor value in place', () {
    final controller = BlenderDockingController<String>(
      root: const BlenderDockAreaNode<String>(id: 'main', value: 'outliner'),
    );

    expect(
      controller.replaceAreaValue(areaId: 'main', value: 'page-editor'),
      isTrue,
    );
    expect(
      (controller.root as BlenderDockAreaNode<String>).value,
      'page-editor',
    );
    controller.dispose();
  });

  testWidgets('corner action zone creates a live editor split', (tester) async {
    final controller = BlenderDockingController<String>(
      root: const BlenderDockAreaNode<String>(id: 'main', value: 'viewport'),
    );
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 400,
          height: 240,
          child: BlenderDockingWorkspace<String>(
            controller: controller,
            areaBuilder: (context, area) =>
                const ColoredBox(color: Color(0xFF303030)),
          ),
        ),
      ),
    );

    final handle = find.bySemanticsLabel(
      'Split or dock area from topLeft corner',
    );
    await tester.dragFrom(tester.getRect(handle).center, const Offset(120, 40));
    await tester.pump();

    expect(controller.root, isA<BlenderDockSplitNode<String>>());
    controller.dispose();
  });

  testWidgets('corner drag into another area commits a center dock', (
    tester,
  ) async {
    final controller = BlenderDockingController<String>(
      root: const BlenderDockSplitNode<String>(
        id: 'columns',
        direction: BlenderSplitDirection.horizontal,
        fraction: .5,
        first: BlenderDockAreaNode<String>(id: 'left', value: 'viewport'),
        second: BlenderDockAreaNode<String>(id: 'right', value: 'properties'),
      ),
    );
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 400,
          height: 240,
          child: BlenderDockingWorkspace<String>(
            controller: controller,
            areaBuilder: (context, area) =>
                const ColoredBox(color: Color(0xFF303030)),
          ),
        ),
      ),
    );

    final handles = find.bySemanticsLabel(
      'Split or dock area from topRight corner',
    );
    final firstHandle = handles.at(0);
    final secondHandle = handles.at(1);
    final sourceHandle =
        tester.getRect(firstHandle).left < tester.getRect(secondHandle).left
        ? firstHandle
        : secondHandle;
    final workspaceRect = tester.getRect(
      find.byType(BlenderDockingWorkspace<String>),
    );
    final gesture = await tester.startGesture(
      tester.getRect(sourceHandle).center,
    );
    await gesture.moveBy(const Offset(0, 30));
    await tester.pump();
    await gesture.moveTo(
      Offset(
        workspaceRect.left + workspaceRect.width * .75,
        workspaceRect.top + workspaceRect.height * .5,
      ),
    );
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(controller.root, isA<BlenderDockAreaNode<String>>());
    expect((controller.root as BlenderDockAreaNode<String>).value, 'viewport');
    controller.dispose();
  });

  testWidgets('Blender control variants and non-3D editors render', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 640,
          height: 640,
          child: Column(
            children: <Widget>[
              BlenderSegmentedControl<String>(
                value: 'Solid',
                items: <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Solid', label: 'Solid'),
                  BlenderMenuItem<String>(value: 'Wire', label: 'Wire'),
                ],
                onChanged: _ignoreString,
              ),
              BlenderProgressBar(value: .5, label: '50%'),
              Expanded(
                child: BlenderSpreadsheetEditor(
                  columns: <BlenderSpreadsheetColumn>[
                    BlenderSpreadsheetColumn(id: 'name', label: 'Name'),
                    BlenderSpreadsheetColumn(id: 'value', label: 'Value'),
                  ],
                  rows: <BlenderSpreadsheetRow>[
                    BlenderSpreadsheetRow(
                      id: 'one',
                      values: <String>['One', '1'],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Solid'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('Spreadsheet'), findsOneWidget);
    expect(find.text('One'), findsOneWidget);
  });

  testWidgets('dropdown uses an anchored popover and reports selection', (
    tester,
  ) async {
    var value = 'Solid';
    await tester.pumpWidget(
      BlenderApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 240,
              child: BlenderDropdown<String>(
                value: value,
                items: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Solid',
                    label: 'Solid',
                    icon: BlenderIcon(BlenderGlyph.scene, size: 16),
                  ),
                  BlenderMenuItem<String>(value: 'Wire', label: 'Wire'),
                ],
                onChanged: (next) => setState(() => value = next),
              ),
            ),
          ),
        ),
      ),
    );

    final dropdownArrow = tester.widget<BlenderIcon>(
      find.byWidgetPredicate(
        (widget) =>
            widget is BlenderIcon &&
            widget.glyph == BlenderGlyph.panelDisclosureDown,
      ),
    );
    expect(dropdownArrow.size, 9);

    await tester.tap(find.text('Solid'));
    await tester.pump();
    expect(find.text('Wire'), findsOneWidget);
    await tester.tap(find.text('Wire'));
    await tester.pump();

    expect(value, 'Wire');
    expect(find.text('Wire'), findsOneWidget);
  });

  testWidgets('menu button opens a pulldown and reports selection', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      BlenderApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 320,
            child: BlenderMenuButton<String>(
              label: 'File',
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'open',
                  label: 'Open File',
                  selected: true,
                ),
              ],
              onSelected: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('File'), warnIfMissed: false);
    await tester.pump();
    expect(find.text('Open File'), findsOneWidget);
    expect(find.byType(BlenderIcon), findsOneWidget);

    // The trigger must remain open after the original pointer-up has been
    // fully processed. A trigger-side fallback that races the tap callback
    // can otherwise open and dismiss this route in the same click.
    await tester.pumpAndSettle();
    expect(find.text('Open File'), findsOneWidget);

    await tester.tap(find.text('Open File'));
    await tester.pump();
    expect(selected, 'open');
  });

  testWidgets('route menus retain the nearest scoped Blender theme', (
    tester,
  ) async {
    final preferences = BlenderInterfacePreferencesService(
      initial: const BlenderInterfacePreferences(
        theme: BlenderThemePreset.light,
      ),
    );
    final application = BlenderApplicationController<Object?>(
      initialState: null,
      interfacePreferences: preferences,
    );
    addTearDown(application.dispose);

    await tester.pumpWidget(
      BlenderApp(
        home: BlenderApplicationScope<Object?>(
          controller: application,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 80,
                child: BlenderMenuButton<String>(
                  label: 'File',
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: 'open', label: 'Open'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(
      find.ancestor(
        of: find.text('File'),
        matching: find.byType(BlenderMenuButton<String>),
      ),
    );
    await tester.pumpAndSettle();
    final surface = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(BlenderMenu<String>),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is DecoratedBox && widget.decoration is BoxDecoration,
            ),
          )
          .first,
    );
    expect(
      (surface.decoration as BoxDecoration).color,
      const BlenderColorScheme.light().menuBackground,
    );
  });

  testWidgets(
    'application top bar fixes menus and actions around a fading workspace strip',
    (tester) async {
      await tester.pumpWidget(
        _harness(
          const SizedBox(
            width: 760,
            height: 34,
            child: BlenderApplicationTopBar<String, int>(
              menus: <BlenderApplicationMenu<String>>[
                BlenderApplicationMenu<String>(
                  label: 'File',
                  items: <BlenderMenuItem<String>>[],
                ),
                BlenderApplicationMenu<String>(
                  label: 'Edit',
                  items: <BlenderMenuItem<String>>[],
                ),
              ],
              workspaces: <BlenderApplicationWorkspace<int>>[
                BlenderApplicationWorkspace<int>(value: 0, label: 'Folders'),
                BlenderApplicationWorkspace<int>(
                  value: 1,
                  label: 'Dictionaries',
                ),
                BlenderApplicationWorkspace<int>(value: 2, label: 'Groups'),
              ],
              activeWorkspace: 0,
              onWorkspaceSelected: _ignoreInt,
              workspaceActions: <Widget>[BlenderButton(label: '+')],
              trailing: <Widget>[BlenderButton(label: 'AI Completions')],
            ),
          ),
        ),
      );

      expect(
        tester.getRect(find.text('File')).left,
        lessThan(tester.getRect(find.text('Folders')).left),
      );
      expect(
        tester.getRect(find.text('Folders')).left,
        lessThan(tester.getRect(find.text('AI Completions')).left),
      );
      expect(
        find.byType(BlenderApplicationTopBar<String, int>),
        findsOneWidget,
      );
    },
  );

  testWidgets('submenu rows use thin arrows and stay highlighted', (
    tester,
  ) async {
    await tester.pumpWidget(
      BlenderApp(
        home: _harness(
          const SizedBox(
            width: 320,
            child: BlenderMenuButton<String>(
              label: 'File',
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'previews',
                  label: 'Data Previews',
                  submenu: <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(
                      value: 'update',
                      label: 'Update Data Previews',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('File'), warnIfMissed: false);
    await tester.pump();

    final arrow = tester.widget<BlenderIcon>(
      find.byKey(const ValueKey<String>('menu-submenu-arrow-Data Previews')),
    );
    expect(arrow.glyph, BlenderGlyph.panelDisclosureRight);
    expect(arrow.size, 9);

    final row = find.byKey(const ValueKey<String>('menu-row-Data Previews'));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(() => mouse.removePointer());
    await mouse.addPointer(location: tester.getCenter(row));
    await mouse.moveTo(tester.getCenter(row));
    await tester.pump(const Duration(milliseconds: 250));

    final colors = BlenderTheme.of(tester.element(row)).colors;
    final decoration =
        tester.widget<Container>(row).decoration! as BoxDecoration;
    expect(decoration.color, colors.menuSelection);
    expect(find.text('Update Data Previews'), findsOneWidget);
  });
}
