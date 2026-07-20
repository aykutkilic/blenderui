import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const key = BlenderGraphKeyframe(id: 'x-50', frame: 50, value: 0);
  const curve = BlenderCurveChannel(
    id: 'x',
    label: 'X Location',
    color: Color(0xFFFF3352),
    active: true,
    keyframes: <BlenderGraphKeyframe>[key],
  );

  test('viewport controller pans, zooms, and frames curve data', () {
    final controller = BlenderGraphViewportController(
      const BlenderGraphViewport(
        frameStart: 0,
        frameEnd: 100,
        valueMin: -1,
        valueMax: 1,
      ),
    );
    addTearDown(controller.dispose);

    controller.pan(frames: 10, values: 1);
    expect(controller.value.frameStart, 10);
    expect(controller.value.valueMin, 0);
    controller.zoom(frameFactor: .5, valueFactor: .5);
    expect(controller.value.frameEnd - controller.value.frameStart, 50);

    controller.frameAll(const <BlenderCurveChannel>[
      BlenderCurveChannel(
        id: 'curve',
        label: 'Curve',
        keyframes: <BlenderGraphKeyframe>[
          BlenderGraphKeyframe(id: 'a', frame: 20, value: -2),
          BlenderGraphKeyframe(id: 'b', frame: 80, value: 4),
        ],
      ),
    ]);
    expect(controller.value.frameStart, lessThan(20));
    expect(controller.value.frameEnd, greaterThan(80));
    expect(controller.value.valueMin, lessThan(-2));
    expect(controller.value.valueMax, greaterThan(4));
  });

  testWidgets('Graph Editor owns independent Channels and Window regions', (
    tester,
  ) async {
    BlenderGraphChannelAction? action;
    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 1000,
          height: 500,
          child: BlenderCurveEditor(
            channels: const <BlenderCurveChannel>[curve],
            channelTree: const <BlenderGraphChannelNode>[
              BlenderGraphChannelNode(
                id: 'object',
                label: 'Cube',
                kind: BlenderGraphChannelKind.object,
                children: <BlenderGraphChannelNode>[
                  BlenderGraphChannelNode(
                    id: 'x',
                    label: 'X Location',
                    kind: BlenderGraphChannelKind.curve,
                    curveId: 'x',
                  ),
                ],
              ),
            ],
            onChannelAction: (value) => action = value,
          ),
        ),
      ),
    );

    final channels = find.byKey(
      const ValueKey<String>('graph-channels-region'),
    );
    final window = find.byKey(const ValueKey<String>('graph-window-region'));
    expect(tester.getSize(channels).width, 260);
    expect(tester.getTopLeft(window).dx, 260);
    expect(find.text('Cube'), findsOneWidget);
    expect(find.text('X Location'), findsOneWidget);

    await tester.tap(
      find
          .descendant(
            of: find.byKey(const ValueKey<String>('graph-channel-object')),
            matching: find.byType(GestureDetector),
          )
          .last,
    );
    await tester.pump();
    expect(action?.nodeId, 'object');
  });

  testWidgets('key selection and movement emit graph-space transactions', (
    tester,
  ) async {
    final viewport = BlenderGraphViewportController(
      const BlenderGraphViewport(
        frameStart: 0,
        frameEnd: 100,
        valueMin: -1,
        valueMax: 1,
      ),
    );
    addTearDown(viewport.dispose);
    Set<BlenderGraphKeyframeRef>? selection;
    BlenderGraphKeyframeMove? movement;
    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 800,
          height: 400,
          child: BlenderCurveEditor(
            channels: const <BlenderCurveChannel>[curve],
            showChannels: false,
            viewportController: viewport,
            onSelectionChanged: (value) => selection = value,
            onKeyframeMoved: (value) => movement = value,
          ),
        ),
      ),
    );

    final canvasRect = tester.getRect(
      find.byKey(const ValueKey<String>('graph-static-canvas')),
    );
    final keyPosition =
        canvasRect.topLeft +
        Offset(
          38 + (canvasRect.width - 38) / 2,
          28 + (canvasRect.height - 28) / 2,
        );
    await tester.tapAt(keyPosition);
    await tester.pump();
    expect(selection, <BlenderGraphKeyframeRef>{
      const BlenderGraphKeyframeRef('x', 'x-50'),
    });

    await tester.dragFrom(keyPosition, const Offset(76.2, -37.2));
    await tester.pump();
    expect(movement?.keyframe, const BlenderGraphKeyframeRef('x', 'x-50'));
    expect(
      movement?.frame,
      closeTo(50 + 76.2 / (canvasRect.width - 38) * 100, .02),
    );
    expect(
      movement?.value,
      closeTo(37.2 / (canvasRect.height - 28) * 2, .02),
    );
  });

  testWidgets('playhead listenable repaints without rebuilding graph canvas', (
    tester,
  ) async {
    final playback = BlenderPlaybackController(initialFrame: 24);
    addTearDown(playback.dispose);
    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 800,
          height: 400,
          child: BlenderCurveEditor(
            channels: const <BlenderCurveChannel>[curve],
            showChannels: false,
            currentFrameListenable: playback,
          ),
        ),
      ),
    );
    final finder = find.byKey(const ValueKey<String>('graph-overlay-canvas'));
    final painter = tester.widget<CustomPaint>(finder).painter;
    playback.seek(48);
    await tester.pump();
    expect(tester.widget<CustomPaint>(finder).painter, same(painter));
  });
}
