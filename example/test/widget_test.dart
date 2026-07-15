import 'package:blender_ui_example/main.dart';
import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart'
    show CustomPaint, Offset, Size, SizedBox, ValueKey;
import 'package:flutter_test/flutter_test.dart';

import '../lib/showcase_viewport.dart';

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

    await tester.tap(find.bySemanticsLabel('Object'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('active-object-field')),
      findsOneWidget,
    );
    expect(find.text('Transform'), findsOneWidget);
    expect(find.text('Location X'), findsOneWidget);
    expect(find.text('Rotation X'), findsOneWidget);
    expect(find.text('Mode'), findsOneWidget);
    expect(find.text('Scale X'), findsOneWidget);
    expect(find.text('Delta Transform'), findsOneWidget);
    expect(find.text('Relations'), findsOneWidget);
    expect(find.text('Viewport Display'), findsOneWidget);
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
      ]),
    );

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
    expect(find.text('Select'), findsWidgets);
    expect(find.text('Channel'), findsOneWidget);
    expect(find.text('Key'), findsOneWidget);
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
}
