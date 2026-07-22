part of '../showcase_app.dart';

extension _ShowcaseRenderProperties on _ShowcaseAppState {
  List<BlenderPropertyGroup> get _workbenchRenderPropertyGroups {
    const aaChoices = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: '2', label: '2'),
      BlenderMenuItem<String>(value: '4', label: '4'),
      BlenderMenuItem<String>(value: '8', label: '8'),
      BlenderMenuItem<String>(value: '16', label: '16'),
    ];
    const lightingChoices = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Studio', label: 'Studio'),
      BlenderMenuItem<String>(value: 'Matcap', label: 'Matcap'),
      BlenderMenuItem<String>(value: 'Flat', label: 'Flat'),
    ];
    const colorChoices = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Material', label: 'Material'),
      BlenderMenuItem<String>(value: 'Object', label: 'Object'),
      BlenderMenuItem<String>(value: 'Random', label: 'Random'),
      BlenderMenuItem<String>(value: 'Texture', label: 'Texture'),
    ];

    return <BlenderPropertyGroup>[
      BlenderPropertyFactory.panel(
        'workbench-sampling',
        'Sampling',
        expanded: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'workbench-render-aa',
            'Render',
            '8',
            aaChoices,
          ),
          BlenderPropertyFactory.choice<String>(
            'workbench-viewport-aa',
            'Viewport',
            '8',
            aaChoices,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'workbench-film',
        'Film',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'workbench-transparent',
            'Transparent',
            false,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'workbench-lighting',
        'Lighting',
        expanded: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'workbench-lighting-type',
            'Lighting',
            'Studio',
            lightingChoices,
          ),
          BlenderPropertyFactory.choice<String>(
            'workbench-studio-light',
            'Studio Light',
            'Basic.sl',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem(value: 'Basic.sl', label: 'Basic.sl'),
              BlenderMenuItem(value: 'Paint.sl', label: 'Paint.sl'),
            ],
          ),
          BlenderPropertyFactory.boolean(
            'workbench-world-lighting',
            'World Space Lighting',
            false,
          ),
          BlenderPropertyFactory.number(
            'workbench-light-rotation',
            'Rotation',
            0,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'workbench-color',
        'Object Color',
        expanded: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'workbench-color-type',
            'Color Type',
            'Material',
            colorChoices,
          ),
          BlenderPropertyFactory.choice<String>(
            'workbench-background-type',
            'Background',
            'Theme',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem(value: 'Theme', label: 'Theme'),
              BlenderMenuItem(value: 'World', label: 'World'),
              BlenderMenuItem(value: 'Viewport', label: 'Viewport'),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'workbench-options',
        'Options',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'workbench-backface-culling',
            'Backface Culling',
            false,
          ),
          BlenderPropertyFactory.boolean('workbench-outline', 'Outline', true),
          BlenderPropertyFactory.boolean('workbench-xray', 'X-Ray', false),
          BlenderPropertyFactory.boolean('workbench-shadows', 'Shadows', true),
          BlenderPropertyFactory.boolean(
            'workbench-depth-of-field',
            'Depth of Field',
            false,
          ),
          BlenderPropertyFactory.boolean('workbench-cavity', 'Cavity', true),
          BlenderPropertyFactory.number(
            'workbench-shadow-direction',
            'Shadow Direction',
            0,
          ),
          BlenderPropertyFactory.number(
            'workbench-shadow-focus',
            'Shadow Focus',
            .5,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'workbench-simplify',
        'Simplify',
        children: <BlenderPropertyGroup>[
          BlenderPropertyFactory.panel(
            'workbench-simplify-viewport',
            'Viewport',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'workbench-simplify-subdivision',
                'Max Subdivision',
                2,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.number(
                'workbench-simplify-particles',
                'Max Child Particles',
                1,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.number(
                'workbench-simplify-volumes',
                'Volume Resolution',
                1,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.boolean(
                'workbench-simplify-normals',
                'Normals',
                true,
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'workbench-simplify-render',
            'Render',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'workbench-simplify-render-subdivision',
                'Max Subdivision',
                2,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.number(
                'workbench-simplify-render-particles',
                'Max Child Particles',
                1,
                decimalDigits: 0,
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'workbench-simplify-grease-pencil',
            'Grease Pencil',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'workbench-simplify-gp',
                'Simplify Grease Pencil',
                0,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'workbench-color-management',
        'Color Management',
        children: <BlenderPropertyGroup>[
          BlenderPropertyFactory.panel(
            'workbench-color-working-space',
            'Working Space',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'workbench-working-file',
                'File',
                'sRGB',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem(value: 'sRGB', label: 'sRGB'),
                  BlenderMenuItem(value: 'Rec.709', label: 'Rec.709'),
                ],
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'workbench-color-advanced',
            'Advanced',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'workbench-emulation',
                'Emulation',
                false,
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'workbench-color-curves',
            'Curves',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'workbench-color-curves-enabled',
                'Use Curve Mapping',
                false,
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'workbench-color-white-balance',
            'White Balance',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'workbench-white-temperature',
                'Temperature',
                6500,
              ),
              BlenderPropertyFactory.number('workbench-white-tint', 'Tint', 10),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'workbench-freestyle',
        'Freestyle',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'workbench-freestyle-enable',
            'Enable Freestyle',
            false,
          ),
        ],
      ),
    ];
  }

  List<BlenderMenuItem<String>> get _renderAxisChoices =>
      const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Center', label: 'Center'),
        BlenderMenuItem<String>(value: 'Start', label: 'Start'),
        BlenderMenuItem<String>(value: 'End', label: 'End'),
      ];

  List<BlenderMenuItem<String>> get _renderDeviceChoices =>
      const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'CPU', label: 'CPU'),
        BlenderMenuItem<String>(value: 'GPU', label: 'GPU'),
      ];

  List<BlenderMenuItem<String>> get _renderGiMethods =>
      const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(
          value: 'Screen Tracing',
          label: 'Screen Tracing',
        ),
        BlenderMenuItem<String>(value: 'Ray Tracing', label: 'Ray Tracing'),
      ];

  List<BlenderPropertyGroup> get _renderPropertyGroups {
    if (_renderEngine == 'Workbench') {
      return _workbenchRenderPropertyGroups;
    }

    return <BlenderPropertyGroup>[
      ..._renderPropertyGroupsRenderSampling(),
      ..._renderPropertyGroupsRenderRaytracing(),
      ..._renderPropertyGroupsRenderFilm(),
      ..._renderPropertyGroupsRenderColorManagement(),
    ];
  }

  List<BlenderPropertyGroup> _renderPropertyGroupsRenderSampling() {
    return <BlenderPropertyGroup>[
      BlenderPropertyFactory.panel(
        'render-sampling',
        'Sampling',
        expanded: true,
        children: <BlenderPropertyGroup>[
          BlenderPropertyFactory.panel(
            'render-sampling-viewport',
            'Viewport',
            expanded: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'render-taa-samples',
                'Samples',
                64,
                min: 1,
                max: 4096,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.boolean(
                'render-temporal-reprojection',
                'Temporal Reprojection',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'render-jittered-shadows',
                'Jittered Shadows',
                true,
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'render-sampling-render',
            'Render',
            expanded: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'render-samples',
                'Samples',
                64,
                min: 1,
                max: 4096,
                decimalDigits: 0,
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'render-sampling-shadows',
            'Shadows',
            toggle: true,
            expanded: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'render-shadow-rays',
                'Rays',
                1,
                min: 1,
                max: 128,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.number(
                'render-shadow-steps',
                'Steps',
                4,
                min: 1,
                max: 64,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.boolean(
                'render-volume-shadows',
                'Volume Shadows',
                true,
              ),
              BlenderPropertyFactory.number(
                'render-volume-shadow-steps',
                'Steps',
                4,
                min: 1,
                max: 64,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.number(
                'render-shadow-resolution',
                'Resolution',
                .763,
                min: 0,
                max: 1,
                step: .01,
                decimalDigits: 3,
                showSteppers: false,
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'render-sampling-advanced',
            'Advanced',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'render-light-threshold',
                'Light Threshold',
                .01,
                min: 0,
                step: .01,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'render-light-paths',
        'Light Paths',
        children: <BlenderPropertyGroup>[
          BlenderPropertyFactory.panel(
            'render-clamping',
            'Clamping',
            children: <BlenderPropertyGroup>[
              BlenderPropertyFactory.panel(
                'render-clamping-surface',
                'Surface',
                expanded: true,
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.number(
                    'render-clamp-surface-direct',
                    'Direct Light',
                    10,
                  ),
                  BlenderPropertyFactory.number(
                    'render-clamp-surface-indirect',
                    'Indirect Light',
                    10,
                  ),
                ],
              ),
              BlenderPropertyFactory.panel(
                'render-clamping-volume',
                'Volume',
                expanded: true,
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.number(
                    'render-clamp-volume-direct',
                    'Direct Light',
                    10,
                  ),
                  BlenderPropertyFactory.number(
                    'render-clamp-volume-indirect',
                    'Indirect Light',
                    10,
                  ),
                ],
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'render-light-path-intensity',
            'Intensity',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'render-direct-intensity',
                'Direct Light',
                1,
              ),
              BlenderPropertyFactory.number(
                'render-indirect-intensity',
                'Indirect Light',
                1,
              ),
            ],
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> _renderPropertyGroupsRenderColorManagement() {
    return <BlenderPropertyGroup>[
      BlenderPropertyFactory.panel(
        'render-color-management',
        'Color Management',
        children: <BlenderPropertyGroup>[
          BlenderPropertyFactory.panel(
            'render-color-working-space',
            'Working Space',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'render-working-file',
                'File',
                'sRGB',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'sRGB', label: 'sRGB'),
                  BlenderMenuItem<String>(value: 'ACEScg', label: 'ACEScg'),
                ],
              ),
              BlenderPropertyFactory.choice<String>(
                'render-working-sequencer',
                'Sequencer',
                'sRGB',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'sRGB', label: 'sRGB'),
                  BlenderMenuItem<String>(value: 'Linear', label: 'Linear'),
                ],
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'render-color-advanced',
            'Advanced',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'render-color-emulation',
                'Emulation',
                'sRGB',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'sRGB', label: 'sRGB'),
                  BlenderMenuItem<String>(
                    value: 'Display P3',
                    label: 'Display P3',
                  ),
                ],
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'render-color-curves',
            'Curves',
            toggle: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'render-color-curve-mapping',
                'Use Curve Mapping',
                true,
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'render-color-white-balance',
            'White Balance',
            toggle: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'render-white-temperature',
                'Temperature',
                6500,
                min: 1000,
                max: 20000,
                decimalDigits: 0,
                suffix: ' K',
              ),
              BlenderPropertyFactory.number(
                'render-white-tint',
                'Tint',
                10,
                min: -100,
                max: 100,
              ),
            ],
          ),
        ],
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'render-display-device',
            'Display Device',
            'sRGB',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'sRGB', label: 'sRGB'),
              BlenderMenuItem<String>(value: 'Display P3', label: 'Display P3'),
            ],
          ),
          BlenderPropertyFactory.choice<String>(
            'render-view-transform',
            'View Transform',
            'AgX',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'AgX', label: 'AgX'),
              BlenderMenuItem<String>(value: 'Standard', label: 'Standard'),
            ],
          ),
          BlenderPropertyFactory.choice<String>(
            'render-look',
            'Look',
            'None',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'None', label: 'None'),
              BlenderMenuItem<String>(
                value: 'Medium High Contrast',
                label: 'Medium High Contrast',
              ),
            ],
          ),
          BlenderPropertyFactory.number(
            'render-exposure',
            'Exposure',
            0,
            min: -10,
            max: 10,
          ),
          BlenderPropertyFactory.number(
            'render-gamma',
            'Gamma',
            1,
            min: .1,
            max: 5,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'render-freestyle',
        'Freestyle',
        toggle: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'freestyle-line-thickness-mode',
            'Line Thickness Mode',
            'Absolute',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Absolute', label: 'Absolute'),
              BlenderMenuItem<String>(value: 'Relative', label: 'Relative'),
            ],
          ),
          BlenderPropertyFactory.number(
            'freestyle-line-thickness',
            'Line Thickness',
            1,
            min: 0,
            max: 10,
          ),
        ],
      ),
    ];
  }
}
