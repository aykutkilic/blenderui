part of '../editors.dart';

/// Blender's compact header for both the File Browser and Asset Browser.
///
/// Navigation belongs to [BlenderFileBrowserPathBar]; this header owns editor
/// menus and browser-wide display/filter state, mirroring `space_filebrowser.py`.
class BlenderFileBrowserHeader extends StatelessWidget {
  const BlenderFileBrowserHeader({
    super.key,
    required this.state,
    this.mode = BlenderFileBrowserMode.files,
    this.onStateChanged,
    this.onCommand,
    this.searchController,
    this.height = 28,
  });

  final BlenderFileBrowserHeaderState state;
  final BlenderFileBrowserMode mode;
  final ValueChanged<BlenderFileBrowserHeaderState>? onStateChanged;
  final ValueChanged<String>? onCommand;
  final TextEditingController? searchController;
  final double height;

  bool get _assets => mode == BlenderFileBrowserMode.assets;

  void _update(BlenderFileBrowserHeaderState value) =>
      onStateChanged?.call(value);

  @override
  Widget build(BuildContext context) {
    final menus = _assets
        ? const <String>['View', 'Select', 'Catalog', 'Asset']
        : const <String>['View', 'Select'];
    return BlenderToolbar(
      key: ValueKey<String>(
        _assets ? 'asset-browser-header-region' : 'file-browser-header-region',
      ),
      height: height,
      children: <Widget>[
        BlenderIconButton(
          glyph: _assets ? BlenderGlyph.assetManager : BlenderGlyph.folder,
          tooltip: _assets ? 'Asset Browser' : 'File Browser',
          size: 24,
        ),
        for (final label in menus)
          BlenderMenuButton<String>(
            label: label,
            items: <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: label.toLowerCase(),
                label: '$label Menu',
              ),
            ],
            onSelected: onCommand,
          ),
        const Spacer(),
        if (_assets)
          SizedBox(
            width: 142,
            child: BlenderDropdown<String>(
              key: const ValueKey<String>('asset-import-method'),
              value: state.importMethod,
              compact: true,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'Append (Reuse Data)',
                  label: 'Import Settings',
                ),
                BlenderMenuItem<String>(value: 'Link', label: 'Link'),
                BlenderMenuItem<String>(value: 'Append', label: 'Append'),
              ],
              onChanged: (value) =>
                  _update(state.copyWith(importMethod: value)),
            ),
          ),
        const Spacer(),
        ...BlenderFileDisplayMode.values.map(
          (mode) => BlenderIconButton(
            key: ValueKey<String>('file-display-${mode.name}'),
            glyph: switch (mode) {
              BlenderFileDisplayMode.listVertical => BlenderGlyph.outliner,
              BlenderFileDisplayMode.listHorizontal => BlenderGlyph.menu,
              BlenderFileDisplayMode.thumbnails => BlenderGlyph.grid,
            },
            selected: state.displayMode == mode,
            onPressed: () => _update(state.copyWith(displayMode: mode)),
            tooltip: switch (mode) {
              BlenderFileDisplayMode.listVertical => 'Vertical List',
              BlenderFileDisplayMode.listHorizontal => 'Horizontal List',
              BlenderFileDisplayMode.thumbnails => 'Thumbnails',
            },
            size: 24,
          ),
        ),
        if (_assets && searchController != null)
          SizedBox(
            width: 180,
            child: BlenderFilterBar(
              controller: searchController!,
              placeholder: 'Search',
            ),
          ),
        BlenderPopover(
          child: BlenderIconButton(
            glyph: BlenderGlyph.filter,
            selected: state.filterEnabled,
            tooltip: 'Filter',
            size: 24,
          ),
          popover: (context, close) => _BlenderFileBrowserSettingsPopover(
            assets: _assets,
            filter: true,
            state: state,
            onStateChanged: _update,
          ),
        ),
        BlenderPopover(
          child: const BlenderIconButton(
            glyph: BlenderGlyph.settings,
            tooltip: 'Options',
            size: 24,
          ),
          popover: (context, close) => _BlenderFileBrowserSettingsPopover(
            assets: _assets,
            filter: false,
            state: state,
            onStateChanged: _update,
          ),
        ),
      ],
    );
  }
}

class _BlenderFileBrowserSettingsPopover extends StatelessWidget {
  const _BlenderFileBrowserSettingsPopover({
    required this.assets,
    required this.filter,
    required this.state,
    required this.onStateChanged,
  });

