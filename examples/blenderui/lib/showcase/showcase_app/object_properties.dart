part of '../showcase_app.dart';

extension _ShowcaseObjectProperties on _ShowcaseAppState {
  void _setObjectVectorValue(
    List<double> values,
    int index,
    double value,
    void Function(List<double>) assign,
  ) {
    final updated = BlenderPropertyValues.replaceAt(values, index, value);
    _update(() => assign(updated));
  }

  void _toggleObjectVectorLock(
    List<bool> locks,
    int index,
    void Function(List<bool>) assign,
  ) {
    final updated = BlenderPropertyValues.toggleAt(locks, index);
    _update(() => assign(updated));
  }

  List<BlenderPropertyGroup> get _objectPropertyGroups {
    const axes = <String>['X', 'Y', 'Z'];

    const parentTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Object', label: 'Object'),
      BlenderMenuItem<String>(value: 'Bone', label: 'Bone'),
      BlenderMenuItem<String>(value: 'Vertex', label: 'Vertex'),
      BlenderMenuItem<String>(value: 'Collection', label: 'Collection'),
    ];
    const displayTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Textured', label: 'Textured'),
      BlenderMenuItem<String>(value: 'Solid', label: 'Solid'),
      BlenderMenuItem<String>(value: 'Wire', label: 'Wire'),
      BlenderMenuItem<String>(value: 'Bounds', label: 'Bounds'),
    ];
    const instanceTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'None', label: 'None'),
      BlenderMenuItem<String>(value: 'Vertices', label: 'Vertices'),
      BlenderMenuItem<String>(value: 'Faces', label: 'Faces'),
      BlenderMenuItem<String>(value: 'Collection', label: 'Collection'),
    ];
    const axisItems = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'X', label: 'X'),
      BlenderMenuItem<String>(value: 'Y', label: 'Y'),
      BlenderMenuItem<String>(value: 'Z', label: 'Z'),
      BlenderMenuItem<String>(value: '-Z', label: '-Z'),
    ];
    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'object-transform',
        title: 'Transform',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          for (var index = 0; index < 3; index++)
            BlenderPropertyDescriptor<double>(
              id: 'object-location-${axes[index].toLowerCase()}',
              label: index == 0 ? 'Location X' : axes[index],
              value: _objectLocation[index],
              editorBuilder: (context, value, onChanged) =>
                  BlenderTransformAxisField(
                    value: value,
                    suffix: ' m',
                    decimalDigits: 4,
                    locked: _objectLocationLocks[index],
                    onChanged: onChanged,
                    onLockChanged: () => _toggleObjectVectorLock(
                      _objectLocationLocks,
                      index,
                      (locks) => _objectLocationLocks = locks,
                    ),
                    onKeyframe: () =>
                        _setStatus('Keyframe Location ${axes[index]}'),
                  ),
              onChanged: (value) => _setObjectVectorValue(
                _objectLocation,
                index,
                value,
                (values) => _objectLocation = values,
              ),
            ),
          for (var index = 0; index < 3; index++)
            BlenderPropertyDescriptor<double>(
              id: 'object-rotation-${axes[index].toLowerCase()}',
              label: index == 0 ? 'Rotation X' : axes[index],
              value: _objectRotation[index],
              editorBuilder: (context, value, onChanged) =>
                  BlenderTransformAxisField(
                    value: value,
                    suffix: '°',
                    decimalDigits: 0,
                    locked: _objectRotationLocks[index],
                    onChanged: onChanged,
                    onLockChanged: () => _toggleObjectVectorLock(
                      _objectRotationLocks,
                      index,
                      (locks) => _objectRotationLocks = locks,
                    ),
                    onKeyframe: () =>
                        _setStatus('Keyframe Rotation ${axes[index]}'),
                  ),
              onChanged: (value) => _setObjectVectorValue(
                _objectRotation,
                index,
                value,
                (values) => _objectRotation = values,
              ),
            ),
          BlenderPropertyDescriptor<String>(
            id: 'object-rotation-mode',
            label: 'Mode',
            value: _objectRotationMode,
            editorBuilder: (context, value, onChanged) =>
                BlenderRotationModeField(
                  value: value,
                  onChanged: onChanged,
                  onKeyframe: () => _setStatus('Keyframe Rotation Mode'),
                ),
            onChanged: (value) => _update(() => _objectRotationMode = value),
          ),
          for (var index = 0; index < 3; index++)
            BlenderPropertyDescriptor<double>(
              id: 'object-scale-${axes[index].toLowerCase()}',
              label: index == 0 ? 'Scale X' : axes[index],
              value: _objectScale[index],
              editorBuilder: (context, value, onChanged) =>
                  BlenderTransformAxisField(
                    value: value,
                    decimalDigits: 3,
                    locked: _objectScaleLocks[index],
                    onChanged: onChanged,
                    onLockChanged: () => _toggleObjectVectorLock(
                      _objectScaleLocks,
                      index,
                      (locks) => _objectScaleLocks = locks,
                    ),
                    onKeyframe: () =>
                        _setStatus('Keyframe Scale ${axes[index]}'),
                  ),
              onChanged: (value) => _setObjectVectorValue(
                _objectScale,
                index,
                value,
                (values) => _objectScale = values,
              ),
            ),
        ],
        children: const <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'object-delta-transform',
            title: 'Delta Transform',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[],
          ),
          BlenderPropertyGroup(
            id: 'object-parent-inverse-transform',
            title: 'Parent Inverse Transform',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'object-relations',
        title: 'Relations',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'object-parent',
            'Parent',
            'Scene',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Scene', label: 'Scene'),
              BlenderMenuItem<String>(value: 'Camera', label: 'Camera'),
              BlenderMenuItem<String>(value: 'Empty', label: 'Empty'),
            ],
          ),
          BlenderPropertyFactory.choice<String>(
            'object-parent-type',
            'Parent Type',
            'Object',
            parentTypes,
          ),
          BlenderPropertyFactory.boolean(
            'object-camera-lock-parent',
            'Camera Lock Parent',
            true,
          ),
          BlenderPropertyFactory.choice<String>(
            'object-track-axis',
            'Tracking Axis',
            '-Z',
            axisItems,
          ),
          BlenderPropertyFactory.choice<String>(
            'object-up-axis',
            'Up Axis',
            'Y',
            axisItems,
          ),
          BlenderPropertyFactory.number('object-pass-index', 'Pass Index', 0),
        ],
      ),
      BlenderPropertyGroup(
        id: 'object-collections',
        title: 'Collections',
        initiallyExpanded: false,
        headerActions: <Widget>[
          BlenderIconButton(
            glyph: BlenderGlyph.plus,
            onPressed: () => _setStatus('Add to Collection'),
            tooltip: 'Add to Collection',
            size: 22,
          ),
        ],
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'object-collection',
            'Collection',
            'Collection',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Collection', label: 'Collection'),
              BlenderMenuItem<String>(
                value: 'Environment',
                label: 'Environment',
              ),
            ],
          ),
          BlenderPropertyFactory.number(
            'object-instance-offset',
            'Instance Offset',
            0,
            decimalDigits: 2,
            step: .1,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'object-instancing',
        title: 'Instancing',
        initiallyExpanded: false,
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'object-instancing-size',
            title: 'Scale by Face Size',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'object-instance-face-scale',
                'Scale by Face Size',
                false,
              ),
              BlenderPropertyFactory.number(
                'object-instance-face-factor',
                'Factor',
                1,
                decimalDigits: 3,
                step: .01,
              ),
            ],
          ),
        ],
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'object-instance-type',
            'Instance Type',
            'None',
            instanceTypes,
          ),
          BlenderPropertyFactory.boolean(
            'object-instance-vertex-rotation',
            'Align to Vertex Normal',
            false,
          ),
          BlenderPropertyFactory.choice<String>(
            'object-instance-collection',
            'Collection',
            'Collection',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Collection', label: 'Collection'),
              BlenderMenuItem<String>(
                value: 'Environment',
                label: 'Environment',
              ),
            ],
          ),
          BlenderPropertyFactory.boolean(
            'object-show-instancer-viewport',
            'Show Instancer Viewport',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'object-show-instancer-render',
            'Show Instancer Render',
            true,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'object-motion-paths',
        title: 'Motion Paths',
        initiallyExpanded: false,
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'object-motion-paths-display',
            title: 'Display',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'object-motion-paths-type',
                'Type',
                'Around Frame',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Around Frame',
                    label: 'Around Frame',
                  ),
                  BlenderMenuItem<String>(value: 'Range', label: 'Range'),
                ],
              ),
              BlenderPropertyFactory.boolean(
                'object-motion-paths-frame-numbers',
                'Frame Numbers',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'object-motion-paths-keyframes',
                'Keyframes',
                true,
              ),
            ],
          ),
        ],
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'object-motion-paths-before',
            'Before',
            20,
          ),
          BlenderPropertyFactory.number(
            'object-motion-paths-after',
            'After',
            20,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'object-viewport-display',
        title: 'Viewport Display',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean('object-show-name', 'Name', true),
          BlenderPropertyFactory.boolean('object-show-axis', 'Axes', false),
          BlenderPropertyFactory.boolean(
            'object-show-wire',
            'Wireframe',
            false,
          ),
          BlenderPropertyFactory.boolean(
            'object-show-all-edges',
            'All Edges',
            false,
          ),
          BlenderPropertyFactory.boolean(
            'object-show-texture-space',
            'Texture Space',
            false,
          ),
          BlenderPropertyFactory.boolean('object-show-shadows', 'Shadow', true),
          BlenderPropertyFactory.boolean(
            'object-show-in-front',
            'In Front',
            false,
          ),
          BlenderPropertyFactory.choice<String>(
            'object-display-type',
            'Display As',
            'Textured',
            displayTypes,
          ),
          BlenderPropertyFactory.boolean('object-show-bounds', 'Bounds', false),
          BlenderPropertyFactory.choice<String>(
            'object-bounds-type',
            'Bounds Type',
            'Box',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Box', label: 'Box'),
              BlenderMenuItem<String>(value: 'Sphere', label: 'Sphere'),
              BlenderMenuItem<String>(value: 'Cylinder', label: 'Cylinder'),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'object-shading',
        title: 'Shading',
        initiallyExpanded: false,
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'object-light-linking',
            title: 'Light Linking',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'object-light-linking-collection',
                'Receiver Collection',
                'Collection',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Collection',
                    label: 'Collection',
                  ),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'object-shadow-linking',
            title: 'Shadow Linking',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'object-shadow-linking-collection',
                'Blocker Collection',
                'Collection',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Collection',
                    label: 'Collection',
                  ),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'object-shadow-terminator',
            title: 'Shadow Terminator',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'object-shadow-normal-offset',
                'Normal Offset',
                0,
                decimalDigits: 3,
                step: .01,
              ),
              BlenderPropertyFactory.number(
                'object-shadow-geometry-offset',
                'Geometry Offset',
                0,
                decimalDigits: 3,
                step: .01,
              ),
            ],
          ),
        ],
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
      ),
      BlenderPropertyGroup(
        id: 'object-visibility',
        title: 'Visibility',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'object-selectable',
            'Selectable',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'object-surface-picking',
            'Surface Picking',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'object-hide-viewport',
            'Viewports',
            true,
          ),
          BlenderPropertyFactory.boolean('object-hide-render', 'Renders', true),
          BlenderPropertyFactory.boolean(
            'object-visible-camera',
            'Ray Visibility Camera',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'object-visible-shadow',
            'Ray Visibility Shadow',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'object-visible-raycast',
            'Ray Visibility Raycast',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'object-hide-probe-volume',
            'Light Probes Volume',
            false,
          ),
          BlenderPropertyFactory.boolean(
            'object-hide-probe-sphere',
            'Light Probes Sphere',
            false,
          ),
          BlenderPropertyFactory.boolean(
            'object-hide-probe-plane',
            'Light Probes Plane',
            false,
          ),
          BlenderPropertyFactory.boolean('object-holdout', 'Holdout', false),
        ],
      ),
      BlenderPropertyGroup(
        id: 'object-line-art',
        title: 'Line Art',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'object-line-art-usage',
            'Usage',
            'Include',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Include', label: 'Include'),
              BlenderMenuItem<String>(value: 'Exclude', label: 'Exclude'),
            ],
          ),
          BlenderPropertyFactory.boolean(
            'object-line-art-crease-override',
            'Override Crease',
            false,
          ),
          BlenderPropertyFactory.number(
            'object-line-art-crease-threshold',
            'Crease Threshold',
            0,
            decimalDigits: 3,
            step: .01,
          ),
          BlenderPropertyFactory.boolean(
            'object-line-art-intersection-override',
            'Override Intersection Priority',
            false,
          ),
          BlenderPropertyFactory.number(
            'object-line-art-intersection-priority',
            'Intersection Priority',
            0,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'object-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'object-animation-use-nla',
            'NLA Tracks',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'object-animation-use-action',
            'Action',
            true,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'object-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<double>(
            id: 'object-custom-property-example',
            label: 'example_value',
            value: 1,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              decimalDigits: 2,
              onChanged: onChanged,
            ),
            onChanged: (_) => _setStatus('Custom property changed'),
          ),
        ],
      ),
    ];
  }

  String get _propertiesContextTitle => switch (_propertyTab) {
    0 => 'Select Box',
    1 => 'Render',
    2 => 'Output',
    3 => 'View Layer',
    4 => 'Scene',
    5 => 'World',
    6 => 'Collection',
    7 => _selectedObject,
    8 => 'Modifiers',
    9 => 'Effects',
    10 => 'Particles',
    11 => 'Physics',
    12 => 'Constraints',
    13 => _dataPropertiesTitle,
    14 => 'Bone Properties',
    15 => 'Bone Constraints',
    16 => 'Material',
    17 => 'Texture',
    18 => 'Strip',
    19 => 'Strip Modifiers',
    _ => _dataPropertiesTitle,
  };

  BlenderGlyph get _propertiesContextGlyph => switch (_propertyTab) {
    0 => BlenderGlyph.selectBox,
    1 => BlenderGlyph.render,
    2 => BlenderGlyph.output,
    3 => BlenderGlyph.viewLayer,
    4 => BlenderGlyph.scene,
    5 => BlenderGlyph.world,
    6 => BlenderGlyph.collection,
    7 => BlenderGlyph.object,
    8 => BlenderGlyph.modifier,
    9 => BlenderGlyph.shaderfx,
    10 => BlenderGlyph.physics,
    11 => BlenderGlyph.physics,
    12 => BlenderGlyph.link,
    14 => BlenderGlyph.bone,
    15 => BlenderGlyph.link,
    16 => BlenderGlyph.material,
    17 => BlenderGlyph.texture,
    18 => BlenderGlyph.sequence,
    19 => BlenderGlyph.modifier,
    _ => _dataPropertiesGlyph,
  };

  List<BlenderPropertyGroup> get _visiblePropertyGroups =>
      switch (_propertyTab) {
        0 => _toolPropertyGroups,
        1 => _renderPropertyGroups,
        2 => _propertyGroups,
        3 => _viewLayerPropertyGroups,
        4 => _scenePropertyGroups,
        5 => _worldPropertyGroups,
        6 => _collectionPropertyGroups,
        7 => _objectPropertyGroups,
        8 => const <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'modifier-context',
            title: 'Modifiers',
            properties: <BlenderPropertyDescriptor<dynamic>>[],
          ),
        ],
        9 => const <BlenderPropertyGroup>[],
        10 => _particlePropertyGroups,
        11 => _physicsPropertyGroups,
        12 => const <BlenderPropertyGroup>[],
        13 => _dataPropertyGroups,
        14 => _bonePropertyGroups,
        15 => const <BlenderPropertyGroup>[],
        16 => _materialPropertyGroups,
        17 => _texturePropertyGroups,
        18 => const <BlenderPropertyGroup>[],
        19 => const <BlenderPropertyGroup>[],
        _ => const <BlenderPropertyGroup>[],
      };
}
