import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const imageBoundary = ValueKey<String>('image-editor-reference');
  const uvBoundary = ValueKey<String>('uv-editor-reference');

  Future<void> configureView(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
  }

  testWidgets('Image Editor rendered reference', (tester) async {
    await configureView(tester);
    await tester.pumpWidget(
      BlenderApp(
        home: RepaintBoundary(
          key: imageBoundary,
          child: Column(
            children: <Widget>[
              const BlenderImageEditorHeader(
                editorType: BlenderEditorType.imageEditor,
              ),
              Expanded(
                child: BlenderImageEditor(
                  label: 'Render Result',
                  toolShelf: BlenderImageEditorToolShelf(
                    mode: BlenderImageEditorMode.view,
                    selectedIndex: 0,
                    onChanged: (_) {},
                  ),
                  sidebar: const BlenderImageEditorSidebar(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(imageBoundary),
      matchesGoldenFile('goldens/image_editor_reference.png'),
    );
  });

  testWidgets('UV Editor rendered reference', (tester) async {
    await configureView(tester);
    await tester.pumpWidget(
      BlenderApp(
        home: RepaintBoundary(
          key: uvBoundary,
          child: Column(
            children: <Widget>[
              const BlenderImageEditorHeader(
                editorType: BlenderEditorType.uvEditor,
              ),
              Expanded(
                child: BlenderUVEditor(
                  points: const <BlenderUVPoint>[
                    BlenderUVPoint(id: 'a', position: Offset(.18, .2)),
                    BlenderUVPoint(id: 'b', position: Offset(.78, .2)),
                    BlenderUVPoint(id: 'c', position: Offset(.78, .78)),
                    BlenderUVPoint(id: 'd', position: Offset(.18, .78)),
                  ],
                  edges: const <BlenderUVEdge>[
                    BlenderUVEdge(from: 0, to: 1),
                    BlenderUVEdge(from: 1, to: 2),
                    BlenderUVEdge(from: 2, to: 3),
                    BlenderUVEdge(from: 3, to: 0),
                  ],
                  selectedId: 'a',
                  toolShelf: BlenderImageEditorToolShelf(
                    mode: BlenderImageEditorMode.uv,
                    selectedIndex: 0,
                    onChanged: (_) {},
                  ),
                  sidebar: const BlenderImageEditorSidebar(uvEditor: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(uvBoundary),
      matchesGoldenFile('goldens/uv_editor_reference.png'),
    );
  });
}
