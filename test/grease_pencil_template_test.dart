import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const brushes = <BlenderGreasePencilBrush>[
    BlenderGreasePencilBrush(id: 'pencil', label: 'Pencil'),
    BlenderGreasePencilBrush(
      id: 'eraser',
      label: 'Eraser Soft',
      category: 'Erase',
    ),
  ];

  testWidgets('Grease Pencil regions expose source-shaped reusable controls', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    BlenderGreasePencilHeaderState? headerState;
    BlenderGreasePencilToolSettings? toolSettings;
    BlenderGreasePencilBrush? selectedBrush;
    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 1100,
          height: 700,
          child: Column(
            children: <Widget>[
              BlenderGreasePencilEditorHeader(
                onStateChanged: (value) => headerState = value,
              ),
              BlenderGreasePencilToolHeader(
                brushes: brushes,
                onChanged: (value) => toolSettings = value,
              ),
              Expanded(
                child: BlenderGreasePencilViewport(
                  strokes: const <BlenderGreasePencilStroke>[
                    BlenderGreasePencilStroke(
                      points: <Offset>[Offset(.2, .2), Offset(.8, .8)],
                    ),
                  ],
                  toolShelf: BlenderGreasePencilToolShelf(
                    selectedTool: BlenderGreasePencilTool.draw,
                    onChanged: (_) {},
                  ),
                  assetShelf: BlenderGreasePencilBrushAssetShelf(
                    brushes: brushes,
                    selectedId: 'pencil',
                    onSelected: (brush) => selectedBrush = brush,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('gp-tool-header')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('gp-camera-canvas')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('gp-brush-asset-shelf')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('gp-add-weight-data')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('gp-draw-on-back')),
      findsOneWidget,
    );
    expect(find.text('Pencil'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey<String>('gp-multiframe')));
    expect(headerState?.multiFrame, isTrue);

    await tester.tap(find.byKey(const ValueKey<String>('gp-brush-selector')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('asset-shelf-popover')),
      findsOneWidget,
    );
    expect(find.text('All Libraries'), findsOneWidget);
    expect(find.text('Grease Pencil Draw'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('asset-shelf-eraser')));
    await tester.pumpAndSettle();
    expect(toolSettings?.brushId, 'eraser');

    await tester.tap(
      find.byKey(const ValueKey<String>('gp-material-selector')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('gp-material-popover')),
      findsOneWidget,
    );
    expect(find.text('Stroke Color:'), findsOneWidget);
    expect(find.text('Fill Color:'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('gp-material-Line')));
    await tester.pumpAndSettle();
    expect(toolSettings?.material, 'Line');

    await tester.tap(find.byKey(const ValueKey<String>('gp-brush-eraser')));
    expect(selectedBrush?.id, 'eraser');

    await tester.tap(find.byType(BlenderAssetShelfCatalogSelector));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('asset-catalog-selector')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('asset-catalog-selector')),
        matching: find.text('Erase'),
      ),
      findsOneWidget,
    );

    final radius = find.widgetWithText(BlenderNumberField, 'Size');
    expect(radius, findsOneWidget);
    tester.widget<BlenderNumberField>(radius).onChanged(.08);
    expect(toolSettings?.radius, .08);
  });

  testWidgets('Sequencer owns Channels and isolated playhead layers', (
    tester,
  ) async {
    final playback = BlenderPlaybackController(initialFrame: 1);
    addTearDown(playback.dispose);
    BlenderSequencerStrip? selected;
    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 900,
          height: 240,
          child: BlenderSequencerEditor(
            strips: const <BlenderSequencerStrip>[
              BlenderSequencerStrip(
                id: 'shot',
                label: 'Shot.001',
                start: 1,
                end: 49,
              ),
            ],
            start: 1,
            end: 97,
            currentFrameListenable: playback,
            showChannels: true,
            showSeconds: true,
            onStripSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('sequencer-channels-region')),
      findsOneWidget,
    );
    final overlay = find.byKey(
      const ValueKey<String>('sequencer-playhead-canvas'),
    );
    final painter = tester.widget<CustomPaint>(overlay).painter;
    playback.seek(24);
    await tester.pump();
    expect(tester.widget<CustomPaint>(overlay).painter, same(painter));

    final window = tester.getRect(
      find.byKey(const ValueKey<String>('sequencer-window-region')),
    );
    await tester.tapAt(window.topLeft + const Offset(100, 40));
    expect(selected?.id, 'shot');
  });
}
