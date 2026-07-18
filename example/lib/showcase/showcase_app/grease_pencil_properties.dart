part of '../showcase_app.dart';

extension _ShowcaseGreasePencilProperties on _ShowcaseAppState {
  List<BlenderPropertyGroup> get _greasePencilPropertyGroups {
    const blendModes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Regular', label: 'Regular'),
      BlenderMenuItem<String>(value: 'Multiply', label: 'Multiply'),
      BlenderMenuItem<String>(value: 'Screen', label: 'Screen'),
      BlenderMenuItem<String>(value: 'Add', label: 'Add'),
    ];
    const onionModes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Absolute', label: 'Absolute'),
      BlenderMenuItem<String>(value: 'Relative', label: 'Relative'),
      BlenderMenuItem<String>(value: 'Selected', label: 'Selected'),
    ];
    const keyframeTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Keyframe', label: 'Keyframe'),
      BlenderMenuItem<String>(value: 'Extreme', label: 'Extreme'),
      BlenderMenuItem<String>(value: 'Breakdown', label: 'Breakdown'),
    ];

    Widget actionButton(BlenderGlyph glyph, String label) => BlenderIconButton(
      glyph: glyph,
      onPressed: () => _setStatus(label),
      tooltip: label,
      size: 22,
    );

    Widget layerList() => SizedBox(
      height: 132,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Expanded(
            child: BlenderBox(
              padding: EdgeInsets.zero,
              child: BlenderListView<String>(
                items: <BlenderListItem<String>>[
                  BlenderListItem<String>(
                    id: 'gp-layer-main',
                    label: 'Main',
                    icon: BlenderGlyph.greasepencil,
                  ),
                  BlenderListItem<String>(
                    id: 'gp-layer-ink',
                    label: 'Ink',
                    icon: BlenderGlyph.greasepencil,
                  ),
                  BlenderListItem<String>(
                    id: 'gp-layer-shadow',
                    label: 'Shadow',
                    icon: BlenderGlyph.greasepencil,
                  ),
                ],
                selectedId: 'gp-layer-main',
              ),
            ),
          ),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              actionButton(BlenderGlyph.plus, 'Add Grease Pencil layer'),
              actionButton(BlenderGlyph.folder, 'Add Grease Pencil group'),
              actionButton(BlenderGlyph.minus, 'Remove Grease Pencil layer'),
              actionButton(BlenderGlyph.more, 'Grease Pencil layer specials'),
              actionButton(BlenderGlyph.stepBack, 'Move layer up'),
              actionButton(BlenderGlyph.stepForward, 'Move layer down'),
            ],
          ),
        ],
      ),
    );

    Widget animation() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Grease Pencil',
          style: BlenderTheme.of(context).textTheme.caption,
        ),
        const SizedBox(height: 4),
        BlenderDataBlockField<String>(
          value: 'GreasePencilAction',
          icon: BlenderGlyph.action,
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(
              value: 'GreasePencilAction',
              label: 'GreasePencilAction',
            ),
            BlenderMenuItem<String>(value: 'None', label: 'None'),
          ],
          onChanged: (value) => _setStatus('Grease Pencil action: $value'),
        ),
      ],
    );

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'grease-pencil-layers',
        title: 'Layers',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'grease-pencil-blend-mode',
            'Blend Mode',
            'Regular',
            blendModes,
          ),
          BlenderPropertyFactory.number(
            'grease-pencil-opacity',
            'Opacity',
            1,
            min: 0,
            max: 1,
          ),
          BlenderPropertyFactory.boolean(
            'grease-pencil-lights',
            'Lights',
            true,
          ),
        ],
        content: layerList(),
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'grease-pencil-masks',
            title: 'Masks',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'grease-pencil-use-masks',
                'Use Masks',
                true,
              ),
            ],
            content: const SizedBox(
              height: 66,
              child: BlenderListView<String>(
                items: <BlenderListItem<String>>[
                  BlenderListItem<String>(id: 'gp-mask-ink', label: 'Ink'),
                  BlenderListItem<String>(
                    id: 'gp-mask-shadow',
                    label: 'Shadow',
                  ),
                ],
              ),
            ),
          ),
          BlenderPropertyGroup(
            id: 'grease-pencil-transform',
            title: 'Transform',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'grease-pencil-translation-x',
                'Translation X',
                0,
              ),
              BlenderPropertyFactory.number(
                'grease-pencil-translation-y',
                'Y',
                0,
              ),
              BlenderPropertyFactory.number(
                'grease-pencil-translation-z',
                'Z',
                0,
              ),
              BlenderPropertyFactory.number(
                'grease-pencil-rotation',
                'Rotation',
                0,
              ),
              BlenderPropertyFactory.number('grease-pencil-scale', 'Scale', 1),
            ],
          ),
          BlenderPropertyGroup(
            id: 'grease-pencil-adjustments',
            title: 'Adjustments',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'grease-pencil-tint-factor',
                'Tint Factor',
                0,
              ),
              BlenderPropertyFactory.number(
                'grease-pencil-radius-offset',
                'Stroke Thickness',
                0,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'grease-pencil-relations',
            title: 'Relations',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyDescriptor<String>(
                id: 'grease-pencil-parent',
                label: 'Parent',
                value: 'None',
                editorBuilder: (context, value, onChanged) =>
                    BlenderDropdown<String>(
                      value: value,
                      items: const <BlenderMenuItem<String>>[
                        BlenderMenuItem<String>(value: 'None', label: 'None'),
                        BlenderMenuItem<String>(
                          value: 'Armature',
                          label: 'Armature',
                        ),
                      ],
                      onChanged: onChanged,
                    ),
                onChanged: (_) => _setStatus('Parent changed'),
              ),
              BlenderPropertyFactory.number(
                'grease-pencil-pass-index',
                'Pass Index',
                0,
                min: 0,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.boolean(
                'grease-pencil-view-layer-mask',
                'View Layer Masks',
                false,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'grease-pencil-layer-display',
            title: 'Display',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'grease-pencil-channel-color',
                'Channel Color',
                true,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'grease-pencil-onion-skinning',
        title: 'Onion Skinning',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'grease-pencil-onion-mode',
            'Mode',
            'Absolute',
            onionModes,
          ),
          BlenderPropertyFactory.number(
            'grease-pencil-onion-opacity',
            'Opacity',
            .5,
            min: 0,
            max: 1,
          ),
          BlenderPropertyFactory.choice<String>(
            'grease-pencil-onion-keyframe-type',
            'Keyframe Type',
            'Keyframe',
            keyframeTypes,
          ),
          BlenderPropertyFactory.number(
            'grease-pencil-ghost-before',
            'Frames Before',
            1,
            min: 0,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.number(
            'grease-pencil-ghost-after',
            'Frames After',
            1,
            min: 0,
            decimalDigits: 0,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'grease-pencil-onion-colors',
            title: 'Custom Colors',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'grease-pencil-custom-colors',
                'Use Custom Colors',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'grease-pencil-color-before',
                'Before',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'grease-pencil-color-after',
                'After',
                true,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'grease-pencil-onion-display',
            title: 'Display',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'grease-pencil-onion-fade',
                'Fade',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'grease-pencil-onion-loop',
                'Show Start Frame',
                false,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'grease-pencil-settings',
        title: 'Settings',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'grease-pencil-stroke-depth-order',
            'Stroke Depth Order',
            '2D Layers',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: '2D Layers', label: '2D Layers'),
              BlenderMenuItem<String>(
                value: '3D Location',
                label: '3D Location',
              ),
            ],
          ),
        ],
      ),
      const BlenderPropertyGroup(
        id: 'grease-pencil-attributes',
        title: 'Attributes',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: const SizedBox(
          height: 66,
          child: BlenderListView<String>(
            items: <BlenderListItem<String>>[
              BlenderListItem<String>(
                id: 'gp-attribute-position',
                label: 'position',
                detail: 'Float Vector',
              ),
              BlenderListItem<String>(
                id: 'gp-attribute-radius',
                label: 'radius',
                detail: 'Float',
              ),
              BlenderListItem<String>(
                id: 'gp-attribute-opacity',
                label: 'opacity',
                detail: 'Float',
              ),
            ],
          ),
        ),
      ),
      BlenderPropertyGroup(
        id: 'grease-pencil-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: animation(),
      ),
      BlenderPropertyGroup(
        id: 'grease-pencil-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'grease-pencil-custom-property',
            'example_value',
            1,
          ),
        ],
      ),
    ];
  }
}
