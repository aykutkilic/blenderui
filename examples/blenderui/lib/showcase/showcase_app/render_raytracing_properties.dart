part of '../showcase_app.dart';

extension _ShowcaseRenderRayTracingProperties on _ShowcaseAppState {
  List<BlenderPropertyGroup> _renderPropertyGroupsRenderRaytracing() {
    return <BlenderPropertyGroup>[
      BlenderPropertyFactory.panel(
        'render-raytracing',
        'Raytracing',
        toggle: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'render-raytracing-method',
            'Method',
            'Screen Tracing',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Screen Tracing',
                label: 'Screen Tracing',
              ),
              BlenderMenuItem<String>(
                value: 'Ray Tracing',
                label: 'Ray Tracing',
              ),
            ],
          ),
          BlenderPropertyFactory.number(
            'render-raytracing-resolution',
            'Resolution',
            100,
            min: 25,
            max: 100,
            suffix: '%',
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyFactory.panel(
            'render-screen-tracing',
            'Screen Tracing',
            expanded: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'render-screen-trace-precision',
                'Precision',
                .5,
                min: 0,
                max: 1,
              ),
              BlenderPropertyFactory.number(
                'render-screen-trace-thickness',
                'Thickness',
                .2,
                min: 0,
                step: .01,
              ),
              BlenderPropertyFactory.boolean(
                'render-screen-trace-backface',
                'Backface',
                true,
              ),
              BlenderPropertyFactory.number(
                'render-screen-trace-radiance',
                'Radiance',
                .5,
                min: 0,
                max: 1,
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'render-fast-gi',
            'Fast GI Approximation',
            toggle: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'render-fast-gi-threshold',
                'Threshold',
                .5,
                min: 0,
                max: 1,
              ),
              BlenderPropertyFactory.choice<String>(
                'render-fast-gi-method',
                'Method',
                'Screen Tracing',
                _renderGiMethods,
              ),
              BlenderPropertyFactory.choice<String>(
                'render-fast-gi-resolution',
                'Resolution',
                'Half',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Full', label: 'Full'),
                  BlenderMenuItem<String>(value: 'Half', label: 'Half'),
                  BlenderMenuItem<String>(value: 'Quarter', label: 'Quarter'),
                ],
              ),
              BlenderPropertyFactory.number(
                'render-fast-gi-rays',
                'Rays',
                4,
                min: 1,
                max: 64,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.number(
                'render-fast-gi-steps',
                'Steps',
                8,
                min: 1,
                max: 64,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.number(
                'render-fast-gi-distance',
                'Distance',
                3,
              ),
              BlenderPropertyFactory.number(
                'render-fast-gi-thickness',
                'Thickness',
                .2,
                min: 0,
                step: .01,
              ),
              BlenderPropertyFactory.number(
                'render-fast-gi-bias',
                'Bias',
                .5,
                min: 0,
                max: 1,
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'render-denoising',
            'Denoising',
            toggle: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'render-denoise-spatial',
                'Spatial',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'render-denoise-temporal',
                'Temporal',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'render-denoise-bilateral',
                'Bilateral',
                true,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'render-volumes',
        'Volumes',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'render-volume-resolution',
            'Resolution',
            '8 px',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: '2 px', label: '2 px'),
              BlenderMenuItem<String>(value: '8 px', label: '8 px'),
              BlenderMenuItem<String>(value: '16 px', label: '16 px'),
            ],
          ),
          BlenderPropertyFactory.number(
            'render-volume-steps',
            'Steps',
            64,
            min: 1,
            max: 1024,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.number(
            'render-volume-distribution',
            'Distribution',
            .5,
            min: 0,
            max: 1,
          ),
          BlenderPropertyFactory.number(
            'render-volume-depth',
            'Max Depth',
            64,
            min: 1,
            max: 1024,
            decimalDigits: 0,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyFactory.panel(
            'render-volume-range',
            'Custom Range',
            toggle: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number('render-volume-start', 'Start', 0),
              BlenderPropertyFactory.number('render-volume-end', 'End', 100),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'render-depth-of-field',
        'Depth of Field',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'render-bokeh-max-size',
            'Max Size',
            10,
            min: 0,
            max: 100,
          ),
          BlenderPropertyFactory.number(
            'render-bokeh-threshold',
            'Threshold',
            1,
            min: 0,
            max: 100,
          ),
          BlenderPropertyFactory.number(
            'render-bokeh-neighbor-max',
            'Neighbor Max',
            10,
            min: 0,
            max: 100,
          ),
          BlenderPropertyFactory.boolean(
            'render-bokeh-jittered',
            'Jitter Camera',
            true,
          ),
          BlenderPropertyFactory.number(
            'render-bokeh-overblur',
            'Overblur',
            0,
            min: 0,
            max: 100,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'render-motion-blur',
        'Motion Blur',
        toggle: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'render-motion-position',
            'Position',
            'Center',
            _renderAxisChoices,
          ),
          BlenderPropertyFactory.number(
            'render-motion-shutter',
            'Shutter',
            .5,
            min: 0,
            max: 2,
          ),
          BlenderPropertyFactory.number(
            'render-motion-depth-scale',
            'Depth Scale',
            1,
            min: 0,
          ),
          BlenderPropertyFactory.number(
            'render-motion-max',
            'Max',
            64,
            min: 1,
            max: 256,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.number(
            'render-motion-steps',
            'Steps',
            2,
            min: 1,
            max: 32,
            decimalDigits: 0,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyFactory.panel(
            'render-shutter-curve',
            'Shutter Curve',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'render-shutter-curve-shape',
                'Preset',
                'Smooth',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Smooth', label: 'Smooth'),
                  BlenderMenuItem<String>(value: 'Round', label: 'Round'),
                  BlenderMenuItem<String>(value: 'Sharp', label: 'Sharp'),
                  BlenderMenuItem<String>(value: 'Linear', label: 'Linear'),
                ],
              ),
            ],
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> _renderPropertyGroupsRenderFilm() {
    return <BlenderPropertyGroup>[
      BlenderPropertyFactory.panel(
        'render-film',
        'Film',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'render-filter-size',
            'Filter Size',
            1.5,
            min: 0,
            max: 20,
          ),
          BlenderPropertyFactory.boolean(
            'render-film-transparent',
            'Transparent',
            false,
          ),
          BlenderPropertyFactory.boolean('render-overscan', 'Overscan', false),
          BlenderPropertyFactory.number(
            'render-overscan-size',
            'Size',
            3,
            min: 0,
            max: 100,
            suffix: '%',
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'render-curves',
        'Curves',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'render-curves-shape',
            'Shape',
            '3D Curves',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: '3D Curves', label: '3D Curves'),
              BlenderMenuItem<String>(value: '2D Curves', label: '2D Curves'),
            ],
          ),
          BlenderPropertyFactory.number(
            'render-curves-subdivision',
            'Subdivision',
            2,
            min: 0,
            max: 10,
            decimalDigits: 0,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'render-performance',
        'Performance',
        children: <BlenderPropertyGroup>[
          BlenderPropertyFactory.panel(
            'render-performance-memory',
            'Memory',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'render-shadow-pool',
                'Shadow Pool',
                512,
                min: 0,
                suffix: ' MB',
              ),
              BlenderPropertyFactory.number(
                'render-probe-pool',
                'Light Probes Volume Pool',
                256,
                min: 0,
                suffix: ' MB',
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'render-performance-viewport',
            'Viewport',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'render-preview-pixel-size',
                'Pixel Size',
                1,
                min: 1,
                max: 64,
                decimalDigits: 0,
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'render-performance-compositor',
            'Compositor',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'render-compositor-device',
                'Device',
                'CPU',
                _renderDeviceChoices,
              ),
              BlenderPropertyFactory.choice<String>(
                'render-compositor-precision',
                'Precision',
                'Full',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Full', label: 'Full'),
                  BlenderMenuItem<String>(value: 'Half', label: 'Half'),
                ],
              ),
            ],
            children: <BlenderPropertyGroup>[
              BlenderPropertyFactory.panel(
                'render-performance-denoise',
                'Denoise Nodes',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.choice<String>(
                    'render-denoise-device',
                    'Denoising Device',
                    'CPU',
                    _renderDeviceChoices,
                  ),
                  BlenderPropertyFactory.choice<String>(
                    'render-denoise-preview-quality',
                    'Preview Quality',
                    'Fast',
                    const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'Fast', label: 'Fast'),
                      BlenderMenuItem<String>(
                        value: 'Accurate',
                        label: 'Accurate',
                      ),
                    ],
                  ),
                  BlenderPropertyFactory.choice<String>(
                    'render-denoise-final-quality',
                    'Final Quality',
                    'High',
                    const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'High', label: 'High'),
                      BlenderMenuItem<String>(value: 'Low', label: 'Low'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'render-grease-pencil',
        'Grease Pencil',
        children: <BlenderPropertyGroup>[
          BlenderPropertyFactory.panel(
            'render-grease-pencil-viewport',
            'Viewport',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'render-gp-smaa-viewport',
                'SMAA Threshold',
                .1,
                min: 0,
                max: 1,
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'render-grease-pencil-render',
            'Render',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'render-gp-smaa-render',
                'SMAA Threshold',
                .1,
                min: 0,
                max: 1,
              ),
              BlenderPropertyFactory.number(
                'render-gp-ssaa-samples',
                'SSAA Samples',
                8,
                min: 1,
                max: 64,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.number(
                'render-gp-motion-steps',
                'Motion Blur Steps',
                4,
                min: 1,
                max: 32,
                decimalDigits: 0,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'render-simplify',
        'Simplify',
        toggle: true,
        children: <BlenderPropertyGroup>[
          BlenderPropertyFactory.panel(
            'render-simplify-viewport',
            'Viewport',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'render-simplify-subdivision',
                'Max Subdivision',
                2,
                min: 0,
                max: 12,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.number(
                'render-simplify-particles',
                'Max Child Particles',
                1,
                min: 0,
                max: 100000,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.number(
                'render-simplify-volumes',
                'Volume Resolution',
                1,
                min: 0,
                max: 100,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.boolean(
                'render-simplify-normals',
                'Normals',
                true,
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'render-simplify-render',
            'Render',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'render-simplify-render-subdivision',
                'Max Subdivision',
                2,
                min: 0,
                max: 12,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.number(
                'render-simplify-render-particles',
                'Max Child Particles',
                1,
                min: 0,
                max: 100000,
                decimalDigits: 0,
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'render-simplify-grease-pencil',
            'Grease Pencil',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'render-simplify-gp',
                'Simplify Grease Pencil',
                true,
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
