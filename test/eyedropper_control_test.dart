import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('eyedropper exposes host-owned activation', (tester) async {
    var active = false;
    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFF202020),
        builder: (context, child) => BlenderTheme(
          child: StatefulBuilder(
            builder: (context, setState) => BlenderEyedropper(
              active: active,
              onPressed: () => setState(() => active = !active),
            ),
          ),
        ),
      ),
    );

    expect(active, isFalse);
    await tester.tap(find.byType(BlenderEyedropper));
    await tester.pump();
    expect(active, isTrue);
    final button = tester.widget<BlenderIconButton>(
      find.descendant(
        of: find.byType(BlenderEyedropper),
        matching: find.byType(BlenderIconButton),
      ),
    );
    expect(button.selected, isTrue);
  });
}
