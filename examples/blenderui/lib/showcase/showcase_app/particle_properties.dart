part of '../showcase_app.dart';

extension _ShowcaseParticleProperties on _ShowcaseAppState {
  List<BlenderPropertyGroup> _physicsPropertyGroupsPhysicsParticles() {
    return <BlenderPropertyGroup>[
      _closedPhysicsPanel(
        'physics-particles',
        'Particle System',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'particle-type',
            'Type',
            'Emitter',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Emitter', label: 'Emitter'),
              BlenderMenuItem<String>(value: 'Hair', label: 'Hair'),
              BlenderMenuItem<String>(value: 'Boids', label: 'Boids'),
            ],
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'particle-emission',
            title: 'Emission',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'particle-number',
                'Number',
                1000,
                min: 0,
              ),
              BlenderPropertyFactory.number(
                'particle-frame-start',
                'Frame Start',
                1,
              ),
              BlenderPropertyFactory.number('particle-frame-end', 'End', 200),
              BlenderPropertyFactory.number(
                'particle-lifetime',
                'Lifetime',
                50,
                min: 0,
              ),
              BlenderPropertyFactory.number(
                'particle-lifetime-random',
                'Randomize',
                0,
                min: 0,
              ),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel(
                'particle-source',
                'Source',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.choice<String>(
                    'particle-source-surface',
                    'Emit From',
                    'Faces',
                    const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'Faces', label: 'Faces'),
                      BlenderMenuItem<String>(
                        value: 'Vertices',
                        label: 'Vertices',
                      ),
                      BlenderMenuItem<String>(value: 'Volume', label: 'Volume'),
                    ],
                  ),
                  BlenderPropertyFactory.number(
                    'particle-source-jitter',
                    'Jitter',
                    0,
                  ),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'particle-hair-dynamics',
            title: 'Hair Dynamics',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'particle-hair-dynamics-enabled',
                'Enabled',
                false,
              ),
              BlenderPropertyFactory.number(
                'particle-hair-dynamics-quality',
                'Quality Steps',
                5,
                min: 1,
              ),
              BlenderPropertyFactory.number(
                'particle-hair-dynamics-pin-stiffness',
                'Pin Goal Strength',
                0.5,
                min: 0,
                max: 1,
              ),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel(
                'particle-hair-dynamics-collisions',
                'Collisions',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.number(
                    'particle-hair-collision-quality',
                    'Quality',
                    5,
                    min: 1,
                  ),
                  BlenderPropertyFactory.number(
                    'particle-hair-collision-distance',
                    'Distance',
                    0.005,
                    min: 0,
                  ),
                  BlenderPropertyFactory.number(
                    'particle-hair-collision-impulse',
                    'Impulse Clamp',
                    0,
                    min: 0,
                  ),
                ],
              ),
              _closedPhysicsPanel(
                'particle-hair-dynamics-structure',
                'Structure',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.number(
                    'particle-hair-mass',
                    'Mass',
                    1,
                    min: 0,
                  ),
                  BlenderPropertyFactory.number(
                    'particle-hair-stiffness',
                    'Stiffness',
                    15,
                    min: 0,
                  ),
                  BlenderPropertyFactory.number(
                    'particle-hair-damping',
                    'Damping',
                    5,
                    min: 0,
                  ),
                ],
              ),
              _closedPhysicsPanel(
                'particle-hair-dynamics-volume',
                'Volume',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.number(
                    'particle-hair-air-damping',
                    'Air Drag',
                    1,
                    min: 0,
                  ),
                  BlenderPropertyFactory.number(
                    'particle-hair-density-target',
                    'Density Target',
                    1,
                    min: 0,
                  ),
                ],
              ),
            ],
          ),
          _closedPhysicsPanel(
            'particle-cache',
            'Cache',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'particle-cache-start',
                'Simulation Start',
                1,
              ),
              BlenderPropertyFactory.number('particle-cache-end', 'End', 200),
              BlenderPropertyFactory.boolean(
                'particle-cache-baked',
                'Baked',
                false,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'particle-velocity',
            title: 'Velocity',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'particle-normal-velocity',
                'Normal',
                1,
              ),
              BlenderPropertyFactory.number(
                'particle-object-velocity',
                'Object Aligned',
                0,
              ),
              BlenderPropertyFactory.number(
                'particle-tangent-velocity',
                'Tangent',
                0,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'particle-rotation',
            title: 'Rotation',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'particle-rotation-enabled',
                'Enabled',
                false,
              ),
              BlenderPropertyFactory.choice<String>(
                'particle-rotation-orientation',
                'Orientation Axis',
                'Velocity / Hair',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Velocity / Hair',
                    label: 'Velocity / Hair',
                  ),
                  BlenderMenuItem<String>(value: 'Normal', label: 'Normal'),
                ],
              ),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel(
                'particle-angular-velocity',
                'Angular Velocity',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.number(
                    'particle-angular-factor',
                    'Factor',
                    1,
                  ),
                  BlenderPropertyFactory.number(
                    'particle-angular-random',
                    'Randomize',
                    0,
                  ),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'particle-physics',
            title: 'Physics',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'particle-physics-type',
                'Physics Type',
                'Newtonian',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Newtonian',
                    label: 'Newtonian',
                  ),
                  BlenderMenuItem<String>(value: 'Boids', label: 'Boids'),
                  BlenderMenuItem<String>(value: 'Keyed', label: 'Keyed'),
                  BlenderMenuItem<String>(value: 'Fluid', label: 'Fluid'),
                ],
              ),
              BlenderPropertyFactory.number(
                'particle-physics-size',
                'Particle Size',
                .05,
                min: 0,
              ),
              BlenderPropertyFactory.number(
                'particle-physics-brownian',
                'Brownian',
                0,
                min: 0,
              ),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel('particle-physics-advanced', 'Advanced'),
              BlenderPropertyGroup(
                id: 'particle-physics-springs',
                title: 'Springs',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[],
                children: <BlenderPropertyGroup>[
                  BlenderPropertyGroup(
                    id: 'particle-physics-viscoelastic-springs',
                    title: 'Viscoelastic Springs',
                    initiallyExpanded: false,
                    properties: <BlenderPropertyDescriptor<dynamic>>[],
                    children: <BlenderPropertyGroup>[
                      _closedPhysicsPanel(
                        'particle-physics-viscoelastic-advanced',
                        'Advanced',
                      ),
                    ],
                  ),
                ],
              ),
              _closedPhysicsPanel('particle-physics-movement', 'Movement'),
              _closedPhysicsPanel('particle-physics-battle', 'Battle'),
              _closedPhysicsPanel('particle-physics-misc', 'Misc'),
              _closedPhysicsPanel('particle-physics-relations', 'Relations'),
              _closedPhysicsPanel(
                'particle-physics-fluid-interaction',
                'Fluid Interaction',
              ),
              _closedPhysicsPanel('particle-physics-deflection', 'Deflection'),
              _closedPhysicsPanel('particle-physics-forces', 'Forces'),
              _closedPhysicsPanel(
                'particle-physics-integration',
                'Integration',
              ),
              _closedPhysicsPanel('particle-physics-boid-brain', 'Boid Brain'),
            ],
          ),
          BlenderPropertyGroup(
            id: 'particle-render',
            title: 'Render',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'particle-render-as',
                'Render As',
                'Halo',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Halo', label: 'Halo'),
                  BlenderMenuItem<String>(value: 'Object', label: 'Object'),
                  BlenderMenuItem<String>(
                    value: 'Collection',
                    label: 'Collection',
                  ),
                  BlenderMenuItem<String>(value: 'Path', label: 'Path'),
                ],
              ),
              BlenderPropertyFactory.number(
                'particle-render-scale',
                'Scale',
                .05,
                min: 0,
              ),
              BlenderPropertyFactory.number(
                'particle-render-random-scale',
                'Randomize',
                0,
                min: 0,
              ),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel('particle-render-extra', 'Extra'),
              _closedPhysicsPanel('particle-render-path', 'Path'),
              _closedPhysicsPanel('particle-render-timing', 'Timing'),
              _closedPhysicsPanel('particle-render-object', 'Object'),
              BlenderPropertyGroup(
                id: 'particle-render-collection',
                title: 'Collection',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[],
                children: <BlenderPropertyGroup>[
                  _closedPhysicsPanel('particle-render-use-count', 'Use Count'),
                ],
              ),
            ],
          ),
          _closedPhysicsPanel(
            'particle-viewport-display',
            'Viewport Display',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'particle-viewport-display-as',
                'Display As',
                'Rendered',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Rendered', label: 'Rendered'),
                  BlenderMenuItem<String>(value: 'Point', label: 'Point'),
                  BlenderMenuItem<String>(value: 'Cross', label: 'Cross'),
                ],
              ),
              BlenderPropertyFactory.number(
                'particle-viewport-percentage',
                'Amount',
                100,
                min: 0,
                max: 100,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'particle-children',
            title: 'Children',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'particle-children-type',
                'Type',
                'Simple',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Simple', label: 'Simple'),
                  BlenderMenuItem<String>(
                    value: 'Interpolated',
                    label: 'Interpolated',
                  ),
                ],
              ),
              BlenderPropertyFactory.number(
                'particle-children-count',
                'Display Amount',
                10,
                min: 0,
              ),
            ],
            children: <BlenderPropertyGroup>[
              _closedPhysicsPanel('particle-children-parting', 'Parting'),
              BlenderPropertyGroup(
                id: 'particle-children-clumping',
                title: 'Clumping',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[],
                children: <BlenderPropertyGroup>[
                  _closedPhysicsPanel(
                    'particle-children-clump-noise',
                    'Clump Noise',
                  ),
                ],
              ),
              _closedPhysicsPanel('particle-children-roughness', 'Roughness'),
              _closedPhysicsPanel('particle-children-kink', 'Kink'),
            ],
          ),
          _closedPhysicsPanel(
            'particle-field-weights',
            'Field Weights',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'particle-field-gravity',
                'Gravity',
                1,
              ),
              BlenderPropertyFactory.number('particle-field-wind', 'Wind', 1),
              BlenderPropertyFactory.number(
                'particle-field-turbulence',
                'Turbulence',
                1,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'particle-force-field-settings',
            title: 'Force Field Settings',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'particle-force-field-type',
                'Type',
                'Force',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Force', label: 'Force'),
                  BlenderMenuItem<String>(value: 'Wind', label: 'Wind'),
                  BlenderMenuItem<String>(value: 'Vortex', label: 'Vortex'),
                ],
              ),
              BlenderPropertyFactory.number(
                'particle-force-field-strength',
                'Strength',
                1,
              ),
            ],
            children: <BlenderPropertyGroup>[
              BlenderPropertyGroup(
                id: 'particle-force-field-type-1',
                title: 'Type 1',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.choice<String>(
                    'particle-force-field-type-1-kind',
                    'Type 1',
                    'Force',
                    const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'Force', label: 'Force'),
                      BlenderMenuItem<String>(value: 'Wind', label: 'Wind'),
                      BlenderMenuItem<String>(value: 'Vortex', label: 'Vortex'),
                    ],
                  ),
                  BlenderPropertyFactory.number(
                    'particle-force-field-type-1-strength',
                    'Strength',
                    1,
                  ),
                ],
                children: <BlenderPropertyGroup>[
                  _closedPhysicsPanel(
                    'particle-force-field-type-1-falloff',
                    'Falloff',
                    properties: <BlenderPropertyDescriptor<dynamic>>[
                      BlenderPropertyFactory.number(
                        'particle-force-field-type-1-distance',
                        'Maximum Distance',
                        10,
                        min: 0,
                      ),
                      BlenderPropertyFactory.number(
                        'particle-force-field-type-1-power',
                        'Power',
                        1,
                        min: 0,
                      ),
                    ],
                  ),
                ],
              ),
              BlenderPropertyGroup(
                id: 'particle-force-field-type-2',
                title: 'Type 2',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.choice<String>(
                    'particle-force-field-type-2-kind',
                    'Type 2',
                    'Force',
                    const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'Force', label: 'Force'),
                      BlenderMenuItem<String>(value: 'Wind', label: 'Wind'),
                      BlenderMenuItem<String>(value: 'Vortex', label: 'Vortex'),
                    ],
                  ),
                  BlenderPropertyFactory.number(
                    'particle-force-field-type-2-strength',
                    'Strength',
                    1,
                  ),
                ],
                children: <BlenderPropertyGroup>[
                  _closedPhysicsPanel(
                    'particle-force-field-type-2-falloff',
                    'Falloff',
                    properties: <BlenderPropertyDescriptor<dynamic>>[
                      BlenderPropertyFactory.number(
                        'particle-force-field-type-2-distance',
                        'Maximum Distance',
                        10,
                        min: 0,
                      ),
                      BlenderPropertyFactory.number(
                        'particle-force-field-type-2-power',
                        'Power',
                        1,
                        min: 0,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          _closedPhysicsPanel(
            'particle-vertex-groups',
            'Vertex Groups',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'particle-vertex-density',
                'Density',
                'Density',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Density', label: 'Density'),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
              BlenderPropertyFactory.choice<String>(
                'particle-vertex-length',
                'Length',
                'Length',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Length', label: 'Length'),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
              BlenderPropertyFactory.choice<String>(
                'particle-vertex-clump',
                'Clump',
                'Clump',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Clump', label: 'Clump'),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
              BlenderPropertyFactory.choice<String>(
                'particle-vertex-kink',
                'Kink',
                'Kink',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Kink', label: 'Kink'),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
            ],
          ),
          _closedPhysicsPanel(
            'particle-textures',
            'Textures',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'particle-active-texture',
                'Texture',
                'None',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                  BlenderMenuItem<String>(value: 'Clouds', label: 'Clouds'),
                  BlenderMenuItem<String>(value: 'Noise', label: 'Noise'),
                ],
              ),
            ],
          ),
          _closedPhysicsPanel(
            'particle-hair-shape',
            'Hair Shape',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'particle-hair-shape-strand',
                'Strand Shape',
                0,
                min: -1,
                max: 1,
              ),
              BlenderPropertyFactory.number(
                'particle-hair-shape-root',
                'Diameter Root',
                1,
                min: 0,
              ),
              BlenderPropertyFactory.number(
                'particle-hair-shape-tip',
                'Tip',
                0,
                min: 0,
              ),
              BlenderPropertyFactory.number(
                'particle-hair-shape-radius-scale',
                'Radius Scale',
                1,
                min: 0,
              ),
              BlenderPropertyFactory.boolean(
                'particle-hair-shape-close-tip',
                'Close Tip',
                false,
              ),
            ],
          ),
          _closedPhysicsPanel(
            'particle-animation',
            'Animation',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'particle-animation-use-keyed',
                'Use Animation',
                false,
              ),
              BlenderPropertyFactory.number(
                'particle-animation-time-offset',
                'Time Offset',
                0,
              ),
            ],
          ),
          _closedPhysicsPanel(
            'particle-custom-properties',
            'Custom Properties',
          ),
        ],
      ),
      _closedPhysicsPanel(
        'physics-geometry-nodes',
        'Simulation Nodes',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'physics-geometry-nodes-enabled',
            'Enabled',
            true,
          ),
          BlenderPropertyFactory.choice<String>(
            'physics-geometry-nodes-node-group',
            'Node Group',
            'Simulation Nodes',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Simulation Nodes',
                label: 'Simulation Nodes',
              ),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
        ],
      ),
    ];
  }
}
