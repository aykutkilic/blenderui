import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tree content is vertically centered in its row', (tester) async {
    await tester.pumpWidget(
      const BlenderApp(
        home: SizedBox(
          width: 240,
          height: 100,
          child: BlenderTree<String>(
            roots: const <BlenderTreeNode<String>>[
              BlenderTreeNode<String>(
                id: 'root',
                label: 'Root',
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(id: 'child', label: 'Child'),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    final row = tester.getRect(
      find.byKey(const ValueKey<String>('tree-row-child')),
    );
    final label = tester.getRect(
      find.byKey(const ValueKey<String>('tree-label-child')),
    );

    expect(label.center.dy, closeTo(row.center.dy, 0.001));
  });
}
