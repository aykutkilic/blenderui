import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'icons.dart';
import 'theme.dart';

enum BlenderControlState {
  hovered,
  focused,
  pressed,
  selected,
  disabled,
  dragged,
}

typedef BlenderStateResolver<T> = T Function(Set<BlenderControlState> states);

enum BlenderButtonVariant {
  regular,
  toolbar,
  tab,
  menu,
  menuTrigger,
  tool,
  topBar,
}

class BlenderStateProperty<T> {
  const BlenderStateProperty(this.resolve);

  final BlenderStateResolver<T> resolve;

  T resolveAs(Set<BlenderControlState> states) => resolve(states);
}

class BlenderButton extends StatefulWidget {
  const BlenderButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.selected = false,
    this.variant = BlenderButtonVariant.regular,
    this.width,
    this.padding,
    this.showBorder = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;
  final bool selected;
  final BlenderButtonVariant variant;
  final double? width;
  final EdgeInsets? padding;
  final bool showBorder;

  @override
  State<BlenderButton> createState() => _BlenderButtonState();
}

class _BlenderButtonState extends State<BlenderButton> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _enabled => widget.enabled && widget.onPressed != null;

  void _invoke() {
    if (_enabled) widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final normalBackground = switch (widget.variant) {
      BlenderButtonVariant.regular => theme.colors.button,
      BlenderButtonVariant.toolbar ||
      BlenderButtonVariant.tool => theme.colors.surface,
      BlenderButtonVariant.tab => theme.colors.tab,
      BlenderButtonVariant.menu => theme.colors.menuBackground,
      BlenderButtonVariant.menuTrigger => theme.colors.surface,
      BlenderButtonVariant.topBar => theme.colors.canvas,
    };
    final hoverBackground = switch (widget.variant) {
      BlenderButtonVariant.tab => theme.colors.tabSelected,
      BlenderButtonVariant.menu => theme.colors.menuSelection,
      BlenderButtonVariant.menuTrigger => theme.colors.buttonSelected.withAlpha(
        0xB3,
      ),
      BlenderButtonVariant.topBar => theme.colors.surfaceRaised,
      _ => theme.colors.buttonHover,
    };
    final selectedBackground = switch (widget.variant) {
      BlenderButtonVariant.tab => theme.colors.tabSelected,
      BlenderButtonVariant.menu => theme.colors.menuSelection,
      BlenderButtonVariant.menuTrigger => theme.colors.buttonSelected.withAlpha(
        0xB3,
      ),
      BlenderButtonVariant.topBar => theme.colors.surfaceRaised,
      _ => theme.colors.buttonSelected,
    };
    final background = widget.selected
        ? selectedBackground
        : _pressed
        ? theme.colors.buttonPressed
        : _hovered
        ? hoverBackground
        : normalBackground;
    final foreground = _enabled
        ? theme.colors.foreground
        : theme.colors.foregroundDisabled;

    return SizedBox(
      width: widget.width,
      height: theme.density.controlHeight,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: FocusableActionDetector(
          enabled: _enabled,
          onShowFocusHighlight: (value) => setState(() => _focused = value),
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                _invoke();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _enabled ? _invoke : null,
            onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
            onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
            onTapCancel: _enabled
                ? () => setState(() => _pressed = false)
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              padding:
                  widget.padding ??
                  EdgeInsets.symmetric(horizontal: theme.density.spacing * 2),
              decoration: BoxDecoration(
                color: background,
                border: _focused
                    ? Border.all(
                        color: theme.colors.focus,
                        width: theme.shapes.focusWidth,
                      )
                    : widget.showBorder &&
                          widget.variant != BlenderButtonVariant.topBar
                    ? Border.all(
                        color: theme.colors.borderSubtle,
                        width: theme.shapes.borderWidth,
                      )
                    : null,
                borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
              ),
              child: DefaultTextStyle(
                style: theme.textTheme.label.copyWith(color: foreground),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Editor headers can intentionally collapse controls to a
                    // single icon.  Keep that state layout-safe instead of
                    // allowing a Row to paint outside an ultra-narrow button.
                    if (constraints.maxWidth < 36 &&
                        widget.label.isEmpty &&
                        widget.leading != null &&
                        widget.trailing != null) {
                      return Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              widget.leading!,
                              SizedBox(width: theme.density.spacing),
                              widget.trailing!,
                            ],
                          ),
                        ),
                      );
                    }
                    if (constraints.maxWidth < 36 &&
                        !(widget.label.isEmpty &&
                            widget.leading != null &&
                            widget.trailing != null)) {
                      final compactChild =
                          widget.leading ??
                          widget.trailing ??
                          Text(widget.label, overflow: TextOverflow.ellipsis);
                      return Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: compactChild,
                        ),
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (widget.leading != null) ...<Widget>[
                          widget.leading!,
                          if (widget.label.isNotEmpty)
                            SizedBox(width: theme.density.spacing),
                        ],
                        Flexible(
                          child: Text(
                            widget.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.trailing != null) ...<Widget>[
                          SizedBox(width: theme.density.spacing),
                          widget.trailing!,
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BlenderIconButton extends StatelessWidget {
  const BlenderIconButton({
    super.key,
    required this.glyph,
    this.onPressed,
    this.tooltip,
    this.selected = false,
    this.enabled = true,
    this.size = 28,
    this.variant = BlenderButtonVariant.toolbar,
  });

  final BlenderGlyph glyph;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool selected;
  final bool enabled;
  final double size;
  final BlenderButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    Widget result = BlenderButton(
      label: '',
      width: size,
      onPressed: onPressed,
      enabled: enabled,
      selected: selected,
      variant: variant,
      padding: EdgeInsets.zero,
      leading: BlenderIcon(glyph, size: 15),
    );
    if (tooltip != null) {
      result = BlenderTooltip(message: tooltip!, child: result);
    }
    return result;
  }
}

class BlenderToggle extends StatelessWidget {
  const BlenderToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final active = enabled && onChanged != null;
    final child = GestureDetector(
      onTap: active ? () => onChanged!(!value) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 28,
            height: 16,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: value ? theme.colors.buttonSelected : theme.colors.button,
              border: Border.all(color: theme.colors.borderSubtle),
              borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
            ),
            child: Align(
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: value
                      ? theme.colors.foreground
                      : theme.colors.foregroundMuted,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox.square(dimension: 10),
              ),
            ),
          ),
          if (label != null) ...<Widget>[
            SizedBox(width: theme.density.spacing),
            Text(
              label!,
              style: theme.textTheme.label.copyWith(
                color: active
                    ? theme.colors.foreground
                    : theme.colors.foregroundDisabled,
              ),
            ),
          ],
        ],
      ),
    );
    return Semantics(
      toggled: value,
      enabled: active,
      label: label,
      button: true,
      child: child,
    );
  }
}

