part of '../showcase_app.dart';

extension _ShowcaseBrushPanels on _ShowcaseAppState {
  Widget _buildGreasePencilBrushSettingsPanel() {
    final controls = _ShowcaseBrushControls(this);

    Widget content(String title) {
      final theme = BlenderTheme.of(context);
      return switch (title) {
        'Advanced' => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            controls.dropdown('Locked Size', 'Scene', <String>[
              'Scene',
              'View',
            ]),
            controls.number('Spacing', 10),
            controls.number('Active Smooth', .5),
            controls.number('Angle', 0),
            controls.number('Hardness', .5),
            controls.number('Aspect', 1),
            const SizedBox(height: 4),
            controls.nested(
              'Gap Closure',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  controls.checkbox('Use Gap Closure'),
                  controls.number('Size', 10),
                  controls.dropdown('Mode', 'Extend', <String>[
                    'Extend',
                    'Radius',
                  ]),
                ],
              ),
            ),
          ],
        ),
        'Stroke' => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            controls.dropdown('Method', 'Draw', <String>[
              'Draw',
              'Erase',
              'Fill',
            ]),
            controls.nested(
              'Post-Processing',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  controls.checkbox('Use Post-Processing'),
                  controls.number('Smooth Factor', .5),
                  controls.number('Smooth Steps', 2),
                  controls.number('Subdivisions', 1),
                  controls.checkbox('Trim'),
                ],
              ),
            ),
            const SizedBox(height: 3),
            controls.nested(
              'Randomize',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  controls.checkbox('Use Randomize'),
                  controls.number('Radius', 0),
                  controls.number('Strength', 0),
                  controls.number('Rotation', 0),
                  controls.number('Jitter', 0),
                ],
              ),
            ),
            const SizedBox(height: 3),
            controls.nested(
              'Stabilize Stroke',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  controls.checkbox('Smooth Stroke'),
                  controls.number('Radius', .5),
                  controls.number('Factor', .5),
                ],
              ),
            ),
          ],
        ),
        'Falloff' => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            controls.dropdown('Shape', 'Smooth', <String>[
              'Smooth',
              'Sphere',
              'Root',
              'Sharp',
            ]),
            controls.number('Radius', .5),
            controls.number('Curve', .5),
          ],
        ),
        'Cursor' => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            controls.checkbox('Show Cursor'),
            BlenderPropertyRow(
              label: 'Color',
              editor: BlenderColorSwatch(color: theme.colors.buttonSelected),
            ),
          ],
        ),
        _ => const SizedBox.shrink(),
      };
    }

    Widget nestedBrushPanel(String title) =>
        controls.nested(title, content(title));

    final children = <Widget>[
      if (_workspaceMode == 'Grease Pencil Draw') ...<Widget>[
        controls.dropdown('Tool', 'Draw', <String>[
          'Draw',
          'Fill',
          'Erase',
          'Tint',
        ]),
        const BlenderPropertyRow(
          label: 'Material',
          editor: const BlenderDataBlockField<String>(
            value: 'Material',
            items: <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Material', label: 'Material'),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
            icon: BlenderGlyph.material,
          ),
        ),
        controls.number('Radius', .5),
        controls.number('Strength', .5),
        _buildToolCheckbox(
          value: true,
          label: 'Use Pressure Strength',
          onChanged: (_) {},
        ),
        const SizedBox(height: 6),
        nestedBrushPanel('Advanced'),
        const SizedBox(height: 3),
        nestedBrushPanel('Stroke'),
        const SizedBox(height: 3),
        nestedBrushPanel('Cursor'),
      ] else if (_workspaceMode == 'Grease Pencil Sculpt') ...<Widget>[
        controls.dropdown('Tool', 'Smooth', <String>[
          'Smooth',
          'Grab',
          'Randomize',
        ]),
        controls.number('Radius', .5),
        controls.number('Strength', .5),
        nestedBrushPanel('Cursor'),
      ] else if (_workspaceMode == 'Grease Pencil Weight Paint') ...<Widget>[
        controls.dropdown('Tool', 'Weight', <String>[
          'Weight',
          'Blur',
          'Smear',
        ]),
        controls.number('Radius', .5),
        controls.number('Strength', .5),
        nestedBrushPanel('Falloff'),
        const SizedBox(height: 3),
        nestedBrushPanel('Cursor'),
      ] else ...<Widget>[
        controls.dropdown('Tool', 'Draw', <String>['Draw', 'Blur', 'Smear']),
        controls.number('Radius', .5),
        controls.number('Strength', .5),
        nestedBrushPanel('Cursor'),
      ],
    ];

    return Container(
      color: BlenderTheme.of(context).colors.panelSubSurface,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildPaintToolSubpanelContent(String title) {
    final theme = BlenderTheme.of(context);
    final controls = _ShowcaseBrushControls(this);

    Widget button(String label) {
      return BlenderButton(label: label, onPressed: () => _setStatus(label));
    }

    final content = switch (title) {
      'Advanced' => <Widget>[
        controls.number('Hardness', .5),
        controls.number('Spacing', 10),
        _buildToolCheckbox(
          value: true,
          label: 'Use Pressure Size',
          onChanged: (_) {},
        ),
      ],
      'Color Picker' => <Widget>[
        BlenderColorPicker(
          color: BlenderTheme.of(context).colors.buttonSelected,
          onChanged: (_) {},
        ),
        _buildToolCheckbox(
          value: false,
          label: 'Unified Color',
          onChanged: (_) {},
        ),
      ],
      'Color Palette' => <Widget>[
        Row(
          children: <Widget>[
            for (final color in <Color>[
              const Color(0xFFCC5544),
              const Color(0xFFDD9944),
              const Color(0xFF5D8FCE),
              const Color(0xFF6EAA68),
            ])
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: BlenderColorSwatch(color: color),
              ),
            const Spacer(),
            button('New'),
            const SizedBox(width: 4),
            button('Delete'),
          ],
        ),
      ],
      'Clone' || 'Clone from Paint Slot' => <Widget>[
        controls.dropdown('Mode', 'Material', <String>['Material', 'Color']),
        controls.number('Alpha', .5),
        controls.number('Offset', 0),
      ],
      'Texture' => <Widget>[
        controls.dropdown('Texture', 'Voronoi', <String>[
          'Voronoi',
          'Noise',
          'Image',
        ]),
        controls.dropdown('Mapping', '3D', <String>['3D', '2D', 'View Plane']),
        controls.number('Opacity', .5),
      ],
      'Texture Mask' => <Widget>[
        controls.dropdown('Texture', 'Voronoi', <String>[
          'Voronoi',
          'Noise',
          'Image',
        ]),
        controls.number('Angle', 0),
        controls.number('Scale', 1),
      ],
      'Stroke' => <Widget>[
        controls.dropdown('Method', 'Space', <String>[
          'Space',
          'Airbrush',
          'Dots',
        ]),
        controls.number('Spacing', 10),
        controls.number('Jitter', 0),
        controls.number('Input Samples', 4),
      ],
      'Stabilize Stroke' => <Widget>[
        _buildToolCheckbox(
          value: true,
          label: 'Smooth Stroke',
          onChanged: (_) {},
        ),
        controls.number('Radius', 0.5),
        controls.number('Factor', .5),
      ],
      'Falloff' => <Widget>[
        controls.dropdown('Shape', 'Smooth', <String>[
          'Smooth',
          'Sphere',
          'Root',
          'Sharp',
        ]),
        controls.number('Radius', .5),
      ],
      'Cursor' || 'Brush Cursor' => <Widget>[
        _buildToolCheckbox(
          value: true,
          label: 'Show Cursor',
          onChanged: (_) {},
        ),
        _buildToolCheckbox(
          value: false,
          label: 'Show Outline',
          onChanged: (_) {},
        ),
        BlenderPropertyRow(
          label: 'Color',
          editor: BlenderColorSwatch(color: theme.colors.buttonSelected),
        ),
      ],
      'Front-Face Falloff' => <Widget>[
        _buildToolCheckbox(
          value: true,
          label: 'Use Front-Face Falloff',
          onChanged: (_) {},
        ),
        controls.number('Angle', .5),
      ],
      'Normal Falloff' => <Widget>[
        _buildToolCheckbox(
          value: false,
          label: 'Use Normal Falloff',
          onChanged: (_) {},
        ),
        controls.number('Angle', .5),
      ],
      _ => const <Widget>[],
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: content,
      ),
    );
  }

  Widget _buildNestedToolPanel({
    required String title,
    required bool expanded,
    required VoidCallback onToggle,
    required Widget child,
  }) => BlenderPanel(
    title: title,
    disclosureKey: ValueKey<String>('tool-settings-nested-disclosure-$title'),
    collapsible: true,
    expanded: expanded,
    onExpansionChanged: (_) => onToggle(),
    padding: EdgeInsets.zero,
    child: child,
  );
}
