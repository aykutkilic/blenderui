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

  testWidgets('placement-aware drops measure the row instead of its sliver', (
    tester,
  ) async {
    BlenderTreeDropPlacement? acceptedPlacement;
    var selectedIds = <String>{};
    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 240,
          height: 100,
          child: StatefulBuilder(
            builder: (context, setState) => BlenderTree<String>(
              roots: <BlenderTreeNode<String>>[
                const BlenderTreeNode<String>(
                  id: 'source',
                  label: 'Source',
                  dragData: 'source',
                ),
                BlenderTreeNode<String>(
                  id: 'target',
                  label: 'Target',
                  dragData: 'target',
                  canAcceptDropAt: (data, placement) => data == 'source',
                  onAcceptDropAt: (data, placement) {
                    acceptedPlacement = placement;
                  },
                ),
              ],
              selectedIds: selectedIds,
              onSelectionChanged: (value) =>
                  setState(() => selectedIds = value),
              contextMenuItemsBuilder: (node) =>
                  const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: 'rename', label: 'Rename'),
                  ],
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Source')),
    );
    await gesture.moveTo(tester.getCenter(find.text('Target')));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(acceptedPlacement, BlenderTreeDropPlacement.inside);
  });
}