class BlenderCheckbox extends StatelessWidget {
  const BlenderCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final active = enabled && onChanged != null;
    return GestureDetector(
      onTap: active ? () => onChanged!(!value) : null,
      child: Semantics(
        checked: value,
        enabled: active,
        label: label,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: value
                    ? theme.colors.buttonSelected
                    : theme.colors.button,
                border: Border.all(
                  color: value
                      ? theme.colors.buttonSelected
                      : const Color(0xFF3D3D3D),
                ),
                borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
              ),
              child: value
                  ? const ExcludeSemantics(
                      child: BlenderIcon(BlenderGlyph.check, size: 13),
                    )
                  : null,
            ),
            if (label != null) ...<Widget>[
              SizedBox(width: theme.density.spacing),
              Flexible(
                child: Text(
                  label!,
                  style: theme.textTheme.label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BlenderRadio<T> extends StatelessWidget {
  const BlenderRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final String? label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final selected = value == groupValue;
    final active = enabled && onChanged != null;
    return GestureDetector(
      onTap: active ? () => onChanged!(value) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? theme.colors.buttonSelected
                    : theme.colors.borderSubtle,
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: selected
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colors.buttonSelected,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
          if (label != null) ...<Widget>[
            SizedBox(width: theme.density.spacing),
            Flexible(
              child: Text(
                label!,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.label.copyWith(
                  color: active
                      ? theme.colors.foreground
                      : theme.colors.foregroundDisabled,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class BlenderSlider extends StatelessWidget {
  const BlenderSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.enabled = true,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final bool enabled;

  double _valueForWidth(double width, double localX) {
    final raw = min + (max - min) * (localX / math.max(1, width));
    final clamped = raw.clamp(min, max).toDouble();
    if (divisions == null || divisions == 0) return clamped;
    final step = (max - min) / divisions!;
    return ((clamped - min) / step).round() * step + min;
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final active = enabled && onChanged != null;
    final step = (max - min) / 20;
    final increasedValue = (value + step).clamp(min, max).toStringAsFixed(2);
    final decreasedValue = (value - step).clamp(min, max).toStringAsFixed(2);
    void update(double width, double x) {
      if (active) onChanged!(_valueForWidth(width, x));
    }

    return Semantics(
      slider: true,
      enabled: active,
      value: value.toStringAsFixed(2),
      increasedValue: increasedValue,
      decreasedValue: decreasedValue,
      onIncrease: active
          ? () => onChanged!(double.parse(increasedValue))
          : null,
      onDecrease: active
          ? () => onChanged!(double.parse(decreasedValue))
          : null,
      child: SizedBox(
        height: 28,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: active
                  ? (details) =>
                        update(constraints.maxWidth, details.localPosition.dx)
                  : null,
              onHorizontalDragUpdate: active
                  ? (details) =>
                        update(constraints.maxWidth, details.localPosition.dx)
                  : null,
              child: CustomPaint(
                painter: _BlenderSliderPainter(
                  value: value,
                  min: min,
                  max: max,
                  active: active,
                  colors: theme.colors,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BlenderSliderPainter extends CustomPainter {
  _BlenderSliderPainter({
    required this.value,
    required this.min,
    required this.max,
    required this.active,
    required this.colors,
  });

  final double value;
  final double min;
  final double max;
  final bool active;
  final BlenderColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    final trackY = size.height / 2;
    const left = 7.0;
    final right = math.max(left, size.width - 7);
    final fraction = ((value - min) / (max - min)).clamp(0.0, 1.0).toDouble();
    final thumbX = left + (right - left) * fraction;
    final track = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = active ? colors.borderSubtle : colors.border;
    canvas.drawLine(Offset(left, trackY), Offset(right, trackY), track);
    track.color = active ? colors.accent : colors.foregroundDisabled;
    canvas.drawLine(Offset(left, trackY), Offset(thumbX, trackY), track);
    canvas.drawCircle(Offset(thumbX, trackY), 6, Paint()..color = track.color);
  }

  @override
  bool shouldRepaint(_BlenderSliderPainter oldDelegate) {
    return value != oldDelegate.value ||
        active != oldDelegate.active ||
        colors != oldDelegate.colors;
  }
}

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
    );
    return Semantics(
      textField: true,
      label: widget.label ?? widget.placeholder,
      enabled: widget.enabled,
      child: AnimatedBuilder(
        animation: node,
        builder: (context, child) => Container(
          height: widget.maxLines == 1 ? theme.density.controlHeight : null,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) => BlenderTextField(
        controller: controller,
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
    this.fieldWidth,
    this.backgroundColor,
    this.enabled = true,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String? label;
  final double? min;
  final double? max;
  final double step;
  final int decimalDigits;
  final double? fieldWidth;
  final Color? backgroundColor;
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
      backgroundColor: widget.backgroundColor ?? theme.colors.button,
      textAlign: TextAlign.center,
      leading: _hovered
          ? _BlenderNumberStepper(
              label: '‹',
              onPressed: () => _setValue(widget.value - widget.step),
            )
          : null,
      trailing: _hovered
          ? _BlenderNumberStepper(
              label: '›',
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
        child: Container(
          height: theme.density.controlHeight,
          padding: EdgeInsets.symmetric(horizontal: _hovered ? 1 : 6),
          decoration: BoxDecoration(
            color: _dragging
                ? theme.colors.textField
                : widget.backgroundColor ?? theme.colors.button,
            border: Border.all(color: theme.colors.borderSubtle),
            borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
          ),
          child: Row(
            children: <Widget>[
              if (_hovered)
                _BlenderNumberStepper(
                  label: '‹',
                  onPressed: () => _setValue(widget.value - widget.step),
                ),
              Expanded(
                child: Text(
                  _format(widget.value),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.body.copyWith(
                    color: widget.enabled
                        ? theme.colors.foreground
                        : theme.colors.foregroundDisabled,
                  ),
                ),
              ),
              if (_hovered)
                _BlenderNumberStepper(
                  label: '›',
                  onPressed: () => _setValue(widget.value + widget.step),
                ),
            ],
          ),
        ),
      ),
    );
    return MouseRegion(
      child: Row(
        children: <Widget>[
          if (label != null) Expanded(child: label),
          if (widget.fieldWidth == null && widget.label == null)
            Expanded(child: _editing ? field : display)
          else
            Flexible(
              fit: FlexFit.loose,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: widget.fieldWidth ?? 90),
                child: _editing ? field : display,
              ),
            ),
        ],
      ),
    );
  }
}

class _BlenderNumberStepper extends StatelessWidget {
  const _BlenderNumberStepper({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox(
        width: 18,
        height: theme.density.controlHeight - 2,
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.body.copyWith(
              color: theme.colors.foreground,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }
}

class BlenderTooltip extends StatefulWidget {
  const BlenderTooltip({
    super.key,
    required this.message,
    required this.child,
    this.content,
  });

  final String message;
  final Widget child;
  final Widget? content;

  @override
  State<BlenderTooltip> createState() => _BlenderTooltipState();
}

/// Shows a centered Blender-style modal surface.
///
/// Blender uses the same popup theme for operator dialogs, confirmation
/// prompts, and property dialogs. Keeping the route creation here means
/// callers do not accidentally fall back to a Material dialog when the
/// package is hosted below a plain [WidgetsApp].
Future<T?> showBlenderDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String barrierLabel = 'Dismiss dialog',
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: const Color(0x99000000),
    transitionDuration: const Duration(milliseconds: 120),
    pageBuilder: (dialogContext, animation, secondaryAnimation) =>
        SafeArea(child: Center(child: builder(dialogContext))),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: .96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// A compact action descriptor for [BlenderDialog].
class BlenderDialogAction {
  const BlenderDialogAction({
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool primary;
  final bool enabled;
}

/// The shared visual shell for centered Blender operator and alert dialogs.
class BlenderDialog extends StatelessWidget {
  const BlenderDialog({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.content,
    this.actions = const <BlenderDialogAction>[],
    this.width = 420,
    this.small = false,
  });

  final String? title;
  final String? message;
  final Widget? icon;
  final Widget? content;
  final List<BlenderDialogAction> actions;
  final double width;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final padding = small ? 7.0 : 14.0;
    final messageLines = message
        ?.trim()
        .split('\n')
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    final body = <Widget>[
      if (title != null && title!.isNotEmpty)
        Text(title!, style: theme.textTheme.heading),
      if (messageLines != null && messageLines.isNotEmpty) ...<Widget>[
        if (title != null && title!.isNotEmpty) const SizedBox(height: 10),
        for (var index = 0; index < messageLines.length; index++) ...<Widget>[
          if (index > 0) const SizedBox(height: 2),
          Text(
            messageLines[index],
            style: theme.textTheme.body.copyWith(
              color: theme.colors.foregroundMuted,
            ),
          ),
        ],
      ],
      if (content != null) ...<Widget>[
        if (title != null || (messageLines?.isNotEmpty ?? false))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              height: 1,
              child: ColoredBox(color: theme.colors.borderSubtle),
            ),
          ),
        content!,
      ],
      if (actions.isNotEmpty) ...<Widget>[
        SizedBox(height: small ? 8 : 14),
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              for (final action in actions)
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 88),
                  child: BlenderButton(
                    label: action.label,
                    selected: action.primary,
                    enabled: action.enabled,
                    onPressed: action.enabled ? action.onPressed : null,
                  ),
                ),
            ],
          ),
        ),
      ],
    ];
    final dialogBody = icon == null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: body,
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 1),
                child: icon,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: body,
                ),
              ),
            ],
          );
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: small ? 280 : 320,
        maxWidth: width,
        maxHeight: MediaQuery.sizeOf(context).height - 28,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.menuBackground,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: dialogBody,
        ),
      ),
    );
  }
}

/// Convenience implementation of Blender's confirmation/alert dialog.
class BlenderAlertDialog extends StatelessWidget {
  const BlenderAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = BlenderGlyph.warning,
    this.confirmLabel = 'OK',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.content,
    this.width = 420,
  });

  final String title;
  final String message;
  final BlenderGlyph? icon;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Widget? content;
  final double width;

  void _close(BuildContext context, VoidCallback? callback, bool result) {
    callback?.call();
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final iconWidget = icon == null
        ? null
        : BlenderIcon(
            icon!,
            size: 34,
            color: icon == BlenderGlyph.error
                ? theme.colors.error
                : icon == BlenderGlyph.warning
                ? theme.colors.warning
                : theme.colors.info,
          );
    return BlenderDialog(
      title: title,
      message: message,
      icon: iconWidget,
      content: content,
      width: width,
      actions: <BlenderDialogAction>[
        BlenderDialogAction(
          label: cancelLabel,
          onPressed: () => _close(context, onCancel, false),
        ),
        BlenderDialogAction(
          label: confirmLabel,
          primary: true,
          onPressed: () => _close(context, onConfirm, true),
        ),
      ],
    );
  }
}

