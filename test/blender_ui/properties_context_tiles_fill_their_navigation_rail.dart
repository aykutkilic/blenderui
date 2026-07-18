part of '../blender_ui_test.dart';

void registerPropertiesContextTilesFillTheirNavigationRailTests() {
  testWidgets('Properties context tiles fill their navigation rail', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 120,
          height: 180,
          child: BlenderPropertyTabs(
            tabs: <BlenderPropertyTab>[
              BlenderPropertyTab(
                id: 'tool',
                label: 'Tool',
                glyph: BlenderGlyph.tool,
              ),
              BlenderPropertyTab(
                id: 'output',
                label: 'Output',
                glyph: BlenderGlyph.output,
              ),
            ],
            selectedIndex: 0,
            onChanged: _ignoreInt,
            visibleTabIds: const <String>{'tool', 'output'},
            onVisibilityChanged: _ignoreStringSet,
          ),
        ),
      ),
    );

    final tabs = tester.widget<BlenderPropertyTabs>(
      find.byType(BlenderPropertyTabs),
    );
    expect(tabs.tileSize, tabs.width);
    final disclosure = tester.widget<BlenderIcon>(
      find.byWidgetPredicate(
        (widget) =>
            widget is BlenderIcon &&
            widget.glyph == BlenderGlyph.panelDisclosureDown,
      ),
    );
    expect(disclosure.size, 9);
    expect(
      tester.getTopLeft(find.byType(BlenderPropertyTabVisibilityMenu)).dy,
      greaterThanOrEqualTo(
        tester
            .getBottomLeft(
              find.byKey(const ValueKey<String>('property-tab-output')),
            )
            .dy,
      ),
    );
  });

  testWidgets('Properties tab rail replaces its scrollbar with edge fades', (
    tester,
  ) async {
    final tabs = <BlenderPropertyTab>[
      for (var index = 0; index < 12; index++)
        BlenderPropertyTab(
          id: 'tab-$index',
          label: 'Tab $index',
          glyph: BlenderGlyph.properties,
        ),
    ];
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 36,
          height: 100,
          child: BlenderPropertyTabs(
            tabs: tabs,
            selectedIndex: 0,
            onChanged: _ignoreInt,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(RawScrollbar), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('property-tabs-scroll')),
      findsOneWidget,
    );
  });

  testWidgets('editor type selector uses Blender menu trigger states', (
    tester,
  ) async {
    await tester.pumpWidget(
      BlenderApp(
        home: _harness(
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 40,
              child: BlenderEditorTypeSelector(
                value: BlenderEditorType.properties,
                compact: true,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final buttonFinder = find.descendant(
      of: find.byType(BlenderEditorTypeSelector),
      matching: find.byType(BlenderButton),
    );
    var button = tester.widget<BlenderButton>(buttonFinder);
    expect(button.variant, BlenderButtonVariant.menuTrigger);
    expect(button.selected, isFalse);
    expect(
      (button.trailing! as BlenderIcon).glyph,
      BlenderGlyph.panelDisclosureDown,
    );
    expect((button.trailing! as BlenderIcon).size, 9);

    await tester.tapAt(tester.getCenter(buttonFinder));
    await tester.pump();

    button = tester.widget<BlenderButton>(buttonFinder);
    expect(button.selected, isTrue);
    expect(find.text('General'), findsOneWidget);
  });

  testWidgets('Preferences stays open when selected from an application menu', (
    tester,
  ) async {
    late BuildContext appContext;
    await tester.pumpWidget(
      BlenderApp(
        home: Builder(
          builder: (context) {
            appContext = context;
            return BlenderMenuButton<String>(
              label: 'Edit',
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem(value: 'preferences', label: 'Preferences…'),
              ],
              onSelected: (_) {
                BlenderPreferencesService(
                  configuration: const BlenderPreferencesConfiguration(
                    categories: <String>['General'],
                    sections: <BlenderPreferenceSection>[],
                  ),
                ).show(appContext);
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Edit'), warnIfMissed: false);
    await tester.pump();
    await tester.tap(find.text('Preferences…'));
    await tester.pumpAndSettle();

    expect(find.byType(BlenderPreferencesWindow), findsOneWidget);
  });

  testWidgets('Outliner filter exposes restriction controls', (tester) async {
    await tester.pumpWidget(
      const BlenderApp(
        home: BlenderTheme(
          child: SizedBox(
            width: 360,
            height: 300,
            child: BlenderOutliner<String>(
              roots: <BlenderTreeNode<String>>[
                BlenderTreeNode<String>(id: 'scene', label: 'Scene Collection'),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is BlenderIconButton && widget.glyph == BlenderGlyph.filter,
      ),
    );
    await tester.pump();

    expect(find.text('Restriction Toggles'), findsOneWidget);
    expect(find.text('Sort Alphabetically'), findsOneWidget);
    expect(find.text('Object Contents'), findsOneWidget);
  });

  testWidgets('Outliner display-mode dropdown reports the selected view', (
    tester,
  ) async {
    var mode = BlenderOutlinerDisplayMode.viewLayer;
    await tester.pumpWidget(
      BlenderApp(
        home: BlenderTheme(
          child: SizedBox(
            width: 360,
            height: 300,
            child: StatefulBuilder(
              builder: (context, setState) => BlenderOutliner<String>(
                displayMode: mode,
                onDisplayModeChanged: (value) => setState(() => mode = value),
                roots: const <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'scene',
                    label: 'Scene Collection',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(BlenderDropdown<BlenderOutlinerDisplayMode>));
    await tester.pump();
    expect(find.text('Video Sequencer'), findsOneWidget);
    await tester.tap(find.text('Blender File'));
    await tester.pump();

    expect(mode, BlenderOutlinerDisplayMode.blenderFile);
  });

  testWidgets('splitter exposes a draggable directional divider', (
    tester,
  ) async {
    var fraction = .5;
    await tester.pumpWidget(
      BlenderApp(
        home: BlenderTheme(
          child: SizedBox(
            width: 400,
            height: 180,
            child: BlenderSplitter(
              initialFraction: fraction,
              onFractionChanged: (value) => fraction = value,
              first: const SizedBox.expand(),
              second: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );

    final rect = tester.getRect(find.bySemanticsLabel('Resize editor width'));
    final dragSurface = find.byKey(
      const ValueKey<String>('blender-splitter-drag-surface'),
    );
    expect(tester.widget<MouseRegion>(dragSurface).cursor, MouseCursor.defer);

    final gesture = await tester.startGesture(rect.center);
    await gesture.moveBy(const Offset(8, 0));
    await tester.pump();

    expect(
      tester.widget<MouseRegion>(dragSurface).cursor,
      SystemMouseCursors.resizeColumn,
    );

    // The divider has moved underneath the pointer, but the cursor remains
    // owned by the active splitter surface instead of flickering to default.
    await gesture.moveBy(const Offset(48, 0));
    await tester.pump();
    expect(
      tester.widget<MouseRegion>(dragSurface).cursor,
      SystemMouseCursors.resizeColumn,
    );
    await gesture.up();
    await tester.pump();

    expect(fraction, greaterThan(.5));
  });

  testWidgets('editor shell exposes a draggable right-area divider', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 400,
          height: 180,
          child: BlenderEditorShell(
            main: SizedBox.expand(),
            right: SizedBox.expand(key: Key('right-editor-area')),
            rightWidth: 100,
          ),
        ),
      ),
    );

    final divider = find.bySemanticsLabel('Resize editor width');
    final before = tester.getRect(find.byKey(const Key('right-editor-area')));
    await tester.dragFrom(tester.getRect(divider).center, const Offset(-40, 0));
    await tester.pump();
    final after = tester.getRect(find.byKey(const Key('right-editor-area')));

    expect(after.width, greaterThan(before.width));
  });

  testWidgets('number field drags with Blender-style sensitivity', (
    tester,
  ) async {
    var value = 1.0;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 180,
          child: StatefulBuilder(
            builder: (context, setState) => BlenderNumberField(
              value: value,
              min: 0,
              max: 100,
              decimalDigits: 2,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(BlenderNumberField), const Offset(40, 0));
    await tester.pump();
    expect(value, greaterThan(1));
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('number field supports precise text-edit transition', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 180,
          child: BlenderNumberField(
            value: 1,
            decimalDigits: 2,
            onChanged: _ignoreDouble,
          ),
        ),
      ),
    );
    final fieldGesture = find.byWidgetPredicate(
      (widget) =>
          widget is GestureDetector && widget.onHorizontalDragStart != null,
    );
    tester.widget<GestureDetector>(fieldGesture.first).onTap!();
    await tester.pumpAndSettle();
    expect(find.byType(EditableText), findsOneWidget);
  });

  testWidgets('number slider surface has no extra outline', (tester) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 180,
          child: BlenderNumberField(
            value: 1920,
            decimalDigits: 0,
            onChanged: _ignoreDouble,
          ),
        ),
      ),
    );

    final surface = tester.widget<Container>(
      find.byKey(const ValueKey<String>('blender-number-field-surface')),
    );
    final decoration = surface.decoration! as BoxDecoration;
    expect(decoration.border, isNull);
    expect(surface.constraints?.minHeight, 20);
    expect(surface.constraints?.maxHeight, 20);
  });

  testWidgets('bounded number fields render a proportional range fill', (
    tester,
  ) async {
    final repaintKey = GlobalKey();
    await tester.pumpWidget(
      _harness(
        RepaintBoundary(
          key: repaintKey,
          child: const SizedBox(
            width: 180,
            child: BlenderNumberField(
              value: 36,
              min: 0,
              max: 100,
              decimalDigits: 0,
              suffix: '%',
              showSteppers: false,
              onChanged: _ignoreDouble,
            ),
          ),
        ),
      ),
    );

    final fill = tester.widget<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    );
    expect(fill.widthFactor, closeTo(.36, .001));
    final surfaceFinder = find.byKey(
      const ValueKey<String>('blender-number-field-surface'),
    );
    final surface = tester.widget<Container>(surfaceFinder);
    expect(surface.clipBehavior, Clip.antiAlias);
    expect(
      tester.getTopLeft(find.byType(FractionallySizedBox)).dx,
      tester.getTopLeft(surfaceFinder).dx,
    );
    final fillDecoration =
        tester
                .widget<DecoratedBox>(
                  find.descendant(
                    of: find.byType(FractionallySizedBox),
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .decoration
            as BoxDecoration;
    expect(fillDecoration.borderRadius, isNull);
    expect(tester.getSize(find.byType(FractionallySizedBox)).height, 20);
    expect(
      tester.getSize(find.byType(FractionallySizedBox)).width,
      closeTo(tester.getSize(surfaceFinder).width * .36, .001),
    );

    final boundary =
        repaintKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final leadingPixels = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final pixels = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      expect(pixels, isNotNull);
      final centerY = image.height ~/ 2;
      final result = <int>[];
      for (var x = 1; x <= 10; x += 1) {
        final offset = (centerY * image.width + x) * 4;
        final red = pixels!.getUint8(offset);
        final green = pixels.getUint8(offset + 1);
        final blue = pixels.getUint8(offset + 2);
        final alpha = pixels.getUint8(offset + 3);
        result.add((alpha << 24) | (red << 16) | (green << 8) | blue);
      }
      image.dispose();
      return result;
    });
    final selected = BlenderThemeData.dark.colors.buttonSelected.toARGB32();
    for (var x = 0; x < leadingPixels!.length; x += 1) {
      expect(
        leadingPixels[x],
        selected,
        reason: 'leading fill pixel x=${x + 1}',
      );
    }

    final pointer = await tester.createGesture();
    await pointer.moveTo(tester.getCenter(find.byType(BlenderNumberField)));
    await tester.pump();
    expect(find.byType(BlenderIcon), findsNothing);
    await pointer.removePointer();
  });

  testWidgets('factor fields retain their range fill while editing', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 180,
          child: BlenderNumberField(
            value: .596,
            min: 0,
            max: 1,
            decimalDigits: 3,
            showSteppers: false,
            onChanged: _ignoreDouble,
          ),
        ),
      ),
    );

    final fieldGesture = find.byWidgetPredicate(
      (widget) =>
          widget is GestureDetector && widget.onHorizontalDragStart != null,
    );
    tester.widget<GestureDetector>(fieldGesture.first).onTap!();
    await tester.pump();

    expect(find.byType(EditableText), findsOneWidget);
    final fills = find.byType(FractionallySizedBox);
    expect(fills, findsOneWidget);
    expect(
      tester.widget<FractionallySizedBox>(fills),
      isA<FractionallySizedBox>().having(
        (fill) => fill.widthFactor,
        'widthFactor',
        closeTo(.596, .001),
      ),
    );
  });

  testWidgets('collapsed panels retain Blender rounded surfaces', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 240,
          child: BlenderPanel(
            title: 'Format',
            collapsible: true,
            initiallyExpanded: false,
            child: SizedBox(height: 40),
          ),
        ),
      ),
    );

    expect(find.byType(ClipRRect), findsOneWidget);
    final surface = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect(surface.borderRadius, BorderRadius.circular(4));
    expect(find.byType(BlenderPanelHeader), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('blender-number-field-surface')),
      findsNothing,
    );
  });

  testWidgets('alert dialog uses centered Blender modal anatomy', (
    tester,
  ) async {
    var confirmed = false;
    await tester.pumpWidget(
      BlenderApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: BlenderButton(
              label: 'Delete',
              onPressed: () => showBlenderAlertDialog(
                context: tester.element(find.text('Delete')),
                title: 'Delete Object',
                message: 'This action cannot be undone.\nContinue?',
                confirmLabel: 'Delete',
                onConfirm: () => confirmed = true,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Object'), findsOneWidget);
    expect(find.text('This action cannot be undone.'), findsOneWidget);
    expect(find.text('Continue?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);
    expect(find.text('Delete Object'), findsNothing);
  });
}
