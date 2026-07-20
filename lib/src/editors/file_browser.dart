part of '../editors.dart';

class BlenderFileBrowser extends StatelessWidget {
  const BlenderFileBrowser({
    super.key,
    required this.entries,
    this.selectedPath,
    this.onSelected,
    this.onOpen,
    this.contextMenuItemsBuilder,
    this.onContextMenuSelected,
    this.searchController,
    this.pathSegments = const <String>[],
    this.onPathSelected,
    this.gridView = false,
    this.onGridViewChanged,
    this.sortColumn = BlenderFileBrowserSortColumn.name,
    this.sortDirection = BlenderFileBrowserSortDirection.ascending,
    this.onSortChanged,
    this.previewBuilder,
    this.showListColumns = true,
    this.onBack,
    this.onForward,
    this.onParent,
    this.onRefresh,
    this.onNewFolder,
    this.sidebar,
    this.sidebarWidth = 220,
    this.assetBrowser = false,
    this.title = 'File Browser',
    this.headerState,
    this.onHeaderStateChanged,
    this.onCommand,
    this.sourceList,
    this.pathController,
    this.showHeader = true,
    this.catalogId,
  });

  final List<BlenderFileEntry> entries;
  final String? selectedPath;
  final ValueChanged<BlenderFileEntry>? onSelected;
  final ValueChanged<BlenderFileEntry>? onOpen;
  final List<BlenderMenuItem<String>> Function(BlenderFileEntry)?
  contextMenuItemsBuilder;
  final void Function(BlenderFileEntry, String)? onContextMenuSelected;
  final TextEditingController? searchController;
  final List<String> pathSegments;
  final ValueChanged<int>? onPathSelected;
  final bool gridView;
  final ValueChanged<bool>? onGridViewChanged;
  final BlenderFileBrowserSortColumn sortColumn;
  final BlenderFileBrowserSortDirection sortDirection;
  final void Function(
    BlenderFileBrowserSortColumn column,
    BlenderFileBrowserSortDirection direction,
  )?
  onSortChanged;
  final BlenderFileBrowserPreviewBuilder? previewBuilder;
  final bool showListColumns;
  final VoidCallback? onBack;
  final VoidCallback? onForward;
  final VoidCallback? onParent;
  final VoidCallback? onRefresh;
  final VoidCallback? onNewFolder;
  final Widget? sidebar;
  final double sidebarWidth;
  final bool assetBrowser;
  final String? title;
  final BlenderFileBrowserHeaderState? headerState;
  final ValueChanged<BlenderFileBrowserHeaderState>? onHeaderStateChanged;
  final ValueChanged<String>? onCommand;
  final Widget? sourceList;
  final TextEditingController? pathController;
  final bool showHeader;
  final String? catalogId;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final resolvedHeaderState =
        headerState ??
        BlenderFileBrowserHeaderState(
          displayMode: gridView
              ? BlenderFileDisplayMode.thumbnails
              : BlenderFileDisplayMode.listVertical,
        );
    final content = searchController == null
        ? _buildFilteredContent(
            context,
            entries,
            theme,
            '',
            resolvedHeaderState.displayMode,
          )
        : ValueListenableBuilder<TextEditingValue>(
            valueListenable: searchController!,
            builder: (context, value, child) => _buildFilteredContent(
              context,
              entries,
              theme,
              value.text.trim().toLowerCase(),
              resolvedHeaderState.displayMode,
            ),
          );
    final main = Column(
      children: <Widget>[
        if (!assetBrowser && pathController != null)
          BlenderFileBrowserPathBar(
            pathController: pathController!,
            searchController: searchController,
            onBack: onBack,
            onForward: onForward,
            onParent: onParent,
            onRefresh: onRefresh,
            onNewFolder: onNewFolder,
          ),
        Expanded(child: content),
      ],
    );
    final body = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (resolvedHeaderState.showSourceList && sourceList != null)
          sourceList!,
        Expanded(child: main),
        if (sidebar != null)
          SizedBox(
            width: sidebarWidth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.surface,
                border: Border(
                  left: BorderSide(color: theme.colors.editorBorder),
                ),
              ),
              child: sidebar,
            ),
          ),
      ],
    );
    final browser = Column(
      children: <Widget>[
        if (showHeader)
          BlenderFileBrowserHeader(
            state: resolvedHeaderState,
            mode: assetBrowser
                ? BlenderFileBrowserMode.assets
                : BlenderFileBrowserMode.files,
            searchController: assetBrowser ? searchController : null,
            onStateChanged: (value) {
              onHeaderStateChanged?.call(value);
              onGridViewChanged?.call(
                value.displayMode == BlenderFileDisplayMode.thumbnails,
              );
            },
            onCommand: onCommand,
          ),
        Expanded(child: body),
      ],
    );
    if (title == null) return browser;
    return BlenderPanel(title: title!, child: browser);
  }

  Widget _buildFilteredContent(
    BuildContext context,
    List<BlenderFileEntry> source,
    BlenderThemeData theme,
    String query,
    BlenderFileDisplayMode displayMode,
  ) {
    final filtered = source
        .where((entry) {
          final catalogMatches =
              catalogId == null ||
              catalogId == '__all__' ||
              (catalogId == '__unassigned__'
                  ? entry.catalogId == null
                  : entry.catalogId == catalogId);
          if (!catalogMatches) return false;
          return query.isEmpty ||
              entry.name.toLowerCase().contains(query) ||
              entry.path.toLowerCase().contains(query) ||
              (entry.detail?.toLowerCase().contains(query) ?? false);
        })
        .toList(growable: false);
    final visible = filtered.toList(growable: false)..sort(_compareEntries);
    return Column(
      children: <Widget>[
        if (pathController == null && pathSegments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 2),
            child: BlenderBreadcrumbs(
              items: pathSegments,
              onSelected: onPathSelected,
            ),
          ),
        if (pathController == null && searchController != null && !assetBrowser)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 4),
            child: BlenderFilterBar(
              controller: searchController!,
              placeholder: 'Search files',
            ),
          ),
        if (displayMode == BlenderFileDisplayMode.thumbnails)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 140,
                mainAxisExtent: 72,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: visible.length,
              itemBuilder: (context, index) =>
                  _buildGridEntry(context, visible[index]),
            ),
          )
        else
          Expanded(
            child: Column(
              children: <Widget>[
                if (showListColumns) _buildListHeader(context),
                Expanded(
                  child: ListView.builder(
                    itemExtent: theme.density.rowHeight,
                    itemCount: visible.length,
                    itemBuilder: (context, index) =>
                        _buildListEntry(context, visible[index]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildListEntry(BuildContext context, BlenderFileEntry entry) {
    final theme = BlenderTheme.of(context);
    Widget cell(String? value, int flex) => Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          value ?? '',
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.body,
        ),
      ),
    );
    Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelected?.call(entry),
      onDoubleTap: () => onOpen?.call(entry),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selectedPath == entry.path
              ? theme.colors.selection
              : const Color(0x00000000),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: <Widget>[
                    BlenderIcon(
                      entry.isDirectory
                          ? BlenderGlyph.folder
                          : BlenderGlyph.file,
                      size: 16,
                      color: entry.isDirectory
                          ? theme.colors.iconFolder
                          : theme.colors.foregroundMuted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(entry.name, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),
            cell(entry.modifiedLabel, 3),
            cell(entry.sizeLabel, 2),
            cell(entry.typeLabel, 2),
          ],
        ),
      ),
    );
    final items = contextMenuItemsBuilder?.call(entry);
    if (items != null && items.isNotEmpty) {
      row = BlenderContextMenu<String>(
        title: entry.name,
        items: items,
        onContextRequested: (_) => onSelected?.call(entry),
        onSelected: (action) => onContextMenuSelected?.call(entry, action),
        child: row,
      );
    }
    return row;
  }

  int _compareEntries(BlenderFileEntry a, BlenderFileEntry b) {
    if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
    final result = switch (sortColumn) {
      BlenderFileBrowserSortColumn.name => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
      BlenderFileBrowserSortColumn.modified =>
        (a.modified ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
          b.modified ?? DateTime.fromMillisecondsSinceEpoch(0),
        ),
      BlenderFileBrowserSortColumn.size => (a.sizeBytes ?? 0).compareTo(
        b.sizeBytes ?? 0,
      ),
      BlenderFileBrowserSortColumn.type =>
        (a.typeLabel ?? '').toLowerCase().compareTo(
          (b.typeLabel ?? '').toLowerCase(),
        ),
    };
    return sortDirection == BlenderFileBrowserSortDirection.ascending
        ? result
        : -result;
  }

  void _requestSort(BlenderFileBrowserSortColumn column) {
    final direction =
        column == sortColumn &&
            sortDirection == BlenderFileBrowserSortDirection.ascending
        ? BlenderFileBrowserSortDirection.descending
        : BlenderFileBrowserSortDirection.ascending;
    onSortChanged?.call(column, direction);
  }

  Widget _buildListHeader(BuildContext context) {
    final theme = BlenderTheme.of(context);
    Widget column(
      BlenderFileBrowserSortColumn value,
      String label,
      double flex,
    ) {
      final active = sortColumn == value;
      return Expanded(
        flex: flex.round(),
        child: BlenderButton(
          label: label,
          variant: BlenderButtonVariant.toolbar,
          onPressed: onSortChanged == null ? null : () => _requestSort(value),
          trailing: active
              ? BlenderIcon(
                  sortDirection == BlenderFileBrowserSortDirection.ascending
                      ? BlenderGlyph.chevronUp
                      : BlenderGlyph.chevronDown,
                  size: 11,
                )
              : null,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.panelHeader,
        border: Border(bottom: BorderSide(color: theme.colors.editorBorder)),
      ),
      child: SizedBox(
        height: theme.density.rowHeight,
        child: Row(
          children: <Widget>[
            column(BlenderFileBrowserSortColumn.name, 'Name', 5),
            column(BlenderFileBrowserSortColumn.modified, 'Date Modified', 3),
            column(BlenderFileBrowserSortColumn.size, 'Size', 2),
            column(BlenderFileBrowserSortColumn.type, 'Type', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildGridEntry(BuildContext context, BlenderFileEntry entry) {
    final theme = BlenderTheme.of(context);
    final selected = entry.path == selectedPath;
    Widget tile = GestureDetector(
      onTap: () => onSelected?.call(entry),
      onDoubleTap: () => onOpen?.call(entry),
      child: BlenderPreviewTile(
        label: entry.name,
        selected: selected,
        width: double.infinity,
        height: double.infinity,
        preview:
            entry.preview ??
            previewBuilder?.call(context, entry) ??
            Center(
              child: BlenderIcon(
                entry.isDirectory ? BlenderGlyph.folder : BlenderGlyph.file,
                color: entry.isDirectory
                    ? theme.colors.iconFolder
                    : theme.colors.foregroundMuted,
              ),
            ),
      ),
    );
    final contextItems = contextMenuItemsBuilder?.call(entry);
    if (contextItems != null && contextItems.isNotEmpty) {
      tile = BlenderContextMenu<String>(
        title: entry.name,
        items: contextItems,
        onContextRequested: (_) => onSelected?.call(entry),
        onSelected: (action) => onContextMenuSelected?.call(entry, action),
        child: tile,
      );
    }
    return tile;
  }
}

/// Source-shaped File Browser and Asset Browser side panels.
///
/// Blender owns the region visibility, file operations, asset metadata, and
/// catalog mutation. This widget only provides the visual panel anatomy so a
/// host can supply those behaviors separately.
class BlenderFileBrowserSidebar extends StatelessWidget {
  const BlenderFileBrowserSidebar({
    super.key,
    this.assetBrowser = false,
    this.assetCatalog,
  });

  final bool assetBrowser;
  final Widget? assetCatalog;

  Widget _actions(List<String> labels) => Wrap(
    spacing: 4,
    runSpacing: 4,
    children: <Widget>[
      for (final label in labels) BlenderButton(label: label, onPressed: () {}),
    ],
  );

  Widget _list(List<String> labels) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      for (final label in labels)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(
            children: <Widget>[
              const BlenderIcon(BlenderGlyph.folder, size: 14),
              const SizedBox(width: 5),
              Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final panels = assetBrowser
        ? <Widget>[
            BlenderStaticPropertyField.panel('Library', <Widget>[
              BlenderStaticPropertyField.menu('Access', 'All', <String>[
                'All',
                'Local',
                'Remote',
              ]),
              _actions(<String>['Refresh', 'Reload Listing']),
            ], expanded: true),
            if (assetCatalog != null)
              SizedBox(height: 300, child: assetCatalog)
            else
              BlenderStaticPropertyField.panel('Catalog', <Widget>[
                _actions(<String>['Undo', 'Redo', 'Save', 'New']),
              ]),
            BlenderStaticPropertyField.panel('Asset', <Widget>[
              _actions(<String>['Clear Asset', 'Open Containing File']),
            ]),
            BlenderStaticPropertyField.panel('Asset Metadata', <Widget>[
              BlenderPropertyRow(
                label: 'Name',
                editor: BlenderTextField(
                  controller: TextEditingController(text: 'Showcase Asset'),
                  readOnly: true,
                ),
              ),
              BlenderPropertyRow(
                label: 'Description',
                editor: BlenderTextField(
                  controller: TextEditingController(
                    text: 'Source-shaped asset',
                  ),
                  readOnly: true,
                ),
              ),
              BlenderStaticPropertyField.menu('License', 'CC0', <String>[
                'CC0',
                'GPL',
                'Unknown',
              ]),
              BlenderStaticPropertyField.menu('Author', 'Blender UI', <String>[
                'Blender UI',
                'Unknown',
              ]),
            ], expanded: true),
            BlenderStaticPropertyField.panel('Import', <Widget>[
              BlenderStaticPropertyField.checkbox('Use Preferred Method'),
              BlenderStaticPropertyField.menu(
                'Preferred Method',
                'Link',
                <String>['Link', 'Append'],
              ),
            ]),
            BlenderStaticPropertyField.panel('Preview', <Widget>[
              const SizedBox(
                height: 70,
                child: Center(child: BlenderIcon(BlenderGlyph.image, size: 32)),
              ),
              _actions(<String>['Load', 'Generate', 'Remove']),
            ]),
            BlenderStaticPropertyField.panel('Tags', <Widget>[
              _list(<String>['Environment', 'Asset']),
              _actions(<String>['Add', 'Remove']),
            ]),
          ]
        : <Widget>[
            BlenderStaticPropertyField.panel('Directory Path', <Widget>[
              _actions(<String>['Back', 'Forward', 'Parent', 'Refresh']),
              BlenderTextField(
                controller: TextEditingController(text: '/showcase/assets'),
                readOnly: true,
              ),
              _actions(<String>['New Folder']),
            ], expanded: true),
            BlenderStaticPropertyField.panel('Volumes', <Widget>[
              _list(<String>['Home', 'Documents']),
            ], expanded: true),
            BlenderStaticPropertyField.panel('System', <Widget>[
              _list(<String>['Desktop', 'Downloads']),
            ]),
            BlenderStaticPropertyField.panel('Bookmarks', <Widget>[
              _list(<String>['Showcase', 'Assets']),
              _actions(<String>['Add', 'Remove', 'Move']),
            ]),
            BlenderStaticPropertyField.panel('Recent', <Widget>[
              _list(<String>['scene.blend', 'assets']),
              _actions(<String>['Clear']),
            ]),
            BlenderStaticPropertyField.panel('Advanced Filter', <Widget>[
              BlenderStaticPropertyField.checkbox('Blender Files Only'),
              BlenderStaticPropertyField.checkbox('Asset Data', value: false),
              BlenderStaticPropertyField.checkbox('Fonts', value: false),
              BlenderStaticPropertyField.checkbox('Images', value: false),
              BlenderStaticPropertyField.checkbox('Movies', value: false),
            ]),
          ];
    return ListView(padding: const EdgeInsets.all(4), children: panels);
  }
}
