part of '../showcase_app.dart';

extension _ShowcasePropertyTopContent on _ShowcaseAppState {
  Widget? get _propertyTopContent {
    if (_propertyTab == 1) {
      return BlenderPropertyRow(
        label: 'Render Engine',
        editor: BlenderDropdown<String>(
          key: const ValueKey<String>('active-render-engine-field'),
          value: _renderEngine,
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(value: 'Eevee', label: 'Eevee'),
            BlenderMenuItem<String>(value: 'Cycles', label: 'Cycles'),
            BlenderMenuItem<String>(value: 'Workbench', label: 'Workbench'),
          ],
          onChanged: (value) {
            _update(() => _renderEngine = value);
            _setStatus('Render engine: $value');
          },
        ),
      );
    }
    if (_propertyTab == 4) {
      return BlenderDataBlockField<String>(
        key: const ValueKey<String>('active-scene-field'),
        value: 'Scene',
        icon: BlenderGlyph.scene,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Scene',
            label: 'Scene',
            icon: BlenderIcon(BlenderGlyph.scene, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Scene.001',
            label: 'Scene.001',
            icon: BlenderIcon(BlenderGlyph.scene, size: 14),
          ),
        ],
        onChanged: (value) => _setStatus('Selected scene $value'),
      );
    }
    if (_propertyTab == 10) {
      return SizedBox(
        height: 92,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Expanded(
              child: BlenderBox(
                key: ValueKey<String>('particle-system-list'),
                padding: EdgeInsets.zero,
                child: BlenderListView<String>(
                  items: <BlenderListItem<String>>[
                    BlenderListItem<String>(
                      id: 'particle-system-emitter',
                      label: 'Particle System',
                      icon: BlenderGlyph.physics,
                    ),
                    BlenderListItem<String>(
                      id: 'particle-system-hair',
                      label: 'Hair System',
                      icon: BlenderGlyph.physics,
                    ),
                  ],
                  selectedId: 'particle-system-emitter',
                ),
              ),
            ),
            const SizedBox(width: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                BlenderIconButton(
                  glyph: BlenderGlyph.plus,
                  onPressed: () => _setStatus('Add particle system'),
                  tooltip: 'Add particle system',
                  size: 22,
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.minus,
                  onPressed: () => _setStatus('Remove particle system'),
                  tooltip: 'Remove particle system',
                  size: 22,
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.more,
                  onPressed: () => _setStatus('Particle system menu'),
                  tooltip: 'Particle system menu',
                  size: 22,
                ),
              ],
            ),
          ],
        ),
      );
    }
    if (_propertyTab == 14) {
      return BlenderDataBlockField<String>(
        key: const ValueKey<String>('active-bone-field'),
        value: 'Upper Arm',
        icon: BlenderGlyph.bone,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Upper Arm',
            label: 'Upper Arm',
            icon: BlenderIcon(BlenderGlyph.bone, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Forearm',
            label: 'Forearm',
            icon: BlenderIcon(BlenderGlyph.bone, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Hand',
            label: 'Hand',
            icon: BlenderIcon(BlenderGlyph.bone, size: 14),
          ),
        ],
        onChanged: (value) => _setStatus('Selected bone $value'),
      );
    }
    if (_propertyTab == 17) {
      return BlenderDataBlockField<String>(
        key: const ValueKey<String>('active-texture-field'),
        value: 'Noise Texture',
        icon: BlenderGlyph.texture,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Noise Texture',
            label: 'Noise Texture',
            icon: BlenderIcon(BlenderGlyph.texture, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Musgrave',
            label: 'Musgrave',
            icon: BlenderIcon(BlenderGlyph.texture, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Image Texture',
            label: 'Image Texture',
            icon: BlenderIcon(BlenderGlyph.image, size: 14),
          ),
        ],
        onChanged: (value) => _setStatus('Selected texture $value'),
      );
    }
    if (_propertyTab == 6) {
      return BlenderDataBlockField<String>(
        key: const ValueKey<String>('active-collection-field'),
        value: 'Collection',
        icon: BlenderGlyph.collection,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Collection',
            label: 'Collection',
            icon: BlenderIcon(BlenderGlyph.collection, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Environment',
            label: 'Environment',
            icon: BlenderIcon(BlenderGlyph.collection, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Characters',
            label: 'Characters',
            icon: BlenderIcon(BlenderGlyph.collection, size: 14),
          ),
        ],
        onChanged: (value) => _setStatus('Selected collection $value'),
      );
    }
    if (_propertyTab == 3) {
      return BlenderDataBlockField<String>(
        key: const ValueKey<String>('active-view-layer-field'),
        value: 'ViewLayer',
        icon: BlenderGlyph.viewLayer,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'ViewLayer',
            label: 'ViewLayer',
            icon: BlenderIcon(BlenderGlyph.viewLayer, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Lighting',
            label: 'Lighting',
            icon: BlenderIcon(BlenderGlyph.viewLayer, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Compositing',
            label: 'Compositing',
            icon: BlenderIcon(BlenderGlyph.viewLayer, size: 14),
          ),
        ],
        onChanged: (value) => _setStatus('Selected view layer $value'),
      );
    }
    if (_propertyTab == 16) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Expanded(
                  child: BlenderListView<String>(
                    items: const <BlenderListItem<String>>[
                      BlenderListItem<String>(
                        id: 'material-slot-0',
                        label: 'Material',
                        value: 'Material',
                        icon: BlenderGlyph.material,
                      ),
                      BlenderListItem<String>(
                        id: 'material-slot-1',
                        label: 'Metallic Accent',
                        value: 'Metallic Accent',
                        icon: BlenderGlyph.material,
                      ),
                    ],
                    selectedId: 'material-slot-0',
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    BlenderIconButton(
                      glyph: BlenderGlyph.plus,
                      onPressed: () => _setStatus('Add material slot'),
                      tooltip: 'Add material slot',
                      size: 22,
                    ),
                    BlenderIconButton(
                      glyph: BlenderGlyph.minus,
                      onPressed: () => _setStatus('Remove material slot'),
                      tooltip: 'Remove material slot',
                      size: 22,
                    ),
                    BlenderIconButton(
                      glyph: BlenderGlyph.stepBack,
                      onPressed: () => _setStatus('Move material slot up'),
                      tooltip: 'Move material slot up',
                      size: 22,
                    ),
                    BlenderIconButton(
                      glyph: BlenderGlyph.stepForward,
                      onPressed: () => _setStatus('Move material slot down'),
                      tooltip: 'Move material slot down',
                      size: 22,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          BlenderDataBlockField<String>(
            key: const ValueKey<String>('active-material-field'),
            value: 'Material',
            icon: BlenderGlyph.material,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Material',
                label: 'Material',
                icon: BlenderIcon(BlenderGlyph.material, size: 14),
              ),
              BlenderMenuItem<String>(
                value: 'Metallic Accent',
                label: 'Metallic Accent',
                icon: BlenderIcon(BlenderGlyph.material, size: 14),
              ),
            ],
            onChanged: (value) => _setStatus('Selected material $value'),
          ),
        ],
      );
    }
    if (_propertyTab == 13) {
      final isCamera = _selectedObject == 'Camera';
      final isLight = _selectedObject == 'Light';
      final isCurve = _selectedObject == 'Curve';
      final isText = _selectedObject == 'Text';
      final isCurves = _selectedObject == 'Curves';
      final isPointCloud = _selectedObject == 'Point Cloud';
      final isSpeaker = _selectedObject == 'Speaker';
      final isVolume = _selectedObject == 'Volume';
      final isLightProbe = _selectedObject == 'Light Probe';
      final isGreasePencil = _selectedObject == 'Grease Pencil';
      final isEmpty = _selectedObject == 'Empty';
      final isLattice = _selectedObject == 'Lattice';
      final isMetaball = _selectedObject == 'Metaball';
      final isArmature = _selectedObject == 'Armature';
      final isBone = _selectedObject == 'Bone';
      final dataName = isCamera
          ? 'Camera'
          : isLight
          ? 'Light'
          : isCurve
          ? 'Curve'
          : isText
          ? 'Text'
          : isCurves
          ? 'Curves'
          : isPointCloud
          ? 'Point Cloud'
          : isSpeaker
          ? 'Speaker'
          : isVolume
          ? 'Volume'
          : isLightProbe
          ? 'Light Probe'
          : isGreasePencil
          ? 'Grease Pencil'
          : isEmpty
          ? 'Empty'
          : isLattice
          ? 'Lattice'
          : isMetaball
          ? 'Metaball'
          : isArmature
          ? 'Armature'
          : isBone
          ? 'Bone'
          : 'Cube';
      final dataIcon = isCamera
          ? BlenderGlyph.camera
          : isLight
          ? BlenderGlyph.light
          : isCurve
          ? BlenderGlyph.curve
          : isText
          ? BlenderGlyph.curve
          : isCurves
          ? BlenderGlyph.curves
          : isPointCloud
          ? BlenderGlyph.pointcloud
          : isSpeaker
          ? BlenderGlyph.speaker
          : isVolume
          ? BlenderGlyph.volume
          : isLightProbe
          ? BlenderGlyph.lightprobe
          : isGreasePencil
          ? BlenderGlyph.greasepencil
          : isEmpty
          ? BlenderGlyph.empty
          : isLattice
          ? BlenderGlyph.lattice
          : isMetaball
          ? BlenderGlyph.metaball
          : isArmature
          ? BlenderGlyph.armature
          : isBone
          ? BlenderGlyph.bone
          : BlenderGlyph.mesh;
      return BlenderDataBlockField<String>(
        key: const ValueKey<String>('active-data-field'),
        value: dataName,
        icon: dataIcon,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Cube',
            label: 'Cube',
            icon: BlenderIcon(BlenderGlyph.mesh, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Suzanne',
            label: 'Suzanne',
            icon: BlenderIcon(BlenderGlyph.mesh, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Camera',
            label: 'Camera',
            icon: BlenderIcon(BlenderGlyph.camera, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Light',
            label: 'Light',
            icon: BlenderIcon(BlenderGlyph.light, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Curve',
            label: 'Curve',
            icon: BlenderIcon(BlenderGlyph.curve, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Text',
            label: 'Text',
            icon: BlenderIcon(BlenderGlyph.curve, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Curves',
            label: 'Curves',
            icon: BlenderIcon(BlenderGlyph.curves, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Point Cloud',
            label: 'Point Cloud',
            icon: BlenderIcon(BlenderGlyph.pointcloud, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Speaker',
            label: 'Speaker',
            icon: BlenderIcon(BlenderGlyph.speaker, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Volume',
            label: 'Volume',
            icon: BlenderIcon(BlenderGlyph.volume, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Light Probe',
            label: 'Light Probe',
            icon: BlenderIcon(BlenderGlyph.lightprobe, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Grease Pencil',
            label: 'Grease Pencil',
            icon: BlenderIcon(BlenderGlyph.greasepencil, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Empty',
            label: 'Empty',
            icon: BlenderIcon(BlenderGlyph.empty, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Empty',
            label: 'Empty',
            icon: BlenderIcon(BlenderGlyph.empty, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Volume',
            label: 'Volume',
            icon: BlenderIcon(BlenderGlyph.volume, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Speaker',
            label: 'Speaker',
            icon: BlenderIcon(BlenderGlyph.speaker, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Lattice',
            label: 'Lattice',
            icon: BlenderIcon(BlenderGlyph.lattice, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Metaball',
            label: 'Metaball',
            icon: BlenderIcon(BlenderGlyph.metaball, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Armature',
            label: 'Armature',
            icon: BlenderIcon(BlenderGlyph.armature, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Bone',
            label: 'Bone',
            icon: BlenderIcon(BlenderGlyph.bone, size: 14),
          ),
        ],
        onChanged: (value) {
          _update(() => _selectedObject = value);
          _application.editorSession.selectOutlinerItem('showcase', value);
          _setStatus('Selected data $value');
        },
      );
    }
    if (_propertyTab == 5) {
      return BlenderDataBlockField<String>(
        key: const ValueKey<String>('active-world-field'),
        value: 'World',
        icon: BlenderGlyph.world,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'World',
            label: 'World',
            icon: BlenderIcon(BlenderGlyph.world, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'World.001',
            label: 'World.001',
            icon: BlenderIcon(BlenderGlyph.world, size: 14),
          ),
        ],
        onChanged: (value) => _setStatus('Selected world $value'),
      );
    }
    if (_propertyTab == 7) {
      return BlenderDataBlockField<String>(
        key: const ValueKey<String>('active-object-field'),
        value: _selectedObject,
        icon: BlenderGlyph.object,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Camera',
            label: 'Camera',
            icon: BlenderIcon(BlenderGlyph.camera, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Cube',
            label: 'Cube',
            icon: BlenderIcon(BlenderGlyph.object, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Curve',
            label: 'Curve',
            icon: BlenderIcon(BlenderGlyph.curve, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Curves',
            label: 'Curves',
            icon: BlenderIcon(BlenderGlyph.curves, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Point Cloud',
            label: 'Point Cloud',
            icon: BlenderIcon(BlenderGlyph.pointcloud, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Lattice',
            label: 'Lattice',
            icon: BlenderIcon(BlenderGlyph.lattice, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Metaball',
            label: 'Metaball',
            icon: BlenderIcon(BlenderGlyph.metaball, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Light',
            label: 'Light',
            icon: BlenderIcon(BlenderGlyph.light, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Light Probe',
            label: 'Light Probe',
            icon: BlenderIcon(BlenderGlyph.lightprobe, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Grease Pencil',
            label: 'Grease Pencil',
            icon: BlenderIcon(BlenderGlyph.greasepencil, size: 14),
          ),
        ],
        onChanged: (value) => _update(() => _selectedObject = value),
      );
    }
    if (_propertyTab != 0) return null;
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 190),
        child: SizedBox(
          key: const ValueKey<String>('tool-selection-operation-group'),
          width: double.infinity,
          child: BlenderSegmentedControl<String>(
            value: _selectionMode,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Set',
                label: '',
                icon: BlenderIcon(BlenderGlyph.selectBox, size: 16),
              ),
              BlenderMenuItem<String>(
                value: 'Extend',
                label: '',
                icon: BlenderIcon(BlenderGlyph.selectExtend, size: 16),
              ),
              BlenderMenuItem<String>(
                value: 'Subtract',
                label: '',
                icon: BlenderIcon(BlenderGlyph.selectSubtract, size: 16),
              ),
              BlenderMenuItem<String>(
                value: 'Difference',
                label: '',
                icon: BlenderIcon(BlenderGlyph.selectDifference, size: 16),
              ),
              BlenderMenuItem<String>(
                value: 'Intersect',
                label: '',
                icon: BlenderIcon(BlenderGlyph.selectIntersect, size: 16),
              ),
            ],
            onChanged: (value) => _update(() => _selectionMode = value),
          ),
        ),
      ),
    );
  }
}
