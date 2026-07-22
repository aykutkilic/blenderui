import 'package:blender_ui_daw/blender_ui_daw.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DawProject project() => const DawProject(
    id: 'test',
    name: 'Test',
    lengthBeats: 32,
    tracks: <DawTrack>[
      DawTrack(
        id: 'midi',
        name: 'MIDI',
        type: DawTrackType.midi,
        clips: <DawClip>[
          DawMidiClip(
            id: 'clip',
            name: 'Pattern',
            startBeat: 0,
            lengthBeats: 8,
            notes: <DawMidiNote>[
              DawMidiNote(id: 'note', pitch: 60, startBeat: 0, lengthBeats: 1),
            ],
          ),
        ],
        automation: <DawAutomationLane>[
          DawAutomationLane(
            id: 'cutoff',
            name: 'Cutoff',
            parameterId: 'cutoff',
            points: <DawAutomationPoint>[
              DawAutomationPoint(id: 'point', beat: 0, value: .2),
            ],
          ),
        ],
      ),
    ],
  );

  test('clip and note edits snap and participate in history', () {
    final session = DawSessionController(initialProject: project());
    addTearDown(session.dispose);

    session.moveClip('midi', 'clip', 2.18);
    final moved = session.project.tracks.single.clips.single;
    expect(moved.startBeat, 2.25);

    session.moveMidiNote('midi', 'clip', 'note', startBeat: 1.12, pitch: 64);
    final note = (session.project.tracks.single.clips.single as DawMidiClip)
        .notes
        .single;
    expect(note.startBeat, 1);
    expect(note.pitch, 64);

    session.undo();
    final restored = (session.project.tracks.single.clips.single as DawMidiClip)
        .notes
        .single;
    expect(restored.pitch, 60);
  });

  test('automation and mixer changes remain immutable', () {
    final initial = project();
    final session = DawSessionController(initialProject: initial);
    addTearDown(session.dispose);

    session.updateAutomationPoint(
      'midi',
      'cutoff',
      'point',
      beat: 3.2,
      value: .75,
    );
    session.setTrackVolume('midi', .4);

    expect(initial.tracks.single.volume, .8);
    expect(session.project.tracks.single.volume, .4);
    expect(
      session.project.tracks.single.automation.single.points.single.beat,
      3.25,
    );
  });

  test('split and duplicate clips remain undoable', () {
    final session = DawSessionController(initialProject: project());
    addTearDown(session.dispose);
    session.selectClip('midi', 'clip');

    session.splitSelectedClip(3);
    expect(session.project.tracks.single.clips, hasLength(2));
    expect(session.project.tracks.single.clips.first.lengthBeats, 3);
    expect(session.project.tracks.single.clips.last.startBeat, 3);

    session.duplicateSelectedClip();
    expect(session.project.tracks.single.clips, hasLength(3));
    session.undo();
    expect(session.project.tracks.single.clips, hasLength(2));
  });

  test('delete selection prioritizes notes and automation points', () {
    final session = DawSessionController(initialProject: project());
    addTearDown(session.dispose);

    session.selectClip('midi', 'clip');
    session.selectNotes(<String>{'note'});
    session.deleteSelection();
    expect(
      (session.project.tracks.single.clips.single as DawMidiClip).notes,
      isEmpty,
    );

    session.selectAutomation('midi', 'cutoff', pointId: 'point');
    session.deleteSelection();
    expect(session.project.tracks.single.automation.single.points, isEmpty);
  });

  test(
    'clip stretch, track lanes, loops, and effect chains are project state',
    () {
      final session = DawSessionController(initialProject: project());
      addTearDown(session.dispose);

      session.setClipResizeMode(DawClipResizeMode.stretch);
      session.resizeClip('midi', 'clip', 16);
      final stretched = session.project.tracks.single.clips.single;
      expect(stretched.lengthBeats, 16);
      expect(stretched.playbackRate, .5);

      session.setTrackHeightScale('midi', 2.5);
      session.toggleTrackAutomation('midi');
      expect(session.project.tracks.single.heightScale, 2.5);
      expect(session.project.tracks.single.automationExpanded, isTrue);

      session.setLoop(enabled: true, startBeat: 4, endBeat: 12);
      expect(session.project.loopEnabled, isTrue);
      expect(session.project.loopStartBeat, 4);

      session.addPlugin(
        'master',
        const DawPluginSlot(id: 'eq', pluginId: 'eq', name: 'EQ'),
      );
      session.addPlugin(
        'master',
        const DawPluginSlot(
          id: 'limiter',
          pluginId: 'limiter',
          name: 'Limiter',
        ),
      );
      session.movePlugin('master', 1, 0);
      session.setPluginWet('master', 'eq', .4);
      expect(session.project.master.plugins.first.id, 'limiter');
      expect(session.project.master.plugins.last.wet, .4);
    },
  );
}
