part of '../blender_ui_test.dart';

void registerMultiColumnMenuReusesCompactEditorMenuTests() {
  testWidgets('multi-column menu reuses compact editor-menu geometry', (
    tester,
  ) async {
    String? selected;
    const groups = <BlenderMultiColumnMenuGroup<String>>[
      BlenderMultiColumnMenuGroup<String>(
        id: 'authoring',
        title: 'Authoring',
        items: <BlenderMultiColumnMenuItem<String>>[
          BlenderMultiColumnMenuItem<String>(
            id: 'page',
            value: 'page',
            label: 'Page Editor',
            glyph: BlenderGlyph.file,
          ),
          BlenderMultiColumnMenuItem<String>(
            id: 'level',
            value: 'level',
            label: 'Level Editor',
            glyph: BlenderGlyph.grid,
          ),
        ],
      ),
      BlenderMultiColumnMenuGroup<String>(
        id: 'properties',
        title: 'Properties',
        items: <BlenderMultiColumnMenuItem<String>>[
          BlenderMultiColumnMenuItem<String>(
            id: 'settings',
            value: 'settings',
            label: 'Settings',
            glyph: BlenderGlyph.settings,
          ),
        ],
      ),
    ];

    await tester.pumpWidget(
      BlenderApp(
        home: Center(
          child: BlenderMultiColumnMenu<String>(
            key: const ValueKey<String>('type-picker-menu'),
            menuId: 'type-picker-menu',
            groups: groups,
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    final menu = find.byKey(const ValueKey<String>('type-picker-menu'));
    expect(menu, findsOneWidget);
    expect(tester.getSize(menu).width, lessThanOrEqualTo(820));
    expect(tester.getSize(menu).height, lessThan(120));
    expect(
      find.byKey(const ValueKey<String>('type-picker-menu-group-authoring')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('type-picker-menu-item-level')),
    );
    await tester.pump();
    expect(selected, 'level');

    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 300,
          child: BlenderMultiColumnMenu<String>(
            key: const ValueKey<String>('narrow-type-picker-menu'),
            menuId: 'narrow-type-picker-menu',
            maxWidth: 300,
            minimumColumnWidth: 500,
            groups: groups,
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );
    final narrowMenu = find.byKey(
      const ValueKey<String>('narrow-type-picker-menu'),
    );
    final narrowSurface = find.descendant(
      of: narrowMenu,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).border != null,
      ),
    );
    expect(narrowSurface, findsOneWidget);
    expect(tester.getSize(narrowSurface).height, greaterThan(120));
  });

  testWidgets('BlenderApp supplies the themed default text foreground', (
    tester,
  ) async {
    await tester.pumpWidget(const BlenderApp(home: Text('Inherited text')));

    final textContext = tester.element(find.text('Inherited text'));
    expect(
      DefaultTextStyle.of(textContext).style.color,
      const Color(0xFFE6E6E6),
    );
  });

  testWidgets(
    'application shell scopes state and services around a dockable workspace',
    (tester) async {
      final application = BlenderApplicationController<int>(
        initialState: 7,
        workspace: const BlenderDockAreaNode<String>(id: 'main', value: 'main'),
      );
      addTearDown(application.dispose);

      await tester.pumpWidget(
        BlenderWorkspaceShell<int>(
          controller: application,
          topBar: const Text('Application menu'),
          statusBar: const Text('Ready'),
          areaBuilder: (context, area) {
            final state = BlenderStateScope.watch<int>(context);
            final commands = BlenderServiceScope.read<BlenderCommandRegistry>(
              context,
            );
            return Text(
              '${area.value}:${state.value}:${commands.commands.length}',
            );
          },
        ),
      );

      expect(find.text('Application menu'), findsOneWidget);
      expect(find.text('main:7:2'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.byType(BlenderDockingWorkspace<String>), findsOneWidget);
      expect(application.services.contains<BlenderHistoryStore<int>>(), isTrue);
      expect(application.services.contains<BlenderCommandRegistry>(), isTrue);
      expect(application.services.contains<BlenderCommandBindings>(), isTrue);
      expect(application.services.contains<BlenderStatusService>(), isTrue);
      expect(
        application.services.contains<BlenderEditorSessionService>(),
        isTrue,
      );
      expect(
        application.services.contains<BlenderApplicationPresentationService>(),
        isTrue,
      );
    },
  );

  testWidgets('application scope installs services without a dock frame', (
    tester,
  ) async {
    final application = BlenderApplicationController<int>(initialState: 4);
    addTearDown(application.dispose);

    await tester.pumpWidget(
      BlenderApp(
        home: BlenderApplicationScope<int>(
          controller: application,
          child: Builder(
            builder: (context) {
              final state = BlenderStateScope.watch<int>(context);
              final status = BlenderServiceScope.read<BlenderStatusService>(
                context,
              );
              return Text('${state.value}:${status.message == null}');
            },
          ),
        ),
      ),
    );

    expect(find.text('4:true'), findsOneWidget);
  });

  testWidgets('interface preferences apply Blender Light and live UI scaling', (
    tester,
  ) async {
    final interfacePreferences = BlenderInterfacePreferencesService(
      initial: const BlenderInterfacePreferences(
        theme: BlenderThemePreset.light,
        uiScale: 1.25,
        lineWidth: BlenderInterfaceLineWidth.thick,
      ),
    );
    final application = BlenderApplicationController<Object?>(
      initialState: null,
      interfacePreferences: interfacePreferences,
    );
    addTearDown(application.dispose);

    await tester.pumpWidget(
      BlenderApp(
        home: BlenderApplicationScope<Object?>(
          controller: application,
          child: Builder(
            builder: (context) {
              final theme = BlenderTheme.of(context);
              return Text(
                '${theme.colors.canvas.toARGB32()}:${theme.density.controlHeight}:${theme.shapes.borderWidth}',
              );
            },
          ),
        ),
      ),
    );

    expect(
      find.text('${const Color(0xFFB3B3B3).toARGB32()}:25.0:1.5'),
      findsOneWidget,
    );
    expect(
      BlenderServiceScope.read<BlenderInterfacePreferencesService>(
        tester.element(find.textContaining(':25.0:')),
      ),
      same(interfacePreferences),
    );
  });

  testWidgets('application scope applies the selected Blender theme service', (
    tester,
  ) async {
    final interfacePreferences = BlenderInterfacePreferencesService();
    final themes = BlenderThemeService();
    final application = BlenderApplicationController<Object?>(
      initialState: null,
      interfacePreferences: interfacePreferences,
      themeService: themes,
    );
    addTearDown(application.dispose);

    await tester.pumpWidget(
      BlenderApp(
        home: BlenderApplicationScope<Object?>(
          controller: application,
          child: Builder(
            builder: (context) => Text(
              BlenderTheme.of(context).colors.canvas.toARGB32().toString(),
            ),
          ),
        ),
      ),
    );

    themes.select('blender-light');
    await tester.pump();
    expect(
      find.text(const Color(0xFFB3B3B3).toARGB32().toString()),
      findsOneWidget,
    );

    themes.updateActiveColor(
      BlenderThemeColorRole.canvas,
      const Color(0xFFEEF7FA),
    );
    await tester.pump();
    expect(
      find.text(const Color(0xFFEEF7FA).toARGB32().toString()),
      findsOneWidget,
    );
    expect(themes.activeTheme.isBuiltIn, isFalse);
  });

  testWidgets(
    'Preferences service carries its live theme through a root Navigator context',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      final interfacePreferences = BlenderInterfacePreferencesService();
      final themes = BlenderThemeService();
      final preferences = BlenderPreferencesService(
        configuration: BlenderPreferencesConfiguration(
          categories: const <String>['Themes'],
          sections: <BlenderPreferenceSection>[
            BlenderPreferenceSection(
              id: 'palette',
              category: 'Themes',
              title: 'Palette',
              child: Builder(
                builder: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DecoratedBox(
                      key: const ValueKey<String>('preferences-live-palette'),
                      decoration: BoxDecoration(
                        color: BlenderTheme.of(context).colors.canvas,
                      ),
                      child: const SizedBox(height: 40),
                    ),
                    const Text(
                      'Live theme label',
                      key: ValueKey<String>('preferences-live-label'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      final application = BlenderApplicationController<Object?>(
        initialState: null,
        interfacePreferences: interfacePreferences,
        themeService: themes,
        preferences: preferences,
      );
      addTearDown(application.dispose);

      await tester.pumpWidget(
        BlenderApp(
          navigatorKey: navigatorKey,
          home: BlenderApplicationScope<Object?>(
            controller: application,
            child: Builder(
              builder: (_) => BlenderButton(
                label: 'Preferences',
                onPressed: () => preferences.show(navigatorKey.currentContext!),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Preferences'));
      await tester.pumpAndSettle();
      final palette = find.byKey(
        const ValueKey<String>('preferences-live-palette'),
      );
      expect(
        (tester.widget<DecoratedBox>(palette).decoration as BoxDecoration)
            .color,
        const BlenderColorScheme.dark().canvas,
      );

      themes.select('blender-light');
      await tester.pump();
      expect(
        (tester.widget<DecoratedBox>(palette).decoration as BoxDecoration)
            .color,
        const BlenderColorScheme.light().canvas,
      );
      expect(
        DefaultTextStyle.of(
          tester.element(
            find.byKey(const ValueKey<String>('preferences-live-label')),
          ),
        ).style.color,
        const BlenderColorScheme.light().foreground,
      );
    },
  );

  testWidgets('theme Preferences delegate Blender XML files to the host', (
    tester,
  ) async {
    final themes = BlenderThemeService();
    addTearDown(themes.dispose);
    String? savedXml;
    await tester.pumpWidget(
      BlenderApp(
        home: SingleChildScrollView(
          child: BlenderThemePreferencesEditor(
            service: themes,
            fileActions: BlenderThemeFileActions(
              onInstall: () async => const BlenderThemeFileContent(
                name: 'Installed_Theme.xml',
                xml:
                    '<bpy><Theme name="From Blender">'
                    '<user_interface><ThemeUserInterface '
                    'editor_border="#123456FF" /></user_interface>'
                    '</Theme><ThemeStyle /></bpy>',
              ),
              onSave: (content) async => savedXml = content.xml,
            ),
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('blender-theme-install')),
    );
    await tester.pumpAndSettle();
    expect(themes.activeTheme.name, 'Installed Theme');
    expect(themes.activeTheme.colors.editorBorder, const Color(0xFF123456));

    await tester.tap(find.byKey(const ValueKey<String>('blender-theme-save')));
    await tester.pump();
    expect(savedXml, contains('<bpy>'));
    expect(savedXml, contains('<Theme name="Installed Theme">'));
  });

  testWidgets('application shell restores persisted editor context', (
    tester,
  ) async {
    final storage = _WorkspaceMemoryStorage()
      ..values['editor-session'] =
          '{"version":1,"viewsByArea":{"default::main":"text"},'
          '"outlinerSelectionByWorkspace":{"default":"cube"},'
          '"propertiesTargetByWorkspace":{"default":"material"}}';
    final application = BlenderApplicationController<Object?>(
      initialState: null,
      workspace: const BlenderDockAreaNode<String>(id: 'main', value: 'main'),
      editorSession: BlenderEditorSessionService(
        persistence: BlenderEditorSessionPersistence(
          storage: storage,
          storageKey: 'editor-session',
        ),
      ),
    );
    addTearDown(application.dispose);

    await tester.pumpWidget(
      BlenderWorkspaceShell<Object?>(
        controller: application,
        areaBuilder: (context, area) {
          final session = BlenderEditorSessionScope.watch(context);
          return Text(
            '${session.viewForArea(workspaceId: 'default', areaId: area.id)}:'
            '${session.outlinerSelectionFor('default')}:'
            '${session.propertiesTargetFor('default')}',
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('text:cube:material'), findsOneWidget);
  });

  testWidgets('preferences helper presents reusable preference descriptors', (
    tester,
  ) async {
    await tester.pumpWidget(
      BlenderApp(
        home: Builder(
          builder: (context) => BlenderButton(
            label: 'Preferences',
            onPressed: () => showBlenderPreferencesWindow(
              context,
              configuration: const BlenderPreferencesConfiguration(
                categories: <String>['Interface'],
                width: 600,
                height: 400,
                sections: <BlenderPreferenceSection>[
                  BlenderPreferenceSection(
                    id: 'display',
                    category: 'Interface',
                    title: 'Display',
                    child: Text('Resolution Scale'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Preferences'));
    await tester.pumpAndSettle();

    expect(find.byType(BlenderPreferencesWindow), findsOneWidget);
    expect(find.text('Resolution Scale'), findsOneWidget);
  });

  testWidgets('temporary Preferences window moves, minimizes, and closes', (
    tester,
  ) async {
    await tester.pumpWidget(
      BlenderApp(
        home: Builder(
          builder: (context) => BlenderButton(
            label: 'Preferences',
            onPressed: () => showBlenderPreferencesWindow(
              context,
              configuration: const BlenderPreferencesConfiguration(
                categories: <String>['Interface'],
                width: 600,
                height: 400,
                sections: <BlenderPreferenceSection>[
                  BlenderPreferenceSection(
                    id: 'display',
                    category: 'Interface',
                    title: 'Display',
                    child: Text('Resolution Scale'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Preferences'));
    await tester.pumpAndSettle();
    final window = find.byType(BlenderPreferencesWindow);
    final initialPosition = tester.getTopLeft(find.text('Resolution Scale'));

    await tester.drag(
      find.byKey(const ValueKey<String>('preferences-window-title-bar')),
      const Offset(-60, -32),
    );
    await tester.pump();
    expect(
      tester.getTopLeft(find.text('Resolution Scale')),
      isNot(initialPosition),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('preferences-window-minimize')),
    );
    await tester.pump();
    expect(tester.getSize(window).height, 48);
    expect(find.text('Resolution Scale'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey<String>('preferences-window-minimize')),
    );
    await tester.pump();
    expect(find.text('Resolution Scale'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('preferences-window-close')),
    );
    await tester.pumpAndSettle();
    expect(window, findsNothing);
  });
}
