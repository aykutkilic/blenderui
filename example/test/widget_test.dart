import 'package:blender_ui_example/main.dart';
import 'package:blender_ui_example/demo/demo_workbench.dart';
import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart'
    show
        BoxDecoration,
        CustomPaint,
        DecoratedBox,
        Offset,
        Scrollable,
        Size,
        SizedBox,
        ValueKey;
import 'package:flutter_test/flutter_test.dart';

import '../lib/showcase_viewport.dart';

Future<void> tapPropertyTab(WidgetTester tester, String id) async {
  final tab = find.byKey(ValueKey<String>('property-tab-$id'));
  final rail = find.byType(BlenderPropertyTabs);
  final scrollable = find.descendant(
    of: rail,
    matching: find.byType(Scrollable),
  );
  for (var attempt = 0; attempt < 10; attempt++) {
    if (tab.evaluate().isNotEmpty) {
      await tester.tap(tab);
      await tester.pumpAndSettle();
      return;
    }
    await tester.drag(scrollable, const Offset(0, -420));
    await tester.pumpAndSettle();
  }
  throw StateError('Properties tab $id was not mounted after scrolling');
}

void main() {
  testWidgets('showcase boots with Blender-like editor regions', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());

    expect(find.textContaining('Perspective'), findsOneWidget);
    expect(find.text('Scene Collection'), findsOneWidget);
    expect(find.text('Scene'), findsOneWidget);
    expect(find.text('Select Box'), findsWidgets);
    expect(find.text('Timeline'), findsWidgets);
    expect(find.text('Saved "scene.blend"'), findsOneWidget);
    expect(find.text('Building Asset Preview'), findsOneWidget);

    for (final value in <String>['Scene', 'ViewLayer']) {
      final arrow = tester.widget<BlenderIcon>(
        find.byKey(ValueKey<String>('data-block-selector-disclosure-$value')),
      );
      expect(arrow.glyph, BlenderGlyph.panelDisclosureDown);
      expect(arrow.size, 9);
    }

    final firstTool = find.descendant(
      of: find.byType(BlenderToolShelf),
      matching: find.byType(BlenderIconButton),
    );
    final firstToolRect = tester.getRect(firstTool.first);
    await tester.tapAt(firstToolRect.topLeft + const Offset(6, 6));
    await tester.pump();
    expect(find.text('Tweak'), findsOneWidget);
    expect(find.text('Select Box'), findsWidgets);
    await tester.tapAt(const Offset(700, 50));
    await tester.pump();

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
    expect(find.text('Animation'), findsNWidgets(2));
    expect(find.text('Scripting'), findsOneWidget);
    expect(find.text('Data'), findsOneWidget);
    expect(find.text('Asset Browser'), findsOneWidget);
    await tester.tap(find.text('3D Viewport'));
    await tester.pump();

    await tester.ensureVisible(find.text('Timeline').last);
    await tester.tap(
      find.ancestor(
        of: find.text('Timeline'),
        matching: find.byType(BlenderButton),
      ),
      warnIfMissed: false,
    );
    await tester.pump();
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

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_workspace.png'),
    );
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

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_graph_editor.png'),
    );
  });

  testWidgets('normal Outliner header keeps source display controls', (
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
    await tester.tap(find.text('Outliner'));
    await tester.pumpAndSettle();

    expect(find.byType(BlenderOutliner<String>), findsNWidgets(2));
    final outlinerHeader = find.byType(BlenderAreaHeader).first;
    expect(
      find.descendant(of: outlinerHeader, matching: find.text('Collection')),
      findsNothing,
    );
    expect(find.text('Scene Collection'), findsWidgets);
    expect(
      find.byType(BlenderDropdown<BlenderOutlinerDisplayMode>),
      findsNWidgets(2),
    );
    expect(find.byType(BlenderSearchField), findsNWidgets(3));

    final outlinerModes = tester
        .widgetList<BlenderDropdown<BlenderOutlinerDisplayMode>>(
          find.byType(BlenderDropdown<BlenderOutlinerDisplayMode>),
        )
        .toList();
    outlinerModes.last.onChanged?.call(BlenderOutlinerDisplayMode.dataApi);
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: outlinerHeader, matching: find.text('Edit')),
      findsOneWidget,
    );
    final mainOutliner = find.byType(BlenderOutliner<String>).first;
    expect(
      find.descendant(
        of: mainOutliner,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is BlenderIconButton &&
              widget.glyph == BlenderGlyph.keyframe,
        ),
      ),
      findsNWidgets(2),
    );

    outlinerModes.last.onChanged?.call(
      BlenderOutlinerDisplayMode.videoSequencer,
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: mainOutliner,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is BlenderIconButton && widget.glyph == BlenderGlyph.sync,
        ),
      ),
      findsOneWidget,
    );

    outlinerModes.last.onChanged?.call(BlenderOutlinerDisplayMode.blenderFile);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: mainOutliner,
        matching: find.byType(BlenderDropdown<String>),
      ),
      findsOneWidget,
    );

    outlinerModes.last.onChanged?.call(
      BlenderOutlinerDisplayMode.libraryOverrides,
    );
    await tester.pumpAndSettle();
    expect(find.byType(BlenderSearchField), findsOneWidget);
    expect(
      find.descendant(
        of: mainOutliner,
        matching: find.byType(BlenderDropdown<String>),
      ),
      findsOneWidget,
    );

    final libraryOverrideModes = tester
        .widgetList<BlenderDropdown<String>>(
          find.descendant(
            of: mainOutliner,
            matching: find.byType(BlenderDropdown<String>),
          ),
        )
        .toList();
    libraryOverrideModes.first.onChanged?.call('Properties');
    await tester.pumpAndSettle();
    expect(find.byType(BlenderSearchField), findsNWidgets(3));
    libraryOverrideModes.first.onChanged?.call('Hierarchies');
    await tester.pumpAndSettle();
    expect(find.byType(BlenderSearchField), findsOneWidget);

    outlinerModes.last.onChanged?.call(BlenderOutlinerDisplayMode.unusedData);
    await tester.pumpAndSettle();
    expect(find.text('Purge'), findsWidgets);
  });

  testWidgets('3D Viewport exposes source sidebar families', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    expect(find.byType(BlenderViewportSidebar), findsOneWidget);
    expect(find.text('Focal Length'), findsOneWidget);
    expect(find.text('View Lock'), findsOneWidget);
    expect(find.text('3D Cursor'), findsOneWidget);
    expect(find.text('Collections'), findsOneWidget);
    expect(find.text('Global Transform'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('viewport-transform-orientation')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('viewport-transform-pivot')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey<String>('viewport-snap')), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('viewport-proportional-editing')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('viewport-object-visibility')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('viewport-gizmo')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('viewport-overlays')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey<String>('viewport-xray')), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('viewport-shading-wireframe')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('viewport-shading-solid')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('viewport-shading-material-preview')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('viewport-shading-rendered')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('viewport-shading-options')),
      findsOneWidget,
    );
    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_viewport_sidebar.png'),
    );
  });

  testWidgets('Clip Editor exposes Blender Mask panels', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final selectorRect = tester.getRect(
      find.byType(BlenderEditorTypeSelector).first,
    );
    await tester.tapAt(selectorRect.topLeft + const Offset(12, 11));
    await tester.pump();
    await tester.tap(find.text('Movie Clip Editor'));
    await tester.pumpAndSettle();

    expect(find.byType(BlenderClipEditor), findsOneWidget);
    expect(find.byType(BlenderClipEditorSidebar), findsOneWidget);
    expect(find.text('Tracking Settings'), findsOneWidget);
    expect(find.text('Solve'), findsOneWidget);
    expect(find.text('2D Stabilization'), findsOneWidget);
    expect(find.text('Footage'), findsOneWidget);
    expect(find.byType(BlenderMaskProperties), findsOneWidget);
    expect(find.text('Mask Settings'), findsOneWidget);
    expect(find.text('Mask Layers'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('clip-mode-selector')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('clip-view-selector')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('clip-lock-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('clip-gizmo-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('clip-overlay-button')),
      findsOneWidget,
    );
    for (final label in <String>[
      'View',
      'Select',
      'Clip',
      'Track',
      'Reconstruction',
    ]) {
      expect(find.text(label), findsWidgets);
    }
    final clipViewMenu = tester.widget<BlenderMenuButton<String>>(
      find
          .ancestor(
            of: find.text('View').first,
            matching: find.byType(BlenderMenuButton<String>),
          )
          .first,
    );
    expect(
      clipViewMenu.items.map((item) => item.label),
      containsAll(<String>['Toolbar', 'Sidebar', 'View All']),
    );
    await tester.tap(find.byKey(const ValueKey<String>('clip-overlay-button')));
    await tester.pumpAndSettle();
    expect(find.text('Overlays'), findsOneWidget);
    expect(find.text('3D Markers'), findsOneWidget);
    await tester.tapAt(const Offset(500, 500));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_clip_mask.png'),
    );
  });

  testWidgets('Preferences exposes Blender source categories and panels', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final selectorRect = tester.getRect(
      find.byType(BlenderEditorTypeSelector).first,
    );
    await tester.tapAt(selectorRect.topLeft + const Offset(12, 11));
    await tester.pump();
    await tester.tap(find.text('Preferences'));
    await tester.pumpAndSettle();

    expect(find.byType(BlenderPreferencesEditor), findsOneWidget);
    expect(find.text('Interface'), findsWidgets);
    expect(find.text('Editing'), findsOneWidget);
    expect(find.text('Animation'), findsWidgets);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Display'), findsOneWidget);
    expect(find.text('Text Rendering'), findsOneWidget);
    expect(find.text('Editors'), findsWidgets);
    expect(find.text('Navigation Controls'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(BlenderPreferencesEditor),
        matching: find.text('Input'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<BlenderPreferencesEditor>(
            find.byType(BlenderPreferencesEditor),
          )
          .selectedCategory,
      'Input',
    );
    expect(find.text('Keyboard'), findsOneWidget);
    final inputSectionTitles = <String>[
      'Keyboard',
      'Mouse',
      'Tablet',
      'Touchpad',
      'NDOF',
    ];
    for (final title in inputSectionTitles) {
      final id = title.toLowerCase().replaceAll(' ', '-');
      expect(
        find.byKey(
          ValueKey<String>('preference-section-handle-preferences-Input-$id'),
        ),
        findsOneWidget,
      );
    }
    for (var index = 0; index < inputSectionTitles.length - 1; index++) {
      expect(
        tester.getTopLeft(find.text(inputSectionTitles[index])).dy,
        lessThan(
          tester.getTopLeft(find.text(inputSectionTitles[index + 1])).dy,
        ),
      );
    }

    await tester.tap(find.text('Assets').first);
    await tester.pumpAndSettle();
    expect(find.byType(BlenderAssetLibrariesPreferencesPanel), findsOneWidget);
    expect(find.text('Essentials'), findsOneWidget);
    expect(find.text('Studio Assets'), findsOneWidget);
    expect(find.text('Import Method'), findsOneWidget);
    expect(find.text('Use Relative Path'), findsOneWidget);
    await tester.tap(find.text('Interface').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Themes').first);
    await tester.pumpAndSettle();
    expect(find.text('User Interface'), findsWidgets);
    expect(find.text('Editor Background'), findsOneWidget);
    await tester.tap(find.text('Widgets').first);
    await tester.pumpAndSettle();
    expect(find.text('Button'), findsOneWidget);

    await tester.tap(find.text('Save & Load').first);
    await tester.pumpAndSettle();
    expect(find.text('Auto Run Python Scripts'), findsOneWidget);
    await tester.tap(find.text('Interface').first);
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_preferences.png'),
    );
  });

  testWidgets('theme selection updates the showcase Properties subsections', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final selectorRect = tester.getRect(
      find.byType(BlenderEditorTypeSelector).first,
    );
    await tester.tapAt(selectorRect.topLeft + const Offset(12, 11));
    await tester.pump();
    await tester.tap(find.text('Preferences'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Themes').first);
    await tester.pumpAndSettle();

    final selector = find.descendant(
      of: find.byType(BlenderThemePreferencesEditor),
      matching: find.byType(BlenderDropdown<String>),
    );
    await tester.tap(
      find.descendant(of: selector, matching: find.byType(BlenderButton)).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blender Light').last);
    await tester.pumpAndSettle();

    final panel = tester.widget<DecoratedBox>(
      find.byKey(
        const ValueKey<String>('showcase-tool-settings-panel-Options'),
      ),
    );
    expect(
      (panel.decoration as BoxDecoration).color,
      const BlenderColorScheme.light().panelBackground,
    );
  });

  testWidgets('File and Asset Browsers expose source side panels', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final selector = find.byType(BlenderEditorTypeSelector).first;
    await tester.tapAt(tester.getRect(selector).topLeft + const Offset(12, 11));
    await tester.pump();
    await tester.tap(find.text('File Browser'));
    await tester.pumpAndSettle();

    expect(find.byType(BlenderFileBrowserSidebar), findsOneWidget);
    final browserHeader = find.byType(BlenderFileBrowser);
    expect(
      find.descendant(
        of: browserHeader,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is BlenderIconButton &&
              widget.glyph == BlenderGlyph.stepBack,
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: browserHeader,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is BlenderIconButton &&
              widget.glyph == BlenderGlyph.stepForward,
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: browserHeader,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is BlenderIconButton &&
              widget.glyph == BlenderGlyph.folder,
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: browserHeader,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is BlenderIconButton &&
              widget.glyph == BlenderGlyph.refresh,
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: browserHeader,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is BlenderIconButton && widget.glyph == BlenderGlyph.plus,
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Directory Path'), findsOneWidget);
    expect(find.text('Volumes'), findsOneWidget);
    expect(find.text('Bookmarks'), findsOneWidget);
    expect(find.text('Advanced Filter'), findsOneWidget);
    final fileBrowser = browserHeader;
    final displaySettings = find.descendant(
      of: fileBrowser,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is BlenderIconButton &&
            widget.glyph == BlenderGlyph.settings,
      ),
    );
    await tester.tap(displaySettings);
    await tester.pumpAndSettle();
    expect(find.text('Recursions'), findsOneWidget);
    expect(find.text('Invert Sort'), findsOneWidget);
    await tester.tapAt(const Offset(500, 500));
    await tester.pumpAndSettle();
    final filterSettings = find.descendant(
      of: fileBrowser,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is BlenderIconButton && widget.glyph == BlenderGlyph.filter,
      ),
    );
    await tester.tap(filterSettings);
    await tester.pumpAndSettle();
    expect(find.text('.blend Files'), findsOneWidget);
    expect(find.text('Show Hidden'), findsOneWidget);
    await tester.tapAt(const Offset(1100, 50));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_file_browser.png'),
    );

    await tester.tapAt(tester.getRect(selector).topLeft + const Offset(12, 11));
    await tester.pump();
    await tester.tap(find.text('Asset Browser'));
    await tester.pumpAndSettle();

    expect(find.text('Asset Metadata'), findsOneWidget);
    expect(find.text('Asset Catalogs'), findsOneWidget);
    expect(find.text('Studio Lighting'), findsOneWidget);
    expect(find.text('Outdoor'), findsOneWidget);
    expect(find.text('Import'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Tags'), findsOneWidget);
    final assetBrowser = find.byType(BlenderFileBrowser);
    await tester.tap(
      find.descendant(
        of: assetBrowser,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is BlenderIconButton &&
              widget.glyph == BlenderGlyph.settings,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Preview Size'), findsOneWidget);
    expect(find.text('Sort By'), findsOneWidget);
    await tester.tapAt(const Offset(1100, 50));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: assetBrowser,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is BlenderIconButton &&
              widget.glyph == BlenderGlyph.filter,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Blender IDs'), findsOneWidget);
    expect(find.text('Access'), findsWidgets);
    await tester.tapAt(const Offset(1100, 50));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_asset_browser.png'),
    );
  });

  testWidgets('Node Editor exposes source sidebar families', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final selector = find.byType(BlenderEditorTypeSelector).first;
    await tester.tapAt(tester.getRect(selector).topLeft + const Offset(12, 11));
    await tester.pump();
    await tester.tap(find.text('Shader Editor'));
    await tester.pumpAndSettle();

    final nodeSidebar = find.byType(BlenderNodeEditorSidebar);
    expect(nodeSidebar, findsOneWidget);
    expect(
      find.descendant(of: nodeSidebar, matching: find.text('Tool')),
      findsOneWidget,
    );
    expect(find.text('Node'), findsWidgets);
    expect(find.text('View'), findsWidgets);
    expect(
      find.descendant(of: nodeSidebar, matching: find.text('Options')),
      findsNothing,
    );
    expect(find.text('Group'), findsOneWidget);
    expect(find.text('Texture Mapping'), findsOneWidget);
    expect(find.text('Properties'), findsOneWidget);
    expect(find.text('Custom Properties'), findsOneWidget);
    expect(
      find.descendant(of: nodeSidebar, matching: find.text('Object Types')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('node-tree-context')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('node-tree-datablock')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('node-pin-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('node-snap-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('node-overlay-button')),
      findsOneWidget,
    );
    for (final label in <String>['View', 'Select', 'Add', 'Node']) {
      expect(find.text(label), findsWidgets);
    }
    final nodeViewMenu = tester.widget<BlenderMenuButton<String>>(
      find
          .ancestor(
            of: find.text('View').first,
            matching: find.byType(BlenderMenuButton<String>),
          )
          .first,
    );
    expect(
      nodeViewMenu.items.map((item) => item.label),
      containsAll(<String>[
        'Toolbar',
        'Sidebar',
        'Frame Selected',
        'Frame All',
        'Zoom In',
        'Zoom Out',
      ]),
    );
    final nodeMenu = tester.widget<BlenderMenuButton<String>>(
      find
          .ancestor(
            of: find.text('Node').first,
            matching: find.byType(BlenderMenuButton<String>),
          )
          .first,
    );
    expect(
      nodeMenu.items.map((item) => item.label),
      containsAll(<String>[
        'Remove from Frame',
        'Make and Replace Links',
        'Links Cut',
        'Show/Hide',
      ]),
    );
    await tester.tap(find.byKey(const ValueKey<String>('node-overlay-button')));
    await tester.pumpAndSettle();
    expect(find.text('Node Editor Overlays'), findsOneWidget);
    expect(find.text('Previews'), findsOneWidget);
    await tester.tapAt(const Offset(1100, 50));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_node_editor.png'),
    );
  });

  testWidgets('Image and UV Editors expose source sidebar families', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final selector = find.byType(BlenderEditorTypeSelector).first;
    await tester.tapAt(tester.getRect(selector).topLeft + const Offset(12, 11));
    await tester.pump();
    await tester.tap(find.text('Image Editor'));
    await tester.pumpAndSettle();

    final imageSidebar = find.byType(BlenderImageEditorSidebar);
    expect(imageSidebar, findsOneWidget);
    expect(
      find.descendant(of: imageSidebar, matching: find.text('Brush Settings')),
      findsOneWidget,
    );
    expect(find.text('Image'), findsWidgets);
    expect(find.text('Render Slots'), findsOneWidget);
    expect(find.text('Histogram'), findsOneWidget);
    expect(find.text('Waveform'), findsOneWidget);
    expect(find.text('Vectorscope'), findsOneWidget);
    expect(find.text('Sample Line'), findsOneWidget);
    expect(find.text('Samples'), findsOneWidget);
    expect(find.text('Mask Layers'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('image-display-source')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('image-snap-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('image-pin-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('image-gizmo-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('image-overlay-button')),
      findsOneWidget,
    );

    final imageViewMenu = tester.widget<BlenderMenuButton<String>>(
      find
          .ancestor(
            of: find.text('View').first,
            matching: find.byType(BlenderMenuButton<String>),
          )
          .first,
    );
    expect(
      imageViewMenu.items.map((item) => item.label),
      containsAll(<String>[
        'Use Realtime Update',
        'Show Metadata',
        'Render Border',
        'Render Slot Cycle Next',
      ]),
    );
    final zoomMenu = imageViewMenu.items.firstWhere(
      (item) => item.label == 'Zoom',
    );
    expect(
      zoomMenu.submenu?.map((item) => item.label),
      containsAll(<String>['100% (1:1)', 'Zoom to Fit', 'Zoom Region...']),
    );

    await tester.tap(find.byKey(const ValueKey<String>('image-snap-button')));
    await tester.pumpAndSettle();
    expect(find.text('Snap Target'), findsOneWidget);
    expect(find.text('Snap Base'), findsOneWidget);
    expect(find.text('Move'), findsWidgets);
    await tester.tapAt(const Offset(500, 500));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_image_editor.png'),
    );

    await tester.tapAt(tester.getRect(selector).topLeft + const Offset(12, 11));
    await tester.pump();
    await tester.tap(find.text('UV Editor'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('image-uv-sync-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('image-proportional-button')),
      findsOneWidget,
    );
    final uvMenu = tester.widget<BlenderMenuButton<String>>(
      find
          .ancestor(
            of: find.text('UVs').first,
            matching: find.byType(BlenderMenuButton<String>),
          )
          .first,
    );
    expect(
      uvMenu.items.map((item) => item.label),
      containsAll(<String>[
        'Transform',
        'Snap',
        'Unwrap',
        'Pack Islands',
        'Show/Hide Faces',
      ]),
    );

    await tester.tap(find.byKey(const ValueKey<String>('image-snap-button')));
    await tester.pumpAndSettle();
    expect(find.text('Snapping'), findsOneWidget);
    expect(find.text('Snap Target'), findsOneWidget);
    await tester.tapAt(const Offset(500, 500));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('image-proportional-button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Proportional Editing'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
    await tester.tapAt(const Offset(500, 500));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_uv_editor.png'),
    );
  });

  testWidgets('Sequencer and NLA editors expose source sidebar families', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final selector = find.byType(BlenderEditorTypeSelector).first;
    await tester.tapAt(tester.getRect(selector).topLeft + const Offset(12, 11));
    await tester.pump();
    await tester.tap(find.text('Nonlinear Animation'));
    await tester.pumpAndSettle();

    expect(find.byType(BlenderSequencerSidebar), findsOneWidget);
    expect(find.text('Action'), findsWidgets);
    expect(find.text('Slot'), findsOneWidget);
    for (final label in <String>[
      'View',
      'Select',
      'Marker',
      'Add',
      'Track',
      'Strip',
    ]) {
      expect(find.text(label), findsWidgets);
    }
    expect(
      find.byKey(const ValueKey<String>('nla-filters-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('nla-snapping-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('nla-only-selected-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('nla-show-hidden-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('nla-show-missing-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('nla-only-errors-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('nla-playback-footer')),
      findsOneWidget,
    );
    final nlaViewMenu = tester.widget<BlenderMenuButton<String>>(
      find
          .ancestor(
            of: find.text('View').first,
            matching: find.byType(BlenderMenuButton<String>),
          )
          .first,
    );
    expect(
      nlaViewMenu.items.map((item) => item.label),
      containsAll(<String>[
        'View Selected',
        'Frame Scene Range',
        'Show Locked Time',
      ]),
    );
    await tester.tap(find.byKey(const ValueKey<String>('nla-filters-button')));
    await tester.pumpAndSettle();
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('F-Curve Name'), findsOneWidget);
    expect(find.text('Filter by Type'), findsOneWidget);
    expect(find.text('Meshes'), findsOneWidget);
    await tester.tapAt(const Offset(500, 500));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_nla_editor.png'),
    );

    await tester.tapAt(tester.getRect(selector).topLeft + const Offset(12, 11));
    await tester.pump();
    await tester.tap(find.text('Video Sequencer'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('sequencer-view-type')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('sequencer-scene-selector')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('sequencer-overlap-mode')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('sequencer-snapping-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('sequencer-gizmo-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('sequencer-overlay-button')),
      findsOneWidget,
    );
    for (final label in <String>['View', 'Select', 'Marker', 'Add', 'Strip']) {
      expect(find.text(label), findsWidgets);
    }
    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('sequencer-overlay-button')),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('sequencer-overlay-button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Overlays'), findsOneWidget);
    expect(find.text('Preview Overlays'), findsOneWidget);
    expect(find.text('Strips'), findsOneWidget);
    await tester.tapAt(const Offset(700, 50));
    await tester.pumpAndSettle();
    expect(find.text('Cache Settings'), findsOneWidget);
    expect(find.text('Proxy Settings'), findsOneWidget);
    expect(find.text('Safe Areas'), findsOneWidget);
    expect(find.text('Composition Guides'), findsOneWidget);
    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_sequencer.png'),
    );
  });

  testWidgets('Text Editor exposes source sidebar panels', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final selector = find.byType(BlenderEditorTypeSelector).first;
    await tester.tapAt(tester.getRect(selector).topLeft + const Offset(12, 11));
    await tester.pump();
    await tester.tap(find.text('Text Editor'));
    await tester.pumpAndSettle();

    expect(find.byType(BlenderTextEditorSidebar), findsOneWidget);
    expect(find.text('Properties'), findsOneWidget);
    expect(find.text('Find & Replace'), findsOneWidget);
    expect(find.text('Match Case'), findsOneWidget);
    expect(find.text('Replace All'), findsOneWidget);
    final textMenu = find.byWidgetPredicate(
      (widget) => widget is BlenderMenuButton<String> && widget.label == 'Text',
    );
    await tester.ensureVisible(textMenu);
    await tester.tap(textMenu);
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Save As'), findsOneWidget);
    await tester.tapAt(const Offset(700, 50));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_text_editor.png'),
    );
  });

  testWidgets('Project Editor exposes source navigation and save panels', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final selector = find.byType(BlenderEditorTypeSelector).first;
    await tester.tapAt(tester.getRect(selector).topLeft + const Offset(12, 11));
    await tester.pump();
    await tester.tap(find.text('Project'));
    await tester.pumpAndSettle();

    expect(find.byType(BlenderProjectEditor), findsOneWidget);
    expect(find.text('Navigation'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Root Path'), findsOneWidget);
    expect(find.text('Save Project'), findsWidgets);
    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_project_editor.png'),
    );
  });

  testWidgets('Spreadsheet exposes source header filter controls', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final selector = find.byType(BlenderEditorTypeSelector).first;
    await tester.tapAt(tester.getRect(selector).topLeft + const Offset(12, 11));
    await tester.pump();
    await tester.tap(find.text('Spreadsheet'));
    await tester.pumpAndSettle();

    expect(find.byType(BlenderSpreadsheetEditor), findsOneWidget);
    expect(find.text('Only Selected'), findsOneWidget);
    expect(find.textContaining('Internal Attributes'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('spreadsheet-only-selected-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('spreadsheet-filter-button')),
      findsOneWidget,
    );
    final spreadsheetViewMenu = tester.widget<BlenderMenuButton<String>>(
      find
          .ancestor(
            of: find.text('View').first,
            matching: find.byType(BlenderMenuButton<String>),
          )
          .first,
    );
    expect(
      spreadsheetViewMenu.items.map((item) => item.label),
      containsAll(<String>['Toolbar', 'Sidebar', 'Internal Attributes']),
    );
    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_spreadsheet.png'),
    );
  });

  testWidgets('Tool Properties uses Blender selection controls', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final selectionModes = find.byKey(
      const ValueKey<String>('tool-selection-operation-group'),
    );
    final selectionModeSize = tester.getSize(selectionModes);
    expect(selectionModeSize.height, 20);
    expect(selectionModeSize.width, greaterThan(180));
    expect(selectionModeSize.width, lessThanOrEqualTo(190));
    for (final glyph in <BlenderGlyph>[
      BlenderGlyph.selectBox,
      BlenderGlyph.selectExtend,
      BlenderGlyph.selectSubtract,
      BlenderGlyph.selectDifference,
      BlenderGlyph.selectIntersect,
    ]) {
      expect(
        find.descendant(
          of: selectionModes,
          matching: find.byWidgetPredicate(
            (widget) => widget is BlenderIcon && widget.glyph == glyph,
          ),
        ),
        findsOneWidget,
      );
    }

    final optionsDisclosure = tester.widget<BlenderIcon>(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Options'),
      ),
    );
    expect(optionsDisclosure.glyph, BlenderGlyph.panelDisclosureDown);
    expect(optionsDisclosure.size, 9);
    final optionsHandle = tester.widget<BlenderIcon>(
      find.byKey(const ValueKey<String>('tool-settings-drag-handle-Options')),
    );
    expect(optionsHandle.glyph, BlenderGlyph.dragHandle);
    expect(optionsHandle.size, 9);

    final transformDisclosure = tester.widget<BlenderIcon>(
      find.byKey(
        const ValueKey<String>('tool-settings-nested-disclosure-Transform'),
      ),
    );
    expect(transformDisclosure.glyph, BlenderGlyph.panelDisclosureDown);
    expect(transformDisclosure.size, 9);

    final workspaceDisclosure = tester.widget<BlenderIcon>(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Workspace'),
      ),
    );
    expect(workspaceDisclosure.glyph, BlenderGlyph.panelDisclosureRight);
    expect(workspaceDisclosure.size, 9);

    await tester.tap(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Workspace'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pin Scene'), findsOneWidget);
    expect(find.text('Filter Add-ons'), findsOneWidget);
    expect(find.text('Unknown add-ons'), findsOneWidget);
    expect(find.text('legacy_tools'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('tool-workspace-filter-by-owner')),
      findsOneWidget,
    );
    expect(find.text('Custom Properties'), findsOneWidget);

    final brushDisclosure = tester.widget<BlenderIcon>(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Brush Asset'),
      ),
    );
    expect(brushDisclosure.glyph, BlenderGlyph.panelDisclosureDown);
    final brushSettingsDisclosure = tester.widget<BlenderIcon>(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Brush Settings'),
      ),
    );
    expect(brushSettingsDisclosure.glyph, BlenderGlyph.panelDisclosureDown);
    for (final title in <String>[
      'Advanced',
      'Color Picker',
      'Color Palette',
      'Clone from Paint Slot',
      'Cursor',
      'Texture',
      'Texture Mask',
      'Stroke',
      'Falloff',
    ]) {
      final disclosure = tester.widget<BlenderIcon>(
        find.byKey(ValueKey<String>('tool-settings-nested-disclosure-$title')),
      );
      expect(disclosure.glyph, BlenderGlyph.panelDisclosureRight);
    }
    expect(find.text('Clone Layer'), findsNothing);
    await tester.ensureVisible(
      find.byKey(
        const ValueKey<String>('tool-settings-nested-disclosure-Stroke'),
      ),
    );
    await tester.tap(
      find.byKey(
        const ValueKey<String>('tool-settings-nested-disclosure-Stroke'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Spacing'), findsOneWidget);
    expect(find.text('Input Samples'), findsOneWidget);
    expect(find.text('Stabilize Stroke'), findsOneWidget);
  });

  testWidgets('Tool Properties follows Blender sculpt mode panel families', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Workspace'),
      ),
    );
    await tester.pumpAndSettle();
    tester
        .widget<BlenderDropdown<String>>(
          find.byKey(const ValueKey<String>('tool-workspace-mode')),
        )
        .onChanged
        ?.call('Sculpt Mode');
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('tool-workspace-mode')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Dyntopo'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Remesh'),
      ),
      findsOneWidget,
    );
    expect(find.text('Symmetry'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Dyntopo'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Detail Size'), findsOneWidget);
    expect(find.text('Refine Method'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Options'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(
        const ValueKey<String>('tool-settings-nested-disclosure-Gravity'),
      ),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(
        const ValueKey<String>('tool-settings-nested-disclosure-Gravity'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Factor'), findsOneWidget);

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_tool_sculpt_mode.png'),
    );
  });

  testWidgets('Tool Properties follows Blender texture paint utility panels', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Workspace'),
      ),
    );
    await tester.pumpAndSettle();
    tester
        .widget<BlenderDropdown<String>>(
          find.byKey(const ValueKey<String>('tool-workspace-mode')),
        )
        .onChanged
        ?.call('Texture Paint');
    await tester.pumpAndSettle();

    for (final title in <String>[
      'Texture Slots',
      'Canvas',
      'Color Attributes',
      'Vertex Groups',
      'Masking',
    ]) {
      expect(
        find.byKey(ValueKey<String>('tool-settings-panel-disclosure-$title')),
        findsOneWidget,
      );
    }

    await tester.tap(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Masking'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(
        const ValueKey<String>('tool-settings-nested-disclosure-Stencil Mask'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('tool-settings-nested-disclosure-Cavity Mask'),
      ),
      findsOneWidget,
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_tool_texture_paint.png'),
    );
  });

  testWidgets('Tool Properties follows Blender Grease Pencil Draw hierarchy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Workspace'),
      ),
    );
    await tester.pumpAndSettle();
    tester
        .widget<BlenderDropdown<String>>(
          find.byKey(const ValueKey<String>('tool-workspace-mode')),
        )
        .onChanged
        ?.call('Grease Pencil Draw');
    await tester.pumpAndSettle();

    expect(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Color'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('tool-settings-nested-disclosure-Advanced'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('tool-settings-nested-disclosure-Stroke'),
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(
        const ValueKey<String>('tool-settings-nested-disclosure-Stroke'),
      ),
    );
    await tester.tap(
      find.byKey(
        const ValueKey<String>('tool-settings-nested-disclosure-Stroke'),
      ),
    );
    await tester.pumpAndSettle();
    for (final title in <String>[
      'Post-Processing',
      'Randomize',
      'Stabilize Stroke',
    ]) {
      expect(
        find.byKey(ValueKey<String>('tool-settings-nested-disclosure-$title')),
        findsOneWidget,
      );
    }

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_tool_grease_pencil_draw.png'),
    );
  });

  testWidgets('Tool Properties follows Blender Grease Pencil paint families', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Workspace'),
      ),
    );
    await tester.pumpAndSettle();
    final modeDropdown = tester.widget<BlenderDropdown<String>>(
      find.byKey(const ValueKey<String>('tool-workspace-mode')),
    );
    modeDropdown.onChanged?.call('Grease Pencil Weight Paint');
    await tester.pumpAndSettle();
    expect(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Options'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('tool-settings-nested-disclosure-Falloff'),
      ),
      findsOneWidget,
    );

    tester
        .widget<BlenderDropdown<String>>(
          find.byKey(const ValueKey<String>('tool-workspace-mode')),
        )
        .onChanged
        ?.call('Grease Pencil Vertex Paint');
    await tester.pumpAndSettle();
    expect(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Color'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Falloff'),
      ),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Color'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(
        const ValueKey<String>('tool-settings-nested-disclosure-Palette'),
      ),
      findsOneWidget,
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_tool_grease_pencil_vertex_paint.png'),
    );
  });

  testWidgets('Tool Properties follows remaining View3D mode branches', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Workspace'),
      ),
    );
    await tester.pumpAndSettle();

    tester
        .widget<BlenderDropdown<String>>(
          find.byKey(const ValueKey<String>('tool-workspace-mode')),
        )
        .onChanged
        ?.call('Armature Edit');
    await tester.pumpAndSettle();
    expect(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Options'),
      ),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Options'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('X-Axis Mirror'), findsOneWidget);

    tester
        .widget<BlenderDropdown<String>>(
          find.byKey(const ValueKey<String>('tool-workspace-mode')),
        )
        .onChanged
        ?.call('Curves Sculpt');
    await tester.pumpAndSettle();
    expect(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Symmetry'),
      ),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(
        const ValueKey<String>('tool-settings-panel-disclosure-Symmetry'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Mirror X'), findsOneWidget);
    expect(find.text('Mirror Y'), findsOneWidget);
    expect(find.text('Mirror Z'), findsOneWidget);
  });

  testWidgets('Output Properties matches Blender panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(720, 700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final propertiesHeader = tester.widget<BlenderAreaHeader>(
      find.byKey(const ValueKey<String>('properties-area-header')),
    );
    expect(propertiesHeader.showBottomBorder, isFalse);
    final propertiesSearch = find.descendant(
      of: find.byKey(const ValueKey<String>('properties-area-header')),
      matching: find.byType(BlenderSearchField),
    );
    expect(tester.getSize(propertiesSearch), const Size(120, 20));

    final outputTab = find.bySemanticsLabel('Output');
    expect(outputTab, findsOneWidget);
    await tester.tap(outputTab);
    await tester.pumpAndSettle();

    expect(find.text('Output'), findsOneWidget);
    expect(find.text('Format'), findsOneWidget);
    expect(find.text('Frame Range'), findsOneWidget);
    expect(find.text('Stereoscopy'), findsOneWidget);
    expect(find.bySemanticsLabel('Format presets'), findsOneWidget);

    final outputEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      outputEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Post Processing',
        'Metadata',
        'Views',
        'Color Management',
        'Pixel Density',
        'Encoding',
      ]),
    );
    await tester.drag(
      find.byType(BlenderPropertiesEditor),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BlenderPathField), findsOneWidget);
    expect(find.text('Saving'), findsOneWidget);
    expect(find.text('File Extensions'), findsOneWidget);
    expect(find.text('Cache Result'), findsOneWidget);
    expect(find.text('Color Depth'), findsOneWidget);
    expect(find.text('Compression'), findsOneWidget);
    expect(find.text('36%'), findsOneWidget);
    expect(find.text('Post Processing'), findsOneWidget);
    expect(find.text('Metadata'), findsOneWidget);
    expect(find.text('Views'), findsOneWidget);
    expect(find.text('Pixel Density'), findsOneWidget);
    expect(find.text('Encoding'), findsOneWidget);
    await tester.drag(
      find.byType(BlenderPropertiesEditor),
      const Offset(0, 1000),
    );
    await tester.pumpAndSettle();

    await tester.enterText(propertiesSearch, 'Frame Rate');
    await tester.pumpAndSettle();
    expect(find.text('Format'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BlenderPropertiesEditor),
        matching: find.text('Frame Rate'),
      ),
      findsOneWidget,
    );
    expect(find.text('Resolution X'), findsNothing);
    expect(find.text('Frame Range'), findsNothing);
    expect(find.text('Stereoscopy'), findsNothing);

    await tester.enterText(propertiesSearch, '');
    await tester.pumpAndSettle();
    expect(find.text('Frame Range'), findsOneWidget);
    expect(find.text('Stereoscopy'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Format presets'));
    await tester.pumpAndSettle();
    expect(find.text('4K DCI 2160p'), findsOneWidget);
    await tester.tap(find.text('4K DCI 2160p'));
    await tester.pumpAndSettle();
    expect(find.text('4K DCI 2160p'), findsNothing);

    final stereoscopy = find.byKey(
      const ValueKey<String>('stereoscopy-header-checkbox'),
    );
    expect(stereoscopy, findsOneWidget);

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_output_properties.png'),
    );
  });

  testWidgets('Render Properties follows Blender panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(720, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(BlenderPropertyTabs),
        matching: find.bySemanticsLabel('Render'),
      ),
    );
    await tester.pumpAndSettle();

    final renderEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      renderEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Sampling',
        'Light Paths',
        'Raytracing',
        'Volumes',
        'Depth of Field',
        'Motion Blur',
        'Film',
        'Performance',
        'Simplify',
        'Color Management',
        'Freestyle',
      ]),
    );
    final sampling = renderEditor.groups.firstWhere(
      (group) => group.title == 'Sampling',
    );
    expect(
      sampling.children.map((group) => group.title),
      containsAll(<String>['Viewport', 'Render', 'Shadows', 'Advanced']),
    );
    final colorManagement = renderEditor.groups.firstWhere(
      (group) => group.title == 'Color Management',
    );
    expect(
      colorManagement.children.map((group) => group.title),
      containsAll(<String>[
        'Working Space',
        'Advanced',
        'Curves',
        'White Balance',
      ]),
    );
    expect(
      find.byKey(const ValueKey<String>('active-render-engine-field')),
      findsOneWidget,
    );
    expect(find.text('Render Engine'), findsOneWidget);
    expect(find.text('Samples'), findsWidgets);

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_render_properties.png'),
    );
  });

  testWidgets('Render Properties switches to Blender Workbench families', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(720, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(BlenderPropertyTabs),
        matching: find.bySemanticsLabel('Render'),
      ),
    );
    await tester.pumpAndSettle();

    tester
        .widget<BlenderDropdown<String>>(
          find.byKey(const ValueKey<String>('active-render-engine-field')),
        )
        .onChanged
        ?.call('Workbench');
    await tester.pumpAndSettle();

    final renderEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      renderEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Sampling',
        'Film',
        'Lighting',
        'Object Color',
        'Options',
        'Simplify',
        'Color Management',
        'Freestyle',
      ]),
    );
    expect(
      renderEditor.groups.map((group) => group.title),
      isNot(contains('Raytracing')),
    );
    final simplify = renderEditor.groups.firstWhere(
      (group) => group.title == 'Simplify',
    );
    expect(
      simplify.children.map((group) => group.title),
      containsAll(<String>['Viewport', 'Render', 'Grease Pencil']),
    );
    expect(find.text('Render Engine'), findsOneWidget);
    expect(find.text('World Space Lighting'), findsOneWidget);
    expect(find.text('Object Color'), findsOneWidget);

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_render_workbench.png'),
    );
  });

  testWidgets('Scene Properties follows Blender panel anatomy', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(720, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(BlenderPropertyTabs),
        matching: find.bySemanticsLabel('Scene'),
      ),
    );
    await tester.pumpAndSettle();

    final sceneEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      find.byKey(const ValueKey<String>('active-scene-field')),
      findsOneWidget,
    );
    expect(
      sceneEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Scene',
        'Units',
        'Keying Sets',
        'Audio',
        'Gravity',
        'Simulation',
        'Rigid Body World',
        'Light Probes',
        'Animation',
        'Custom Properties',
      ]),
    );
    final rigidBody = sceneEditor.groups.firstWhere(
      (group) => group.title == 'Rigid Body World',
    );
    expect(
      rigidBody.children.map((group) => group.title),
      containsAll(<String>['Settings', 'Cache', 'Field Weights']),
    );
    expect(find.text('Camera'), findsWidgets);
    expect(find.text('Background Set'), findsOneWidget);
    expect(find.text('Active Clip'), findsOneWidget);

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_scene_properties.png'),
    );
  });

  testWidgets('World Properties follows Blender panel anatomy', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(720, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(BlenderPropertyTabs),
        matching: find.bySemanticsLabel('World'),
      ),
    );
    await tester.pumpAndSettle();

    final worldEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      worldEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Surface',
        'Volume',
        'Mist Pass',
        'Settings',
        'Viewport Display',
        'Animation',
        'Custom Properties',
      ]),
    );
    final settings = worldEditor.groups.firstWhere(
      (group) => group.title == 'Settings',
    );
    expect(
      settings.children.map((group) => group.title),
      containsAll(<String>['Light Probe', 'Sun']),
    );
    final sun = settings.children.firstWhere((group) => group.title == 'Sun');
    expect(sun.children.map((group) => group.title), contains('Shadow'));
    expect(
      find.byKey(const ValueKey<String>('active-world-field')),
      findsOneWidget,
    );
    expect(find.text('Surface'), findsWidgets);

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_world_properties.png'),
    );
  });

  testWidgets('Modifier Properties follows Blender source menus and stack', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(BlenderPropertyTabs),
        matching: find.bySemanticsLabel('Modifiers'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add Modifier'), findsOneWidget);
    expect(find.text('Bevel'), findsOneWidget);
    expect(find.text('Subdivision Surface'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Segments'), findsOneWidget);
    expect(find.byType(BlenderModifierStack), findsOneWidget);

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_modifier_properties.png'),
    );
  });

  testWidgets('Material Properties follows Blender panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tapPropertyTab(tester, 'material');

    final materialEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      materialEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Preview',
        'Surface',
        'Volume',
        'Displacement',
        'Thickness',
        'Settings',
        'Viewport Display',
        'Line Art',
        'Freestyle Line',
        'Grease Pencil',
        'Animation',
        'Custom Properties',
      ]),
    );
    final settings = materialEditor.groups.firstWhere(
      (group) => group.title == 'Settings',
    );
    expect(
      settings.children.map((group) => group.title),
      containsAll(<String>['Surface', 'Volume']),
    );
    final greasePencil = materialEditor.groups.firstWhere(
      (group) => group.title == 'Grease Pencil',
    );
    expect(
      greasePencil.children.map((group) => group.title),
      contains('Surface'),
    );
    expect(
      find.byKey(const ValueKey<String>('active-material-field')),
      findsOneWidget,
    );
    expect(find.text('Material'), findsWidgets);
    expect(find.text('Surface'), findsWidgets);

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_material_properties.png'),
    );
  });

  testWidgets('Object Properties follows Blender transform anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final optionsButton = tester.widget<BlenderIconButton>(
      find.byKey(const ValueKey<String>('properties-context-options-button')),
    );
    expect(optionsButton.glyph, BlenderGlyph.panelDisclosureDown);
    await tester.tap(
      find.byKey(const ValueKey<String>('properties-context-options-button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sync with Outliner'), findsOneWidget);
    expect(find.text('Always'), findsOneWidget);
    expect(find.text('Never'), findsOneWidget);
    expect(find.text('Auto'), findsOneWidget);
    expect(find.text('Selectable'), findsNothing);
    await tester.tapAt(const Offset(500, 500));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Object').last);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('active-object-field')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(BlenderPropertiesEditor),
        matching: find.text('Transform'),
      ),
      findsOneWidget,
    );
    final properties = find.byType(BlenderPropertiesEditor);
    for (final label in <String>[
      'Location X',
      'Rotation X',
      'Mode',
      'Scale X',
      'Delta Transform',
    ]) {
      expect(
        find.descendant(of: properties, matching: find.text(label)),
        findsOneWidget,
      );
    }
    final objectEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      objectEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Collections',
        'Instancing',
        'Motion Paths',
        'Visibility',
        'Animation',
        'Custom Properties',
        'Shading',
        'Line Art',
      ]),
    );
    final shading = objectEditor.groups.firstWhere(
      (group) => group.title == 'Shading',
    );
    expect(
      shading.children.map((group) => group.title),
      containsAll(<String>[
        'Light Linking',
        'Shadow Linking',
        'Shadow Terminator',
      ]),
    );

    // The source-ordered object panels extend beyond the initial viewport.
    // Scroll to the later headers before asserting their rendered presence;
    // the descriptor assertions above still cover the complete anatomy.
    final propertiesScroll = find.descendant(
      of: find.byType(BlenderPropertiesEditor),
      matching: find.byType(Scrollable),
    );
    expect(propertiesScroll, findsOneWidget);
    for (var index = 0; index < 4; index++) {
      await tester.drag(propertiesScroll.first, const Offset(0, -500));
      await tester.pumpAndSettle();
    }
    expect(find.text('Relations'), findsOneWidget);
    expect(find.text('Viewport Display'), findsWidgets);
    await tester.drag(propertiesScroll.first, const Offset(0, 10000));
    await tester.pumpAndSettle();

    final numberFields = tester
        .widgetList<BlenderNumberField>(find.byType(BlenderNumberField))
        .toList();
    expect(numberFields.where((field) => field.suffix == ' m').length, 3);
    expect(numberFields.where((field) => field.suffix == '°').length, 3);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is BlenderIcon && widget.glyph == BlenderGlyph.unlock,
      ),
      findsNWidgets(9),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_object_properties.png'),
    );
  });

  testWidgets('Mesh Data Properties follows Blender data panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Data'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('active-data-field')),
      findsOneWidget,
    );
    expect(find.text('Vertex Groups'), findsOneWidget);
    expect(find.text('Shape Keys'), findsOneWidget);

    final meshEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      meshEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Vertex Groups',
        'Shape Keys',
        'UV Maps',
        'Color Attributes',
        'Attributes',
        'Texture Space',
        'Remesh',
        'Geometry Data',
        'Animation',
        'Custom Properties',
      ]),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_mesh_data.png'),
    );
  });

  testWidgets('Camera Data follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find
          .descendant(
            of: find.byType(BlenderOutliner<String>),
            matching: find.text('Camera'),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Data'));
    await tester.pumpAndSettle();

    expect(find.text('Camera Data'), findsOneWidget);
    expect(find.text('Lens'), findsOneWidget);
    expect(find.text('Depth of Field'), findsOneWidget);
    expect(find.text('Background Images'), findsOneWidget);

    final cameraEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      cameraEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Lens',
        'Stereoscopy',
        'Camera',
        'Depth of Field',
        'Background Images',
        'Viewport Display',
        'Safe Areas',
        'Animation',
        'Custom Properties',
      ]),
    );
    final depthOfField = cameraEditor.groups.firstWhere(
      (group) => group.title == 'Depth of Field',
    );
    expect(
      depthOfField.children.map((group) => group.title),
      contains('Aperture'),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_camera_data.png'),
    );
  });

  testWidgets('Curve Data follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final outlinerScroll = find.descendant(
      of: find.byType(BlenderOutliner<String>),
      matching: find.byType(Scrollable),
    );
    await tester.drag(outlinerScroll.last, const Offset(0, -100));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Curve').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Data'));
    await tester.pumpAndSettle();

    expect(find.text('Curve Data'), findsOneWidget);
    expect(find.text('Shape'), findsOneWidget);

    final curveEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      curveEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Shape',
        'Texture Space',
        'Geometry',
        'Path Animation',
        'Animation',
        'Custom Properties',
      ]),
    );
    final geometry = curveEditor.groups.firstWhere(
      (group) => group.title == 'Geometry',
    );
    expect(
      geometry.children.map((group) => group.title),
      containsAll(<String>['Bevel', 'Start & End Mapping']),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_curve_data.png'),
    );
  });

  testWidgets('Text Data follows Blender source panel anatomy', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Data'));
    await tester.pumpAndSettle();
    final dataField = tester.widget<BlenderDataBlockField<String>>(
      find.byKey(const ValueKey<String>('active-data-field')),
    );
    dataField.onChanged?.call('Text');
    await tester.pumpAndSettle();

    expect(find.text('Text Data'), findsOneWidget);
    final textEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      textEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Shape',
        'Texture Space',
        'Font',
        'Paragraph',
        'Text Boxes',
        'Animation',
        'Custom Properties',
      ]),
    );
    final font = textEditor.groups.firstWhere((group) => group.title == 'Font');
    expect(font.children.map((group) => group.title), contains('Transform'));
    final paragraph = textEditor.groups.firstWhere(
      (group) => group.title == 'Paragraph',
    );
    expect(
      paragraph.children.map((group) => group.title),
      containsAll(<String>['Alignment', 'Spacing']),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_text_data.png'),
    );
  });

  testWidgets('Light Data follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final outlinerScroll = find.descendant(
      of: find.byType(BlenderOutliner<String>),
      matching: find.byType(Scrollable),
    );
    await tester.drag(outlinerScroll.last, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Light').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Data'));
    await tester.pumpAndSettle();

    expect(find.text('Light Data'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Light'), findsWidgets);

    final lightEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      lightEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Preview',
        'Light',
        'Animation',
        'Custom Properties',
      ]),
    );
    final lightSettings = lightEditor.groups.firstWhere(
      (group) => group.title == 'Light',
    );
    expect(
      lightSettings.children.map((group) => group.title),
      containsAll(<String>[
        'Shadow',
        'Influence',
        'Custom Distance',
        'Beam Shape',
      ]),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_light_data.png'),
    );
  });

  testWidgets('Curves Data follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final outlinerScroll = find.descendant(
      of: find.byType(BlenderOutliner<String>),
      matching: find.byType(Scrollable),
    );
    await tester.drag(outlinerScroll.last, const Offset(0, -100));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Curves').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Data'));
    await tester.pumpAndSettle();

    expect(find.text('Curves Data'), findsOneWidget);
    expect(find.text('Surface'), findsWidgets);

    final curvesEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      curvesEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Surface',
        'Attributes',
        'Animation',
        'Custom Properties',
      ]),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_curves_data.png'),
    );
  });

  testWidgets('Lattice Data follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final outlinerScroll = find.descendant(
      of: find.byType(BlenderOutliner<String>),
      matching: find.byType(Scrollable),
    );
    await tester.drag(outlinerScroll.last, const Offset(0, -420));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lattice').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Data'));
    await tester.pumpAndSettle();

    expect(find.text('Lattice Data'), findsOneWidget);
    expect(find.text('Lattice'), findsWidgets);

    final latticeEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      latticeEditor.groups.map((group) => group.title),
      containsAll(<String>['Lattice', 'Animation', 'Custom Properties']),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_lattice_data.png'),
    );
  });

  testWidgets('Speaker Data follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final outlinerScroll = find.descendant(
      of: find.byType(BlenderOutliner<String>),
      matching: find.byType(Scrollable),
    );
    await tester.drag(outlinerScroll.last, const Offset(0, -220));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Speaker').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Data'));
    await tester.pumpAndSettle();

    expect(find.text('Speaker Data'), findsOneWidget);
    expect(find.text('Sound'), findsWidgets);

    final speakerEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      speakerEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Sound',
        'Distance',
        'Cone',
        'Animation',
        'Custom Properties',
      ]),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_speaker_data.png'),
    );
  });

  testWidgets('Point Cloud Data follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final outlinerScroll = find.descendant(
      of: find.byType(BlenderOutliner<String>),
      matching: find.byType(Scrollable),
    );
    await tester.drag(outlinerScroll.last, const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Point Cloud').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Data'));
    await tester.pumpAndSettle();

    expect(find.text('Point Cloud Data'), findsOneWidget);
    expect(find.text('Attributes'), findsWidgets);

    final pointCloudEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      pointCloudEditor.groups.map((group) => group.title),
      containsAll(<String>['Attributes', 'Custom Properties']),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_point_cloud_data.png'),
    );
  });

  testWidgets('Volume Data follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final outlinerScroll = find.descendant(
      of: find.byType(BlenderOutliner<String>),
      matching: find.byType(Scrollable),
    );
    await tester.drag(outlinerScroll.last, const Offset(0, -260));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Volume').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Data'));
    await tester.pumpAndSettle();

    expect(find.text('Volume Data'), findsOneWidget);
    expect(find.text('OpenVDB File'), findsOneWidget);

    final volumeEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      volumeEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'OpenVDB File',
        'Grids',
        'Render',
        'Viewport Display',
        'Animation',
        'Custom Properties',
      ]),
    );
    final viewport = volumeEditor.groups.firstWhere(
      (group) => group.title == 'Viewport Display',
    );
    expect(viewport.children.map((group) => group.title), contains('Slicing'));

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_volume_data.png'),
    );
  });

  testWidgets('Armature Data follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 820);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final outlinerScroll = find.descendant(
      of: find.byType(BlenderOutliner<String>),
      matching: find.byType(Scrollable),
    );
    expect(outlinerScroll, findsNWidgets(3));
    await tester.drag(outlinerScroll.last, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Armature').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Data'));
    await tester.pumpAndSettle();

    expect(find.text('Armature Data'), findsOneWidget);
    expect(find.text('Pose'), findsOneWidget);
    expect(find.text('Bone Collections'), findsOneWidget);

    final armatureEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      armatureEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Pose',
        'Viewport Display',
        'Bone Collections',
        'Inverse Kinematics',
        'Motion Paths',
        'Selection Sets',
        'Animation',
        'Custom Properties',
      ]),
    );
    final motionPaths = armatureEditor.groups.firstWhere(
      (group) => group.title == 'Motion Paths',
    );
    expect(
      motionPaths.children.map((group) => group.title),
      contains('Display'),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_armature_data.png'),
    );
  });

  testWidgets('Bone Properties follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 820);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final outlinerScroll = find.descendant(
      of: find.byType(BlenderOutliner<String>),
      matching: find.byType(Scrollable),
    );
    await tester.drag(outlinerScroll.last, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Armature').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Data'));
    await tester.pumpAndSettle();
    final dataField = tester.widget<BlenderDataBlockField<String>>(
      find.byKey(const ValueKey<String>('active-data-field')),
    );
    dataField.onChanged?.call('Bone');
    await tester.pumpAndSettle();

    expect(find.text('Bone Properties'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BlenderPropertiesEditor),
        matching: find.text('Transform'),
      ),
      findsOneWidget,
    );

    final boneEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      boneEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Transform',
        'Bendy Bones',
        'Relations',
        'Viewport Display',
        'Inverse Kinematics',
        'Deform',
        'Custom Properties',
      ]),
    );
    final relations = boneEditor.groups.firstWhere(
      (group) => group.title == 'Relations',
    );
    expect(
      relations.children.map((group) => group.title),
      contains('Bone Collections'),
    );
    final display = boneEditor.groups.firstWhere(
      (group) => group.title == 'Viewport Display',
    );
    expect(
      display.children.map((group) => group.title),
      contains('Custom Shape'),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_bone_properties.png'),
    );
  });

  testWidgets('ShaderFX Properties follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.bySemanticsLabel('Effects'));
    await tester.tap(find.bySemanticsLabel('Effects'));
    await tester.pumpAndSettle();

    expect(find.text('Effects'), findsWidgets);
    expect(find.text('Add Effect'), findsOneWidget);
    expect(find.text('Drop Shadow'), findsOneWidget);
    expect(find.text('Colorize'), findsOneWidget);

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_shaderfx_properties.png'),
    );
  });

  testWidgets('View Layer Properties follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 820);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('View Layer'));
    await tester.pumpAndSettle();

    expect(find.text('View Layer'), findsWidgets);
    expect(find.text('Passes'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('active-view-layer-field')),
      findsOneWidget,
    );

    final viewLayerEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      viewLayerEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'View Layer',
        'Passes',
        'Filter',
        'Override',
        'Freestyle',
        'Custom Properties',
      ]),
    );
    final passes = viewLayerEditor.groups.firstWhere(
      (group) => group.title == 'Passes',
    );
    expect(
      passes.children.map((group) => group.title),
      containsAll(<String>[
        'Data',
        'Light',
        'Shader AOV',
        'Cryptomatte',
        'Light Groups',
      ]),
    );
    final freestyle = viewLayerEditor.groups.firstWhere(
      (group) => group.title == 'Freestyle',
    );
    expect(
      freestyle.children.map((group) => group.title),
      containsAll(<String>['Edge Detection', 'Style Modules']),
    );
    expect(
      viewLayerEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Freestyle Line Set',
        'Freestyle Strokes',
        'Freestyle Color',
        'Freestyle Alpha',
        'Freestyle Thickness',
        'Freestyle Geometry',
        'Freestyle Texture',
        'Freestyle Animation',
      ]),
    );
    final freestyleAlpha = viewLayerEditor.groups.firstWhere(
      (group) => group.title == 'Freestyle Alpha',
    );
    expect(
      freestyleAlpha.properties.map((property) => property.label),
      contains('Base Transparency'),
    );
    expect(freestyleAlpha.content, isNotNull);
    final freestyleAnimation = viewLayerEditor.groups.firstWhere(
      (group) => group.title == 'Freestyle Animation',
    );
    expect(
      freestyleAnimation.properties.map((property) => property.label),
      containsAll(<String>['Action', 'Slot']),
    );

    expect(
      freestyle.properties.map((property) => property.label),
      containsAll(<String>['Control Mode', 'View Map Cache', 'As Render Pass']),
    );
    final edgeDetection = freestyle.children.firstWhere(
      (group) => group.title == 'Edge Detection',
    );
    expect(
      edgeDetection.properties.map((property) => property.label),
      containsAll(<String>[
        'Crease Angle',
        'Material Boundaries',
        'Ridges and Valleys',
        'Suggestive Contours',
        'Sphere Radius',
        'Kr Derivative Epsilon',
      ]),
    );
    final styleModules = freestyle.children.firstWhere(
      (group) => group.title == 'Style Modules',
    );
    expect(styleModules.content, isNotNull);
    final lineSet = viewLayerEditor.groups.firstWhere(
      (group) => group.title == 'Freestyle Line Set',
    );
    expect(
      lineSet.properties.map((property) => property.label),
      containsAll(<String>['Select by Image Border', 'Line Style']),
    );
    final strokes = viewLayerEditor.groups.firstWhere(
      (group) => group.title == 'Freestyle Strokes',
    );
    expect(
      <String>[
        ...strokes.properties.map((property) => property.label),
        ...strokes.children
            .expand((group) => group.properties)
            .map((property) => property.label),
      ],
      containsAll(<String>[
        'Caps',
        'Use Chaining',
        'Use Sorting',
        'Use Dashed Line',
      ]),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_view_layer_properties.png'),
    );
  });

  testWidgets('Collection Properties follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 820);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
    await tapPropertyTab(tester, 'collection');

    expect(find.text('Collection'), findsWidgets);
    expect(find.text('Visibility'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('active-collection-field')),
      findsOneWidget,
    );

    final collectionEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      collectionEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Visibility',
        'Importer',
        'Exporters',
        'Instancing',
        'Line Art',
        'Custom Properties',
      ]),
    );
    final visibility = collectionEditor.groups.firstWhere(
      (group) => group.title == 'Visibility',
    );
    expect(
      visibility.children.map((group) => group.title),
      contains('View Layer'),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_collection_properties.png'),
    );
  });

  testWidgets('Texture Properties follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 820);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
    await tapPropertyTab(tester, 'texture');

    expect(find.text('Texture'), findsWidgets);
    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Texture User'), findsOneWidget);
    expect(find.text('Base Color'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('active-texture-field')),
      findsOneWidget,
    );

    final textureEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      textureEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Preview',
        'Texture',
        'Node',
        'Clouds',
        'Mapping',
        'Influence',
        'Colors',
        'Animation',
        'Custom Properties',
      ]),
    );
    final colors = textureEditor.groups.firstWhere(
      (group) => group.title == 'Colors',
    );
    expect(colors.children.map((group) => group.title), contains('Color Ramp'));

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_texture_properties.png'),
    );
  });

  testWidgets('Constraint Properties follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 820);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
    await tapPropertyTab(tester, 'constraint');

    expect(find.text('Object Constraints'), findsOneWidget);
    expect(find.text('Copy Location'), findsOneWidget);
    expect(find.text('Child Of'), findsOneWidget);
    expect(find.text('Follow Path'), findsOneWidget);
    expect(find.text('Limit Rotation'), findsOneWidget);
    expect(find.text('Armature'), findsWidgets);

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_constraint_properties.png'),
    );
  });

  testWidgets('Physics Properties follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Physics'));
    await tester.pumpAndSettle();

    expect(find.text('Physics'), findsWidgets);
    expect(find.text('Add Physics'), findsOneWidget);
    expect(find.text('Cloth'), findsWidgets);

    final physicsEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      physicsEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Add Physics',
        'Cloth',
        'Soft Body',
        'Fluid',
        'Dynamic Paint',
        'Force Fields',
        'Rigid Body',
        'Rigid Body Constraint',
        'Particle System',
        'Simulation Nodes',
      ]),
    );
    final cloth = physicsEditor.groups.firstWhere(
      (group) => group.title == 'Cloth',
    );
    expect(
      cloth.children.map((group) => group.title),
      containsAll(<String>[
        'Physical Properties',
        'Cache',
        'Shape',
        'Collisions',
        'Property Weights',
        'Field Weights',
      ]),
    );
    final physicalProperties = cloth.children.firstWhere(
      (group) => group.title == 'Physical Properties',
    );
    expect(
      physicalProperties.children.map((group) => group.title),
      containsAll(<String>[
        'Stiffness',
        'Damping',
        'Internal Springs',
        'Pressure',
      ]),
    );
    final particleSystem = physicsEditor.groups.firstWhere(
      (group) => group.title == 'Particle System',
    );
    expect(
      particleSystem.children.map((group) => group.title),
      containsAll(<String>[
        'Emission',
        'Cache',
        'Velocity',
        'Rotation',
        'Physics',
        'Render',
        'Viewport Display',
        'Children',
        'Field Weights',
        'Force Field Settings',
      ]),
    );
    final softBody = physicsEditor.groups.firstWhere(
      (group) => group.title == 'Soft Body',
    );
    expect(
      softBody.children.map((group) => group.title),
      containsAll(<String>[
        'Object',
        'Simulation',
        'Cache',
        'Goal',
        'Edges',
        'Self Collision',
        'Solver',
        'Field Weights',
      ]),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_physics_properties.png'),
    );
  });

  testWidgets('Strip Properties follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
    await tapPropertyTab(tester, 'strip');

    expect(find.text('Strip'), findsWidgets);
    expect(find.text('Effect Strip'), findsOneWidget);

    final stripEditor = tester.widget<BlenderPropertiesEditor>(
      find.descendant(
        of: find.byType(BlenderStripProperties),
        matching: find.byType(BlenderPropertiesEditor),
      ),
    );
    expect(
      stripEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Crop',
        'Effect Strip',
        'Source',
        'Movie Clip',
        'Scene',
        'Sound',
        'Mask',
        'Time',
        'Sound Adjustment',
        'Compositing',
        'Transform',
        'Video',
        'Color',
        'Custom Properties',
        'Modifiers',
      ]),
    );
    final effect = stripEditor.groups.firstWhere(
      (group) => group.title == 'Effect Strip',
    );
    expect(
      effect.children.map((group) => group.title),
      containsAll(<String>['Layout', 'Style']),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_strip_properties.png'),
    );
  });

  testWidgets('Empty Data follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final outlinerScroll = find.descendant(
      of: find.byType(BlenderOutliner<String>),
      matching: find.byType(Scrollable),
    );
    await tester.drag(outlinerScroll.last, const Offset(0, -360));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Empty').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Data'));
    await tester.pumpAndSettle();

    expect(find.text('Empty Data'), findsOneWidget);
    expect(find.text('Empty'), findsWidgets);

    final emptyEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      emptyEditor.groups.map((group) => group.title),
      containsAll(<String>['Empty', 'Image']),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_empty_data.png'),
    );
  });

  testWidgets('Metaball Data follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final outlinerScroll = find.descendant(
      of: find.byType(BlenderOutliner<String>),
      matching: find.byType(Scrollable),
    );
    await tester.drag(outlinerScroll.last, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Metaball').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Data'));
    await tester.pumpAndSettle();

    expect(find.text('Metaball Data'), findsOneWidget);
    expect(find.text('Metaball'), findsWidgets);

    final metaballEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      metaballEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Metaball',
        'Texture Space',
        'Active Element',
        'Animation',
        'Custom Properties',
      ]),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_metaball_data.png'),
    );
  });

  testWidgets('Light Probe Data follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 820);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final outlinerScroll = find.descendant(
      of: find.byType(BlenderOutliner<String>),
      matching: find.byType(Scrollable),
    );
    await tester.drag(outlinerScroll.last, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Light Probe').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Data'));
    await tester.pumpAndSettle();

    expect(find.text('Light Probe Data'), findsOneWidget);
    expect(find.text('Probe'), findsWidgets);
    expect(find.text('Visibility'), findsOneWidget);

    final lightProbeEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      lightProbeEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Probe',
        'Capture',
        'Bake',
        'Custom Parallax',
        'Viewport Display',
        'Animation',
        'Custom Properties',
      ]),
    );
    final probe = lightProbeEditor.groups.firstWhere(
      (group) => group.title == 'Probe',
    );
    expect(probe.children.map((group) => group.title), contains('Visibility'));
    final bake = lightProbeEditor.groups.firstWhere(
      (group) => group.title == 'Bake',
    );
    expect(
      bake.children.map((group) => group.title),
      containsAll(<String>['Resolution', 'Capture']),
    );
    final bakeCapture = bake.children.firstWhere(
      (group) => group.title == 'Capture',
    );
    expect(
      bakeCapture.children.map((group) => group.title),
      containsAll(<String>['Offset', 'Clamping']),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_light_probe_data.png'),
    );
  });

  testWidgets('Grease Pencil Data follows Blender source panel anatomy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 820);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final outlinerScroll = find.descendant(
      of: find.byType(BlenderOutliner<String>),
      matching: find.byType(Scrollable),
    );
    await tester.drag(outlinerScroll.last, const Offset(0, -340));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grease Pencil').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Data'));
    await tester.pumpAndSettle();

    expect(find.text('Grease Pencil Data'), findsOneWidget);
    expect(find.text('Layers'), findsOneWidget);

    final greasePencilEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      greasePencilEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Layers',
        'Onion Skinning',
        'Settings',
        'Attributes',
        'Animation',
        'Custom Properties',
      ]),
    );
    final layers = greasePencilEditor.groups.firstWhere(
      (group) => group.title == 'Layers',
    );
    expect(
      layers.children.map((group) => group.title),
      containsAll(<String>[
        'Masks',
        'Transform',
        'Adjustments',
        'Relations',
        'Display',
      ]),
    );
    final onionSkinning = greasePencilEditor.groups.firstWhere(
      (group) => group.title == 'Onion Skinning',
    );
    expect(
      onionSkinning.children.map((group) => group.title),
      containsAll(<String>['Custom Colors', 'Display']),
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_grease_pencil_data.png'),
    );
  });

  testWidgets('bottom animation editor exposes Timeline and Action details', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final timeline = tester.widget<BlenderTimeline>(
      find.byType(BlenderTimeline),
    );
    expect(
      timeline.model.tracks.map((track) => track.label),
      containsAll(<String>['Cube', 'Camera', 'Light']),
    );
    expect(
      find.byKey(const ValueKey<String>('animation-view-menu')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('animation-marker-menu')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('animation-playback-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('animation-autokey-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('animation-time-jump-controls')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('animation-playhead-snapping-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('animation-filters-button')),
      findsNothing,
    );
    final timelineViewMenu = tester.widget<BlenderMenuButton<String>>(
      find.byKey(const ValueKey<String>('animation-view-menu')),
    );
    expect(
      timelineViewMenu.items.map((item) => item.label),
      containsAll(<String>['Frame Scene Range', 'Show Locked Time', 'Cache']),
    );

    await tester.tap(
      find.ancestor(
        of: find.text('Timeline'),
        matching: find.byType(BlenderButton),
      ),
      warnIfMissed: false,
    );
    await tester.pump();
    await tester.tap(find.text('Action'));
    await tester.pumpAndSettle();

    expect(find.byType(BlenderDopeSheetEditor), findsOneWidget);
    expect(find.byType(BlenderDopeSheetSidebar), findsOneWidget);
    expect(find.text('Active Action'), findsOneWidget);
    expect(find.text('Use Frame Range'), findsOneWidget);
    expect(find.text('Slot'), findsOneWidget);
    expect(find.text('Select'), findsWidgets);
    expect(find.text('Channel'), findsOneWidget);
    expect(find.text('Key'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('animation-playback-button')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('animation-action-menu')),
      findsOneWidget,
    );
    final actionViewMenu = tester.widget<BlenderMenuButton<String>>(
      find.byKey(const ValueKey<String>('animation-view-menu')),
    );
    expect(
      actionViewMenu.items.map((item) => item.label),
      containsAll(<String>[
        'View Selected',
        'Multi-Word Match Search',
        'Toggle Graph Editor',
      ]),
    );
    expect(
      find.byKey(const ValueKey<String>('animation-filters-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('animation-snapping-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('animation-overlay-button')),
      findsOneWidget,
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('animation-filters-button')),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('animation-filters-button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Only Selected'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('animation-snapping-button')),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('animation-snapping-button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Snapping'), findsOneWidget);
    expect(find.text('Snap To'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('CubeAction'), findsWidgets);
    final action = tester.widget<BlenderDopeSheetEditor>(
      find.byType(BlenderDopeSheetEditor),
    );
    expect(
      action.model.tracks.map((track) => track.label),
      containsAll(<String>[
        'CubeAction Summary',
        'X Location',
        'Y Location',
        'Z Euler Rotation',
      ]),
    );
    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_action_editor.png'),
    );
  });

  testWidgets('main animation headers follow Blender mode families', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final selector = find.byType(BlenderEditorTypeSelector).first;
    await tester.tapAt(tester.getRect(selector).topLeft + const Offset(12, 11));
    await tester.pump();
    await tester.tap(find.text('Dope Sheet'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('main-animation-action-selector')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('main-animation-filters-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('main-animation-snapping-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('main-animation-proportional-button')),
      findsOneWidget,
    );
    for (final label in <String>[
      'View',
      'Select',
      'Marker',
      'Channel',
      'Key',
    ]) {
      expect(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(BlenderMenuButton<String>),
        ),
        findsWidgets,
      );
    }
    final channelMenu = tester.widget<BlenderMenuButton<String>>(
      find
          .ancestor(
            of: find.text('Channel'),
            matching: find.byType(BlenderMenuButton<String>),
          )
          .first,
    );
    expect(
      channelMenu.items.map((item) => item.label),
      containsAll(<String>[
        'Delete Channels',
        'Group Channels',
        'Bake Channels',
      ]),
    );

    await tester.tapAt(const Offset(700, 50));
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getRect(selector).topLeft + const Offset(12, 11));
    await tester.pump();
    await tester.tap(find.text('Timeline').last);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('main-animation-playback-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('main-animation-autokey-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('main-animation-playhead-snap')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('main-animation-time-jump-controls')),
      findsOneWidget,
    );
    expect(
      find.ancestor(
        of: find.text('Select'),
        matching: find.byType(BlenderMenuButton<String>),
      ),
      findsNothing,
    );

    await expectLater(
      find.byType(ShowcaseApp),
      matchesGoldenFile('goldens/showcase_main_animation_headers.png'),
    );
  });

  testWidgets('Timeline header popovers expose source time settings', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final timeJumpControls = find.byKey(
      const ValueKey<String>('animation-time-jump-controls'),
    );
    await tester.ensureVisible(timeJumpControls);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: timeJumpControls,
        matching: find.byType(BlenderPopover),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Time Jump'), findsOneWidget);
    expect(find.text('Jump Unit'), findsOneWidget);
    expect(find.text('Delta'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    final playheadSnap = find.byKey(
      const ValueKey<String>('animation-playhead-snapping-button'),
    );
    await tester.ensureVisible(playheadSnap);
    await tester.pumpAndSettle();
    await tester.tap(playheadSnap);
    await tester.pumpAndSettle();
    expect(find.text('Playhead'), findsOneWidget);
    expect(find.text('Frame Step'), findsOneWidget);
  });

  testWidgets('viewport responds to orbit and zoom gestures', (tester) async {
    await tester.pumpWidget(
      const BlenderApp(
        home: SizedBox(
          width: 480,
          height: 360,
          child: ShowcaseViewport(
            selectedObject: 'Cube',
            showGrid: true,
            wireframe: false,
          ),
        ),
      ),
    );
    final scenePaint = find
        .descendant(
          of: find.byType(ShowcaseViewport),
          matching: find.byType(CustomPaint),
        )
        .first;
    final before = tester.widget<CustomPaint>(scenePaint).painter;

    await tester.drag(find.byType(ShowcaseViewport), const Offset(50, -30));
    await tester.pump(const Duration(milliseconds: 100));

    final after = tester.widget<CustomPaint>(scenePaint).painter;
    expect(after, isNot(same(before)));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Components workbench is searchable and service-backed', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const BlenderApp(home: DemoWorkbench()));
    await tester.pumpAndSettle();

    expect(find.text('Feature map'), findsOneWidget);
    expect(find.text('App Services'), findsOneWidget);
    await tester.tap(find.text('App Services'));
    await tester.pumpAndSettle();

    expect(find.text('Observable state'), findsOneWidget);
    expect(find.text('Counter 0'), findsOneWidget);
    await tester.tap(find.text('Increment command'));
    await tester.pump();
    expect(find.text('Counter 1'), findsOneWidget);
    await tester.tap(find.text('Undo (1)'));
    await tester.pump();
    expect(find.text('Counter 0'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey<String>('demo-search')),
      'timeline',
    );
    await tester.pumpAndSettle();
    expect(find.text('Editors'), findsWidgets);
    expect(find.text('Timeline'), findsWidgets);
    expect(find.text('Controls'), findsNothing);
  });

  testWidgets('Components workbench matches its visual baseline', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const BlenderApp(home: DemoWorkbench()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(DemoWorkbench),
      matchesGoldenFile('goldens/components_workbench.png'),
    );
  });

  testWidgets('showcase exposes Components as a first-class workspace', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final components = find.widgetWithText(BlenderButton, 'Components');
    expect(components, findsOneWidget);
    final workspaceTabs = tester.widget<BlenderTabBar>(
      find.ancestor(of: components, matching: find.byType(BlenderTabBar)),
    );
    expect(workspaceTabs.scrollable, isFalse);
    expect(
      find.ancestor(of: components, matching: find.byType(Scrollable)),
      findsOneWidget,
    );
    workspaceTabs.onChanged(10);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<BlenderTabBar>(
            find.ancestor(
              of: find.widgetWithText(BlenderButton, 'Components'),
              matching: find.byType(BlenderTabBar),
            ),
          )
          .selectedIndex,
      10,
    );
    expect(
      tester.widget<BlenderEditorShell>(find.byType(BlenderEditorShell)).main,
      isA<DemoWorkbench>(),
    );

    expect(find.byType(DemoWorkbench), findsOneWidget);
    expect(find.text('Feature map'), findsOneWidget);
  });
}
