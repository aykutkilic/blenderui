import 'package:blender_ui/blender_ui.dart';
import 'package:blender_ui_daw/blender_ui_daw.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('built-in catalog creates device-specific parameter sets', () async {
    final host = DawInMemoryPluginHost();
    addTearDown(host.dispose);

    expect(
      host.catalog.map((item) => item.name),
      containsAll(<String>[
        'Auto Filter',
        'EQ Eight',
        'Compressor',
        'Dynamics Compressor',
        'Delay',
        'Reverb',
      ]),
    );

    final equalizer = await host.instantiate('internal:eq-eight');
    expect(equalizer.parameters, hasLength(8));
    expect(equalizer.parameters.first.name, 'Band 1');

    await host.setEnabled(equalizer.instanceId, false);
    expect(host.instances.single.enabled, isFalse);
  });

  testWidgets('browser devices drag into an exact chain insertion point', (
    tester,
  ) async {
    final host = DawInMemoryPluginHost();
    final engine = DawInMemoryAudioEngine();
    final session = DawSessionController(
      initialProject: DawProject(
        id: 'device-chain',
        name: 'Device Chain',
        lengthBeats: 16,
        tracks: <DawTrack>[],
        master: DawTrack(
          id: 'master',
          name: 'Master',
          type: DawTrackType.audio,
        ),
      ),
    );
    addTearDown(host.dispose);
    addTearDown(engine.dispose);
    addTearDown(session.dispose);

    await tester.binding.setSurfaceSize(const Size(1200, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      BlenderApp(
        home: Row(
          children: <Widget>[
            SizedBox(width: 330, child: DawPluginBrowser(host: host)),
            Expanded(
              child: DawEffectChainEditor(
                session: session,
                host: host,
                audioEngine: engine,
              ),
            ),
          ],
        ),
      ),
    );

    final source = find.text('Auto Filter');
    final target = find.byKey(
      const ValueKey<String>('daw-effect-chain-drop-0'),
    );
    expect(source, findsOneWidget);
    expect(target, findsOneWidget);

    final gesture = await tester.startGesture(tester.getCenter(source));
    await tester.pump();
    await gesture.moveBy(const Offset(24, 0));
    await tester.pump();
    await gesture.moveTo(tester.getCenter(target));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(session.project.master.plugins.single.name, 'Auto Filter');
    expect(host.instances.single.descriptor.id, 'internal:auto-filter');
  });
}
