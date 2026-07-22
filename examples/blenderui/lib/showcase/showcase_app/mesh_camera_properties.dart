part of '../showcase_app.dart';

extension _ShowcaseMeshCameraProperties on _ShowcaseAppState {
  List<BlenderPropertyGroup> get _meshPropertyGroups {
    const remeshModes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Voxel', label: 'Voxel'),
      BlenderMenuItem<String>(value: 'QuadriFlow', label: 'QuadriFlow'),
    ];
    const textureMeshes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Original', label: 'Original'),
      BlenderMenuItem<String>(value: 'None', label: 'None'),
    ];

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'mesh-vertex-groups',
        title: 'Vertex Groups',
        content: _meshListContent(
          label: 'Vertex Group',
          showMoveButtons: true,
          items: const <BlenderListItem<String>>[
            BlenderListItem<String>(
              id: 'mesh-vgroup-deform',
              label: 'Deform',
              icon: BlenderGlyph.collection,
              detail: '0.000',
            ),
            BlenderListItem<String>(
              id: 'mesh-vgroup-secondary',
              label: 'Secondary',
              icon: BlenderGlyph.collection,
            ),
          ],
        ),
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<double>(
            id: 'mesh-vgroup-weight',
            label: 'Weight',
            value: 1,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: 0,
              max: 1,
              decimalDigits: 3,
              onChanged: onChanged,
            ),
            onChanged: (_) => _setStatus('Vertex group weight changed'),
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'mesh-vgroup-normalize',
            label: 'Auto Normalize',
            value: true,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (_) => _setStatus('Auto Normalize changed'),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mesh-shape-keys',
        title: 'Shape Keys',
        content: _meshListContent(
          label: 'Shape Key',
          showMoveButtons: true,
          items: const <BlenderListItem<String>>[
            BlenderListItem<String>(
              id: 'mesh-shape-basis',
              label: 'Basis',
              icon: BlenderGlyph.keyframe,
            ),
            BlenderListItem<String>(
              id: 'mesh-shape-smile',
              label: 'Smile',
              icon: BlenderGlyph.keyframe,
            ),
          ],
        ),
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<bool>(
            id: 'mesh-shape-relative',
            label: 'Relative',
            value: true,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (_) => _setStatus('Shape key mode changed'),
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'mesh-shape-edit-mode',
            label: 'Edit Mode',
            value: false,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (_) => _setStatus('Shape key Edit Mode changed'),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mesh-uv-maps',
        title: 'UV Maps',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: _meshListContent(
          label: 'UV Map',
          items: const <BlenderListItem<String>>[
            BlenderListItem<String>(
              id: 'mesh-uvmap-primary',
              label: 'UVMap',
              icon: BlenderGlyph.uv,
              detail: 'Render',
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'mesh-color-attributes',
        title: 'Color Attributes',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: _meshListContent(
          label: 'Color Attribute',
          items: const <BlenderListItem<String>>[
            BlenderListItem<String>(
              id: 'mesh-color-attribute',
              label: 'Color',
              icon: BlenderGlyph.color,
              detail: 'Point - Color',
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'mesh-attributes',
        title: 'Attributes',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: _meshListContent(
          label: 'Attribute',
          items: const <BlenderListItem<String>>[
            BlenderListItem<String>(
              id: 'mesh-attribute-position',
              label: 'position',
              detail: 'Point - Float3',
            ),
            BlenderListItem<String>(
              id: 'mesh-attribute-material',
              label: 'material_index',
              detail: 'Face - Int',
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'mesh-texture-space',
        title: 'Texture Space',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<String>(
            id: 'mesh-texture-mesh',
            label: 'Texture Mesh',
            value: 'Original',
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: textureMeshes,
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Texture Mesh changed'),
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'mesh-auto-texspace',
            label: 'Auto Texture Space',
            value: true,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (_) => _setStatus('Auto Texture Space changed'),
          ),
          BlenderPropertyDescriptor<List<double>>(
            id: 'mesh-texspace-location',
            label: 'Location',
            value: const <double>[0, 0, 0],
            editorBuilder: (context, value, onChanged) =>
                BlenderVectorField(values: value, onChanged: onChanged),
            onChanged: (_) => _setStatus('Texture space location changed'),
          ),
          BlenderPropertyDescriptor<List<double>>(
            id: 'mesh-texspace-size',
            label: 'Size',
            value: const <double>[2, 2, 2],
            editorBuilder: (context, value, onChanged) =>
                BlenderVectorField(values: value, min: 0, onChanged: onChanged),
            onChanged: (_) => _setStatus('Texture space size changed'),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mesh-remesh',
        title: 'Remesh',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<String>(
            id: 'mesh-remesh-mode',
            label: 'Mode',
            value: 'Voxel',
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: remeshModes,
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Remesh mode changed'),
          ),
          BlenderPropertyDescriptor<double>(
            id: 'mesh-remesh-voxel-size',
            label: 'Voxel Size',
            value: .1,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: .001,
              max: 10,
              decimalDigits: 3,
              onChanged: onChanged,
            ),
            onChanged: (_) => _setStatus('Voxel Size changed'),
          ),
          BlenderPropertyDescriptor<double>(
            id: 'mesh-remesh-adaptivity',
            label: 'Adaptivity',
            value: 0,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: 0,
              max: 1,
              decimalDigits: 2,
              onChanged: onChanged,
            ),
            onChanged: (_) => _setStatus('Adaptivity changed'),
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'mesh-remesh-preserve-volume',
            label: 'Preserve Volume',
            value: true,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (_) => _setStatus('Preserve Volume changed'),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mesh-geometry-data',
        title: 'Geometry Data',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlenderButton(
              label: 'Clear Custom Normals',
              onPressed: () => _setStatus('Clear Custom Normals'),
            ),
            const SizedBox(height: 4),
            BlenderButton(
              label: 'Reorder Vertices Spatially',
              onPressed: () => _setStatus('Reorder vertices'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'mesh-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Mesh', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'MeshAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'MeshAction',
                  label: 'MeshAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Mesh action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'mesh-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<double>(
            id: 'mesh-custom-property',
            label: 'example_value',
            value: 1,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              decimalDigits: 2,
              onChanged: onChanged,
            ),
            onChanged: (_) => _setStatus('Mesh custom property changed'),
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _cameraPropertyGroups {
    const cameraTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Perspective', label: 'Perspective'),
      BlenderMenuItem<String>(value: 'Orthographic', label: 'Orthographic'),
      BlenderMenuItem<String>(value: 'Panoramic', label: 'Panoramic'),
    ];
    const lensUnits = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Millimeters', label: 'Millimeters'),
      BlenderMenuItem<String>(value: 'Field of View', label: 'Field of View'),
    ];
    const sensorFits = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Auto', label: 'Auto'),
      BlenderMenuItem<String>(value: 'Horizontal', label: 'Horizontal'),
      BlenderMenuItem<String>(value: 'Vertical', label: 'Vertical'),
    ];

    Widget backgroundImages() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        BlenderButton(
          label: 'Add Image',
          onPressed: () => _setStatus('Add camera background image'),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 70,
          child: BlenderBox(
            padding: EdgeInsets.zero,
            child: BlenderListView<String>(
              items: const <BlenderListItem<String>>[
                BlenderListItem<String>(
                  id: 'camera-background-image',
                  label: 'Reference Image',
                  icon: BlenderGlyph.image,
                  detail: 'Visible',
                ),
              ],
              selectedId: 'camera-background-image',
              onSelected: (item) => _setStatus('Background: ${item.label}'),
            ),
          ),
        ),
      ],
    );

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'camera-lens',
        title: 'Lens',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'camera-type',
            'Type',
            'Perspective',
            cameraTypes,
          ),
          BlenderPropertyFactory.number(
            'camera-lens',
            'Focal Length',
            50,
            min: 1,
            max: 500,
          ),
          BlenderPropertyFactory.choice<String>(
            'camera-lens-unit',
            'Unit',
            'Millimeters',
            lensUnits,
          ),
          BlenderPropertyFactory.number(
            'camera-shift-x',
            'Shift X',
            0,
            decimalDigits: 3,
          ),
          BlenderPropertyFactory.number(
            'camera-shift-y',
            'Y',
            0,
            decimalDigits: 3,
          ),
          BlenderPropertyFactory.number(
            'camera-clip-start',
            'Clip Start',
            .1,
            min: .001,
          ),
          BlenderPropertyFactory.number(
            'camera-clip-end',
            'End',
            1000,
            min: .001,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'camera-stereoscopy',
        title: 'Stereoscopy',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'camera-stereo-convergence',
            'Convergence',
            true,
          ),
          BlenderPropertyFactory.number(
            'camera-stereo-interocular',
            'Interocular Distance',
            .065,
            min: 0,
            decimalDigits: 3,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'camera-settings',
        title: 'Camera',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'camera-sensor-fit',
            'Sensor Fit',
            'Auto',
            sensorFits,
          ),
          BlenderPropertyFactory.number(
            'camera-sensor-width',
            'Sensor Width',
            36,
            min: 1,
            max: 100,
          ),
          BlenderPropertyFactory.number(
            'camera-sensor-height',
            'Sensor Height',
            24,
            min: 1,
            max: 100,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'camera-depth-of-field',
        title: 'Depth of Field',
        initiallyExpanded: false,
        headerLeading: BlenderPropertyFactory.boolean(
          'camera-use-dof-header',
          '',
          true,
        ).buildEditor(context),
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'camera-focus-object',
            'Focus on Object',
            'Empty',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Empty', label: 'Empty'),
              BlenderMenuItem<String>(value: 'Cube', label: 'Cube'),
            ],
          ),
          BlenderPropertyFactory.number(
            'camera-focus-distance',
            'Focus Distance',
            10,
            min: 0,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'camera-aperture',
            title: 'Aperture',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'camera-fstop',
                'F-Stop',
                2.8,
                min: .1,
                max: 128,
                decimalDigits: 2,
              ),
              BlenderPropertyFactory.number(
                'camera-aperture-blades',
                'Blades',
                6,
                min: 0,
                max: 32,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.number(
                'camera-aperture-rotation',
                'Rotation',
                0,
                decimalDigits: 2,
              ),
              BlenderPropertyFactory.number(
                'camera-aperture-ratio',
                'Ratio',
                1,
                min: .01,
                max: 1,
                decimalDigits: 2,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'camera-background-images',
        title: 'Background Images',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: backgroundImages(),
      ),
      BlenderPropertyGroup(
        id: 'camera-display',
        title: 'Viewport Display',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'camera-display-size',
            'Size',
            1,
            min: .01,
          ),
          BlenderPropertyFactory.boolean('camera-show-limits', 'Limits', false),
          BlenderPropertyFactory.boolean('camera-show-mist', 'Mist', false),
          BlenderPropertyFactory.boolean('camera-show-sensor', 'Sensor', true),
          BlenderPropertyFactory.boolean('camera-show-name', 'Name', true),
          BlenderPropertyFactory.boolean(
            'camera-show-passepartout',
            'Passepartout',
            true,
          ),
          BlenderPropertyFactory.number(
            'camera-passepartout-alpha',
            'Alpha',
            .5,
            min: 0,
            max: 1,
            decimalDigits: 2,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'camera-composition-guides',
            title: 'Composition Guides',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'camera-guides-thirds',
                'Thirds',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'camera-guides-center',
                'Center',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'camera-guides-diagonal',
                'Diagonal',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'camera-guides-golden',
                'Golden',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'camera-guides-harmony',
                'Harmony',
                false,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'camera-safe-areas',
        title: 'Safe Areas',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'camera-safe-areas-show',
            'Show Safe Areas',
            true,
          ),
          BlenderPropertyFactory.number(
            'camera-safe-title',
            'Title',
            .8,
            min: 0,
            max: 1,
            decimalDigits: 2,
          ),
          BlenderPropertyFactory.number(
            'camera-safe-action',
            'Action',
            .9,
            min: 0,
            max: 1,
            decimalDigits: 2,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'camera-center-cut',
            title: 'Center-Cut Safe Areas',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'camera-safe-center',
                'Show Center-Cut',
                false,
              ),
              BlenderPropertyFactory.number(
                'camera-safe-title-center',
                'Title',
                .8,
                min: 0,
                max: 1,
                decimalDigits: 2,
              ),
              BlenderPropertyFactory.number(
                'camera-safe-action-center',
                'Action',
                .9,
                min: 0,
                max: 1,
                decimalDigits: 2,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'camera-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Camera', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'CameraAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'CameraAction',
                  label: 'CameraAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Camera action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'camera-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'camera-custom-property',
            'example_value',
            1,
          ),
        ],
      ),
    ];
  }
}
