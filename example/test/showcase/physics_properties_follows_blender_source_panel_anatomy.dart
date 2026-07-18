part of '../widget_test.dart';

void registerPhysicsPropertiesFollowsBlenderSourcePanelAnatomyTests() {
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
  });
}
