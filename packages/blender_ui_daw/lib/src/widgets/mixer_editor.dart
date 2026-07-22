import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

import '../controllers/session_controller.dart';
import '../model/project.dart';
import 'editor_shared.dart';

class DawMixerEditor extends StatefulWidget {
  const DawMixerEditor({super.key, required this.session});

  final DawSessionController session;

  @override
  State<DawMixerEditor> createState() => _DawMixerEditorState();
}

class _DawMixerEditorState extends State<DawMixerEditor> {
  bool _compact = false;
  bool _showMeters = true;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.session,
    builder: (context, _) => BlenderEditorFrame(
      child: Column(
        children: <Widget>[
          DawEditorHeader(
            title: 'Mixer',
            menus: const <String>['View', 'Select', 'Channel', 'Routing'],
            actions: <Widget>[
              BlenderButton(
                label: 'Compact',
                selected: _compact,
                onPressed: () => setState(() => _compact = !_compact),
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.volume,
                selected: _showMeters,
                tooltip: 'Show Meters',
                onPressed: () => setState(() => _showMeters = !_showMeters),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                for (final track in widget.session.project.tracks)
                  _DawChannelStrip(
                    track: track,
                    width: _compact ? 70 : 92,
                    showMeter: _showMeters,
                    selected: widget.session.selection.trackId == track.id,
                    onSelected: () => widget.session.selectTrack(track.id),
                    onVolumeChanged: (value) =>
                        widget.session.setTrackVolume(track.id, value),
                    onPanChanged: (value) =>
                        widget.session.setTrackPan(track.id, value),
                    onMute: () => widget.session.toggleTrackMute(track.id),
                    onSolo: () => widget.session.toggleTrackSolo(track.id),
                    onArm: () => widget.session.toggleTrackArm(track.id),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _DawChannelStrip extends StatelessWidget {
  const _DawChannelStrip({
    required this.track,
    required this.width,
    required this.showMeter,
    required this.selected,
    required this.onSelected,
    required this.onVolumeChanged,
    required this.onPanChanged,
    required this.onMute,
    required this.onSolo,
    required this.onArm,
  });

  final DawTrack track;
  final double width;
  final bool showMeter;
  final bool selected;
  final VoidCallback onSelected;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<double> onPanChanged;
  final VoidCallback onMute;
  final VoidCallback onSolo;
  final VoidCallback onArm;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSelected,
      child: Container(
        key: ValueKey<String>('daw-mixer-channel-${track.id}'),
        width: width,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: selected
              ? theme.colors.selection
              : theme.colors.panelBackground,
          border: Border(right: BorderSide(color: theme.colors.border)),
        ),
        child: Column(
          children: <Widget>[
            Container(height: 5, color: Color(track.colorValue)),
            const SizedBox(height: 5),
            Text(
              track.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.label,
            ),
            const SizedBox(height: 6),
            BlenderSlider(
              value: (track.pan + 1) / 2,
              onChanged: (value) => onPanChanged(value * 2 - 1),
            ),
            Text(
              track.pan.abs() < .01
                  ? 'C'
                  : '${track.pan < 0 ? 'L' : 'R'} ${(track.pan.abs() * 100).round()}',
              style: theme.textTheme.caption,
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (showMeter) ...<Widget>[
                    _DawLevelMeter(level: track.muted ? 0 : track.volume * .82),
                    const SizedBox(width: 6),
                  ],
                  RotatedBox(
                    quarterTurns: 3,
                    child: SizedBox(
                      width: 150,
                      child: BlenderSlider(
                        value: track.volume,
                        onChanged: onVolumeChanged,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${(track.volume * 12 - 12).toStringAsFixed(1)} dB',
              style: theme.textTheme.caption,
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                Expanded(
                  child: BlenderButton(
                    label: 'M',
                    selected: track.muted,
                    onPressed: onMute,
                    padding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: BlenderButton(
                    label: 'S',
                    selected: track.solo,
                    onPressed: onSolo,
                    padding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: BlenderButton(
                    label: 'R',
                    selected: track.armed,
                    onPressed: onArm,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${track.plugins.length} FX', style: theme.textTheme.caption),
          ],
        ),
      ),
    );
  }
}

class _DawLevelMeter extends StatelessWidget {
  const _DawLevelMeter({required this.level});
  final double level;

  @override
  Widget build(BuildContext context) => Container(
    width: 9,
    decoration: BoxDecoration(
      color: const Color(0xFF151515),
      border: Border.all(color: BlenderTheme.of(context).colors.border),
    ),
    padding: const EdgeInsets.all(1),
    child: Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: level.clamp(0, 1),
        widthFactor: 1,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: <Color>[
                Color(0xFF49B65B),
                Color(0xFFE9CB42),
                Color(0xFFDC4A42),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
