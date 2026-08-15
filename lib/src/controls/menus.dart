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
    this.key,
    required this.label,
    required this.items,
    this.onSelected,
    this.enabled = true,
    this.variant = BlenderButtonVariant.topBar,
  });

  final Key? key;
  final String label;
  final List<BlenderMenuItem<T>> items;
  final ValueChanged<T>? onSelected;
  final bool enabled;
  final BlenderButtonVariant variant;

  Widget build() => BlenderMenuButton<T>(
    key: key,
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
  BlenderMenuFooterBuilder? footerBuilder,
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
                  footer: footerBuilder?.call(
                    dialogContext,
                    () => Navigator.of(dialogContext).pop(),
                  ),
                  items: selectedValue == null
                      ? items
                      : <BlenderMenuItem<T>>[
                          for (final item in items)
                            item.copyWith(
                              selected: item.value == selectedValue,
                            ),
                        ],
                  onSelected: (item) {
                    Navigator.of(dialogContext).pop();
                    // Remove the menu route before dispatching. A selection
                    // may synchronously open another route; popping after the
                    // callback would close that new dialog instead.
                    onSelected?.call(item.value);
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
  BlenderMenuFooterBuilder? footerBuilder,
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
    footerBuilder: footerBuilder,
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
    this.iconOnly = false,
    this.selectedLabel,
  });

  final T? value;
  final List<BlenderMenuItem<T>> items;
  final ValueChanged<T>? onChanged;
  final bool enabled;

  /// Uses header-density padding and toolbar colors while retaining the
  /// selected item's label and icon.
  final bool compact;

  /// Hides the selected label for genuinely icon-only selectors.
  ///
  /// This is separate from [compact] because Blender header dropdowns remain
  /// compact while still communicating their current selection.
  final bool iconOnly;
  final String? selectedLabel;

  @override
  State<BlenderDropdown<T>> createState() => _BlenderDropdownState<T>();
}

class _BlenderDropdownState<T> extends State<BlenderDropdown<T>> {
  final GlobalKey _buttonKey = GlobalKey();
  bool _menuOpen = false;