/// Opens [BlenderAlertDialog] using the package's modal route and theme.
Future<bool?> showBlenderAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  BlenderGlyph? icon = BlenderGlyph.warning,
  String confirmLabel = 'OK',
  String cancelLabel = 'Cancel',
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  Widget? content,
  double width = 420,
  bool barrierDismissible = true,
}) {
  return showBlenderDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) => BlenderAlertDialog(
      title: title,
      message: message,
      icon: icon,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      onConfirm: onConfirm,
      onCancel: onCancel,
      content: content,
      width: width,
    ),
  );
}

/// An interactive anchored overlay for Blender-style popovers and inspectors.
class BlenderPopover extends StatefulWidget {
  const BlenderPopover({
    super.key,
    required this.child,
    required this.popover,
    this.offset = const Offset(0, 4),
    this.targetAnchor = Alignment.bottomLeft,
    this.followerAnchor = Alignment.topLeft,
    this.onOpenChanged,
    this.openOnHover = false,
    this.hoverDelay = const Duration(milliseconds: 200),
  });

  final Widget child;
  final Widget Function(BuildContext context, VoidCallback close) popover;
  final Offset offset;
  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final ValueChanged<bool>? onOpenChanged;
  final bool openOnHover;
  final Duration hoverDelay;

  @override
  State<BlenderPopover> createState() => _BlenderPopoverState();
}

