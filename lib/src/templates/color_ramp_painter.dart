part of '../templates.dart';

class _BlenderColorRampState extends State<BlenderColorRamp> {
  int _selected = 0;

  int get _selectedIndex {
    if (widget.stops.isEmpty) return 0;
    return _selected.clamp(0, widget.stops.length - 1);
  }

  int _nearest(double position) {
    var index = 0;
    var distance = double.infinity;
    for (var i = 0; i < widget.stops.length; i++) {
      final next = (widget.stops[i].position - position).abs();
      if (next < distance) {
        distance = next;
        index = i;
      }
    }
    return index;
  }

  void _selectAt(Offset local, double width) {
    if (widget.stops.isEmpty) return;
    setState(() => _selected = _nearest((local.dx / width).clamp(0, 1)));
  }

  void _updateSelected(double position) {
    if (widget.stops.isEmpty) return;
    final next = widget.stops.toList();
    next[_selectedIndex] = next[_selectedIndex].copyWith(
      position: position.clamp(0, 1),
    );
    widget.onChanged(next);
  }

  @override
  void didUpdateWidget(covariant BlenderColorRamp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stops.isEmpty) {
      _selected = 0;
    } else {
      _selected = _selected.clamp(0, widget.stops.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LayoutBuilder(
          builder: (context, constraints) {
            final width = math.max(1.0, constraints.maxWidth);
            return GestureDetector(
              onTapDown: (details) => _selectAt(details.localPosition, width),
              onPanStart: (details) => _selectAt(details.localPosition, width),
              onPanUpdate: (details) =>
                  _updateSelected(details.localPosition.dx / width),
              child: SizedBox(
                height: widget.height,
                child: CustomPaint(
                  painter: _BlenderColorRampPainter(
                    stops: widget.stops,
                    selected: _selectedIndex,
                    colors: theme.colors,
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.stops.isNotEmpty)
          Row(
            children: <Widget>[
              Expanded(
                child: BlenderNumberField(
                  value: widget.stops[_selectedIndex].position,
                  min: 0,
                  max: 1,
                  step: .01,
                  decimalDigits: 2,
                  onChanged: _updateSelected,
                ),
              ),
              const SizedBox(width: 4),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.stops[_selectedIndex].color,
                  border: Border.all(color: theme.colors.borderSubtle),
                  borderRadius: BorderRadius.circular(
                    theme.shapes.controlRadius,
                  ),
                ),
                child: const SizedBox(width: 28, height: 22),
              ),
            ],
          ),
        if (widget.showControls)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              BlenderIconButton(
                glyph: BlenderGlyph.plus,
                onPressed: widget.onAdd,
                tooltip: 'Add color stop',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.minus,
                onPressed: widget.onRemove,
                tooltip: 'Remove color stop',
                size: 22,
              ),
            ],
          ),
      ],
    );
  }
}

class _BlenderColorRampPainter extends CustomPainter {
  _BlenderColorRampPainter({
    required this.stops,
    required this.selected,
    required this.colors,
  });

  final List<BlenderColorRampStop> stops;
  final int selected;
  final BlenderColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (stops.isEmpty) return;
    final ordered = stops.toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    final rect = Rect.fromLTWH(0, 4, size.width, 24);
    final gradient = LinearGradient(
      colors: [for (final stop in ordered) stop.color],
      stops: [for (final stop in ordered) stop.position.clamp(0, 1)],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
    canvas.drawRect(
      rect,
      Paint()
        ..color = colors.borderSubtle
        ..style = PaintingStyle.stroke,
    );
    for (var index = 0; index < stops.length; index++) {
      final stop = stops[index];
      final x = stop.position.clamp(0, 1) * size.width;
      final path = Path()
        ..moveTo(x - 5, 32)
        ..lineTo(x + 5, 32)
        ..lineTo(x, 25)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = index == selected ? colors.foreground : colors.borderSubtle,
      );
      canvas.drawCircle(
        Offset(x, 36),
        4,
        Paint()
          ..color = stop.color
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_BlenderColorRampPainter oldDelegate) {
    return stops != oldDelegate.stops ||
        selected != oldDelegate.selected ||
        colors != oldDelegate.colors;
  }
}
