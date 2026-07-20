import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const model = BlenderNodeGraphModel(
    nodes: <BlenderGraphNode>[
      BlenderGraphNode(id: 'a', title: 'Input', position: Offset(100, 100)),
      BlenderGraphNode(id: 'b', title: 'Output', position: Offset(360, 100)),
    ],
  );

  Widget harness(Widget child) =>
      BlenderApp(home: SizedBox(width: 760, height: 480, child: child));

  testWidgets('node clicks replace or extend host-owned selection', (
    tester,
  ) async {
    var selected = <String>{};
    await tester.pumpWidget(
      harness(
        StatefulBuilder(
          builder: (context, setState) => BlenderNodeEditor(
            title: null,
            model: model,
            selectedNodeIds: selected,
            onNodeSelectionChanged: (value) => setState(() => selected = value),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('node-editor-node-a')));
    await tester.pump();
    expect(selected, <String>{'a'});

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.tap(find.byKey(const ValueKey<String>('node-editor-node-b')));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    expect(selected, <String>{'a', 'b'});
  });

  testWidgets('blank-canvas drag emits box-selected node IDs', (tester) async {
    Set<String>? selected;
    await tester.pumpWidget(
      harness(
        BlenderNodeEditor(
          title: null,
          model: model,
          onNodeSelectionChanged: (value) => selected = value,
        ),
      ),
    );

    await tester.dragFrom(const Offset(40, 50), const Offset(300, 230));
    await tester.pump();
    expect(selected, <String>{'a'});
  });

  testWidgets('Cut Links tool reports a scene-space stroke', (tester) async {
    (Offset, Offset)? stroke;
    await tester.pumpWidget(
      harness(
        BlenderNodeEditor(
          title: null,
          model: model,
          linkCutting: true,
          onLinksCut: (start, end) => stroke = (start, end),
        ),
      ),
    );

    await tester.dragFrom(const Offset(300, 40), const Offset(0, 260));
    expect(stroke, isNotNull);
    expect(stroke!.$1.dx, stroke!.$2.dx);
  });

  testWidgets('dragging a selected node reports one grouped transaction', (
    tester,
  ) async {
    Map<BlenderGraphNode, Offset>? moved;
    await tester.pumpWidget(
      harness(
        BlenderNodeEditor(
          title: null,
          model: model,
          selectedNodeIds: const <String>{'a', 'b'},
          onNodesMoved: (value) => moved = value,
          snapIncrement: 10,
        ),
      ),
    );

    final node = find.byKey(const ValueKey<String>('node-editor-node-a'));
    await tester.dragFrom(
      tester.getTopLeft(node) + const Offset(50, 12),
      const Offset(23, 17),
    );
    await tester.pump();

    expect(moved, isNotNull);
    expect(moved!.length, 2);
    expect(moved!.entries.first.value.dx % 10, 0);
  });

  test('duplicates selected subgraphs with host-generated IDs', () {
    final selectedModel = model.selectNodes(<String>{'a', 'b'}, activeId: 'b');
    final linked = selectedModel.copyWith(
      links: const <BlenderGraphLink>[BlenderGraphLink(from: 'a', to: 'b')],
    );
    final duplicated = linked.duplicateSelectedNodes(
      idBuilder: (node) => '${node.id}-copy',
    );

    expect(
      duplicated.nodes.map((node) => node.id),
      containsAll(<String>['a-copy', 'b-copy']),
    );
    expect(
      duplicated.links.any(
        (link) => link.from == 'a-copy' && link.to == 'b-copy',
      ),
      isTrue,
    );
    expect(
      duplicated.nodes.where((node) => node.selected).map((node) => node.id),
      <String>['a-copy', 'b-copy'],
    );
  });

  test('cut stroke removes crossed links only', () {
    final linked = model.copyWith(
      links: const <BlenderGraphLink>[BlenderGraphLink(from: 'a', to: 'b')],
    );

    expect(
      linked.cutLinks(const Offset(300, 0), const Offset(300, 300)).links,
      isEmpty,
    );
    expect(
      linked.cutLinks(const Offset(0, 0), const Offset(0, 300)),
      same(linked),
    );
  });

  testWidgets('node group breadcrumbs jump through immutable path state', (
    tester,
  ) async {
    final navigation = BlenderNodeGroupNavigation(
      path: const <BlenderNodeGroupPathEntry>[
        BlenderNodeGroupPathEntry(id: 'root', label: 'Geometry Nodes'),
        BlenderNodeGroupPathEntry(id: 'scatter', label: 'Scatter'),
      ],
    );
    BlenderNodeGroupNavigation? changed;
    await tester.pumpWidget(
      harness(
        BlenderNodeEditorHeader(
          editorType: BlenderEditorType.geometryNodeEditor,
          treeContext: 'Modifier',
          dataBlock: 'Geometry Nodes',
          groupNavigation: navigation,
          onGroupNavigationChanged: (value) => changed = value,
        ),
      ),
    );

    expect(find.text('Geometry Nodes'), findsWidgets);
    expect(find.text('Scatter'), findsOneWidget);
    await tester.tap(find.text('Geometry Nodes').last);
    expect(changed?.current.id, 'root');
    expect(navigation.exit().current.id, 'root');
  });
}
