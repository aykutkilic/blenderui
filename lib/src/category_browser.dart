import 'package:flutter/widgets.dart';

import 'controls.dart';
import 'icons.dart';
import 'theme.dart';

class BlenderCategoryItem<T> {
  const BlenderCategoryItem({
    required this.value,
    required this.label,
    this.description,
    this.keywords = '',
    this.glyph,
  });

  final T value;
  final String label;
  final String? description;
  final String keywords;
  final BlenderGlyph? glyph;

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    return normalized.isEmpty ||
        label.toLowerCase().contains(normalized) ||
        (description?.toLowerCase().contains(normalized) ?? false) ||
        keywords.toLowerCase().contains(normalized);
  }
}

class BlenderCategoryGroup<T> {
  const BlenderCategoryGroup({
    required this.id,
    required this.items,
    this.label,
  });

  final String id;
  final String? label;
  final List<BlenderCategoryItem<T>> items;
}

/// Reusable categorized navigation used by Preferences and master/detail UI.
class BlenderCategoryNavigation<T> extends StatelessWidget {
  const BlenderCategoryNavigation({
    super.key,
    required this.groups,
    required this.selected,
    required this.onSelected,
    this.searchController,
    this.searchPlaceholder = 'Search',
    this.emptyLabel = 'No matching categories',
    this.padding = const EdgeInsets.all(10),
  });

  final List<BlenderCategoryGroup<T>> groups;
  final T? selected;
  final ValueChanged<T> onSelected;
  final TextEditingController? searchController;
  final String searchPlaceholder;
  final String emptyLabel;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final search = searchController;
    if (search == null) return _buildList(context, '');
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: search,
      builder: (context, value, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: BlenderSearchField(
              controller: search,
              placeholder: searchPlaceholder,
            ),
          ),
          Expanded(child: _buildList(context, value.text)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, String query) {
    final visible = <BlenderCategoryGroup<T>>[
      for (final group in groups)
        BlenderCategoryGroup<T>(
          id: group.id,
          label: group.label,
          items: group.items.where((item) => item.matches(query)).toList(),
        ),
    ].where((group) => group.items.isNotEmpty).toList();
    if (visible.isEmpty) return Center(child: Text(emptyLabel));
    final theme = BlenderTheme.of(context);
    final scale = theme.density.interfaceScale;
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView(
        padding: padding,
        children: <Widget>[
          for (final group in visible) ...<Widget>[
            if (group.label != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  6 * scale,
                  5 * scale,
                  6 * scale,
                  3 * scale,
                ),
                child: Text(group.label!, style: theme.textTheme.heading),
              ),
            for (final item in group.items)
              _BlenderCategoryButton<T>(
                item: item,
                selected: item.value == selected,
                onPressed: () => onSelected(item.value),
              ),
            SizedBox(height: 6 * scale),
          ],
        ],
      ),
    );
  }
}

class _BlenderCategoryButton<T> extends StatelessWidget {
  const _BlenderCategoryButton({
    required this.item,
    required this.selected,
    required this.onPressed,
  });

  final BlenderCategoryItem<T> item;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final scale = theme.density.interfaceScale;
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          constraints: BoxConstraints(minHeight: theme.density.rowHeight),
          padding: EdgeInsets.symmetric(
            horizontal: 7 * scale,
            vertical: 4 * scale,
          ),
          decoration: BoxDecoration(
            color: selected ? theme.colors.selection : null,
            borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
          ),
          child: Row(
            children: <Widget>[
              if (item.glyph != null) ...<Widget>[
                BlenderIcon(item.glyph!, size: 15 * scale),
                SizedBox(width: 6 * scale),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(item.label, style: theme.textTheme.label),
                    if (item.description != null)
                      Text(
                        item.description!,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.caption.copyWith(
                          color: theme.colors.foregroundMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef BlenderCategoryDetailBuilder<T> =
    Widget Function(BuildContext context, T selected);

/// Generic searchable category/detail frame for dense editor tools.
class BlenderCategoryBrowser<T> extends StatelessWidget {
  const BlenderCategoryBrowser({
    super.key,
    required this.groups,
    required this.selected,
    required this.onSelected,
    required this.detailBuilder,
    this.searchController,
    this.navigationWidth = 220,
  });

  final List<BlenderCategoryGroup<T>> groups;
  final T selected;
  final ValueChanged<T> onSelected;
  final BlenderCategoryDetailBuilder<T> detailBuilder;
  final TextEditingController? searchController;
  final double navigationWidth;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          width: navigationWidth,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.surface,
              border: Border(
                right: BorderSide(color: theme.colors.editorBorder),
              ),
            ),
            child: BlenderCategoryNavigation<T>(
              groups: groups,
              selected: selected,
              onSelected: onSelected,
              searchController: searchController,
            ),
          ),
        ),
        Expanded(child: detailBuilder(context, selected)),
      ],
    );
  }
}
