part of '../showcase_app.dart';

extension _ShowcasePhysicsProperties on _ShowcaseAppState {
  List<BlenderMenuItem<String>> get _physicsBendingModels =>
      const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Angular', label: 'Angular'),
        BlenderMenuItem<String>(value: 'Bending', label: 'Bending'),
      ];

  Widget _physicsButtons() {
    Widget button(String label) => BlenderButton(
      label: label,
      onPressed: () => _setStatus('$label physics'),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              button('Force Field'),
              button('Collision'),
              button('Cloth'),
              button('Dynamic Paint'),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              button('Soft Body'),
              button('Fluid'),
              button('Rigid Body'),
              button('Rigid Body Constraint'),
            ],
          ),
        ),
      ],
    );
  }

  BlenderPropertyGroup _closedPhysicsPanel(
    String id,
    String title, {
    List<BlenderPropertyDescriptor<dynamic>> properties =
        const <BlenderPropertyDescriptor<dynamic>>[],
    List<BlenderPropertyGroup> children = const <BlenderPropertyGroup>[],
  }) => BlenderPropertyGroup(
    id: id,
    title: title,
    initiallyExpanded: false,
    properties: properties,
    children: children,
  );

  List<BlenderPropertyGroup> get _physicsPropertyGroups {
    return <BlenderPropertyGroup>[
      ..._physicsPropertyGroupsPhysicsAdd(),
      ..._physicsPropertyGroupsPhysicsFluid(),
      ..._physicsPropertyGroupsPhysicsRigidBodyConstraint(),
      ..._physicsPropertyGroupsPhysicsParticles(),
    ];
  }

  List<BlenderPropertyGroup> _physicsPropertyGroupsPhysicsAdd() {
    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'physics-add',
        title: 'Add Physics',
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: _physicsButtons(),
      ),
      BlenderPropertyGroup(
        id: 'physics-cloth',
        title: 'Cloth',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'cloth-quality',
            'Quality Steps',
            5,
            min: 1,
            max: 80,
          ),
          BlenderPropertyFactory.number(
            'cloth-speed',
            'Speed Multiplier',
            1,
            min: .01,
            max: 10,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'cloth-physical-properties',
            title: 'Physical Properties',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'cloth-mass',
                'Vertex Mass',
                .3,
                min: 0,
              ),
              BlenderPropertyFactory.number(
                'cloth-air-damping',
                'Air Viscosity',
                1,
                min: 0,
              ),
              BlenderPropertyFactory.choice<String>(
                'cloth-bending-model',
                'Bending Model',
                'Angular',
                _physicsBendingModels,
              ),
            ],
            children: <BlenderPropertyGroup>[
              BlenderPropertyGroup(
                id: 'cloth-stiffness',
                title: 'Stiffness',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.number(
                    'cloth-tension',
                    'Tension',
                    15,
                    min: 0,
                  ),
                  BlenderPropertyFactory.number(
                    'cloth-compression',
                    'Compression',
                    15,
                    min: 0,
                  ),
                  BlenderPropertyFactory.number(
                    'cloth-shear',
                    'Shear',
                    5,
                    min: 0,
                  ),
                  BlenderPropertyFactory.number(
                    'cloth-bending',
                    'Bending',
                    .5,
                    min: 0,
                  ),
                ],
              ),
              BlenderPropertyGroup(
                id: 'cloth-damping',
                title: 'Damping',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.number(
                    'cloth-tension-damping',
                    'Tension',
                    5,
                    min: 0,
                  ),
                  BlenderPropertyFactory.number(
                    'cloth-compression-damping',
                    'Compression',
                    5,
                    min: 0,
                  ),
                  BlenderPropertyFactory.number(
                    'cloth-shear-damping',
                    'Shear',
                    5,
                    min: 0,
                  ),
                  BlenderPropertyFactory.number(
                    'cloth-bending-damping',
                    'Bending',
                    .5,
                    min: 0,
                  ),
                ],
              ),
              _closedPhysicsPanel(
                'cloth-internal-springs',
                'Internal Springs',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.boolean(
                    'cloth-use-internal-springs',
                    'Enabled',
                    false,
                  ),
                  BlenderPropertyFactory.number(
                    'cloth-internal-max-length',
                    'Max Spring Creation Length',
                    0.2,
                    min: 0,
                  ),
                  BlenderPropertyFactory.number(
                    'cloth-internal-tension',
                    'Tension',
                    15,
                    min: 0,
                  ),
                  BlenderPropertyFactory.number(
                    'cloth-internal-compression',
                    'Compression',
                    15,
                    min: 0,
                  ),
                ],
              ),
              _closedPhysicsPanel(
                'cloth-pressure',
                'Pressure',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.boolean(
                    'cloth-use-pressure',
                    'Enabled',
                    false,
                  ),
                  BlenderPropertyFactory.number(
                    'cloth-pressure-force',
                    'Uniform Pressure Force',
                    1,
                    min: 0,
                  ),
                  BlenderPropertyFactory.boolean(
                    'cloth-custom-volume',
                    'Custom Volume',
                    false,
                  ),
                  BlenderPropertyFactory.number(
                    'cloth-pressure-factor',
                    'Pressure Factor',
                    1,
                  ),
                ],
              ),
            ],
          ),
          _closedPhysicsPanel(
            'cloth-cache',
            'Cache',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'cloth-cache-start',
                'Simulation Start',
                1,
                min: 0,
              ),
              BlenderPropertyFactory.number(
                'cloth-cache-end',
                'End',
                250,
                min: 1,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.boolean(
                'cloth-cache-disk',
                'Disk Cache',
                false,
              ),
            ],
          ),
          _closedPhysicsPanel(
            'cloth-shape',
            'Shape',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyDescriptor<String>(
                id: 'cloth-pin-group',
                label: 'Pin Group',
                value: 'Pin',
                editorBuilder: (context, value, onChanged) =>
                    BlenderDropdown<String>(
                      value: value,
                      items: const <BlenderMenuItem<String>>[
                        BlenderMenuItem<String>(value: 'Pin', label: 'Pin'),
                        BlenderMenuItem<String>(value: 'None', label: 'None'),
                      ],
                      onChanged: onChanged,
                    ),
                onChanged: (_) => _setStatus('Pin Group changed'),
              ),
              BlenderPropertyFactory.number(
                'cloth-pin-stiffness',
                'Stiffness',
                1,
                min: 0,
                max: 1,
              ),
              BlenderPropertyFactory.boolean('cloth-sewing', 'Sewing', false),
              BlenderPropertyFactory.number(
                'cloth-shrinking',
                'Shrinking Factor',
                0,
                min: -1,
                max: 1,
              ),
              BlenderPropertyFactory.boolean(
                'cloth-dynamic-mesh',
                'Dynamic Mesh',
                false,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'cloth-collisions',
            title: 'Collisions',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'cloth-collision-quality',
                'Quality',
                2,
                min: 1,
                max: 20,
              ),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel(
                'cloth-object-collisions',
                'Object Collisions',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.boolean(
                    'cloth-object-collision-enabled',
                    'Enabled',
                    true,
                  ),
                  BlenderPropertyFactory.number(
                    'cloth-object-distance',
                    'Distance',
                    .015,
                    min: 0,
                  ),
                  BlenderPropertyFactory.number(
                    'cloth-object-impulse',
                    'Impulse Clamp',
                    0,
                    min: 0,
                  ),
                ],
              ),
              _closedPhysicsPanel(
                'cloth-self-collisions',
                'Self Collisions',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.boolean(
                    'cloth-self-collision-enabled',
                    'Enabled',
                    false,
                  ),
                  BlenderPropertyFactory.number(
                    'cloth-self-friction',
                    'Friction',
                    0,
                    min: 0,
                  ),
                  BlenderPropertyFactory.number(
                    'cloth-self-distance',
                    'Distance',
                    .02,
                    min: 0,
                  ),
                ],
              ),
            ],
          ),
          _closedPhysicsPanel(
            'cloth-property-weights',
            'Property Weights',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'cloth-weight-structural',
                'Structural Max',
                1,
                min: 0,
              ),
              BlenderPropertyFactory.number(
                'cloth-weight-shear',
                'Shear Max',
                1,
                min: 0,
              ),
              BlenderPropertyFactory.number(
                'cloth-weight-bending',
                'Bending Max',
                1,
                min: 0,
              ),
              BlenderPropertyFactory.number(
                'cloth-weight-shrink',
                'Shrinking Max',
                1,
                min: 0,
              ),
            ],
          ),
          _closedPhysicsPanel(
            'cloth-field-weights',
            'Field Weights',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'cloth-field-gravity',
                'Gravity',
                1,
                min: 0,
              ),
              BlenderPropertyFactory.number(
                'cloth-field-wind',
                'Wind',
                1,
                min: 0,
              ),
              BlenderPropertyFactory.number(
                'cloth-field-turbulence',
                'Turbulence',
                1,
                min: 0,
              ),
            ],
          ),
        ],
      ),
      _closedPhysicsPanel(
        'physics-soft-body',
        'Soft Body',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number('soft-body-mass', 'Mass', 1, min: 0),
          BlenderPropertyFactory.number('soft-body-speed', 'Speed', 1, min: 0),
        ],
        children: <BlenderPropertyGroup>[
          _closedPhysicsPanel(
            'soft-body-object',
            'Object',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'soft-body-friction',
                'Friction',
                .5,
                min: 0,
              ),
              BlenderPropertyFactory.number(
                'soft-body-object-mass',
                'Mass',
                1,
                min: 0,
              ),
              BlenderPropertyFactory.choice<String>(
                'soft-body-control-point',
                'Control Point',
                'None',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                  BlenderMenuItem<String>(value: 'Mass', label: 'Mass'),
                ],
              ),
            ],
          ),
          _closedPhysicsPanel(
            'soft-body-simulation',
            'Simulation',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'soft-body-simulation-speed',
                'Speed',
                1,
                min: 0,
              ),
            ],
          ),
          _closedPhysicsPanel(
            'soft-body-cache',
            'Cache',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'soft-body-cache-start',
                'Simulation Start',
                1,
              ),
              BlenderPropertyFactory.number('soft-body-cache-end', 'End', 250),
              BlenderPropertyFactory.boolean(
                'soft-body-cache-disk',
                'Disk Cache',
                false,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'soft-body-goal',
            title: 'Goal',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'soft-body-use-goal',
                'Enabled',
                false,
              ),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel(
                'soft-body-goal-strengths',
                'Strengths',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.number(
                    'soft-body-goal-default',
                    'Default',
                    .5,
                  ),
                  BlenderPropertyFactory.number('soft-body-goal-min', 'Min', 0),
                  BlenderPropertyFactory.number('soft-body-goal-max', 'Max', 1),
                ],
              ),
              _closedPhysicsPanel(
                'soft-body-goal-settings',
                'Settings',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.number(
                    'soft-body-goal-spring',
                    'Stiffness',
                    .5,
                  ),
                  BlenderPropertyFactory.number(
                    'soft-body-goal-friction',
                    'Damping',
                    .5,
                  ),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'soft-body-edges',
            title: 'Edges',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'soft-body-use-edges',
                'Enabled',
                true,
              ),
              BlenderPropertyFactory.number('soft-body-pull', 'Pull', .5),
              BlenderPropertyFactory.number('soft-body-push', 'Push', .5),
              BlenderPropertyFactory.number(
                'soft-body-edge-damping',
                'Damping',
                .5,
              ),
              BlenderPropertyFactory.number('soft-body-bend', 'Bend', .5),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel(
                'soft-body-aerodynamics',
                'Aerodynamics',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.number(
                    'soft-body-aero-factor',
                    'Factor',
                    1,
                  ),
                ],
              ),
              _closedPhysicsPanel(
                'soft-body-edge-stiffness',
                'Stiffness',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.number(
                    'soft-body-spring-length',
                    'Length',
                    1,
                  ),
                  BlenderPropertyFactory.boolean(
                    'soft-body-edge-collision',
                    'Edge',
                    false,
                  ),
                  BlenderPropertyFactory.boolean(
                    'soft-body-face-collision',
                    'Face',
                    false,
                  ),
                ],
              ),
            ],
          ),
          _closedPhysicsPanel(
            'soft-body-self-collision',
            'Self Collision',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'soft-body-use-self-collision',
                'Enabled',
                false,
              ),
              BlenderPropertyFactory.number(
                'soft-body-self-friction',
                'Friction',
                .5,
              ),
              BlenderPropertyFactory.number(
                'soft-body-self-distance',
                'Ball Size',
                .1,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'soft-body-solver',
            title: 'Solver',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'soft-body-min-step',
                'Min Step',
                .01,
              ),
              BlenderPropertyFactory.number(
                'soft-body-max-step',
                'Max Step',
                .1,
              ),
              BlenderPropertyFactory.number('soft-body-choke', 'Choke', .5),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel('soft-body-diagnostics', 'Diagnostics'),
              _closedPhysicsPanel('soft-body-helpers', 'Helpers'),
            ],
          ),
          _closedPhysicsPanel(
            'soft-body-field-weights',
            'Field Weights',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'soft-body-field-gravity',
                'Gravity',
                1,
              ),
              BlenderPropertyFactory.number('soft-body-field-wind', 'Wind', 1),
              BlenderPropertyFactory.number(
                'soft-body-field-turbulence',
                'Turbulence',
                1,
              ),
            ],
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _particlePropertyGroups {
    final particleSystem = _physicsPropertyGroups.firstWhere(
      (group) => group.title == 'Particle System',
    );
    return particleSystem.children;
  }

  List<BlenderPropertyGroup> get _dataPropertyGroups =>
      switch (_selectedObject) {
        'Camera' => _cameraPropertyGroups,
        'Light' => _lightPropertyGroups,
        'Curve' => _curvePropertyGroups,
        'Text' => _fontCurvePropertyGroups,
        'Curves' => _curvesPropertyGroups,
        'Point Cloud' => _pointCloudPropertyGroups,
        'Speaker' => _speakerPropertyGroups,
        'Volume' => _volumePropertyGroups,
        'Light Probe' => _lightProbePropertyGroups,
        'Grease Pencil' => _greasePencilPropertyGroups,
        'Empty' => _emptyPropertyGroups,
        'Lattice' => _latticePropertyGroups,
        'Metaball' => _metaballPropertyGroups,
        'Armature' => _armaturePropertyGroups,
        'Bone' => _bonePropertyGroups,
        _ => _meshPropertyGroups,
      };

  List<BlenderPropertyGroup> get _toolPropertyGroups {
    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'tool-options',
        title: 'Options',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<bool>(
            id: 'select-through',
            label: 'Select Through',
            value: _renderRegion,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (value) => _update(() => _renderRegion = value),
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'select-overlap',
            label: 'Select Overlap',
            value: !_cropToRenderRegion,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (value) => _update(() => _cropToRenderRegion = !value),
          ),
        ],
      ),
    ];
  }
}
