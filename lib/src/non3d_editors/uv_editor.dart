part of '../non3d_editors.dart';

class BlenderUVPoint {
  const BlenderUVPoint({required this.id, required this.position, this.color});

  final String id;
  final Offset position;
  final Color? color;
}

class BlenderUVEdge {
  const BlenderUVEdge({required this.from, required this.to});

  final int from;
  final int to;
}

/// A 2D UV editor surface; it deliberately contains no 3D rendering.
class BlenderUVEditor extends StatelessWidget {
  const BlenderUVEditor({
    super.key,
    required this.points,
    this.edges = const <BlenderUVEdge>[],
    this.selectedId,
    this.onSelected,
    this.sidebar,
    this.sidebarWidth = 240,
    this.title = 'UV Editor',
  });

  final List<BlenderUVPoint> points;
  final List<BlenderUVEdge> edges;
  final String? selectedId;
  final ValueChanged<BlenderUVPoint>? onSelected;
  final Widget? sidebar;
  final double sidebarWidth;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: sidebar == null
          ? _buildCanvas(theme)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: _buildCanvas(theme)),
                SizedBox(
                  width: sidebarWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colors.surface,
                      border: Border(
                        left: BorderSide(color: theme.colors.editorBorder),
                      ),
                    ),
                    child: sidebar,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCanvas(BlenderThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        Offset toLocal(Offset point) =>
            Offset(point.dx * size.width, (1 - point.dy) * size.height);
        return GestureDetector(
          onTapDown: onSelected == null
              ? null
              : (details) {
                  if (points.isEmpty) return;
                  var nearest = points.first;
                  var distance = double.infinity;
                  for (final point in points) {
                    final next =
                        (toLocal(point.position) - details.localPosition)
                            .distance;
                    if (next < distance) {
                      distance = next;
                      nearest = point;
                    }
                  }
                  onSelected!(nearest);
                },
          child: CustomPaint(
            painter: _BlenderUVPainter(
              points: points,
              edges: edges,
              selectedId: selectedId,
              colors: theme.colors,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _BlenderUVPainter extends CustomPainter {
  _BlenderUVPainter({
    required this.points,
    required this.edges,
    required this.selectedId,
    required this.colors,
  });

  final List<BlenderUVPoint> points;
  final List<BlenderUVEdge> edges;
  final String? selectedId;
  final BlenderColorScheme colors;

  Offset _local(Offset point, Size size) =>
      Offset(point.dx * size.width, (1 - point.dy) * size.height);

  @override
  void paint(Canvas canvas, Size size) {
    const tile = 16.0;
    final light = Paint()..color = colors.surface;
    final dark = Paint()..color = colors.panelSubSurface;
    for (var y = 0.0; y < size.height; y += tile) {
      for (var x = 0.0; x < size.width; x += tile) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, tile, tile),
          ((x / tile).floor() + (y / tile).floor()).isEven ? light : dark,
        );
      }
    }
    final grid = Paint()
      ..color = colors.borderSubtle
      ..strokeWidth = 1;
    for (var i = 1; i < 10; i++) {
      final x = size.width * i / 10;
      final y = size.height * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final edgePaint = Paint()
      ..color = colors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final edge in edges) {
      if (edge.from < 0 ||
          edge.to < 0 ||
          edge.from >= points.length ||
          edge.to >= points.length) {
        continue;
      }
      canvas.drawLine(
        _local(points[edge.from].position, size),
        _local(points[edge.to].position, size),
        edgePaint,
      );
    }
    for (final point in points) {
      canvas.drawCircle(
        _local(point.position, size),
        point.id == selectedId ? 5 : 3,
        Paint()..color = point.color ?? colors.foreground,
      );
    }
  }

  @override
  bool shouldRepaint(_BlenderUVPainter oldDelegate) {
    return points != oldDelegate.points ||
        edges != oldDelegate.edges ||
        selectedId != oldDelegate.selectedId ||
        colors != oldDelegate.colors;
  }
}