class _BlenderPopoverState extends State<BlenderPopover> {
  RenderBox? _targetRenderObject;
  Timer? _hoverTimer;
  bool _open = false;

  Future<void> _show() async {
    if (_open) return;
    _hoverTimer?.cancel();
    final renderObject = _targetRenderObject;
    if (renderObject is! RenderBox) return;
    final origin = renderObject.localToGlobal(Offset.zero);
    setState(() => _open = true);
    widget.onOpenChanged?.call(true);
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss popover',
      barrierColor: const Color(0x00000000),
      transitionDuration: const Duration(milliseconds: 80),
      pageBuilder: (dialogContext, animation, secondaryAnimation) => Stack(
        children: <Widget>[
          CustomSingleChildLayout(
            delegate: _BlenderPopoverPositionDelegate(
              target: Rect.fromLTWH(
                origin.dx,
                origin.dy,
                renderObject.size.width,
                renderObject.size.height,
              ),
              offset: widget.offset,
              targetAnchor: widget.targetAnchor,
              followerAnchor: widget.followerAnchor,
            ),
            child: widget.popover(
              dialogContext,
              () => Navigator.of(dialogContext).pop(),
            ),
          ),
        ],
      ),
    );
    if (mounted) {
      setState(() => _open = false);
      widget.onOpenChanged?.call(false);
    }
  }

  void _hide() {
    if (_open) Navigator.of(context).pop();
  }

  void _scheduleHoverShow() {
    if (!widget.openOnHover || _open) return;
    _hoverTimer?.cancel();
    _hoverTimer = Timer(widget.hoverDelay, _show);
  }

  void _cancelHoverShow() {
    _hoverTimer?.cancel();
    _hoverTimer = null;
  }

  @override
  void dispose() {
    _cancelHoverShow();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BlenderPopoverAnchor(
      onLaidOut: (renderObject) => _targetRenderObject = renderObject,
      child: MouseRegion(
        onEnter: (_) => _scheduleHoverShow(),
        onExit: (_) => _cancelHoverShow(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _open ? _hide : _show,
          child: widget.child,
        ),
      ),
    );
  }
}

