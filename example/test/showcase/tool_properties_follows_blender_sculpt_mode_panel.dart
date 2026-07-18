part of '../widget_test.dart';

void registerToolPropertiesFollowsBlenderSculptModePanelTests() {
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
  });
}
