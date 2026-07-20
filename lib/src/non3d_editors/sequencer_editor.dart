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
  final Widget? footer;
  final Widget? sidebar;
  final double sidebarWidth;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final canvas = _buildCanvas(theme);
    final content = sidebar == null
        ? canvas
        : Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(child: canvas),
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
            behavior: HitTestBehavior.opaque,
            onTapDown: onCurrentFrameChanged == null
                ? null
                : (details) =>
                      onCurrentFrameChanged!(frameAt(details.localPosition)),
            child: SizedBox(
              height: height,
              child: CustomPaint(
                painter: _BlenderSequencerPainter(
                  strips: strips,
                  start: start,
                  end: end,
                  currentFrame: currentFrame,
                  selectedId: selectedId,
                  colors: theme.colors,
                  textTheme: theme.textTheme,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
