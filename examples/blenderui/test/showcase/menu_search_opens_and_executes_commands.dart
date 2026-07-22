part of '../widget_test.dart';

void registerMenuSearchOpensAndExecutesCommandsTests() {
  testWidgets('F3 opens Menu Search and executes the highlighted command', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.f3);
    await tester.pumpAndSettle();

    expect(find.byType(BlenderMenuSearch), findsOneWidget);
    final field = find.descendant(
      of: find.byKey(const ValueKey<String>('menu-search-field')),
      matching: find.byType(EditableText),
    );
    await tester.enterText(field, 'camera');
    await tester.pump();
    expect(find.textContaining('3D Viewport'), findsWidgets);
    expect(
      find.descendant(
        of: find.byType(BlenderMenuSearch),
        matching: find.textContaining('Camera'),
      ),
      findsOneWidget,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(BlenderMenuSearch), findsNothing);
  });

  testWidgets('Preferences exposes the live runtime keymap', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.f3);
    await tester.pumpAndSettle();
    final field = find.descendant(
      of: find.byKey(const ValueKey<String>('menu-search-field')),
      matching: find.byType(EditableText),
    );
    await tester.enterText(field, 'preferences');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.byType(BlenderPreferencesWindow), findsOneWidget);
    await tester.tap(find.text('Keymap').first);
    await tester.pumpAndSettle();
    expect(find.byType(BlenderKeymapEditor), findsOneWidget);
    expect(find.text('Menu Search...'), findsOneWidget);
    expect(find.text('F3'), findsOneWidget);
  });
}
