import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('state store updates, resets, and suppresses equal values', () {
    final store = BlenderStateStore<int>(1);
    addTearDown(store.dispose);
    var notifications = 0;
    store.addListener(() => notifications++);

    expect(store.replace(1), isFalse);
    expect(store.update((value) => value + 2), isTrue);
    expect(store.value, 3);
    expect(store.reset(), isTrue);
    expect(store.value, 1);
    expect(notifications, 2);
  });

  test('history store offers bounded undo and redo', () {
    final store = BlenderHistoryStore<int>(0, historyLimit: 2);
    addTearDown(store.dispose);

    store.replace(1);
    store.replace(2);
    store.replace(3);
    expect(store.undoHistory, <int>[1, 2]);

    expect(store.undo(), isTrue);
    expect(store.value, 2);
    expect(store.undo(), isTrue);
    expect(store.value, 1);
    expect(store.undo(), isFalse);
    expect(store.redo(), isTrue);
    expect(store.value, 2);

    store.replace(8);
    expect(store.canRedo, isFalse);
  });

  test('service containers support scopes, factories, and disposal', () {
    final root = BlenderServiceContainer();
    final disposable = _DisposableService();
    root.registerSingleton<_DisposableService>(disposable);
    root.registerLazySingleton<_LazyService>((services) => _LazyService());
    root.registerFactory<_FactoryService>(
      (services) => _FactoryService(services.get<_LazyService>()),
    );
    final child = root.createChild();

    expect(child.get<_DisposableService>(), same(disposable));
    expect(root.get<_LazyService>(), same(root.get<_LazyService>()));
    expect(
      root.get<_FactoryService>(),
      isNot(same(root.get<_FactoryService>())),
    );
    expect(root.maybeGet<String>(), isNull);

    child.dispose();
    expect(disposable.disposed, isFalse);
    root.dispose();
    expect(disposable.disposed, isTrue);
    expect(() => root.get<_LazyService>(), throwsStateError);
  });

  test('service container reports circular dependencies', () {
    final services = BlenderServiceContainer();
    addTearDown(services.dispose);
    services.registerLazySingleton<_CircularService>(
      (container) => _CircularService(container.get<_CircularService>()),
    );

    expect(() => services.get<_CircularService>(), throwsStateError);
  });

  test('command registry executes enabled commands', () async {
    final registry = BlenderCommandRegistry();
    addTearDown(registry.dispose);
    var enabled = false;
    var executions = 0;
    registry.register(
      BlenderCommand(
        id: 'save',
        label: 'Save',
        shortcut: 'Ctrl S',
        enabled: () => enabled,
        execute: () => executions++,
      ),
    );

    expect(await registry.execute('missing'), isFalse);
    expect(await registry.execute('save'), isFalse);
    enabled = true;
    registry.refresh();
    expect(await registry.execute('save'), isTrue);
    expect(executions, 1);
  });

  test('status service reports and clears application messages', () {
    final status = BlenderStatusService();
    addTearDown(status.dispose);

    status.report('Saved scene', level: BlenderStatusLevel.success);
    expect(status.message?.text, 'Saved scene');
    expect(status.message?.level, BlenderStatusLevel.success);

    status.clear();
    expect(status.message, isNull);
  });

  test('command bindings map shortcuts to stable command ids', () {
    final bindings = BlenderCommandBindings();
    addTearDown(bindings.dispose);
    const activator = SingleActivator(LogicalKeyboardKey.keyK, control: true);
    bindings.register(
      const BlenderCommandBinding(
        commandId: 'document.comment',
        activator: activator,
      ),
    );

    expect(bindings.bindings.single.commandId, 'document.comment');
    expect(bindings.commandFor(activator), 'document.comment');
    expect(bindings.shortcuts[activator], isA<BlenderCommandIntent>());
    expect(
      () => bindings.register(
        const BlenderCommandBinding(commandId: 'other', activator: activator),
      ),
      throwsStateError,
    );
  });

  test('application keeps an injected command-binding override', () {
    final bindings = BlenderCommandBindings()
      ..register(
        const BlenderCommandBinding(
          commandId: 'document.undo',
          activator: SingleActivator(LogicalKeyboardKey.keyZ, control: true),
        ),
      );
    final application = BlenderApplicationController<int>(
      initialState: 0,
      workspace: const BlenderDockAreaNode<String>(id: 'main', value: 'main'),
      commandBindings: bindings,
    );
    addTearDown(application.dispose);

    expect(
      application.commandBindings.commandFor(
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true),
      ),
      'document.undo',
    );
    expect(
      application.commandBindings.commandFor(
        const SingleActivator(
          LogicalKeyboardKey.keyZ,
          control: true,
          shift: true,
        ),
      ),
      'application.redo',
    );
  });

  testWidgets('command binding scope dispatches the registered command', (
    tester,
  ) async {
    final commands = BlenderCommandRegistry();
    final bindings = BlenderCommandBindings();
    addTearDown(commands.dispose);
    addTearDown(bindings.dispose);
    var executions = 0;
    commands.register(
      BlenderCommand(
        id: 'document.comment',
        label: 'Comment',
        execute: () => executions++,
      ),
    );
    bindings.register(
      const BlenderCommandBinding(
        commandId: 'document.comment',
        activator: SingleActivator(LogicalKeyboardKey.keyK, control: true),
      ),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: BlenderCommandBindingScope(
          commands: commands,
          bindings: bindings,
          child: const Focus(autofocus: true, child: Text('Editor')),
        ),
      ),
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyK);
    await tester.pump();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

    expect(executions, 1);
  });

  test(
    'editor session persists views, outline selection, and properties target',
    () async {
      final storage = _MemoryStorage();
      final persistence = BlenderEditorSessionPersistence(
        storage: storage,
        storageKey: 'editor-session',
      );
      final session = BlenderEditorSessionService(persistence: persistence);
      session.selectView(
        workspaceId: 'modeling',
        areaId: 'main',
        viewId: 'viewport',
      );
      session.selectOutlinerItem('modeling', 'Cube');
      session.inspectPropertiesTarget('modeling', 'Cube');
      await session.flush();
      session.dispose();

      final restored = BlenderEditorSessionService(persistence: persistence);
      addTearDown(restored.dispose);
      expect(await restored.restore(), isTrue);
      expect(
        restored.viewForArea(workspaceId: 'modeling', areaId: 'main'),
        'viewport',
      );
      expect(restored.outlinerSelectionFor('modeling'), 'Cube');
      expect(restored.propertiesTargetFor('modeling'), 'Cube');
    },
  );

  test('interface preferences persist portable values', () async {
    final storage = _MemoryStorage();
    final persistence = BlenderInterfacePreferencesPersistence(
      storage: storage,
      storageKey: 'interface-preferences',
    );
    final preferences = BlenderInterfacePreferencesService(
      persistence: persistence,
    );
    preferences.update(
      (value) => value.copyWith(
        theme: BlenderThemePreset.light,
        uiScale: 1.25,
        lineWidth: BlenderInterfaceLineWidth.thick,
        showSplash: false,
        factorDisplayType: BlenderFactorDisplayType.percentage,
      ),
    );
    await preferences.flush();
    preferences.dispose();

    final restored = BlenderInterfacePreferencesService(
      persistence: persistence,
    );
    addTearDown(restored.dispose);
    expect(await restored.restore(), isTrue);
    expect(restored.value.theme, BlenderThemePreset.light);
    expect(restored.value.uiScale, 1.25);
    expect(restored.value.lineWidth, BlenderInterfaceLineWidth.thick);
    expect(restored.value.showSplash, isFalse);
    expect(
      restored.value.factorDisplayType,
      BlenderFactorDisplayType.percentage,
    );
  });

  test(
    'theme service imports Blender XML and persists custom themes',
    () async {
      const xml = '''<bpy>
  <Theme name="Portable Light">
    <user_interface>
      <ThemeUserInterface editor_border="#2D2D2DFF" editor_outline="#3A3A3AFF" editor_outline_active="#4F78BFFF" widget_text_cursor="#111111FF" link="#0A66C2FF" panel_header="#D5D5D5FF" panel_back="#C4C4C4FF" panel_sub_back="#B7B7B7FF" panel_outline="#707070FF">
        <wcol_regular><ThemeWidgetColors outline="#808080FF" inner="#D9D9D9FF" inner_sel="#A3C4F3FF" text="#202020FF" /></wcol_regular>
        <wcol_text><ThemeWidgetColors inner="#FFFFFFFF" text="#202020FF" /></wcol_text>
        <wcol_toolbar_item><ThemeWidgetColors inner="#C9C9C9FF" /></wcol_toolbar_item>
        <wcol_menu_back><ThemeWidgetColors inner="#E6E6E6FF" inner_sel="#A3C4F3FF" text="#555555FF" /></wcol_menu_back>
        <wcol_tab><ThemeWidgetColors inner="#CFCFCFFF" inner_sel="#F2F2F2FF" text="#303030FF" text_sel="#111111FF" /></wcol_tab>
        <wcol_list_item><ThemeWidgetColors inner_sel="#A3C4F3FF" /></wcol_list_item>
        <wcol_state><ThemeWidgetStateColors warning="#D99200FF" error="#C23B22FF" success="#2F8F4EFF" /></wcol_state>
      </ThemeUserInterface>
    </user_interface>
    <preferences><ThemePreferences back="#B3B3B3FF" /></preferences>
    <properties><ThemeProperties><space><ThemeSpaceGeneric back="#BABABAFF" /></space></ThemeProperties></properties>
  </Theme>
  <ThemeStyle />
</bpy>''';
      final storage = _MemoryStorage();
      final persistence = BlenderThemePersistence(
        storage: storage,
        storageKey: 'themes',
      );
      final service = BlenderThemeService(persistence: persistence);
      final imported = service.importBlenderXml(
        xml,
        sourceFileName: 'light.xml',
      );

      expect(imported.name, 'Portable Light');
      expect(imported.colors.canvas, const Color(0xFFB3B3B3));
      expect(imported.colors.buttonSelected, const Color(0xFFA3C4F3));
      expect(imported.colors.propertiesBackground, const Color(0xFFBABABA));
      expect(imported.sourceFileName, 'light.xml');
      expect(service.themes, hasLength(3));

      final encoded = service.exportActiveBlenderXml();
      final roundTrip = const BlenderThemeXmlCodec().decode(
        encoded,
        id: 'round-trip',
      );
      expect(roundTrip.colors.canvas, imported.colors.canvas);
      expect(roundTrip.colors.menuSelection, imported.colors.menuSelection);
      expect(
        roundTrip.colors.propertiesBackground,
        imported.colors.propertiesBackground,
      );

      await service.flush();
      service.dispose();
      final restored = BlenderThemeService(persistence: persistence);
      addTearDown(restored.dispose);
      expect(await restored.restore(), isTrue);
      expect(restored.activeTheme.name, 'Portable Light');
      expect(restored.activeTheme.colors.canvas, const Color(0xFFB3B3B3));
      restored.resetToDefault();
      expect(restored.activeTheme.id, 'blender-dark');
      expect(restored.themes, hasLength(3));
    },
  );

  test('theme service makes a custom copy before editing a built-in', () {
    final service = BlenderThemeService();
    addTearDown(service.dispose);

    service.updateActiveColor(
      BlenderThemeColorRole.accent,
      const Color(0xFF00AA88),
    );

    expect(service.activeTheme.isBuiltIn, isFalse);
    expect(service.activeTheme.name, 'Blender Dark Custom');
    expect(service.activeTheme.colors.accent, const Color(0xFF00AA88));
    expect(service.themes.first.colors.accent, isNot(const Color(0xFF00AA88)));
  });

  testWidgets('state and service scopes expose typed values', (tester) async {
    final state = BlenderStateStore<int>(4);
    final services = BlenderServiceContainer()
      ..registerSingleton<_LazyService>(_LazyService());
    addTearDown(state.dispose);
    addTearDown(services.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: BlenderServiceScope(
          services: services,
          child: BlenderStateScope<int>(
            store: state,
            child: Builder(
              builder: (context) => Text(
                '${BlenderStateScope.watch<int>(context).value} '
                '${BlenderServiceScope.read<_LazyService>(context).label}',
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('4 lazy'), findsOneWidget);
    state.replace(9);
    await tester.pump();
    expect(find.text('9 lazy'), findsOneWidget);
  });

  testWidgets('presentation service opens splash and About dialogs', (
    tester,
  ) async {
    final presentation = BlenderApplicationPresentationService(
      splash: const BlenderSplashScreenConfiguration(
        title: 'Editor Suite',
        message: 'Welcome back',
      ),
      about: const BlenderAboutDialogConfiguration(
        title: 'Editor Suite',
        version: '1.2.0',
      ),
    );
    addTearDown(presentation.dispose);
    await tester.pumpWidget(
      BlenderApp(
        home: Builder(
          builder: (context) => Column(
            children: <Widget>[
              BlenderButton(
                label: 'Splash',
                onPressed: () => presentation.showSplash(context),
              ),
              BlenderButton(
                label: 'About',
                onPressed: () => presentation.showAbout(context),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Splash'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('1.2.0'), findsOneWidget);
  });
}

class _DisposableService implements BlenderServiceDisposable {
  bool disposed = false;

  @override
  void dispose() => disposed = true;
}

class _LazyService {
  String get label => 'lazy';
}

class _FactoryService {
  _FactoryService(this.dependency);

  final _LazyService dependency;
}

class _CircularService {
  _CircularService(this.self);

  final _CircularService self;
}

class _MemoryStorage implements BlenderPersistentStorage {
  final Map<String, String> values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}
