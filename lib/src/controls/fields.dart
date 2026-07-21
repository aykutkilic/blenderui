part of '../controls.dart';

class BlenderTextField extends StatefulWidget {
  const BlenderTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.label,
    this.placeholder,
    this.leading,
    this.trailing,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.enabled = true,
    this.backgroundColor,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.obscureText = false,
    this.obscuringCharacter = '•',
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? label;
  final String? placeholder;
  final Widget? leading;
  final Widget? trailing;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final bool enabled;
  final Color? backgroundColor;
  final TextAlign textAlign;
  final int maxLines;
  final int? minLines;
  final TextInputType? keyboardType;

  /// Masks the input while retaining the standard Blender text-field chrome.
  ///
  /// Preferences commonly edit API tokens and passwords.  Keeping that use
  /// case in the base field prevents applications from rebuilding a separate
  ///, visually divergent `EditableText` control for secret values.
  final bool obscureText;
  final String obscuringCharacter;

  @override
  State<BlenderTextField> createState() => _BlenderTextFieldState();
}

class _BlenderTextFieldState extends State<BlenderTextField> {
  FocusNode? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) _internalFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(BlenderTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode == null && widget.focusNode != null) {
      _internalFocusNode?.dispose();
      _internalFocusNode = null;
    } else if (oldWidget.focusNode != null && widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final node = widget.focusNode ?? _internalFocusNode!;
    final field = EditableText(
      controller: widget.controller,
      focusNode: node,
      style: theme.textTheme.body.copyWith(
        color: widget.enabled
            ? theme.colors.foreground
            : theme.colors.foregroundDisabled,
      ),
      cursorColor: theme.colors.cursor,
      backgroundCursorColor: theme.colors.foregroundMuted,
      selectionColor: theme.colors.selection,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      readOnly: widget.readOnly || !widget.enabled,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      textAlign: widget.textAlign,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      obscuringCharacter: widget.obscuringCharacter,
    );
    return Semantics(
      textField: true,
      label: widget.label ?? widget.placeholder,
      enabled: widget.enabled,
      child: AnimatedBuilder(
        animation: node,
        builder: (context, child) => Container(
          height: widget.maxLines == 1 ? theme.density.controlHeight : null,
          // Keep the single-line text metrics inside Blender's compact
          // control height. Three pixels of vertical inset leaves the body
          // line clipped once the border is accounted for.
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? theme.colors.textField,
            border: Border.all(
              color: node.hasFocus
                  ? theme.colors.focus
                  : theme.colors.borderSubtle,
              width: node.hasFocus
                  ? theme.shapes.focusWidth
                  : theme.shapes.borderWidth,
            ),
            borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
          ),
          child: Row(
            children: <Widget>[
              if (widget.leading != null) ...<Widget>[
                widget.leading!,
                const SizedBox(width: 5),
              ],
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: <Widget>[
                    if (widget.placeholder != null &&
                        widget.controller.text.isEmpty)
                      IgnorePointer(
                        child: Text(
                          widget.placeholder!,
                          style: theme.textTheme.body.copyWith(
                            color: theme.colors.foregroundMuted,
                          ),
                        ),
                      ),
                    field,
                  ],
                ),
              ),
              if (widget.trailing != null) ...<Widget>[
                const SizedBox(width: 5),
                widget.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class BlenderSearchField extends StatelessWidget {
  const BlenderSearchField({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.placeholder = 'Search',
    this.focusNode,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String placeholder;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) => BlenderTextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        placeholder: placeholder,
        leading: const BlenderIcon(BlenderGlyph.search, size: 14),
        trailing: value.text.isEmpty
            ? null
            : BlenderIconButton(
                glyph: BlenderGlyph.close,
                size: 20,
                onPressed: controller.clear,
                tooltip: 'Clear search',
              ),
        keyboardType: TextInputType.text,
      ),
    );
  }
}

class BlenderNumberField extends StatefulWidget {
  const BlenderNumberField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.min,
    this.max,
    this.step = 1,
    this.decimalDigits = 3,
    this.suffix,
    this.fieldWidth,
    this.backgroundColor,
    this.showSteppers,
    this.enabled = true,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String? label;
  final double? min;
  final double? max;
  final double step;
  final int decimalDigits;
  final String? suffix;
  final double? fieldWidth;
  final Color? backgroundColor;

  /// Shows Blender-style increment/decrement handles while hovered.
  ///
  /// Blender's bounded factor properties use a `NumSlider` instead of a
  /// number button. Set this explicitly to override the app-wide Interface
  /// preference; use `false` for factor fields so the range fill can occupy
  /// the complete control, matching `PROP_FACTOR` behavior.
  final bool? showSteppers;
  final bool enabled;

  @override
  State<BlenderNumberField> createState() => _BlenderNumberFieldState();
}

class _BlenderNumberFieldState extends State<BlenderNumberField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hovered = false;
  bool _editing = false;
  bool _dragging = false;
  double _dragValue = 0;

  String _format(double value) => value.toStringAsFixed(widget.decimalDigits);

  double _clamp(double value) {
    var result = value;
    if (widget.min != null) result = math.max(widget.min!, result);
    if (widget.max != null) result = math.min(widget.max!, result);
    return result;
  }

  void _setValue(double value) {
    final next = _clamp(value);
    widget.onChanged(next);
    if (!_editing) _controller.text = _format(next);
  }

  double _roundForDisplay(double value) {
    if (widget.decimalDigits == 0) return value.roundToDouble();
    final multiplier = math.pow(10, widget.decimalDigits).toDouble();
    return (value * multiplier).roundToDouble() / multiplier;
  }

  void _beginEditing({required bool selectAll}) {
    if (!widget.enabled || _dragging) return;
    setState(() {
      _editing = true;
      _controller.text = _format(widget.value);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
      if (selectAll) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      }
    });
  }

  void _finishEditing() {
    final parsed = double.tryParse(_controller.text);
    final next = parsed == null ? widget.value : _clamp(parsed);
    widget.onChanged(next);
    _controller.text = _format(next);
    if (mounted) setState(() => _editing = false);
  }

  double _dragIncrement(DragUpdateDetails details) {
    final range = widget.min != null && widget.max != null
        ? (widget.max! - widget.min!).abs()
        : 0.0;
    final isInteger = widget.decimalDigits == 0;
    final base = isInteger
        ? (range > 256
              ? 1.0
              : range > 32
              ? .5
              : 1 / 16)
        : math.max(widget.step * .01, math.pow(10, -widget.decimalDigits));
    final nonlinear = range > (isInteger ? 129 : 11)
        ? 1 + details.globalPosition.dx.abs() / (isInteger ? 250 : 500)
        : 1.0;
    final precision = HardwareKeyboard.instance.isShiftPressed ? .1 : 1.0;
    return details.delta.dx * base * nonlinear * precision;
  }

  void _beginDrag() {
    if (!widget.enabled) return;
    _focusNode.unfocus();
    setState(() {
      _editing = false;
      _dragging = true;
      _dragValue = widget.value;
    });
  }

  void _updateDrag(DragUpdateDetails details) {
    if (!_dragging) return;
    _dragValue = _roundForDisplay(_clamp(_dragValue + _dragIncrement(details)));
    widget.onChanged(_dragValue);
    _controller.text = _format(_dragValue);
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _editing) _finishEditing();
    });
  }

  @override
  void didUpdateWidget(BlenderNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && oldWidget.value != widget.value) {
      _controller.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final showSteppers =
        widget.showSteppers ??
        BlenderServiceScope.maybeRead<BlenderInterfacePreferencesService>(
          context,
        )?.value.showNumericInputArrows ??
        true;
    final range = widget.min != null && widget.max != null
        ? widget.max! - widget.min!
        : 0.0;
    final fraction = range > 0
        ? ((widget.value - widget.min!) / range).clamp(0.0, 1.0).toDouble()
        : 0.0;
    final radius = BorderRadius.circular(theme.shapes.controlRadius);
    final label = widget.label == null
        ? null
        : GestureDetector(
            onHorizontalDragUpdate: widget.enabled
                ? (details) => _setValue(
                    widget.value + details.delta.dx * widget.step * .1,
                  )
                : null,
            child: Text(widget.label!, style: theme.textTheme.label),
          );
    final field = BlenderTextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      // Blender keeps a factor field's slider layer visible while its value
      // is edited. The range fill is supplied by the parent stack below.
      backgroundColor: !showSteppers && range > 0
          ? const Color(0x00000000)
          : widget.backgroundColor ?? theme.colors.button,
      textAlign: TextAlign.center,
      leading: _hovered && showSteppers
          ? _BlenderNumberStepper(
              previous: true,
              onPressed: () => _setValue(widget.value - widget.step),
            )
          : null,
      trailing: _hovered && showSteppers
          ? _BlenderNumberStepper(
              previous: false,
              onPressed: () => _setValue(widget.value + widget.step),
            )
          : null,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      onChanged: (text) {
        final parsed = double.tryParse(text);
        if (parsed != null) widget.onChanged(_clamp(parsed));
      },
      onSubmitted: (text) {
        _finishEditing();
      },
    );
    final editingField = !showSteppers && range > 0
        ? _BlenderNumberRangeSurface(
            height: theme.density.controlHeight,
            radius: radius,
            backgroundColor: widget.backgroundColor ?? theme.colors.button,
            fraction: fraction,
            fillColor: widget.enabled
                ? theme.colors.buttonSelected
                : theme.colors.borderSubtle,
            child: field,
          )
        : field;
    final display = MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.resizeColumn
          : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _beginEditing(selectAll: false),
        onDoubleTap: () => _beginEditing(selectAll: true),
        onHorizontalDragStart: widget.enabled ? (_) => _beginDrag() : null,
        onHorizontalDragUpdate: widget.enabled ? _updateDrag : null,
        onHorizontalDragEnd: widget.enabled
            ? (_) => setState(() => _dragging = false)
            : null,
        onHorizontalDragCancel: widget.enabled
            ? () => setState(() => _dragging = false)
            : null,
        child: _BlenderNumberRangeSurface(
          surfaceKey: const ValueKey<String>('blender-number-field-surface'),
          height: theme.density.controlHeight,
          radius: radius,
          backgroundColor: _dragging
              ? theme.colors.textField
              : widget.backgroundColor ?? theme.colors.button,
          fraction: range > 0 ? fraction : null,
          fillColor: widget.enabled
              ? theme.colors.buttonSelected
              : theme.colors.borderSubtle,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _hovered ? 1 : 6),
            child: Row(
              children: <Widget>[
                if (_hovered && showSteppers)
                  _BlenderNumberStepper(
                    previous: true,
                    onPressed: () => _setValue(widget.value - widget.step),
                  ),
                Expanded(
                  child: Text(
                    '${_format(widget.value)}${widget.suffix ?? ''}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.body.copyWith(
                      color: widget.enabled
                          ? theme.colors.foreground
                          : theme.colors.foregroundDisabled,
                    ),
                  ),
                ),
                if (_hovered && showSteppers)
                  _BlenderNumberStepper(
                    previous: false,
                    onPressed: () => _setValue(widget.value + widget.step),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    return MouseRegion(
      child: Row(
        children: <Widget>[
          if (label != null) Expanded(child: label),
          if (widget.fieldWidth == null && widget.label == null)
            Expanded(child: _editing ? editingField : display)
          else
            Flexible(
              fit: FlexFit.loose,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: widget.fieldWidth ?? 90),
                child: _editing ? editingField : display,
              ),
            ),
        ],
      ),
    );
  }
}

