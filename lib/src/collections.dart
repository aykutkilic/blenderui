import 'package:flutter/widgets.dart';

import 'controls.dart';
import 'icons.dart';
import 'theme.dart';

class BlenderListItem<T> {
  const BlenderListItem({
    required this.id,
    required this.label,
    this.value,
    this.icon,
    this.iconColor,
    this.detail,
    this.enabled = true,
  });

  final String id;
  final String label;
  final T? value;
  final BlenderGlyph? icon;
  final Color? iconColor;
  final String? detail;
  final bool enabled;
}

class BlenderListView<T> extends StatelessWidget {
  const BlenderListView({
    super.key,
    required this.items,
    this.selectedId,
    this.onSelected,
    this.onActivated,
    this.rowHeight,
    this.emptyLabel = 'No items',
  });

  final List<BlenderListItem<T>> items;
  final String? selectedId;
  final ValueChanged<BlenderListItem<T>>? onSelected;
  final ValueChanged<BlenderListItem<T>>? onActivated;
  final double? rowHeight;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: theme.textTheme.caption.copyWith(
            color: theme.colors.foregroundMuted,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: items.length,
      itemExtent: rowHeight ?? theme.density.rowHeight,
      itemBuilder: (context, index) {
        final item = items[index];
        final selected = item.id == selectedId;
        final active = item.enabled && onSelected != null;
        return Semantics(
          selected: selected,
          enabled: item.enabled,
          button: active,
          label: item.label,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: active ? () => onSelected!(item) : null,
            onDoubleTap: item.enabled && onActivated != null
                ? () => onActivated!(item)
                : null,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: selected ? theme.colors.selection : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: <Widget>[
                    if (item.icon != null) ...<Widget>[
                      BlenderIcon(item.icon!, color: item.iconColor, size: 14),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        item.label,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.label.copyWith(
                          color: item.enabled
                              ? theme.colors.foreground
                              : theme.colors.foregroundDisabled,
                        ),
                      ),
                    ),
                    if (item.detail != null)
                      Text(
                        item.detail!,
                        style: theme.textTheme.caption.copyWith(
                          color: theme.colors.foregroundMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BlenderFilterBar extends StatelessWidget {
  const BlenderFilterBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onFilter,
    this.onSort,
    this.actions = const <Widget>[],
    this.placeholder = 'Search',
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilter;
  final VoidCallback? onSort;
  final List<Widget> actions;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: BlenderSearchField(
            controller: controller,
            onChanged: onChanged,
            placeholder: placeholder,
          ),
        ),
        if (onFilter != null)
          BlenderIconButton(
            glyph: BlenderGlyph.filter,
            onPressed: onFilter,
            tooltip: 'Filter',
            size: 22,
          ),
        if (onSort != null)
          BlenderIconButton(
            glyph: BlenderGlyph.sort,
            onPressed: onSort,
            tooltip: 'Sort',
            size: 22,
          ),
        ...actions,
      ],
    );
  }
}
