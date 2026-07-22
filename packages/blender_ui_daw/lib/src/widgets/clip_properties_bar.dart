import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

import '../controllers/session_controller.dart';
import '../model/project.dart';

class DawClipPropertiesBar extends StatelessWidget {
  const DawClipPropertiesBar({super.key, required this.session});

  final DawSessionController session;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: session,
    builder: (context, _) {
      final track = session.selectedTrack;
      final clip = session.selectedClip;
      if (track == null || clip == null) return const SizedBox.shrink();
      final theme = BlenderTheme.of(context);
      return Container(
        height: 30 * theme.density.interfaceScale,
        decoration: BoxDecoration(
          color: theme.colors.panelHeader,
          border: Border(bottom: BorderSide(color: theme.colors.border)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 120,
                child: Text(
                  clip.name,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.label,
                ),
              ),
              _number(
                'Start',
                clip.startBeat,
                (value) =>
                    session.editClip(track.id, clip.id, startBeat: value),
              ),
              _number(
                'Length',
                clip.lengthBeats,
                (value) =>
                    session.editClip(track.id, clip.id, lengthBeats: value),
              ),
              _number(
                'Offset',
                clip.offsetBeats,
                (value) =>
                    session.editClip(track.id, clip.id, offsetBeats: value),
              ),
              _number(
                'Source BPM',
                clip.sourceTempo,
                (value) =>
                    session.editClip(track.id, clip.id, sourceTempo: value),
                width: 136,
              ),
              _number(
                'Rate',
                clip.playbackRate,
                (value) =>
                    session.editClip(track.id, clip.id, playbackRate: value),
              ),
              BlenderButton(
                label: 'Trim',
                selected: session.clipResizeMode == DawClipResizeMode.trim,
                onPressed: () =>
                    session.setClipResizeMode(DawClipResizeMode.trim),
              ),
              BlenderButton(
                label: 'Stretch',
                selected: session.clipResizeMode == DawClipResizeMode.stretch,
                onPressed: () =>
                    session.setClipResizeMode(DawClipResizeMode.stretch),
              ),
              const SizedBox(width: 4),
              Text('Loop', style: theme.textTheme.caption),
              BlenderCheckbox(
                value: clip.looped,
                onChanged: (value) =>
                    session.editClip(track.id, clip.id, looped: value),
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _number(
    String label,
    double value,
    ValueChanged<double> onChanged, {
    double width = 96,
  }) => SizedBox(
    width: width,
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(label),
        ),
        Expanded(
          child: BlenderNumberField(
            value: value,
            step: .25,
            decimalDigits: 2,
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}
