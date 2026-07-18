part of '../showcase_app.dart';

extension _ShowcaseTextureCollectionProperties on _ShowcaseAppState {
  List<BlenderPropertyGroup> get _texturePropertyGroups {
    const textureTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Clouds', label: 'Clouds'),
      BlenderMenuItem<String>(value: 'Marble', label: 'Marble'),
      BlenderMenuItem<String>(value: 'Voronoi', label: 'Voronoi'),
      BlenderMenuItem<String>(value: 'Image or Movie', label: 'Image or Movie'),
    ];
    const textureCoordinates = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Generated', label: 'Generated'),
      BlenderMenuItem<String>(value: 'UV', label: 'UV'),
      BlenderMenuItem<String>(value: 'Object', label: 'Object'),
      BlenderMenuItem<String>(value: 'Global', label: 'Global'),
    ];
    const blendTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Mix', label: 'Mix'),
      BlenderMenuItem<String>(value: 'Multiply', label: 'Multiply'),
      BlenderMenuItem<String>(value: 'Screen', label: 'Screen'),
      BlenderMenuItem<String>(value: 'Add', label: 'Add'),
    ];

    return <BlenderPropertyGroup>[
      const BlenderPropertyGroup(
        id: 'texture-preview',
        title: 'Preview',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: const SizedBox(
          height: 92,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Color(0xFF202020)),
            child: Center(child: BlenderIcon(BlenderGlyph.texture, size: 44)),
          ),
        ),
      ),
      BlenderPropertyGroup(
        id: 'texture-context',
        title: 'Texture',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlenderPropertyRow(
              label: 'Texture User',
              editor: BlenderTextureUserSelector(
                inTextureProperties: true,
                selectedId: 'base-color',
                users: const <BlenderTextureUser>[
                  BlenderTextureUser(
                    id: 'base-color',
                    name: 'Base Color',
                    textureName: 'Noise Texture',
                    category: 'Material',
                  ),
                  BlenderTextureUser(
                    id: 'roughness',
                    name: 'Roughness',
                    textureName: 'Musgrave',
                    category: 'Material',
                  ),
                  BlenderTextureUser(
                    id: 'modifier',
                    name: 'Displace',
                    textureName: 'Image Texture',
                    category: 'Modifiers',
                    icon: BlenderGlyph.modifier,
                  ),
                ],
                onChanged: (user) => _setStatus('Texture user: ${user.name}'),
              ),
            ),
          ],
        ),
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'texture-type',
            'Type',
            'Clouds',
            textureTypes,
          ),
          BlenderPropertyFactory.boolean(
            'texture-use-nodes',
            'Use Nodes',
            false,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'texture-node',
        title: 'Node',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'texture-node-active',
            'Use Texture Node',
            true,
          ),
        ],
        content: const SizedBox(
          height: 42,
          child: BlenderBox(child: Center(child: Text('Texture Node'))),
        ),
      ),
      BlenderPropertyGroup(
        id: 'texture-clouds',
        title: 'Clouds',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'texture-noise-basis',
            'Noise Basis',
            'Improved Perlin',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Improved Perlin',
                label: 'Improved Perlin',
              ),
              BlenderMenuItem<String>(
                value: 'Original Perlin',
                label: 'Original Perlin',
              ),
              BlenderMenuItem<String>(value: 'Voronoi', label: 'Voronoi'),
            ],
          ),
          BlenderPropertyFactory.number(
            'texture-noise-scale',
            'Scale',
            .25,
            min: 0,
          ),
          BlenderPropertyFactory.number(
            'texture-noise-depth',
            'Depth',
            2,
            min: 0,
            max: 30,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.number(
            'texture-noise-nabla',
            'Nabla',
            .03,
            min: 0,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'texture-mapping',
        title: 'Mapping',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'texture-coordinates',
            'Coordinates',
            'Generated',
            textureCoordinates,
          ),
          BlenderPropertyFactory.choice<String>(
            'texture-projection',
            'Projection',
            'Flat',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Flat', label: 'Flat'),
              BlenderMenuItem<String>(value: 'Cube', label: 'Cube'),
              BlenderMenuItem<String>(value: 'Sphere', label: 'Sphere'),
            ],
          ),
          BlenderPropertyFactory.number('texture-offset-x', 'Offset X', 0),
          BlenderPropertyFactory.number('texture-offset-y', 'Y', 0),
          BlenderPropertyFactory.number('texture-offset-z', 'Z', 0),
          BlenderPropertyFactory.number('texture-scale-x', 'Scale X', 1),
          BlenderPropertyFactory.number('texture-scale-y', 'Y', 1),
          BlenderPropertyFactory.number('texture-scale-z', 'Z', 1),
        ],
      ),
      BlenderPropertyGroup(
        id: 'texture-influence',
        title: 'Influence',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'texture-blend-type',
            'Blend',
            'Mix',
            blendTypes,
          ),
          BlenderPropertyFactory.number(
            'texture-color-factor',
            'Color',
            1,
            min: 0,
            max: 1,
          ),
          BlenderPropertyFactory.number(
            'texture-alpha-factor',
            'Alpha',
            1,
            min: 0,
            max: 1,
          ),
          BlenderPropertyFactory.number(
            'texture-normal-factor',
            'Normal',
            1,
            min: 0,
            max: 1,
          ),
          BlenderPropertyFactory.boolean(
            'texture-use-map-time',
            'General Time',
            false,
          ),
          BlenderPropertyFactory.boolean(
            'texture-use-map-life',
            'Lifetime',
            false,
          ),
          BlenderPropertyFactory.boolean(
            'texture-use-map-density',
            'Density',
            false,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'texture-colors',
        title: 'Colors',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean('texture-clamp', 'Clamp', false),
          BlenderPropertyFactory.number(
            'texture-multiply-red',
            'Multiply R',
            1,
            min: 0,
          ),
          BlenderPropertyFactory.number(
            'texture-multiply-green',
            'G',
            1,
            min: 0,
          ),
          BlenderPropertyFactory.number(
            'texture-multiply-blue',
            'B',
            1,
            min: 0,
          ),
          BlenderPropertyFactory.number(
            'texture-intensity',
            'Intensity',
            1,
            min: 0,
          ),
          BlenderPropertyFactory.number(
            'texture-contrast',
            'Contrast',
            1,
            min: 0,
          ),
          BlenderPropertyFactory.number(
            'texture-saturation',
            'Saturation',
            1,
            min: 0,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'texture-color-ramp',
            title: 'Color Ramp',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'texture-use-color-ramp',
                'Use Color Ramp',
                true,
              ),
            ],
            content: const SizedBox(
              height: 36,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[Color(0xFF202020), Color(0xFF4772B3)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'texture-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Texture', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'TextureAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'TextureAction',
                  label: 'TextureAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Texture action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'texture-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'texture-custom-property',
            'example_value',
            1,
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _collectionPropertyGroups {
    const lineArtUsages = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Inclusive', label: 'Inclusive'),
      BlenderMenuItem<String>(value: 'Exclusive', label: 'Exclusive'),
      BlenderMenuItem<String>(value: 'None', label: 'None'),
    ];

    Widget exporterContent() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(
          height: 70,
          child: BlenderListView<String>(
            items: const <BlenderListItem<String>>[
              BlenderListItem<String>(id: 'collection-gltf', label: 'glTF 2.0'),
              BlenderListItem<String>(id: 'collection-fbx', label: 'FBX'),
            ],
            selectedId: 'collection-gltf',
          ),
        ),
        const SizedBox(height: 4),
        BlenderPathField(
          controller: _exporterPathController,
          placeholder: 'File Path',
          onBrowse: () => _setStatus('Browse exporter path'),
        ),
        const SizedBox(height: 4),
        Row(
          children: <Widget>[
            Expanded(
              child: BlenderButton(
                label: 'Export All',
                onPressed: () => _setStatus('Export all collections'),
              ),
            ),
            const SizedBox(width: 4),
            BlenderIconButton(
              glyph: BlenderGlyph.plus,
              onPressed: () => _setStatus('Add exporter'),
              tooltip: 'Add exporter',
              size: 24,
            ),
            BlenderIconButton(
              glyph: BlenderGlyph.minus,
              onPressed: () => _setStatus('Remove exporter'),
              tooltip: 'Remove exporter',
              size: 24,
            ),
          ],
        ),
      ],
    );

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'collection-visibility',
        title: 'Visibility',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'collection-selectable',
            'Selectable',
            true,
          ),
          BlenderPropertyFactory.boolean('collection-renders', 'Renders', true),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'collection-view-layer',
            title: 'View Layer',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'collection-include',
                'Include',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'collection-holdout',
                'Holdout',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'collection-indirect-only',
                'Indirect Only',
                false,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'collection-importer',
        title: 'Importer',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'collection-keep-collections',
            'Keep Collections',
            true,
          ),
        ],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlenderPathField(
              controller: _importerPathController,
              placeholder: 'File Path',
              onBrowse: () => _setStatus('Browse importer path'),
            ),
            const SizedBox(height: 4),
            BlenderButton(
              label: 'Remove Importer',
              onPressed: () => _setStatus('Remove collection importer'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'collection-exporters',
        title: 'Exporters',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: exporterContent(),
      ),
      BlenderPropertyGroup(
        id: 'collection-instancing',
        title: 'Instancing',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'collection-instance-offset-x',
            'Instance Offset X',
            0,
          ),
          BlenderPropertyFactory.number('collection-instance-offset-y', 'Y', 0),
          BlenderPropertyFactory.number('collection-instance-offset-z', 'Z', 0),
        ],
      ),
      BlenderPropertyGroup(
        id: 'collection-line-art',
        title: 'Line Art',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'collection-lineart-usage',
            'Usage',
            'Inclusive',
            lineArtUsages,
          ),
          BlenderPropertyFactory.boolean(
            'collection-lineart-mask',
            'Collection Mask',
            false,
          ),
          BlenderPropertyFactory.boolean(
            'collection-lineart-priority-enabled',
            'Intersection Priority',
            false,
          ),
          BlenderPropertyFactory.number(
            'collection-lineart-priority',
            'Priority',
            0,
            min: 0,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.boolean(
            'collection-lineart-mask-1',
            'Mask 1',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'collection-lineart-mask-2',
            'Mask 2',
            false,
          ),
          BlenderPropertyFactory.boolean(
            'collection-lineart-mask-3',
            'Mask 3',
            false,
          ),
          BlenderPropertyFactory.boolean(
            'collection-lineart-mask-4',
            'Mask 4',
            false,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'collection-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'collection-custom-property',
            'example_value',
            1,
          ),
        ],
      ),
    ];
  }
}
