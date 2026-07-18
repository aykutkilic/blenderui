part of '../showcase_app.dart';

extension _ShowcaseFreestyleProperties on _ShowcaseAppState {
  List<BlenderPropertyGroup> _viewLayerPropertyGroupsFreestyleStrokes() {
    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'freestyle-strokes',
        title: 'Freestyle Strokes',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'freestyle-strokes-caps',
            'Caps',
            'Butt',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Butt', label: 'Butt'),
              BlenderMenuItem<String>(value: 'Round', label: 'Round'),
              BlenderMenuItem<String>(value: 'Square', label: 'Square'),
            ],
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'freestyle-strokes-chaining',
            title: 'Chaining',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'freestyle-use-chaining',
                'Use Chaining',
                true,
              ),
              BlenderPropertyFactory.choice<String>(
                'freestyle-chaining-method',
                'Method',
                'Plain',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Plain', label: 'Plain'),
                  BlenderMenuItem<String>(value: 'Sketchy', label: 'Sketchy'),
                ],
              ),
              BlenderPropertyFactory.number(
                'freestyle-chaining-rounds',
                'Rounds',
                3,
                min: 1,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.boolean(
                'freestyle-chaining-same-object',
                'Same Object',
                true,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'freestyle-strokes-splitting',
            title: 'Splitting',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'freestyle-min-2d-angle',
                'Min 2D Angle',
                0.1,
                min: 0,
                decimalDigits: 2,
              ),
              BlenderPropertyFactory.number(
                'freestyle-max-2d-angle',
                'Max 2D Angle',
                1.5,
                min: 0,
                decimalDigits: 2,
              ),
              BlenderPropertyFactory.number(
                'freestyle-2d-length',
                '2D Length',
                10,
                min: 0,
                decimalDigits: 1,
              ),
              BlenderPropertyFactory.boolean(
                'freestyle-material-boundary-split',
                'Material Boundary',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'freestyle-split-pattern',
                'Split Pattern',
                false,
              ),
              BlenderPropertyFactory.number(
                'freestyle-split-dash-1',
                'Dash 1',
                1,
                min: 0,
                decimalDigits: 1,
              ),
              BlenderPropertyFactory.number(
                'freestyle-split-gap-1',
                'Gap 1',
                1,
                min: 0,
                decimalDigits: 1,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'freestyle-strokes-sorting',
            title: 'Sorting',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'freestyle-use-sorting',
                'Use Sorting',
                false,
              ),
              BlenderPropertyFactory.choice<String>(
                'freestyle-sort-key',
                'Sort Key',
                'Distance from Camera',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Distance from Camera',
                    label: 'Distance from Camera',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Projected X',
                    label: 'Projected X',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Projected Y',
                    label: 'Projected Y',
                  ),
                ],
              ),
              BlenderPropertyFactory.choice<String>(
                'freestyle-integration-type',
                'Integration Type',
                'Mean',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Mean', label: 'Mean'),
                  BlenderMenuItem<String>(value: 'Min', label: 'Min'),
                  BlenderMenuItem<String>(value: 'Max', label: 'Max'),
                ],
              ),
              BlenderPropertyFactory.choice<String>(
                'freestyle-sort-order',
                'Sort Order',
                'Ascending',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Ascending',
                    label: 'Ascending',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Descending',
                    label: 'Descending',
                  ),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'freestyle-strokes-selection',
            title: 'Selection',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'freestyle-min-2d-length',
                'Min 2D Length',
                0,
                min: 0,
                decimalDigits: 1,
              ),
              BlenderPropertyFactory.number(
                'freestyle-max-2d-length',
                'Max 2D Length',
                100,
                min: 0,
                decimalDigits: 1,
              ),
              BlenderPropertyFactory.number(
                'freestyle-chain-count',
                'Chain Count',
                1,
                min: 0,
                decimalDigits: 0,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'freestyle-strokes-dashed-line',
            title: 'Dashed Line',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'freestyle-use-dashed-line',
                'Use Dashed Line',
                false,
              ),
              BlenderPropertyFactory.number(
                'freestyle-dash-1',
                'Dash 1',
                1,
                min: 0,
                decimalDigits: 1,
              ),
              BlenderPropertyFactory.number(
                'freestyle-dash-2',
                'Dash 2',
                1,
                min: 0,
                decimalDigits: 1,
              ),
              BlenderPropertyFactory.number(
                'freestyle-dash-3',
                'Dash 3',
                1,
                min: 0,
                decimalDigits: 1,
              ),
              BlenderPropertyFactory.number(
                'freestyle-gap-1',
                'Gap 1',
                1,
                min: 0,
                decimalDigits: 1,
              ),
              BlenderPropertyFactory.number(
                'freestyle-gap-2',
                'Gap 2',
                1,
                min: 0,
                decimalDigits: 1,
              ),
              BlenderPropertyFactory.number(
                'freestyle-gap-3',
                'Gap 3',
                1,
                min: 0,
                decimalDigits: 1,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'freestyle-color',
        title: 'Freestyle Color',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'freestyle-color-target',
            'Target',
            'Material',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Material', label: 'Material'),
              BlenderMenuItem<String>(value: 'Line Style', label: 'Line Style'),
              BlenderMenuItem<String>(value: 'Random', label: 'Random'),
            ],
          ),
          BlenderPropertyFactory.boolean(
            'freestyle-color-material',
            'Material',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'freestyle-color-random',
            'Random',
            false,
          ),
          BlenderPropertyFactory.boolean(
            'freestyle-color-ramp',
            'Use Color Ramp',
            false,
          ),
          BlenderPropertyFactory.number(
            'freestyle-color-amplitude',
            'Amplitude',
            1,
            min: 0,
            decimalDigits: 2,
          ),
          BlenderPropertyFactory.number(
            'freestyle-color-period',
            'Period',
            1,
            min: 0,
            decimalDigits: 2,
          ),
          BlenderPropertyFactory.number(
            'freestyle-color-seed',
            'Seed',
            0,
            min: 0,
            decimalDigits: 0,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'freestyle-alpha',
        title: 'Freestyle Alpha',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'freestyle-alpha-base',
            'Base Transparency',
            1,
            min: 0,
            max: 1,
            decimalDigits: 2,
          ),
        ],
        content: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: BlenderButton(
            label: 'Add Modifier',
            leading: const BlenderIcon(BlenderGlyph.plus, size: 14),
            onPressed: () => _setStatus('Add alpha modifier'),
            width: double.infinity,
          ),
        ),
      ),
    ];
  }

  List<BlenderPropertyGroup> _viewLayerPropertyGroupsFreestyleThickness() {
    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'freestyle-thickness',
        title: 'Freestyle Thickness',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'freestyle-thickness-value',
            'Thickness',
            1,
            min: 0,
          ),
          BlenderPropertyFactory.boolean(
            'freestyle-thickness-material',
            'Material',
            false,
          ),
          BlenderPropertyFactory.choice<String>(
            'freestyle-thickness-position',
            'Position',
            'Center',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Center', label: 'Center'),
              BlenderMenuItem<String>(value: 'Inside', label: 'Inside'),
              BlenderMenuItem<String>(value: 'Outside', label: 'Outside'),
            ],
          ),
          BlenderPropertyFactory.number(
            'freestyle-thickness-ratio',
            'Ratio',
            0.5,
            min: 0,
            max: 1,
            decimalDigits: 2,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'freestyle-geometry',
        title: 'Freestyle Geometry',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'freestyle-geometry-target',
            'Target',
            'Sampling',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Sampling', label: 'Sampling'),
              BlenderMenuItem<String>(
                value: 'Displacement',
                label: 'Displacement',
              ),
              BlenderMenuItem<String>(
                value: 'Guiding Lines',
                label: 'Guiding Lines',
              ),
            ],
          ),
          BlenderPropertyFactory.number(
            'freestyle-geometry-sampling',
            'Sampling',
            1,
            min: 0,
            decimalDigits: 2,
          ),
          BlenderPropertyFactory.number(
            'freestyle-geometry-error',
            'Error',
            0.1,
            min: 0,
            decimalDigits: 2,
          ),
          BlenderPropertyFactory.number(
            'freestyle-geometry-wavelength',
            'Wavelength',
            1,
            min: 0,
            decimalDigits: 2,
          ),
          BlenderPropertyFactory.number(
            'freestyle-geometry-amplitude',
            'Amplitude',
            1,
            min: 0,
            decimalDigits: 2,
          ),
          BlenderPropertyFactory.number(
            'freestyle-geometry-frequency',
            'Frequency',
            1,
            min: 0,
            decimalDigits: 2,
          ),
          BlenderPropertyFactory.number(
            'freestyle-geometry-angle',
            'Angle',
            0,
            min: 0,
            decimalDigits: 2,
          ),
          BlenderPropertyFactory.number(
            'freestyle-geometry-backbone-length',
            'Backbone Length',
            1,
            min: 0,
            decimalDigits: 2,
          ),
          BlenderPropertyFactory.number(
            'freestyle-geometry-tip-length',
            'Tip Length',
            1,
            min: 0,
            decimalDigits: 2,
          ),
          BlenderPropertyFactory.choice<String>(
            'freestyle-geometry-shape',
            'Shape',
            'Circle',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Circle', label: 'Circle'),
              BlenderMenuItem<String>(value: 'Square', label: 'Square'),
            ],
          ),
          BlenderPropertyFactory.boolean(
            'freestyle-geometry-pure-random',
            'Pure Random',
            false,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'freestyle-texture',
        title: 'Freestyle Texture',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'freestyle-texture-use-nodes',
            'Use Nodes',
            false,
          ),
          BlenderPropertyFactory.number(
            'freestyle-texture-spacing',
            'Spacing Along Stroke',
            1,
            min: 0,
            decimalDigits: 2,
          ),
          BlenderPropertyFactory.choice<String>(
            'freestyle-texture-slot',
            'Texture',
            'None',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'None', label: 'None'),
              BlenderMenuItem<String>(
                value: 'Line Texture',
                label: 'Line Texture',
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'freestyle-animation',
        title: 'Freestyle Animation',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'freestyle-animation-action',
            'Action',
            'FreestyleAction',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'FreestyleAction',
                label: 'FreestyleAction',
              ),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
          BlenderPropertyFactory.choice<String>(
            'freestyle-animation-slot',
            'Slot',
            'Slot 1',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Slot 1', label: 'Slot 1'),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'view-layer-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'view-layer-custom-property',
            'example_value',
            1,
            decimalDigits: 2,
          ),
        ],
      ),
    ];
  }
}
