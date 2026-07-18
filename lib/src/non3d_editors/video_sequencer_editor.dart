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
    this.title = 'Video Sequencer',
  });

  final List<BlenderSequencerStrip> strips;
  final double start;
  final double end;
  final double? currentFrame;
  final ValueChanged<double>? onCurrentFrameChanged;
  final String? selectedId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlenderSequencerEditor(
      strips: strips,
      start: start,
      end: end,
      currentFrame: currentFrame,
      onCurrentFrameChanged: onCurrentFrameChanged,
      selectedId: selectedId,
      title: title,
      sidebar: const BlenderSequencerSidebar(),
    );
  }
}
