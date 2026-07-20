import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child) => BlenderApp(home: BlenderTheme(child: child));

  testWidgets('Image header owns source-conditioned menu anatomy', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const BlenderImageEditorHeader(
          editorType: BlenderEditorType.imageEditor,
        ),
      ),
    );

    BlenderAreaHeader header = tester.widget<BlenderAreaHeader>(
      find.byType(BlenderAreaHeader),
    );
    expect(
      header.menuDescriptors.map(
        (menu) => (menu as BlenderMenuDescriptor<String>).label,
      ),
      <String>['View', 'Image'],
    );
    final view = header.menuDescriptors.first as BlenderMenuDescriptor<String>;
    expect(
      view.items.map((item) => item.label),
      isNot(contains('Render Border')),
    );
    final zoom = view.items.firstWhere((item) => item.label == 'Zoom');
    expect(
      zoom.submenu?.map((item) => item.label),
      containsAll(<String>['400% (4:1)', '800% (8:1)', 'Zoom In', 'Zoom Out']),
    );

    await tester.pumpWidget(
      host(
        const BlenderImageEditorHeader(
          editorType: BlenderEditorType.imageEditor,
          showRender: true,
        ),
      ),
    );
    header = tester.widget<BlenderAreaHeader>(find.byType(BlenderAreaHeader));
    final renderView =
        header.menuDescriptors.first as BlenderMenuDescriptor<String>;
    expect(
      renderView.items.map((item) => item.label),
      contains('Render Border'),
    );
  });

  testWidgets('UV header keeps settings host-owned and popovers independent', (
    tester,
  ) async {
    var value = const BlenderImageEditorHeaderState();
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => BlenderImageEditorHeader(
            editorType: BlenderEditorType.uvEditor,
            state: value,
            onStateChanged: (next) => setState(() => value = next),
          ),
        ),
      ),
    );

    final header = tester.widget<BlenderAreaHeader>(
      find.byType(BlenderAreaHeader),
    );
    expect(
      header.menuDescriptors.map(
        (menu) => (menu as BlenderMenuDescriptor<String>).label,
      ),
      <String>['View', 'Select', 'Image', 'UV'],
    );
    final select = header.menuDescriptors[1] as BlenderMenuDescriptor<String>;
    expect(
      select.items.map((item) => item.label),
      containsAll(<String>[
        'Box Select Pinned',
        'More',
        'Less',
        'Select Similar',
        'Select Split',
        'Select All by Trait',
      ]),
    );
    final uv = header.menuDescriptors[3] as BlenderMenuDescriptor<String>;
    expect(
      uv.items.map((item) => item.label),
      containsAll(<String>[
        'Live Unwrap',
        'Invert Pins',
        'Seams from Islands',
        'Arrange Islands',
        'Minimize Stretch',
        'Reset',
      ]),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('image-snap-toggle-button')),
    );
    await tester.pump();
    expect(value.snapping, isTrue);

    await tester.tap(find.byKey(const ValueKey<String>('image-snap-button')));
    await tester.pumpAndSettle();
    expect(find.text('Snapping'), findsOneWidget);
    expect(value.snapping, isTrue);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(value.snapping, isTrue);

    await tester.tap(find.byKey(const ValueKey<String>('image-pin-button')));
    await tester.pump();
    expect(value.pinned, isTrue);
  });

  testWidgets(
    'Image editor region layout owns toolbar sidebar and asset shelf',
    (tester) async {
      await tester.pumpWidget(
        host(
          const Center(
            child: SizedBox(
              width: 800,
              height: 600,
              child: BlenderImageEditorLayout(
                canvas: SizedBox.expand(key: ValueKey<String>('image-canvas')),
                toolShelf: SizedBox.expand(
                  key: ValueKey<String>('image-tools'),
                ),
                sidebar: SizedBox.expand(
                  key: ValueKey<String>('image-sidebar'),
                ),
                assetShelf: SizedBox.expand(
                  key: ValueKey<String>('image-assets'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byKey(const ValueKey<String>('image-tools'))).width,
        42,
      );
      expect(
        tester
            .getSize(find.byKey(const ValueKey<String>('image-sidebar')))
            .width,
        240,
      );
      expect(
        tester
            .getSize(find.byKey(const ValueKey<String>('image-assets')))
            .height,
        144,
      );
      expect(
        tester.getSize(find.byKey(const ValueKey<String>('image-canvas'))),
        const Size(518, 456),
      );
    },
  );

  test('Image tool shelves follow local source mode families', () {
    expect(
      BlenderImageEditorToolShelf.viewTools.map((tool) => tool.tooltip),
      <String>['Sample', 'Annotate'],
    );
    expect(
      BlenderImageEditorToolShelf.paintTools.map((tool) => tool.tooltip),
      <String>['Brush', 'Blur', 'Smear', 'Clone'],
    );
    expect(
      BlenderImageEditorToolShelf.uvTools.map((tool) => tool.tooltip),
      containsAll(<String>[
        'Select',
        'Cursor',
        'Move',
        'Rotate',
        'Scale',
        'Transform',
        'Rip Region',
        'Grab',
        'Relax',
        'Pinch',
      ]),
    );
  });
}
