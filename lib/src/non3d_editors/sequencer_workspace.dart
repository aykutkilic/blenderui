part of '../non3d_editors.dart';

/// Preview region used by Blender's Video Sequence Editor.
///
/// The host may supply a decoded frame through [child]. Guides and the
/// checkerboard/window chrome remain cheap painter layers, so playback can
/// update without rebuilding strip widgets.
class BlenderSequencerPreview extends StatelessWidget {
  const BlenderSequencerPreview({
    super.key,
    this.child,
    this.currentFrame,
    this.currentFrameListenable,
    this.showSafeAreas = false,
    this.showMetadata = true,
    this.label = 'Preview',
    this.aspectRatio = 16 / 9,
  });

  final Widget? child;
  final double? currentFrame;
  final ValueListenable<double>? currentFrameListenable;
  final bool showSafeAreas;
  final bool showMetadata;
  final String label;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return ColoredBox(
      key: const ValueKey<String>('sequencer-preview-region'),
      color: theme.colors.canvas,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: RepaintBoundary(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    border: Border.all(color: theme.colors.editorBorder),
                  ),
                  child:
                      child ??
                      Center(
                        child: BlenderIcon(
                          BlenderGlyph.movie,
                          size: 40,
                          color: theme.colors.foregroundMuted,
                        ),
                      ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: CustomPaint(
              painter: _BlenderSequencerPreviewOverlayPainter(
                colors: theme.colors,
                showSafeAreas: showSafeAreas,
              ),
            ),
          ),
          if (showMetadata)
            Positioned(
              left: 8,
              top: 7,
              child: currentFrameListenable == null
                  ? Text('$label  ${_frameLabel(currentFrame)}')
                  : ValueListenableBuilder<double>(
                      valueListenable: currentFrameListenable!,
                      builder: (context, frame, child) =>
                          Text('$label  ${_frameLabel(frame)}'),
                    ),
            ),
        ],
      ),
    );
  }

  String _frameLabel(double? frame) =>
      frame == null ? '' : 'Frame ${frame.round()}';
}

class _BlenderSequencerPreviewOverlayPainter extends CustomPainter {
  const _BlenderSequencerPreviewOverlayPainter({
    required this.colors,
    required this.showSafeAreas,
  });

  final BlenderColorScheme colors;
  final bool showSafeAreas;

  @override
  void paint(Canvas canvas, Size size) {
    if (!showSafeAreas) return;
    final paint = Paint()
      ..color = colors.foregroundMuted.withValues(alpha: .55)
      ..style = PaintingStyle.stroke;
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .1,
        size.height * .1,
        size.width * .8,
        size.height * .8,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .05,
        size.height * .05,
        size.width * .9,
        size.height * .9,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BlenderSequencerPreviewOverlayPainter oldDelegate) =>
      colors != oldDelegate.colors ||
      showSafeAreas != oldDelegate.showSafeAreas;
}

/// Full source-shaped Video Sequence Editor region composition.
class BlenderVideoSequencerWorkspace extends StatelessWidget {
  const BlenderVideoSequencerWorkspace({
    super.key,
    required this.headerState,
    required this.strips,
    required this.start,
    required this.end,
    this.onHeaderStateChanged,
    this.onCommand,
    this.currentFrame,
    this.currentFrameListenable,
    this.onCurrentFrameChanged,
    this.selectedId,
    this.onStripSelected,
    this.preview,
    this.footer,
    this.sidebar,
    this.channelLabels = const <int, String>{},
    this.showChannels = true,
    this.showToolHeader = true,
    this.showSeconds = true,
    this.framesPerSecond = 24,
  });

  final BlenderSequencerEditorHeaderState headerState;
  final ValueChanged<BlenderSequencerEditorHeaderState>? onHeaderStateChanged;
  final ValueChanged<String>? onCommand;
  final List<BlenderSequencerStrip> strips;
  final double start;
  final double end;
  final double? currentFrame;
  final ValueListenable<double>? currentFrameListenable;
  final ValueChanged<double>? onCurrentFrameChanged;
  final String? selectedId;
  final ValueChanged<BlenderSequencerStrip>? onStripSelected;
  final Widget? preview;
  final Widget? footer;
  final Widget? sidebar;
  final Map<int, String> channelLabels;
  final bool showChannels;
  final bool showToolHeader;
  final bool showSeconds;
  final double framesPerSecond;

  bool get _hasPreview => headerState.viewType != 'Sequencer';
  bool get _hasSequencer => headerState.viewType != 'Preview';

  @override
  Widget build(BuildContext context) {
    final timeline = BlenderSequencerEditor(
      strips: strips,
      start: start,
      end: end,
      currentFrame: currentFrame,
      currentFrameListenable: currentFrameListenable,
      onCurrentFrameChanged: onCurrentFrameChanged,
      selectedId: selectedId,
      onStripSelected: onStripSelected,
      showChannels: showChannels,
      channelLabels: channelLabels,
      showSeconds: showSeconds,
      framesPerSecond: framesPerSecond,
      sidebar: sidebar,
      title: null,
    );
    final previewRegion = BlenderSequencerPreview(
      currentFrame: currentFrame,
      currentFrameListenable: currentFrameListenable,
      showSafeAreas: headerState.overlays,
      child: preview,
    );
    return Column(
      children: <Widget>[
        BlenderSequencerEditorHeader(
          editorType: BlenderEditorType.sequencer,
          state: headerState,
          onStateChanged: onHeaderStateChanged,
          onCommand: onCommand,
        ),
        if (showToolHeader && _hasSequencer)
          BlenderToolbar(
            key: const ValueKey<String>('sequencer-tool-header-region'),
            height: 28,
            children: <Widget>[
              const BlenderIconButton(
                glyph: BlenderGlyph.pointer,
                selected: true,
                tooltip: 'Select',
              ),
              BlenderButton(
                label: 'Blade',
                onPressed: () => onCommand?.call('blade'),
              ),
              const Spacer(),
              Text('Overlap: ${headerState.overlapMode}'),
              const SizedBox(width: 8),
            ],
          ),
        Expanded(
          child: switch ((_hasPreview, _hasSequencer)) {
            (true, true) => Column(
              children: <Widget>[
                Expanded(flex: 3, child: previewRegion),
                Container(
                  height: 1,
                  color: BlenderTheme.of(context).colors.editorBorder,
                ),
                Expanded(flex: 2, child: timeline),
              ],
            ),
            (true, false) => previewRegion,
            _ => timeline,
          },
        ),
        if (footer != null)
          KeyedSubtree(
            key: const ValueKey<String>('sequencer-footer-region'),
            child: footer!,
          ),
      ],
    );
  }
}