  final bool assets;
  final bool filter;
  final BlenderFileBrowserHeaderState state;
  final ValueChanged<BlenderFileBrowserHeaderState> onStateChanged;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 310, maxHeight: 600),
    child: BlenderPanel(
      title: filter ? 'Filter' : 'Display Settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: filter ? _filters() : _display(),
      ),
    ),
  );

  List<Widget> _display() => <Widget>[
    BlenderStaticPropertyField.menu(
      'Display Type',
      switch (state.displayMode) {
        BlenderFileDisplayMode.listVertical => 'List Vertical',
        BlenderFileDisplayMode.listHorizontal => 'List Horizontal',
        BlenderFileDisplayMode.thumbnails => 'Thumbnail',
      },
      const <String>['List Vertical', 'List Horizontal', 'Thumbnail'],
    ),
    BlenderStaticPropertyField.menu('Preview Size', 'Medium', const <String>[
      'Small',
      'Medium',
      'Large',
    ]),
    if (!assets)
      BlenderStaticPropertyField.menu('Recursions', 'None', const <String>[
        'None',
        'One Level',
        'All',
      ]),
    BlenderStaticPropertyField.menu('Sort By', 'Name', const <String>[
      'Name',
      'Modified',
      'Size',
      'Type',
    ]),
    BlenderStaticPropertyField.checkbox('Invert Sort', value: false),
  ];

  List<Widget> _filters() => assets
      ? <Widget>[
          BlenderStaticPropertyField.checkbox('Blender IDs'),
          BlenderStaticPropertyField.checkbox('Objects'),
          BlenderStaticPropertyField.checkbox('Materials'),
          BlenderStaticPropertyField.checkbox('Collections'),
          BlenderStaticPropertyField.checkbox('Worlds', value: false),
          BlenderStaticPropertyField.menu('Access', 'All', const <String>[
            'All',
            'Local',
            'Remote',
          ]),
        ]
      : <Widget>[
          BlenderCheckbox(
            value: state.showHidden,
            label: 'Show Hidden',
            onChanged: (value) =>
                onStateChanged(state.copyWith(showHidden: value)),
          ),
          BlenderStaticPropertyField.checkbox('Folders'),
          BlenderStaticPropertyField.checkbox('.blend Files'),
          BlenderStaticPropertyField.checkbox(
            'Backup .blend Files',
            value: false,
          ),
          BlenderStaticPropertyField.checkbox('Image Files'),
          BlenderStaticPropertyField.checkbox('Movie Files', value: false),
          BlenderStaticPropertyField.checkbox('Script Files', value: false),
          BlenderStaticPropertyField.checkbox('Font Files', value: false),
          BlenderStaticPropertyField.checkbox('Sound Files', value: false),
          BlenderStaticPropertyField.checkbox('Text Files', value: false),
          BlenderStaticPropertyField.checkbox('Volume Files', value: false),
        ];
}

/// File Browser directory controls, intentionally separate from the header.
class BlenderFileBrowserPathBar extends StatelessWidget {
  const BlenderFileBrowserPathBar({
    super.key,
    required this.pathController,
    this.searchController,
    this.onBack,
    this.onForward,
    this.onParent,
    this.onRefresh,
    this.onNewFolder,
  });

  final TextEditingController pathController;
  final TextEditingController? searchController;
  final VoidCallback? onBack;
  final VoidCallback? onForward;
  final VoidCallback? onParent;
  final VoidCallback? onRefresh;
  final VoidCallback? onNewFolder;

  @override
  Widget build(BuildContext context) => BlenderToolbar(
    key: const ValueKey<String>('file-browser-path-region'),
    height: 36,
    children: <Widget>[
      BlenderIconButton(
        glyph: BlenderGlyph.stepBack,
        onPressed: onBack,
        tooltip: 'Back',
      ),
      BlenderIconButton(
        glyph: BlenderGlyph.stepForward,
        onPressed: onForward,
        tooltip: 'Forward',
      ),
      BlenderIconButton(
        glyph: BlenderGlyph.chevronUp,
        onPressed: onParent,
        tooltip: 'Parent Directory',
      ),
      BlenderIconButton(
        glyph: BlenderGlyph.refresh,
        onPressed: onRefresh,
        tooltip: 'Refresh',
      ),
      BlenderIconButton(
        glyph: BlenderGlyph.plus,
        onPressed: onNewFolder,
        tooltip: 'New Folder',
      ),
      Expanded(child: BlenderTextField(controller: pathController)),
      if (searchController != null)
        SizedBox(
          width: 150,
          child: BlenderFilterBar(
            controller: searchController!,
            placeholder: 'Search',
          ),
        ),
    ],
  );
}

