part of '../non3d_editors.dart';

class _BlenderImageEditorState extends State<BlenderImageEditor> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final layout = BlenderImageEditorLayout(
      canvas: _buildCanvas(theme),
      toolShelf: widget.toolShelf,
      sidebar: widget.sidebar,
      assetShelf: widget.assetShelf,
      toolShelfWidth: widget.toolShelfWidth,
      sidebarWidth: widget.sidebarWidth,
      assetShelfHeight: widget.assetShelfHeight,
    );
    if (widget.title == null) return layout;
    return BlenderPanel(
      title: widget.title,
      padding: EdgeInsets.zero,
      child: layout,
    );
  }

  Widget _buildCanvas(BlenderThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) => InteractiveViewer(
        transformationController: _transformationController,
        minScale: .1,
        maxScale: 8,
        boundaryMargin: const EdgeInsets.all(240),
        child: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              const CustomPaint(painter: _BlenderCheckerPainter()),
              if (widget.image != null)
                Center(child: widget.image)
              else
                Center(
                  child: Text(
                    widget.label,
                    style: theme.textTheme.body.copyWith(
                      color: theme.colors.foregroundMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlenderCheckerPainter extends CustomPainter {
  const _BlenderCheckerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const tile = 12.0;
    final light = Paint()..color = const Color(0xFF303030);
    final dark = Paint()..color = const Color(0xFF242424);
    for (var y = 0.0; y < size.height; y += tile) {
      for (var x = 0.0; x < size.width; x += tile) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, tile, tile),
          ((x / tile).floor() + (y / tile).floor()).isEven ? light : dark,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BlenderCheckerPainter oldDelegate) => false;
}
