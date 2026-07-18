part of '../widget_test.dart';

void registerNormalOutlinerHeaderKeepsSourceDisplayControlsTests() {
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
  });
}
