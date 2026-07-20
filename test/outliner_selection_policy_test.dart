import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const roots = <BlenderTreeNode<String>>[
    BlenderTreeNode<String>(id: 'a', label: 'Alpha'),
    BlenderTreeNode<String>(id: 'b', label: 'Beta'),
    BlenderTreeNode<String>(id: 'c', label: 'Gamma'),
  ];

  testWidgets('shift selects a visible row range', (tester) async {
    var selected = <String>{};
    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 360,
          height: 240,
          child: StatefulBuilder(
            builder: (context, setState) => BlenderOutliner<String>(
              roots: roots,
              selectedIds: selected,
              onSelectionChanged: (value) => setState(() => selected = value),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Alpha'));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.tap(find.text('Gamma'));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    expect(selected, <String>{'a', 'b', 'c'});
  });

  testWidgets('arrow keys move the active row and enter activates it', (
    tester,
  ) async {
    var selected = <String>{};
    String? activeId;
    String? activatedId;
    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 360,
          height: 240,
          child: StatefulBuilder(
            builder: (context, setState) => BlenderTree<String>(
              roots: roots,
              selectedIds: selected,
              onSelected: (node) => activeId = node.id,
              onSelectionChanged: (value) => setState(() => selected = value),
              onActivated: (node) => activatedId = node.id,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Alpha'));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);

    expect(selected, <String>{'b'});
    expect(activeId, 'b');
    expect(activatedId, 'b');
  });
}
