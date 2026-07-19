part of '../layout.dart';

enum BlenderSplitDirection { horizontal, vertical }

class BlenderSplitter extends StatefulWidget {
  const BlenderSplitter({
    super.key,
    required this.first,
    required this.second,
    this.direction = BlenderSplitDirection.horizontal,
    this.initialFraction = .5,
    this.onFractionChanged,
    this.dividerExtent = 4,
    this.dividerKey,
    this.onDividerSecondaryTapDown,
  });

  final Widget first;
  final Widget second;
  final BlenderSplitDirection direction;
  final double initialFraction;
  final ValueChanged<double>? onFractionChanged;
  final double dividerExtent;

  /// Optional identity for the complete divider hit surface.
  final Key? dividerKey;

  /// Receives a secondary click without replacing divider resize behavior.
  final GestureTapDownCallback? onDividerSecondaryTapDown;

  @override
  State<BlenderSplitter> createState() => _BlenderSplitterState();
}

class _BlenderSplitterState extends State<BlenderSplitter> {
  late double _fraction = widget.initialFraction.clamp(.05, .95).toDouble();
  bool _hovered = false;
  bool _dragging = false;

  @override
  void didUpdateWidget(BlenderSplitter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFraction != widget.initialFraction) {
      _fraction = widget.initialFraction.clamp(.05, .95).toDouble();
    }
  }

  void _move(double delta, double extent) {
    final next = (_fraction + delta / extent).clamp(.05, .95).toDouble();
    if (next == _fraction) return;
    setState(() => _fraction = next);
    widget.onFractionChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final dragCursor = widget.direction == BlenderSplitDirection.horizontal
        ? SystemMouseCursors.resizeColumn
        : SystemMouseCursors.resizeRow;
    return MouseRegion(
      key: const ValueKey<String>('blender-splitter-drag-surface'),
      // A divider moves underneath the pointer while it is being dragged.
      // Keep the active resize cursor on the whole splitter surface so the
      // divider's small MouseRegion cannot briefly lose ownership during
      // relayout.
      cursor: _dragging ? dragCursor : MouseCursor.defer,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isHorizontal =
              widget.direction == BlenderSplitDirection.horizontal;
          final extent = isHorizontal
              ? constraints.maxWidth
              : constraints.maxHeight;
          final available = (extent - widget.dividerExtent).clamp(
            0,
            double.infinity,
          );
          final firstExtent = available * _fraction;
          final divider = Semantics(
            label: isHorizontal
                ? 'Resize editor width'
                : 'Resize editor height',
            child: MouseRegion(
              key: widget.dividerKey,
              cursor: isHorizontal
                  ? SystemMouseCursors.resizeColumn
                  : SystemMouseCursors.resizeRow,
              onEnter: (_) => setState(() => _hovered = true),
              onExit: (_) {
                if (!_dragging) setState(() => _hovered = false);
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: isHorizontal
                    ? (_) => setState(() => _dragging = true)
                    : null,
                onVerticalDragStart: !isHorizontal
                    ? (_) => setState(() => _dragging = true)
                    : null,
                onHorizontalDragUpdate: isHorizontal
                    ? (details) => _move(details.delta.dx, extent)
                    : null,
                onVerticalDragUpdate: !isHorizontal
                    ? (details) => _move(details.delta.dy, extent)
                    : null,
                onHorizontalDragEnd: isHorizontal ? (_) => _endDrag() : null,
                onVerticalDragEnd: !isHorizontal ? (_) => _endDrag() : null,
                onHorizontalDragCancel: isHorizontal ? _endDrag : null,
                onVerticalDragCancel: !isHorizontal ? _endDrag : null,
                onSecondaryTapDown: widget.onDividerSecondaryTapDown,
                child: SizedBox(
                  width: isHorizontal ? widget.dividerExtent : double.infinity,
                  height: isHorizontal ? double.infinity : widget.dividerExtent,
                  child: Stack(
                    clipBehavior: Clip.none,
                    fit: StackFit.expand,
                    children: <Widget>[
                      Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: _hovered
                                ? theme.colors.editorOutlineActive
                                : theme.colors.editorBorder,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: theme.colors.editorOutline,
                                spreadRadius: .5,
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: isHorizontal ? 1 : double.infinity,
                            height: isHorizontal ? double.infinity : 1,
                          ),
                        ),
                      ),
                      Center(
                        child: IgnorePointer(
                          child: AnimatedOpacity(
                            opacity: _dragging ? 1 : 0,
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                color: const Color(0xFFE8E8E8),
                                boxShadow: const <BoxShadow>[
                                  BoxShadow(
                                    color: Color(0xB0000000),
                                    blurRadius: 2,
                                    spreadRadius: .5,
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: isHorizontal ? 2 : double.infinity,
                                height: isHorizontal ? double.infinity : 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: IgnorePointer(
                          child: AnimatedOpacity(
                            opacity: _dragging ? 1 : 0,
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            child: OverflowBox(
                              maxWidth: double.infinity,
                              maxHeight: double.infinity,
                              child: SizedBox(
                                width: isHorizontal ? 44 : 30,
                                height: isHorizontal ? 30 : 44,
                                child: CustomPaint(
                                  painter: _BlenderSplitHandlePainter(
                                    verticalDivider: isHorizontal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          if (isHorizontal) {
            return Row(
              children: <Widget>[
                SizedBox(width: firstExtent, child: widget.first),
                divider,
                Expanded(child: widget.second),
              ],
            );
          }
          return Column(
            children: <Widget>[
              SizedBox(height: firstExtent, child: widget.first),
              divider,
              Expanded(child: widget.second),
            ],
          );
        },
      ),
    );
  }

  void _endDrag() {
    if (!mounted) return;
    setState(() => _dragging = false);
  }
}

class _BlenderSplitHandlePainter extends CustomPainter {
  const _BlenderSplitHandlePainter({required this.verticalDivider});

  final bool verticalDivider;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void draw(Path path) {
      stroke
        ..color = const Color(0xD0000000)
        ..strokeWidth = 6;
      canvas.drawPath(path, stroke);
      stroke
        ..color = const Color(0xFFF2F2F2)
        ..strokeWidth = 2.5;
      canvas.drawPath(path, stroke);
    }

    final center = Offset(size.width / 2, size.height / 2);
    if (verticalDivider) {
      draw(
        Path()
          ..moveTo(center.dx, center.dy - 8)
          ..lineTo(center.dx, center.dy + 8),
      );
      draw(
        Path()
          ..moveTo(center.dx - 7, center.dy - 7)
          ..lineTo(center.dx - 13, center.dy)
          ..lineTo(center.dx - 7, center.dy + 7),
      );
      draw(
        Path()
          ..moveTo(center.dx + 7, center.dy - 7)
          ..lineTo(center.dx + 13, center.dy)
          ..lineTo(center.dx + 7, center.dy + 7),
      );
      return;
    }
    draw(
      Path()
        ..moveTo(center.dx - 8, center.dy)
        ..lineTo(center.dx + 8, center.dy),
    );
    draw(
      Path()
        ..moveTo(center.dx - 7, center.dy - 7)
        ..lineTo(center.dx, center.dy - 13)
        ..lineTo(center.dx + 7, center.dy - 7),
    );
    draw(
      Path()
        ..moveTo(center.dx - 7, center.dy + 7)
        ..lineTo(center.dx, center.dy + 13)
        ..lineTo(center.dx + 7, center.dy + 7),
    );
  }

  @override
  bool shouldRepaint(covariant _BlenderSplitHandlePainter oldDelegate) {
    return oldDelegate.verticalDivider != verticalDivider;
  }
}
