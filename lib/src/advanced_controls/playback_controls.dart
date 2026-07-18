part of '../advanced_controls.dart';

class BlenderPlaybackControls extends StatelessWidget {
  const BlenderPlaybackControls({
    super.key,
    this.onFirst,
    this.onPrevious,
    this.onPlay,
    this.onNext,
    this.onLast,
    this.onRecord,
    this.playing = false,
    this.recording = false,
  });

  final VoidCallback? onFirst;
  final VoidCallback? onPrevious;
  final VoidCallback? onPlay;
  final VoidCallback? onNext;
  final VoidCallback? onLast;
  final VoidCallback? onRecord;
  final bool playing;
  final bool recording;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        BlenderIconButton(
          glyph: BlenderGlyph.stepBack,
          onPressed: onFirst,
          tooltip: 'Jump to first frame',
          size: 22,
        ),
        BlenderIconButton(
          glyph: BlenderGlyph.stepBack,
          onPressed: onPrevious,
          tooltip: 'Previous frame',
          size: 22,
        ),
        BlenderIconButton(
          glyph: playing ? BlenderGlyph.pause : BlenderGlyph.play,
          onPressed: onPlay,
          selected: playing,
          tooltip: playing ? 'Pause' : 'Play',
          size: 22,
        ),
        BlenderIconButton(
          glyph: BlenderGlyph.stepForward,
          onPressed: onNext,
          tooltip: 'Next frame',
          size: 22,
        ),
        BlenderIconButton(
          glyph: BlenderGlyph.stepForward,
          onPressed: onLast,
          tooltip: 'Jump to last frame',
          size: 22,
        ),
        BlenderIconButton(
          glyph: BlenderGlyph.record,
          onPressed: onRecord,
          selected: recording,
          tooltip: 'Record animation',
          size: 22,
        ),
      ],
    );
  }
}

/// The compact time-jump controls registered by Blender's Timeline header.
///
/// The host owns the frame-jump callbacks and the contents of the anchored
/// `TIME_PT_jump` popover; this widget preserves the source ordering and
/// control density.
class BlenderTimeJumpControls extends StatelessWidget {
  const BlenderTimeJumpControls({
    super.key,
    this.onBackward,
    this.onForward,
    required this.popover,
  });

  final VoidCallback? onBackward;
  final VoidCallback? onForward;
  final Widget Function(BuildContext context, VoidCallback close) popover;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        BlenderIconButton(
          glyph: BlenderGlyph.stepBack,
          onPressed: onBackward,
          tooltip: 'Jump backward',
          size: 22,
        ),
        BlenderIconButton(
          glyph: BlenderGlyph.stepForward,
          onPressed: onForward,
          tooltip: 'Jump forward',
          size: 22,
        ),
        BlenderPopover(
          child: const BlenderIconButton(
            glyph: BlenderGlyph.panelDisclosureDown,
            tooltip: 'Time jump settings',
            size: 22,
            iconSize: 9,
          ),
          popover: popover,
        ),
      ],
    );
  }
}
