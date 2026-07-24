import 'dart:math' as math;

import 'package:blender_ui_daw/blender_ui_daw.dart';

DawProject buildDemoProject() {
  final waveform = DawWaveform(
    peaks: List<double>.generate(1000, (index) {
      final envelope = .25 + .75 * math.sin(index / 190).abs();
      return math.sin(index * .17) *
          envelope *
          (.7 + .3 * math.sin(index * .037));
    }, growable: false),
  );
  return DawProject(
    id: 'midnight-drive',
    name: 'Midnight Drive',
    lengthBeats: 128,
    tempoMap: const <DawTempoPoint>[
      DawTempoPoint(beat: 0, bpm: 124),
      DawTempoPoint(beat: 96, bpm: 126),
    ],
    loopEnabled: true,
    loopStartBeat: 16,
    loopEndBeat: 32,
    tracks: <DawTrack>[
      DawTrack(
        id: 'drums',
        name: 'Drum Machine',
        type: DawTrackType.instrument,
        colorValue: 0xFFE07A45,
        armed: true,
        clips: <DawClip>[
          DawMidiClip(
            id: 'drum-pattern-a',
            name: 'Pattern 1',
            startBeat: 0,
            lengthBeats: 16,
            colorValue: 0xFFE07A45,
            looped: true,
            notes: _drumNotes(),
          ),
          DawMidiClip(
            id: 'drum-pattern-b',
            name: 'Pattern 2',
            startBeat: 16,
            lengthBeats: 16,
            colorValue: 0xFFE07A45,
            notes: _drumNotes(accent: true),
          ),
          DawMidiClip(
            id: 'drum-fill',
            name: 'Fill',
            startBeat: 60,
            lengthBeats: 4,
            colorValue: 0xFFF09A58,
          ),
        ],
        automation: <DawAutomationLane>[
          DawAutomationLane(
            id: 'drum-filter',
            name: 'Filter Cutoff',
            parameterId: 'internal.auto-filter.frequency',
            colorValue: 0xFFE07A45,
            points: <DawAutomationPoint>[
              const DawAutomationPoint(id: 'df-1', beat: 0, value: .25),
              const DawAutomationPoint(id: 'df-2', beat: 16, value: .72),
              const DawAutomationPoint(id: 'df-3', beat: 32, value: .42),
              const DawAutomationPoint(id: 'df-4', beat: 64, value: .9),
            ],
          ),
        ],
        plugins: <DawPluginSlot>[
          DawPluginSlot(
            id: 'drum-filter-device',
            pluginId: 'internal:auto-filter',
            name: 'Auto Filter',
          ),
          DawPluginSlot(
            id: 'drum-comp',
            pluginId: 'internal:compressor',
            name: 'Compressor',
          ),
        ],
      ),
      DawTrack(
        id: 'bass',
        name: 'Neon Bass',
        type: DawTrackType.instrument,
        colorValue: 0xFF6B8EE8,
        clips: <DawClip>[
          DawMidiClip(
            id: 'bass-midi',
            name: 'Bassline A',
            startBeat: 8,
            lengthBeats: 24,
            colorValue: 0xFF6B8EE8,
            notes: _bassNotes(),
          ),
          DawMidiClip(
            id: 'bass-midi-b',
            name: 'Bassline B',
            startBeat: 40,
            lengthBeats: 24,
            colorValue: 0xFF6B8EE8,
            notes: _bassNotes(transpose: 5),
          ),
        ],
        automation: <DawAutomationLane>[
          DawAutomationLane(
            id: 'bass-resonance',
            name: 'Resonance',
            parameterId: 'internal.eq-eight.band-2',
            colorValue: 0xFF6B8EE8,
            points: <DawAutomationPoint>[
              const DawAutomationPoint(id: 'br-1', beat: 0, value: .2),
              const DawAutomationPoint(id: 'br-2', beat: 24, value: .6),
              const DawAutomationPoint(id: 'br-3', beat: 48, value: .35),
              const DawAutomationPoint(id: 'br-4', beat: 72, value: .78),
            ],
          ),
        ],
        plugins: <DawPluginSlot>[
          DawPluginSlot(
            id: 'bass-eq-device',
            pluginId: 'internal:eq-eight',
            name: 'EQ Eight',
          ),
        ],
      ),
      DawTrack(
        id: 'guitar',
        name: 'Guitar Loop',
        type: DawTrackType.audio,
        colorValue: 0xFF55A879,
        clips: <DawClip>[
          DawAudioClip(
            id: 'guitar-audio-a',
            name: 'Guitar Take 03',
            startBeat: 16,
            lengthBeats: 16,
            sourcePath: 'Audio/Guitar Take 03.wav',
            waveform: waveform,
            colorValue: 0xFF55A879,
            fadeInBeats: .5,
            fadeOutBeats: .75,
          ),
          DawAudioClip(
            id: 'guitar-audio-b',
            name: 'Guitar Take 03',
            startBeat: 48,
            lengthBeats: 16,
            sourcePath: 'Audio/Guitar Take 03.wav',
            waveform: waveform,
            colorValue: 0xFF55A879,
            offsetBeats: 4,
          ),
        ],
        plugins: <DawPluginSlot>[
          DawPluginSlot(
            id: 'guitar-filter-device',
            pluginId: 'internal:auto-filter',
            name: 'Auto Filter',
          ),
          DawPluginSlot(id: 'delay', pluginId: 'internal:delay', name: 'Delay'),
        ],
      ),
      DawTrack(
        id: 'vocal',
        name: 'Lead Vocal',
        type: DawTrackType.audio,
        colorValue: 0xFFB56DDD,
        volume: .9,
        clips: <DawClip>[
          DawAudioClip(
            id: 'vocal-audio',
            name: 'Verse Comp',
            startBeat: 32,
            lengthBeats: 32,
            sourcePath: 'Audio/Lead Vocal Comp.wav',
            waveform: waveform,
            colorValue: 0xFFB56DDD,
          ),
        ],
      ),
      DawTrack(
        id: 'reverb',
        name: 'Reverb Bus',
        type: DawTrackType.bus,
        colorValue: 0xFF47A6B8,
        volume: .65,
        plugins: <DawPluginSlot>[
          DawPluginSlot(
            id: 'room',
            pluginId: 'internal:reverb',
            name: 'Reverb',
          ),
        ],
      ),
      DawTrack(
        id: 'master',
        name: 'Master',
        type: DawTrackType.master,
        colorValue: 0xFFE4C34C,
        volume: .82,
        plugins: <DawPluginSlot>[
          DawPluginSlot(
            id: 'master-dynamics-device',
            pluginId: 'internal:dynamics-compressor',
            name: 'Dynamics Compressor',
          ),
        ],
      ),
    ],
  );
}

List<DawMidiNote> _drumNotes({bool accent = false}) => <DawMidiNote>[
  for (var step = 0; step < 64; step++)
    if (step % 4 == 0 || step % 8 == 4 || (accent && step % 16 == 14))
      DawMidiNote(
        id: 'drum-$accent-$step',
        pitch: step % 8 == 4 ? 38 : (step % 16 == 14 ? 42 : 36),
        startBeat: step / 4,
        lengthBeats: .18,
        velocity: step % 16 == 0 ? 1 : .72,
      ),
];

List<DawMidiNote> _bassNotes({int transpose = 0}) {
  const pitches = <int>[40, 40, 43, 38, 40, 47, 43, 38];
  return <DawMidiNote>[
    for (var index = 0; index < 24; index++)
      DawMidiNote(
        id: 'bass-$transpose-$index',
        pitch: pitches[index % pitches.length] + transpose,
        startBeat: index.toDouble(),
        lengthBeats: index % 4 == 3 ? .75 : .48,
        velocity: .68 + (index % 3) * .1,
      ),
  ];
}
