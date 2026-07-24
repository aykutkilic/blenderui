part of '../widget_test.dart';

void registerScenePropertiesFollowsBlenderPanelAnatomyTests() {
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
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
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
  });
}
