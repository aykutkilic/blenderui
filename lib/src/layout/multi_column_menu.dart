part of '../layout.dart';

/// A descriptor for one category in a compact Blender-style menu.
///
/// Applications provide their own values and labels; BlenderUI owns the
/// shared geometry, highlighting, and menu chrome used by editor-type menus.
class BlenderMultiColumnMenuGroup<T> {
  const BlenderMultiColumnMenuGroup({
    required this.id,
    required this.title,
    required this.items,
  });

  final String id;
  final String title;
  final List<BlenderMultiColumnMenuItem<T>> items;
}

/// A selectable entry in a [BlenderMultiColumnMenuGroup].
class BlenderMultiColumnMenuItem<T> {
  const BlenderMultiColumnMenuItem({
    required this.id,
    required this.value,
    required this.label,
    required this.glyph,
    this.trailingLabel,
    this.enabled = true,
  });

  final String id;
  final T value;
  final String label;
  final BlenderGlyph glyph;
  final String? trailingLabel;
  final bool enabled;
}

/// The compact, four-or-more-column menu used for Blender editor types and
/// application-owned type pickers.
///
/// It intentionally uses the same 24px rows, 11px labels, and 12px column
/// gaps as Blender's editor-type popover. It is data-driven so applications do
/// not need to fork a visual control merely to present a different catalogue.
class BlenderMultiColumnMenu<T> extends StatelessWidget {
  const BlenderMultiColumnMenu({
    super.key,
    required this.groups,
    required this.onSelected,
    this.selected,
    this.menuId,
    this.semanticLabel,
    this.maxWidth = 820,
    this.minimumColumnWidth = 160,
  });

  final List<BlenderMultiColumnMenuGroup<T>> groups;
  final T? selected;
  final ValueChanged<T>? onSelected;
  final String? menuId;
  final String? semanticLabel;
  final double maxWidth;

  /// Minimum width reserved for each category when the menu is columnar.
  ///
  /// If the available width cannot fit every category at this width, the
  /// same groups are laid out vertically so the menu remains usable in narrow
  /// popovers and compact editor regions.
  final double minimumColumnWidth;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Semantics(
      label: semanticLabel ?? 'Multi-column menu',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = math.min(maxWidth, constraints.maxWidth).toDouble();
          final columnWidth =
              groups.length * minimumColumnWidth +
              math.max(0, groups.length - 1) * 12;
          final useColumns = groups.length > 1 && width >= columnWidth;
          final categories = <Widget>[
            for (final entry in groups.indexed) ...<Widget>[
              if (entry.$1 > 0 && !useColumns) const SizedBox(height: 12),
              if (useColumns && entry.$1 > 0) const SizedBox(width: 12),
              useColumns
                  ? Expanded(
                      child: _BlenderMultiColumnMenuCategory<T>(
                        group: groups[entry.$1],
                        selected: selected,
                        onSelected: onSelected,
                        menuId: menuId,
                      ),
                    )
                  : _BlenderMultiColumnMenuCategory<T>(
                      group: groups[entry.$1],
                      selected: selected,
                      onSelected: onSelected,
                      menuId: menuId,
                    ),
            ],
          ];
          return SizedBox(
            width: width,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.menuBackground,
                border: Border.all(color: theme.colors.borderSubtle),
                borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: useColumns
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: categories,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: categories,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BlenderMultiColumnMenuCategory<T> extends StatelessWidget {
  const _BlenderMultiColumnMenuCategory({
    required this.group,
    required this.selected,
    required this.onSelected,
    required this.menuId,
  });

  final BlenderMultiColumnMenuGroup<T> group;
  final T? selected;
  final ValueChanged<T>? onSelected;
  final String? menuId;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Column(
      key: menuId == null
          ? null
          : ValueKey<String>('$menuId-group-${group.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            group.title,
            style: theme.textTheme.heading.copyWith(fontSize: 11),
          ),
        ),
        SizedBox(
          height: 1,
          child: ColoredBox(color: theme.colors.borderSubtle),
        ),
        const SizedBox(height: 4),
        for (final item in group.items)
          _BlenderMultiColumnMenuEntry<T>(
            item: item,
            selected: item.value == selected,
            enabled: item.enabled && onSelected != null,
            onTap: onSelected == null ? null : () => onSelected!(item.value),
            itemKey: menuId == null
                ? null
                : ValueKey<String>('$menuId-item-${item.id}'),
          ),
      ],
    );
  }
}

class _BlenderMultiColumnMenuEntry<T> extends StatefulWidget {
  const _BlenderMultiColumnMenuEntry({
    required this.item,
    required this.selected,
    required this.enabled,
    required this.onTap,
    required this.itemKey,
  });

  final BlenderMultiColumnMenuItem<T> item;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;
  final Key? itemKey;

  @override
  State<_BlenderMultiColumnMenuEntry<T>> createState() =>
      _BlenderMultiColumnMenuEntryState<T>();
}

class _BlenderMultiColumnMenuEntryState<T>
    extends State<_BlenderMultiColumnMenuEntry<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final highlighted = widget.selected || (_hovered && widget.enabled);
    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: widget.enabled ? (_) => setState(() => _hovered = true) : null,
      onExit: widget.enabled ? (_) => setState(() => _hovered = false) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled ? widget.onTap : null,
        child: Container(
          key: widget.itemKey,
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: highlighted ? theme.colors.menuSelection : null,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            children: <Widget>[
              BlenderIcon(
                widget.item.glyph,
                size: 15,
                color: widget.enabled ? null : theme.colors.foregroundDisabled,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.item.label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.body.copyWith(
                    fontSize: 11,
                    height: 1.1,
                    color: widget.enabled
                        ? null
                        : theme.colors.foregroundDisabled,
                  ),
                ),
              ),
              if (widget.item.trailingLabel != null)
                Text(
                  widget.item.trailingLabel!,
                  style: theme.textTheme.caption.copyWith(fontSize: 9),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
