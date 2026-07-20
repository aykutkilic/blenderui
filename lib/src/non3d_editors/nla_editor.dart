part of '../non3d_editors.dart';

class BlenderNLAEditor extends StatelessWidget {
  const BlenderNLAEditor({
    super.key,
    required this.strips,
    required this.start,
    required this.end,
    this.currentFrame,
    this.onCurrentFrameChanged,
    this.selectedId,
    this.footer,
  });

  final List<BlenderSequencerStrip> strips;
  final double start;
  final double end;
  final double? currentFrame;
  final ValueChanged<double>? onCurrentFrameChanged;
  final String? selectedId;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return BlenderSequencerEditor(
      strips: strips,
      start: start,
      end: end,
      currentFrame: currentFrame,
      onCurrentFrameChanged: onCurrentFrameChanged,
      selectedId: selectedId,
      title: null,
      sidebar: const BlenderSequencerSidebar(nlaEditor: true),
      footer: footer,
    );
  }
}
