part of '../specialized_templates.dart';

/// A descriptor-driven version of Blender's full `template_ID()` property
/// control.  The compact [BlenderDataBlockGroup] remains useful for headers;
/// this field covers the wider Properties-panel anatomy with a browse/search
/// surface and data-block lifecycle affordances.
class BlenderDataBlockField<T> extends StatelessWidget {
  const BlenderDataBlockField({
    super.key,
    required this.value,
    required this.items,
    this.label,
    this.placeholder = 'None',
    this.icon = BlenderGlyph.object,
    this.onChanged,
    this.onNew,
    this.onOpen,
    this.onMakeSingleUser,
    this.onMakeLocal,
    this.onToggleFakeUser,
    this.onUnlink,
    this.fakeUser = false,
    this.userCount = 0,
    this.linked = false,
    this.libraryOverride = false,
    this.showPreviews = false,
    this.enabled = true,
    this.fieldWidth,
  });

  final T? value;
  final List<BlenderMenuItem<T>> items;
  final String? label;
  final String placeholder;
  final BlenderGlyph icon;
  final ValueChanged<T>? onChanged;
  final VoidCallback? onNew;
  final VoidCallback? onOpen;
  final VoidCallback? onMakeSingleUser;
  final VoidCallback? onMakeLocal;
  final ValueChanged<bool>? onToggleFakeUser;
  final VoidCallback? onUnlink;
  final bool fakeUser;
  final int userCount;
  final bool linked;
  final bool libraryOverride;
  final bool showPreviews;
  final bool enabled;
  final double? fieldWidth;

  BlenderMenuItem<T>? _selectedItem() {
    for (final item in items) {
      if (item.value == value) return item;
    }
    return null;
  }

