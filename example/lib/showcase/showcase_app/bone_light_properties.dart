part of '../showcase_app.dart';

extension _ShowcaseBoneLightProperties on _ShowcaseAppState {
  List<BlenderPropertyGroup> get _bonePropertyGroups {
    const rotationModes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'XYZ Euler', label: 'XYZ Euler'),
      BlenderMenuItem<String>(value: 'Quaternion', label: 'Quaternion'),
      BlenderMenuItem<String>(value: 'Axis Angle', label: 'Axis Angle'),
    ];
    const displayTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Octahedral', label: 'Octahedral'),
      BlenderMenuItem<String>(value: 'Stick', label: 'Stick'),
      BlenderMenuItem<String>(value: 'B-Bone', label: 'B-Bone'),
      BlenderMenuItem<String>(value: 'Envelope', label: 'Envelope'),
      BlenderMenuItem<String>(value: 'Wire', label: 'Wire'),
    ];
    const handleTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Automatic', label: 'Automatic'),
      BlenderMenuItem<String>(value: 'Absolute', label: 'Absolute'),
      BlenderMenuItem<String>(value: 'Relative', label: 'Relative'),
      BlenderMenuItem<String>(value: 'Tangent', label: 'Tangent'),
    ];

    Widget boneCollections() => SizedBox(
      height: 82,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Expanded(
            child: BlenderBox(
              padding: EdgeInsets.zero,
              child: BlenderListView<String>(
                items: <BlenderListItem<String>>[
                  BlenderListItem<String>(
                    id: 'bone-collection-deform',
                    label: 'Deform',
                    icon: BlenderGlyph.collection,
                  ),
                  BlenderListItem<String>(
                    id: 'bone-collection-controls',
                    label: 'Controls',
                    icon: BlenderGlyph.collection,
                  ),
                ],
                selectedId: 'bone-collection-deform',
              ),
            ),
          ),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              BlenderIconButton(
                glyph: BlenderGlyph.eye,
                onPressed: () =>
                    _setStatus('Toggle bone collection visibility'),
                tooltip: 'Toggle bone collection visibility',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.lock,
                onPressed: () => _setStatus('Toggle bone collection solo'),
                tooltip: 'Toggle bone collection solo',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.minus,
                onPressed: () => _setStatus('Unassign bone collection'),
                tooltip: 'Unassign bone collection',
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'bone-transform',
        title: 'Transform',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number('bone-location-x', 'Location X', 0),
          BlenderPropertyFactory.number('bone-location-y', 'Y', 0),
          BlenderPropertyFactory.number('bone-location-z', 'Z', 0),
          BlenderPropertyFactory.number('bone-rotation-x', 'Rotation X', 0),
          BlenderPropertyFactory.number('bone-rotation-y', 'Y', 0),
          BlenderPropertyFactory.number('bone-rotation-z', 'Z', 0),
          BlenderPropertyFactory.choice<String>(
            'bone-rotation-mode',
            'Mode',
            'XYZ Euler',
            rotationModes,
          ),
          BlenderPropertyFactory.number('bone-scale-x', 'Scale X', 1),
          BlenderPropertyFactory.number('bone-scale-y', 'Y', 1),
          BlenderPropertyFactory.number('bone-scale-z', 'Z', 1),
          BlenderPropertyFactory.number('bone-head-x', 'Head X', 0),
          BlenderPropertyFactory.number('bone-tail-x', 'Tail X', 1),
          BlenderPropertyFactory.number('bone-length', 'Length', 1, min: 0),
        ],
      ),
      BlenderPropertyGroup(
        id: 'bone-bendy-bones',
        title: 'Bendy Bones',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'bone-bbone-segments',
            'Segments',
            4,
            min: 1,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.number(
            'bone-bbone-size-x',
            'Display Size X',
            .25,
            min: 0,
          ),
          BlenderPropertyFactory.number('bone-bbone-size-z', 'Z', .25, min: 0),
          BlenderPropertyFactory.choice<String>(
            'bone-bbone-mapping',
            'Vertex Mapping',
            'Automatic',
            handleTypes,
          ),
          BlenderPropertyFactory.number(
            'bone-bbone-curve-in-x',
            'Curve In X',
            0,
          ),
          BlenderPropertyFactory.number(
            'bone-bbone-curve-out-x',
            'Curve Out X',
            0,
          ),
          BlenderPropertyFactory.number('bone-bbone-roll-in', 'Roll In', 0),
          BlenderPropertyFactory.number('bone-bbone-roll-out', 'Out', 0),
          BlenderPropertyFactory.number(
            'bone-bbone-ease-in',
            'Ease In',
            1,
            min: 0,
          ),
          BlenderPropertyFactory.number(
            'bone-bbone-ease-out',
            'Out',
            1,
            min: 0,
          ),
          BlenderPropertyFactory.choice<String>(
            'bone-bbone-handle-start',
            'Start Handle',
            'Automatic',
            handleTypes,
          ),
          BlenderPropertyFactory.choice<String>(
            'bone-bbone-handle-end',
            'End Handle',
            'Automatic',
            handleTypes,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'bone-relations',
        title: 'Relations',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<String>(
            id: 'bone-parent',
            label: 'Parent',
            value: 'Upper Arm',
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(
                      value: 'Upper Arm',
                      label: 'Upper Arm',
                    ),
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Bone parent changed'),
          ),
          BlenderPropertyFactory.boolean(
            'bone-relative-parent',
            'Relative Parent',
            false,
          ),
          BlenderPropertyFactory.boolean('bone-connected', 'Connected', true),
          BlenderPropertyFactory.boolean(
            'bone-local-location',
            'Local Location',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'bone-inherit-rotation',
            'Inherit Rotation',
            true,
          ),
          BlenderPropertyFactory.choice<String>(
            'bone-inherit-scale',
            'Inherit Scale',
            'Full',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Full', label: 'Full'),
              BlenderMenuItem<String>(value: 'Fix Shear', label: 'Fix Shear'),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'bone-collections',
            title: 'Bone Collections',
            properties: const <BlenderPropertyDescriptor<dynamic>>[],
            content: boneCollections(),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'bone-display',
        title: 'Viewport Display',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean('bone-hide', 'Hide', false),
          BlenderPropertyFactory.boolean(
            'bone-hide-select',
            'Selectable',
            true,
          ),
          BlenderPropertyFactory.choice<String>(
            'bone-display-type',
            'Display As',
            'Octahedral',
            displayTypes,
          ),
          BlenderPropertyFactory.choice<String>(
            'bone-color-palette',
            'Bone Color',
            'Pose Bone Color Set 1',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Pose Bone Color Set 1',
                label: 'Pose Bone Color Set 1',
              ),
              BlenderMenuItem<String>(value: 'Custom', label: 'Custom'),
            ],
          ),
          BlenderPropertyFactory.choice<String>(
            'bone-pose-color-palette',
            'Pose Bone Color',
            'Pose Bone Color Set 1',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Pose Bone Color Set 1',
                label: 'Pose Bone Color Set 1',
              ),
              BlenderMenuItem<String>(value: 'Custom', label: 'Custom'),
            ],
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'bone-custom-shape',
            title: 'Custom Shape',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyDescriptor<String>(
                id: 'bone-custom-shape-object',
                label: 'Custom Shape',
                value: 'None',
                editorBuilder: (context, value, onChanged) =>
                    BlenderDropdown<String>(
                      value: value,
                      items: const <BlenderMenuItem<String>>[
                        BlenderMenuItem<String>(value: 'None', label: 'None'),
                        BlenderMenuItem<String>(value: 'Cube', label: 'Cube'),
                      ],
                      onChanged: onChanged,
                    ),
                onChanged: (_) => _setStatus('Custom shape changed'),
              ),
              BlenderPropertyFactory.number(
                'bone-custom-shape-translation',
                'Translation',
                0,
              ),
              BlenderPropertyFactory.number(
                'bone-custom-shape-rotation',
                'Rotation',
                0,
              ),
              BlenderPropertyFactory.number(
                'bone-custom-shape-scale',
                'Scale',
                1,
                min: 0,
              ),
              BlenderPropertyFactory.boolean(
                'bone-custom-shape-wire',
                'Wireframe',
                false,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'bone-inverse-kinematics',
        title: 'Inverse Kinematics',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'bone-ik-stretch',
            'IK Stretch',
            1,
            min: 0,
            max: 1,
          ),
          BlenderPropertyFactory.boolean('bone-lock-ik-x', 'Lock IK X', false),
          BlenderPropertyFactory.boolean('bone-lock-ik-y', 'Y', false),
          BlenderPropertyFactory.boolean('bone-lock-ik-z', 'Z', false),
          BlenderPropertyFactory.number(
            'bone-ik-stiffness-x',
            'Stiffness X',
            0,
            min: 0,
            max: 1,
          ),
          BlenderPropertyFactory.number(
            'bone-ik-stiffness-y',
            'Y',
            0,
            min: 0,
            max: 1,
          ),
          BlenderPropertyFactory.number(
            'bone-ik-stiffness-z',
            'Z',
            0,
            min: 0,
            max: 1,
          ),
          BlenderPropertyFactory.boolean('bone-ik-limit-x', 'Limit X', false),
          BlenderPropertyFactory.boolean('bone-ik-limit-y', 'Y', false),
          BlenderPropertyFactory.boolean('bone-ik-limit-z', 'Z', false),
        ],
      ),
      BlenderPropertyGroup(
        id: 'bone-deform',
        title: 'Deform',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean('bone-use-deform', 'Use Deform', true),
          BlenderPropertyFactory.number(
            'bone-envelope-distance',
            'Envelope Distance',
            .25,
            min: 0,
          ),
          BlenderPropertyFactory.number(
            'bone-envelope-weight',
            'Envelope Weight',
            1,
            min: 0,
          ),
          BlenderPropertyFactory.boolean(
            'bone-envelope-multiply',
            'Envelope Multiply',
            false,
          ),
          BlenderPropertyFactory.number(
            'bone-head-radius',
            'Radius Head',
            .1,
            min: 0,
          ),
          BlenderPropertyFactory.number('bone-tail-radius', 'Tail', .1, min: 0),
        ],
      ),
      BlenderPropertyGroup(
        id: 'bone-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'bone-custom-property',
            'example_value',
            1,
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _lightPropertyGroups {
    const lightTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Point', label: 'Point'),
      BlenderMenuItem<String>(value: 'Sun', label: 'Sun'),
      BlenderMenuItem<String>(value: 'Spot', label: 'Spot'),
      BlenderMenuItem<String>(value: 'Area', label: 'Area'),
    ];
    const areaShapes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Square', label: 'Square'),
      BlenderMenuItem<String>(value: 'Disk', label: 'Disk'),
      BlenderMenuItem<String>(value: 'Rectangle', label: 'Rectangle'),
      BlenderMenuItem<String>(value: 'Ellipse', label: 'Ellipse'),
    ];

    return <BlenderPropertyGroup>[
      const BlenderPropertyGroup(
        id: 'light-preview',
        title: 'Preview',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: SizedBox(
          height: 90,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Color(0xFF202020)),
            child: Center(child: BlenderIcon(BlenderGlyph.light, size: 46)),
          ),
        ),
      ),
      BlenderPropertyGroup(
        id: 'light-settings',
        title: 'Light',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'light-type',
            'Type',
            'Point',
            lightTypes,
          ),
          BlenderPropertyFactory.boolean(
            'light-temperature',
            'Use Temperature',
            false,
          ),
          BlenderPropertyFactory.number(
            'light-temperature-value',
            'Temperature',
            6500,
            min: 1000,
            max: 20000,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.number(
            'light-energy',
            'Power',
            1000,
            min: 0,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.number(
            'light-exposure',
            'Exposure',
            0,
            decimalDigits: 2,
          ),
          BlenderPropertyFactory.boolean('light-normalize', 'Normalize', true),
          BlenderPropertyFactory.number(
            'light-radius',
            'Radius',
            .25,
            min: 0,
            decimalDigits: 3,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'light-shadow',
            title: 'Shadow',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'light-use-shadow',
                'Use Shadow',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'light-shadow-jitter',
                'Jitter',
                false,
              ),
              BlenderPropertyFactory.number(
                'light-shadow-filter',
                'Filter',
                1,
                min: 0,
                decimalDigits: 2,
              ),
              BlenderPropertyFactory.number(
                'light-shadow-resolution',
                'Resolution Limit',
                2048,
                min: 1,
                decimalDigits: 0,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'light-influence',
            title: 'Influence',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'light-diffuse',
                'Diffuse',
                1,
                min: 0,
                max: 1,
                decimalDigits: 2,
              ),
              BlenderPropertyFactory.number(
                'light-glossy',
                'Glossy',
                1,
                min: 0,
                max: 1,
                decimalDigits: 2,
              ),
              BlenderPropertyFactory.number(
                'light-transmission',
                'Transmission',
                1,
                min: 0,
                max: 1,
                decimalDigits: 2,
              ),
              BlenderPropertyFactory.number(
                'light-volume',
                'Volume Scatter',
                1,
                min: 0,
                max: 1,
                decimalDigits: 2,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'light-custom-distance',
            title: 'Custom Distance',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'light-use-custom-distance',
                'Use Custom Distance',
                false,
              ),
              BlenderPropertyFactory.number(
                'light-cutoff-distance',
                'Distance',
                40,
                min: 0,
                decimalDigits: 2,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'light-beam-shape',
            title: 'Beam Shape',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'light-spot-angle',
                'Angle',
                .785,
                min: 0,
                max: 3.14,
                decimalDigits: 3,
              ),
              BlenderPropertyFactory.number(
                'light-spot-blend',
                'Blend',
                .15,
                min: 0,
                max: 1,
                decimalDigits: 2,
              ),
              BlenderPropertyFactory.choice<String>(
                'light-area-shape',
                'Shape',
                'Square',
                areaShapes,
              ),
              BlenderPropertyFactory.number(
                'light-area-size',
                'Size',
                1,
                min: 0,
                decimalDigits: 2,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'light-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Light', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'LightAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'LightAction',
                  label: 'LightAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Light action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'light-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'light-custom-property',
            'example_value',
            1,
          ),
        ],
      ),
    ];
  }
}