class _BlenderPopoverPositionDelegate extends SingleChildLayoutDelegate {
  const _BlenderPopoverPositionDelegate({
    required this.target,
    required this.offset,
    required this.targetAnchor,
    required this.followerAnchor,
  });

  final Rect target;
  final Offset offset;
  final Alignment targetAnchor;
  final Alignment followerAnchor;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.loosen().copyWith(
      maxWidth: math.max(0, constraints.maxWidth - 8),
      maxHeight: math.max(0, constraints.maxHeight - 8),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final targetPoint = Offset(
      target.left + target.width * (targetAnchor.x + 1) / 2,
      target.top + target.height * (targetAnchor.y + 1) / 2,
    );
    final followerOffset = Offset(
      childSize.width * (followerAnchor.x + 1) / 2,
      childSize.height * (followerAnchor.y + 1) / 2,
    );
    final desired = targetPoint + offset - followerOffset;
    return Offset(
      desired.dx.clamp(4, math.max(4, size.width - childSize.width - 4)),
      desired.dy.clamp(4, math.max(4, size.height - childSize.height - 4)),
    );
  }

  @override
  bool shouldRelayout(_BlenderPopoverPositionDelegate oldDelegate) {
    return target != oldDelegate.target ||
        offset != oldDelegate.offset ||
        targetAnchor != oldDelegate.targetAnchor ||
        followerAnchor != oldDelegate.followerAnchor;
  }
}

