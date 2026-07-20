import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const model = BlenderTimelineModel(
    start: 1,
    end: 120,
    currentFrame: 24,
    tracks: <BlenderTimelineTrack>[
      BlenderTimelineTrack(
        id: 'cube',
        label: 'Cube',
        keyframes: <BlenderTimelineKeyframe>[
          BlenderTimelineKeyframe(1),
          BlenderTimelineKeyframe(24),
        ],
      ),
      BlenderTimelineTrack(id: 'camera', label: 'Camera'),
    ],
  );

  testWidgets('Timeline owns native scrub, channels, and Summary regions', (
    tester,
  ) async {
    double? changedFrame;
    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 1200,
          height: 500,
          child: BlenderTimeline(
            model: model,
            onCurrentFrameChanged: (value) => changedFrame = value,
          ),
        ),
      ),
    );

    final channels = find.byKey(
      const ValueKey<String>('timeline-channels-region'),
    );
    final window = find.byKey(const ValueKey<String>('timeline-window-region'));
    expect(tester.getSize(channels).width, 240);
    expect(tester.getTopLeft(window).dx, 240);
    expect(
      tester
          .getSize(
            find.byKey(const ValueKey<String>('timeline-channel-search')),
          )
          .height,
      28,
    );
    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Cube'), findsNothing);
    expect(find.byType(BlenderView3dToolShelf), findsNothing);

    await tester.tapAt(tester.getCenter(window));
    expect(changedFrame, closeTo(60.5, .01));
  });

  testWidgets('Timeline header keeps Blender source control ordering', (
    tester,
  ) async {
    await tester.pumpWidget(
      const BlenderApp(
        home: SizedBox(
          width: 1200,
          child: BlenderDopeSheetEditorHeader(
            editorType: BlenderEditorType.timeline,
            keyPrefix: 'timeline-test',
            frame: 24,
            frameMax: 120,
            rangeStart: 1,
            rangeEnd: 120,
          ),
        ),
      ),
    );

    double x(String suffix) => tester
        .getTopLeft(find.byKey(ValueKey<String>('timeline-test-$suffix')))
        .dx;
    expect(x('view-menu'), lessThan(x('playback-button')));
    expect(x('playback-button'), lessThan(x('autokey-toggle-button')));
    expect(x('autokey-toggle-button'), lessThan(x('time-jump-controls')));
    expect(x('time-jump-controls'), lessThan(x('playhead-snap-toggle-button')));
    expect(
      x('playhead-snap-toggle-button'),
      lessThan(x('current-frame-field')),
    );
    expect(x('current-frame-field'), lessThan(x('range-start-field')));
    expect(x('range-start-field'), lessThan(x('range-end-field')));
  });

  testWidgets('Timeline scrub and channel regions follow resolution scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: BlenderTheme(
          data: const BlenderThemeData().copyWith(
            density: const BlenderDensity().scaled(1.5),
          ),
          child: SizedBox(
            width: 1200,
            height: 500,
            child: BlenderTimeline(model: model, onCurrentFrameChanged: (_) {}),
          ),
        ),
      ),
    );

    expect(
      tester
          .getSize(
            find.byKey(const ValueKey<String>('timeline-channels-region')),
          )
          .width,
      360,
    );
    expect(
      tester
          .getSize(
            find.byKey(const ValueKey<String>('timeline-channel-search')),
          )
          .height,
      42,
    );
  });

  testWidgets('scrubbing repaints only the current-frame overlay', (
    tester,
  ) async {
    var currentFrame = 24.0;
    late StateSetter setHostState;

    await tester.pumpWidget(
      BlenderApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            setHostState = setState;
            return SizedBox(
              width: 1200,
              height: 500,
              child: BlenderTimeline(
                model: BlenderTimelineModel(
                  start: 1,
                  end: 120,
                  currentFrame: currentFrame,
                  tracks: model.tracks,
                ),
                onCurrentFrameChanged: (_) {},
              ),
            );
          },
        ),
      ),
    );

    CustomPainter painter(String key) =>
        tester.widget<CustomPaint>(find.byKey(ValueKey<String>(key))).painter!;
    final oldStatic = painter('timeline-static-canvas');
    final oldPlayhead = painter('timeline-playhead-canvas');

    setHostState(() => currentFrame = 25);
    await tester.pump();

    expect(painter('timeline-static-canvas').shouldRepaint(oldStatic), isFalse);
    expect(
      painter('timeline-playhead-canvas').shouldRepaint(oldPlayhead),
      isTrue,
    );
  });

  testWidgets('data revision invalidates the prepared static keylist', (
    tester,
  ) async {
    var dataRevision = 0;
    late StateSetter setHostState;
    await tester.pumpWidget(
      BlenderApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            setHostState = setState;
            return SizedBox(
              width: 1200,
              height: 500,
              child: BlenderTimeline(
                model: BlenderTimelineModel(
                  start: 1,
                  end: 120,
                  currentFrame: 24,
                  tracks: model.tracks,
                  dataRevision: dataRevision,
                ),
                onCurrentFrameChanged: (_) {},
              ),
            );
          },
        ),
      ),
    );

    final finder = find.byKey(const ValueKey<String>('timeline-static-canvas'));
    final oldPainter = tester.widget<CustomPaint>(finder).painter!;
    setHostState(() => dataRevision++);
    await tester.pump();

    expect(
      tester.widget<CustomPaint>(finder).painter!.shouldRepaint(oldPainter),
      isTrue,
    );
  });

  testWidgets('playback listenable advances without rebuilding Timeline', (
    tester,
  ) async {
    final playback = BlenderPlaybackController(initialFrame: 24);
    addTearDown(playback.dispose);
    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 1200,
          height: 500,
          child: BlenderTimeline(
            model: model,
            currentFrameListenable: playback,
            onCurrentFrameChanged: playback.seek,
          ),
        ),
      ),
    );

    final finder = find.byKey(
      const ValueKey<String>('timeline-playhead-canvas'),
    );
    final painter = tester.widget<CustomPaint>(finder).painter;
    playback.seek(48);
    await tester.pump();

    expect(tester.widget<CustomPaint>(finder).painter, same(painter));
  });
}
