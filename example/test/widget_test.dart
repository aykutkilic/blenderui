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

    final outputTab = find.bySemanticsLabel('Output');
    expect(outputTab, findsOneWidget);
    await tester.tap(outputTab);
    await tester.pumpAndSettle();

    expect(find.text('Output'), findsOneWidget);
    expect(find.text('Format'), findsOneWidget);
    expect(find.text('Frame Range'), findsOneWidget);
    expect(find.text('Stereoscopy'), findsOneWidget);
    expect(find.bySemanticsLabel('Format presets'), findsOneWidget);

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
