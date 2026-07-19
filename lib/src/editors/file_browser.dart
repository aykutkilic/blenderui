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
    this.onBack,
    this.onForward,
    this.onParent,
    this.onRefresh,
    this.onNewFolder,
    this.sidebar,
    this.sidebarWidth = 220,
    this.assetBrowser = false,
    this.title = 'File Browser',
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
  final VoidCallback? onBack;
  final VoidCallback? onForward;
  final VoidCallback? onParent;
  final VoidCallback? onRefresh;
  final VoidCallback? onNewFolder;
  final Widget? sidebar;
  final double sidebarWidth;
  final bool assetBrowser;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final content = searchController == null
        ? _buildFilteredContent(context, entries, theme, '')
        : ValueListenableBuilder<TextEditingValue>(
            valueListenable: searchController!,
            builder: (context, value, child) => _buildFilteredContent(
              context,
              entries,
              theme,
              value.text.trim().toLowerCase(),
            ),
          );
    return BlenderPanel(
      title: title,
      headerActions: <Widget>[
        _headerAction(BlenderGlyph.stepBack, 'Back', onBack),
        _headerAction(BlenderGlyph.stepForward, 'Forward', onForward),
        _headerAction(BlenderGlyph.folder, 'Parent Directory', onParent),
        _headerAction(BlenderGlyph.refresh, 'Refresh', onRefresh),
        _headerAction(BlenderGlyph.plus, 'New Folder', onNewFolder),
        _BlenderFileBrowserPopover(assetBrowser: assetBrowser, filter: false),
        _BlenderFileBrowserPopover(assetBrowser: assetBrowser, filter: true),
        if (onGridViewChanged != null) ...<Widget>[
          BlenderIconButton(
            glyph: BlenderGlyph.outliner,
            selected: !gridView,
            onPressed: () => onGridViewChanged!(false),
            tooltip: 'List view',
            size: 22,
          ),
          BlenderIconButton(
            glyph: BlenderGlyph.grid,
            selected: gridView,
            onPressed: () => onGridViewChanged!(true),
            tooltip: 'Grid view',
            size: 22,
          ),
        ],
      ],
      child: sidebar == null
          ? content
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: content),
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
            ),
    );
  }

  Widget _headerAction(
    BlenderGlyph glyph,
    String tooltip,
    VoidCallback? callback,
  ) {
    return BlenderIconButton(
      glyph: glyph,
      tooltip: tooltip,
      onPressed: callback ?? () {},
      size: 22,
    );
  }

  Widget _buildFilteredContent(
    BuildContext context,
    List<BlenderFileEntry> source,
    BlenderThemeData theme,
    String query,
  ) {
    final visible = query.isEmpty
        ? source
        : source
              .where(
                (entry) =>
                    entry.name.toLowerCase().contains(query) ||
                    entry.path.toLowerCase().contains(query) ||
                    (entry.detail?.toLowerCase().contains(query) ?? false),
              )
              .toList(growable: false);
    return Column(
      children: <Widget>[
        if (pathSegments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 2),
            child: BlenderBreadcrumbs(
              items: pathSegments,
              onSelected: onPathSelected,
            ),
          ),
        if (searchController != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 4),
            child: BlenderFilterBar(
              controller: searchController!,
              placeholder: 'Search files',
            ),
          ),
        if (gridView)
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
            child: BlenderListView<BlenderFileEntry>(
              items: [
                for (final entry in visible)
                  BlenderListItem<BlenderFileEntry>(
                    id: entry.path,
                    value: entry,
                    label: entry.name,
                    detail: entry.detail,
                    icon: entry.isDirectory
                        ? BlenderGlyph.folder
                        : BlenderGlyph.file,
                    iconColor: entry.isDirectory
                        ? theme.colors.iconFolder
                        : theme.colors.foregroundMuted,
                  ),
              ],
              selectedId: selectedPath,
              onSelected: onSelected == null
                  ? null
                  : (item) => onSelected!(item.value!),
              onActivated: onOpen == null
                  ? null
                  : (item) => onOpen!(item.value!),
              contextMenuTitleBuilder: (item) => item.label,
              contextMenuItemsBuilder: contextMenuItemsBuilder == null
                  ? null
                  : (item) => contextMenuItemsBuilder!(item.value!),
              onContextMenuSelected: onContextMenuSelected == null
                  ? null
                  : (item, action) =>
                        onContextMenuSelected!(item.value!, action),
            ),
          ),
      ],
    );
  }

  Widget _buildGridEntry(BuildContext context, BlenderFileEntry entry) {
    final theme = BlenderTheme.of(context);
    final selected = entry.path == selectedPath;
    Widget tile = GestureDetector(
      onTap: () => onSelected?.call(entry),
      onDoubleTap: () => onOpen?.call(entry),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? theme.colors.selection : theme.colors.surface,
          border: Border.all(color: theme.colors.editorBorder),
          borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BlenderIcon(
              entry.isDirectory ? BlenderGlyph.folder : BlenderGlyph.file,
              color: entry.isDirectory
                  ? theme.colors.iconFolder
                  : theme.colors.foregroundMuted,
            ),
            const SizedBox(height: 3),
            Text(entry.name, overflow: TextOverflow.ellipsis),
          ],
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

/// Source-shaped File Browser and Asset Browser header popovers from
/// `space_filebrowser.py`.
class _BlenderFileBrowserPopover extends StatelessWidget {
  const _BlenderFileBrowserPopover({
    required this.assetBrowser,
    required this.filter,
  });

  final bool assetBrowser;
  final bool filter;

  List<Widget> _displayChildren() {
    if (assetBrowser) {
      return <Widget>[
        BlenderStaticPropertyField.menu('Display Type', 'Thumbnail', <String>[
          'Thumbnail',
          'List Horizontal',
          'List Vertical',
        ]),
        BlenderStaticPropertyField.menu('Preview Size', 'Medium', <String>[
          'Small',
          'Medium',
          'Large',
        ]),
        BlenderStaticPropertyField.menu('Sort By', 'Name', <String>[
          'Name',
          'Asset Type',
          'Modified',
        ]),
      ];
    }
    return <Widget>[
      BlenderStaticPropertyField.menu('Display Type', 'List Vertical', <String>[
        'List Vertical',
        'List Horizontal',
        'Thumbnail',
      ]),
      BlenderStaticPropertyField.menu('Size', 'Medium', <String>[
        'Small',
        'Medium',
        'Large',
      ]),
      BlenderStaticPropertyField.checkbox('Date', value: false),
      BlenderStaticPropertyField.menu('Recursions', 'None', <String>[
        'None',
        'One Level',
        'All',
      ]),
      BlenderStaticPropertyField.menu('Sort By', 'Name', <String>[
        'Name',
        'Modified',
        'Size',
        'Type',
      ]),
      BlenderStaticPropertyField.checkbox('Invert Sort', value: false),
    ];
  }

  List<Widget> _filterChildren() {
    if (assetBrowser) {
      return <Widget>[
        BlenderStaticPropertyField.checkbox('Blender IDs'),
        BlenderStaticPropertyField.checkbox('Objects'),
        BlenderStaticPropertyField.checkbox('Materials'),
        BlenderStaticPropertyField.checkbox('Collections'),
        BlenderStaticPropertyField.checkbox('Worlds', value: false),
        BlenderStaticPropertyField.menu('Access', 'All', <String>[
          'All',
          'Local',
          'Remote',
        ]),
      ];
    }
    return <Widget>[
      BlenderStaticPropertyField.checkbox('Folders'),
      BlenderStaticPropertyField.checkbox('.blend Files'),
      BlenderStaticPropertyField.checkbox('Backup .blend Files', value: false),
      BlenderStaticPropertyField.checkbox('Image Files'),
      BlenderStaticPropertyField.checkbox('Movie Files', value: false),
      BlenderStaticPropertyField.checkbox('Script Files', value: false),
      BlenderStaticPropertyField.checkbox('Font Files', value: false),
      BlenderStaticPropertyField.checkbox('Sound Files', value: false),
      BlenderStaticPropertyField.checkbox('Text Files', value: false),
      BlenderStaticPropertyField.checkbox('Volume Files', value: false),
      BlenderStaticPropertyField.checkbox('Show Hidden', value: false),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final title = filter
        ? (assetBrowser ? 'Filter' : 'Filter Settings')
        : (assetBrowser ? 'Display Settings' : 'Display Settings');
    return BlenderPopover(
      child: BlenderIconButton(
        glyph: filter ? BlenderGlyph.filter : BlenderGlyph.settings,
        tooltip: title,
        size: 22,
      ),
      popover: (context, close) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 330, maxHeight: 620),
        child: SingleChildScrollView(
          child: BlenderPanel(
            title: title,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: filter ? _filterChildren() : _displayChildren(),
            ),
          ),
        ),
      ),
    );
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
