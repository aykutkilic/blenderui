part of '../showcase_app.dart';

extension _ShowcaseArmatureProperties on _ShowcaseAppState {
  List<BlenderPropertyGroup> get _metaballPropertyGroups {
    const elementTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Ball', label: 'Ball'),
      BlenderMenuItem<String>(value: 'Cube', label: 'Cube'),
      BlenderMenuItem<String>(value: 'Capsule', label: 'Capsule'),
      BlenderMenuItem<String>(value: 'Ellipsoid', label: 'Ellipsoid'),
      BlenderMenuItem<String>(value: 'Plane', label: 'Plane'),
    ];
    const updateMethods = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Continuous', label: 'Continuous'),
      BlenderMenuItem<String>(value: 'Half', label: 'Half'),
      BlenderMenuItem<String>(value: 'Fast', label: 'Fast'),
    ];

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'metaball',
        title: 'Metaball',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'metaball-resolution',
            'Resolution Viewport',
            .4,
          ),
          BlenderPropertyFactory.number(
            'metaball-render-resolution',
            'Render',
            .2,
          ),
          BlenderPropertyFactory.number(
            'metaball-threshold',
            'Influence Threshold',
            .6,
          ),
          BlenderPropertyFactory.choice<String>(
            'metaball-update-method',
            'Update on Edit',
            'Continuous',
            updateMethods,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'metaball-texture-space',
        title: 'Texture Space',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'metaball-auto-texspace',
            'Auto Texture Space',
            true,
          ),
          BlenderPropertyFactory.number(
            'metaball-texspace-location',
            'Location',
            0,
          ),
          BlenderPropertyFactory.number('metaball-texspace-size', 'Size', 2),
        ],
      ),
      BlenderPropertyGroup(
        id: 'metaball-active-element',
        title: 'Active Element',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'metaball-element-type',
            'Type',
            'Ball',
            elementTypes,
          ),
          BlenderPropertyFactory.number('metaball-stiffness', 'Stiffness', 2),
          BlenderPropertyFactory.number('metaball-radius', 'Radius', 1),
          BlenderPropertyFactory.boolean(
            'metaball-negative',
            'Negative',
            false,
          ),
          BlenderPropertyFactory.boolean('metaball-hide', 'Hide', false),
          BlenderPropertyFactory.number('metaball-size-x', 'Size X', 1),
          BlenderPropertyFactory.number('metaball-size-y', 'Y', 1),
          BlenderPropertyFactory.number('metaball-size-z', 'Z', 1),
        ],
      ),
      BlenderPropertyGroup(
        id: 'metaball-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Metaball', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'MetaballAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'MetaballAction',
                  label: 'MetaballAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Metaball action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'metaball-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'metaball-custom-property',
            'example_value',
            1,
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _armaturePropertyGroups {
    const displayTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Octahedral', label: 'Octahedral'),
      BlenderMenuItem<String>(value: 'Stick', label: 'Stick'),
      BlenderMenuItem<String>(value: 'B-Bone', label: 'B-Bone'),
      BlenderMenuItem<String>(value: 'Envelope', label: 'Envelope'),
    ];
    const posePositions = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Pose Position', label: 'Pose Position'),
      BlenderMenuItem<String>(value: 'Rest Position', label: 'Rest Position'),
    ];

    Widget boneCollections() => SizedBox(
      height: 132,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Expanded(
            child: BlenderBox(
              padding: EdgeInsets.zero,
              child: BlenderBoneCollectionTree(
                showPanel: false,
                collections: const <BlenderBoneCollection>[
                  BlenderBoneCollection(
                    id: 'armature-deform',
                    name: 'Deform',
                    active: true,
                    initiallyExpanded: true,
                    children: <BlenderBoneCollection>[
                      BlenderBoneCollection(
                        id: 'armature-spine',
                        name: 'Spine',
                        hasSelectedBones: true,
                      ),
                      BlenderBoneCollection(
                        id: 'armature-limbs',
                        name: 'Limbs',
                      ),
                    ],
                  ),
                  BlenderBoneCollection(
                    id: 'armature-controls',
                    name: 'Controls',
                    visible: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              BlenderIconButton(
                glyph: BlenderGlyph.plus,
                onPressed: () => _setStatus('Add bone collection'),
                tooltip: 'Add bone collection',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.minus,
                onPressed: () => _setStatus('Remove bone collection'),
                tooltip: 'Remove bone collection',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.more,
                onPressed: () => _setStatus('Bone collection specials'),
                tooltip: 'Bone collection specials',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.stepBack,
                onPressed: () => _setStatus('Move bone collection up'),
                tooltip: 'Move bone collection up',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.stepForward,
                onPressed: () => _setStatus('Move bone collection down'),
                tooltip: 'Move bone collection down',
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );

    Widget selectionSets() => SizedBox(
      height: 82,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: BlenderBox(
              padding: EdgeInsets.zero,
              child: BlenderListView<String>(
                items: const <BlenderListItem<String>>[
                  BlenderListItem<String>(id: 'sel-all', label: 'All Controls'),
                  BlenderListItem<String>(
                    id: 'sel-face',
                    label: 'Face Controls',
                  ),
                ],
                selectedId: 'sel-all',
                onSelected: (item) =>
                    _setStatus('Selection set: ${item.label}'),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Column(
            children: <Widget>[
              BlenderIconButton(
                glyph: BlenderGlyph.plus,
                onPressed: () => _setStatus('Add selection set'),
                tooltip: 'Add selection set',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.minus,
                onPressed: () => _setStatus('Remove selection set'),
                tooltip: 'Remove selection set',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.more,
                onPressed: () => _setStatus('Selection set specials'),
                tooltip: 'Selection set specials',
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'armature-pose',
        title: 'Pose',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'armature-pose-position',
            'Position',
            'Pose Position',
            posePositions,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'armature-display',
        title: 'Viewport Display',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'armature-display-type',
            'Display As',
            'Octahedral',
            displayTypes,
          ),
          BlenderPropertyFactory.boolean('armature-show-names', 'Names', true),
          BlenderPropertyFactory.boolean(
            'armature-show-shapes',
            'Shapes',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'armature-show-colors',
            'Bone Colors',
            true,
          ),
          BlenderPropertyFactory.boolean(
            'armature-in-front',
            'In Front',
            false,
          ),
          BlenderPropertyFactory.boolean('armature-show-axes', 'Axes', false),
          BlenderPropertyFactory.choice<String>(
            'armature-axes-position',
            'Position',
            'Tail',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Head', label: 'Head'),
              BlenderMenuItem<String>(value: 'Tail', label: 'Tail'),
            ],
          ),
          BlenderPropertyFactory.choice<String>(
            'armature-relation-lines',
            'Relations',
            'Head to Tail',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Head to Tail',
                label: 'Head to Tail',
              ),
              BlenderMenuItem<String>(
                value: 'Tail to Head',
                label: 'Tail to Head',
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'armature-bone-collections',
        title: 'Bone Collections',
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: boneCollections(),
      ),
      BlenderPropertyGroup(
        id: 'armature-ik',
        title: 'Inverse Kinematics',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'armature-ik-solver',
            'Solver',
            'Standard',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Standard', label: 'Standard'),
              BlenderMenuItem<String>(value: 'iTaSC', label: 'iTaSC'),
            ],
          ),
          BlenderPropertyFactory.number(
            'armature-ik-precision',
            'Precision',
            .001,
            min: 0,
            decimalDigits: 4,
          ),
          BlenderPropertyFactory.number(
            'armature-ik-iterations',
            'Iterations',
            500,
            min: 1,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.boolean(
            'armature-ik-auto-step',
            'Auto Step',
            true,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'armature-motion-paths',
        title: 'Motion Paths',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'armature-motion-paths-show',
            'Show Paths',
            true,
          ),
          BlenderPropertyFactory.number(
            'armature-motion-paths-frame-before',
            'Before',
            1,
            min: 0,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.number(
            'armature-motion-paths-frame-after',
            'After',
            20,
            min: 0,
            decimalDigits: 0,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'armature-motion-paths-display',
            title: 'Display',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'armature-motion-paths-keyframes',
                'Keyframes',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'armature-motion-paths-bone-heads',
                'Bone Heads',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'armature-motion-paths-bone-tail',
                'Bone Tails',
                false,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'armature-selection-sets',
        title: 'Selection Sets',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: selectionSets(),
      ),
      BlenderPropertyGroup(
        id: 'armature-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Armature', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'ArmatureAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'ArmatureAction',
                  label: 'ArmatureAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Armature action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'armature-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'armature-custom-property',
            'example_value',
            1,
          ),
        ],
      ),
    ];
  }
}
