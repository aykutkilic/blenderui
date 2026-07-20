part of '../showcase_app.dart';

extension _ShowcaseSceneModels on _ShowcaseAppState {
  BlenderGlyph get _dataPropertiesGlyph => switch (_selectedObject) {
    'Camera' => BlenderGlyph.camera,
    'Light' => BlenderGlyph.light,
    'Curve' => BlenderGlyph.curve,
    'Text' => BlenderGlyph.curve,
    'Curves' => BlenderGlyph.curves,
    'Point Cloud' => BlenderGlyph.pointcloud,
    'Speaker' => BlenderGlyph.speaker,
    'Volume' => BlenderGlyph.volume,
    'Light Probe' => BlenderGlyph.lightprobe,
    'Grease Pencil' => BlenderGlyph.greasepencil,
    'Empty' => BlenderGlyph.empty,
    'Lattice' => BlenderGlyph.lattice,
    'Metaball' => BlenderGlyph.metaball,
    'Armature' => BlenderGlyph.armature,
    'Bone' => BlenderGlyph.bone,
    _ => BlenderGlyph.mesh,
  };

  String get _dataPropertiesTitle => switch (_selectedObject) {
    'Camera' => 'Camera Data',
    'Light' => 'Light Data',
    'Curve' => 'Curve Data',
    'Text' => 'Text Data',
    'Curves' => 'Curves Data',
    'Point Cloud' => 'Point Cloud Data',
    'Speaker' => 'Speaker Data',
    'Volume' => 'Volume Data',
    'Light Probe' => 'Light Probe Data',
    'Grease Pencil' => 'Grease Pencil Data',
    'Empty' => 'Empty Data',
    'Lattice' => 'Lattice Data',
    'Metaball' => 'Metaball Data',
    'Armature' => 'Armature Data',
    'Bone' => 'Bone Properties',
    _ => 'Mesh Data',
  };

  List<BlenderPropertyTab> get _propertyTabs => <BlenderPropertyTab>[
    const BlenderPropertyTab(
      id: 'tool',
      label: 'Tool',
      glyph: BlenderGlyph.tool,
      group: 0,
    ),
    const BlenderPropertyTab(
      id: 'render',
      label: 'Render',
      glyph: BlenderGlyph.render,
      group: 1,
    ),
    const BlenderPropertyTab(
      id: 'output',
      label: 'Output',
      glyph: BlenderGlyph.output,
      group: 1,
    ),
    const BlenderPropertyTab(
      id: 'view_layer',
      label: 'View Layer',
      glyph: BlenderGlyph.viewLayer,
      group: 2,
    ),
    const BlenderPropertyTab(
      id: 'scene',
      label: 'Scene',
      glyph: BlenderGlyph.scene,
      group: 2,
    ),
    const BlenderPropertyTab(
      id: 'world',
      label: 'World',
      glyph: BlenderGlyph.world,
      group: 2,
    ),
    const BlenderPropertyTab(
      id: 'collection',
      label: 'Collection',
      glyph: BlenderGlyph.collection,
      group: 3,
    ),
    const BlenderPropertyTab(
      id: 'object',
      label: 'Object',
      glyph: BlenderGlyph.object,
      group: 3,
    ),
    const BlenderPropertyTab(
      id: 'modifier',
      label: 'Modifiers',
      glyph: BlenderGlyph.modifier,
      group: 3,
    ),
    const BlenderPropertyTab(
      id: 'shaderfx',
      label: 'Effects',
      glyph: BlenderGlyph.shaderfx,
      group: 5,
    ),
    const BlenderPropertyTab(
      id: 'particles',
      label: 'Particles',
      glyph: BlenderGlyph.physics,
      group: 6,
    ),
    const BlenderPropertyTab(
      id: 'physics',
      label: 'Physics',
      glyph: BlenderGlyph.physics,
      group: 6,
    ),
    const BlenderPropertyTab(
      id: 'constraint',
      label: 'Constraints',
      glyph: BlenderGlyph.link,
      group: 3,
    ),
    BlenderPropertyTab(
      id: 'data',
      label: 'Data',
      glyph: _dataPropertiesGlyph,
      group: 5,
    ),
    const BlenderPropertyTab(
      id: 'bone',
      label: 'Bone',
      glyph: BlenderGlyph.bone,
      group: 5,
    ),
    const BlenderPropertyTab(
      id: 'bone_constraint',
      label: 'Bone Constraints',
      glyph: BlenderGlyph.link,
      group: 3,
    ),
    const BlenderPropertyTab(
      id: 'material',
      label: 'Material',
      glyph: BlenderGlyph.material,
      group: 4,
    ),
    const BlenderPropertyTab(
      id: 'texture',
      label: 'Texture',
      glyph: BlenderGlyph.texture,
      group: 4,
    ),
    const BlenderPropertyTab(
      id: 'strip',
      label: 'Strip',
      glyph: BlenderGlyph.sequence,
      group: 7,
    ),
    const BlenderPropertyTab(
      id: 'strip_modifier',
      label: 'Strip Modifiers',
      glyph: BlenderGlyph.modifier,
      group: 7,
    ),
  ];