  Future<void> _open() async {
    final renderObject = _buttonKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;
    final origin = renderObject.localToGlobal(Offset.zero);
    setState(() => _menuOpen = true);
    try {
      await _showBlenderMenuOverlay<T>(
        context: context,
        position: Offset(origin.dx, origin.dy + renderObject.size.height + 2),
        items: widget.items,
        selectedValue: widget.value,
        onSelected: widget.onChanged,
      );
    } finally {
      if (mounted) setState(() => _menuOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final densityScale = BlenderTheme.of(context).density.controlHeight / 20;
    BlenderMenuItem<T>? item;
    for (final candidate in widget.items) {
      if (candidate.value == widget.value) {
        item = candidate;
        break;
      }
    }
    final label = widget.iconOnly
        ? ''
        : widget.selectedLabel ?? item?.label ?? 'Select';
    return LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          key: _buttonKey,
          width: constraints.hasBoundedWidth ? constraints.maxWidth : null,
          height: BlenderTheme.of(context).density.controlHeight,
          child: BlenderButton(
            label: label,
            leading: item?.icon,
            enabled: widget.enabled,
            selected: _menuOpen,
            variant: widget.compact
                ? BlenderButtonVariant.toolbar
                : BlenderButtonVariant.regular,
            onPressed: widget.enabled && widget.onChanged != null
                ? _open
                : null,
            padding: widget.compact
                ? EdgeInsets.symmetric(
                    horizontal: (widget.iconOnly ? 4 : 6) * densityScale,
                  )
                : null,
            trailing: BlenderIcon(
              BlenderGlyph.panelDisclosureDown,
              size: 9 * densityScale,
            ),
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
    this.footer,
  });

  final List<BlenderMenuItem<T>> items;
  final ValueChanged<BlenderMenuItem<T>> onSelected;
  final String? title;
  final Widget? footer;

  double _preferredWidth(
    BuildContext context,
    BlenderThemeData theme,
    double scale, {
    required bool hasSelectionMarkers,
    required bool hasLeadingMarkers,
  }) {
    final textDirection = Directionality.maybeOf(context) ?? TextDirection.ltr;
    final labelStyle = theme.textTheme.body.copyWith(
      fontSize: 11 * scale,
      height: 1.1,
    );
    final shortcutStyle = theme.textTheme.caption.copyWith(
      fontSize: 10 * scale,
    );

    double textWidth(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: textDirection,
        maxLines: 1,
      )..layout();
      final width = painter.width;
      painter.dispose();
      return width;
    }

    final leadingWidth = hasLeadingMarkers
        ? (hasSelectionMarkers ? 35 * scale : 18 * scale)
        : 0.0;
    var contentWidth = 0.0;
    for (final item in items) {
      if (item.separator) continue;
      var rowWidth = 14 * scale + textWidth(item.label, labelStyle);
      if (leadingWidth > 0) rowWidth += leadingWidth + 7 * scale;
      if (item.shortcut case final shortcut?) {
        rowWidth += 8 * scale + textWidth(shortcut, shortcutStyle);
      }
      if (item.submenu != null) rowWidth += 17 * scale;
      contentWidth = math.max(contentWidth, rowWidth);
    }
    if (title case final title? when title.isNotEmpty) {
      contentWidth = math.max(
        contentWidth,
        16 * scale + textWidth(title, labelStyle),
      );
    }
    return (contentWidth + 8 * scale)
        .clamp(180 * scale, 300 * scale)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final scale = theme.density.interfaceScale;
    final hasSelectionMarkers = items.any((candidate) => candidate.selected);
    final hasLeadingMarkers = items.any(
      (candidate) =>
          candidate.selected || candidate.checked || candidate.icon != null,
    );
    final preferredWidth = _preferredWidth(
      context,
      theme,
      scale,
      hasSelectionMarkers: hasSelectionMarkers,
      hasLeadingMarkers: hasLeadingMarkers,
    );
    return SizedBox(
      width: preferredWidth,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 420 * scale),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.menuBackground,
            border: Border.all(color: theme.colors.borderSubtle),
            borderRadius: BorderRadius.circular(
              theme.shapes.menuRadius * scale,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0x66000000),
                blurRadius: 8 * scale,
                offset: Offset(0, 3 * scale),
              ),
            ],
          ),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(4 * scale),
            children: <Widget>[
              if (title != null && title!.isNotEmpty) ...<Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    8 * scale,
                    5 * scale,
                    8 * scale,
                    7 * scale,
                  ),
                  child: Text(
                    title!,
                    style: theme.textTheme.body.copyWith(
                      color: theme.colors.foregroundMuted,
                      fontSize: 11 * scale,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 3 * scale),
                  child: SizedBox(
                    height: scale,
                    child: ColoredBox(color: theme.colors.borderSubtle),
                  ),
                ),
              ],
              for (final item in items)
                if (item.separator)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 3 * scale),
                    child: SizedBox(
                      height: scale,
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
                                  width: 15 * scale,
                                  child: item.selected
                                      ? BlenderIcon(
                                          BlenderGlyph.check,
                                          size: 12 * scale,
                                        )
                                      : null,
                                ),
                              if (item.checked)
                                _BlenderMenuCheck(enabled: item.enabled)
                              else if (item.icon != null)
                                SizedBox(
                                  width: 16 * scale,
                                  height: 16 * scale,
                                  child: item.icon!,
                                ),
                            ],
                          )
                        : null,
                    leadingWidth: hasLeadingMarkers
                        ? (hasSelectionMarkers ? 35 * scale : 18 * scale)
                        : 0,
                    onSelected: onSelected,
                  ),
              if (footer != null) ...<Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3 * scale),
                  child: SizedBox(
                    height: scale,
                    child: ColoredBox(color: theme.colors.borderSubtle),
                  ),
                ),
                footer!,
              ],
            ],
          ),
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
    final scale = theme.density.interfaceScale;
    final color = enabled
        ? theme.colors.foreground
        : theme.colors.foregroundDisabled;
    return SizedBox(
      width: 16 * scale,
      height: 16 * scale,
      child: BlenderIcon(BlenderGlyph.check, size: 15 * scale, color: color),
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
    final scale = theme.density.interfaceScale;
    final selected = widget.item.selected;
    final hovered = _hovered || _submenuOpen;
    final foreground = widget.item.enabled
        ? theme.colors.foreground
        : theme.colors.foregroundDisabled;
    Widget content = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        key: ValueKey<String>('menu-row-${widget.item.label}'),
        height: theme.density.controlHeight,
        padding: EdgeInsets.symmetric(horizontal: 7 * scale),
        decoration: BoxDecoration(
          color: selected
              ? theme.colors.menuSelection
              : hovered
              ? theme.colors.surfaceRaised
              : null,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          children: <Widget>[
            if (widget.leadingWidth > 0) ...<Widget>[
              SizedBox(width: widget.leadingWidth, child: widget.leading),
              SizedBox(width: 7 * scale),
            ],
            Expanded(
              child: Text(
                widget.item.label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.body.copyWith(
                  color: foreground,
                  fontSize: 11 * scale,
                  height: 1.1,
                ),
              ),
            ),
            if (widget.item.shortcut != null)
              Padding(
                padding: EdgeInsets.only(left: 8 * scale),
                child: Text(
                  widget.item.shortcut!,
                  style: theme.textTheme.caption.copyWith(
                    color: foreground,
                    fontSize: 10 * scale,
                  ),
                ),
              ),
            if (widget.item.submenu != null)
              Padding(
                padding: EdgeInsets.only(left: 8 * scale),
                child: BlenderIcon(
                  key: ValueKey<String>(
                    'menu-submenu-arrow-${widget.item.label}',
                  ),
                  BlenderGlyph.panelDisclosureRight,
                  size: 9 * scale,
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

/// Coordinates sibling pulldowns so an open Blender-style menu follows hover.
///
/// Nested submenus use their own popovers and are deliberately outside this
/// peer group. [BlenderToolbar] installs a menu bar automatically.
class BlenderMenuBar extends StatefulWidget {
  const BlenderMenuBar({super.key, required this.child});

  final Widget child;

  @override
  State<BlenderMenuBar> createState() => _BlenderMenuBarState();
}

class _BlenderMenuBarState extends State<BlenderMenuBar> {
  final _coordinator = _BlenderMenuBarCoordinator();

  @override
  Widget build(BuildContext context) {
    return _BlenderMenuBarScope(coordinator: _coordinator, child: widget.child);
  }
}

class _BlenderMenuBarScope extends InheritedWidget {
  const _BlenderMenuBarScope({required this.coordinator, required super.child});

  final _BlenderMenuBarCoordinator coordinator;

  static _BlenderMenuBarCoordinator? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_BlenderMenuBarScope>()
        ?.coordinator;
  }

  @override
  bool updateShouldNotify(_BlenderMenuBarScope oldWidget) =>
      coordinator != oldWidget.coordinator;
}

class _BlenderMenuBarEntry {
  _BlenderMenuBarEntry({
    required this.bounds,
    required this.show,
    required this.hide,
  });

  final Rect? Function() bounds;
  final VoidCallback show;
  final VoidCallback hide;
}

class _BlenderMenuBarCoordinator {
  final List<_BlenderMenuBarEntry> _entries = <_BlenderMenuBarEntry>[];
  _BlenderMenuBarEntry? _active;
  _BlenderMenuBarEntry? _switchingTo;

  void register(_BlenderMenuBarEntry entry) => _entries.add(entry);

  void unregister(_BlenderMenuBarEntry entry) {
    _entries.remove(entry);
    if (identical(_active, entry)) _active = null;
    if (identical(_switchingTo, entry)) _switchingTo = null;
  }

  void setOpen(_BlenderMenuBarEntry entry, bool open) {
    if (open) {
      _active = entry;
      if (identical(_switchingTo, entry)) _switchingTo = null;
    } else if (identical(_active, entry)) {
      _active = null;
    }
  }

  void handleOverlayHover(Offset position) {
    final active = _active;
    if (active == null) return;
    _BlenderMenuBarEntry? target;
    for (final entry in _entries) {
      if (!identical(entry, active) &&
          (entry.bounds()?.contains(position) ?? false)) {
        target = entry;
        break;
      }
    }
    if (target == null || identical(_switchingTo, target)) return;
    _switchingTo = target;
    active.hide();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!identical(_switchingTo, target)) return;
      target!.show();
    });
  }
}

/// A Blender-style pulldown label that opens a compact anchored menu.
class BlenderMenuButton<T> extends StatefulWidget {
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
  State<BlenderMenuButton<T>> createState() => _BlenderMenuButtonState<T>();
}

class _BlenderMenuButtonState<T> extends State<BlenderMenuButton<T>> {
  final _anchorKey = GlobalKey();
  final _popoverKey = GlobalKey<_BlenderPopoverState>();
  late final _BlenderMenuBarEntry _menuBarEntry = _BlenderMenuBarEntry(
    bounds: _globalBounds,
    show: _show,
    hide: _hide,
  );
  _BlenderMenuBarCoordinator? _coordinator;
  bool _open = false;

  Rect? _globalBounds() {
    if (!widget.enabled) return null;
    final renderObject = _anchorKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) return null;
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }

  void _show() => _popoverKey.currentState?._show();

  void _hide() => _popoverKey.currentState?._hide();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final coordinator = _BlenderMenuBarScope.maybeOf(context);
    if (identical(coordinator, _coordinator)) return;
    _coordinator?.unregister(_menuBarEntry);
    _coordinator = coordinator;
    _coordinator?.register(_menuBarEntry);
  }

  @override
  void dispose() {
    _coordinator?.unregister(_menuBarEntry);
    super.dispose();
  }

  void _handleOpenChanged(bool open) {
    if (mounted && _open != open) setState(() => _open = open);
    _coordinator?.setOpen(_menuBarEntry, open);
  }

  @override
  Widget build(BuildContext context) {
    final button = BlenderButton(
      label: widget.label,
      variant: widget.variant,
      enabled: widget.enabled,
      selected: _open,
      showBorder: widget.variant != BlenderButtonVariant.menuTrigger,
      padding: widget.variant == BlenderButtonVariant.menuTrigger
          ? EdgeInsets.symmetric(
              horizontal: BlenderTheme.of(context).density.spacing * 1.5,
            )
          : null,
      // The popover owns the activation; this callback keeps the pulldown
      // visually enabled while allowing the outer gesture to receive taps.
      onPressed: widget.enabled ? () {} : null,
    );
    if (!widget.enabled) return KeyedSubtree(key: _anchorKey, child: button);
    return BlenderPopover(
      key: _popoverKey,
      // Blender menus begin at the trigger's leading edge. Center anchoring
      // makes a narrow application-menu label open a menu on both sides of
      // the label, unlike Blender's File/Edit/Window pulldowns.
      targetAnchor: Alignment.bottomLeft,
      followerAnchor: Alignment.topLeft,
      onOpenChanged: _handleOpenChanged,
      onOverlayHover: _coordinator?.handleOverlayHover,
      child: KeyedSubtree(
        key: _anchorKey,
        child: IgnorePointer(child: button),
      ),
      popover: (context, close) => BlenderMenu<T>(
        items: widget.items,
        onSelected: (item) {
          close();
          // Keep dialog-opening commands above the dismissed menu route.
          widget.onSelected?.call(item.value);
        },
      ),
    );
  }
}

typedef BlenderMenuFooterBuilder =
    Widget? Function(BuildContext context, VoidCallback close);

class BlenderContextMenu<T> extends StatelessWidget {
  const BlenderContextMenu({
    super.key,
    required this.child,
    required this.items,
    this.onSelected,
    this.title,
    this.onOpenChanged,
    this.onContextRequested,
    this.footerBuilder,
    this.includeLongPress = true,
  });

  final Widget child;
  final List<BlenderMenuItem<T>> items;
  final ValueChanged<T>? onSelected;
  final String? title;
  final ValueChanged<bool>? onOpenChanged;
  final ValueChanged<Offset>? onContextRequested;
  final BlenderMenuFooterBuilder? footerBuilder;
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
        footerBuilder: footerBuilder,
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
