part of '../showcase_app.dart';

extension _ShowcaseToolSettings on _ShowcaseAppState {
  Widget _buildFormatPresetButton() {
    const presets = <String>[
      '4K DCI 2160p',
      '4K UHDTV 2160p',
      '4K UW 1600p',
      'DVCPRO HD 720p',
      'DVCPRO HD 1080p',
      'HDTV 720p',
      'HDTV 1080p',
      'HDV 1080p',
      'HDV NTSC 1080p',
      'HDV PAL 1080p',
      'TV NTSC 4:3',
      'TV NTSC 16:9',
      'TV PAL 4:3',
      'TV PAL 16:9',
    ];
    return BlenderPopover(
      targetAnchor: Alignment.bottomRight,
      followerAnchor: Alignment.topRight,
      child: const BlenderIconButton(
        glyph: BlenderGlyph.preset,
        size: 22,
        tooltip: 'Format presets',
      ),
      popover: (context, close) => BlenderMenu<String>(
        items: <BlenderMenuItem<String>>[
          for (final preset in presets)
            BlenderMenuItem<String>(
              value: preset,
              label: preset,
              selected: preset == _formatPreset,
            ),
          const BlenderMenuItem<String>(
            value: 'separator',
            label: '',
            separator: true,
          ),
          const BlenderMenuItem<String>(
            value: 'new-preset',
            label: 'New Preset',
            icon: BlenderIcon(BlenderGlyph.plus, size: 13),
          ),
        ],
        onSelected: (item) {
          if (item.value != 'separator') {
            _update(() => _formatPreset = item.value);
            close();
          }
        },
      ),
    );
  }

  void _setStereoscopy(bool value) {
    _update(() => _stereoscopy = value);
  }

