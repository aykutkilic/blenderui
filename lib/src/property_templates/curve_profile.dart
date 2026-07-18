part of '../property_templates.dart';

class _BlenderCurveProfileState extends State<BlenderCurveProfile> {
  int _selected = 0;
  double _zoom = 1;

  @override
  void didUpdateWidget(BlenderCurveProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.points.isEmpty) {
      _selected = 0;
    } else {
      _selected = math.min(_selected, widget.points.length - 1);
    }
  }

  Offset _display(Offset point) {
    final normalized = Offset(
      point.dx.clamp(0, 1).toDouble(),
      point.dy.clamp(0, 1).toDouble(),
    );
    return Offset(
      (normalized.dx - .5) * _zoom + .5,
      (normalized.dy - .5) * _zoom + .5,
    );
  }

  Offset _normalize(Offset local, Size size) {
    final display = Offset(
      (local.dx / math.max(1, size.width) - .5) / _zoom + .5,
      (1 - local.dy / math.max(1, size.height) - .5) / _zoom + .5,
    );
    return Offset(display.dx.clamp(0, 1), display.dy.clamp(0, 1));
  }

  int _nearest(Offset normalized) {
    var nearest = 0;
    var distance = double.infinity;
    for (var index = 0; index < widget.points.length; index++) {
      final candidate = (_display(widget.points[index]) - normalized).distance;
      if (candidate < distance) {
        distance = candidate;
        nearest = index;
      }
    }
    return nearest;
  }

  void _select(Offset local, Size size) {
    if (widget.points.isEmpty) return;
    final normalized = _normalize(local, size);
    setState(() => _selected = _nearest(normalized));
  }

  void _move(Offset local, Size size) {
    if (widget.points.isEmpty) return;
    final next = widget.points.toList();
    next[_selected] = _normalize(local, size);
    widget.onChanged(next);
  }

  void _resetCurve() {
    widget.onReset?.call();
    if (widget.onReset == null) {
      widget.onChanged(const <Offset>[Offset(0, 0), Offset(1, 1)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: widget.title,
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: 2,
            children: <Widget>[
              if (widget.presets.isNotEmpty)
                BlenderMenuButton<String>(
                  label: 'Presets',
                  items: [
                    for (final preset in widget.presets)
                      BlenderMenuItem<String>(
                        value: preset.name,
                        label: preset.name,
                      ),
                  ],
                  onSelected: (name) {
                    for (final preset in widget.presets) {
                      if (preset.name == name) {
                        widget.onChanged(preset.points.toList());
                        break;
                      }
                    }
                  },
                ),
              BlenderIconButton(
                glyph: BlenderGlyph.minus,
                onPressed: _zoom <= 1
                    ? null
                    : () => setState(() => _zoom = math.max(1, _zoom - .5)),
                tooltip: 'Zoom out',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.plus,
                onPressed: _zoom >= 4
                    ? null
                    : () => setState(() => _zoom = math.min(4, _zoom + .5)),
                tooltip: 'Zoom in',
                size: 22,
              ),
              BlenderButton(
                label: '${_zoom.toStringAsFixed(1)}x',
                variant: BlenderButtonVariant.toolbar,
                onPressed: () => setState(() => _zoom = 1),
              ),
              BlenderButton(
                label: 'Reset Curve',
                variant: BlenderButtonVariant.toolbar,
                onPressed: _resetCurve,
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: widget.height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(
                  constraints.maxWidth.isFinite ? constraints.maxWidth : 200,
                  widget.height,
                );
                return GestureDetector(
                  onTapDown: (details) => _select(details.localPosition, size),
                  onPanStart: (details) => _select(details.localPosition, size),
                  onPanUpdate: (details) => _move(details.localPosition, size),
                  child: CustomPaint(
                    painter: _BlenderCurveProfilePainter(
                      points: widget.points,
                      selected: _selected,
                      zoom: _zoom,
                      colors: theme.colors,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BlenderCurveProfilePainter extends CustomPainter {
  const _BlenderCurveProfilePainter({
    required this.points,
    required this.selected,
    required this.zoom,
    required this.colors,
  });

  final List<Offset> points;
  final int selected;
  final double zoom;
  final BlenderColorScheme colors;

  Offset _toCanvas(Offset point, Size size) {
    final x = (point.dx.clamp(0, 1).toDouble() - .5) * zoom + .5;
    final y = (point.dy.clamp(0, 1).toDouble() - .5) * zoom + .5;
    return Offset(x * size.width, (1 - y) * size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.textField);
    final grid = Paint()
      ..color = colors.borderSubtle
      ..strokeWidth = 1;
    for (var index = 1; index < 4; index++) {
      final x = size.width * index / 4;
      final y = size.height * index / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final normalized = [for (final point in points) _toCanvas(point, size)];
    if (normalized.length > 1) {
      final path = Path()..moveTo(normalized.first.dx, normalized.first.dy);
      for (var index = 1; index < normalized.length; index++) {
        path.lineTo(normalized[index].dx, normalized[index].dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = colors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    for (var index = 0; index < normalized.length; index++) {
      canvas.drawCircle(
        normalized[index],
        index == selected ? 5 : 4,
        Paint()..color = index == selected ? colors.focus : colors.foreground,
      );
    }
  }

  @override
  bool shouldRepaint(_BlenderCurveProfilePainter oldDelegate) {
    return points != oldDelegate.points ||
        selected != oldDelegate.selected ||
        zoom != oldDelegate.zoom ||
        colors != oldDelegate.colors;
  }
}
