import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('hover completes the outline of an attached editor frame', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: BlenderTheme(
          child: SizedBox(
            width: 120,
            height: 80,
            child: BlenderEditorFrame(
              showTopBorder: false,
              showLeftBorder: false,
              child: SizedBox.expand(),
            ),
          ),
        ),
      ),
    );

    final child = find.byType(SizedBox).last;
    final childRectBeforeHover = tester.getRect(child);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(BlenderEditorFrame)));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.getRect(child), childRectBeforeHover);

    final overlays = tester.widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(AnimatedOpacity),
        matching: find.byType(DecoratedBox),
      ),
    );
    final outline =
        (overlays.single.decoration! as BoxDecoration).border! as Border;
    final theme = BlenderTheme.of(
      tester.element(find.byType(BlenderEditorFrame)),
    );

    expect(outline.top.color, theme.colors.editorOutlineActive);
    expect(outline.right.color, theme.colors.editorOutlineActive);
    expect(outline.bottom.color, theme.colors.editorOutlineActive);
    expect(outline.left.color, theme.colors.editorOutlineActive);
  });
}
