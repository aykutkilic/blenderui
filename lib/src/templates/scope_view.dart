part of '../templates.dart';

enum BlenderScopeType { histogram, waveform, vectorscope }

class BlenderScopeSeries {
  const BlenderScopeSeries({required this.color, required this.points});

  final Color color;

  /// Normalized samples in the [0, 1] range.
  ///
  /// Histogram samples use `x` as the bin position and `y` as the bin height.
  /// Waveform samples use `x` as time and `y` as signal level. Vectorscope
  /// samples use `x` and `y` as coordinates around the center of the scope.
  final List<Offset> points;
}

/// A compact waveform, histogram, or vectorscope template for image-oriented
/// editor panels.
class BlenderScopeView extends StatefulWidget {
  const BlenderScopeView({
    super.key,
    required this.type,
    required this.series,
    this.title = 'Scope',
    this.height = 150,
    this.minHeight = 20,
    this.maxHeight = 400,
  });

  final BlenderScopeType type;
  final List<BlenderScopeSeries> series;
  final String title;
  final double height;
  final double minHeight;
  final double maxHeight;

  @override
  State<BlenderScopeView> createState() => _BlenderScopeViewState();
}

class _BlenderScopeViewState extends State<BlenderScopeView> {
  late double _height;

  @override
  void initState() {
    super.initState();
    _height = widget.height.clamp(widget.minHeight, widget.maxHeight);
  }

  @override
  void didUpdateWidget(BlenderScopeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.height != widget.height ||
        oldWidget.minHeight != widget.minHeight ||
        oldWidget.maxHeight != widget.maxHeight) {
      _height = widget.height.clamp(widget.minHeight, widget.maxHeight);
    }
  }

  void _resize(double delta) {
    setState(() {
      _height = (_height + delta).clamp(widget.minHeight, widget.maxHeight);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: widget.title,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: _height,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CustomPaint(
              painter: _BlenderScopePainter(
                type: widget.type,
                series: widget.series,
                colors: theme.colors,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (details) => _resize(details.delta.dy),
                child: SizedBox(
                  height: 10,
                  child: Center(
                    child: BlenderIcon(
                      BlenderGlyph.grip,
                      size: 10,
                      color: theme.colors.foregroundMuted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlenderScopePainter extends CustomPainter {
  _BlenderScopePainter({
    required this.type,
    required this.series,
    required this.colors,
  });

  final BlenderScopeType type;
  final List<BlenderScopeSeries> series;
  final BlenderColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.textField);
    final grid = Paint()
      ..color = colors.borderSubtle.withValues(alpha: .65)
      ..strokeWidth = 1;
    if (type == BlenderScopeType.vectorscope) {
      _paintVectorscope(canvas, size, grid);
    } else {
      _paintRectilinearGrid(canvas, size, grid);
      for (final data in series) {
        final paint = Paint()
          ..color = data.color.withValues(alpha: .7)
          ..strokeWidth = type == BlenderScopeType.histogram ? 2 : 1.5
          ..strokeCap = StrokeCap.round;
        if (type == BlenderScopeType.histogram) {
          for (final point in data.points) {
            final x = point.dx.clamp(0, 1).toDouble() * size.width;
            final height = point.dy.clamp(0, 1).toDouble() * size.height;
            canvas.drawLine(
              Offset(x, size.height),
              Offset(x, size.height - height),
              paint,
            );
          }
        } else {
          canvas.drawPoints(PointMode.points, [
            for (final point in data.points)
              Offset(
                point.dx.clamp(0, 1).toDouble() * size.width,
                (1 - point.dy.clamp(0, 1).toDouble()) * size.height,
              ),
          ], paint);
        }
      }
    }
  }

  void _paintRectilinearGrid(Canvas canvas, Size size, Paint paint) {
    for (var index = 1; index < 4; index++) {
      final x = size.width * index / 4;
      final y = size.height * index / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _paintVectorscope(Canvas canvas, Size size, Paint grid) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 8;
    canvas.drawCircle(center, radius, grid);
    canvas.drawCircle(center, radius * .5, grid);
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      grid,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      grid,
    );
    for (final data in series) {
      final paint = Paint()
        ..color = data.color.withValues(alpha: .75)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawPoints(PointMode.points, [
        for (final point in data.points)
          Offset(
            center.dx + (point.dx.clamp(0, 1).toDouble() * 2 - 1) * radius,
            center.dy + (1 - point.dy.clamp(0, 1).toDouble() * 2) * radius,
          ),
      ], paint);
    }
  }

  @override
  bool shouldRepaint(_BlenderScopePainter oldDelegate) {
    return type != oldDelegate.type ||
        series != oldDelegate.series ||
        colors != oldDelegate.colors;
  }
}
