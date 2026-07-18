part of '../non3d_editors.dart';

class _BlenderImageEditorState extends State<BlenderImageEditor> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetView() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: widget.title,
      padding: EdgeInsets.zero,
      headerActions: <Widget>[
        BlenderIconButton(
          glyph: BlenderGlyph.refresh,
          onPressed: _resetView,
          tooltip: 'Reset view',
          size: 22,
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.maximize,
          tooltip: 'Fit image',
          size: 22,
        ),
      ],
      child: widget.sidebar == null
          ? _buildCanvas(theme)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: _buildCanvas(theme)),
                SizedBox(
                  width: widget.sidebarWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colors.surface,
                      border: Border(
                        left: BorderSide(color: theme.colors.editorBorder),
                      ),
                    ),
                    child: widget.sidebar,
                  ),
                ),
              ],
            ),
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
