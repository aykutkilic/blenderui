part of '../showcase_app.dart';

extension _ShowcaseViewLayerProperties on _ShowcaseAppState {
  List<BlenderMenuItem<String>> get _viewLayerOverrideSamples =>
      const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Scene', label: 'Scene'),
        BlenderMenuItem<String>(value: '128', label: '128'),
        BlenderMenuItem<String>(value: '256', label: '256'),
      ];

  Widget _viewLayerListContent({
    required List<BlenderListItem<String>> items,
  }) => SizedBox(
    height: 76,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: BlenderBox(
            padding: EdgeInsets.zero,
            child: BlenderListView<String>(items: items),
          ),
        ),
        const SizedBox(width: 4),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            BlenderIconButton(
              glyph: BlenderGlyph.plus,
              onPressed: () => _setStatus('Add view layer item'),
              tooltip: 'Add view layer item',
              size: 22,
            ),
            BlenderIconButton(
              glyph: BlenderGlyph.minus,
              onPressed: () => _setStatus('Remove view layer item'),
              tooltip: 'Remove view layer item',
              size: 22,
            ),
          ],
        ),
      ],
    ),
  );

  List<BlenderPropertyGroup> get _viewLayerPropertyGroups {
    return <BlenderPropertyGroup>[
      ..._viewLayerPropertyGroupsViewLayerSettings(),
      ..._viewLayerPropertyGroupsViewLayerFreestyle(),
      ..._viewLayerPropertyGroupsFreestyleStrokes(),
      ..._viewLayerPropertyGroupsFreestyleThickness(),
    ];
  }

  List<BlenderPropertyGroup> _viewLayerPropertyGroupsViewLayerSettings() {
    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'view-layer-settings',
        title: 'View Layer',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'view-layer-use',
            'Use for Rendering',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'view-layer-single-layer',
            'Render Single Layer',
            false,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'view-layer-passes',
        title: 'Passes',
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'view-layer-passes-data',
            title: 'Data',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'view-layer-pass-combined',
                'Combined',
                true,
              ),
              BlenderPropertyFactory.boolean('view-layer-pass-z', 'Z', false),
              BlenderPropertyFactory.boolean(
                'view-layer-pass-mist',
                'Mist',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'view-layer-pass-normal',
                'Normal',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'view-layer-pass-position',
                'Position',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'view-layer-pass-vector',
                'Vector',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'view-layer-pass-grease-pencil',
                'Grease Pencil',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'view-layer-pass-denoising',
                'Denoising Data',
                false,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'view-layer-passes-light',
            title: 'Light',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'view-layer-diffuse-direct',
                'Diffuse Light',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'view-layer-diffuse-color',
                'Diffuse Color',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'view-layer-glossy-direct',
                'Specular Light',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'view-layer-glossy-color',
                'Specular Color',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'view-layer-volume-direct',
                'Volume Light',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'view-layer-emission',
                'Emission',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'view-layer-environment',
                'Environment',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'view-layer-shadow',
                'Shadow',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'view-layer-ao',
                'Ambient Occlusion',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'view-layer-transparent',
                'Transparent',
                false,
              ),
              BlenderPropertyFactory.number(
                'view-layer-ao-distance',
                'Occlusion Distance',
                10,
                min: 0,
                decimalDigits: 2,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'view-layer-passes-aov',
            title: 'Shader AOV',
            properties: const <BlenderPropertyDescriptor<dynamic>>[],
            content: _viewLayerListContent(
              items: const <BlenderListItem<String>>[
                BlenderListItem<String>(
                  id: 'aov-beauty',
                  label: 'Beauty',
                  detail: 'Color',
                ),
                BlenderListItem<String>(
                  id: 'aov-mask',
                  label: 'Mask',
                  detail: 'Value',
                ),
                BlenderListItem<String>(
                  id: 'aov-depth',
                  label: 'Depth',
                  detail: 'Value',
                ),
              ],
            ),
          ),
          BlenderPropertyGroup(
            id: 'view-layer-passes-cryptomatte',
            title: 'Cryptomatte',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'view-layer-crypto-object',
                'Object',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'view-layer-crypto-material',
                'Material',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'view-layer-crypto-asset',
                'Asset',
                false,
              ),
              BlenderPropertyFactory.number(
                'view-layer-crypto-depth',
                'Levels',
                6,
                min: 1,
                decimalDigits: 0,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'view-layer-passes-lightgroups',
            title: 'Light Groups',
            properties: const <BlenderPropertyDescriptor<dynamic>>[],
            content: _viewLayerListContent(
              items: const <BlenderListItem<String>>[
                BlenderListItem<String>(
                  id: 'lightgroup-key',
                  label: 'Key Light',
                ),
                BlenderListItem<String>(
                  id: 'lightgroup-fill',
                  label: 'Fill Light',
                ),
              ],
            ),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'view-layer-filter',
        title: 'Filter',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'view-layer-filter-environment',
            'Environment',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'view-layer-filter-surfaces',
            'Surfaces',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'view-layer-filter-curves',
            'Curves',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'view-layer-filter-volumes',
            'Volumes',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'view-layer-filter-grease-pencil',
            'Grease Pencil',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'view-layer-filter-motion-blur',
            'Motion Blur',
            true,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'view-layer-override',
        title: 'Override',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<String>(
            id: 'view-layer-material-override',
            label: 'Material Override',
            value: 'None',
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                    BlenderMenuItem<String>(
                      value: 'Override Material',
                      label: 'Override Material',
                    ),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Material override changed'),
          ),
          BlenderPropertyDescriptor<String>(
            id: 'view-layer-world-override',
            label: 'World Override',
            value: 'None',
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                    BlenderMenuItem<String>(
                      value: 'Night World',
                      label: 'Night World',
                    ),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('World override changed'),
          ),
          BlenderPropertyFactory.choice<String>(
            'view-layer-samples',
            'Samples',
            'Scene',
            _viewLayerOverrideSamples,
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> _viewLayerPropertyGroupsViewLayerFreestyle() {
    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'view-layer-freestyle',
        title: 'Freestyle',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'freestyle-control-mode',
            'Control Mode',
            'Editor',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Editor', label: 'Editor'),
              BlenderMenuItem<String>(value: 'Python', label: 'Python'),
            ],
          ),
          BlenderPropertyFactory.boolean(
            'freestyle-view-map-cache',
            'View Map Cache',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'freestyle-render-pass',
            'As Render Pass',
            false,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'freestyle-edge-detection',
            title: 'Edge Detection',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'freestyle-crease-angle',
                'Crease Angle',
                0.785,
                min: 0,
                max: 3.14,
                decimalDigits: 3,
              ),
              BlenderPropertyFactory.boolean(
                'freestyle-culling',
                'Culling',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'freestyle-face-smoothness',
                'Face Smoothness',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'freestyle-material-boundaries',
                'Material Boundaries',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'freestyle-ridges-valleys',
                'Ridges and Valleys',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'freestyle-suggestive-contours',
                'Suggestive Contours',
                false,
              ),
              BlenderPropertyFactory.number(
                'freestyle-sphere-radius',
                'Sphere Radius',
                0.1,
                min: 0,
                decimalDigits: 3,
              ),
              BlenderPropertyFactory.number(
                'freestyle-kr-derivative-epsilon',
                'Kr Derivative Epsilon',
                0.01,
                min: 0,
                decimalDigits: 3,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'freestyle-style-modules',
            title: 'Style Modules',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'freestyle-use-python',
                'Use Python',
                false,
              ),
            ],
            content: _viewLayerListContent(
              items: const <BlenderListItem<String>>[
                BlenderListItem<String>(
                  id: 'freestyle-module-cartoon',
                  label: 'cartoon.py',
                  detail: 'Enabled',
                ),
                BlenderListItem<String>(
                  id: 'freestyle-module-sketch',
                  label: 'sketchy.py',
                  detail: 'Disabled',
                ),
              ],
            ),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'freestyle-lineset',
        title: 'Freestyle Line Set',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'freestyle-lineset-image-border',
            'Select by Image Border',
            false,
          ),
          BlenderPropertyFactory.choice<String>(
            'freestyle-lineset-style',
            'Line Style',
            'Freestyle LineStyle',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Freestyle LineStyle',
                label: 'Freestyle LineStyle',
              ),
              BlenderMenuItem<String>(value: 'Thin Ink', label: 'Thin Ink'),
            ],
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'freestyle-visibility',
            title: 'Visibility',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'freestyle-visible-ridges',
                'Ridges',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'freestyle-visible-valleys',
                'Valleys',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'freestyle-visible-silhouette',
                'Silhouette',
                true,
              ),
              BlenderPropertyFactory.choice<String>(
                'freestyle-visibility-type',
                'Type',
                'Visible',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Visible', label: 'Visible'),
                  BlenderMenuItem<String>(value: 'Range', label: 'Range'),
                ],
              ),
              BlenderPropertyFactory.number(
                'freestyle-qi-start',
                'QI Start',
                0,
                min: 0,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.number(
                'freestyle-qi-end',
                'QI End',
                1,
                min: 0,
                decimalDigits: 0,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'freestyle-edge-type',
            title: 'Edge Type',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'freestyle-edge-silhouette',
                'Silhouette',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'freestyle-edge-border',
                'Border',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'freestyle-edge-crease',
                'Crease',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'freestyle-edge-mark',
                'Edge Mark',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'freestyle-edge-contour',
                'Contour',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'freestyle-edge-external-contour',
                'External Contour',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'freestyle-edge-material-boundary',
                'Material Boundary',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'freestyle-edge-suggestive-contour',
                'Suggestive Contour',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'freestyle-edge-ridge-valley',
                'Ridge Valley',
                false,
              ),
              BlenderPropertyFactory.choice<String>(
                'freestyle-edge-negation',
                'Negation',
                'AND',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'AND', label: 'AND'),
                  BlenderMenuItem<String>(value: 'OR', label: 'OR'),
                ],
              ),
              BlenderPropertyFactory.choice<String>(
                'freestyle-edge-combination',
                'Combination',
                'AND',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'AND', label: 'AND'),
                  BlenderMenuItem<String>(value: 'OR', label: 'OR'),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'freestyle-face-marks',
            title: 'Face Marks',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'freestyle-face-mark-negation',
                'Negation',
                'AND',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'AND', label: 'AND'),
                  BlenderMenuItem<String>(value: 'OR', label: 'OR'),
                ],
              ),
              BlenderPropertyFactory.choice<String>(
                'freestyle-face-mark-condition',
                'Condition',
                'Equal',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Equal', label: 'Equal'),
                  BlenderMenuItem<String>(
                    value: 'Not Equal',
                    label: 'Not Equal',
                  ),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'freestyle-line-collection',
            title: 'Collection',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'freestyle-collection-name',
                'Line Set Collection',
                'All Collections',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'All Collections',
                    label: 'All Collections',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Characters',
                    label: 'Characters',
                  ),
                ],
              ),
              BlenderPropertyFactory.boolean(
                'freestyle-collection-negation',
                'Negation',
                false,
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
