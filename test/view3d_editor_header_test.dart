import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('View3D header owns Object Mode source chrome', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    var value = const BlenderView3dEditorHeaderState();
    await tester.pumpWidget(
      BlenderApp(
        home: BlenderTheme(
          child: StatefulBuilder(
            builder: (context, setState) => BlenderView3dEditorHeader(
              state: value,
              onStateChanged: (next) => setState(() => value = next),
            ),
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
      <String>['View', 'Select', 'Add', 'Object'],
    );
    final add = header.menuDescriptors[2] as BlenderMenuDescriptor<String>;
    expect(
      add.items.map((item) => item.label),
      containsAll(<String>['Mesh', 'Grease Pencil', 'Light Probe', 'Camera']),
    );

    await tester.tap(find.byKey(const ValueKey<String>('viewport-mode')));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('view3d-mode-menu'))),
      const Size(204, 204),
    );
    expect(find.text('Draw Mode'), findsOneWidget);
    expect(find.text('Weight Paint'), findsOneWidget);
    expect(find.text('Vertex Paint'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey<String>('view3d-mode-Sculpt Mode')),
    );
    await tester.pumpAndSettle();
    expect(value.mode, 'Sculpt Mode');

    await tester.tap(
      find.byKey(const ValueKey<String>('viewport-transform-orientation')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Transform Orientations'), findsOneWidget);
    expect(
      tester
          .getSize(
            find.byKey(const ValueKey<String>('transform-orientation-panel')),
          )
          .width,
      224,
    );
    expect(find.text('Gimbal'), findsOneWidget);
    expect(find.text('Parent'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Create Transform Orientation'),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('transform-orientation-Local')),
    );
    await tester.pumpAndSettle();
    expect(value.transformOrientation, 'Local');

    await tester.tap(find.byKey(const ValueKey<String>('viewport-snap')));
    await tester.pump();
    expect(value.snapping, isTrue);
    await tester.tap(
      find.byKey(const ValueKey<String>('viewport-shading-rendered')),
    );
    await tester.pump();
    expect(value.shading, 'Rendered');
    await tester.tap(find.byKey(const ValueKey<String>('viewport-overlays')));
    await tester.pumpAndSettle();
    expect(find.text('Relationship Lines'), findsOneWidget);
  });
}
