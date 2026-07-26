import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('viewport hides its sidebar when the dock is too narrow', (
    tester,
  ) async {
    final controller = BlenderViewportController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 304.2,
          height: 351.2,
          child: BlenderViewportShell(
            controller: controller,
            sidebarWidth: 320,
            sceneBuilder: (context, state) => const SizedBox.expand(),
            sidebar: const SizedBox(width: 320),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('selection mode bar remains bounded in a narrow viewport', (
    tester,
  ) async {
    await tester.pumpWidget(
      const BlenderApp(
        home: SizedBox(
          width: 304.2,
          height: 40,
          child: BlenderViewportSelectionModeBar(
            value: 'Set',
            onChanged: _ignoreString,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

void _ignoreString(String value) {}
