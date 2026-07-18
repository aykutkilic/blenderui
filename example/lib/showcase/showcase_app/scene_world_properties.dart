part of '../showcase_app.dart';

extension _ShowcaseSceneWorldProperties on _ShowcaseAppState {
  List<BlenderPropertyGroup> get _scenePropertyGroups {
    const sceneChoices = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Scene', label: 'Scene'),
      BlenderMenuItem<String>(value: 'Scene.001', label: 'Scene.001'),
    ];
    const unitChoices = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'None', label: 'None'),
      BlenderMenuItem<String>(value: 'Metric', label: 'Metric'),
      BlenderMenuItem<String>(value: 'Imperial', label: 'Imperial'),
    ];
    const rotationChoices = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Degrees', label: 'Degrees'),
      BlenderMenuItem<String>(value: 'Radians', label: 'Radians'),
    ];
    const distanceChoices = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'HRTF', label: 'HRTF'),
      BlenderMenuItem<String>(value: 'Inverse', label: 'Inverse'),
      BlenderMenuItem<String>(value: 'Linear', label: 'Linear'),
    ];

    BlenderPropertyDescriptor<List<double>> vectorProperty(
      String id,
      String label,
      List<double> value, {
      double? min,
      double? max,
      double step = .1,
      int decimalDigits = 3,
    }) {
      return BlenderPropertyDescriptor<List<double>>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderVectorField(
          values: value,
          min: min,
          max: max,
          step: step,
          decimalDigits: decimalDigits,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<bool> actionProperty(String id, String label) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: false,
        labelPlacement: BlenderPropertyLabelPlacement.splitColumn,
        editorBuilder: (context, value, onChanged) =>
            BlenderButton(label: label, onPressed: () => _setStatus(label)),
      );
    }

    return <BlenderPropertyGroup>[
      BlenderPropertyFactory.panel(
        'scene-scene',
        'Scene',
        expanded: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'scene-camera',
            'Camera',
            'Camera',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Camera', label: 'Camera'),
              BlenderMenuItem<String>(value: 'Camera.001', label: 'Camera.001'),
            ],
          ),
          BlenderPropertyFactory.choice<String>(
            'scene-background-set',
            'Background Set',
            'None',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'None', label: 'None'),
              ...sceneChoices,
            ],
          ),
          BlenderPropertyFactory.choice<String>(
            'scene-active-clip',
            'Active Clip',
            'None',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'None', label: 'None'),
              BlenderMenuItem<String>(
                value: 'Tracking Clip',
                label: 'Tracking Clip',
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'scene-units',
        'Units',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'scene-unit-system',
            'Unit System',
            'Metric',
            unitChoices,
          ),
          BlenderPropertyFactory.number(
            'scene-scale-length',
            'Scale Length',
            1,
            min: .0001,
            step: .01,
          ),
          BlenderPropertyFactory.boolean(
            'scene-separate-units',
            'Separate Units',
            false,
          ),
          BlenderPropertyFactory.choice<String>(
            'scene-rotation-system',
            'Rotation',
            'Degrees',
            rotationChoices,
          ),
          BlenderPropertyFactory.choice<String>(
            'scene-length-unit',
            'Length',
            'Meters',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Meters', label: 'Meters'),
              BlenderMenuItem<String>(
                value: 'Centimeters',
                label: 'Centimeters',
              ),
            ],
          ),
          BlenderPropertyFactory.choice<String>(
            'scene-mass-unit',
            'Mass',
            'Kilograms',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Kilograms', label: 'Kilograms'),
              BlenderMenuItem<String>(value: 'Grams', label: 'Grams'),
            ],
          ),
          BlenderPropertyFactory.choice<String>(
            'scene-time-unit',
            'Time',
            'Seconds',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Seconds', label: 'Seconds'),
              BlenderMenuItem<String>(value: 'Frames', label: 'Frames'),
            ],
          ),
          BlenderPropertyFactory.choice<String>(
            'scene-temperature-unit',
            'Temperature',
            'Kelvin',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Kelvin', label: 'Kelvin'),
              BlenderMenuItem<String>(value: 'Celsius', label: 'Celsius'),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'scene-keying-sets',
        'Keying Sets',
        children: <BlenderPropertyGroup>[
          BlenderPropertyFactory.panel(
            'scene-keyframing-settings',
            'Keyframing Settings',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'scene-key-needed',
                'Needed',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'scene-key-visual',
                'Visual',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'scene-key-available',
                'Available',
                true,
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'scene-active-keying-set',
            'Active Keying Set',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'scene-key-target',
                'Target ID-Block',
                'Cube',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Cube', label: 'Cube'),
                  BlenderMenuItem<String>(value: 'Camera', label: 'Camera'),
                ],
              ),
              BlenderPropertyFactory.choice<String>(
                'scene-key-data-path',
                'Data Path',
                'Location',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Location', label: 'Location'),
                  BlenderMenuItem<String>(value: 'Rotation', label: 'Rotation'),
                ],
              ),
              BlenderPropertyFactory.boolean(
                'scene-key-array-all',
                'Array All Items',
                true,
              ),
              BlenderPropertyFactory.choice<String>(
                'scene-key-grouping',
                'F-Curve Grouping',
                'Named',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Named', label: 'Named'),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
            ],
          ),
        ],
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'scene-keying-set',
            'Keying Set',
            'Location & Rotation',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Location & Rotation',
                label: 'Location & Rotation',
              ),
              BlenderMenuItem<String>(value: 'Available', label: 'Available'),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'scene-audio',
        'Audio',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'scene-audio-volume',
            'Volume',
            1,
            min: 0,
            max: 2,
          ),
          BlenderPropertyFactory.choice<String>(
            'scene-audio-distance',
            'Distance Model',
            'HRTF',
            distanceChoices,
          ),
          BlenderPropertyFactory.number(
            'scene-audio-doppler-speed',
            'Doppler Speed',
            343,
            min: 0,
          ),
          BlenderPropertyFactory.number(
            'scene-audio-doppler-factor',
            'Doppler Factor',
            1,
            min: 0,
          ),
          actionProperty('scene-audio-bake', 'Bake Animation'),
        ],
      ),
      BlenderPropertyFactory.panel(
        'scene-gravity',
        'Gravity',
        toggle: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          vectorProperty('scene-gravity-vector', 'Gravity', <double>[
            0,
            0,
            -9.81,
          ], step: .01),
        ],
      ),
      BlenderPropertyFactory.panel(
        'scene-simulation',
        'Simulation',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'scene-custom-simulation-range',
            'Simulation Range',
            true,
          ),
          BlenderPropertyFactory.number(
            'scene-simulation-start',
            'Start',
            1,
            min: 0,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.number(
            'scene-simulation-end',
            'End',
            250,
            min: 0,
            decimalDigits: 0,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'scene-rigid-body-world',
        'Rigid Body World',
        toggle: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          actionProperty('scene-rigid-remove', 'Remove'),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyFactory.panel(
            'scene-rigid-body-settings',
            'Settings',
            expanded: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'scene-rigid-collection',
                'Collection',
                'RigidBodyWorld',
                sceneChoices,
              ),
              BlenderPropertyFactory.choice<String>(
                'scene-rigid-constraints',
                'Constraints',
                'RigidBodyConstraints',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'RigidBodyConstraints',
                    label: 'RigidBodyConstraints',
                  ),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
              BlenderPropertyFactory.number(
                'scene-rigid-speed',
                'Speed',
                1,
                min: 0,
                step: .01,
              ),
              BlenderPropertyFactory.boolean(
                'scene-rigid-split-impulse',
                'Split Impulse',
                true,
              ),
              BlenderPropertyFactory.number(
                'scene-rigid-substeps',
                'Substeps Per Frame',
                10,
                min: 1,
                max: 100,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.number(
                'scene-rigid-solver-iterations',
                'Solver Iterations',
                10,
                min: 1,
                max: 100,
                decimalDigits: 0,
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'scene-rigid-cache',
            'Cache',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'scene-rigid-cache-start',
                'Frame Start',
                1,
                min: 0,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.number(
                'scene-rigid-cache-end',
                'End',
                250,
                min: 0,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.choice<String>(
                'scene-rigid-cache-type',
                'Simulation',
                'Replay',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Replay', label: 'Replay'),
                  BlenderMenuItem<String>(value: 'Fixed', label: 'Fixed'),
                ],
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'scene-rigid-field-weights',
            'Field Weights',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'scene-rigid-gravity-weight',
                'Gravity',
                1,
                min: 0,
                max: 1,
              ),
              BlenderPropertyFactory.number(
                'scene-rigid-all-weight',
                'All',
                1,
                min: 0,
                max: 1,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'scene-light-probes',
        'Light Probes',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'scene-probe-resolution',
            'Spheres Resolution',
            '256',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: '64', label: '64'),
              BlenderMenuItem<String>(value: '128', label: '128'),
              BlenderMenuItem<String>(value: '256', label: '256'),
            ],
          ),
          actionProperty('scene-probe-bake', 'Bake All Light Probe Volumes'),
        ],
      ),
      BlenderPropertyFactory.panel(
        'scene-animation',
        'Animation',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'scene-action',
            'Action',
            'SceneAction',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'SceneAction',
                label: 'SceneAction',
              ),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
          BlenderPropertyFactory.choice<String>(
            'scene-slot',
            'Slot',
            'Scene',
            sceneChoices,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'scene-custom-properties',
        'Custom Properties',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'scene-custom-property',
            'example_value',
            1,
            decimalDigits: 2,
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _worldPropertyGroups {
    return <BlenderPropertyGroup>[
      BlenderPropertyFactory.panel(
        'world-surface',
        'Surface',
        expanded: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'world-surface-node',
            'Surface',
            'Background',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Background', label: 'Background'),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'world-volume',
        'Volume',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'world-volume-node',
            'Volume',
            'Principled Volume',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Principled Volume',
                label: 'Principled Volume',
              ),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'world-volume-convert',
            label: 'Convert Volume',
            value: false,
            labelPlacement: BlenderPropertyLabelPlacement.splitColumn,
            editorBuilder: (context, value, onChanged) => BlenderButton(
              label: 'Convert Volume',
              onPressed: () => _setStatus('Convert volume to mesh'),
            ),
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'world-mist',
        'Mist Pass',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number('world-mist-start', 'Start', 5, min: 0),
          BlenderPropertyFactory.number(
            'world-mist-depth',
            'Depth',
            25,
            min: 0,
          ),
          BlenderPropertyFactory.choice<String>(
            'world-mist-falloff',
            'Falloff',
            'Quadratic',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Quadratic', label: 'Quadratic'),
              BlenderMenuItem<String>(value: 'Linear', label: 'Linear'),
              BlenderMenuItem<String>(
                value: 'Inverse Quadratic',
                label: 'Inverse Quadratic',
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'world-settings',
        'Settings',
        children: <BlenderPropertyGroup>[
          BlenderPropertyFactory.panel(
            'world-light-probe',
            'Light Probe',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'world-probe-resolution',
                'Resolution',
                '256',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: '64', label: '64'),
                  BlenderMenuItem<String>(value: '128', label: '128'),
                  BlenderMenuItem<String>(value: '256', label: '256'),
                ],
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'world-sun',
            'Sun',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'world-sun-threshold',
                'Threshold',
                .1,
                min: 0,
              ),
              BlenderPropertyFactory.number(
                'world-sun-angle',
                'Angle',
                .526,
                min: 0,
                max: 3.14,
                step: .01,
              ),
            ],
            children: <BlenderPropertyGroup>[
              BlenderPropertyFactory.panel(
                'world-sun-shadow',
                'Shadow',
                toggle: true,
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.boolean(
                    'world-sun-shadow-jitter',
                    'Jitter',
                    true,
                  ),
                  BlenderPropertyFactory.number(
                    'world-sun-shadow-overblur',
                    'Overblur',
                    .1,
                    min: 0,
                  ),
                  BlenderPropertyFactory.number(
                    'world-sun-shadow-filter',
                    'Filter',
                    3,
                    min: 0,
                  ),
                  BlenderPropertyFactory.number(
                    'world-sun-shadow-resolution',
                    'Resolution Limit',
                    2048,
                    min: 1,
                    decimalDigits: 0,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'world-viewport-display',
        'Viewport Display',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<Color>(
            id: 'world-color',
            label: 'Color',
            value: const Color(0xFF202020),
            editorBuilder: (context, value, onChanged) => BlenderColorField(
              color: value,
              onPressed: () => _setStatus('World color picker opened'),
            ),
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'world-animation',
        'Animation',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'world-action',
            'World',
            'WorldAction',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'WorldAction',
                label: 'WorldAction',
              ),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
          BlenderPropertyFactory.choice<String>(
            'world-node-action',
            'Shader Node Tree',
            'WorldNodes',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'WorldNodes', label: 'WorldNodes'),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'world-custom-properties',
        'Custom Properties',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'world-custom-property',
            'example_value',
            1,
          ),
        ],
      ),
    ];
  }
}