  Widget _buildToolSettingsBody() {
    return BlenderScrollView(
      child: Padding(
        // Blender's panel layout applies UI_PANEL_MARGIN_X before drawing
        // panel cards. The specialized Tool body bypasses the generic
        // Properties list, so keep the equivalent horizontal inset here.
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _propertyTopContent!,
            const SizedBox(height: 10),
            if (_workspaceMode == 'Object Mode')
              _buildToolSettingsPanel(
                title: 'Options',
                expanded: _toolOptionsExpanded,
                onToggle: () =>
                    _update(() => _toolOptionsExpanded = !_toolOptionsExpanded),
                child: _buildObjectModeOptionsPanel(),
              )
            else
              ..._buildModeSpecificToolPanels(),
            const SizedBox(height: 4),
            _buildToolSettingsPanel(
              title: 'Workspace',
              expanded: _toolWorkspaceExpanded,
              onToggle: () => _update(
                () => _toolWorkspaceExpanded = !_toolWorkspaceExpanded,
              ),
              child: _buildWorkspaceToolPanel(),
            ),
            const SizedBox(height: 4),
            _buildToolSettingsPanel(
              title: 'Brush Asset',
              expanded: _toolBrushExpanded,
              onToggle: () =>
                  _update(() => _toolBrushExpanded = !_toolBrushExpanded),
              child: _buildBrushAssetPanel(),
            ),
            const SizedBox(height: 4),
            _buildToolSettingsPanel(
              title: 'Brush Settings',
              expanded: _toolBrushSettingsExpanded,
              onToggle: () => _update(
                () => _toolBrushSettingsExpanded = !_toolBrushSettingsExpanded,
              ),
              child: _buildBrushSettingsPanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectModeOptionsPanel() {
    final theme = BlenderTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        BlenderPanel(
          title: 'Transform',
          disclosureKey: const ValueKey<String>(
            'tool-settings-nested-disclosure-Transform',
          ),
          collapsible: true,
          expanded: _toolTransformExpanded,
          onExpansionChanged: (value) =>
              _update(() => _toolTransformExpanded = value),
          child: const SizedBox.shrink(),
        ),
        if (_toolTransformExpanded)
          Container(
            color: theme.colors.panelSubSurface,
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 48) {
                  return const SizedBox(height: 20);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          'Affect Only',
                          textAlign: TextAlign.right,
                          style: theme.textTheme.body.copyWith(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildToolCheckbox(
                            value: _toolAffectOrigins,
                            label: 'Origins',
                            onChanged: (value) =>
                                _update(() => _toolAffectOrigins = value),
                          ),
                          const SizedBox(height: 3),
                          _buildToolCheckbox(
                            value: _toolAffectLocations,
                            label: 'Locations',
                            onChanged: (value) =>
                                _update(() => _toolAffectLocations = value),
                          ),
                          const SizedBox(height: 3),
                          _buildToolCheckbox(
                            value: _toolAffectParents,
                            label: 'Parents',
                            onChanged: (value) =>
                                _update(() => _toolAffectParents = value),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  List<Widget> _buildModeSpecificToolPanels() {
    Widget checkbox(String label, {bool value = true}) =>
        _buildToolCheckbox(value: value, label: label, onChanged: (_) {});

    Widget number(String label, double value) => BlenderPropertyRow(
      label: label,
      editor: BlenderNumberField(
        value: value,
        decimalDigits: 2,
        onChanged: (_) {},
      ),
    );

    Widget dropdown(String label, String value, List<String> values) =>
        BlenderPropertyRow(
          label: label,
          editor: BlenderDropdown<String>(
            value: value,
            items: <BlenderMenuItem<String>>[
              for (final item in values)
                BlenderMenuItem<String>(value: item, label: item),
            ],
            onChanged: (_) {},
          ),
        );

    Widget modePanel(String title, Widget child) {
      final expanded = _toolModePanelExpanded[title] ?? false;
      return _buildToolSettingsPanel(
        title: title,
        expanded: expanded,
        onToggle: () => _update(() {
          _toolModePanelExpanded[title] = !expanded;
        }),
        child: child,
      );
    }

    Widget nested(String title, Widget child) {
      final expanded = _toolModePanelExpanded[title] ?? false;
      return _buildNestedToolPanel(
        title: title,
        expanded: expanded,
        onToggle: () => _update(() {
          _toolModePanelExpanded[title] = !expanded;
        }),
        child: child,
      );
    }

    Widget editOptions() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        nested(
          'Transform',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              checkbox('Correct Face Attributes'),
              checkbox('Keep Connected', value: false),
              checkbox('Auto Merge', value: false),
              number('Threshold', .001),
              BlenderPropertyRow(
                label: 'Mirror',
                editor: BlenderSegmentedControl<String>(
                  value: 'X',
                  items: <BlenderMenuItem<String>>[
                    const BlenderMenuItem<String>(value: 'X', label: 'X'),
                    const BlenderMenuItem<String>(value: 'Y', label: 'Y'),
                    const BlenderMenuItem<String>(value: 'Z', label: 'Z'),
                  ],
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        nested('UVs', checkbox('Live Unwrap')),
      ],
    );

    Widget sculptOptions() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        checkbox('Show Low Resolution'),
        checkbox('Delay Updates', value: false),
        checkbox('Deform Only', value: false),
        const SizedBox(height: 4),
        nested(
          'Gravity',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              number('Factor', .5),
              dropdown('Object', 'None', <String>['None', 'Cube']),
            ],
          ),
        ),
      ],
    );

    Widget symmetry() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        checkbox('Mirror X'),
        checkbox('Mirror Y'),
        checkbox('Mirror Z'),
        checkbox('Lock X', value: false),
        checkbox('Lock Y', value: false),
        checkbox('Lock Z', value: false),
        number('Radial', 1),
      ],
    );

    Widget paintOptions() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        number('Seam Bleed', 2),
        number('Dither', 0),
        checkbox('Occlude', value: false),
        checkbox('Backface Culling', value: false),
        nested(
          'External',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              number('Screen Grab Size', 512),
              const BlenderButton(label: 'Quick Edit'),
              const BlenderButton(label: 'Apply'),
            ],
          ),
        ),
      ],
    );

