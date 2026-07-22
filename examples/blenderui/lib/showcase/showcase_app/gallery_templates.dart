part of '../showcase_app.dart';

extension _ShowcaseGalleryTemplates on _ShowcaseAppState {
  List<Widget> _buildControlGalleryFbxImporter() => <Widget>[
    BlenderCollectionImporterPanel(
      importer: BlenderCollectionImporter(
        label: 'FBX Importer',
        filepathController: _importerPathController,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<bool>(
            id: 'keep-collections',
            label: 'Keep Collections',
            value: true,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, label: '', onChanged: onChanged),
            onChanged: (value) => _setStatus('Keep collections: $value'),
          ),
        ],
        onRemove: () => _setStatus('Remove collection importer'),
        onBrowse: () => _setStatus('Browse importer path'),
      ),
    ),
    const SizedBox(height: 8),
    BlenderCollectionExportersPanel(
      selectedId: _selectedExporterId,
      exporters: <BlenderCollectionExporter>[
        BlenderCollectionExporter(
          id: 'gltf',
          label: 'glTF 2.0',
          filepathController: _exporterPathController,
          properties: <BlenderPropertyDescriptor<dynamic>>[
            BlenderPropertyDescriptor<bool>(
              id: 'apply-modifiers',
              label: 'Apply Modifiers',
              value: true,
              editorBuilder: (context, value, onChanged) => BlenderCheckbox(
                value: value,
                label: '',
                onChanged: onChanged,
              ),
              onChanged: (value) => _setStatus('Apply modifiers: $value'),
            ),
            BlenderPropertyDescriptor<double>(
              id: 'scale',
              label: 'Scale',
              value: 1,
              editorBuilder: (context, value, onChanged) => BlenderNumberField(
                value: value,
                min: .01,
                max: 100,
                step: .1,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
        const BlenderCollectionExporter(id: 'usd', label: 'USD', valid: false),
      ],
      onSelected: (exporter) => _update(() {
        _selectedExporterId = exporter.id;
        _setStatus('Exporter: ${exporter.label}');
      }),
      onAdd: () => _setStatus('Add collection exporter'),
      onRemove: () => _setStatus('Remove collection exporter'),
      onMoveUp: () => _setStatus('Move exporter up'),
      onMoveDown: () => _setStatus('Move exporter down'),
      onExportAll: () => _setStatus('Export all collections'),
      onExport: () => _setStatus('Export collection'),
      onPresets: () => _setStatus('Exporter presets'),
      onBrowse: () => _setStatus('Browse exporter path'),
    ),
    const SizedBox(height: 8),
    BlenderColorPalette(
      title: 'Palette',
      colors: const <Color>[
        Color(0xFFB84A4A),
        Color(0xFFD68A3B),
        Color(0xFFD5C34A),
        Color(0xFF6DAA5C),
        Color(0xFF4F8EA8),
        Color(0xFF7965A8),
        Color(0xFFB45B91),
        Color(0xFF6E747A),
      ],
      selectedIndex: 2,
      onSelected: (index) => _setStatus('Palette color $index'),
      onAdd: () => _setStatus('Add palette color'),
      onRemove: () => _setStatus('Remove palette color'),
      onMoveUp: () => _setStatus('Move palette color up'),
      onMoveDown: () => _setStatus('Move palette color down'),
      sortItems: const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'hue', label: 'Hue'),
        BlenderMenuItem<String>(value: 'saturation', label: 'Saturation'),
        BlenderMenuItem<String>(value: 'value', label: 'Value'),
        BlenderMenuItem<String>(value: 'luminance', label: 'Luminance'),
      ],
      onSort: (value) => _setStatus('Sort palette by $value'),
    ),
    const SizedBox(height: 8),
    BlenderColorRamp(
      stops: _galleryRamp,
      onChanged: (stops) => _update(() => _galleryRamp = stops),
      onAdd: _addGalleryRampStop,
      onRemove: _removeGalleryRampStop,
    ),
    const SizedBox(height: 8),
    BlenderCurveMapping(
      points: _galleryCurve,
      onChanged: (points) => _update(() => _galleryCurve = points),
    ),
    const SizedBox(height: 8),
    BlenderCurveProfile(
      points: _galleryProfile,
      presets: const <BlenderCurveProfilePreset>[
        BlenderCurveProfilePreset(
          name: 'Default',
          points: <Offset>[Offset(0, 0), Offset(1, 1)],
        ),
        BlenderCurveProfilePreset(
          name: 'Support Loops',
          points: <Offset>[Offset(0, 0), Offset(.25, .1), Offset(1, 1)],
        ),
      ],
      onChanged: (points) => _update(() => _galleryProfile = points),
    ),
    const SizedBox(height: 8),
    const BlenderScopeView(
      type: BlenderScopeType.waveform,
      title: 'Waveform',
      height: 120,
      series: <BlenderScopeSeries>[
        BlenderScopeSeries(
          color: Color(0xFF71A8FF),
          points: <Offset>[
            Offset(0, .2),
            Offset(.12, .65),
            Offset(.24, .4),
            Offset(.38, .85),
            Offset(.52, .3),
            Offset(.68, .72),
            Offset(.82, .48),
            Offset(1, .8),
          ],
        ),
      ],
    ),
    const SizedBox(height: 8),
    BlenderColorManagement(
      settings: _galleryColorManagement,
      onChanged: (settings) =>
          _update(() => _galleryColorManagement = settings),
    ),
    const SizedBox(height: 8),
    BlenderDataBlockField<String>(
      label: 'Material',
      value: 'Principled',
      items: const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(
          value: 'Principled',
          label: 'Principled BSDF',
          icon: BlenderIcon(BlenderGlyph.material, size: 14),
        ),
        BlenderMenuItem<String>(
          value: 'Toon',
          label: 'Toon Material',
          icon: BlenderIcon(BlenderGlyph.material, size: 14),
        ),
        BlenderMenuItem<String>(
          value: 'Glass',
          label: 'Glass Material',
          icon: BlenderIcon(BlenderGlyph.material, size: 14),
        ),
      ],
      showPreviews: true,
      userCount: 3,
      fakeUser: true,
      linked: true,
      onChanged: (value) => _setStatus('Material: $value'),
      onNew: () => _setStatus('Make new material'),
      onOpen: () => _setStatus('Open material'),
      onMakeSingleUser: () => _setStatus('Make material single-user'),
      onMakeLocal: () => _setStatus('Make material local'),
      onToggleFakeUser: (value) => _setStatus('Fake user: $value'),
      onUnlink: () => _setStatus('Unlink material'),
    ),
    const SizedBox(height: 8),
    BlenderActionSelector<String>(
      value: 'walk',
      label: 'Action',
      items: const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(
          value: 'walk',
          label: 'Walk Cycle',
          icon: BlenderIcon(BlenderGlyph.action, size: 14),
        ),
        BlenderMenuItem<String>(
          value: 'idle',
          label: 'Idle',
          icon: BlenderIcon(BlenderGlyph.action, size: 14),
        ),
      ],
      userCount: 2,
      onChanged: (value) => _setStatus('Action: $value'),
      onNew: () => _setStatus('New action'),
      onUnlink: () => _setStatus('Unlink action'),
    ),
    const SizedBox(height: 8),
    BlenderCryptoPicker(
      label: 'Cryptomatte',
      onPressed: () => _setStatus('Pick Cryptomatte color'),
    ),
    const SizedBox(height: 8),
  ];

  List<Widget> _buildControlGalleryKeymapItemProperties() => <Widget>[
    BlenderKeymapItemProperties(
      title: 'Keymap Item Properties',
      properties: <BlenderKeymapProperty>[
        BlenderKeymapProperty(
          id: 'repeat',
          label: 'Repeat',
          editor: BlenderCheckbox(
            value: true,
            label: 'Repeat',
            onChanged: (_) {},
          ),
          onUnset: () => _setStatus('Unset repeat'),
        ),
        BlenderKeymapProperty(
          id: 'threshold',
          label: 'Threshold',
          editor: BlenderNumberField(
            value: .5,
            min: 0,
            max: 1,
            step: .05,
            onChanged: (_) {},
          ),
          onUnset: () => _setStatus('Unset threshold'),
        ),
        BlenderKeymapProperty(
          id: 'direction',
          label: 'Direction',
          editor: const Text('Inherited'),
          isSet: false,
          onUnset: () => _setStatus('Unset direction'),
        ),
      ],
    ),
    const SizedBox(height: 8),
    BlenderModifierStack(
      modifiers: <BlenderModifierDescriptor>[
        BlenderModifierDescriptor(
          id: 'bevel',
          name: 'Bevel',
          icon: BlenderGlyph.modifier,
          child: BlenderNumberField(
            value: .1,
            label: 'Amount',
            min: 0,
            max: 1,
            step: .01,
            onChanged: (_) {},
          ),
          onToggleEnabled: () => _setStatus('Toggle Bevel'),
          onToggleViewport: () => _setStatus('Toggle viewport'),
          onToggleRender: () => _setStatus('Toggle render'),
          onMoveUp: () => _setStatus('Move Bevel up'),
          onMoveDown: () => _setStatus('Move Bevel down'),
          onRemove: () => _setStatus('Remove Bevel'),
        ),
      ],
    ),
    const SizedBox(height: 8),
    BlenderNodeInputs(
      groups: <BlenderNodeInputGroup>[
        BlenderNodeInputGroup(
          id: 'surface',
          title: 'Surface',
          inputs: <BlenderNodeInputDescriptor>[
            const BlenderNodeInputDescriptor(
              id: 'color',
              label: 'Base Color',
              editor: BlenderColorSwatch(color: Color(0xFF4772B3)),
            ),
            BlenderNodeInputDescriptor(
              id: 'roughness',
              label: 'Roughness',
              editor: BlenderNumberField(
                value: .35,
                min: 0,
                max: 1,
                step: .01,
                onChanged: (_) {},
              ),
            ),
            const BlenderNodeInputDescriptor(
              id: 'normal',
              label: 'Normal',
              editor: SizedBox.shrink(),
              linked: true,
            ),
          ],
        ),
      ],
    ),
    const SizedBox(height: 8),
    const BlenderNoticeBanner(
      message: 'Drag the color-ramp handles and curve points.',
      level: BlenderNoticeLevel.info,
    ),
    const SizedBox(height: 8),
    BlenderReportBanner(
      message: 'Preview built successfully. Click to open Info.',
      level: BlenderNoticeLevel.success,
      onPressed: () => _setStatus('Info report opened'),
    ),
    const SizedBox(height: 8),
    BlenderStatusInfo(
      statusText: 'Scene 1  |  Collection  |  12 Objects',
      versionText: 'Blender 4.5.0',
      extensionStatus: BlenderExtensionStatus.updates,
      extensionCount: 2,
      onExtensionPressed: () => _setStatus('Open extension updates'),
      warningMessage: 'Color Management',
      warningTooltip: 'Displays or color spaces were changed',
      onWarningPressed: () => _setStatus('Open color management'),
    ),
    const SizedBox(height: 8),
    const BlenderInputStatus(
      items: <BlenderInputStatusItem>[
        BlenderInputStatusItem(event: 'LMB drag', label: 'Split/Dock'),
        BlenderInputStatusItem(
          modifiers: <String>['Shift'],
          event: 'LMB drag',
          label: 'Duplicate into Window',
        ),
        BlenderInputStatusItem(
          modifiers: <String>['Ctrl'],
          event: 'LMB drag',
          label: 'Swap Areas',
        ),
        BlenderInputStatusItem(event: 'MMB drag', label: 'Pan'),
        BlenderInputStatusItem(event: 'RMB', label: 'Options'),
        BlenderInputStatusItem(
          modifiers: <String>['Shift'],
          events: <String>['X', 'Y', 'Z'],
          label: 'Axis',
        ),
        BlenderInputStatusItem(events: <String>['X', 'Y', 'Z'], label: 'Plane'),
        BlenderInputStatusItem(
          events: <String>['+', '-', 'Wheel'],
          label: 'Proportional Size',
        ),
        BlenderInputStatusItem(
          label: 'Active object has non-uniform scale',
          icon: BlenderGlyph.warning,
          warning: true,
        ),
      ],
    ),
    const SizedBox(height: 8),
    const BlenderStatusContextBar(kind: BlenderStatusContextKind.splitDock),
    const SizedBox(height: 8),
    const BlenderStatusContextBar(kind: BlenderStatusContextKind.header),
    const SizedBox(height: 8),
    const BlenderStatusContextBar(
      kind: BlenderStatusContextKind.viewportWarning,
      warningText: 'Active object has non-uniform scale',
    ),
    const SizedBox(height: 8),
    BlenderJobProgress(
      name: 'Building preview',
      progress: .68,
      icon: BlenderGlyph.image,
      onCancel: () => _setStatus('Preview build canceled'),
    ),
    const SizedBox(height: 8),
    BlenderRecentFiles(
      files: const <BlenderRecentFile>[
        BlenderRecentFile(
          id: 'scene',
          name: 'showcase.blend',
          path: '/showcase/showcase.blend',
          detail: '2.4 MB',
        ),
        BlenderRecentFile(
          id: 'library',
          name: 'materials.blend',
          path: '/showcase/materials.blend',
          detail: '840 KB',
        ),
      ],
      onSelected: (file) => _setStatus('Opened ${file.name}'),
    ),
    const SizedBox(height: 8),
    BlenderConstraintStack(
      constraints: <BlenderConstraintDescriptor>[
        BlenderConstraintDescriptor(
          id: 'copy-location',
          name: 'Copy Location',
          icon: BlenderGlyph.transform,
          child: BlenderPropertyRow(
            label: 'Influence',
            editor: BlenderNumberField(
              value: .75,
              min: 0,
              max: 1,
              step: .01,
              onChanged: (_) {},
            ),
          ),
          onToggleEnabled: () => _setStatus('Constraint toggled'),
          onMenu: () => _setStatus('Constraint menu'),
          onMoveUp: () => _setStatus('Constraint moved up'),
          onMoveDown: () => _setStatus('Constraint moved down'),
          onRemove: () => _setStatus('Constraint removed'),
        ),
      ],
    ),
    const SizedBox(height: 8),
    BlenderShaderEffectStack(
      effects: <BlenderShaderEffectDescriptor>[
        BlenderShaderEffectDescriptor(
          id: 'shadow',
          name: 'Drop Shadow',
          child: BlenderPropertyRow(
            label: 'Opacity',
            editor: BlenderNumberField(
              value: .5,
              min: 0,
              max: 1,
              step: .01,
              onChanged: (_) {},
            ),
          ),
          onToggleEnabled: () => _setStatus('Shader effect toggled'),
          onMoveUp: () => _setStatus('Shader effect moved up'),
          onMoveDown: () => _setStatus('Shader effect moved down'),
          onRemove: () => _setStatus('Shader effect removed'),
        ),
      ],
    ),
    const SizedBox(height: 8),
  ];

  List<Widget> _buildControlGallerySurface() => <Widget>[
    const BlenderNodeTreeInterface(
      items: <BlenderNodeInterfaceItem>[
        BlenderNodeInterfaceItem.panel(
          BlenderNodeInterfacePanel(
            id: 'surface',
            name: 'Surface',
            children: <BlenderNodeInterfaceItem>[
              BlenderNodeInterfaceItem.socket(
                BlenderNodeInterfaceSocket(
                  id: 'base-color',
                  label: 'Base Color',
                  input: true,
                  color: Color(0xFF8BC34A),
                ),
              ),
              BlenderNodeInterfaceItem.socket(
                BlenderNodeInterfaceSocket(
                  id: 'shader',
                  label: 'Shader',
                  input: false,
                  output: true,
                  color: Color(0xFFFFB74D),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    const SizedBox(height: 8),
    BlenderBoneCollectionTree(
      collections: <BlenderBoneCollection>[
        BlenderBoneCollection(
          id: 'rig',
          name: 'Rig Controls',
          active: true,
          children: <BlenderBoneCollection>[
            BlenderBoneCollection(
              id: 'deform',
              name: 'Deform',
              hasSelectedBones: true,
              onActivate: () => _setStatus('Deform active'),
              onVisibilityChanged: (value) =>
                  _setStatus('Deform visible: $value'),
              onSoloChanged: (value) => _setStatus('Deform solo: $value'),
            ),
            BlenderBoneCollection(
              id: 'controls',
              name: 'Controls',
              solo: true,
              onActivate: () => _setStatus('Controls active'),
            ),
          ],
        ),
      ],
    ),
    const SizedBox(height: 8),
    BlenderAssetShelfPopover(
      label: 'Asset Shelf',
      big: true,
      assets: const <BlenderAssetShelfPopoverItem>[
        BlenderAssetShelfPopoverItem(
          id: 'cube',
          label: 'Cube',
          color: Color(0xFF4772B3),
        ),
        BlenderAssetShelfPopoverItem(
          id: 'sphere',
          label: 'Sphere',
          color: Color(0xFFAC8737),
        ),
        BlenderAssetShelfPopoverItem(
          id: 'light',
          label: 'Studio Light',
          color: Color(0xFF6A8F65),
        ),
      ],
      onSelected: (asset) => _setStatus('Selected ${asset.label}'),
    ),
    const SizedBox(height: 8),
    BlenderComponentMenu<String>(
      value: _galleryMode,
      items: const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Regular', label: 'Regular'),
        BlenderMenuItem<String>(value: 'Compact', label: 'Compact'),
        BlenderMenuItem<String>(value: 'Expanded', label: 'Expanded'),
      ],
      onChanged: (value) => _update(() => _galleryMode = value),
    ),
    const SizedBox(height: 8),
    BlenderIconView<String>(
      value: _galleryMode,
      items: const <BlenderIconViewItem<String>>[
        BlenderIconViewItem<String>(
          value: 'Regular',
          label: 'Regular',
          icon: BlenderIcon(BlenderGlyph.object, size: 30),
        ),
        BlenderIconViewItem<String>(
          value: 'Compact',
          label: 'Compact',
          icon: BlenderIcon(BlenderGlyph.collection, size: 30),
        ),
        BlenderIconViewItem<String>(
          value: 'Expanded',
          label: 'Expanded',
          icon: BlenderIcon(BlenderGlyph.material, size: 30),
        ),
        BlenderIconViewItem<String>(
          value: 'Preview',
          label: 'Preview',
          icon: BlenderIcon(BlenderGlyph.image, size: 30),
        ),
      ],
      onChanged: (value) => _update(() => _galleryMode = value),
    ),
    const SizedBox(height: 8),
    BlenderCompactList<String>(
      selectedIndex: _galleryListIndex,
      onChanged: (value) => _update(() => _galleryListIndex = value),
      items: const <BlenderListItem<String>>[
        BlenderListItem<String>(
          id: 'one',
          label: 'First component',
          value: 'one',
          detail: 'A',
        ),
        BlenderListItem<String>(
          id: 'two',
          label: 'Second component',
          value: 'two',
          detail: 'B',
        ),
      ],
    ),
    const SizedBox(height: 8),
    BlenderCacheFilePanel(
      settings: _galleryCacheFile,
      onChanged: (settings) => _update(() => _galleryCacheFile = settings),
      onBrowse: () => _setStatus('Browse cache file'),
      onReload: () => _setStatus('Reload cache file'),
    ),
    const SizedBox(height: 8),
    BlenderLightLinkingCollection(
      collectionLabel: 'Studio Lights',
      items: <BlenderLightLinkingItem>[
        BlenderLightLinkingItem(
          id: 'key',
          label: 'Key Light',
          icon: BlenderGlyph.light,
          onStateChanged: (state) => _setStatus('Key Light ${state.name}'),
        ),
        BlenderLightLinkingItem(
          id: 'fill',
          label: 'Fill Collection',
          icon: BlenderGlyph.collection,
          state: BlenderLightLinkingState.exclude,
          onStateChanged: (state) =>
              _setStatus('Fill Collection ${state.name}'),
        ),
      ],
    ),
    const SizedBox(height: 8),
    BlenderGreasePencilLayerTree(
      searchController: _layerSearchController,
      layers: <BlenderGreasePencilLayer>[
        BlenderGreasePencilLayer(
          id: 'characters',
          name: 'Characters',
          isGroup: true,
          active: true,
          children: <BlenderGreasePencilLayer>[
            BlenderGreasePencilLayer(
              id: 'outline',
              name: 'Outline',
              useMasks: true,
              onActivate: () => _setStatus('Outline active'),
              onMasksChanged: (value) => _setStatus('Outline masks: $value'),
              onHiddenChanged: (value) => _setStatus('Outline hidden: $value'),
              onLockedChanged: (value) => _setStatus('Outline locked: $value'),
            ),
            BlenderGreasePencilLayer(
              id: 'fill',
              name: 'Fill',
              useOnionSkinning: true,
              onActivate: () => _setStatus('Fill active'),
            ),
          ],
        ),
        BlenderGreasePencilLayer(
          id: 'background',
          name: 'Background',
          onActivate: () => _setStatus('Background active'),
        ),
      ],
    ),
  ];
}
