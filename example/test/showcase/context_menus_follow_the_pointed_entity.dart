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
}
