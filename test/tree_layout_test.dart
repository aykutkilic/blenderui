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

  testWidgets('collapsed summaries clear the overlaid scrollbar', (
    tester,
  ) async {
    await tester.pumpWidget(
      const BlenderApp(
        home: SizedBox(
          width: 240,
          height: 44,
          child: BlenderTree<String>(
            roots: <BlenderTreeNode<String>>[
              BlenderTreeNode<String>(
                id: 'root',
                label: 'Root',
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'child-a',
                    label: 'Child A',
                    icon: BlenderGlyph.file,
                  ),
                  BlenderTreeNode<String>(
                    id: 'child-b',
                    label: 'Child B',
                    icon: BlenderGlyph.file,
                  ),
                ],
              ),
              BlenderTreeNode<String>(id: 'second', label: 'Second'),
              BlenderTreeNode<String>(id: 'third', label: 'Third'),
            ],
          ),
        ),
      ),
    );

    final viewport = tester.getRect(find.byType(BlenderTree<String>));
    final summary = tester.getRect(
      find.byKey(const ValueKey<String>('tree-collapsed-summary-root')),
    );
    expect(summary.right, lessThanOrEqualTo(viewport.right - 8));
  });
}
