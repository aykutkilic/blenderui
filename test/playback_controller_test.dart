import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('playback controller keeps free seek and bounded stepping distinct', () {
    final controller = BlenderPlaybackController(
      initialFrame: 24,
      rangeStart: 1,
      rangeEnd: 48,
    );
    addTearDown(controller.dispose);

    controller.seek(60);
    expect(controller.currentFrame, 60);

    controller.stepForward();
    expect(controller.currentFrame, 48);
    controller.stepBackward(100);
    expect(controller.currentFrame, 1);
  });

  test('range and transport mutations notify once per effective change', () {
    final controller = BlenderPlaybackController(initialFrame: 24);
    addTearDown(controller.dispose);
    var notifications = 0;
    controller.addListener(() => notifications++);

    controller.setRange(10, 20);
    expect(controller.currentFrame, 20);
    expect(notifications, 1);

    controller.setRange(10, 20);
    expect(notifications, 1);
    controller.togglePlaying();
    controller.toggleRecording();
    expect(controller.playing, isTrue);
    expect(controller.recording, isTrue);
    expect(notifications, 3);
  });

  testWidgets('playback builder limits rebuilds to its own subtree', (
    tester,
  ) async {
    final controller = BlenderPlaybackController(initialFrame: 1);
    addTearDown(controller.dispose);
    var outsideBuilds = 0;
    var playbackBuilds = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            outsideBuilds++;
            return BlenderPlaybackBuilder(
              controller: controller,
              builder: (context, playback, child) {
                playbackBuilds++;
                return Text('${playback.currentFrame}');
              },
            );
          },
        ),
      ),
    );

    controller.seek(2);
    await tester.pump();
    expect(outsideBuilds, 1);
    expect(playbackBuilds, 2);
    expect(find.text('2.0'), findsOneWidget);
  });
}
