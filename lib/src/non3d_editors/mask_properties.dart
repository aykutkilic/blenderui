part of '../non3d_editors.dart';

class BlenderClipMarker {
  const BlenderClipMarker({
    required this.id,
    required this.position,
    this.color,
  });

  final String id;
  final Offset position;
  final Color? color;
}

/// Source-shaped mask controls used by the Movie Clip Editor sidebar.
///
/// Blender's `properties_mask_common.py` supplies these panels to both the
/// image and clip editors. The widget deliberately owns only the visual
/// descriptors; mask evaluation, spline editing, tracking, and operators stay
/// with the host application.
class BlenderMaskProperties extends StatelessWidget {
  const BlenderMaskProperties({super.key, this.title = 'Mask'});

  final String title;

  List<BlenderPropertyGroup> _groups() {
    const blendModes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Merge Add', label: 'Merge Add'),
      BlenderMenuItem<String>(value: 'Merge Subtract', label: 'Merge Subtract'),
      BlenderMenuItem<String>(value: 'Replace', label: 'Replace'),
    ];
    const fillSolvers = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Sweep Line', label: 'Sweep Line'),
      BlenderMenuItem<String>(value: 'Fast', label: 'Fast'),
    ];

    Widget layerList() {
      return SizedBox(
        height: 92,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Expanded(
              child: BlenderBox(
                padding: EdgeInsets.zero,
                child: BlenderListView<String>(
                  items: const <BlenderListItem<String>>[
                    BlenderListItem<String>(
                      id: 'mask-layer-main',
                      label: 'Mask Layer',
                      detail: 'Visible',
                      icon: BlenderGlyph.mesh,
                    ),
                    BlenderListItem<String>(
                      id: 'mask-layer-secondary',
                      label: 'Roto Details',
                      detail: 'Overlay',
                      icon: BlenderGlyph.mesh,
                    ),
                  ],
                  selectedId: 'mask-layer-main',
                ),
              ),
            ),
            const SizedBox(width: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                BlenderIconButton(
                  glyph: BlenderGlyph.plus,
                  onPressed: () {},
                  tooltip: 'Add mask layer',
                  size: 22,
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.minus,
                  onPressed: () {},
                  tooltip: 'Remove mask layer',
                  size: 22,
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.stepBack,
                  onPressed: () {},
                  tooltip: 'Move mask layer up',
                  size: 22,
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.stepForward,
                  onPressed: () {},
                  tooltip: 'Move mask layer down',
                  size: 22,
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget toolButtons(List<String> labels) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final label in labels)
            BlenderButton(label: label, onPressed: () {}),
        ],
      );
    }

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'mask-settings',
        title: 'Mask Settings',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'mask-frame-start',
            'Frame Start',
            1,
            min: 0,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.number(
            'mask-frame-end',
            'Frame End',
            250,
            min: 1,
            decimalDigits: 0,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mask-layers',
        title: 'Mask Layers',
        content: layerList(),
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'mask-layer-alpha',
            'Alpha',
            .85,
            min: 0,
            max: 1,
          ),
          BlenderPropertyFactory.boolean('mask-layer-invert', 'Invert', false),
          BlenderPropertyFactory.menu(
            'mask-layer-blend',
            'Blend',
            'Merge Add',
            blendModes,
          ),
          BlenderPropertyFactory.menu(
            'mask-layer-falloff',
            'Falloff',
            'Smooth',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Smooth', label: 'Smooth'),
              BlenderMenuItem<String>(value: 'Linear', label: 'Linear'),
            ],
          ),
          BlenderPropertyFactory.menu(
            'mask-layer-fill-solver',
            'Fill Solver',
            'Sweep Line',
            fillSolvers,
          ),
          BlenderPropertyFactory.boolean('mask-layer-overlap', 'Overlap', true),
          BlenderPropertyFactory.boolean('mask-layer-holes', 'Holes', true),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mask-active-spline',
        title: 'Active Spline',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.menu(
            'mask-spline-offset-mode',
            'Offset',
            'Absolute',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Absolute', label: 'Absolute'),
              BlenderMenuItem<String>(value: 'Relative', label: 'Relative'),
            ],
          ),
          BlenderPropertyFactory.menu(
            'mask-spline-interpolation',
            'Interpolation',
            'Linear',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Linear', label: 'Linear'),
              BlenderMenuItem<String>(value: 'Cardinal', label: 'Cardinal'),
            ],
          ),
          BlenderPropertyFactory.boolean('mask-spline-cyclic', 'Cyclic', true),
          BlenderPropertyFactory.boolean('mask-spline-fill', 'Fill', true),
          BlenderPropertyFactory.boolean(
            'mask-spline-self-intersection',
            'Self Intersection Check',
            true,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mask-active-point',
        title: 'Active Point',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.menu(
            'mask-point-parent',
            'Parent',
            'Movie Clip',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Movie Clip', label: 'Movie Clip'),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
          BlenderPropertyFactory.menu(
            'mask-point-parent-type',
            'Type',
            'Point Track',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Point Track',
                label: 'Point Track',
              ),
              BlenderMenuItem<String>(
                value: 'Plane Track',
                label: 'Plane Track',
              ),
            ],
          ),
          BlenderPropertyFactory.menu(
            'mask-point-object',
            'Object',
            'Camera',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Camera', label: 'Camera'),
              BlenderMenuItem<String>(value: 'Object', label: 'Object'),
            ],
          ),
          BlenderPropertyFactory.menu(
            'mask-point-track',
            'Track',
            'Track',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Track', label: 'Track'),
              BlenderMenuItem<String>(value: 'Plane', label: 'Plane'),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mask-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.menu(
            'mask-action',
            'Action',
            'MaskAction',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'MaskAction', label: 'MaskAction'),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mask-display',
        title: 'Mask Display',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean('mask-show-spline', 'Spline', true),
          BlenderPropertyFactory.menu(
            'mask-display-type',
            'Display Type',
            'Outline',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Outline', label: 'Outline'),
              BlenderMenuItem<String>(value: 'Overlay', label: 'Overlay'),
            ],
          ),
          BlenderPropertyFactory.boolean('mask-show-overlay', 'Overlay', true),
          BlenderPropertyFactory.menu(
            'mask-overlay-mode',
            'Overlay Mode',
            'Combined',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Combined', label: 'Combined'),
              BlenderMenuItem<String>(value: 'Replace', label: 'Replace'),
            ],
          ),
          BlenderPropertyFactory.number(
            'mask-blend-factor',
            'Blending Factor',
            .5,
            min: 0,
            max: 1,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mask-transforms',
        title: 'Transforms',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: toolButtons(<String>[
          'Translate',
          'Rotate',
          'Scale',
          'Scale Feather',
        ]),
      ),
      BlenderPropertyGroup(
        id: 'mask-tools',
        title: 'Mask Tools',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: toolButtons(<String>[
          'Delete',
          'Cyclic Toggle',
          'Switch Direction',
          'Set Vector Handle',
          'Clear Feather Weight',
          'Parent',
          'Clear Parent',
          'Insert Key',
          'Clear Key',
          'Reset Feather Animation',
          'Re-Key Shape Points',
        ]),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlenderPropertiesEditor(title: title, groups: _groups());
  }
}
