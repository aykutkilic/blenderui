part of '../specialized_templates.dart';

class _BlenderAssetLibrariesPreferencesPanelState
    extends State<BlenderAssetLibrariesPreferencesPanel> {
  final Map<String, TextEditingController> _pathControllers =
      <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(BlenderAssetLibrariesPreferencesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  void _syncControllers() {
    final ids = widget.libraries.map((library) => library.id).toSet();
    for (final id in _pathControllers.keys.toList()) {
      if (!ids.contains(id)) _pathControllers.remove(id)?.dispose();
    }
    for (final library in widget.libraries) {
      final controller = _pathControllers.putIfAbsent(
        library.id,
        () => TextEditingController(),
      );
      final text = library.isRemote ? library.remoteUrl : library.path;
      if (controller.text != text) controller.text = text;
    }
  }

  @override
  void dispose() {
    for (final controller in _pathControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  BlenderAssetLibraryPreference? get _selected {
    for (final library in widget.libraries) {
      if (library.id == widget.selectedId) return library;
    }
    return widget.libraries.isEmpty ? null : widget.libraries.first;
  }

  Widget _libraryRow(
    BuildContext context,
    BlenderAssetLibraryPreference library,
  ) {
    final theme = BlenderTheme.of(context);
    final selected = library.id == (_selected?.id ?? widget.selectedId);
    final icon = library.isRemote
        ? BlenderGlyph.internet
        : BlenderGlyph.diskDrive;
    return Semantics(
      selected: selected,
      button: widget.onSelected != null,
      label: library.name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onSelected == null
            ? null
            : () => widget.onSelected!(library),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? theme.colors.selection : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Row(
              children: <Widget>[
                if (!library.builtIn) ...<Widget>[
                  BlenderIcon(
                    icon,
                    size: 14,
                    color: library.isRemote
                        ? theme.colors.accentHover
                        : theme.colors.iconFolder,
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    library.name,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.label.copyWith(
                      color: library.builtIn
                          ? theme.colors.foregroundMuted
                          : theme.colors.foreground,
                    ),
                  ),
                ),
                if (library.builtIn)
                  Text(
                    'Built-In',
                    style: theme.textTheme.caption.copyWith(
                      color: theme.colors.foregroundMuted,
                    ),
                  ),
                if (library.invalid)
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: BlenderIcon(
                      BlenderGlyph.errorFilled,
                      size: 14,
                      color: theme.colors.error,
                    ),
                  ),
                if (!library.builtIn && widget.onEnabledChanged != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: BlenderCheckbox(
                      value: library.enabled,
                      onChanged: (value) =>
                          widget.onEnabledChanged!(library, value),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _settings(
    BuildContext context,
    BlenderAssetLibraryPreference library,
  ) {
    final controller = _pathControllers[library.id];
    final pathLabel = library.isRemote ? 'Repository URL' : 'Path';
    final importItems = <BlenderMenuItem<String>>[
      if (!library.isRemote)
        const BlenderMenuItem<String>(value: 'Link', label: 'Link'),
      const BlenderMenuItem<String>(value: 'Append', label: 'Append'),
      const BlenderMenuItem<String>(
        value: 'Append (Reuse Data)',
        label: 'Append (Reuse Data)',
      ),
      const BlenderMenuItem<String>(value: 'Pack', label: 'Pack'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (library.isEssentials)
          BlenderCheckbox(
            value: library.includeOnlineEssentials,
            label: 'Include Online Essentials',
            onChanged: library.onlineEssentialsEnabled
                ? widget.onIncludeOnlineEssentialsChanged
                : null,
          ),
        if (controller != null && !library.builtIn)
          BlenderTextField(
            controller: controller,
            label: pathLabel,
            onChanged: (value) => widget.onPathChanged?.call(library, value),
            trailing: library.invalid
                ? BlenderIcon(
                    BlenderGlyph.errorFilled,
                    size: 14,
                    color: BlenderTheme.of(context).colors.error,
                  )
                : null,
            backgroundColor: library.invalid
                ? BlenderTheme.of(context).colors.warning.withValues(alpha: .16)
                : null,
          ),
        if (!library.builtIn) ...<Widget>[
          const SizedBox(height: 5),
          BlenderPropertyRow(
            label: 'Import Method',
            editor: BlenderDropdown<String>(
              value:
                  importItems.any((item) => item.value == library.importMethod)
                  ? library.importMethod
                  : importItems.first.value,
              items: importItems,
              onChanged: widget.onImportMethodChanged == null
                  ? null
                  : (value) => widget.onImportMethodChanged!(library, value),
            ),
          ),
          if (!library.isRemote)
            BlenderPropertyRow(
              label: 'Use Relative Path',
              editor: BlenderCheckbox(
                value: library.useRelativePath,
                label: '',
                onChanged: widget.onRelativePathChanged == null
                    ? null
                    : (value) => widget.onRelativePathChanged!(library, value),
              ),
            ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return BlenderPanel(
      title: widget.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: widget.libraryListHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: BlenderBox(
                    padding: EdgeInsets.zero,
                    child: ListView.builder(
                      itemCount: widget.libraries.length,
                      itemExtent: 28,
                      itemBuilder: (context, index) =>
                          _libraryRow(context, widget.libraries[index]),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    BlenderIconButton(
                      glyph: BlenderGlyph.plus,
                      onPressed: widget.onAdd,
                      tooltip: 'Add asset library',
                      size: 24,
                    ),
                    BlenderIconButton(
                      glyph: BlenderGlyph.minus,
                      onPressed: selected != null && !selected.builtIn
                          ? widget.onRemove
                          : null,
                      tooltip: 'Remove asset library',
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (selected != null) ...<Widget>[
            const SizedBox(height: 8),
            _settings(context, selected),
          ],
        ],
      ),
    );
  }
}
