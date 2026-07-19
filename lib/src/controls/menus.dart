part of '../controls.dart';

class BlenderMenuItem<T> {
  const BlenderMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
    this.selected = false,
    this.checked = false,
    this.shortcut,
    this.description,
    this.separator = false,
    this.submenu,
  });

  final T value;
  final String label;
  final Widget? icon;
  final bool enabled;
  final bool selected;
  final bool checked;
  final String? shortcut;

  /// Optional operator-style help shown after the standard tooltip delay.
  final String? description;
  final bool separator;
  final List<BlenderMenuItem<T>>? submenu;

  BlenderMenuItem<T> copyWith({
    T? value,
    String? label,
    Widget? icon,
    bool? enabled,
    bool? selected,
    bool? checked,
    String? shortcut,
    String? description,
    bool? separator,
    List<BlenderMenuItem<T>>? submenu,
  }) {
    return BlenderMenuItem<T>(
      value: value ?? this.value,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      enabled: enabled ?? this.enabled,
      selected: selected ?? this.selected,
      checked: checked ?? this.checked,
      shortcut: shortcut ?? this.shortcut,
      description: description ?? this.description,
      separator: separator ?? this.separator,
      submenu: submenu ?? this.submenu,
    );
  }
}

/// Shared descriptor for application and editor-header pulldown menus.
///
/// The descriptor owns menu presentation and choice routing. Use the
/// command-backed controls when entries represent registered application
/// commands rather than ordinary enum or mode choices.
abstract interface class BlenderMenuDescriptorWidget {
  Widget build();
}

class BlenderMenuDescriptor<T> implements BlenderMenuDescriptorWidget {
  const BlenderMenuDescriptor({
    required this.label,
    required this.items,
    this.onSelected,
    this.enabled = true,
    this.variant = BlenderButtonVariant.topBar,
  });

  final String label;
  final List<BlenderMenuItem<T>> items;
  final ValueChanged<T>? onSelected;
  final bool enabled;
  final BlenderButtonVariant variant;

  Widget build() => BlenderMenuButton<T>(
    label: label,
    items: items,
    onSelected: onSelected,
    enabled: enabled,
    variant: variant,
  );
}

Future<void> _showBlenderMenuOverlay<T>({
  required BuildContext context,
  required Offset position,
  required List<BlenderMenuItem<T>> items,
  required ValueChanged<T>? onSelected,
  T? selectedValue,
  String? title,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss menu',
    barrierColor: const Color(0x00000000),
    transitionDuration: const Duration(milliseconds: 80),
    pageBuilder: (dialogContext, animation, secondaryAnimation) =>
        InheritedTheme.captureAll(
          context,
          Stack(
            children: <Widget>[
              CustomSingleChildLayout(
                delegate: _BlenderPopoverPositionDelegate(
                  target: Rect.fromLTWH(position.dx, position.dy, 0, 0),
                  offset: Offset.zero,
                  targetAnchor: Alignment.topLeft,
                  followerAnchor: Alignment.topLeft,
                ),
                child: BlenderMenu<T>(
                  title: title,
                  items: selectedValue == null
                      ? items
                      : <BlenderMenuItem<T>>[
                          for (final item in items)
                            item.copyWith(
                              selected: item.value == selectedValue,
                            ),
                        ],
                  onSelected: (item) {
                    onSelected?.call(item.value);
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ),
            ],
          ),
        ),
  );
}

/// Opens a Blender-style context menu at a global pointer position.
///
/// Use [BlenderContextMenu] for ordinary child widgets. This imperative form
/// is intended for existing gesture surfaces, such as a draggable divider,
/// where wrapping the target would compete in Flutter's gesture arena.
Future<void> showBlenderContextMenu<T>({
  required BuildContext context,
  required Offset globalPosition,
  required List<BlenderMenuItem<T>> items,
  ValueChanged<T>? onSelected,
  String? title,
}) async {
  if (items.isEmpty) return;
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;
  final renderObject = overlay.context.findRenderObject();
  if (renderObject is! RenderBox) return;
  await _showBlenderMenuOverlay<T>(
    context: context,
    position: renderObject.globalToLocal(globalPosition),
    items: items,
    onSelected: onSelected,
    title: title,
  );
}

class BlenderDropdown<T> extends StatefulWidget {
  const BlenderDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.compact = false,
    this.selectedLabel,
  });

  final T? value;
  final List<BlenderMenuItem<T>> items;
  final ValueChanged<T>? onChanged;
  final bool enabled;
  final bool compact;
  final String? selectedLabel;

  @override
  State<BlenderDropdown<T>> createState() => _BlenderDropdownState<T>();
}

