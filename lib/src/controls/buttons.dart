part of '../controls.dart';

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
    this.checked = false,
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

  /// Displays a checkbox in the menu row.
  ///
  /// This is intentionally separate from [selected]: selection describes a
  /// choice within a menu, while a checked item represents a persistent
  /// toggle such as Blender's "Lock Object Modes" preference.
  final bool checked;
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
      BlenderButtonVariant.topBar => theme.colors.topBar,
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
    final normalForeground = switch (widget.variant) {
      BlenderButtonVariant.tab => theme.colors.tabText,
      _ => theme.colors.foreground,
    };
    final selectedForeground = switch (widget.variant) {
      BlenderButtonVariant.tab => theme.colors.tabTextSelected,
      _ => theme.colors.foreground,
    };
    final background = widget.selected
        ? selectedBackground
        : _pressed
        ? theme.colors.buttonPressed
        : _hovered
        ? hoverBackground
        : normalBackground;
    final foreground = !_enabled
        ? theme.colors.foregroundDisabled
        : widget.selected
        ? selectedForeground
        : normalForeground;
    final buttonHeight = widget.variant == BlenderButtonVariant.tab
        ? theme.density.rowHeight
        : theme.density.controlHeight;
    final buttonPadding =
        widget.padding ??
        (widget.variant == BlenderButtonVariant.tab
            ? EdgeInsets.symmetric(horizontal: theme.density.spacing * 2.5)
            : EdgeInsets.symmetric(horizontal: theme.density.spacing * 2));
    final buttonRadius = widget.variant == BlenderButtonVariant.tab
        ? theme.shapes.tabRadius
        : theme.shapes.controlRadius;

    return SizedBox(
      width: widget.width,
      height: buttonHeight,
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
              padding: buttonPadding,
              decoration: BoxDecoration(
                color: background,
                border: _focused
                    ? Border.all(
                        color: theme.colors.focus,
                        width: theme.shapes.focusWidth,
                      )
                    : widget.showBorder &&
                          widget.variant != BlenderButtonVariant.topBar &&
                          widget.variant != BlenderButtonVariant.tab
                    ? Border.all(
                        color: theme.colors.borderSubtle,
                        width: theme.shapes.borderWidth,
                      )
                    : null,
                borderRadius: BorderRadius.circular(buttonRadius),
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

                    final row = Row(
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
                    // Resolution scaling can make a previously fitting
                    // header control a few pixels narrower than its label,
                    // especially in Timeline and compact editor headers.
                    // Blender clips/fits these controls rather than allowing
                    // a RenderFlex overflow to escape its hit target.
                    return constraints.maxWidth <
                            72 * theme.density.interfaceScale
                        ? Center(
                            child: FittedBox(fit: BoxFit.scaleDown, child: row),
                          )
                        : row;
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
    this.iconSize = 15,
    this.scaleWithDensity = true,
    this.variant = BlenderButtonVariant.toolbar,
  });

  final BlenderGlyph glyph;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool selected;
  final bool enabled;
  final double size;
  final double iconSize;
  final bool scaleWithDensity;
  final BlenderButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final densityScale = scaleWithDensity
        ? BlenderTheme.of(context).density.controlHeight / 20
        : 1.0;
    Widget result = BlenderButton(
      label: '',
      width: size * densityScale,
      onPressed: onPressed,
      enabled: enabled,
      selected: selected,
      variant: variant,
      padding: EdgeInsets.zero,
      leading: BlenderIcon(glyph, size: iconSize * densityScale),
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
