part of '../non3d_editors.dart';

class BlenderVideoSequencerEditor extends StatelessWidget {
  const BlenderVideoSequencerEditor({
    super.key,
    required this.strips,
    required this.start,
    required this.end,
    this.currentFrame,
    this.onCurrentFrameChanged,
    this.selectedId,
    this.onStripSelected,
    this.currentFrameListenable,
    this.showChannels = false,
    this.channelLabels = const <int, String>{},
    this.showSeconds = false,
    this.framesPerSecond = 24,
    this.title = 'Video Sequencer',
  });

  final List<BlenderSequencerStrip> strips;
  final double start;
  final double end;
  final double? currentFrame;
  final ValueChanged<double>? onCurrentFrameChanged;
  final String? selectedId;
  final ValueChanged<BlenderSequencerStrip>? onStripSelected;
  final ValueListenable<double>? currentFrameListenable;
  final bool showChannels;
  final Map<int, String> channelLabels;
  final bool showSeconds;
  final double framesPerSecond;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return BlenderSequencerEditor(
      strips: strips,
      start: start,
      end: end,
      currentFrame: currentFrame,
      onCurrentFrameChanged: onCurrentFrameChanged,
      selectedId: selectedId,
      onStripSelected: onStripSelected,
      currentFrameListenable: currentFrameListenable,
      showChannels: showChannels,
      channelLabels: channelLabels,
      showSeconds: showSeconds,
      framesPerSecond: framesPerSecond,
      title: title,
      sidebar: const BlenderSequencerSidebar(),
    );
  }
}
