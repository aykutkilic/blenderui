part of '../showcase_app.dart';

extension _ShowcaseCurveProperties on _ShowcaseAppState {
  List<BlenderPropertyGroup> get _curvePropertyGroups {
    const dimensions = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: '2D', label: '2D'),
      BlenderMenuItem<String>(value: '3D', label: '3D'),
    ];
    const twistModes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Z-Up', label: 'Z-Up'),
      BlenderMenuItem<String>(value: 'Minimum', label: 'Minimum'),
      BlenderMenuItem<String>(value: 'Tangent', label: 'Tangent'),
    ];
    const fillModes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Half', label: 'Half'),
      BlenderMenuItem<String>(value: 'Full', label: 'Full'),
      BlenderMenuItem<String>(value: 'Front', label: 'Front'),
      BlenderMenuItem<String>(value: 'Back', label: 'Back'),
    ];
    const bevelModes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Round', label: 'Round'),
      BlenderMenuItem<String>(value: 'Object', label: 'Object'),
      BlenderMenuItem<String>(value: 'Profile', label: 'Profile'),
    ];

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'curve-shape',
        title: 'Shape',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'curve-dimensions',
            'Dimensions',
            '3D',
            dimensions,
          ),
          BlenderPropertyFactory.number(
            'curve-resolution-preview',
            'Resolution Preview U',
            12,
            min: 1,
            max: 64,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.number(
            'curve-resolution-render',
            'Render U',
            24,
            min: 1,
            max: 64,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.choice<String>(
            'curve-twist-mode',
            'Twist Mode',
            'Z-Up',
            twistModes,
          ),
          BlenderPropertyFactory.number(
            'curve-twist-smooth',
            'Smooth',
            12,
            min: 0,
            max: 32,
          ),
          BlenderPropertyFactory.choice<String>(
            'curve-fill-mode',
            'Fill Mode',
            'Half',
            fillModes,
          ),
          BlenderPropertyFactory.choice<String>(
            'curve-fill-solver',
            'Fill Solver',
            'Even Offset',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Even Offset',
                label: 'Even Offset',
              ),
              BlenderMenuItem<String>(value: 'CDT', label: 'CDT'),
            ],
          ),
          BlenderPropertyFactory.choice<String>(
            'curve-fill-rule',
            'Fill Rule',
            'Even Odd',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Even Odd', label: 'Even Odd'),
              BlenderMenuItem<String>(value: 'Non Zero', label: 'Non Zero'),
            ],
          ),
          BlenderPropertyFactory.boolean(
            'curve-use-radius',
            'Curve Deform Radius',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'curve-use-stretch',
            'Curve Deform Stretch',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'curve-use-deform-bounds',
            'Curve Deform Bounds',
            false,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'curve-texture-space',
        title: 'Texture Space',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'curve-auto-texspace',
            'Auto Texture Space',
            true,
          ),
          BlenderPropertyFactory.number('curve-texspace-x', 'Location X', 0),
          BlenderPropertyFactory.number('curve-texspace-y', 'Location Y', 0),
          BlenderPropertyFactory.number('curve-texspace-z', 'Location Z', 0),
          BlenderPropertyFactory.number('curve-texspace-size', 'Size', 2),
        ],
      ),
      BlenderPropertyGroup(
        id: 'curve-geometry',
        title: 'Geometry',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number('curve-offset', 'Offset', 0),
          BlenderPropertyFactory.number('curve-extrude', 'Extrude', 0, min: 0),
          BlenderPropertyDescriptor<String>(
            id: 'curve-taper-object',
            label: 'Taper Object',
            value: 'None',
            editorBuilder: (context, value, onChanged) =>
                BlenderDataBlockField<String>(
                  value: value,
                  icon: BlenderGlyph.object,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                    BlenderMenuItem<String>(value: 'Taper', label: 'Taper'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Taper Object changed'),
          ),
          BlenderPropertyFactory.choice<String>(
            'curve-taper-radius-mode',
            'Taper Radius Mode',
            'Override',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Override', label: 'Override'),
              BlenderMenuItem<String>(value: 'Multiply', label: 'Multiply'),
            ],
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'curve-bevel',
            title: 'Bevel',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'curve-bevel-mode',
                'Mode',
                'Round',
                bevelModes,
              ),
              BlenderPropertyFactory.number(
                'curve-bevel-depth',
                'Depth',
                .02,
                min: 0,
              ),
              BlenderPropertyFactory.number(
                'curve-bevel-resolution',
                'Resolution',
                4,
                min: 0,
                max: 32,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.boolean(
                'curve-fill-caps',
                'Fill Caps',
                true,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'curve-start-end',
            title: 'Start & End Mapping',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'curve-factor-start',
                'Factor Start',
                0,
                min: 0,
              ),
              BlenderPropertyFactory.number(
                'curve-factor-end',
                'End',
                1,
                min: 0,
              ),
              BlenderPropertyFactory.choice<String>(
                'curve-mapping-start',
                'Mapping Start',
                'RESOLUTION',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'RESOLUTION',
                    label: 'Resolution',
                  ),
                  BlenderMenuItem<String>(value: 'SEGMENTS', label: 'Segments'),
                ],
              ),
              BlenderPropertyFactory.choice<String>(
                'curve-mapping-end',
                'End',
                'RESOLUTION',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'RESOLUTION',
                    label: 'Resolution',
                  ),
                  BlenderMenuItem<String>(value: 'SEGMENTS', label: 'Segments'),
                ],
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'curve-path-animation',
        title: 'Path Animation',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean('curve-use-path', 'Use Path', true),
          BlenderPropertyFactory.number(
            'curve-path-duration',
            'Frames',
            100,
            min: 1,
          ),
          BlenderPropertyFactory.number(
            'curve-eval-time',
            'Evaluation Time',
            0,
          ),
          BlenderPropertyFactory.boolean('curve-path-clamp', 'Clamp', false),
          BlenderPropertyFactory.boolean('curve-path-follow', 'Follow', false),
        ],
      ),
      BlenderPropertyGroup(
        id: 'curve-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Curve', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'CurveAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'CurveAction',
                  label: 'CurveAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Curve action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'curve-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'curve-custom-property',
            'example_value',
            1,
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _fontCurvePropertyGroups {
    BlenderPropertyDescriptor<String> fontField(String id, String label) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: 'Bfont',
        editorBuilder: (context, value, onChanged) =>
            BlenderDataBlockField<String>(
              value: value,
              icon: BlenderGlyph.curve,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'Bfont', label: 'Bfont'),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: onChanged,
            ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'font-shape',
        title: 'Shape',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'font-resolution',
            'Resolution Preview U',
            12,
            min: 1,
          ),
          BlenderPropertyFactory.boolean(
            'font-fast-edit',
            'Fast Editing',
            false,
          ),
          BlenderPropertyFactory.choice<String>(
            'font-fill-mode',
            'Fill Mode',
            'Half',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Half', label: 'Half'),
              BlenderMenuItem<String>(value: 'Both', label: 'Both'),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'font-texture-space',
        title: 'Texture Space',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'font-auto-texspace',
            'Auto Texture Space',
            true,
          ),
          BlenderPropertyFactory.number('font-texspace-x', 'Location X', 0),
          BlenderPropertyFactory.number('font-texspace-y', 'Location Y', 0),
          BlenderPropertyFactory.number('font-texspace-z', 'Location Z', 0),
          BlenderPropertyFactory.number('font-texspace-size', 'Size', 2),
        ],
      ),
      BlenderPropertyGroup(
        id: 'font-settings',
        title: 'Font',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          fontField('font-regular', 'Regular'),
          fontField('font-bold', 'Bold'),
          fontField('font-italic', 'Italic'),
          fontField('font-bold-italic', 'Bold & Italic'),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'font-transform',
            title: 'Transform',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number('font-size', 'Size', 1, min: 0),
              BlenderPropertyFactory.number(
                'font-shear',
                'Shear',
                0,
                min: -1,
                max: 1,
              ),
              fontField('font-family', 'Family'),
              fontField('font-follow-curve', 'Follow Curve'),
              BlenderPropertyFactory.number(
                'font-underline-position',
                'Underline Position',
                -0.1,
              ),
              BlenderPropertyFactory.number(
                'font-underline-height',
                'Underline Thickness',
                0.05,
              ),
              BlenderPropertyFactory.number(
                'font-small-caps-scale',
                'Small Caps Scale',
                0.75,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'font-paragraph',
        title: 'Paragraph',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'font-alignment',
            title: 'Alignment',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'font-align-x',
                'Horizontal',
                'Left',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Left', label: 'Left'),
                  BlenderMenuItem<String>(value: 'Center', label: 'Center'),
                  BlenderMenuItem<String>(value: 'Right', label: 'Right'),
                ],
              ),
              BlenderPropertyFactory.choice<String>(
                'font-align-y',
                'Vertical',
                'Top',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Top', label: 'Top'),
                  BlenderMenuItem<String>(value: 'Center', label: 'Center'),
                  BlenderMenuItem<String>(value: 'Bottom', label: 'Bottom'),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'font-spacing',
            title: 'Spacing',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'font-space-character',
                'Character Spacing',
                1,
              ),
              BlenderPropertyFactory.number(
                'font-space-word',
                'Word Spacing',
                1,
              ),
              BlenderPropertyFactory.number(
                'font-space-line',
                'Line Spacing',
                1,
              ),
              BlenderPropertyFactory.number('font-offset-x', 'Offset X', 0),
              BlenderPropertyFactory.number('font-offset-y', 'Y', 0),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'font-text-boxes',
        title: 'Text Boxes',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'font-overflow',
            'Overflow',
            'Overflow',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Overflow', label: 'Overflow'),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
        ],
        content: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: BlenderButton(
            label: 'Add Text Box',
            leading: const BlenderIcon(BlenderGlyph.plus, size: 14),
            onPressed: () => _setStatus('Add text box'),
            width: double.infinity,
          ),
        ),
      ),
      BlenderPropertyGroup(
        id: 'font-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          fontField('font-action', 'Action'),
          fontField('font-slot', 'Slot'),
        ],
      ),
      BlenderPropertyGroup(
        id: 'font-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'font-custom-property',
            'example_value',
            1,
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _curvesPropertyGroups {
    BlenderPropertyDescriptor<String> surfaceProperty(
      String id,
      String label,
      String value,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) =>
            BlenderDataBlockField<String>(
              value: value,
              icon: BlenderGlyph.mesh,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'None', label: 'None'),
                BlenderMenuItem<String>(value: 'Surface', label: 'Surface'),
              ],
              onChanged: onChanged,
            ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'curves-surface',
        title: 'Surface',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          surfaceProperty('curves-surface-object', 'Surface', 'None'),
          surfaceProperty('curves-surface-uv-map', 'UV Map', 'None'),
        ],
      ),
      BlenderPropertyGroup(
        id: 'curves-attributes',
        title: 'Attributes',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const BlenderListView<String>(
              items: <BlenderListItem<String>>[
                BlenderListItem<String>(
                  id: 'curves-radius',
                  label: 'radius',
                  detail: 'Point  •  Float',
                ),
                BlenderListItem<String>(
                  id: 'curves-color',
                  label: 'color',
                  detail: 'Point  •  Color',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                Expanded(
                  child: BlenderButton(
                    label: 'Add Attribute',
                    onPressed: () => _setStatus('Add Curves attribute'),
                  ),
                ),
                const SizedBox(width: 4),
                BlenderIconButton(
                  glyph: BlenderGlyph.minus,
                  tooltip: 'Remove attribute',
                  onPressed: () => _setStatus('Remove Curves attribute'),
                  size: 24,
                ),
              ],
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'curves-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Curves', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'CurvesAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'CurvesAction',
                  label: 'CurvesAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Curves action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'curves-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<double>(
            id: 'curves-custom-property',
            label: 'example_value',
            value: 1,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              decimalDigits: 2,
              onChanged: onChanged,
            ),
            onChanged: (_) => _setStatus('Curves custom property changed'),
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _pointCloudPropertyGroups {
    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'point-cloud-attributes',
        title: 'Attributes',
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(
              height: 88,
              child: BlenderListView<String>(
                items: <BlenderListItem<String>>[
                  BlenderListItem<String>(
                    id: 'point-radius',
                    label: 'radius',
                    detail: 'Float',
                  ),
                  BlenderListItem<String>(
                    id: 'point-color',
                    label: 'color',
                    detail: 'Float Color',
                  ),
                  BlenderListItem<String>(
                    id: 'point-id',
                    label: 'id',
                    detail: 'Integer',
                  ),
                  BlenderListItem<String>(
                    id: 'point-velocity',
                    label: 'velocity',
                    detail: 'Float Vector',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                Expanded(
                  child: BlenderButton(
                    label: 'Add Attribute',
                    onPressed: () => _setStatus('Add Point Cloud attribute'),
                  ),
                ),
                const SizedBox(width: 4),
                BlenderIconButton(
                  glyph: BlenderGlyph.minus,
                  tooltip: 'Remove attribute',
                  onPressed: () => _setStatus('Remove Point Cloud attribute'),
                  size: 24,
                ),
              ],
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'point-cloud-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<double>(
            id: 'point-cloud-custom-property',
            label: 'example_value',
            value: 1,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              decimalDigits: 2,
              onChanged: onChanged,
            ),
            onChanged: (_) => _setStatus('Point Cloud custom property changed'),
          ),
        ],
      ),
    ];
  }
}
