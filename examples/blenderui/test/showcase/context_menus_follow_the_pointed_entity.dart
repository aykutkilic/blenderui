part of '../widget_test.dart';

void registerContextMenusFollowThePointedEntityTests() {
  testWidgets('showcase Outliner opens the pointed entity context menu', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final cubeRow = find.byKey(const ValueKey<String>('tree-row-cube'));
    await tester.tapAt(
      tester.getCenter(cubeRow),
      buttons: kSecondaryMouseButton,
    );
    await tester.pumpAndSettle();

    expect(find.text('Delete Hierarchy'), findsOneWidget);
    expect(find.text('Mark as Asset'), findsOneWidget);
    expect(find.text('Library Override'), findsOneWidget);

    await tester.tap(find.text('Delete Hierarchy'));
    await tester.pumpAndSettle();
    expect(find.textContaining('delete-hierarchy: Cube'), findsWidgets);
  });

  testWidgets('showcase dock divider opens source-shaped area options', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    final divider = find.byKey(
      const ValueKey<String>('dock-divider-workspace-columns'),
    );
    await tester.tapAt(
      tester.getCenter(divider),
      buttons: kSecondaryMouseButton,
    );
    await tester.pumpAndSettle();

    expect(find.text('Area Options'), findsOneWidget);
    expect(find.text('Vertical Split'), findsOneWidget);
    expect(find.text('Horizontal Split'), findsOneWidget);
    expect(find.text('Join Right'), findsOneWidget);
    expect(find.text('Join Left'), findsOneWidget);
    expect(find.text('Swap Areas'), findsOneWidget);
  });
}