/// The File Browser's left-side Bookmarks/System/Volumes source region.
class BlenderFileBrowserSourceList extends StatelessWidget {
  const BlenderFileBrowserSourceList({
    super.key,
    required this.sections,
    this.selectedId,
    this.onSelected,
    this.onAdd,
    this.width = 270,
  });

  final List<BlenderFileSourceSection> sections;
  final String? selectedId;
  final ValueChanged<BlenderFileSourceEntry>? onSelected;
  final ValueChanged<BlenderFileSourceSection>? onAdd;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return SizedBox(
      key: const ValueKey<String>('file-browser-source-region'),
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.surface,
          border: Border(right: BorderSide(color: theme.colors.editorBorder)),
        ),
        child: ListView(
          padding: const EdgeInsets.all(6),
          children: <Widget>[
            for (final section in sections) _section(context, section),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, BlenderFileSourceSection section) {
    final theme = BlenderTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.editorBorder),
        borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 32,
            child: Row(
              children: <Widget>[
                const SizedBox(width: 8),
                const BlenderIcon(BlenderGlyph.panelDisclosureDown, size: 13),
                const SizedBox(width: 5),
                Expanded(child: Text(section.label)),
                if (section.allowAdd)
                  BlenderIconButton(
                    glyph: BlenderGlyph.plus,
                    onPressed: () => onAdd?.call(section),
                    tooltip: 'Add ${section.label}',
                    size: 24,
                  ),
                const BlenderIcon(BlenderGlyph.dragHandle, size: 13),
                const SizedBox(width: 6),
              ],
            ),
          ),
          for (final entry in section.entries)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected?.call(entry),
              child: Container(
                height: 29,
                margin: const EdgeInsets.symmetric(horizontal: 9),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: selectedId == entry.id
                      ? theme.colors.selection
                      : const Color(0x00000000),
                  borderRadius: BorderRadius.circular(
                    theme.shapes.controlRadius,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    BlenderIcon(entry.icon, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(entry.label, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

/// Left-side asset library and catalog tree region used by the Asset Browser.
class BlenderAssetBrowserCatalogRegion extends StatelessWidget {
  const BlenderAssetBrowserCatalogRegion({
    super.key,
    required this.catalogs,
    this.library = 'All Libraries',
    this.selectedCatalogId = '__all__',
    this.onLibraryChanged,
    this.onCatalogSelected,
    this.onRefresh,
    this.width = 280,
  });

  final List<BlenderAssetCatalog> catalogs;
  final String library;
  final String selectedCatalogId;
  final ValueChanged<String>? onLibraryChanged;
  final ValueChanged<String>? onCatalogSelected;
  final VoidCallback? onRefresh;
  final double width;

  @override
  Widget build(BuildContext context) {
    final roots = <BlenderTreeNode<String>>[
      BlenderTreeNode<String>(
        id: '__all__',
        label: 'All',
        value: '__all__',
        initiallyExpanded: true,
        children: catalogs.map(_node).toList(),
      ),
      const BlenderTreeNode<String>(
        id: '__unassigned__',
        label: 'Unassigned',
        value: '__unassigned__',
        icon: BlenderGlyph.file,
      ),
    ];
    return SizedBox(
      key: const ValueKey<String>('asset-browser-catalog-region'),
      width: width,
      child: BlenderPanel(
        title: null,
        padding: const EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: BlenderDropdown<String>(
                    value: library,
                    items: const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(
                        value: 'All Libraries',
                        label: 'All Libraries',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Current File',
                        label: 'Current File',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Essentials',
                        label: 'Essentials',
                      ),
                    ],
                    onChanged: onLibraryChanged,
                  ),
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.refresh,
                  onPressed: onRefresh,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlenderTree<String>(
                roots: roots,
                selectedId: selectedCatalogId,
                onSelected: (node) => onCatalogSelected?.call(node.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BlenderTreeNode<String> _node(BlenderAssetCatalog catalog) =>
      BlenderTreeNode<String>(
        id: catalog.id,
        label: catalog.label,
        value: catalog.id,
        icon: BlenderGlyph.folder,
        initiallyExpanded: catalog.initiallyExpanded,
        children: catalog.children.map(_node).toList(),
      );
}
