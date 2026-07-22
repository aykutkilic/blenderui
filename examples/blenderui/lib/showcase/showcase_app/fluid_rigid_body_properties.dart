part of '../showcase_app.dart';

extension _ShowcaseFluidRigidBodyProperties on _ShowcaseAppState {
  List<BlenderPropertyGroup> _physicsPropertyGroupsPhysicsFluid() {
    return <BlenderPropertyGroup>[
      _closedPhysicsPanel(
        'physics-fluid',
        'Fluid',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'fluid-type',
            'Fluid Type',
            'Domain',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Domain', label: 'Domain'),
              BlenderMenuItem<String>(value: 'Flow', label: 'Flow'),
              BlenderMenuItem<String>(value: 'Effector', label: 'Effector'),
            ],
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'fluid-settings',
            title: 'Settings',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'fluid-resolution',
                'Resolution Divisions',
                '128',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: '64', label: '64'),
                  BlenderMenuItem<String>(value: '128', label: '128'),
                  BlenderMenuItem<String>(value: '256', label: '256'),
                ],
              ),
              BlenderPropertyFactory.number(
                'fluid-time-scale',
                'Time Scale',
                1,
              ),
              BlenderPropertyFactory.boolean(
                'fluid-is-resumable',
                'Is Resumable',
                false,
              ),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel(
                'fluid-border-collisions',
                'Border Collisions',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.boolean('fluid-border-x', 'X', true),
                  BlenderPropertyFactory.boolean('fluid-border-y', 'Y', true),
                  BlenderPropertyFactory.boolean('fluid-border-z', 'Z', true),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'fluid-gas',
            title: 'Gas',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number('fluid-vorticity', 'Vorticity', 2),
              BlenderPropertyFactory.boolean(
                'fluid-dissolve',
                'Dissolve',
                false,
              ),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel('fluid-dissolve', 'Dissolve'),
            ],
          ),
          _closedPhysicsPanel(
            'fluid-liquid',
            'Liquid',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'fluid-liquid-spray',
                'Spray',
                true,
              ),
              BlenderPropertyFactory.boolean('fluid-liquid-flip', 'FLIP', true),
            ],
          ),
          _closedPhysicsPanel(
            'fluid-flow-source',
            'Flow Source',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'fluid-flow-behavior',
                'Flow Behavior',
                'Inflow',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Inflow', label: 'Inflow'),
                  BlenderMenuItem<String>(value: 'Outflow', label: 'Outflow'),
                  BlenderMenuItem<String>(value: 'Geometry', label: 'Geometry'),
                ],
              ),
              BlenderPropertyFactory.number('fluid-flow-surface', 'Surface', 1),
            ],
          ),
          _closedPhysicsPanel(
            'fluid-adaptive-domain',
            'Adaptive Domain',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'fluid-adaptive-domain-enabled',
                'Enabled',
                true,
              ),
              BlenderPropertyFactory.number(
                'fluid-adaptive-margin',
                'Margin',
                4,
              ),
            ],
          ),
          _closedPhysicsPanel(
            'fluid-cache',
            'Cache',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'fluid-cache-type',
                'Type',
                'Modular',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Modular', label: 'Modular'),
                  BlenderMenuItem<String>(value: 'Replay', label: 'Replay'),
                  BlenderMenuItem<String>(value: 'Final', label: 'Final'),
                ],
              ),
              BlenderPropertyFactory.number(
                'fluid-cache-start',
                'Simulation Start',
                1,
              ),
              BlenderPropertyFactory.number('fluid-cache-end', 'End', 250),
            ],
          ),
          _closedPhysicsPanel(
            'fluid-viewport-display',
            'Viewport Display',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'fluid-display-thickness',
                'Display Thickness',
                'Both',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Both', label: 'Both'),
                  BlenderMenuItem<String>(value: 'Slice', label: 'Slice'),
                  BlenderMenuItem<String>(value: 'Full', label: 'Full'),
                ],
              ),
              BlenderPropertyFactory.number('fluid-display-slice', 'Slice', .5),
            ],
          ),
          _closedPhysicsPanel(
            'fluid-render',
            'Render',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'fluid-render-bake',
                'Bake',
                false,
              ),
              BlenderPropertyFactory.number(
                'fluid-render-resolution',
                'Resolution',
                64,
              ),
            ],
          ),
        ],
      ),
      _closedPhysicsPanel(
        'physics-dynamic-paint',
        'Dynamic Paint',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'dynamic-paint-ui-type',
            'Type',
            'Canvas',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Canvas', label: 'Canvas'),
              BlenderMenuItem<String>(value: 'Brush', label: 'Brush'),
            ],
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'dynamic-paint-settings',
            title: 'Settings',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'dynamic-paint-enabled',
                'Enabled',
                true,
              ),
              BlenderPropertyFactory.number(
                'dynamic-paint-frame-start',
                'Frame Start',
                1,
              ),
              BlenderPropertyFactory.number(
                'dynamic-paint-frame-end',
                'End',
                250,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'dynamic-paint-surface',
            title: 'Surface',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'dynamic-paint-surface-type',
                'Surface Type',
                'Paint',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Paint', label: 'Paint'),
                  BlenderMenuItem<String>(value: 'Displace', label: 'Displace'),
                  BlenderMenuItem<String>(value: 'Wave', label: 'Wave'),
                ],
              ),
              BlenderPropertyFactory.choice<String>(
                'dynamic-paint-surface-format',
                'Format',
                'Vertex',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Vertex', label: 'Vertex'),
                  BlenderMenuItem<String>(value: 'Image', label: 'Image'),
                ],
              ),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel(
                'dynamic-paint-dry',
                'Dry',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.boolean(
                    'dynamic-paint-dry-enabled',
                    'Enabled',
                    false,
                  ),
                  BlenderPropertyFactory.number(
                    'dynamic-paint-dry-speed',
                    'Speed',
                    .5,
                  ),
                ],
              ),
              _closedPhysicsPanel(
                'dynamic-paint-dissolve',
                'Dissolve',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.boolean(
                    'dynamic-paint-dissolve-enabled',
                    'Enabled',
                    false,
                  ),
                  BlenderPropertyFactory.number(
                    'dynamic-paint-dissolve-time',
                    'Time',
                    1,
                  ),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'dynamic-paint-output',
            title: 'Output',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'dynamic-paint-output-paintmaps',
                'Paintmaps',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'dynamic-paint-output-wetmaps',
                'Wetmaps',
                false,
              ),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel('dynamic-paint-paintmaps', 'Paintmaps'),
              _closedPhysicsPanel('dynamic-paint-wetmaps', 'Wetmaps'),
            ],
          ),
          BlenderPropertyGroup(
            id: 'dynamic-paint-effects',
            title: 'Effects',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'dynamic-paint-effects-enabled',
                'Enabled',
                true,
              ),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel('dynamic-paint-spread', 'Spread'),
              BlenderPropertyGroup(
                id: 'dynamic-paint-drip',
                title: 'Drip',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[],
                children: <BlenderPropertyGroup>[
                  _closedPhysicsPanel('dynamic-paint-drip-weights', 'Weights'),
                ],
              ),
              _closedPhysicsPanel('dynamic-paint-shrink', 'Shrink'),
            ],
          ),
          _closedPhysicsPanel(
            'dynamic-paint-cache',
            'Cache',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'dynamic-paint-cache-start',
                'Simulation Start',
                1,
              ),
              BlenderPropertyFactory.number(
                'dynamic-paint-cache-end',
                'End',
                250,
              ),
              BlenderPropertyFactory.boolean(
                'dynamic-paint-cache-baked',
                'Baked',
                false,
              ),
            ],
          ),
          _closedPhysicsPanel(
            'dynamic-paint-source',
            'Source',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'dynamic-paint-source-type',
                'Paint Source',
                'Mesh Volume',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Mesh Volume',
                    label: 'Mesh Volume',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Proximity',
                    label: 'Proximity',
                  ),
                ],
              ),
              BlenderPropertyFactory.number(
                'dynamic-paint-source-radius',
                'Radius',
                1,
              ),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel('dynamic-paint-falloff-ramp', 'Falloff Ramp'),
            ],
          ),
          BlenderPropertyGroup(
            id: 'dynamic-paint-velocity',
            title: 'Velocity',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'dynamic-paint-velocity-enabled',
                'Enabled',
                true,
              ),
              BlenderPropertyFactory.number(
                'dynamic-paint-velocity-factor',
                'Factor',
                1,
              ),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel('dynamic-paint-velocity-ramp', 'Ramp'),
              _closedPhysicsPanel('dynamic-paint-velocity-smudge', 'Smudge'),
            ],
          ),
          _closedPhysicsPanel(
            'dynamic-paint-waves',
            'Waves',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'dynamic-paint-waves-enabled',
                'Enabled',
                false,
              ),
              BlenderPropertyFactory.number(
                'dynamic-paint-wave-timescale',
                'Timescale',
                1,
              ),
              BlenderPropertyFactory.number(
                'dynamic-paint-wave-speed',
                'Speed',
                1,
              ),
            ],
          ),
        ],
      ),
      _closedPhysicsPanel(
        'physics-force-field',
        'Force Fields',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'force-field-type',
            'Type',
            'Force',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Force', label: 'Force'),
              BlenderMenuItem<String>(value: 'Wind', label: 'Wind'),
              BlenderMenuItem<String>(value: 'Vortex', label: 'Vortex'),
            ],
          ),
          BlenderPropertyFactory.number('force-field-strength', 'Strength', 1),
        ],
        children: <BlenderPropertyGroup>[
          _closedPhysicsPanel('force-field-settings', 'Settings'),
          _closedPhysicsPanel('force-field-falloff', 'Falloff'),
          _closedPhysicsPanel('force-field-texture', 'Texture'),
        ],
      ),
      _closedPhysicsPanel(
        'physics-rigid-body',
        'Rigid Body',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'rigid-body-type',
            'Type',
            'Active',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Active', label: 'Active'),
              BlenderMenuItem<String>(value: 'Passive', label: 'Passive'),
            ],
          ),
          BlenderPropertyFactory.number('rigid-body-mass', 'Mass', 1, min: 0),
        ],
        children: <BlenderPropertyGroup>[
          _closedPhysicsPanel(
            'rigid-body-settings',
            'Settings',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'rigid-body-enabled',
                'Dynamic',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'rigid-body-kinematic',
                'Animated',
                false,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'rigid-body-collisions',
            title: 'Collisions',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'rigid-body-collision-shape',
                'Shape',
                'Convex Hull',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Box', label: 'Box'),
                  BlenderMenuItem<String>(
                    value: 'Convex Hull',
                    label: 'Convex Hull',
                  ),
                  BlenderMenuItem<String>(value: 'Mesh', label: 'Mesh'),
                ],
              ),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel(
                'rigid-body-surface-response',
                'Surface Response',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.number(
                    'rigid-body-friction',
                    'Friction',
                    .5,
                  ),
                  BlenderPropertyFactory.number(
                    'rigid-body-restitution',
                    'Bounciness',
                    .5,
                  ),
                ],
              ),
              _closedPhysicsPanel(
                'rigid-body-sensitivity',
                'Sensitivity',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.boolean(
                    'rigid-body-use-margin',
                    'Use Margin',
                    false,
                  ),
                  BlenderPropertyFactory.number(
                    'rigid-body-margin',
                    'Margin',
                    .04,
                  ),
                ],
              ),
              _closedPhysicsPanel('rigid-body-collections', 'Collections'),
            ],
          ),
          BlenderPropertyGroup(
            id: 'rigid-body-dynamics',
            title: 'Dynamics',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'rigid-body-deactivate',
                'Enable Deactivation',
                false,
              ),
              BlenderPropertyFactory.number(
                'rigid-body-linear-velocity',
                'Linear Velocity',
                .4,
              ),
              BlenderPropertyFactory.number(
                'rigid-body-angular-velocity',
                'Angular Velocity',
                .5,
              ),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel('rigid-body-deactivation', 'Deactivation'),
            ],
          ),
          _closedPhysicsPanel(
            'rigid-body-cache',
            'Cache',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'rigid-body-cache-start',
                'Simulation Start',
                1,
              ),
              BlenderPropertyFactory.number('rigid-body-cache-end', 'End', 250),
            ],
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup>
  _physicsPropertyGroupsPhysicsRigidBodyConstraint() {
    return <BlenderPropertyGroup>[
      _closedPhysicsPanel(
        'physics-rigid-body-constraint',
        'Rigid Body Constraint',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'rigid-body-constraint-type',
            'Type',
            'Fixed',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Fixed', label: 'Fixed'),
              BlenderMenuItem<String>(value: 'Hinge', label: 'Hinge'),
              BlenderMenuItem<String>(value: 'Generic', label: 'Generic'),
              BlenderMenuItem<String>(value: 'Motor', label: 'Motor'),
            ],
          ),
        ],
        children: <BlenderPropertyGroup>[
          _closedPhysicsPanel(
            'rigid-body-constraint-settings',
            'Settings',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'rigid-body-constraint-enabled',
                'Enabled',
                true,
              ),
              BlenderPropertyFactory.boolean(
                'rigid-body-constraint-disable-collisions',
                'Disable Collisions',
                false,
              ),
              BlenderPropertyFactory.boolean(
                'rigid-body-constraint-breaking',
                'Breakable',
                false,
              ),
              BlenderPropertyFactory.number(
                'rigid-body-constraint-threshold',
                'Threshold',
                10,
              ),
            ],
          ),
          _closedPhysicsPanel(
            'rigid-body-constraint-objects',
            'Objects',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'rigid-body-constraint-first',
                'First',
                'Cube',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Cube', label: 'Cube'),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
              BlenderPropertyFactory.choice<String>(
                'rigid-body-constraint-second',
                'Second',
                'Sphere',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Sphere', label: 'Sphere'),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'rigid-body-constraint-limits',
            title: 'Limits',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel(
                'rigid-body-constraint-linear',
                'Linear',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.boolean(
                    'rigid-body-limit-x',
                    'X',
                    false,
                  ),
                  BlenderPropertyFactory.number(
                    'rigid-body-limit-x-lower',
                    'X Lower',
                    -1,
                  ),
                  BlenderPropertyFactory.number(
                    'rigid-body-limit-x-upper',
                    'Upper',
                    1,
                  ),
                  BlenderPropertyFactory.boolean(
                    'rigid-body-limit-y',
                    'Y',
                    false,
                  ),
                  BlenderPropertyFactory.boolean(
                    'rigid-body-limit-z',
                    'Z',
                    false,
                  ),
                ],
              ),
              _closedPhysicsPanel(
                'rigid-body-constraint-angular',
                'Angular',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.boolean(
                    'rigid-body-limit-ang-x',
                    'X',
                    false,
                  ),
                  BlenderPropertyFactory.number(
                    'rigid-body-limit-ang-x-lower',
                    'X Lower',
                    -1,
                  ),
                  BlenderPropertyFactory.number(
                    'rigid-body-limit-ang-x-upper',
                    'Upper',
                    1,
                  ),
                  BlenderPropertyFactory.boolean(
                    'rigid-body-limit-ang-y',
                    'Y',
                    false,
                  ),
                  BlenderPropertyFactory.boolean(
                    'rigid-body-limit-ang-z',
                    'Z',
                    false,
                  ),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'rigid-body-constraint-motor',
            title: 'Motor',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'rigid-body-motor-enabled',
                'Enabled',
                false,
              ),
              BlenderPropertyFactory.number(
                'rigid-body-motor-target-velocity',
                'Target Velocity',
                1,
              ),
              BlenderPropertyFactory.number(
                'rigid-body-motor-max-impulse',
                'Max Impulse',
                1,
              ),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel('rigid-body-motor-angular', 'Angular'),
              _closedPhysicsPanel('rigid-body-motor-linear', 'Linear'),
            ],
          ),
          BlenderPropertyGroup(
            id: 'rigid-body-constraint-springs',
            title: 'Springs',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel('rigid-body-springs-angular', 'Angular'),
              _closedPhysicsPanel('rigid-body-springs-linear', 'Linear'),
            ],
          ),
        ],
      ),
    ];
  }
}