class _BlenderNumberRangeSurface extends StatelessWidget {
  const _BlenderNumberRangeSurface({
    this.surfaceKey,
    required this.height,
    required this.radius,
    required this.backgroundColor,
    required this.fraction,
    required this.fillColor,
    required this.child,
  });

  final Key? surfaceKey;
  final double height;
  final BorderRadius radius;
  final Color backgroundColor;
  final double? fraction;
  final Color fillColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: surfaceKey,
      height: height,
      decoration: BoxDecoration(color: backgroundColor, borderRadius: radius),
      // The outer surface owns the rounded shape. Clipping one square range
      // layer to that shape keeps the selected color flush with the leading
      // edge instead of exposing the backdrop through a separately
      // anti-aliased leading cap. Display and text-edit modes share this path.
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (fraction != null)
            _BlenderNumberRangeFill(fraction: fraction!, color: fillColor),
          child,
        ],
      ),
    );
  }
}

class _BlenderNumberRangeFill extends StatelessWidget {
  const _BlenderNumberRangeFill({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: fraction,
        heightFactor: 1,
        child: DecoratedBox(decoration: BoxDecoration(color: color)),
      ),
    );
  }
}

class _BlenderNumberStepper extends StatelessWidget {
  const _BlenderNumberStepper({
    required this.previous,
    required this.onPressed,
  });

  final bool previous;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox(
        width: 16,
        height: theme.density.controlHeight,
        child: Center(
          child: RotatedBox(
            quarterTurns: previous ? 2 : 0,
            child: BlenderIcon(
              BlenderGlyph.chevronRight,
              size: 11,
              color: theme.colors.foreground,
            ),
          ),
        ),
      ),
    );
  }
}
