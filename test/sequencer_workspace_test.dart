import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('combined sequencer exposes registered editor regions', (
    tester,
  ) async {
    final playback = BlenderPlaybackController(initialFrame: 12);
    addTearDown(playback.dispose);
    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 960,
          height: 620,
          child: BlenderVideoSequencerWorkspace(
            headerState: const BlenderSequencerEditorHeaderState(),
            strips: const <BlenderSequencerStrip>[
              BlenderSequencerStrip(
                id: 'movie',
                label: 'Shot.001',
                start: 1,
                end: 48,
                channel: 0,
                type: BlenderSequencerStripType.movie,
              ),
              BlenderSequencerStrip(
                id: 'sound',
                label: 'Dialogue',
                start: 1,
                end: 48,
                channel: 1,
                type: BlenderSequencerStripType.sound,
                showWaveform: true,
              ),
            ],
            start: 1,
            end: 96,
            currentFrameListenable: playback,
            footer: const SizedBox(height: 28),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('sequencer-preview-region')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('sequencer-tool-header-region')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('sequencer-channels-region')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('sequencer-window-region')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('sequencer-footer-region')),
      findsOneWidget,
    );
  });
}
