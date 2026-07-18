part of '../specialized_templates.dart';

/// An enum/icon choice used by Blender's icon-view template.
@immutable
class BlenderIconViewItem<T> {
  const BlenderIconViewItem({
    required this.value,
    required this.label,
    required this.icon,
    this.enabled = true,
  });

  final T value;
  final String label;
  final Widget icon;
  final bool enabled;
}

/// A selected icon that opens Blender's eight-column icon-view popup.
///
/// The descriptor is intentionally independent of enum/RNA values.  It keeps
/// the popup geometry and selected-state treatment reusable for render modes,
/// brush presets, editor choices, and other icon-backed enumerations.
class BlenderIconView<T> extends StatelessWidget {
  const BlenderIconView({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.showLabels = true,
    this.iconScale = 28,
    this.iconScalePopup = 46,
    this.enabled = true,
  });

  final List<BlenderIconViewItem<T>> items;
  final T value;
  final ValueChanged<T>? onChanged;
  final bool showLabels;
  final double iconScale;
  final double iconScalePopup;
  final bool enabled;

  BlenderIconViewItem<T>? get _selected {
    for (final item in items) {
      if (item.value == value) return item;
    }
    return null;
  }

  Widget _tile(
    BuildContext context,
    BlenderIconViewItem<T> item,
    VoidCallback close,
  ) {
    final theme = BlenderTheme.of(context);
    final selected = item.value == value;
    final active = enabled && item.enabled && onChanged != null;
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? theme.colors.menuSelection : null,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: iconScalePopup,
              child: Center(child: item.icon),
            ),
            if (showLabels) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.caption.copyWith(
                  color: active
                      ? theme.colors.foreground
                      : theme.colors.foregroundDisabled,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
    return Semantics(
      button: true,
      enabled: active,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: active
            ? () {
                onChanged!(item.value);
                close();
              }
            : null,
        child: content,
      ),
    );
  }

  Widget _popup(BuildContext context, VoidCallback close) {
    final theme = BlenderTheme.of(context);
    final tileHeight = showLabels ? iconScalePopup + 22 : iconScalePopup + 8;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 420),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.menuBackground,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
        ),
        child: SizedBox(
          width: 8 * (showLabels ? 64.0 : 52.0) + 10,
          child: GridView.builder(
            padding: const EdgeInsets.all(5),
            shrinkWrap: true,
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              mainAxisExtent: tileHeight,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemBuilder: (context, index) =>
                _tile(context, items[index], close),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final trigger = BlenderButton(
      label: '',
      leading: selected?.icon ?? const BlenderIcon(BlenderGlyph.grid, size: 16),
      enabled: enabled && items.isNotEmpty && onChanged != null,
      onPressed: () {},
      variant: BlenderButtonVariant.toolbar,
      width: iconScale,
      padding: EdgeInsets.zero,
    );
    final semanticTrigger = Semantics(
      button: true,
      enabled: enabled && items.isNotEmpty && onChanged != null,
      label: selected?.label ?? 'Icon view',
      child: trigger,
    );
    if (!enabled || items.isEmpty || onChanged == null) return semanticTrigger;
    return BlenderPopover(
      child: IgnorePointer(child: semanticTrigger),
      popover: (context, close) => _popup(context, close),
    );
  }
}
