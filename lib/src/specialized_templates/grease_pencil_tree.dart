part of '../specialized_templates.dart';

class _BlenderGreasePencilLayerTreeState
    extends State<BlenderGreasePencilLayerTree> {
  late Set<String> _expanded = _initialExpanded(widget.layers);
  late final TextEditingController _emptySearchController;

  @override
  void initState() {
    super.initState();
    _emptySearchController = TextEditingController();
  }

  static Set<String> _initialExpanded(List<BlenderGreasePencilLayer> layers) =>
      BlenderTreeState.initialExpanded<BlenderGreasePencilLayer>(
        layers,
        idOf: (layer) => layer.id,
        childrenOf: (layer) => layer.children,
        initiallyExpanded: (layer) => layer.isGroup && layer.initiallyExpanded,
      );

  @override
  void didUpdateWidget(BlenderGreasePencilLayerTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    _expanded = <String>{..._expanded, ..._initialExpanded(widget.layers)};
  }

  @override
  void dispose() {
    _emptySearchController.dispose();
    super.dispose();
  }

  List<BlenderTreeEntry<BlenderGreasePencilLayer>> _visibleRows(
    List<BlenderGreasePencilLayer> layers,
    String query,
  ) {
    final normalizedQuery = query.toLowerCase();
    return BlenderTreeState.flatten<BlenderGreasePencilLayer>(
      layers,
      idOf: (layer) => layer.id,
      childrenOf: (layer) => layer.children,
      expanded: _expanded,
      include: (layer) =>
          query.isEmpty || layer.name.toLowerCase().contains(normalizedQuery),
      expandWhen: (layer) => query.isEmpty || _expanded.contains(layer.id),
    );
  }

  Widget _restrictionButton({
    required BlenderGlyph glyph,
    required bool selected,
    required bool enabled,
    required ValueChanged<bool>? onChanged,
    required String tooltip,
  }) {
    return BlenderIconButton(
      glyph: glyph,
      selected: selected,
      enabled: enabled,
      onPressed: onChanged == null ? null : () => onChanged(!selected),
      tooltip: tooltip,
      size: 21,
    );
  }

  Widget _row(
    BuildContext context,
    BlenderTreeEntry<BlenderGreasePencilLayer> visible,
  ) {
    final theme = BlenderTheme.of(context);
    final layer = visible.value;
    final expandable = layer.isGroup && layer.children.isNotEmpty;
    final indent = 8.0 + visible.depth * 14;
    return SizedBox(
      height: theme.density.rowHeight,
      child: Row(
        children: <Widget>[
          SizedBox(width: indent),
          if (expandable)
            BlenderDisclosureButton(
              expanded: _expanded.contains(layer.id),
              onPressed: () => setState(() {
                if (_expanded.contains(layer.id)) {
                  _expanded.remove(layer.id);
                } else {
                  _expanded.add(layer.id);
                }
              }),
              size: 18,
              tooltip: 'Expand ${layer.name}',
            )
          else
            const SizedBox(width: 18),
          GestureDetector(
            onTap: layer.enabled ? layer.onActivate : null,
            child: Row(
              children: <Widget>[
                BlenderIcon(
                  layer.isGroup ? BlenderGlyph.collection : BlenderGlyph.object,
                  size: 15,
                  color: layer.active ? theme.colors.accentHover : null,
                ),
                const SizedBox(width: 5),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: layer.enabled ? layer.onActivate : null,
              child: Text(
                layer.name,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.label.copyWith(
                  color: layer.enabled
                      ? theme.colors.foreground
                      : theme.colors.foregroundDisabled,
                ),
              ),
            ),
          ),
          _restrictionButton(
            glyph: BlenderGlyph.link,
            selected: layer.useMasks,
            enabled: layer.enabled,
            onChanged: layer.onMasksChanged,
            tooltip: 'Use masks',
          ),
          _restrictionButton(
            glyph: BlenderGlyph.color,
            selected: layer.useOnionSkinning,
            enabled: layer.enabled,
            onChanged: layer.onOnionSkinningChanged,
            tooltip: 'Use onion skinning',
          ),
          _restrictionButton(
            glyph: BlenderGlyph.eye,
            selected: !layer.hidden,
            enabled: layer.enabled,
            onChanged: layer.onHiddenChanged == null
                ? null
                : (visible) => layer.onHiddenChanged!(!visible),
            tooltip: 'Show layer',
          ),
          _restrictionButton(
            glyph: BlenderGlyph.lock,
            selected: !layer.locked,
            enabled: layer.enabled,
            onChanged: layer.onLockedChanged == null
                ? null
                : (visible) => layer.onLockedChanged!(!visible),
            tooltip: 'Unlock layer',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final search = widget.searchController;
    return BlenderPanel(
      title: widget.title,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (search != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
              child: BlenderSearchField(
                controller: search,
                placeholder: 'Search layers',
              ),
            ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: search ?? _emptySearchController,
            builder: (context, value, child) {
              final rows = _visibleRows(widget.layers, value.text.trim());
              if (rows.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    widget.emptyLabel,
                    style: BlenderTheme.of(context).textTheme.caption,
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[for (final row in rows) _row(context, row)],
              );
            },
          ),
        ],
      ),
    );
  }
}
