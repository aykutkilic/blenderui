part of '../widget_test.dart';

void registerNodeEditorExposesSourceSidebarFamiliesTests() {
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
  });

  testWidgets('Geometry Node Editor composes the detailed reusable graph', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 980);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final selector = find.byType(BlenderEditorTypeSelector).first;
    await tester.tapAt(tester.getRect(selector).topLeft + const Offset(12, 11));
    await tester.pump();
    await tester.tap(find.text('Geometry Node Editor'));
    await tester.pumpAndSettle();

    expect(find.byType(BlenderNodeEditorHeader), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('node-editor-tool-shelf')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('node-editor-grid')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('node-editor-links')),
      findsOneWidget,
    );
    expect(find.text('Scatter Pebbles on Geometry'), findsOneWidget);
    expect(find.text('Group Input'), findsOneWidget);
    expect(find.text('Distribute Points on Faces'), findsWidgets);
    expect(find.text('Instance on Points'), findsOneWidget);

    final editor = tester.widget<BlenderNodeEditor>(
      find.byType(BlenderNodeEditor),
    );
    expect(editor.model.nodes, hasLength(8));
    expect(editor.model.links, hasLength(11));
    expect(editor.model.validate(), isEmpty);
    expect(
      editor.model.nodes.map((node) => node.kind),
      containsAll(<BlenderGraphNodeKind>[
        BlenderGraphNodeKind.frame,
        BlenderGraphNodeKind.reroute,
      ]),
    );

    final addMenu = tester.widget<BlenderMenuButton<String>>(
      find
          .ancestor(
            of: find.text('Add').first,
            matching: find.byType(BlenderMenuButton<String>),
          )
          .first,
    );
    expect(
      addMenu.items.map((item) => item.label),
      containsAll(<String>[
        'Attribute',
        'Geometry',
        'Curve',
        'Instances',
        'Mesh',
        'Simulation',
        'Utilities',
      ]),
    );
    final curve = addMenu.items.firstWhere((item) => item.label == 'Curve');
    expect(
      curve.submenu!.map((item) => item.label),
      containsAll(<String>['Read', 'Sample', 'Write', 'Operations']),
    );

    Finder socketHandle(String key) => find
        .descendant(
          of: find.byKey(ValueKey<String>(key)),
          matching: find.byType(GestureDetector),
        )
        .first;
    final source = socketHandle('node-socket-group-input-geometry-true');
    final target = socketHandle('node-socket-instance-points-false');
    final gesture = await tester.startGesture(tester.getCenter(source));
    await gesture.moveTo(
      tester.getCenter(target),
      timeStamp: const Duration(milliseconds: 100),
    );
    await tester.pump();
    expect(
      find.byKey(const ValueKey<String>('node-editor-link-preview')),
      findsOneWidget,
    );
    await gesture.up();
    await tester.pumpAndSettle();
    final connectedEditor = tester.widget<BlenderNodeEditor>(
      find.byType(BlenderNodeEditor),
    );
    expect(
      connectedEditor.model.links,
      contains(
        isA<BlenderGraphLink>()
            .having((link) => link.from, 'from', 'group-input')
            .having((link) => link.fromSocket, 'from socket', 'geometry')
            .having((link) => link.to, 'to', 'instance')
            .having((link) => link.toSocket, 'to socket', 'points'),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('node-overlay-button')));
    await tester.pumpAndSettle();
    expect(find.text('Named Attributes'), findsWidgets);
    expect(find.text('Timings'), findsOneWidget);
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
    expect(find.byType(BlenderImageEditorToolShelf), findsOneWidget);
    expect(find.byType(BlenderView3dToolShelf), findsNothing);
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
      findsNothing,
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
          .byWidgetPredicate(
            (widget) =>
                widget is BlenderMenuButton<String> && widget.label == 'View',
          )
          .first,
    );
    expect(
      imageViewMenu.items.map((item) => item.label),
      containsAll(<String>['Use Realtime Update', 'Show Metadata']),
    );
    expect(
      imageViewMenu.items.map((item) => item.label),
      isNot(contains('Render Border')),
    );
    final zoomMenu = imageViewMenu.items.firstWhere(
      (item) => item.label == 'Zoom',
    );
    expect(
      zoomMenu.submenu?.map((item) => item.label),
      containsAll(<String>['100% (1:1)', 'Zoom to Fit', 'Zoom Region...']),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('image-display-source')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paint').last);
    await tester.pumpAndSettle();
    expect(find.byType(BlenderAssetShelf), findsOneWidget);
    expect(find.text('Brush Assets'), findsOneWidget);

    await tester.tapAt(tester.getRect(selector).topLeft + const Offset(12, 11));
    await tester.pump();
    await tester.tap(find.text('UV Editor'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('image-uv-sync-button')),
      findsOneWidget,
    );
    expect(find.byType(BlenderImageEditorToolShelf), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('image-proportional-button')),
      findsOneWidget,
    );
    final uvMenu = tester.widget<BlenderMenuButton<String>>(
      find
          .byWidgetPredicate(
            (widget) =>
                widget is BlenderMenuButton<String> && widget.label == 'UV',
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
        'Reset',
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
    await tapPropertyTab(tester, 'tool');

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
}
