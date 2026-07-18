part of '../specialized_templates.dart';

class _BlenderBoneCollectionTreeState extends State<BlenderBoneCollectionTree> {
  late final Set<String> _expanded = _initialExpanded(widget.collections);

  static Set<String> _initialExpanded(List<BlenderBoneCollection> items) =>
      BlenderTreeState.initialExpanded<BlenderBoneCollection>(
        items,
        idOf: (item) => item.id,
        childrenOf: (item) => item.children,
        initiallyExpanded: (item) => item.initiallyExpanded,
      );

  Widget _row(
    BuildContext context,
    BlenderTreeEntry<BlenderBoneCollection> visible,
  ) {
    final theme = BlenderTheme.of(context);
    final collection = visible.value;
    final expandable = collection.children.isNotEmpty;
    return SizedBox(
      height: theme.density.rowHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Properties can become substantially narrower than a standalone
          // Bone Collections editor. Keep the source-like columns visible,
          // but tighten their footprint before the row can overflow.
          final compact = constraints.maxWidth < 120;
          final depthIndent = compact
              ? 4.0 + visible.depth * 10
              : 8.0 + visible.depth * 14;
          final disclosureSize = compact ? 16.0 : 18.0;
          final statusSize = compact ? 14.0 : 15.0;
          final restrictionSize = compact ? 18.0 : 21.0;
          return Row(
            children: <Widget>[
              SizedBox(width: depthIndent),
              if (expandable)
                BlenderDisclosureButton(
                  expanded: _expanded.contains(collection.id),
                  onPressed: () => setState(() {
                    if (_expanded.contains(collection.id)) {
                      _expanded.remove(collection.id);
                    } else {
                      _expanded.add(collection.id);
                    }
                  }),
                  size: disclosureSize,
                )
              else
                SizedBox(width: disclosureSize),
              Expanded(
                child: GestureDetector(
                  onTap: collection.enabled ? collection.onActivate : null,
                  child: Text(
                    collection.name,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.label.copyWith(
                      color: collection.enabled
                          ? (collection.active
                                ? theme.colors.accentHover
                                : theme.colors.foreground)
                          : theme.colors.foregroundDisabled,
                    ),
                  ),
                ),
              ),
              BlenderIcon(
                collection.active
                    ? BlenderGlyph.checkCircle
                    : collection.hasSelectedBones
                    ? BlenderGlyph.radio
                    : BlenderGlyph.minus,
                size: statusSize,
                color: collection.hasSelectedBones || collection.active
                    ? theme.colors.accentHover
                    : theme.colors.foregroundMuted,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.eye,
                selected: collection.visible,
                enabled: collection.enabled,
                onPressed: collection.onVisibilityChanged == null
                    ? null
                    : () =>
                          collection.onVisibilityChanged!(!collection.visible),
                tooltip: 'Show bone collection',
                size: restrictionSize,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.radio,
                selected: collection.solo,
                enabled: collection.enabled,
                onPressed: collection.onSoloChanged == null
                    ? null
                    : () => collection.onSoloChanged!(!collection.solo),
                tooltip: 'Solo bone collection',
                size: restrictionSize,
              ),
              if (collection.onRemove != null)
                BlenderIconButton(
                  glyph: BlenderGlyph.close,
                  onPressed: collection.onRemove,
                  tooltip: 'Remove bone collection',
                  size: restrictionSize,
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = BlenderTreeState.flatten<BlenderBoneCollection>(
      widget.collections,
      idOf: (item) => item.id,
      childrenOf: (item) => item.children,
      expanded: _expanded,
    );
    final content = rows.isEmpty
        ? Text(
            widget.emptyLabel,
            style: BlenderTheme.of(context).textTheme.caption,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[for (final row in rows) _row(context, row)],
          );
    return widget.showPanel
        ? BlenderPanel(title: widget.title, child: content)
        : content;
  }
}