class _BlenderPopoverAnchor extends SingleChildRenderObjectWidget {
  const _BlenderPopoverAnchor({required this.onLaidOut, required super.child});

  final ValueChanged<RenderBox> onLaidOut;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _BlenderPopoverAnchorRenderObject(onLaidOut);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _BlenderPopoverAnchorRenderObject renderObject,
  ) {
    renderObject.onLaidOut = onLaidOut;
  }
}

class _BlenderPopoverAnchorRenderObject extends RenderProxyBox {
  _BlenderPopoverAnchorRenderObject(this.onLaidOut);

  ValueChanged<RenderBox> onLaidOut;

  @override
  void performLayout() {
    if (child == null) {
      size = constraints.smallest;
      onLaidOut(this);
      return;
    }
    child!.layout(constraints.loosen(), parentUsesSize: true);
    size = constraints.constrain(child!.size);
    onLaidOut(child!);
  }
}

class _BlenderTooltipState extends State<BlenderTooltip> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;

  void _show() {
    if (_entry != null) return;
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    final theme = BlenderTheme.of(context);
    _entry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: const Offset(0, 4),
            showWhenUnlinked: false,
            child: Align(
              alignment: Alignment.topLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colors.menuBackground,
                  border: Border.all(color: theme.colors.borderSubtle),
                  borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child:
                      widget.content ??
                      Text(
                        widget.message,
                        style: theme.textTheme.caption.copyWith(
                          color: theme.colors.foreground,
                        ),
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_entry!);
  }

  void _hide() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: Semantics(
        label: widget.message,
        child: MouseRegion(
          onEnter: (_) => _show(),
          onExit: (_) => _hide(),
          child: widget.child,
        ),
      ),
    );
  }
}