  List<BlenderTreeNode<String>> get _tree {
    final colors = BlenderTheme.of(context).colors;
    if (_templateMode != _ShowcaseTemplateMode.general) {
      final suffix = _templateMode == _ShowcaseTemplateMode.storyboarding
          ? '.001'
          : '';
      return <BlenderTreeNode<String>>[
        BlenderTreeNode<String>(
          id: 'scene-collection',
          label: 'Scene Collection',
          icon: BlenderGlyph.collection,
          iconColor: colors.iconCollection,
          initiallyExpanded: true,
          children: <BlenderTreeNode<String>>[
            BlenderTreeNode<String>(
              id: 'collection',
              label: 'Collection',
              icon: BlenderGlyph.collection,
              iconColor: colors.iconCollection,
              initiallyExpanded: true,
              children: <BlenderTreeNode<String>>[
                BlenderTreeNode<String>(
                  id: 'camera',
                  label: 'Camera$suffix',
                  value: 'Camera$suffix',
                  icon: BlenderGlyph.camera,
                  iconColor: colors.iconObject,
                ),
                BlenderTreeNode<String>(
                  id: 'stroke',
                  label: 'Stroke$suffix',
                  value: 'Stroke$suffix',
                  icon: BlenderGlyph.greasepencil,
                  iconColor: colors.iconObject,
                  initiallyExpanded: true,
                  children: <BlenderTreeNode<String>>[
                    BlenderTreeNode<String>(
                      id: 'stroke-data',
                      label: 'Stroke$suffix',
                      icon: BlenderGlyph.greasepencil,
                      iconColor: colors.iconObjectData,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ];
    }
    return <BlenderTreeNode<String>>[
      BlenderTreeNode<String>(
        id: 'scene-collection',
        label: 'Scene Collection',
        icon: BlenderGlyph.collection,
        iconColor: colors.iconCollection,
        initiallyExpanded: true,
        children: <BlenderTreeNode<String>>[
          BlenderTreeNode<String>(
            id: 'collection',
            label: 'Collection',
            icon: BlenderGlyph.collection,
            iconColor: colors.iconCollection,
            initiallyExpanded: true,
            children: <BlenderTreeNode<String>>[
              BlenderTreeNode<String>(
                id: 'camera',
                label: 'Camera',
                value: 'Camera',
                icon: BlenderGlyph.camera,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'camera-data',
                    label: 'Camera',
                    icon: BlenderGlyph.camera,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'cube',
                label: 'Cube',
                value: 'Cube',
                icon: BlenderGlyph.cube,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'cube-data',
                    label: 'Cube',
                    icon: BlenderGlyph.wireframe,
                    iconColor: colors.iconObjectData,
                  ),
                  BlenderTreeNode<String>(
                    id: 'cube-material',
                    label: 'Material',
                    icon: BlenderGlyph.material,
                    iconColor: colors.iconShading,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'curve',
                label: 'Curve',
                value: 'Curve',
                icon: BlenderGlyph.curve,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'curve-data',
                    label: 'Curve',
                    icon: BlenderGlyph.curve,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'curves',
                label: 'Curves',
                value: 'Curves',
                icon: BlenderGlyph.curves,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'curves-data',
                    label: 'Curves',
                    icon: BlenderGlyph.curves,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'point-cloud',
                label: 'Point Cloud',
                value: 'Point Cloud',
                icon: BlenderGlyph.pointcloud,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'point-cloud-data',
                    label: 'Point Cloud',
                    icon: BlenderGlyph.pointcloud,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'speaker',
                label: 'Speaker',
                value: 'Speaker',
                icon: BlenderGlyph.speaker,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'speaker-data',
                    label: 'Speaker',
                    icon: BlenderGlyph.speaker,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'volume',
                label: 'Volume',
                value: 'Volume',
                icon: BlenderGlyph.volume,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'volume-data',
                    label: 'Volume',
                    icon: BlenderGlyph.volume,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'light-probe',
                label: 'Light Probe',
                value: 'Light Probe',
                icon: BlenderGlyph.lightprobe,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'light-probe-data',
                    label: 'Light Probe',
                    icon: BlenderGlyph.lightprobe,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'grease-pencil',
                label: 'Grease Pencil',
                value: 'Grease Pencil',
                icon: BlenderGlyph.greasepencil,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'grease-pencil-data',
                    label: 'Grease Pencil',
                    icon: BlenderGlyph.greasepencil,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'empty',
                label: 'Empty',
                value: 'Empty',
                icon: BlenderGlyph.empty,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'empty-data',
                    label: 'Empty',
                    icon: BlenderGlyph.empty,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'lattice',
                label: 'Lattice',
                value: 'Lattice',
                icon: BlenderGlyph.lattice,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'lattice-data',
                    label: 'Lattice',
                    icon: BlenderGlyph.lattice,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'metaball',
                label: 'Metaball',
                value: 'Metaball',
                icon: BlenderGlyph.metaball,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'metaball-data',
                    label: 'Metaball',
                    icon: BlenderGlyph.metaball,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'light',
                label: 'Light',
                value: 'Light',
                icon: BlenderGlyph.light,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'light-data',
                    label: 'Light',
                    icon: BlenderGlyph.light,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'armature',
                label: 'Armature',
                value: 'Armature',
                icon: BlenderGlyph.armature,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'armature-data',
                    label: 'Armature',
                    icon: BlenderGlyph.armature,
                    iconColor: colors.iconObjectData,
                  ),
                  BlenderTreeNode<String>(
                    id: 'armature-bone',
                    label: 'Bone',
                    value: 'Bone',
                    icon: BlenderGlyph.bone,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
            ],
          ),
          BlenderTreeNode<String>(
            id: 'world',
            label: 'World',
            icon: BlenderGlyph.world,
            iconColor: colors.iconScene,
          ),
        ],
      ),
    ];
  }

  List<BlenderTreeNode<String>> get _outlinerRoots {
    final colors = BlenderTheme.of(context).colors;
    return switch (_outlinerDisplayMode) {
      BlenderOutlinerDisplayMode.viewLayer => _tree,
      BlenderOutlinerDisplayMode.scenes => <BlenderTreeNode<String>>[
        BlenderTreeNode<String>(
          id: 'scene',
          label: 'Scene',
          icon: BlenderGlyph.scene,
          iconColor: colors.iconScene,
          initiallyExpanded: true,
          children: _tree,
        ),
      ],
      BlenderOutlinerDisplayMode.videoSequencer => <BlenderTreeNode<String>>[
        BlenderTreeNode<String>(
          id: 'sequence-editor',
          label: 'Sequence Editor',
          icon: BlenderGlyph.sequence,
          iconColor: colors.iconObject,
          initiallyExpanded: true,
          children: const <BlenderTreeNode<String>>[
            BlenderTreeNode<String>(id: 'strip-intro', label: 'Intro'),
            BlenderTreeNode<String>(id: 'strip-title', label: 'Title Card'),
            BlenderTreeNode<String>(id: 'strip-outro', label: 'Outro'),
          ],
        ),
      ],
      BlenderOutlinerDisplayMode.blenderFile => <BlenderTreeNode<String>>[
        BlenderTreeNode<String>(
          id: 'blend-file',
          label: 'Untitled',
          icon: BlenderGlyph.file,
          iconColor: colors.foregroundMuted,
          initiallyExpanded: true,
          children: const <BlenderTreeNode<String>>[
            BlenderTreeNode(id: 'objects', label: 'Objects'),
            BlenderTreeNode(id: 'collections', label: 'Collections'),
            BlenderTreeNode(id: 'materials', label: 'Materials'),
          ],
        ),
      ],
      BlenderOutlinerDisplayMode.dataApi => const <BlenderTreeNode<String>>[
        BlenderTreeNode(id: 'bpy-data', label: 'bpy.data'),
      ],
      BlenderOutlinerDisplayMode.libraryOverrides =>
        const <BlenderTreeNode<String>>[
          BlenderTreeNode(id: 'overrides', label: 'Library Overrides'),
        ],
      BlenderOutlinerDisplayMode.unusedData => const <BlenderTreeNode<String>>[
        BlenderTreeNode(id: 'orphan-data', label: 'Unused Data'),
      ],
    };
  }

  BlenderNodeGraphModel get _nodeGraph {
    if (_mainEditorType == BlenderEditorType.geometryNodeEditor) {
      return BlenderNodeGraphModel(
        nodes: List<BlenderGraphNode>.unmodifiable(_geometryNodes),
        links: List<BlenderGraphLink>.unmodifiable(_geometryLinks),
      );
    }
    return BlenderNodeGraphModel(
      nodes: List<BlenderGraphNode>.unmodifiable(_nodes),
      links: List<BlenderGraphLink>.unmodifiable(_nodeLinks),
    );
  }

  BlenderTimelineModel get _timelineModel {
    return BlenderTimelineModel(
      start: 1,
      end: 120,
      currentFrame: _frame,
      tracks: const <BlenderTimelineTrack>[
        BlenderTimelineTrack(
          id: 'cube',
          label: 'Cube',
          keyframes: <BlenderTimelineKeyframe>[
            BlenderTimelineKeyframe(1),
            BlenderTimelineKeyframe(24),
            BlenderTimelineKeyframe(60),
          ],
        ),
        BlenderTimelineTrack(
          id: 'camera',
          label: 'Camera',
          keyframes: <BlenderTimelineKeyframe>[
            BlenderTimelineKeyframe(1),
            BlenderTimelineKeyframe(80),
          ],
        ),
        BlenderTimelineTrack(
          id: 'light',
          label: 'Light',
          keyframes: <BlenderTimelineKeyframe>[
            BlenderTimelineKeyframe(1),
            BlenderTimelineKeyframe(48),
            BlenderTimelineKeyframe(96),
          ],
        ),
      ],
    );
  }

  BlenderTimelineModel get _actionModel {
    return BlenderTimelineModel(
      start: 1,
      end: 120,
      currentFrame: _frame,
      tracks: const <BlenderTimelineTrack>[
        BlenderTimelineTrack(
          id: 'summary',
          label: 'CubeAction Summary',
          keyframes: <BlenderTimelineKeyframe>[
            BlenderTimelineKeyframe(1),
            BlenderTimelineKeyframe(24),
            BlenderTimelineKeyframe(60),
          ],
        ),
        BlenderTimelineTrack(
          id: 'location-x',
          label: 'X Location',
          keyframes: <BlenderTimelineKeyframe>[
            BlenderTimelineKeyframe(1),
            BlenderTimelineKeyframe(24),
            BlenderTimelineKeyframe(60),
          ],
        ),
        BlenderTimelineTrack(
          id: 'location-y',
          label: 'Y Location',
          keyframes: <BlenderTimelineKeyframe>[
            BlenderTimelineKeyframe(1),
            BlenderTimelineKeyframe(60),
          ],
        ),
        BlenderTimelineTrack(
          id: 'rotation-z',
          label: 'Z Euler Rotation',
          keyframes: <BlenderTimelineKeyframe>[
            BlenderTimelineKeyframe(1),
            BlenderTimelineKeyframe(24),
            BlenderTimelineKeyframe(60),
          ],
        ),
      ],
    );
  }

  List<BlenderSequencerStrip> get _sequenceStrips {
    return const <BlenderSequencerStrip>[
      BlenderSequencerStrip(
        id: 'intro',
        label: 'Intro',
        start: 1,
        end: 28,
        channel: 0,
        color: Color(0xFF4772B3),
      ),
      BlenderSequencerStrip(
        id: 'title',
        label: 'Title Card',
        start: 18,
        end: 48,
        channel: 1,
        color: Color(0xFFAC8737),
      ),
      BlenderSequencerStrip(
        id: 'outro',
        label: 'Outro',
        start: 52,
        end: 96,
        channel: 0,
        color: Color(0xFF188625),
      ),
    ];
  }
}
