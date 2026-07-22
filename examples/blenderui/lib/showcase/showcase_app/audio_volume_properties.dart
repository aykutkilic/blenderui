part of '../showcase_app.dart';

extension _ShowcaseAudioVolumeProperties on _ShowcaseAppState {
  List<BlenderPropertyGroup> get _speakerPropertyGroups {
    const attenuation = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Inverse', label: 'Inverse'),
      BlenderMenuItem<String>(value: 'Linear', label: 'Linear'),
      BlenderMenuItem<String>(value: 'Exponential', label: 'Exponential'),
    ];

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'speaker-sound',
        title: 'Sound',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<String>(
            id: 'speaker-sound-file',
            label: 'Sound',
            value: 'sound.wav',
            editorBuilder: (context, value, onChanged) =>
                BlenderDataBlockField<String>(
                  value: value,
                  icon: BlenderGlyph.speaker,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(
                      value: 'sound.wav',
                      label: 'sound.wav',
                    ),
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Sound changed'),
          ),
          BlenderPropertyFactory.boolean('speaker-muted', 'Muted', false),
          BlenderPropertyFactory.number('speaker-volume', 'Volume', 1),
          BlenderPropertyFactory.number('speaker-pitch', 'Pitch', 1),
        ],
      ),
      BlenderPropertyGroup(
        id: 'speaker-distance',
        title: 'Distance',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number('speaker-volume-min', 'Volume Min', 0),
          BlenderPropertyFactory.number('speaker-volume-max', 'Max', 1),
          BlenderPropertyDescriptor<String>(
            id: 'speaker-attenuation',
            label: 'Attenuation',
            value: 'Inverse',
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: attenuation,
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Attenuation changed'),
          ),
          BlenderPropertyFactory.number(
            'speaker-distance-max',
            'Max Distance',
            100,
          ),
          BlenderPropertyFactory.number(
            'speaker-distance-reference',
            'Distance Reference',
            1,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'speaker-cone',
        title: 'Cone',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'speaker-cone-outer',
            'Angle Outer',
            360,
          ),
          BlenderPropertyFactory.number('speaker-cone-inner', 'Inner', 360),
          BlenderPropertyFactory.number(
            'speaker-cone-volume',
            'Volume Outer',
            1,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'speaker-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Speaker', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'SpeakerAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'SpeakerAction',
                  label: 'SpeakerAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Speaker action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'speaker-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'speaker-custom-property',
            'example_value',
            1,
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _volumePropertyGroups {
    const wireframeTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Boxes', label: 'Boxes'),
      BlenderMenuItem<String>(value: 'Points', label: 'Points'),
      BlenderMenuItem<String>(value: 'Wire', label: 'Wire'),
    ];
    const interpolation = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Linear', label: 'Linear'),
      BlenderMenuItem<String>(value: 'Cubic', label: 'Cubic'),
    ];

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'volume-file',
        title: 'OpenVDB File',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<String>(
            id: 'volume-filepath',
            label: 'File Path',
            value: '//smoke.vdb',
            editorBuilder: (context, value, onChanged) =>
                BlenderDataBlockField<String>(
                  value: value,
                  icon: BlenderGlyph.file,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(
                      value: '//smoke.vdb',
                      label: '//smoke.vdb',
                    ),
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Volume file changed'),
          ),
          BlenderPropertyFactory.boolean(
            'volume-sequence',
            'Is Sequence',
            true,
          ),
          BlenderPropertyFactory.number('volume-frame-duration', 'Frames', 100),
          BlenderPropertyFactory.number('volume-frame-start', 'Start', 1),
          BlenderPropertyFactory.number('volume-frame-offset', 'Offset', 0),
          BlenderPropertyFactory.choice<String>(
            'volume-sequence-mode',
            'Mode',
            'REPEAT',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'REPEAT', label: 'Repeat'),
              BlenderMenuItem<String>(value: 'CLIP', label: 'Clip'),
            ],
          ),
        ],
      ),
      const BlenderPropertyGroup(
        id: 'volume-grids',
        title: 'Grids',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: const SizedBox(
          height: 66,
          child: BlenderListView<String>(
            items: const <BlenderListItem<String>>[
              BlenderListItem<String>(
                id: 'density-grid',
                label: 'density',
                detail: 'Float',
              ),
              BlenderListItem<String>(
                id: 'temperature-grid',
                label: 'temperature',
                detail: 'Float',
              ),
              BlenderListItem<String>(
                id: 'velocity-grid',
                label: 'velocity',
                detail: 'Vector',
              ),
            ],
          ),
        ),
      ),
      BlenderPropertyGroup(
        id: 'volume-render',
        title: 'Render',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'volume-render-space',
            'Space',
            'WORLD',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'WORLD', label: 'World'),
              BlenderMenuItem<String>(value: 'OBJECT', label: 'Object'),
            ],
          ),
          BlenderPropertyFactory.number('volume-step-size', 'Step Size', .1),
          BlenderPropertyFactory.number('volume-clipping', 'Clipping', 0),
          BlenderPropertyFactory.choice<String>(
            'volume-precision',
            'Precision',
            'FULL',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'FULL', label: 'Full'),
              BlenderMenuItem<String>(value: 'HALF', label: 'Half'),
            ],
          ),
          BlenderPropertyDescriptor<String>(
            id: 'volume-velocity-grid',
            label: 'Velocity Grid',
            value: 'velocity',
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(
                      value: 'velocity',
                      label: 'velocity',
                    ),
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Velocity Grid changed'),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'volume-viewport',
        title: 'Viewport Display',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'volume-wireframe-type',
            'Wireframe Type',
            'Boxes',
            wireframeTypes,
          ),
          BlenderPropertyFactory.number('volume-wireframe-detail', 'Detail', 1),
          BlenderPropertyFactory.number('volume-density', 'Density', 1),
          BlenderPropertyFactory.choice<String>(
            'volume-interpolation',
            'Interpolation',
            'Linear',
            interpolation,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'volume-slicing',
            title: 'Slicing',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'volume-use-slice',
                'Use Slice',
                false,
              ),
              BlenderPropertyFactory.choice<String>(
                'volume-slice-axis',
                'Axis',
                'X',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'X', label: 'X'),
                  BlenderMenuItem<String>(value: 'Y', label: 'Y'),
                  BlenderMenuItem<String>(value: 'Z', label: 'Z'),
                ],
              ),
              BlenderPropertyFactory.number('volume-slice-depth', 'Depth', .5),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'volume-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Volume', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'VolumeAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'VolumeAction',
                  label: 'VolumeAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Volume action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'volume-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'volume-custom-property',
            'example_value',
            1,
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _emptyPropertyGroups {
    const displayTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Plain Axes', label: 'Plain Axes'),
      BlenderMenuItem<String>(value: 'Arrows', label: 'Arrows'),
      BlenderMenuItem<String>(value: 'Single Arrow', label: 'Single Arrow'),
      BlenderMenuItem<String>(value: 'Circle', label: 'Circle'),
      BlenderMenuItem<String>(value: 'Cube', label: 'Cube'),
      BlenderMenuItem<String>(value: 'Image', label: 'Image'),
    ];
    const imageDepth = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Default', label: 'Default'),
      BlenderMenuItem<String>(value: 'Front', label: 'Front'),
      BlenderMenuItem<String>(value: 'Back', label: 'Back'),
    ];

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'empty',
        title: 'Empty',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<String>(
            id: 'empty-display-type',
            label: 'Display As',
            value: 'Plain Axes',
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: displayTypes,
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Display As changed'),
          ),
          BlenderPropertyFactory.number('empty-display-size', 'Size', 1),
          BlenderPropertyFactory.number('empty-image-offset-x', 'Offset X', 0),
          BlenderPropertyFactory.number('empty-image-offset-y', 'Y', 0),
          BlenderPropertyDescriptor<String>(
            id: 'empty-image-depth',
            label: 'Depth',
            value: 'Default',
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: imageDepth,
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Image Depth changed'),
          ),
          BlenderPropertyFactory.boolean(
            'empty-show-orthographic',
            'Orthographic',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'empty-show-perspective',
            'Perspective',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'empty-axis-aligned',
            'Only Axis Aligned',
            false,
          ),
          BlenderPropertyFactory.boolean('empty-alpha', 'Use Alpha', true),
          BlenderPropertyFactory.number('empty-opacity', 'Opacity', .8),
        ],
      ),
      BlenderPropertyGroup(
        id: 'empty-image',
        title: 'Image',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<String>(
            id: 'empty-image-file',
            label: 'Image',
            value: 'reference.png',
            editorBuilder: (context, value, onChanged) =>
                BlenderDataBlockField<String>(
                  value: value,
                  icon: BlenderGlyph.image,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(
                      value: 'reference.png',
                      label: 'reference.png',
                    ),
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Empty image changed'),
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'empty-image-sequence',
            label: 'Sequence',
            value: false,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (_) => _setStatus('Image sequence changed'),
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _latticePropertyGroups {
    const interpolationTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Linear', label: 'Linear'),
      BlenderMenuItem<String>(value: 'Cardinal', label: 'Cardinal'),
      BlenderMenuItem<String>(value: 'B-Spline', label: 'B-Spline'),
    ];

    BlenderPropertyDescriptor<int> integerProperty(
      String id,
      String label,
      int value,
    ) {
      return BlenderPropertyDescriptor<int>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value.toDouble(),
          min: 1,
          max: 64,
          decimalDigits: 0,
          onChanged: (next) => onChanged(next.round()),
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'lattice',
        title: 'Lattice',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          integerProperty('lattice-points-u', 'Resolution U', 4),
          integerProperty('lattice-points-v', 'V', 4),
          integerProperty('lattice-points-w', 'W', 4),
          BlenderPropertyFactory.choice<String>(
            'lattice-interpolation-u',
            'Interpolation U',
            'Linear',
            interpolationTypes,
          ),
          BlenderPropertyFactory.choice<String>(
            'lattice-interpolation-v',
            'V',
            'Linear',
            interpolationTypes,
          ),
          BlenderPropertyFactory.choice<String>(
            'lattice-interpolation-w',
            'W',
            'B-Spline',
            interpolationTypes,
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'lattice-use-outside',
            label: 'Outside',
            value: false,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (_) => _setStatus('Outside changed'),
          ),
          BlenderPropertyDescriptor<String>(
            id: 'lattice-vertex-group',
            label: 'Vertex Group',
            value: 'None',
            editorBuilder: (context, value, onChanged) =>
                BlenderDataBlockField<String>(
                  value: value,
                  icon: BlenderGlyph.object,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                    BlenderMenuItem<String>(value: 'Deform', label: 'Deform'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Vertex Group changed'),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'lattice-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Lattice', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'LatticeAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'LatticeAction',
                  label: 'LatticeAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Lattice action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'lattice-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<double>(
            id: 'lattice-custom-property',
            label: 'example_value',
            value: 1,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              decimalDigits: 2,
              onChanged: onChanged,
            ),
            onChanged: (_) => _setStatus('Lattice custom property changed'),
          ),
        ],
      ),
    ];
  }
}
