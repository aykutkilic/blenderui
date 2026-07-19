part of '../blender_ui_test.dart';

void registerContextMenusFollowBlenderRegionsAndTargetsTests() {
  test('context catalogs preserve Blender grouping and command state', () {
    final object = BlenderContextMenuCatalog.object(
      selectedCount: 1,
      canPaste: false,
    );
    expect(object.first.label, 'Copy');
    expect(object.where((item) => item.separator), isNotEmpty);
    expect(
      object
          .singleWhere((item) => item.value == BlenderContextActionIds.paste)
          .enabled,
      isFalse,
    );
    expect(
      object
          .singleWhere((item) => item.value == BlenderContextActionIds.delete)
          .shortcut,
      'X',
    );

    final property = BlenderContextMenuCatalog.property(
      animated: true,
      developerMode: true,
    );
    expect(property.any((item) => item.label == 'Delete Keyframe'), isTrue);
    expect(property.any((item) => item.label == 'Edit Source'), isTrue);

    final verticalEdge = BlenderContextMenuCatalog.areaEdge(
      dividerAxis: Axis.vertical,
    );
    expect(
      verticalEdge.where((item) => !item.separator).map((item) => item.label),
      <String>[
        'Vertical Split',
        'Horizontal Split',
        'Join Right',
        'Join Left',
        'Swap Areas',
      ],
    );
    expect(
      verticalEdge.first.description,
      'Split selected area into new windows',
    );
    final horizontalEdge = BlenderContextMenuCatalog.areaEdge(
      dividerAxis: Axis.horizontal,
    );
    expect(horizontalEdge.any((item) => item.label == 'Join Up'), isTrue);
    expect(horizontalEdge.any((item) => item.label == 'Join Down'), isTrue);
    expect(horizontalEdge.any((item) => item.label == 'Join Left'), isFalse);
  });

  testWidgets('context menu is titled, actionable, and clamped to the view', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 240);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    String? selected;
    await tester.pumpWidget(
      BlenderApp(
        home: Align(
          alignment: Alignment.bottomRight,
          child: BlenderContextMenu<String>(
            title: 'Object',
            items: BlenderContextMenuCatalog.object(),
            onSelected: (value) => selected = value,
            child: const SizedBox(
              key: ValueKey<String>('context-target'),
              width: 32,
              height: 24,
            ),
          ),
        ),
      ),
    );

    await tester.tapAt(
      tester.getCenter(find.byKey(const ValueKey<String>('context-target'))),
      buttons: kSecondaryMouseButton,
    );
    await tester.pumpAndSettle();

    expect(find.text('Object'), findsOneWidget);
    final menuRect = tester.getRect(find.byType(BlenderMenu<String>));
    expect(menuRect.left, greaterThanOrEqualTo(0));
    expect(menuRect.top, greaterThanOrEqualTo(0));
    expect(menuRect.right, lessThanOrEqualTo(320));
    expect(menuRect.bottom, lessThanOrEqualTo(240));

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(selected, BlenderContextActionIds.delete);
  });

  testWidgets('Outliner selects the pointed entity before opening its menu', (
    tester,
  ) async {
    BlenderTreeNode<String>? selectedNode;
    String? selectedAction;
    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 420,
          height: 260,
          child: BlenderOutliner<String>(
            roots: const <BlenderTreeNode<String>>[
              BlenderTreeNode<String>(id: 'cube', label: 'Cube', value: 'cube'),
            ],
            onSelected: (node) => selectedNode = node,
            contextMenuTitleBuilder: (node) => node.label,
            contextMenuItemsBuilder: (_) =>
                BlenderContextMenuCatalog.outliner(),
            onContextMenuSelected: (node, action) {
              selectedNode = node;
              selectedAction = action;
            },
          ),
        ),
      ),
    );

    await tester.tapAt(
      tester.getCenter(find.text('Cube')),
      buttons: kSecondaryMouseButton,
    );
    await tester.pumpAndSettle();
    expect(selectedNode?.id, 'cube');
    expect(find.text('Cube'), findsNWidgets(2));

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(selectedAction, BlenderContextActionIds.delete);
  });

  testWidgets('file and node editors route context actions with identity', (
    tester,
  ) async {
    String? event;
    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 500,
          height: 300,
          child: BlenderFileBrowser(
            entries: const <BlenderFileEntry>[
              BlenderFileEntry(path: '/scene.blend', name: 'scene.blend'),
            ],
            contextMenuItemsBuilder: (_) =>
                BlenderContextMenuCatalog.fileBrowser(),
            onContextMenuSelected: (entry, action) =>
                event = '${entry.path}:$action',
          ),
        ),
      ),
    );
    await tester.tapAt(
      tester.getCenter(find.text('scene.blend')),
      buttons: kSecondaryMouseButton,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();
    expect(event, '/scene.blend:${BlenderContextActionIds.rename}');

    event = null;
    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 500,
          height: 300,
          child: BlenderNodeEditor(
            model: const BlenderNodeGraphModel(
              nodes: <BlenderGraphNode>[
                BlenderGraphNode(
                  id: 'shader',
                  title: 'Shader',
                  position: Offset(40, 40),
                ),
              ],
            ),
            contextMenuItemsBuilder: (_) => BlenderContextMenuCatalog.node(),
            onContextMenuSelected: (node, action) =>
                event = '${node.id}:$action',
          ),
        ),
      ),
    );
    await tester.tapAt(
      tester.getCenter(find.text('Shader')),
      buttons: kSecondaryMouseButton,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(event, 'shader:${BlenderContextActionIds.delete}');
  });
}
