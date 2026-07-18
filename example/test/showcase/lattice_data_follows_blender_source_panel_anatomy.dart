part of '../widget_test.dart';

void registerLatticeDataFollowsBlenderSourcePanelAnatomyTests() {
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
  });
}
