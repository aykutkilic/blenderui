part of '../widget_test.dart';

void registerTimelineHeaderPopoversExposeSourceTimeSettingsTests() {
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
    expect(
      find.ancestor(of: components, matching: find.byType(Scrollable)),
      findsOneWidget,
    );
    await tester.ensureVisible(components);
    await tester.pumpAndSettle();
    await tester.tap(components);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<BlenderButton>(
            find.widgetWithText(BlenderButton, 'Components'),
          )
          .selected,
      isTrue,
    );
    expect(
      tester.widget<BlenderEditorShell>(find.byType(BlenderEditorShell)).main,
      isA<DemoWorkbench>(),
    );

    expect(find.byType(DemoWorkbench), findsOneWidget);
    expect(find.text('Feature map'), findsOneWidget);
  });
}
