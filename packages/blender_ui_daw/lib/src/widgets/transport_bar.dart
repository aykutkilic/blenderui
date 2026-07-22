import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

import '../controllers/session_controller.dart';
import '../controllers/transport_controller.dart';

class DawTransportBar extends StatelessWidget {
  const DawTransportBar({
    super.key,
    required this.session,
    required this.transport,
    this.onSave,
    this.onMetronome,
    this.metronomeEnabled = true,
  });

  final DawSessionController session;
  final DawTransportController transport;
  final VoidCallback? onSave;
  final VoidCallback? onMetronome;
  final bool metronomeEnabled;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge(<Listenable>[session, transport]),
    builder: (context, _) {
      final theme = BlenderTheme.of(context);
      final beat = session.playback.currentFrame;
      final signature = session.project.timeSignature;
      final bar = beat ~/ signature.numerator + 1;
      final beatInBar = beat.floor() % signature.numerator + 1;
      final tick = ((beat - beat.floor()) * 960).round();
      return Container(
        key: const ValueKey<String>('daw-transport-bar'),
        height: 42 * theme.density.interfaceScale,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: theme.colors.topBar,
          border: Border(bottom: BorderSide(color: theme.colors.border)),
        ),
        child: Row(
          children: <Widget>[
            BlenderIconButton(
              glyph: BlenderGlyph.save,
              tooltip: 'Save Project',
              onPressed: onSave,
            ),
            const SizedBox(width: 8),
            BlenderPlaybackControls(
              playing: transport.playing,
              recording: transport.recording,
              onFirst: session.playback.jumpToStart,
              onPrevious: () =>
                  session.playback.stepBackward(session.snapBeats),
              onPlay: transport.togglePlay,
              onNext: () => session.playback.stepForward(session.snapBeats),
              onLast: session.playback.jumpToEnd,
              onRecord: transport.toggleRecord,
            ),
            const SizedBox(width: 8),
            BlenderButton(
              label: 'Metronome',
              selected: metronomeEnabled,
              onPressed: onMetronome,
            ),
            BlenderButton(
              label: 'Loop',
              selected: session.project.loopEnabled,
              onPressed: () =>
                  session.setLoop(enabled: !session.project.loopEnabled),
            ),
            BlenderIconButton(
              glyph: BlenderGlyph.stepBack,
              tooltip: 'Set Loop Start to Playhead',
              onPressed: () => session.setLoop(
                enabled: true,
                startBeat: session.playback.currentFrame,
              ),
            ),
            BlenderIconButton(
              glyph: BlenderGlyph.stepForward,
              tooltip: 'Set Loop End to Playhead',
              onPressed: () => session.setLoop(
                enabled: true,
                endBeat: session.playback.currentFrame,
              ),
            ),
            const SizedBox(width: 8),
            _DawTransportReadout(
              label: 'POSITION',
              value: '$bar.$beatInBar.${tick.toString().padLeft(3, '0')}',
            ),
            const SizedBox(width: 5),
            _DawTransportReadout(
              label: 'TEMPO',
              value: '${session.project.tempoAt(beat).toStringAsFixed(1)} BPM',
            ),
            const SizedBox(width: 5),
            _DawTransportReadout(
              label: 'SIGNATURE',
              value: '${signature.numerator}/${signature.denominator}',
            ),
            const Spacer(),
            Text(
              '${(session.project.sampleRate / 1000).toStringAsFixed(1)} kHz  •  24-bit',
              style: theme.textTheme.caption.copyWith(
                color: theme.colors.foregroundMuted,
              ),
            ),
            const SizedBox(width: 8),
            _DawCpuMeter(value: transport.playing ? .24 : .07),
          ],
        ),
      );
    },
  );
}

class _DawTransportReadout extends StatelessWidget {
  const _DawTransportReadout({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 84),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colors.textField,
        border: Border.all(color: theme.colors.borderSubtle),
        borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.caption.copyWith(
              fontSize: 8,
              color: theme.colors.foregroundMuted,
            ),
          ),
          Text(value, style: theme.textTheme.label),
        ],
      ),
    );
  }
}

class _DawCpuMeter extends StatelessWidget {
  const _DawCpuMeter({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 80,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'DSP ${(value * 100).round()}%',
          style: BlenderTheme.of(context).textTheme.caption,
        ),
        BlenderProgressBar(value: value),
      ],
    ),
  );
}