class BlenderMenuItem<T> {
  const BlenderMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
    this.selected = false,
    this.shortcut,
    this.separator = false,
    this.submenu,
  });

  final T value;
  final String label;
  final Widget? icon;
  final bool enabled;
  final bool selected;
  final String? shortcut;
  final bool separator;
  final List<BlenderMenuItem<T>>? submenu;

  BlenderMenuItem<T> copyWith({
    T? value,
    String? label,
    Widget? icon,
    bool? enabled,
    bool? selected,
    String? shortcut,
    bool? separator,
    List<BlenderMenuItem<T>>? submenu,
  }) {
    return BlenderMenuItem<T>(
      value: value ?? this.value,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      enabled: enabled ?? this.enabled,
      selected: selected ?? this.selected,
      shortcut: shortcut ?? this.shortcut,
      separator: separator ?? this.separator,
      submenu: submenu ?? this.submenu,
    );
  }
}

class BlenderDropdown<T> extends StatefulWidget {
  const BlenderDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.compact = false,
  });

  final T? value;
  final List<BlenderMenuItem<T>> items;
  final ValueChanged<T>? onChanged;
  final bool enabled;
  final bool compact;

  @override
  State<BlenderDropdown<T>> createState() => _BlenderDropdownState<T>();
}

class _BlenderDropdownState<T> extends State<BlenderDropdown<T>> {
  final GlobalKey _buttonKey = GlobalKey();
  Future<void> _open() async {
    final renderObject = _buttonKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;
    final origin = renderObject.localToGlobal(Offset.zero);
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss menu',
      barrierColor: const Color(0x00000000),
      transitionDuration: const Duration(milliseconds: 80),
      pageBuilder: (context, animation, secondaryAnimation) => Stack(
        children: <Widget>[
          Positioned(
            left: origin.dx,
            top: origin.dy + renderObject.size.height + 2,
            child: BlenderMenu<T>(
              items: [
                for (final item in widget.items)
                  item.copyWith(selected: item.value == widget.value),
              ],
              onSelected: (item) {
                widget.onChanged?.call(item.value);
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    BlenderMenuItem<T>? item;
    for (final candidate in widget.items) {
      if (candidate.value == widget.value) {
        item = candidate;
        break;
      }
    }
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        key: _buttonKey,
        width: double.infinity,
        height: BlenderTheme.of(context).density.controlHeight,
        child: BlenderButton(
          label: widget.compact ? '' : item?.label ?? 'Select',
          leading: item?.icon,
          enabled: widget.enabled,
          onPressed: widget.enabled && widget.onChanged != null ? _open : null,
          padding: widget.compact ? EdgeInsets.zero : null,
          trailing: const BlenderIcon(BlenderGlyph.chevronDown, size: 13),
        ),
      ),
    );
  }
}

class BlenderMenu<T> extends StatelessWidget {
  const BlenderMenu({super.key, required this.items, required this.onSelected});

  final List<BlenderMenuItem<T>> items;
  final ValueChanged<BlenderMenuItem<T>> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final hasSelectionMarkers = items.any((candidate) => candidate.selected);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 220,
        maxWidth: 300,
        maxHeight: 420,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.menuBackground,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(4),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            if (item.separator) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: SizedBox(
                  height: 1,
                  child: ColoredBox(
                    color: BlenderTheme.of(context).colors.borderSubtle,
                  ),
                ),
              );
            }
            final leading = hasSelectionMarkers
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        width: 15,
                        child: item.selected
                            ? const BlenderIcon(BlenderGlyph.check, size: 12)
                            : null,
                      ),
                      if (item.icon != null) ...<Widget>[
                        const SizedBox(width: 4),
                        item.icon!,
                      ],
                    ],
                  )
                : item.icon;
            return _BlenderMenuRow<T>(
              item: item,
              leading: leading,
              leadingWidth: hasSelectionMarkers && item.icon != null ? 40 : 22,
              onSelected: onSelected,
            );
          },
        ),
      ),
    );
  }
}

