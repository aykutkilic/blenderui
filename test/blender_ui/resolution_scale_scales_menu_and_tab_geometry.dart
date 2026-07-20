part of '../blender_ui_test.dart';

void registerResolutionScaleScalesMenuAndTabGeometryTests() {
  testWidgets('resolution scale applies to menu rows and popup bounds', (
    tester,
  ) async {
    final theme = const BlenderThemeData().copyWith(
      density: const BlenderDensity().scaled(1.5),
    );
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: BlenderTheme(
          data: theme,
          child: Align(
            alignment: Alignment.topLeft,
            child: BlenderMenu<String>(
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'view', label: 'View'),
              ],
              onSelected: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('menu-row-View')))
          .height,
      42,
    );
    expect(tester.getSize(find.byType(BlenderMenu<String>)).width, 450);
  });

  testWidgets('resolution scale applies to tab headers and tab hit targets', (
    tester,
  ) async {
    final theme = const BlenderThemeData().copyWith(
      density: const BlenderDensity().scaled(1.5),
    );
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: BlenderTheme(
          data: theme,
          child: const Align(
            alignment: Alignment.topLeft,
            child: BlenderTabBar(
              tabs: <String>['Layout', 'Shading'],
              selectedIndex: 0,
              onChanged: _ignoreResolutionInt,
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(BlenderTabBar)).height, 36);
    expect(tester.getSize(find.byType(BlenderButton).first).height, 33);
  });
}

void _ignoreResolutionInt(int value) {}
