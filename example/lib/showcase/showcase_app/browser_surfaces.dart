part of '../showcase_app.dart';

extension _ShowcaseBrowserSurfaces on _ShowcaseAppState {
  Widget _buildFileBrowserSurface() => BlenderFileBrowser(
    title: null,
    entries: const <BlenderFileEntry>[
      BlenderFileEntry(
        path: '/ACE_Studio',
        name: 'ACE_Studio',
        isDirectory: true,
        modifiedLabel: '16 Mar 2026 11:01',
        typeLabel: 'Folder',
      ),
      BlenderFileEntry(
        path: '/AndroidStudioProjects',
        name: 'AndroidStudioProjects',
        isDirectory: true,
        modifiedLabel: '17 Mar 2025 06:55',
        typeLabel: 'Folder',
      ),
      BlenderFileEntry(
        path: '/Applications',
        name: 'Applications',
        isDirectory: true,
        modifiedLabel: '09 Jun 2026 12:32',
        typeLabel: 'Folder',
      ),
      BlenderFileEntry(
        path: '/Desktop',
        name: 'Desktop',
        isDirectory: true,
        modifiedLabel: '18 Jul 2026 15:07',
        typeLabel: 'Folder',
      ),
      BlenderFileEntry(
        path: '/Documents',
        name: 'Documents',
        isDirectory: true,
        modifiedLabel: '22 Jun 2026 19:18',
        typeLabel: 'Folder',
      ),
      BlenderFileEntry(
        path: '/Downloads',
        name: 'Downloads',
        isDirectory: true,
        modifiedLabel: 'Yesterday 19:05',
        typeLabel: 'Folder',
      ),
      BlenderFileEntry(
        path: '/git',
        name: 'git',
        isDirectory: true,
        modifiedLabel: '14 Jul 2026 13:39',
        typeLabel: 'Folder',
      ),
      BlenderFileEntry(
        path: '/scene.blend',
        name: 'scene.blend',
        modifiedLabel: 'Today 10:24',
        sizeLabel: '2.4 MB',
        typeLabel: 'Blender',
      ),
    ],
    searchController: _fileSearchController,
    pathController: _filePathController,
    headerState: _fileBrowserHeaderState,
    onHeaderStateChanged: (value) =>
        _update(() => _fileBrowserHeaderState = value),
    onCommand: _setStatus,
    sourceList: BlenderFileBrowserSourceList(
      selectedId: _selectedFileSource,
      onSelected: (entry) => _update(() {
        _selectedFileSource = entry.id;
        _filePathController.text = entry.id == 'home'
            ? '/Users/aykutkilic/'
            : '/Users/aykutkilic/${entry.label}/';
      }),
      onAdd: (section) => _setStatus('Add ${section.label}'),
      sections: const <BlenderFileSourceSection>[
        BlenderFileSourceSection(
          id: 'bookmarks',
          label: 'Bookmarks',
          allowAdd: true,
          entries: <BlenderFileSourceEntry>[],
        ),
        BlenderFileSourceSection(
          id: 'system',
          label: 'System',
          entries: <BlenderFileSourceEntry>[
            BlenderFileSourceEntry(id: 'applications', label: 'Applications'),
            BlenderFileSourceEntry(id: 'desktop', label: 'Desktop'),
            BlenderFileSourceEntry(
              id: 'documents',
              label: 'Documents',
              icon: BlenderGlyph.file,
            ),
            BlenderFileSourceEntry(
              id: 'downloads',
              label: 'Downloads',
              icon: BlenderGlyph.open,
            ),
            BlenderFileSourceEntry(id: 'git', label: 'git'),
          ],
        ),
        BlenderFileSourceSection(
          id: 'volumes',
          label: 'Volumes',
          entries: <BlenderFileSourceEntry>[
            BlenderFileSourceEntry(
              id: 'icloud',
              label: 'iCloud Drive',
              icon: BlenderGlyph.link,
            ),
            BlenderFileSourceEntry(
              id: 'home',
              label: 'Macintosh HD',
              icon: BlenderGlyph.diskDrive,
            ),
          ],
        ),
      ],
    ),
    onBack: () => _setStatus('Back'),
    onForward: () => _setStatus('Forward'),
    onParent: () => _setStatus('Parent directory'),
    onRefresh: () => _setStatus('Refreshed'),
    onNewFolder: () => _setStatus('New folder'),
    selectedPath: _selectedFile,
    gridView: _fileGrid,
    onGridViewChanged: (value) => _update(() => _fileGrid = value),
    onSelected: (entry) => _update(() => _selectedFile = entry.path),
    onOpen: (entry) => _setStatus('Opened ${entry.name}'),
    contextMenuItemsBuilder: (_) => BlenderContextMenuCatalog.fileBrowser(),
    onContextMenuSelected: (entry, action) =>
        _setStatus('$action: ${entry.name}'),
  );

  Widget _buildAssetBrowserSurface() => BlenderFileBrowser(
    title: null,
    entries: const <BlenderFileEntry>[
      BlenderFileEntry(
        path: '/assets/chromatic',
        name: 'Chromatic Aberration',
        asset: true,
        catalogId: 'camera',
        typeLabel: 'Node Group',
        preview: ColoredBox(color: Color(0xFF8094A8)),
      ),
      BlenderFileEntry(
        path: '/assets/noise',
        name: 'Sensor Noise',
        asset: true,
        catalogId: 'camera',
        typeLabel: 'Node Group',
        preview: ColoredBox(color: Color(0xFF8D7279)),
      ),
      BlenderFileEntry(
        path: '/assets/vignette',
        name: 'Vignette',
        asset: true,
        catalogId: 'camera',
        typeLabel: 'Node Group',
        preview: ColoredBox(color: Color(0xFF20202B)),
      ),
    ],
    searchController: _fileSearchController,
    headerState: _assetBrowserHeaderState,
    onHeaderStateChanged: (value) =>
        _update(() => _assetBrowserHeaderState = value),
    onCommand: _setStatus,
    sourceList: BlenderAssetBrowserCatalogRegion(
      selectedCatalogId: _selectedAssetCatalog,
      onCatalogSelected: (value) =>
          _update(() => _selectedAssetCatalog = value),
      onLibraryChanged: (value) => _setStatus('Library: $value'),
      onRefresh: () => _setStatus('Refresh asset library'),
      catalogs: const <BlenderAssetCatalog>[
        BlenderAssetCatalog(id: 'brushes', label: 'Brushes'),
        BlenderAssetCatalog(id: 'camera', label: 'Camera & Lens Effects'),
        BlenderAssetCatalog(id: 'creative', label: 'Creative'),
        BlenderAssetCatalog(id: 'generate', label: 'Generate'),
        BlenderAssetCatalog(id: 'geometry', label: 'Geometry'),
        BlenderAssetCatalog(id: 'hair', label: 'Hair'),
        BlenderAssetCatalog(id: 'mesh', label: 'Mesh'),
        BlenderAssetCatalog(id: 'utilities', label: 'Utilities'),
      ],
    ),
    assetBrowser: true,
    catalogId: _selectedAssetCatalog,
    selectedPath: _selectedFile,
    gridView: true,
    onSelected: (entry) => _update(() => _selectedFile = entry.path),
    onOpen: (entry) => _setStatus('Opened ${entry.name}'),
    contextMenuItemsBuilder: (_) => BlenderContextMenuCatalog.fileBrowser(),
    onContextMenuSelected: (entry, action) =>
        _setStatus('$action asset: ${entry.name}'),
  );
}
