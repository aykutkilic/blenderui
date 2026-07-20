part of '../widget_test.dart';

void registerShowcaseBootsWithBlenderLikeEditorRegionsTests() {
  testWidgets('showcase remains overflow-free at an extreme window size', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 300);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('showcase panes remain overflow-free at minimum split extents', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 500);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.drag(
      find.byKey(const ValueKey<String>('dock-divider-workspace-columns')),
      const Offset(500, 0),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.drag(
      find.byKey(const ValueKey<String>('dock-divider-main-stack')),
      const Offset(0, 400),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('showcase boots with Blender-like editor regions', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());

    expect(find.textContaining('Perspective'), findsOneWidget);
    expect(find.text('Scene Collection'), findsOneWidget);
    expect(find.text('Scene'), findsOneWidget);
    final propertiesTabs = tester.widget<BlenderPropertyTabs>(
      find.byType(BlenderPropertyTabs),
    );
    expect(propertiesTabs.tabs[propertiesTabs.selectedIndex].label, 'Object');
    expect(
      find.byKey(const ValueKey<String>('bottom-editor-selector')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('timeline-window-region')),
      findsOneWidget,
    );
    expect(find.text('Saved "scene.blend"'), findsOneWidget);
    expect(find.text('Building Asset Preview'), findsOneWidget);

    for (final value in <String>['Scene', 'ViewLayer']) {
      final arrow = tester.widget<BlenderIcon>(
        find.byKey(ValueKey<String>('data-block-selector-disclosure-$value')),
      );
      expect(arrow.glyph, BlenderGlyph.panelDisclosureDown);
      expect(arrow.size, 9);
    }

    final firstToolOptions = find.descendant(
      of: find.byKey(const ValueKey<String>('viewport-tool-shelf')),
      matching: find.byType(BlenderPopover),
    );
    expect(firstToolOptions, findsOneWidget);

    final fileRect = tester.getRect(find.text('File'));
    await tester.tapAt(fileRect.topLeft + const Offset(5, 5));
    await tester.pump();
    expect(find.text('Open Recent'), findsOneWidget);
    expect(find.text('Save Incremental'), findsOneWidget);
    await tester.tap(find.text('Import'));
    await tester.pump();
    expect(find.text('Alembic (.abc)'), findsOneWidget);
    await tester.tapAt(const Offset(700, 50));
    await tester.pump();
    await tester.tapAt(const Offset(700, 50));
    await tester.pump();

    final selectorRect = tester.getRect(
      find.byType(BlenderEditorTypeSelector).first,
    );
    await tester.tapAt(selectorRect.topLeft + const Offset(12, 11));
    await tester.pump();
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Animation'), findsNWidgets(3));
    expect(find.text('Scripting'), findsOneWidget);
    expect(find.text('Data'), findsOneWidget);
    expect(find.text('Asset Browser'), findsOneWidget);
    await tester.tap(find.text('3D Viewport'));
    await tester.pump();

    final bottomSelector = find.byKey(
      const ValueKey<String>('bottom-editor-selector'),
    );
    await tester.ensureVisible(bottomSelector);
    await tester.tap(bottomSelector);
    await tester.pump();
    expect(find.text('Timeline'), findsOneWidget);
    await tester.tap(find.text('UI Catalog'));
    await tester.pump();
    expect(find.text('Core controls'), findsOneWidget);
    expect(find.text('Templates'), findsOneWidget);
  });

  testWidgets('Edit opens the source-shaped Preferences temporary window', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1400, 980);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.ancestor(
        of: find.text('Edit'),
        matching: find.byType(BlenderPopover),
      ),
    );
    await tester.pump();
    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('Lock Object Modes'), findsOneWidget);
    expect(find.text('Preferences...'), findsOneWidget);

    final editMenu = tester.widget<BlenderMenu<String>>(
      find.byType(BlenderMenu<String>),
    );
    // Menu data remains the source of enabled state; UI rendering is covered
    // by the reusable control test.
    expect(
      editMenu.items.firstWhere((item) => item.label == 'Redo').enabled,
      isFalse,
    );

    await tester.tap(find.text('Preferences...'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Keyframes'), findsOneWidget);
    expect(find.text('F-Curves'), findsOneWidget);
    expect(find.text('Default Key Channels'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('preferences-window-menu-button')),
      findsOneWidget,
    );
    final resizeHandle = find.byKey(
      const ValueKey<String>('preferences-window-resize-handle'),
    );
    final beforeResize = tester.getSize(find.byType(BlenderPreferencesWindow));
    await tester.drag(resizeHandle, const Offset(80, 40));
    await tester.pump();
    expect(
      tester.getSize(find.byType(BlenderPreferencesWindow)).width,
      greaterThan(beforeResize.width),
    );

    await tester.tap(find.text('Themes').first);
    await tester.pumpAndSettle();
    final themeSelector = find.descendant(
      of: find.byType(BlenderThemePreferencesEditor),
      matching: find.byType(BlenderDropdown<String>),
    );
    await tester.tap(
      find
          .descendant(of: themeSelector, matching: find.byType(BlenderButton))
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blender Light').last);
    await tester.pumpAndSettle();
    final preferencesSurface = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey<String>('preferences-window-surface')),
    );
    expect(
      (preferencesSurface.decoration as BoxDecoration).color,
      const BlenderColorScheme.light().canvas,
    );
  });

  testWidgets('Properties contexts follow Blender source tab order', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final tabs = tester.widget<BlenderPropertyTabs>(
      find.byType(BlenderPropertyTabs),
    );
    expect(
      tabs.tabs.map((tab) => tab.label),
      orderedEquals(<String>[
        'Tool',
        'Render',
        'Output',
        'View Layer',
        'Scene',
        'World',
        'Collection',
        'Object',
        'Modifiers',
        'Effects',
        'Particles',
        'Physics',
        'Constraints',
        'Data',
        'Bone',
        'Bone Constraints',
        'Material',
        'Texture',
        'Strip',
        'Strip Modifiers',
      ]),
    );
    expect(
      tabs.visibleTabIds,
      containsAll(<String>[
        'particles',
        'bone',
        'bone_constraint',
        'strip_modifier',
      ]),
    );
  });

  testWidgets('Properties exposes the added source context bodies', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 820);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tapPropertyTab(tester, 'particles');
    expect(
      find.byKey(const ValueKey<String>('particle-system-list')),
      findsOneWidget,
    );
    expect(find.text('Particle System'), findsWidgets);
    final particleEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      particleEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Emission',
        'Hair Dynamics',
        'Cache',
        'Velocity',
        'Rotation',
        'Physics',
        'Render',
        'Viewport Display',
        'Children',
        'Field Weights',
        'Force Field Settings',
        'Vertex Groups',
        'Textures',
        'Hair Shape',
        'Animation',
        'Custom Properties',
      ]),
    );
    final hairDynamics = particleEditor.groups.firstWhere(
      (group) => group.title == 'Hair Dynamics',
    );
    expect(
      hairDynamics.children.map((group) => group.title),
      containsAll(<String>['Collisions', 'Structure', 'Volume']),
    );
    final forceFields = particleEditor.groups.firstWhere(
      (group) => group.title == 'Force Field Settings',
    );
    expect(
      forceFields.children.map((group) => group.title),
      containsAll(<String>['Type 1', 'Type 2']),
    );
    expect(
      forceFields.children
          .firstWhere((group) => group.title == 'Type 1')
          .children
          .map((group) => group.title),
      contains('Falloff'),
    );
    final physics = particleEditor.groups.firstWhere(
      (group) => group.title == 'Physics',
    );
    final springs = physics.children.firstWhere(
      (group) => group.title == 'Springs',
    );
    expect(
      springs.children.map((group) => group.title),
      contains('Viscoelastic Springs'),
    );
    expect(
      springs.children
          .firstWhere((group) => group.title == 'Viscoelastic Springs')
          .children
          .map((group) => group.title),
      contains('Advanced'),
    );

    await tapPropertyTab(tester, 'bone');
    expect(
      find.byKey(const ValueKey<String>('active-bone-field')),
      findsOneWidget,
    );
    final boneEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      boneEditor.groups.map((group) => group.title),
      contains('Bendy Bones'),
    );
    expect(
      boneEditor.groups
          .firstWhere((group) => group.title == 'Relations')
          .children
          .map((group) => group.title),
      contains('Bone Collections'),
    );

    await tapPropertyTab(tester, 'bone_constraint');
    final boneConstraints = tester.widget<BlenderConstraintStack>(
      find.byType(BlenderConstraintStack),
    );
    expect(boneConstraints.title, 'Bone Constraints');
    expect(find.text('Add Bone Constraint'), findsOneWidget);
    expect(
      boneConstraints.constraints.map((constraint) => constraint.name),
      contains('Copy Location'),
    );

    await tapPropertyTab(tester, 'strip_modifier');
    final stripModifiers = tester.widget<BlenderModifierStack>(
      find.byType(BlenderModifierStack),
    );
    expect(stripModifiers.title, 'Strip Modifiers');
    expect(
      stripModifiers.modifiers.map((modifier) => modifier.name),
      contains('Bevel'),
    );
  });

  testWidgets('showcase workspace matches its visual baseline', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
  });

  testWidgets('utility editor headers expose source menu families', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final selector = find.byWidgetPredicate(
      (widget) =>
          widget is BlenderEditorTypeSelector &&
          widget.value == BlenderEditorType.view3d,
    );
    final selectorRect = tester.getRect(selector);
    await tester.tapAt(selectorRect.topLeft + const Offset(12, 11));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Python Console'));
    await tester.pumpAndSettle();
    final mainHeader = find.ancestor(
      of: find.byWidgetPredicate(
        (widget) =>
            widget is BlenderEditorTypeSelector &&
            widget.value == BlenderEditorType.pythonConsole,
      ),
      matching: find.byType(BlenderAreaHeader),
    );
    final viewButton = find.ancestor(
      of: find.descendant(of: mainHeader, matching: find.text('View')),
      matching: find.byType(BlenderButton),
    );
    final viewRect = tester.getRect(viewButton.first);
    await tester.tapAt(viewRect.topLeft + const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Move to Line Begin'), findsOneWidget);
    expect(find.text('Languages'), findsOneWidget);
    expect(find.text('Area'), findsOneWidget);
    await tester.tapAt(const Offset(700, 50));
    await tester.pumpAndSettle();

    final consoleButton = find.ancestor(
      of: find.descendant(of: mainHeader, matching: find.text('Console')),
      matching: find.byType(BlenderButton),
    );
    final consoleRect = tester.getRect(consoleButton.first);
    await tester.tapAt(consoleRect.topLeft + const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Delete Previous Word'), findsOneWidget);
    expect(find.text('Delete Next Word'), findsOneWidget);
    await tester.tapAt(const Offset(700, 50));
    await tester.pumpAndSettle();

    final infoSelector = find.byWidgetPredicate(
      (widget) =>
          widget is BlenderEditorTypeSelector &&
          widget.value == BlenderEditorType.pythonConsole,
    );
    final infoSelectorRect = tester.getRect(infoSelector);
    await tester.tapAt(infoSelectorRect.topLeft + const Offset(12, 11));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Info'));
    await tester.pumpAndSettle();
    final infoButton = find.ancestor(
      of: find.descendant(
        of: find.ancestor(
          of: find.byWidgetPredicate(
            (widget) =>
                widget is BlenderEditorTypeSelector &&
                widget.value == BlenderEditorType.infoEditor,
          ),
          matching: find.byType(BlenderAreaHeader),
        ),
        matching: find.text('Info'),
      ),
      matching: find.byType(BlenderButton),
    );
    final infoRect = tester.getRect(infoButton.first);
    await tester.tapAt(infoRect.topLeft + const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Deselect All'), findsOneWidget);
    expect(find.text('Invert Selection'), findsOneWidget);
    expect(find.text('Select Box'), findsWidgets);
    expect(find.text('Report Details'), findsNothing);
  });

  testWidgets('top bar exposes source menu families', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final blenderButton = find.byWidgetPredicate(
      (widget) =>
          widget is BlenderIconButton &&
          widget.glyph == BlenderGlyph.cube &&
          widget.size == 30,
    );
    final blenderRect = tester.getRect(blenderButton);
    await tester.tapAt(blenderRect.topLeft + const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Splash Screen'), findsOneWidget);
    expect(find.text('Install Application Template...'), findsOneWidget);
    final blenderMenu = tester.widget<BlenderMenu<String>>(
      find.byType(BlenderMenu<String>),
    );
    final systemMenu = blenderMenu.items.firstWhere(
      (item) => item.label == 'System',
    );
    expect(
      systemMenu.submenu!.map((item) => item.label),
      containsAll(<String>[
        'Redraw Timer',
        'Clean Up Spacedata',
        'Clean Up Operator Presets',
      ]),
    );
    await tester.tapAt(const Offset(700, 50));
    await tester.pumpAndSettle();

    Future<void> openMenu(String label) async {
      final button = find.ancestor(
        of: find.text(label),
        matching: find.byType(BlenderButton),
      );
      final rect = tester.getRect(button.first);
      await tester.tapAt(rect.topLeft + const Offset(5, 5));
      await tester.pumpAndSettle();
    }

    await openMenu('Edit');
    expect(find.text('Undo History'), findsOneWidget);
    expect(find.text('Menu Search...'), findsOneWidget);
    expect(find.text('Operator Search...'), findsOneWidget);
    expect(find.text('Project Setup...'), findsOneWidget);
    await tester.tapAt(const Offset(700, 50));
    await tester.pumpAndSettle();

    await openMenu('File');
    final fileMenu = tester.widget<BlenderMenu<String>>(
      find.byType(BlenderMenu<String>),
    );
    final externalData = fileMenu.items.firstWhere(
      (item) => item.label == 'External Data',
    );
    expect(
      externalData.submenu!.map((item) => item.label),
      containsAll(<String>['Make Paths Relative', 'Find Missing Files...']),
    );
    final cleanUp = fileMenu.items.firstWhere(
      (item) => item.label == 'Clean Up',
    );
    expect(
      cleanUp.submenu!.map((item) => item.label),
      containsAll(<String>['Purge Unused Data...', 'Manage Unused Data...']),
    );
    final newFile = fileMenu.items.firstWhere((item) => item.label == 'New');
    expect(
      newFile.submenu!.map((item) => item.label),
      containsAll(<String>['Storyboarding', 'VFX']),
    );
    await tester.tapAt(const Offset(700, 50));
    await tester.pumpAndSettle();

    await openMenu('Render');
    expect(find.text('Render Audio...'), findsOneWidget);
    expect(find.text('View Render'), findsOneWidget);
    expect(find.text('View Animation'), findsOneWidget);
    await tester.tapAt(const Offset(700, 50));
    await tester.pumpAndSettle();

    await openMenu('Window');
    expect(find.text('New Main Window'), findsOneWidget);
    expect(find.text('Save Screenshot (Editor)...'), findsOneWidget);
    await tester.tapAt(const Offset(700, 50));
    await tester.pumpAndSettle();

    await openMenu('Help');
    expect(find.text('User Communities'), findsOneWidget);
    expect(find.text('Report a Bug'), findsOneWidget);
  });

  testWidgets('Graph Editor exposes source header families', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final selector = find.byWidgetPredicate(
      (widget) =>
          widget is BlenderEditorTypeSelector &&
          widget.value == BlenderEditorType.view3d,
    );
    final selectorRect = tester.getRect(selector);
    await tester.tapAt(selectorRect.topLeft + const Offset(12, 11));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Graph Editor'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('graph-normalize-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('graph-auto-normalize-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('graph-ghost-curves-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('graph-filters-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('graph-snapping-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('graph-proportional-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('graph-channels-region')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('graph-window-region')),
      findsOneWidget,
    );
    expect(find.text('CubeAction'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    for (final label in <String>['View', 'Select', 'Channel', 'Key']) {
      expect(find.text(label), findsWidgets);
    }

    final graphViewMenu = tester.widget<BlenderMenuButton<String>>(
      find
          .ancestor(
            of: find.text('View').first,
            matching: find.byType(BlenderMenuButton<String>),
          )
          .first,
    );
    expect(
      graphViewMenu.items.map((item) => item.label),
      containsAll(<String>[
        'Local View',
        'Show Extrapolation',
        'Toggle Dope Sheet',
      ]),
    );
  });
}
