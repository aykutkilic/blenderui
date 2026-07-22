part of '../showcase_app.dart';

extension _ShowcaseMaterialProperties on _ShowcaseAppState {
  List<BlenderPropertyGroup> get _materialPropertyGroups {
    const shaderChoices = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(
        value: 'Principled BSDF',
        label: 'Principled BSDF',
      ),
      BlenderMenuItem<String>(value: 'Diffuse BSDF', label: 'Diffuse BSDF'),
      BlenderMenuItem<String>(value: 'None', label: 'None'),
    ];
    const renderMethods = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Dithered', label: 'Dithered'),
      BlenderMenuItem<String>(value: 'Blended', label: 'Blended'),
      BlenderMenuItem<String>(value: 'Opaque', label: 'Opaque'),
    ];

    return <BlenderPropertyGroup>[
      BlenderPropertyFactory.panel(
        'material-preview',
        'Preview',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'material-preview-shape',
            'Preview Shape',
            'Sphere',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Sphere', label: 'Sphere'),
              BlenderMenuItem<String>(value: 'Cube', label: 'Cube'),
              BlenderMenuItem<String>(
                value: 'Shader Ball',
                label: 'Shader Ball',
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'material-surface',
        'Surface',
        expanded: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'material-surface-node',
            'Surface',
            'Principled BSDF',
            shaderChoices,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'material-volume',
        'Volume',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'material-volume-node',
            'Volume',
            'Principled BSDF',
            shaderChoices,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'material-displacement',
        'Displacement',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'material-displacement-node',
            'Displacement',
            'None',
            shaderChoices,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'material-thickness',
        'Thickness',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'material-thickness-node',
            'Thickness',
            'None',
            shaderChoices,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'material-settings',
        'Settings',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'material-pass-index',
            'Pass Index',
            0,
            min: 0,
            max: 32767,
            decimalDigits: 0,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyFactory.panel(
            'material-settings-surface',
            'Surface',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'material-backface-camera',
                'Backface Culling Camera',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'material-backface-shadow',
                'Backface Culling Shadow',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'material-backface-probe',
                'Backface Culling Light Probe Volume',
                false,
              ),
              BlenderPropertyFactory.choice<String>(
                'material-displacement-method',
                'Displacement',
                'Bump',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Bump', label: 'Bump'),
                  BlenderMenuItem<String>(
                    value: 'Displacement',
                    label: 'Displacement',
                  ),
                ],
              ),
              BlenderPropertyFactory.number(
                'material-max-displacement',
                'Max Distance',
                0,
                min: 0,
              ),
              BlenderPropertyFactory.boolean(
                'material-transparent-shadow',
                'Transparent Shadow',
                true,
              ),
              BlenderPropertyFactory.choice<String>(
                'material-render-method',
                'Render Method',
                'Dithered',
                renderMethods,
              ),
              BlenderPropertyFactory.boolean(
                'material-transparency-overlap',
                'Transparency Overlap',
                true,
              ),
              BlenderPropertyFactory.choice<String>(
                'material-thickness-mode',
                'Thickness',
                'Slab',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Slab', label: 'Slab'),
                  BlenderMenuItem<String>(value: 'Sphere', label: 'Sphere'),
                ],
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'material-settings-volume',
            'Volume',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'material-volume-intersection',
                'Intersection',
                'Fast',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Fast', label: 'Fast'),
                  BlenderMenuItem<String>(value: 'Accurate', label: 'Accurate'),
                ],
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'material-viewport-display',
        'Viewport Display',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<Color>(
            id: 'material-diffuse-color',
            label: 'Color',
            value: const Color(0xFF4772B3),
            editorBuilder: (context, value, onChanged) => BlenderColorField(
              color: value,
              onPressed: () => _setStatus('Material color picker opened'),
            ),
          ),
          BlenderPropertyFactory.number(
            'material-metallic',
            'Metallic',
            .2,
            min: 0,
            max: 1,
          ),
          BlenderPropertyFactory.number(
            'material-roughness',
            'Roughness',
            .35,
            min: 0,
            max: 1,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'material-line-art',
        'Line Art',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'material-mask',
            'Material Mask',
            false,
          ),
          BlenderPropertyFactory.number(
            'material-occlusion',
            'Levels',
            0,
            min: 0,
            max: 8,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.boolean(
            'material-intersection-override',
            'Intersection Priority Override',
            false,
          ),
          BlenderPropertyFactory.number(
            'material-intersection-priority',
            'Intersection Priority',
            0,
            min: 0,
            max: 255,
            decimalDigits: 0,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'material-freestyle-line',
        'Freestyle Line',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<Color>(
            id: 'material-freestyle-line-color',
            label: 'Line Color',
            value: const Color(0xFF101010),
            editorBuilder: (context, value, onChanged) => BlenderColorField(
              color: value,
              onPressed: () => _setStatus('Freestyle line color opened'),
            ),
          ),
          BlenderPropertyFactory.number(
            'material-freestyle-line-priority',
            'Priority',
            0,
            min: 0,
            max: 32767,
            decimalDigits: 0,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'material-grease-pencil',
        'Grease Pencil',
        children: <BlenderPropertyGroup>[
          BlenderPropertyFactory.panel(
            'material-grease-pencil-surface',
            'Surface',
            expanded: true,
            children: <BlenderPropertyGroup>[
              BlenderPropertyFactory.panel(
                'material-grease-pencil-stroke',
                'Stroke',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.choice<String>(
                    'material-grease-pencil-stroke-mode',
                    'Mode',
                    'Line',
                    const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'Line', label: 'Line'),
                      BlenderMenuItem<String>(value: 'Dots', label: 'Dots'),
                      BlenderMenuItem<String>(value: 'Box', label: 'Box'),
                    ],
                  ),
                  BlenderPropertyFactory.choice<String>(
                    'material-grease-pencil-stroke-style',
                    'Style',
                    'Solid',
                    const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'Solid', label: 'Solid'),
                      BlenderMenuItem<String>(
                        value: 'Texture',
                        label: 'Texture',
                      ),
                    ],
                  ),
                  BlenderPropertyFactory.boolean(
                    'material-grease-pencil-stroke-holdout',
                    'Holdout',
                    false,
                  ),
                ],
                children: <BlenderPropertyGroup>[
                  BlenderPropertyFactory.panel(
                    'material-grease-pencil-randomize',
                    'Randomize',
                    properties: <BlenderPropertyDescriptor<dynamic>>[
                      BlenderPropertyFactory.number(
                        'material-grease-pencil-random-radius',
                        'Radius',
                        0,
                        min: 0,
                      ),
                      BlenderPropertyFactory.number(
                        'material-grease-pencil-random-opacity',
                        'Opacity',
                        0,
                        min: 0,
                        max: 1,
                      ),
                    ],
                  ),
                ],
              ),
              BlenderPropertyFactory.panel(
                'material-grease-pencil-fill',
                'Fill',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyDescriptor<Color>(
                    id: 'material-grease-pencil-fill-color',
                    label: 'Base Color',
                    value: const Color(0xFF4772B3),
                    editorBuilder: (context, value, onChanged) =>
                        BlenderColorField(
                          color: value,
                          onPressed: () => _setStatus('GP fill color picker'),
                        ),
                  ),
                  BlenderPropertyFactory.boolean(
                    'material-grease-pencil-fill-holdout',
                    'Holdout',
                    false,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'material-animation',
        'Animation',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'material-action',
            'Material',
            'MaterialAction',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'MaterialAction',
                label: 'MaterialAction',
              ),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
          BlenderPropertyFactory.choice<String>(
            'material-node-action',
            'Shader Node Tree',
            'MaterialNodes',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'MaterialNodes',
                label: 'MaterialNodes',
              ),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'material-custom-properties',
        'Custom Properties',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'material-custom-property',
            'example_value',
            1,
          ),
        ],
      ),
    ];
  }

  Widget _meshListContent({
    required List<BlenderListItem<String>> items,
    required String label,
    bool showMoveButtons = false,
  }) {
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: BlenderBox(
              padding: EdgeInsets.zero,
              child: BlenderListView<String>(
                items: items,
                selectedId: items.isEmpty ? null : items.first.id,
                onSelected: (item) => _setStatus('$label: ${item.label}'),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              BlenderIconButton(
                glyph: BlenderGlyph.plus,
                onPressed: () => _setStatus('Add $label'),
                tooltip: 'Add $label',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.minus,
                onPressed: () => _setStatus('Remove $label'),
                tooltip: 'Remove $label',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.more,
                onPressed: () => _setStatus('$label specials'),
                tooltip: '$label specials',
                size: 22,
              ),
              if (showMoveButtons) ...<Widget>[
                BlenderIconButton(
                  glyph: BlenderGlyph.stepBack,
                  onPressed: () => _setStatus('Move $label up'),
                  tooltip: 'Move $label up',
                  size: 22,
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.stepForward,
                  onPressed: () => _setStatus('Move $label down'),
                  tooltip: 'Move $label down',
                  size: 22,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
