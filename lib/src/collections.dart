import 'package:flutter/widgets.dart';

import 'controls.dart';
import 'icons.dart';
import 'layout.dart';
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
    this.contextMenuTitleBuilder,
    this.contextMenuItemsBuilder,
    this.onContextMenuSelected,
    this.rowHeight,
    this.emptyLabel = 'No items',
  });

  final List<BlenderListItem<T>> items;
  final String? selectedId;
  final ValueChanged<BlenderListItem<T>>? onSelected;
  final ValueChanged<BlenderListItem<T>>? onActivated;
  final String Function(BlenderListItem<T>)? contextMenuTitleBuilder;
  final List<BlenderMenuItem<String>> Function(BlenderListItem<T>)?
  contextMenuItemsBuilder;
  final void Function(BlenderListItem<T>, String)? onContextMenuSelected;
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
        Widget row = Semantics(
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
                      Flexible(
                        child: Text(
                          item.detail!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.caption.copyWith(
                            color: theme.colors.foregroundMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
        final contextItems = contextMenuItemsBuilder?.call(item);
        if (contextItems != null && contextItems.isNotEmpty) {
          row = BlenderContextMenu<String>(
            title: contextMenuTitleBuilder?.call(item),
            items: contextItems,
            onContextRequested: (_) {
              if (active) onSelected!(item);
            },
            onSelected: (action) => onContextMenuSelected?.call(item, action),
            child: row,
          );
        }
        return row;
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
    this.onInvertFilter,
    this.onSortAlphabetically,
    this.onSortReverse,
    this.invertFilter = false,
    this.sortAlphabetically = false,
    this.sortReverse = false,
    this.actions = const <Widget>[],
    this.placeholder = 'Search',
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilter;
  final VoidCallback? onSort;
  final VoidCallback? onInvertFilter;
  final VoidCallback? onSortAlphabetically;
  final VoidCallback? onSortReverse;
  final bool invertFilter;
  final bool sortAlphabetically;
  final bool sortReverse;
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
        if (onInvertFilter != null)
          BlenderIconButton(
            glyph: BlenderGlyph.arrowLeftRight,
            selected: invertFilter,
            onPressed: onInvertFilter,
            tooltip: 'Invert Filter',
            size: 22,
          ),
        if (onSortAlphabetically != null)
          BlenderIconButton(
            glyph: BlenderGlyph.sortAlphabetically,
            selected: sortAlphabetically,
            onPressed: onSortAlphabetically,
            tooltip: 'Sort Alphabetically',
            size: 22,
          ),
        if (onSortReverse != null)
          BlenderIconButton(
            glyph: sortReverse
                ? BlenderGlyph.sortDescending
                : BlenderGlyph.sort,
            selected: sortReverse,
            onPressed: onSortReverse,
            tooltip: sortReverse ? 'Sort Ascending' : 'Sort Descending',
            size: 22,
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

/// Blender's `template_uilist()` default layout with its list box, filter
/// disclosure row, resize grip, and source-shaped filter controls.
class BlenderTemplateList<T> extends StatefulWidget {
  const BlenderTemplateList({
    super.key,
    required this.items,
    this.selectedId,
    this.onSelected,
    this.onActivated,
    this.rowHeight,
    this.emptyLabel = 'No items',
    this.filterController,
    this.onFilterChanged,
    this.initiallyFilterExpanded = false,
    this.onFilterExpandedChanged,
    this.onInvertFilter,
    this.onSortAlphabetically,
    this.onSortReverse,
    this.invertFilter = false,
    this.sortAlphabetically = false,
    this.sortReverse = false,
    this.sortLocked = false,
    this.listHeight = 160,
  });

  final List<BlenderListItem<T>> items;
  final String? selectedId;
  final ValueChanged<BlenderListItem<T>>? onSelected;
  final ValueChanged<BlenderListItem<T>>? onActivated;
  final double? rowHeight;
  final String emptyLabel;
  final TextEditingController? filterController;
  final ValueChanged<String>? onFilterChanged;
  final bool initiallyFilterExpanded;
  final ValueChanged<bool>? onFilterExpandedChanged;
  final VoidCallback? onInvertFilter;
  final VoidCallback? onSortAlphabetically;
  final VoidCallback? onSortReverse;
  final bool invertFilter;
  final bool sortAlphabetically;
  final bool sortReverse;
  final bool sortLocked;
  final double listHeight;

  @override
  State<BlenderTemplateList<T>> createState() => _BlenderTemplateListState<T>();
}

class _BlenderTemplateListState<T> extends State<BlenderTemplateList<T>> {
  late bool _filterExpanded = widget.initiallyFilterExpanded;

  @override
  void didUpdateWidget(BlenderTemplateList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyFilterExpanded != widget.initiallyFilterExpanded) {
      _filterExpanded = widget.initiallyFilterExpanded;
    }
  }

  void _toggleFilter() {
    final expanded = !_filterExpanded;
    setState(() => _filterExpanded = expanded);
    widget.onFilterExpandedChanged?.call(expanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final showFilter = widget.filterController != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: widget.listHeight,
          child: BlenderBox(
            padding: EdgeInsets.zero,
            child: BlenderListView<T>(
              items: widget.items,
              selectedId: widget.selectedId,
              onSelected: widget.onSelected,
              onActivated: widget.onActivated,
              rowHeight: widget.rowHeight,
              emptyLabel: widget.emptyLabel,
            ),
          ),
        ),
        if (showFilter)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: theme.density.rowHeight * .6,
                child: Row(
                  children: <Widget>[
                    BlenderIconButton(
                      glyph: _filterExpanded
                          ? BlenderGlyph.chevronDown
                          : BlenderGlyph.chevronRight,
                      onPressed: _toggleFilter,
                      tooltip: _filterExpanded
                          ? 'Hide filtering options'
                          : 'Show filtering options',
                      size: 20,
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: BlenderIcon(
                          BlenderGlyph.grip,
                          size: 10,
                          color: theme.colors.foregroundMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_filterExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                  child: BlenderFilterBar(
                    controller: widget.filterController!,
                    onChanged: widget.onFilterChanged,
                    onInvertFilter: widget.onInvertFilter,
                    onSortAlphabetically: widget.sortLocked
                        ? null
                        : widget.onSortAlphabetically,
                    onSortReverse: widget.sortLocked
                        ? null
                        : widget.onSortReverse,
                    invertFilter: widget.invertFilter,
                    sortAlphabetically: widget.sortAlphabetically,
                    sortReverse: widget.sortReverse,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