    Widget particleOptions() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        nested(
          'Cut Particles to Shape',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              dropdown('Shape Object', 'None', <String>['None', 'Cube']),
              const BlenderButton(label: 'Cut'),
            ],
          ),
        ),
        const SizedBox(height: 3),
        nested(
          'Viewport Display',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              number('Path Steps', 5),
              checkbox('Particles'),
              checkbox('Fade Time', value: false),
            ],
          ),
        ),
      ],
    );

    Widget paintDataPanel(String title, Widget child) {
      final expanded = _toolModePanelExpanded[title] ?? false;
      return _buildToolSettingsPanel(
        title: title,
        expanded: expanded,
        onToggle: () => _update(() {
          _toolModePanelExpanded[title] = !expanded;
        }),
        child: child,
      );
    }

    Widget nestedPaintDataPanel(String title, Widget child) {
      final expanded = _toolModePanelExpanded[title] ?? false;
      return _buildNestedToolPanel(
        title: title,
        expanded: expanded,
        onToggle: () => _update(() {
          _toolModePanelExpanded[title] = !expanded;
        }),
        child: child,
      );
    }

    Widget listPanel({required String active, required String addLabel}) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlenderPropertyRow(
              label: 'Active',
              editor: BlenderDropdown<String>(
                value: active,
                items: <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: active, label: active),
                  const BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
                onChanged: (_) {},
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: <Widget>[
                Expanded(child: BlenderButton(label: addLabel)),
                const SizedBox(width: 4),
                const Expanded(child: BlenderButton(label: 'Remove')),
              ],
            ),
          ],
        );

    Widget texturePaintDataPanels() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        paintDataPanel(
          'Texture Slots',
          listPanel(active: 'Material Slot', addLabel: 'Add Slot'),
        ),
        const SizedBox(height: 4),
        paintDataPanel(
          'Canvas',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              dropdown('Source', 'Material', <String>[
                'Material',
                'Image',
                'Color Attribute',
              ]),
              const BlenderPropertyRow(
                label: 'Image',
                editor: const BlenderDataBlockField<String>(
                  value: 'Paint Canvas',
                  items: <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(
                      value: 'Paint Canvas',
                      label: 'Paint Canvas',
                    ),
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                  ],
                  icon: BlenderGlyph.image,
                ),
              ),
              const BlenderButton(label: 'Save All Images'),
            ],
          ),
        ),
        const SizedBox(height: 4),
        paintDataPanel(
          'Color Attributes',
          listPanel(active: 'Color', addLabel: 'Add Attribute'),
        ),
        const SizedBox(height: 4),
        paintDataPanel(
          'Vertex Groups',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              listPanel(active: 'Group', addLabel: 'Add Group'),
              const SizedBox(height: 4),
              const Row(
                children: <Widget>[
                  Expanded(child: BlenderButton(label: 'Move Up')),
                  const SizedBox(width: 4),
                  Expanded(child: BlenderButton(label: 'Move Down')),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    Widget texturePaintMasking() => paintDataPanel(
      'Masking',
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          nestedPaintDataPanel(
            'Stencil Mask',
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                checkbox('Use Stencil Layer'),
                const BlenderPropertyRow(
                  label: 'Stencil Image',
                  editor: const BlenderDataBlockField<String>(
                    value: 'Stencil',
                    items: <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(
                        value: 'Stencil',
                        label: 'Stencil',
                      ),
                      BlenderMenuItem<String>(value: 'None', label: 'None'),
                    ],
                    icon: BlenderGlyph.image,
                  ),
                ),
                dropdown('UV Map', 'UVMap', <String>['UVMap', 'None']),
              ],
            ),
          ),
          const SizedBox(height: 3),
          nestedPaintDataPanel(
            'Cavity Mask',
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                checkbox('Use Cavity'),
                dropdown('Type', 'World', <String>['World', 'Both']),
                number('Ridge Factor', 1),
                number('Valley Factor', 1),
              ],
            ),
          ),
        ],
      ),
    );

    Widget greasePencilColor({required bool includePalette}) {
      final color = BlenderTheme.of(context).colors.buttonSelected;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          dropdown('Color Mode', 'Vertex Color', <String>[
            'Vertex Color',
            'Material',
          ]),
          BlenderColorPicker(color: color, onChanged: (_) {}),
          number('Mix Factor', .5),
          if (includePalette) ...<Widget>[
            const SizedBox(height: 4),
            nested(
              'Palette',
              Row(
                children: <Widget>[
                  for (final swatch in <Color>[
                    const Color(0xFFCC5544),
                    const Color(0xFFDD9944),
                    const Color(0xFF5D8FCE),
                    const Color(0xFF6EAA68),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: BlenderColorSwatch(color: swatch),
                    ),
                  const Spacer(),
                  const BlenderButton(label: 'New'),
                ],
              ),
            ),
          ],
        ],
      );
    }

    Widget greasePencilFalloff() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        dropdown('Shape', 'Smooth', <String>[
          'Smooth',
          'Sphere',
          'Root',
          'Sharp',
        ]),
        number('Radius', .5),
        number('Curve', .5),
      ],
    );

    return switch (_workspaceMode) {
      'Edit Mode' => <Widget>[modePanel('Options', editOptions())],
      'Armature Edit' => <Widget>[
        modePanel(
          'Options',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[checkbox('X-Axis Mirror')],
          ),
        ),
      ],
      'Pose Mode' => <Widget>[
        modePanel(
          'Pose Options',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              checkbox('Auto IK', value: false),
              checkbox('X-Axis Mirror', value: false),
              checkbox('Relative Mirror', value: false),
              checkbox('Affect Locations'),
            ],
          ),
        ),
      ],
      'Sculpt Mode' => <Widget>[
        modePanel(
          'Dyntopo',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              checkbox('Enable Dynamic Topology', value: false),
              number('Detail Size', 12),
              dropdown('Refine Method', 'Subdivide Collapse', <String>[
                'Subdivide Collapse',
                'Subdivide',
                'Collapse',
              ]),
              dropdown('Detailing', 'Relative', <String>[
                'Relative',
                'Constant',
                'Manual',
              ]),
            ],
          ),
        ),
        const SizedBox(height: 4),
        modePanel(
          'Remesh',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              number('Voxel Size', .1),
              number('Adaptivity', 0),
              checkbox('Preserve Volume'),
              checkbox('Preserve Attributes'),
              const BlenderButton(label: 'Remesh'),
            ],
          ),
        ),
        const SizedBox(height: 4),
        modePanel('Options', sculptOptions()),
        const SizedBox(height: 4),
        modePanel('Symmetry', symmetry()),
      ],
      'Curves Sculpt' => <Widget>[
        modePanel(
          'Symmetry',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              checkbox('Mirror X'),
              checkbox('Mirror Y'),
              checkbox('Mirror Z'),
            ],
          ),
        ),
      ],
      'Weight Paint' => <Widget>[
        modePanel('Symmetry', symmetry()),
        const SizedBox(height: 4),
        modePanel(
          'Options',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              checkbox('Auto Normalize'),
              checkbox('Lock-Relative', value: false),
              checkbox('Multi-Paint', value: false),
              checkbox('Group Restrict', value: false),
            ],
          ),
        ),
      ],
      'Vertex Paint' => <Widget>[modePanel('Symmetry', symmetry())],
      'Grease Pencil Draw' => <Widget>[
        modePanel('Color', greasePencilColor(includePalette: true)),
      ],
      'Grease Pencil Sculpt' => const <Widget>[],
      'Grease Pencil Weight Paint' => <Widget>[
        modePanel(
          'Options',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              checkbox('Auto Normalize'),
              checkbox('Lock Relative', value: false),
            ],
          ),
        ),
      ],
      'Grease Pencil Vertex Paint' => <Widget>[
        modePanel('Color', greasePencilColor(includePalette: true)),
        const SizedBox(height: 4),
        modePanel('Falloff', greasePencilFalloff()),
      ],
      'Texture Paint' => <Widget>[
        texturePaintDataPanels(),
        const SizedBox(height: 4),
        texturePaintMasking(),
        const SizedBox(height: 4),
        modePanel('Symmetry', symmetry()),
        const SizedBox(height: 4),
        modePanel('Options', paintOptions()),
      ],
      'Particle Edit' => <Widget>[
        modePanel(
          'Particle Tool',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              dropdown('Editing Type', 'Particles', <String>[
                'Particles',
                'Hair',
                'Cloth',
              ]),
              checkbox('Auto-Velocity', value: false),
              checkbox('Strand Lengths'),
              checkbox('Root Positions'),
            ],
          ),
        ),
        const SizedBox(height: 4),
        modePanel('Options', particleOptions()),
      ],
      _ => const <Widget>[],
    };
  }
}
