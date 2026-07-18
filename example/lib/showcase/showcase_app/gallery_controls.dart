part of '../showcase_app.dart';

extension _ShowcaseGalleryControls on _ShowcaseAppState {
  Widget _buildControlGallery() {
    return BlenderPanel(
      title: 'UI Catalog',
      padding: EdgeInsets.zero,
      child: BlenderScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ..._buildControlGalleryCoreControls(),
              ..._buildControlGallerySearchPreview(),
              ..._buildControlGalleryFbxImporter(),
              ..._buildControlGalleryKeymapItemProperties(),
              ..._buildControlGallerySurface(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildControlGalleryCoreControls() => <Widget>[
    Text('Core controls', style: BlenderTheme.of(context).textTheme.heading),
    const SizedBox(height: 6),
    BlenderFlow(
      children: <Widget>[
        for (final variant in BlenderButtonVariant.values)
          BlenderButton(
            label: variant.name,
            variant: variant,
            onPressed: () => _setStatus('${variant.name} pressed'),
          ),
        BlenderIconButton(
          glyph: BlenderGlyph.settings,
          onPressed: () => _setStatus('Icon pressed'),
          tooltip: 'Catalog icon button',
        ),
        BlenderButton(label: 'Alert dialog', onPressed: _showCatalogAlert),
        BlenderButton(
          label: 'Property dialog',
          onPressed: _showCatalogPropertyDialog,
        ),
        BlenderOperatorRedoPopup(
          title: 'Set Frame Range',
          properties: <BlenderPropertyDescriptor<dynamic>>[
            BlenderPropertyDescriptor<double>(
              id: 'start',
              label: 'Start',
              value: _frameStart,
              editorBuilder: (context, value, onChanged) => BlenderNumberField(
                value: value,
                min: 1,
                max: 10000,
                decimalDigits: 0,
                onChanged: onChanged,
              ),
              onChanged: (value) => _update(() => _frameStart = value),
            ),
            BlenderPropertyDescriptor<bool>(
              id: 'preview',
              label: 'Preview Range',
              value: _renderRegion,
              editorBuilder: (context, value, onChanged) => BlenderCheckbox(
                value: value,
                label: '',
                onChanged: onChanged,
              ),
              onChanged: (value) => _update(() => _renderRegion = value),
            ),
          ],
        ),
        BlenderCheckbox(
          value: _useSmoothShading,
          label: 'Checkbox',
          onChanged: (value) => _update(() => _useSmoothShading = value),
        ),
        BlenderToggle(
          value: _galleryToggle,
          label: 'Toggle',
          onChanged: (value) => _update(() => _galleryToggle = value),
        ),
        BlenderRadio<String>(
          value: 'Regular',
          groupValue: _galleryMode,
          label: 'Radio',
          onChanged: (value) => _update(() => _galleryMode = value),
        ),
      ],
    ),
    const SizedBox(height: 8),
    Row(
      children: <Widget>[
        Expanded(
          child: BlenderSlider(
            value: _gallerySlider,
            onChanged: (value) => _update(() => _gallerySlider = value),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: BlenderNumberField(
            value: _gallerySlider,
            min: 0,
            max: 1,
            step: .01,
            onChanged: (value) => _update(() => _gallerySlider = value),
          ),
        ),
      ],
    ),
    const SizedBox(height: 8),
    Text('Templates', style: BlenderTheme.of(context).textTheme.heading),
    const SizedBox(height: 6),
    BlenderVectorField(
      values: <double>[_locationX, _locationY, _gallerySlider],
      onChanged: (values) => _update(() {
        _locationX = values[0];
        _locationY = values[1];
        _gallerySlider = values[2];
      }),
    ),
    const SizedBox(height: 6),
    BlenderMatrixField(
      values: _galleryMatrix,
      rowLabels: const <String>['X', 'Y', 'Z'],
      columnLabels: const <String>['X', 'Y', 'Z'],
      onChanged: (values) => _update(() => _galleryMatrix = values),
    ),
    const SizedBox(height: 6),
    BlenderMatrixTransformPanel(
      values: const BlenderMatrixTransformValues(
        location: <double>[1.25, -0.5, 3],
        rotation: <double>[0, 45, 90],
        scale: <double>[1, 1, 1],
        hasShear: true,
      ),
      onRotationModeChanged: (mode) => _setStatus('Rotation mode: $mode'),
    ),
    const SizedBox(height: 6),
    BlenderAttributeSearch<String>(
      value: _galleryAttribute,
      options: const <BlenderAttributeOption<String>>[
        BlenderAttributeOption<String>(
          name: 'position',
          value: 'position',
          domain: 'Point',
          dataType: 'Float3',
        ),
        BlenderAttributeOption<String>(
          name: 'uv_map',
          value: 'uv_map',
          domain: 'Corner',
          dataType: 'Float2',
        ),
        BlenderAttributeOption<String>(
          name: 'material_index',
          value: 'material_index',
          domain: 'Face',
          dataType: 'Int',
        ),
      ],
      onChanged: (value) => _update(() => _galleryAttribute = value),
      onCreate: (value) => _update(() => _galleryAttribute = value),
      onClear: () => _update(() => _galleryAttribute = null),
    ),
    const SizedBox(height: 6),
    BlenderLayerSelector(
      layers: [
        for (var index = 1; index <= 8; index++)
          BlenderLayerItem(
            id: '$index',
            label: '$index',
            active: _galleryLayers.contains('$index'),
            used: index == 2 || index == 5,
          ),
      ],
      onChanged: (value) => _update(() => _galleryLayers = value.toSet()),
    ),
    const SizedBox(height: 6),
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: BlenderUnitVector(
            value: _galleryVector,
            onChanged: (value) => _update(() => _galleryVector = value),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: BlenderPathField(
            controller: _galleryPathController,
            onBrowse: () => _setStatus('Browse path'),
            placeholder: 'File name',
          ),
        ),
        const SizedBox(width: 8),
        const BlenderPreviewTile(label: 'Preview'),
      ],
    ),
    const SizedBox(height: 6),
    BlenderPreviewPanel(
      preview: const ColoredBox(
        color: Color(0xFF202020),
        child: Center(child: BlenderIcon(BlenderGlyph.material, size: 56)),
      ),
      previewModes: const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Material', label: 'Material'),
        BlenderMenuItem<String>(value: 'World', label: 'World'),
      ],
      previewMode: 'Material',
      onPreviewModeChanged: (value) => _setStatus('Preview mode: $value'),
      usePreviewWorld: true,
      onUsePreviewWorldChanged: (value) => _setStatus('Preview world: $value'),
      textureModes: const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Texture', label: 'Texture'),
        BlenderMenuItem<String>(value: 'Material', label: 'Material'),
        BlenderMenuItem<String>(value: 'Both', label: 'Both'),
      ],
      textureMode: 'Both',
      onTextureModeChanged: (value) => _setStatus('Texture mode: $value'),
      usePreviewAlpha: true,
      onUsePreviewAlphaChanged: (value) => _setStatus('Preview alpha: $value'),
    ),
    const SizedBox(height: 8),
  ];

