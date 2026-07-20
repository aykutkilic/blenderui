part of '../blender_ui_test.dart';

void registerView3dChromeIsLibraryOwnedTests() {
  testWidgets('View3D tool taxonomy and orientation gizmo are reusable', (
    tester,
  ) async {
    var selectedTool = 0;
    await tester.pumpWidget(
      _harness(
        StatefulBuilder(
          builder: (context, setState) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BlenderView3dToolShelf(
                selectedIndex: selectedTool,
                onChanged: (value) => setState(() => selectedTool = value),
              ),
              const BlenderViewportOrientationGizmo(yaw: .4, pitch: .6),
            ],
          ),
        ),
      ),
    );

    expect(BlenderView3dToolShelf.tools, hasLength(8));
    expect(BlenderView3dToolShelf.tools.first.options, hasLength(4));
    expect(find.byType(BlenderViewportOrientationGizmo), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    final shelf = tester.getSize(find.byType(BlenderView3dToolShelf));
    expect(shelf.width, 56);
    final firstToolButton = tester.widget<BlenderIconButton>(
      find
          .descendant(
            of: find.byType(BlenderView3dToolShelf),
            matching: find.byType(BlenderIconButton),
          )
          .first,
    );
    expect(firstToolButton.size, 40);
    expect(firstToolButton.iconSize, 32);
    expect(
      tester.getSize(find.byType(BlenderViewportOrientationGizmo)),
      const Size.square(80),
    );

    final moveButton = find
        .descendant(
          of: find.byType(BlenderView3dToolShelf),
          matching: find.byType(BlenderIconButton),
        )
        .at(2);
    await tester.tap(moveButton);
    await tester.pump();
    expect(selectedTool, 2);
  });

  testWidgets('floating View3D tool shelf scrolls in a short pane', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 56,
          height: 120,
          child: BlenderView3dToolShelf(
            selectedIndex: 0,
            onChanged: _ignoreToolSelection,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      find.descendant(
        of: find.byType(BlenderView3dToolShelf),
        matching: find.byType(Scrollable),
      ),
      findsOneWidget,
    );
  });

  testWidgets('View3D selection strip uses toolbar-sized controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const BlenderViewportSelectionModeBar(
          value: 'Set',
          onChanged: _ignoreSelectionMode,
        ),
      ),
    );

    final buttons = find.descendant(
      of: find.byType(BlenderViewportSelectionModeBar),
      matching: find.byType(BlenderIconButton),
    );
    expect(buttons, findsNWidgets(5));
    for (final button in tester.widgetList<BlenderIconButton>(buttons)) {
      expect(button.size, 32);
      expect(button.iconSize, 20);
      expect(button.scaleWithDensity, isFalse);
    }
  });

  testWidgets('View3D sidebar tabs scroll in a short pane', (tester) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 29,
          height: 120,
          child: BlenderViewportSidebarRail(
            tabs: <BlenderViewportSidebarTab>[
              BlenderViewportSidebarTab(id: 'item', label: 'Item'),
              BlenderViewportSidebarTab(id: 'tool', label: 'Tool'),
              BlenderViewportSidebarTab(id: 'view', label: 'View'),
              BlenderViewportSidebarTab(id: 'animation', label: 'Animation'),
            ],
            selected: 'item',
            expanded: true,
            onSelected: _ignoreSidebarSelection,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      find.descendant(
        of: find.byType(BlenderViewportSidebarRail),
        matching: find.byType(Scrollable),
      ),
      findsOneWidget,
    );
  });

  testWidgets('settings popover panel owns the standard vertical layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        BlenderPopoverPanel.settings('Overlays', const <Widget>[
          Text('Grid'),
          Text('Axes'),
        ]),
      ),
    );

    expect(find.text('Overlays'), findsOneWidget);
    expect(find.text('Grid'), findsOneWidget);
    expect(find.text('Axes'), findsOneWidget);
    final column = tester.widget<Column>(find.byType(Column).last);
    expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
  });
}

void _ignoreToolSelection(int _) {}

void _ignoreSelectionMode(String _) {}

void _ignoreSidebarSelection(String _) {}
