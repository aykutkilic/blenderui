part of '../non3d_editors.dart';

class BlenderKeymapEntry {
  const BlenderKeymapEntry({
    required this.id,
    required this.action,
    required this.shortcut,
    this.category = 'General',
    this.detail,
    this.enabled = true,
  });

  final String id;
  final String action;
  final String shortcut;
  final String category;
  final String? detail;
  final bool enabled;
}

class BlenderKeymapEditor extends StatelessWidget {
  const BlenderKeymapEditor({
    super.key,
    required this.entries,
    required this.searchController,
    this.selectedId,
    this.onSelected,
    this.title = 'Keymap',
  });

  final List<BlenderKeymapEntry> entries;
  final TextEditingController searchController;
  final String? selectedId;
  final ValueChanged<BlenderKeymapEntry>? onSelected;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: searchController,
        builder: (context, value, child) {
          final query = value.text.trim().toLowerCase();
          final visible = entries
              .where(
                (entry) =>
                    query.isEmpty ||
                    entry.action.toLowerCase().contains(query) ||
                    entry.shortcut.toLowerCase().contains(query) ||
                    entry.category.toLowerCase().contains(query) ||
                    (entry.detail?.toLowerCase().contains(query) ?? false),
              )
              .toList(growable: false);
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
                child: BlenderFilterBar(
                  controller: searchController,
                  placeholder: 'Search keymap',
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? const Center(child: Text('No shortcuts'))
                    : ListView.builder(
                        itemCount: visible.length,
                        itemExtent: BlenderTheme.of(context).density.rowHeight,
                        itemBuilder: (context, index) {
                          final entry = visible[index];
                          final selected = entry.id == selectedId;
                          final active = entry.enabled && onSelected != null;
                          return Semantics(
                            selected: selected,
                            enabled: entry.enabled,
                            button: active,
                            label: '${entry.category}: ${entry.action}',
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: active ? () => onSelected!(entry) : null,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: selected
                                      ? BlenderTheme.of(
                                          context,
                                        ).colors.selection
                                      : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              entry.action,
                                              overflow: TextOverflow.ellipsis,
                                              style: BlenderTheme.of(
                                                context,
                                              ).textTheme.label,
                                            ),
                                            Text(
                                              entry.category,
                                              overflow: TextOverflow.ellipsis,
                                              style: BlenderTheme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .copyWith(
                                                    color: BlenderTheme.of(
                                                      context,
                                                    ).colors.foregroundMuted,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      BlenderKeycap(entry.shortcut),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
