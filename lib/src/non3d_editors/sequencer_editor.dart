part of '../non3d_editors.dart';

class BlenderSequencerEditor extends StatelessWidget {
  const BlenderSequencerEditor({
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
    this.channelWidth = 160,
    this.channelLabels = const <int, String>{},
    this.showSeconds = false,
    this.framesPerSecond = 24,
    this.footer,
    this.sidebar,
    this.sidebarWidth = 240,
    this.title,
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
  final double channelWidth;
  final Map<int, String> channelLabels;
  final bool showSeconds;
  final double framesPerSecond;
  final Widget? footer;
  final Widget? sidebar;
  final double sidebarWidth;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final graph = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (showChannels)
          SizedBox(
            key: const ValueKey<String>('sequencer-channels-region'),
            width: channelWidth,
            child: _BlenderSequencerChannels(
              maxChannel: strips.fold<int>(
                0,
                (value, strip) => math.max(value, strip.channel),
              ),
              labels: channelLabels,
              colors: theme.colors,
              textTheme: theme.textTheme,
            ),
          ),
        Expanded(child: _buildCanvas(theme)),
      ],
    );
    final content = sidebar == null
        ? graph
        : Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(child: graph),
              SizedBox(width: sidebarWidth, child: sidebar),
            ],
          );
    if (footer == null) return content;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: content),
        footer!,
      ],
    );
  }

  Widget _buildCanvas(BlenderThemeData theme) {
    final maxChannel = strips.fold<int>(
      0,
      (value, strip) => math.max(value, strip.channel),
    );
    final height = math.max(96, (maxChannel + 1) * 28 + 30).toDouble();
    return BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = math.max(1, constraints.maxWidth);
          double frameAt(Offset position) {
            return start + (end - start) * (position.dx / width).clamp(0, 1);
          }

          return GestureDetector(
            key: const ValueKey<String>('sequencer-window-region'),
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              onCurrentFrameChanged?.call(frameAt(details.localPosition));
              if (onStripSelected == null || details.localPosition.dy < 28)
                return;
              final channel = ((details.localPosition.dy - 28) / 28).floor();
              final frame = frameAt(details.localPosition);
              for (final strip in strips.reversed) {
                if (strip.channel == channel &&
                    frame >= strip.start &&
                    frame <= strip.end) {
                  onStripSelected!(strip);
                  break;
                }
              }
            },
            child: SizedBox(
              height: height,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  RepaintBoundary(
                    child: Semantics(
                      label:
                          'Sequencer strips: ${strips.map((strip) => strip.label).join(', ')}',
                      child: CustomPaint(
                        key: const ValueKey<String>('sequencer-static-canvas'),
                        painter: _BlenderSequencerPainter(
                          strips: strips,
                          start: start,
                          end: end,
                          selectedId: selectedId,
                          colors: theme.colors,
                          textTheme: theme.textTheme,
                          showSeconds: showSeconds,
                          framesPerSecond: framesPerSecond,
                        ),
                      ),
                    ),
                  ),
                  RepaintBoundary(
                    child: CustomPaint(
                      key: const ValueKey<String>('sequencer-playhead-canvas'),
                      painter: _BlenderSequencerPlayheadPainter(
                        start: start,
                        end: end,
                        currentFrame: currentFrame,
                        currentFrameListenable: currentFrameListenable,
                        colors: theme.colors,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BlenderSequencerChannels extends StatelessWidget {
  const _BlenderSequencerChannels({
    required this.maxChannel,
    required this.labels,
    required this.colors,
    required this.textTheme,
  });

  final int maxChannel;
  final Map<int, String> labels;
  final BlenderColorScheme colors;
  final BlenderTextTheme textTheme;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: colors.canvas,
      border: Border(right: BorderSide(color: colors.border)),
    ),
    child: Column(
      children: <Widget>[
        SizedBox(height: 28, child: ColoredBox(color: colors.surface)),
        for (var channel = 0; channel <= maxChannel; channel++)
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.borderSubtle)),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    labels[channel] ?? 'Channel ${channel + 1}',
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.body,
                  ),
                ),
                const BlenderIcon(BlenderGlyph.check, size: 12),
                const SizedBox(width: 7),
                const BlenderIcon(BlenderGlyph.unlock, size: 12),
              ],
            ),
          ),
      ],
    ),
  );
}