  Widget _browseField(BuildContext context, BlenderMenuItem<T>? selected) {
    final theme = BlenderTheme.of(context);
    final hasValue = value != null;
    final field = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.textField,
        border: Border.all(color: theme.colors.borderSubtle),
        borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
      ),
      child: SizedBox(
        height: theme.density.controlHeight,
        child: Row(
          children: <Widget>[
            const SizedBox(width: 5),
            selected?.icon ?? BlenderIcon(icon, size: 14),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                selected?.label ?? placeholder,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.label.copyWith(
                  color: hasValue
                      ? theme.colors.foreground
                      : theme.colors.foregroundMuted,
                ),
              ),
            ),
            BlenderIcon(
              BlenderGlyph.chevronDown,
              size: 12,
              color: theme.colors.foregroundMuted,
            ),
            const SizedBox(width: 5),
          ],
        ),
      ),
    );
    return BlenderPopover(
      child: Semantics(
        container: true,
        button: true,
        enabled: enabled && onChanged != null,
        label: 'Browse ${label ?? 'data-block'}',
        child: IgnorePointer(child: field),
      ),
      popover: (context, close) => _BlenderDataBlockBrowser<T>(
        items: items,
        selectedValue: value,
        showPreviews: showPreviews,
        onSelected: onChanged == null
            ? null
            : (item) {
                onChanged!(item.value);
                close();
              },
      ),
    );
  }

  Widget _action({
    required BlenderGlyph glyph,
    required String tooltip,
    required VoidCallback? onPressed,
    bool selected = false,
  }) {
    return BlenderIconButton(
      glyph: glyph,
      selected: selected,
      enabled: enabled,
      onPressed: enabled ? onPressed : null,
      tooltip: tooltip,
      size: 22,
    );
  }

  Widget _content(BuildContext context) {
    final selected = _selectedItem();
    final actions = <Widget>[
      if (onNew != null)
        value == null
            ? BlenderButton(
                label: 'New',
                leading: const BlenderIcon(BlenderGlyph.plus, size: 13),
                enabled: enabled,
                onPressed: enabled ? onNew : null,
                padding: const EdgeInsets.symmetric(horizontal: 7),
              )
            : _action(
                glyph: BlenderGlyph.duplicate,
                tooltip: 'Make new data-block',
                onPressed: onNew,
              ),
      if (userCount > 1 && onMakeSingleUser != null)
        BlenderButton(
          label: '$userCount',
          enabled: enabled,
          onPressed: enabled ? onMakeSingleUser : null,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          variant: BlenderButtonVariant.toolbar,
        ),
      if (linked)
        _action(
          glyph: BlenderGlyph.link,
          tooltip: 'Make local',
          onPressed: onMakeLocal,
        ),
      if (libraryOverride)
        _action(
          glyph: BlenderGlyph.linkBroken,
          tooltip: 'Library override',
          onPressed: onMakeLocal,
        ),
      if (onToggleFakeUser != null && value != null)
        _action(
          glyph: BlenderGlyph.pin,
          tooltip: 'Keep data-block',
          selected: fakeUser,
          onPressed: () => onToggleFakeUser!(!fakeUser),
        ),
      if (onOpen != null)
        value == null
            ? BlenderButton(
                label: 'Open',
                leading: const BlenderIcon(BlenderGlyph.open, size: 13),
                enabled: enabled,
                onPressed: enabled ? onOpen : null,
                padding: const EdgeInsets.symmetric(horizontal: 7),
              )
            : _action(
                glyph: BlenderGlyph.open,
                tooltip: 'Open data-block',
                onPressed: onOpen,
              ),
      if (onUnlink != null && value != null)
        _action(
          glyph: BlenderGlyph.close,
          tooltip: 'Unlink data-block',
          onPressed: onUnlink,
        ),
    ];
    final field = Row(
      children: <Widget>[
        Expanded(child: _browseField(context, selected)),
        if (actions.isNotEmpty) ...<Widget>[
          const SizedBox(width: 3),
          ...actions,
        ],
      ],
    );
    if (label == null) return field;
    return Row(
      children: <Widget>[
        SizedBox(
          width: 88,
          child: Text(label!, style: BlenderTheme.of(context).textTheme.label),
        ),
        Expanded(child: field),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _content(context);
    return fieldWidth == null
        ? content
        : SizedBox(width: fieldWidth, child: content);
  }
}

class _BlenderDataBlockBrowser<T> extends StatefulWidget {
  const _BlenderDataBlockBrowser({
    required this.items,
    required this.selectedValue,
    required this.showPreviews,
    required this.onSelected,
  });

  final List<BlenderMenuItem<T>> items;
  final T? selectedValue;
  final bool showPreviews;
  final ValueChanged<BlenderMenuItem<T>>? onSelected;

  @override
  State<_BlenderDataBlockBrowser<T>> createState() =>
      _BlenderDataBlockBrowserState<T>();
}

class _BlenderDataBlockBrowserState<T>
    extends State<_BlenderDataBlockBrowser<T>> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 280,
        maxWidth: 360,
        minHeight: 250,
        maxHeight: 420,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.menuBackground,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
        ),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchController,
          builder: (context, value, child) {
            final query = value.text.trim().toLowerCase();
            final visible = widget.items
                .where((item) => item.label.toLowerCase().contains(query))
                .toList(growable: false);
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: BlenderSearchField(
                    controller: _searchController,
                    placeholder: 'Search data-blocks',
                  ),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? Center(
                          child: Text(
                            'No data-blocks',
                            style: theme.textTheme.caption.copyWith(
                              color: theme.colors.foregroundMuted,
                            ),
                          ),
                        )
                      : widget.showPreviews
                      ? GridView.builder(
                          padding: const EdgeInsets.all(5),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 112,
                                mainAxisExtent: 92,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                              ),
                          itemCount: visible.length,
                          itemBuilder: (context, index) {
                            final item = visible[index];
                            return BlenderPreviewTile(
                              label: item.label,
                              selected: item.value == widget.selectedValue,
                              preview: item.icon == null
                                  ? null
                                  : Center(child: item.icon),
                              onPressed:
                                  item.enabled && widget.onSelected != null
                                  ? () => widget.onSelected!(item)
                                  : null,
                              width: 100,
                              height: 88,
                            );
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          itemCount: visible.length,
                          itemBuilder: (context, index) {
                            final item = visible[index];
                            return BlenderButton(
                              label: item.label,
                              leading: item.icon,
                              selected: item.value == widget.selectedValue,
                              enabled: item.enabled,
                              variant: BlenderButtonVariant.menu,
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              onPressed:
                                  item.enabled && widget.onSelected != null
                                  ? () => widget.onSelected!(item)
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