  List<Widget> _buildControlGallerySearchPreview() => <Widget>[
    SizedBox(
      height: 220,
      child: BlenderSearchMenu<String>(
        controller: _operatorSearchController,
        title: 'Search Preview',
        previewRows: 2,
        previewColumns: 4,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'cube',
            label: 'Cube',
            icon: BlenderIcon(BlenderGlyph.cube, size: 30),
          ),
          BlenderMenuItem<String>(
            value: 'sphere',
            label: 'Sphere',
            icon: BlenderIcon(BlenderGlyph.object, size: 30),
          ),
          BlenderMenuItem<String>(
            value: 'material',
            label: 'Material',
            icon: BlenderIcon(BlenderGlyph.material, size: 30),
          ),
          BlenderMenuItem<String>(
            value: 'world',
            label: 'World',
            icon: BlenderIcon(BlenderGlyph.world, size: 30),
          ),
        ],
        onSelected: (item) => _setStatus('Search: ${item.label}'),
      ),
    ),
    const SizedBox(height: 8),
    BlenderFileOperatorPanel(
      operatorName: 'Open Blender File',
      properties: <BlenderPropertyDescriptor<dynamic>>[
        BlenderPropertyDescriptor<bool>(
          id: 'relative-path',
          label: 'Relative Path',
          value: true,
          editorBuilder: (context, value, onChanged) =>
              BlenderCheckbox(value: value, label: '', onChanged: onChanged),
          onChanged: (value) => _setStatus('Relative path: $value'),
        ),
        BlenderPropertyDescriptor<String>(
          id: 'display',
          label: 'Display',
          value: 'Thumbnails',
          editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
            value: value,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Thumbnails', label: 'Thumbnails'),
              BlenderMenuItem<String>(value: 'List', label: 'List'),
            ],
            onChanged: onChanged,
          ),
          onChanged: (value) => _setStatus('Display: $value'),
        ),
      ],
    ),
    const SizedBox(height: 8),
    BlenderFileExecutionPanel(
      filenameController: _galleryPathController,
      overwriteAlert: true,
      onDecrement: () => _setStatus('Previous filename'),
      onIncrement: () => _setStatus('Next filename'),
      onCancel: () => _setStatus('File operation canceled'),
      onExecute: () => _setStatus('Overwrite file'),
    ),
    const SizedBox(height: 8),
    SizedBox(
      height: 270,
      child: BlenderFileBrowserHint(
        title: 'Internet Access Required',
        icon: BlenderGlyph.internetOffline,
        message:
            'Allow Online Access in order to browse and download online assets, or turn off the "Remote Assets" filter to show only the downloaded assets.\n\nYou can adjust this later from the "System" preferences.',
        actions: <BlenderFileBrowserHintAction>[
          BlenderFileBrowserHintAction(
            label: 'Continue Offline',
            icon: BlenderGlyph.close,
            onPressed: () => _setStatus('Continue offline'),
          ),
          BlenderFileBrowserHintAction(
            label: 'Allow Online Access',
            icon: BlenderGlyph.check,
            onPressed: () => _setStatus('Allow online access'),
          ),
        ],
      ),
    ),
    const SizedBox(height: 8),
    const SizedBox(
      height: 180,
      child: BlenderFileBrowserUnreadableLibraryHint(
        path: '/showcase/library.blend',
        reports: const <BlenderFileBrowserReport>[
          BlenderFileBrowserReport(
            message: 'File is not a valid Blender library.',
            level: BlenderNoticeLevel.error,
          ),
          BlenderFileBrowserReport(
            message: 'The file may be incomplete or corrupted.',
          ),
        ],
      ),
    ),
    const SizedBox(height: 8),
    SizedBox(
      height: 250,
      child: BlenderFileAssetCatalogPanel(
        libraryValue: 'Local',
        libraryItems: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Local', label: 'Local'),
          BlenderMenuItem<String>(value: 'Essentials', label: 'Essentials'),
        ],
        catalogRoots: const <BlenderTreeNode<String>>[
          BlenderTreeNode<String>(
            id: 'environment',
            label: 'Environment',
            icon: BlenderGlyph.collection,
            initiallyExpanded: true,
            children: <BlenderTreeNode<String>>[
              BlenderTreeNode<String>(
                id: 'studio',
                label: 'Studio Lighting',
                icon: BlenderGlyph.folder,
                value: 'studio',
              ),
              BlenderTreeNode<String>(
                id: 'outdoor',
                label: 'Outdoor',
                icon: BlenderGlyph.folder,
                value: 'outdoor',
              ),
            ],
          ),
        ],
        onLibraryChanged: (value) => _setStatus('Library: $value'),
        onRefresh: () => _setStatus('Refresh asset library'),
        onBundleInstall: () => _setStatus('Install asset bundle'),
        onNewCatalog: (node) => _setStatus('New catalog under ${node.label}'),
        onCatalogContextMenuSelected: (node, action) =>
            _setStatus('$action catalog: ${node.label}'),
        onSelected: (node) => _setStatus('Catalog: ${node.label}'),
      ),
    ),
    const SizedBox(height: 8),
    SizedBox(
      height: 360,
      child: BlenderAssetLibrariesPreferencesPanel(
        selectedId: 'local',
        libraries: const <BlenderAssetLibraryPreference>[
          BlenderAssetLibraryPreference(id: 'all', name: 'All', builtIn: true),
          BlenderAssetLibraryPreference(
            id: 'essentials',
            name: 'Essentials',
            isEssentials: true,
            builtIn: true,
            includeOnlineEssentials: true,
          ),
          BlenderAssetLibraryPreference(
            id: 'local',
            name: 'Studio Assets',
            path: '/showcase/assets',
            enabled: true,
            useRelativePath: true,
          ),
          BlenderAssetLibraryPreference(
            id: 'remote',
            name: 'Remote Repository',
            isRemote: true,
            remoteUrl: 'https://assets.example.test',
            importMethod: 'Append',
            invalid: true,
          ),
        ],
        onSelected: (library) => _setStatus('Asset library: ${library.name}'),
        onEnabledChanged: (library, value) =>
            _setStatus('${library.name}: enabled $value'),
        onPathChanged: (library, value) =>
            _setStatus('${library.name}: $value'),
        onImportMethodChanged: (library, value) =>
            _setStatus('${library.name}: import $value'),
        onRelativePathChanged: (library, value) =>
            _setStatus('${library.name}: relative $value'),
        onIncludeOnlineEssentialsChanged: (value) =>
            _setStatus('Online Essentials: $value'),
        onAdd: () => _setStatus('Add asset library'),
        onRemove: () => _setStatus('Remove asset library'),
      ),
    ),
    const SizedBox(height: 8),
    BlenderTextureUserSelector(
      selectedId: 'noise',
      users: const <BlenderTextureUser>[
        BlenderTextureUser(
          id: 'noise',
          name: 'Base Color',
          textureName: 'Noise Texture',
          category: 'Material',
          icon: BlenderGlyph.texture,
        ),
        BlenderTextureUser(
          id: 'roughness',
          name: 'Roughness',
          textureName: 'Musgrave',
          category: 'Material',
          icon: BlenderGlyph.texture,
        ),
      ],
      onChanged: (user) => _setStatus('Texture user: ${user.name}'),
      onShowTexture: () => _setStatus('Show texture in Texture tab'),
    ),
    const SizedBox(height: 8),
  ];
}
