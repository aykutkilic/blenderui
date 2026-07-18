part of '../specialized_templates.dart';

/// An expanded enum row matching Blender's component-menu template.
class BlenderComponentMenu<T> extends StatelessWidget {
  const BlenderComponentMenu({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.expanded = true,
  });

  final T value;
  final List<BlenderMenuItem<T>> items;
  final ValueChanged<T> onChanged;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return BlenderSegmentedControl<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      expanded: expanded,
    );
  }
}

/// The compact one-item/list-count variant of Blender's UI list template.
class BlenderCompactList<T> extends StatelessWidget {
  const BlenderCompactList({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.emptyLabel = 'No items',
  });

  final List<BlenderListItem<T>> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    if (items.isEmpty) {
      return BlenderBox(
        child: Text(
          emptyLabel,
          style: theme.textTheme.caption.copyWith(
            color: theme.colors.foregroundMuted,
          ),
        ),
      );
    }
    final index = selectedIndex.clamp(0, items.length - 1).toInt();
    final item = items[index];
    return Row(
      children: <Widget>[
        Semantics(
          button: true,
          label: 'Previous list item',
          enabled: index > 0,
          child: ExcludeSemantics(
            child: BlenderIconButton(
              glyph: BlenderGlyph.chevronRight,
              enabled: index > 0,
              onPressed: index > 0 ? () => onChanged(index - 1) : null,
              tooltip: 'Previous list item',
              size: 22,
            ),
          ),
        ),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.textField,
              border: Border.all(color: theme.colors.borderSubtle),
              borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
            ),
            child: SizedBox(
              height: theme.density.controlHeight,
              child: Row(
                children: <Widget>[
                  if (item.icon != null) ...<Widget>[
                    const SizedBox(width: 5),
                    BlenderIcon(item.icon!, color: item.iconColor, size: 14),
                  ],
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.label,
                    ),
                  ),
                  if (item.detail != null)
                    Text(
                      item.detail!,
                      style: theme.textTheme.caption.copyWith(
                        color: theme.colors.foregroundMuted,
                      ),
                    ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
          ),
        ),
        Semantics(
          button: true,
          label: 'Next list item',
          enabled: index < items.length - 1,
          child: ExcludeSemantics(
            child: BlenderIconButton(
              glyph: BlenderGlyph.chevronRight,
              enabled: index < items.length - 1,
              onPressed: index < items.length - 1
                  ? () => onChanged(index + 1)
                  : null,
              tooltip: 'Next list item',
              size: 22,
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            '${index + 1} : ${items.length}',
            textAlign: TextAlign.center,
            style: theme.textTheme.caption,
          ),
        ),
      ],
    );
  }
}
