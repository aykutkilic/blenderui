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