class _BlenderDropdownState<T> extends State<BlenderDropdown<T>> {
  final GlobalKey _buttonKey = GlobalKey();
  Future<void> _open() async {
    final renderObject = _buttonKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;
    final origin = renderObject.localToGlobal(Offset.zero);
    await _showBlenderMenuOverlay<T>(
      context: context,
      position: Offset(origin.dx, origin.dy + renderObject.size.height + 2),
      items: widget.items,
      selectedValue: widget.value,
      onSelected: widget.onChanged,
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
          label: widget.compact
              ? ''
              : widget.selectedLabel ?? item?.label ?? 'Select',
          leading: item?.icon,
          enabled: widget.enabled,
          onPressed: widget.enabled && widget.onChanged != null ? _open : null,
          padding: widget.compact ? EdgeInsets.zero : null,
          trailing: const BlenderIcon(
            BlenderGlyph.panelDisclosureDown,
            size: 9,
          ),
        ),
      ),
    );
  }
}

class BlenderMenu<T> extends StatelessWidget {
  const BlenderMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.title,
  });

  final List<BlenderMenuItem<T>> items;
  final ValueChanged<BlenderMenuItem<T>> onSelected;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final hasSelectionMarkers = items.any((candidate) => candidate.selected);
    final hasLeadingMarkers = items.any(
      (candidate) =>
          candidate.selected || candidate.checked || candidate.icon != null,
    );
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
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(4),
          children: <Widget>[
            if (title != null && title!.isNotEmpty) ...<Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 5, 8, 7),
                child: Text(
                  title!,
                  style: theme.textTheme.body.copyWith(
                    color: theme.colors.foregroundMuted,
                    fontSize: 12,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: SizedBox(
                  height: 1,
                  child: ColoredBox(color: theme.colors.borderSubtle),
                ),
              ),
            ],
            for (final item in items)
              if (item.separator)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: SizedBox(
                    height: 1,
                    child: ColoredBox(color: theme.colors.borderSubtle),
                  ),
                )
              else
                _BlenderMenuRow<T>(
                  item: item,
                  leading: hasLeadingMarkers
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (hasSelectionMarkers)
                              SizedBox(
                                width: 15,
                                child: item.selected
                                    ? const BlenderIcon(
                                        BlenderGlyph.check,
                                        size: 12,
                                      )
                                    : null,
                              ),
                            if (item.checked)
                              _BlenderMenuCheck(enabled: item.enabled)
                            else if (item.icon != null)
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: item.icon!,
                              ),
                          ],
                        )
                      : null,
                  leadingWidth: hasLeadingMarkers
                      ? (hasSelectionMarkers ? 35 : 18)
                      : 0,
                  onSelected: onSelected,
                ),
          ],
        ),
      ),
    );
  }
}

class _BlenderMenuCheck extends StatelessWidget {
  const _BlenderMenuCheck({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final color = enabled
        ? theme.colors.foreground
        : theme.colors.foregroundDisabled;
    return SizedBox(
      width: 16,
      height: 16,
      child: BlenderIcon(BlenderGlyph.check, size: 15, color: color),
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
  bool _submenuOpen = false;

  Widget _buildContent(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final highlighted = widget.item.selected || _hovered || _submenuOpen;
    final foreground = widget.item.enabled
        ? theme.colors.foreground
        : theme.colors.foregroundDisabled;
    Widget content = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        key: ValueKey<String>('menu-row-${widget.item.label}'),
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: highlighted ? theme.colors.menuSelection : null,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          children: <Widget>[
            if (widget.leadingWidth > 0) ...<Widget>[
              SizedBox(width: widget.leadingWidth, child: widget.leading),
              const SizedBox(width: 7),
            ],
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
                  key: ValueKey<String>(
                    'menu-submenu-arrow-${widget.item.label}',
                  ),
                  BlenderGlyph.panelDisclosureRight,
                  size: 9,
                  color: foreground,
                ),
              ),
          ],
        ),
      ),
    );
    if (widget.item.description != null) {
      content = BlenderTooltip(
        message: widget.item.description!,
        child: content,
      );
    }
    return content;
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
      onOpenChanged: (open) {
        if (mounted && _submenuOpen != open) {
          setState(() => _submenuOpen = open);
        }
      },
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
    this.title,
    this.onOpenChanged,
    this.onContextRequested,
    this.includeLongPress = true,
  });

  final Widget child;
  final List<BlenderMenuItem<T>> items;
  final ValueChanged<T>? onSelected;
  final String? title;
  final ValueChanged<bool>? onOpenChanged;
  final ValueChanged<Offset>? onContextRequested;
  final bool includeLongPress;

  Future<void> _show(BuildContext context, Offset globalPosition) async {
    if (items.isEmpty) return;
    onContextRequested?.call(globalPosition);
    onOpenChanged?.call(true);
    try {
      await showBlenderContextMenu<T>(
        context: context,
        globalPosition: globalPosition,
        items: items,
        onSelected: onSelected,
        title: title,
      );
    } finally {
      onOpenChanged?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) => _show(context, details.globalPosition),
      onLongPressStart: includeLongPress
          ? (details) => _show(context, details.globalPosition)
          : null,
      child: child,
    );
  }
}
