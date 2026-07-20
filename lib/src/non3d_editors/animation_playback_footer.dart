part of '../non3d_editors.dart';

/// Reusable playback footer shared by animation editors whose source header
/// delegates transport controls to a footer region (Graph and NLA).
class BlenderAnimationPlaybackFooter extends StatelessWidget {
  const BlenderAnimationPlaybackFooter({
    super.key,
    required this.state,
    this.onStateChanged,
    this.playing = false,
    this.onFirst,
    this.onPrevious,
    this.onPlay,
    this.onNext,
    this.onLast,
    this.onRecord,
    this.frame = 1,
    this.frameMin = 1,
    this.frameMax = 250,
    this.onFrameChanged,
    this.keyPrefix = 'animation-playback',
    this.background,
    this.height = 30,
  });

  final BlenderDopeSheetEditorHeaderState state;
  final ValueChanged<BlenderDopeSheetEditorHeaderState>? onStateChanged;
  final bool playing;
  final VoidCallback? onFirst;
  final VoidCallback? onPrevious;
  final VoidCallback? onPlay;
  final VoidCallback? onNext;
  final VoidCallback? onLast;
  final VoidCallback? onRecord;
  final double frame;
  final double frameMin;
  final double frameMax;
  final ValueChanged<double>? onFrameChanged;
  final String keyPrefix;
  final Color? background;
  final double height;

  Key _key(String suffix) => ValueKey<String>('$keyPrefix-$suffix');

  @override
  Widget build(BuildContext context) => BlenderToolbar(
    key: _key('footer'),
    height: height,
    scrollable: true,
    background: background,
    children: <Widget>[
      BlenderPopover(
        key: _key('settings-button'),
        child: const IgnorePointer(
          child: BlenderButton(
            label: 'Playback',
            variant: BlenderButtonVariant.topBar,
            onPressed: _noopAnimationHeaderControl,
          ),
        ),
        popover: (context, close) =>
            _blenderAnimationPlaybackPanel(context, state, onStateChanged),
      ),
      BlenderPlaybackControls(
        playing: playing,
        onFirst: onFirst,
        onPrevious: onPrevious,
        onPlay: onPlay,
        onNext: onNext,
        onLast: onLast,
        onRecord: onRecord,
      ),
      SizedBox(
        width: 92,
        child: BlenderNumberField(
          value: frame,
          min: frameMin,
          max: frameMax,
          step: 1,
          decimalDigits: 0,
          onChanged: (value) => onFrameChanged?.call(value),
        ),
      ),
      BlenderIconButton(
        key: _key('playhead-snap-toggle-button'),
        glyph: BlenderGlyph.snap,
        selected: state.playheadSnapping,
        onPressed: () => onStateChanged?.call(
          state.copyWith(playheadSnapping: !state.playheadSnapping),
        ),
        tooltip: 'Toggle playhead snapping',
      ),
      BlenderPopover(
        key: _key('playhead-snap-button'),
        child: IgnorePointer(
          child: BlenderIconButton(
            glyph: BlenderGlyph.chevronDown,
            selected: state.playheadSnapping,
            tooltip: 'Playhead snapping settings',
            onPressed: _noopAnimationHeaderControl,
          ),
        ),
        popover: (context, close) =>
            _blenderAnimationPlayheadPanel(context, state, onStateChanged),
      ),
    ],
  );
}

Widget _blenderAnimationPlaybackPanel(
  BuildContext context,
  BlenderDopeSheetEditorHeaderState state,
  ValueChanged<BlenderDopeSheetEditorHeaderState>? onChanged,
) => BlenderPopoverPanel.settings('Playback', <Widget>[
  BlenderDropdown<String>(
    value: state.playbackSync,
    items: const <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(
        value: 'Play Every Frame',
        label: 'Play Every Frame',
      ),
      BlenderMenuItem<String>(value: 'Frame Dropping', label: 'Frame Dropping'),
    ],
    onChanged: (value) => onChanged?.call(state.copyWith(playbackSync: value)),
  ),
  BlenderCheckbox(
    value: state.audioScrubbing,
    label: 'Audio Scrubbing',
    onChanged: (value) =>
        onChanged?.call(state.copyWith(audioScrubbing: value)),
  ),
  BlenderCheckbox(
    value: state.useAudio,
    label: 'Use Audio',
    onChanged: (value) => onChanged?.call(state.copyWith(useAudio: value)),
  ),
  BlenderCheckbox(
    value: state.limitToFrameRange,
    label: 'Limit to Frame Range',
    onChanged: (value) =>
        onChanged?.call(state.copyWith(limitToFrameRange: value)),
  ),
  BlenderCheckbox(
    value: state.followCurrentFrame,
    label: 'Follow Current Frame',
    onChanged: (value) =>
        onChanged?.call(state.copyWith(followCurrentFrame: value)),
  ),
  BlenderDropdown<String>(
    value: state.playbackLoop,
    items: const <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Cycle', label: 'Cycle'),
      BlenderMenuItem<String>(value: 'Hold', label: 'Hold'),
      BlenderMenuItem<String>(value: 'Ping-Pong', label: 'Ping-Pong'),
    ],
    onChanged: (value) => onChanged?.call(state.copyWith(playbackLoop: value)),
  ),
]);

Widget _blenderAnimationPlayheadPanel(
  BuildContext context,
  BlenderDopeSheetEditorHeaderState state,
  ValueChanged<BlenderDopeSheetEditorHeaderState>? onChanged,
) => BlenderPopoverPanel.settings('Playhead', <Widget>[
  BlenderNumberField(
    value: state.playheadSnapDistance,
    min: 0,
    max: 20,
    step: 1,
    decimalDigits: 0,
    label: 'Snap Distance',
    onChanged: (value) =>
        onChanged?.call(state.copyWith(playheadSnapDistance: value)),
  ),
  Text('Snap Target', style: BlenderTheme.of(context).textTheme.caption),
  BlenderSegmentedControl<String>(
    value: state.playheadSnapTarget,
    items: const <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
      BlenderMenuItem<String>(value: 'Second', label: 'Second'),
      BlenderMenuItem<String>(value: 'Marker', label: 'Marker'),
    ],
    onChanged: (value) =>
        onChanged?.call(state.copyWith(playheadSnapTarget: value)),
  ),
  BlenderNumberField(
    value: state.playheadFrameStep,
    min: 1,
    max: 120,
    step: 1,
    decimalDigits: 0,
    label: 'Frame Step',
    onChanged: (value) =>
        onChanged?.call(state.copyWith(playheadFrameStep: value)),
  ),
]);
