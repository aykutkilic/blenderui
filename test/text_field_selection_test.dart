import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  testWidgets('BlenderTextField double tap selects the word under the pointer', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'alpha beta gamma');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      BlenderApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 320,
            child: BlenderTextField(controller: controller),
          ),
        ),
      ),
    );
    await tester.pump();

    final editable = find.byType(EditableText);
    final rect = tester.getRect(editable);
    final point = Offset(rect.left + 90, rect.center.dy);
    await tester.tapAt(point, kind: PointerDeviceKind.mouse);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(point, kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();

    expect(controller.selection.textInside(controller.text), 'beta');
  });
}
