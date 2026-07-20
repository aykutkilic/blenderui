import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _selectorHarness(Widget selector) => BlenderApp(
  home: BlenderTheme(
    child: ColoredBox(
      color: const Color(0xFF303030),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(width: 120, child: selector),
        ),
      ),
    ),
  ),
);

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Object Mode selector rendered reference', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(520, 360);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _selectorHarness(
        BlenderView3dModeSelector(value: 'Object Mode', onChanged: (_) {}),
      ),
    );
    await tester.tap(find.byType(BlenderView3dModeSelector));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Overlay),
      matchesGoldenFile('goldens/view3d_object_mode_selector_reference.png'),
    );
  });

  testWidgets('Transform Orientation selector rendered reference', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(520, 420);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _selectorHarness(
        BlenderTransformOrientationSelector(
          value: 'Global',
          onChanged: (_) {},
          onCreate: () {},
        ),
      ),
    );
    await tester.tap(find.byType(BlenderTransformOrientationSelector));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Overlay),
      matchesGoldenFile(
        'goldens/view3d_transform_orientation_selector_reference.png',
      ),
    );
  });
}
