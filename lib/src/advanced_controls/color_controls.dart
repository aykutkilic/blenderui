part of '../advanced_controls.dart';

/// Compact host-driven color sampling control matching Blender's eyedropper.
///
/// The package owns the active, disabled, tooltip, and icon presentation. The
/// embedding application owns screen sampling, cancellation, and the sampled
/// value because those depend on the host platform and document model.
class BlenderEyedropper extends StatelessWidget {
  const BlenderEyedropper({
    super.key,
    this.active = false,
    this.enabled = true,
    this.onPressed,
    this.tooltip = 'Eyedropper',
    this.size = 22,
  });

  final bool active;
  final bool enabled;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;

  @override
  Widget build(BuildContext context) => BlenderIconButton(
    glyph: BlenderGlyph.eyedropper,
    selected: active,
    enabled: enabled,
    onPressed: onPressed,
    tooltip: tooltip,
    size: size,
  );
}

class BlenderColorSwatch extends StatelessWidget {
  const BlenderColorSwatch({
    super.key,
    required this.color,
    this.onPressed,
    this.size = 22,
    this.tooltip,
  });

  final Color color;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    Widget child = Semantics(
      label: tooltip,
      button: onPressed != null,
      enabled: onPressed != null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
        ),
      ),
    );
    if (onPressed != null) {
      child = GestureDetector(onTap: onPressed, child: child);
    }
    if (tooltip != null) {
      child = BlenderTooltip(message: tooltip!, child: child);
    }
    return child;
  }
}

class BlenderColorField extends StatelessWidget {
  const BlenderColorField({
    super.key,
    required this.color,
    this.label,
    this.onPressed,
    this.enabled = true,
  });

  final Color color;
  final String? label;
  final VoidCallback? onPressed;
  final bool enabled;

  String get _hex =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final content = GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        height: theme.density.controlHeight,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: theme.colors.textField,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              BlenderColorSwatch(color: color, size: 14),
              const SizedBox(width: 5),
              Text(
                _hex,
                style: theme.textTheme.caption.copyWith(
                  color: enabled
                      ? theme.colors.foreground
                      : theme.colors.foregroundDisabled,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return label == null
        ? content
        : Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label!,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.label,
                ),
              ),
              Flexible(child: content),
            ],
          );
  }
}

class BlenderColorPicker extends StatefulWidget {
  const BlenderColorPicker({
    super.key,
    required this.color,
    required this.onChanged,
    this.showFields = true,
    this.showAlpha = true,
  });

  final Color color;
  final ValueChanged<Color> onChanged;
  final bool showFields;
  final bool showAlpha;

  @override
  State<BlenderColorPicker> createState() => _BlenderColorPickerState();
}

class _BlenderColorPickerState extends State<BlenderColorPicker> {
  late HSVColor _hsv = HSVColor.fromColor(widget.color);

  @override
  void didUpdateWidget(BlenderColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      _hsv = HSVColor.fromColor(widget.color);
    }
  }

  void _setColor(HSVColor value) {
    setState(() => _hsv = value);
    widget.onChanged(value.toColor());
  }

  void _updateSaturationValue(Offset localPosition, Size size) {
    final saturation = (localPosition.dx / size.width).clamp(0, 1).toDouble();
    final value = (1 - localPosition.dy / size.height).clamp(0, 1).toDouble();
    _setColor(_hsv.withSaturation(saturation).withValue(value));
  }

  void _updateHue(Offset localPosition, Size size) {
    final hue = (localPosition.dx / size.width * 360).clamp(0, 360).toDouble();
    _setColor(_hsv.withHue(hue));
  }

  void _updateChannel(int channel, double value) {
    final current = _hsv.toColor();
    final red = channel == 0 ? value : current.r;
    final green = channel == 1 ? value : current.g;
    final blue = channel == 2 ? value : current.b;
    final alpha = channel == 3 ? value : current.a;
    _setColor(
      HSVColor.fromColor(
        Color.fromARGB(
          (alpha * 255).round(),
          (red * 255).round(),
          (green * 255).round(),
          (blue * 255).round(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final currentColor = _hsv.toColor();
    final channels = <double>[
      currentColor.r,
      currentColor.g,
      currentColor.b,
      if (widget.showAlpha) currentColor.a,
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.panelSubSurface,
        border: Border.all(color: theme.colors.editorBorder),
        borderRadius: BorderRadius.circular(theme.shapes.panelRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 150,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) => _updateSaturationValue(
                      details.localPosition,
                      constraints.biggest,
                    ),
                    onPanUpdate: (details) => _updateSaturationValue(
                      details.localPosition,
                      constraints.biggest,
                    ),
                    child: CustomPaint(
                      painter: _BlenderColorPickerPainter(hsv: _hsv),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 18,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) =>
                        _updateHue(details.localPosition, constraints.biggest),
                    onHorizontalDragUpdate: (details) =>
                        _updateHue(details.localPosition, constraints.biggest),
                    child: const CustomPaint(painter: _BlenderHuePainter()),
                  );
                },
              ),
            ),
            if (widget.showFields) ...<Widget>[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: <Widget>[
                  for (var channel = 0; channel < channels.length; channel++)
                    SizedBox(
                      width: 100,
                      child: BlenderNumberField(
                        label: const <String>['R', 'G', 'B', 'A'][channel],
                        value: channels[channel],
                        min: 0,
                        max: 1,
                        step: .01,
                        decimalDigits: 2,
                        onChanged: (value) => _updateChannel(channel, value),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                BlenderColorSwatch(color: currentColor, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '#${currentColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.caption,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BlenderColorPickerPainter extends CustomPainter {
  const _BlenderColorPickerPainter({required this.hsv});

  final HSVColor hsv;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final hueColor = hsv.withSaturation(1).withValue(1).toColor();
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: <Color>[const Color(0xFFFFFFFF), hueColor],
        ).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0x00000000), Color(0xFF000000)],
        ).createShader(rect),
    );
    final cursor = Offset(
      hsv.saturation * size.width,
      (1 - hsv.value) * size.height,
    );
    canvas.drawCircle(
      cursor,
      6,
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_BlenderColorPickerPainter oldDelegate) =>
      hsv != oldDelegate.hsv;
}

class _BlenderHuePainter extends CustomPainter {
  const _BlenderHuePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final colors = <Color>[
      for (var i = 0; i <= 6; i++)
        HSVColor.fromAHSV(1, i * 60.0 % 360, 1, 1).toColor(),
    ];
    canvas.drawRect(
      rect,
      Paint()..shader = LinearGradient(colors: colors).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_BlenderHuePainter oldDelegate) => false;
}
