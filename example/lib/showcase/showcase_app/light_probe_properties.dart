part of '../showcase_app.dart';

extension _ShowcaseLightProbeProperties on _ShowcaseAppState {
  List<BlenderPropertyGroup> get _lightProbePropertyGroups {
    const probeTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Volume', label: 'Volume'),
      BlenderMenuItem<String>(value: 'Sphere', label: 'Sphere'),
      BlenderMenuItem<String>(value: 'Plane', label: 'Plane'),
    ];
    const influenceTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Box', label: 'Box'),
      BlenderMenuItem<String>(value: 'Ellipsoid', label: 'Ellipsoid'),
    ];
    const parallaxTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Box', label: 'Box'),
      BlenderMenuItem<String>(value: 'Ellipsoid', label: 'Ellipsoid'),
    ];

    Widget actionRow() => Row(
      children: <Widget>[
        Expanded(
          child: BlenderButton(
            label: 'Bake Probe',
            onPressed: () => _setStatus('Bake probe'),
          ),
        ),
        const SizedBox(width: 4),
        BlenderIconButton(
          glyph: BlenderGlyph.deleteIcon,
          onPressed: () => _setStatus('Free probe bake'),
          tooltip: 'Free probe bake',
          size: 24,
        ),
      ],
    );

    Widget animation(String label) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(label, style: BlenderTheme.of(context).textTheme.caption),
        const SizedBox(height: 4),
        BlenderDataBlockField<String>(
          value: '${label}Action',
          icon: BlenderGlyph.action,
          items: <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(
              value: '${label}Action',
              label: '${label}Action',
            ),
            const BlenderMenuItem<String>(value: 'None', label: 'None'),
          ],
          onChanged: (value) => _setStatus('$label action: $value'),
        ),
      ],
    );

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'light-probe-probe',
        title: 'Probe',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'light-probe-type',
            'Type',
            'Volume',
            probeTypes,
          ),
          BlenderPropertyFactory.choice<String>(
            'light-probe-influence-type',
            'Influence Type',
            'Box',
            influenceTypes,
          ),
          BlenderPropertyFactory.number(
            'light-probe-distance',
            'Distance',
            10,
            min: 0,
          ),
          BlenderPropertyFactory.number(
            'light-probe-falloff',
            'Falloff',
            1,
            min: 0,
          ),
          BlenderPropertyFactory.number(
            'light-probe-intensity',
            'Intensity',
            1,
            min: 0,
          ),
          BlenderPropertyFactory.number(
            'light-probe-resolution-x',
            'Resolution X',
            32,
            min: 1,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.number(
            'light-probe-resolution-y',
            'Y',
            32,
            min: 1,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.number(
            'light-probe-resolution-z',
            'Z',
            32,
            min: 1,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.number(
            'light-probe-clipping-start',
            'Clipping Start',
            .1,
          ),
          BlenderPropertyFactory.number('light-probe-clipping-end', 'End', 40),
          BlenderPropertyFactory.number(
            'light-probe-normal-bias',
            'Normal Bias',
            .6,
          ),
          BlenderPropertyFactory.number(
            'light-probe-view-bias',
            'View Bias',
            .8,
          ),
          BlenderPropertyFactory.number(
            'light-probe-facing-bias',
            'Facing Bias',
            .5,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'light-probe-visibility',
            title: 'Visibility',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'light-probe-visibility-bias',
                'Bias',
                .05,
              ),
              BlenderPropertyFactory.number(
                'light-probe-visibility-bleed-bias',
                'Bleed Bias',
                .2,
              ),
              BlenderPropertyFactory.number(
                'light-probe-visibility-blur',
                'Blur',
                .1,
              ),
              BlenderPropertyDescriptor<String>(
                id: 'light-probe-visibility-collection',
                label: 'Collection',
                value: 'Collection',
                editorBuilder: (context, value, onChanged) =>
                    BlenderDataBlockField<String>(
                      value: value,
                      icon: BlenderGlyph.collection,
                      items: const <BlenderMenuItem<String>>[
                        BlenderMenuItem<String>(
                          value: 'Collection',
                          label: 'Collection',
                        ),
                        BlenderMenuItem<String>(value: 'None', label: 'None'),
                      ],
                      onChanged: onChanged,
                    ),
                onChanged: (_) => _setStatus('Visibility collection changed'),
              ),
              BlenderPropertyFactory.boolean(
                'light-probe-invert-visibility',
                'Invert Visibility',
                false,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'light-probe-capture',
        title: 'Capture',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'light-probe-capture-start',
            'Clipping Start',
            .1,
          ),
          BlenderPropertyFactory.number('light-probe-capture-end', 'End', 40),
        ],
      ),
      BlenderPropertyGroup(
        id: 'light-probe-bake',
        title: 'Bake',
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: actionRow(),
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'light-probe-bake-resolution',
            title: 'Resolution',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'light-probe-bake-resolution-x',
                'Resolution X',
                32,
                min: 1,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.number(
                'light-probe-bake-resolution-y',
                'Y',
                32,
                min: 1,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.number(
                'light-probe-bake-resolution-z',
                'Z',
                32,
                min: 1,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.number(
                'light-probe-bake-samples',
                'Bake Samples',
                128,
                min: 1,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.number(
                'light-probe-bake-surfel-density',
                'Surfel Density',
                8,
                min: 0,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'light-probe-bake-capture',
            title: 'Capture',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'light-probe-capture-distance',
                'Distance',
                20,
                min: 0,
              ),
              BlenderPropertyFactory.boolean(
                'light-probe-capture-world',
                'World',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'light-probe-capture-indirect',
                'Indirect Light',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'light-probe-capture-emission',
                'Emission',
                true,
              ),
            ],
            children: <BlenderPropertyGroup>[
              BlenderPropertyGroup(
                id: 'light-probe-bake-offset',
                title: 'Offset',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.number(
                    'light-probe-surface-bias',
                    'Surface Bias',
                    .1,
                  ),
                  BlenderPropertyFactory.number(
                    'light-probe-escape-bias',
                    'Escape Bias',
                    .1,
                  ),
                ],
              ),
              BlenderPropertyGroup(
                id: 'light-probe-bake-clamping',
                title: 'Clamping',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.number(
                    'light-probe-clamp-direct',
                    'Direct Light',
                    0,
                    min: 0,
                  ),
                  BlenderPropertyFactory.number(
                    'light-probe-clamp-indirect',
                    'Indirect Light',
                    10,
                    min: 0,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'light-probe-parallax',
        title: 'Custom Parallax',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'light-probe-use-parallax',
            'Use Custom Parallax',
            true,
          ),
          BlenderPropertyFactory.choice<String>(
            'light-probe-parallax-type',
            'Type',
            'Box',
            parallaxTypes,
          ),
          BlenderPropertyFactory.number(
            'light-probe-parallax-distance',
            'Size',
            10,
            min: 0,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'light-probe-display',
        title: 'Viewport Display',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean('light-probe-show-data', 'Data', true),
          BlenderPropertyFactory.number(
            'light-probe-display-size',
            'Size',
            1,
            min: 0,
          ),
          BlenderPropertyFactory.boolean(
            'light-probe-show-clip',
            'Clipping',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'light-probe-show-influence',
            'Influence',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'light-probe-show-parallax',
            'Parallax',
            true,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'light-probe-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: animation('Light Probe'),
      ),
      BlenderPropertyGroup(
        id: 'light-probe-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'light-probe-custom-property',
            'example_value',
            1,
          ),
        ],
      ),
    ];
  }
}
