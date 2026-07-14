import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void _ignoreDouble(double _) {}

void _ignoreBool(bool _) {}

Widget _propertiesHarness() {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: BlenderTheme(
      child: SizedBox(
        width: 460,
        height: 360,
        child: BlenderPropertiesEditor(
          title: 'Output',
          joinNavigationRail: true,
          groups: <BlenderPropertyGroup>[
            BlenderPropertyGroup(
              id: 'format',
              title: 'Format',
              properties: <BlenderPropertyDescriptor<dynamic>>[
                BlenderPropertyDescriptor<double>(
                  id: 'resolution-x',
                  label: 'Resolution X',
                  value: 1920,
                  editorBuilder: (context, value, onChanged) =>
                      BlenderNumberField(
                        value: value,
                        decimalDigits: 0,
                        onChanged: _ignoreDouble,
                      ),
                ),
                BlenderPropertyDescriptor<double>(
                  id: 'resolution-y',
                  label: 'Y',
                  value: 1080,
                  editorBuilder: (context, value, onChanged) =>
                      BlenderNumberField(
                        value: value,
                        decimalDigits: 0,
                        onChanged: _ignoreDouble,
                      ),
                ),
                BlenderPropertyDescriptor<bool>(
                  id: 'render-region',
                  label: 'Render Region',
                  value: false,
                  editorBuilder: (context, value, onChanged) =>
                      BlenderCheckbox(value: value, onChanged: _ignoreBool),
                ),
                BlenderPropertyDescriptor<bool>(
                  id: 'crop-region',
                  label: 'Crop to Render Region',
                  value: false,
                  editorBuilder: (context, value, onChanged) =>
                      BlenderCheckbox(value: value, onChanged: _ignoreBool),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('Output properties preserve Blender boolean row composition', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(460, 360);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_propertiesHarness());
    await tester.pumpAndSettle();

    final frame = tester.widget<BlenderEditorFrame>(
      find.byType(BlenderEditorFrame),
    );
    expect(frame.showTopBorder, isFalse);
    expect(frame.squareTopCorners, isTrue);

    final editorLeft = tester
        .getTopLeft(find.byType(BlenderPropertiesEditor))
        .dx;
    final panelLeft = tester.getTopLeft(find.byType(BlenderPanel)).dx;
    expect(panelLeft - editorLeft, 10);

    final disclosure = tester.widget<BlenderIcon>(
      find.byWidgetPredicate(
        (widget) =>
            widget is BlenderIcon &&
            widget.glyph == BlenderGlyph.panelDisclosureDown,
      ),
    );
    expect(disclosure.size, 9);

    await expectLater(
      find.byType(BlenderPropertiesEditor),
      matchesGoldenFile('goldens/output_format_properties.png'),
    );
  });
}