class _BlenderMenuRow<T> extends StatefulWidget {
  const _BlenderMenuRow({
    required this.item,
    required this.leading,
    required this.leadingWidth,
    required this.onSelected,
  });

  final BlenderMenuItem<T> item;
  final Widget? leading;
  final double leadingWidth;
  final ValueChanged<BlenderMenuItem<T>> onSelected;

  @override
  State<_BlenderMenuRow<T>> createState() => _BlenderMenuRowState<T>();
}

class _BlenderMenuRowState<T> extends State<_BlenderMenuRow<T>> {
  bool _hovered = false;

  Widget _buildContent(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final highlighted = widget.item.selected || _hovered;
    final foreground = widget.item.enabled
        ? theme.colors.foreground
        : theme.colors.foregroundDisabled;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: highlighted ? theme.colors.menuSelection : null,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(width: widget.leadingWidth, child: widget.leading),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                widget.item.label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.body.copyWith(
                  color: foreground,
                  fontSize: 12,
                  height: 1.1,
                ),
              ),
            ),
            if (widget.item.shortcut != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  widget.item.shortcut!,
                  style: theme.textTheme.caption.copyWith(
                    color: foreground,
                    fontSize: 10,
                  ),
                ),
              ),
            if (widget.item.submenu != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: BlenderIcon(
                  BlenderGlyph.chevronRight,
                  size: 12,
                  color: foreground,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final content = _buildContent(context);
    if (item.submenu == null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: item.enabled ? () => widget.onSelected(item) : null,
        child: content,
      );
    }
    return BlenderPopover(
      targetAnchor: Alignment.centerRight,
      followerAnchor: Alignment.centerLeft,
      offset: const Offset(3, 0),
      openOnHover: true,
      hoverDelay: const Duration(milliseconds: 200),
      child: content,
      popover: (context, close) => BlenderMenu<T>(
        items: item.submenu!,
        onSelected: (submenuItem) {
          widget.onSelected(submenuItem);
          close();
        },
      ),
    );
  }
}

/// A Blender-style pulldown label that opens a compact anchored menu.
class BlenderMenuButton<T> extends StatelessWidget {
  const BlenderMenuButton({
    super.key,
    required this.label,
    required this.items,
    this.onSelected,
    this.enabled = true,
    this.variant = BlenderButtonVariant.toolbar,
  });

  final String label;
  final List<BlenderMenuItem<T>> items;
  final ValueChanged<T>? onSelected;
  final bool enabled;
  final BlenderButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final button = BlenderButton(
      label: label,
      variant: variant,
      enabled: enabled,
      // The popover owns the activation; this callback keeps the pulldown
      // visually enabled while allowing the outer gesture to receive taps.
      onPressed: enabled ? () {} : null,
    );
    if (!enabled) return button;
    return BlenderPopover(
      child: IgnorePointer(child: button),
      popover: (context, close) => BlenderMenu<T>(
        items: items,
        onSelected: (item) {
          onSelected?.call(item.value);
          close();
        },
      ),
    );
  }
}

class BlenderContextMenu<T> extends StatelessWidget {
  const BlenderContextMenu({
    super.key,
    required this.child,
    required this.items,
    this.onSelected,
  });

  final Widget child;
  final List<BlenderMenuItem<T>> items;
  final ValueChanged<T>? onSelected;

  Future<void> _show(BuildContext context, Offset globalPosition) async {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    final renderObject = overlay.context.findRenderObject();
    if (renderObject is! RenderBox) return;
    final position = renderObject.globalToLocal(globalPosition);
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss context menu',
      barrierColor: const Color(0x00000000),
      transitionDuration: const Duration(milliseconds: 80),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: <Widget>[
            Positioned(
              left: position.dx,
              top: position.dy,
              child: BlenderMenu<T>(
                items: items,
                onSelected: (item) {
                  onSelected?.call(item.value);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) => _show(context, details.globalPosition),
      child: child,
    );
  }
}
