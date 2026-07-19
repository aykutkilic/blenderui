part of '../showcase_app.dart';

extension _ShowcasePropertiesSurface on _ShowcaseAppState {
  Widget _buildModifierPropertiesBody({String title = 'Modifiers'}) {
    const addModifierItems = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(
        value: 'Edit',
        label: 'Edit',
        submenu: <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Data Transfer',
            label: 'Data Transfer',
          ),
          BlenderMenuItem<String>(value: 'UV Project', label: 'UV Project'),
          BlenderMenuItem<String>(value: 'Mesh Cache', label: 'Mesh Cache'),
        ],
      ),
      BlenderMenuItem<String>(
        value: 'Generate',
        label: 'Generate',
        submenu: <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Array', label: 'Array'),
          BlenderMenuItem<String>(value: 'Bevel', label: 'Bevel'),
          BlenderMenuItem<String>(value: 'Boolean', label: 'Boolean'),
          BlenderMenuItem<String>(
            value: 'Subdivision Surface',
            label: 'Subdivision Surface',
          ),
          BlenderMenuItem<String>(value: 'Solidify', label: 'Solidify'),
        ],
      ),
      BlenderMenuItem<String>(
        value: 'Deform',
        label: 'Deform',
        submenu: <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Armature', label: 'Armature'),
          BlenderMenuItem<String>(value: 'Cast', label: 'Cast'),
          BlenderMenuItem<String>(value: 'Shrinkwrap', label: 'Shrinkwrap'),
          BlenderMenuItem<String>(value: 'Wave', label: 'Wave'),
        ],
      ),
      BlenderMenuItem<String>(
        value: 'Normals',
        label: 'Normals',
        submenu: <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Normal Edit', label: 'Normal Edit'),
          BlenderMenuItem<String>(
            value: 'Weighted Normal',
            label: 'Weighted Normal',
          ),
        ],
      ),
      BlenderMenuItem<String>(
        value: 'Physics',
        label: 'Physics',
        submenu: <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Cloth', label: 'Cloth'),
          BlenderMenuItem<String>(value: 'Collision', label: 'Collision'),
          BlenderMenuItem<String>(value: 'Fluid', label: 'Fluid'),
          BlenderMenuItem<String>(value: 'Soft Body', label: 'Soft Body'),
        ],
      ),
      BlenderMenuItem<String>(
        value: 'Color',
        label: 'Color',
        submenu: <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Tint', label: 'Tint'),
          BlenderMenuItem<String>(value: 'Opacity', label: 'Opacity'),
        ],
      ),
    ];

    return BlenderScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          BlenderMenuButton<String>(
            label: 'Add Modifier',
            items: addModifierItems,
            onSelected: (value) => _setStatus('Add $value modifier'),
          ),
          const SizedBox(height: 8),
          BlenderModifierStack(
            title: title,
            modifiers: <BlenderModifierDescriptor>[
              BlenderModifierDescriptor(
                id: 'bevel',
                name: 'Bevel',
                icon: BlenderGlyph.modifier,
                child: Column(
                  children: <Widget>[
                    BlenderPropertyRow(
                      label: 'Amount',
                      editor: BlenderNumberField(
                        value: .1,
                        min: 0,
                        max: 1,
                        step: .01,
                        onChanged: (_) {},
                      ),
                    ),
                    BlenderPropertyRow(
                      label: 'Segments',
                      editor: BlenderNumberField(
                        value: 3,
                        min: 1,
                        max: 32,
                        decimalDigits: 0,
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
                onToggleEnabled: () => _setStatus('Toggle Bevel'),
                onToggleViewport: () => _setStatus('Toggle Bevel viewport'),
                onToggleRender: () => _setStatus('Toggle Bevel render'),
                onMoveUp: () => _setStatus('Move Bevel up'),
                onMoveDown: () => _setStatus('Move Bevel down'),
                onRemove: () => _setStatus('Remove Bevel'),
              ),
              BlenderModifierDescriptor(
                id: 'subdivision-surface',
                name: 'Subdivision Surface',
                icon: BlenderGlyph.modifier,
                initiallyExpanded: false,
                child: BlenderPropertyRow(
                  label: 'Levels Viewport',
                  editor: BlenderNumberField(
                    value: 2,
                    min: 0,
                    max: 6,
                    decimalDigits: 0,
                    onChanged: (_) {},
                  ),
                ),
                onToggleEnabled: () => _setStatus('Toggle Subdivision'),
                onToggleViewport: () =>
                    _setStatus('Toggle Subdivision viewport'),
                onToggleRender: () => _setStatus('Toggle Subdivision render'),
                onRemove: () => _setStatus('Remove Subdivision'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConstraintPropertiesBody({String title = 'Object Constraints'}) {
    Widget numberRow(
      String label,
      double value, {
      double min = 0,
      double max = 1,
    }) {
      return BlenderPropertyRow(
        label: label,
        editor: BlenderNumberField(
          value: value,
          min: min,
          max: max,
          step: .01,
          onChanged: (_) {},
        ),
      );
    }

    Widget dropdownRow(
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyRow(
        label: label,
        editor: BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: (_) {},
        ),
      );
    }

    final isBoneConstraint = title == 'Bone Constraints';
    final addLabel = isBoneConstraint
        ? 'Add Bone Constraint'
        : 'Add Object Constraint';
    final addItems = <BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(
        value: 'Copy Location',
        label: 'Copy Location',
      ),
      const BlenderMenuItem<String>(value: 'Child Of', label: 'Child Of'),
      const BlenderMenuItem<String>(value: 'Follow Path', label: 'Follow Path'),
      const BlenderMenuItem<String>(
        value: 'Limit Rotation',
        label: 'Limit Rotation',
      ),
      const BlenderMenuItem<String>(value: 'Armature', label: 'Armature'),
    ];

    return BlenderScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          BlenderMenuButton<String>(
            label: addLabel,
            items: addItems,
            onSelected: (value) => _setStatus('Add $value constraint'),
          ),
          const SizedBox(height: 6),
          BlenderConstraintStack(
            title: title,
            actionSize: 17,
            constraints: <BlenderConstraintDescriptor>[
              BlenderConstraintDescriptor(
                id: 'constraint-copy-location',
                name: 'Copy Location',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    dropdownRow('Target', 'Camera', const <
                      BlenderMenuItem<String>
                    >[
                      BlenderMenuItem<String>(value: 'Camera', label: 'Camera'),
                      BlenderMenuItem<String>(value: 'Light', label: 'Light'),
                    ]),
                    numberRow('Influence', .75),
                    const BlenderPropertyRow(
                      label: 'Axes',
                      editor: Text('X  Y  Z'),
                    ),
                  ],
                ),
                onToggleEnabled: () => _setStatus('Copy Location toggled'),
                onMenu: () => _setStatus('Copy Location menu'),
                onRemove: () => _setStatus('Copy Location removed'),
              ),
              BlenderConstraintDescriptor(
                id: 'constraint-child-of',
                name: 'Child Of',
                initiallyExpanded: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    dropdownRow('Target', 'Empty', const <
                      BlenderMenuItem<String>
                    >[
                      BlenderMenuItem<String>(value: 'Empty', label: 'Empty'),
                      BlenderMenuItem<String>(value: 'Camera', label: 'Camera'),
                    ]),
                    numberRow('Influence', 1),
                    numberRow('Location', 0, min: -10, max: 10),
                    numberRow('Rotation', 0, min: -180, max: 180),
                    numberRow('Scale', 1, min: 0, max: 10),
                  ],
                ),
                onToggleEnabled: () => _setStatus('Child Of toggled'),
                onMenu: () => _setStatus('Child Of menu'),
                onRemove: () => _setStatus('Child Of removed'),
              ),
              BlenderConstraintDescriptor(
                id: 'constraint-follow-path',
                name: 'Follow Path',
                initiallyExpanded: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    dropdownRow(
                      'Target',
                      'BezierCurve',
                      const <BlenderMenuItem<String>>[
                        BlenderMenuItem<String>(
                          value: 'BezierCurve',
                          label: 'BezierCurve',
                        ),
                        BlenderMenuItem<String>(value: 'None', label: 'None'),
                      ],
                    ),
                    numberRow('Offset', 0, min: -100, max: 100),
                    numberRow('Influence', 1),
                  ],
                ),
                onToggleEnabled: () => _setStatus('Follow Path toggled'),
                onMenu: () => _setStatus('Follow Path menu'),
                onRemove: () => _setStatus('Follow Path removed'),
              ),
              BlenderConstraintDescriptor(
                id: 'constraint-limit-rotation',
                name: 'Limit Rotation',
                initiallyExpanded: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const BlenderPropertyRow(
                      label: 'Owner Space',
                      editor: Text('World Space'),
                    ),
                    numberRow('X Min', -1, min: -3.14, max: 3.14),
                    numberRow('X Max', 1, min: -3.14, max: 3.14),
                    numberRow('Influence', 1),
                  ],
                ),
                onToggleEnabled: () => _setStatus('Limit Rotation toggled'),
                onMenu: () => _setStatus('Limit Rotation menu'),
                onRemove: () => _setStatus('Limit Rotation removed'),
              ),
              BlenderConstraintDescriptor(
                id: 'constraint-armature',
                name: 'Armature',
                initiallyExpanded: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    dropdownRow(
                      'Target',
                      'Armature',
                      const <BlenderMenuItem<String>>[
                        BlenderMenuItem<String>(
                          value: 'Armature',
                          label: 'Armature',
                        ),
                        BlenderMenuItem<String>(value: 'None', label: 'None'),
                      ],
                    ),
                    numberRow('Influence', 1),
                  ],
                ),
                onToggleEnabled: () =>
                    _setStatus('Armature constraint toggled'),
                onMenu: () => _setStatus('Armature constraint menu'),
                onRemove: () => _setStatus('Armature constraint removed'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShaderFxPropertiesBody() {
    const effectItems = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Drop Shadow', label: 'Drop Shadow'),
      BlenderMenuItem<String>(value: 'Colorize', label: 'Colorize'),
      BlenderMenuItem<String>(value: 'Glow', label: 'Glow'),
      BlenderMenuItem<String>(value: 'Wave', label: 'Wave'),
      BlenderMenuItem<String>(value: 'Pixelate', label: 'Pixelate'),
    ];
    return BlenderScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          BlenderMenuButton<String>(
            label: 'Add Effect',
            items: effectItems,
            onSelected: (value) => _setStatus('Add $value effect'),
          ),
          const SizedBox(height: 6),
          BlenderShaderEffectStack(
            title: 'Effects',
            effects: <BlenderShaderEffectDescriptor>[
              BlenderShaderEffectDescriptor(
                id: 'shaderfx-drop-shadow',
                name: 'Drop Shadow',
                icon: BlenderGlyph.shaderfx,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    BlenderPropertyRow(
                      label: 'Opacity',
                      editor: BlenderNumberField(
                        value: .5,
                        min: 0,
                        max: 1,
                        step: .01,
                        onChanged: (_) {},
                      ),
                    ),
                    BlenderPropertyRow(
                      label: 'Offset X',
                      editor: BlenderNumberField(
                        value: 4,
                        decimalDigits: 1,
                        onChanged: (_) {},
                      ),
                    ),
                    BlenderPropertyRow(
                      label: 'Offset Y',
                      editor: BlenderNumberField(
                        value: -4,
                        decimalDigits: 1,
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
                onToggleEnabled: () => _setStatus('Shader effect toggled'),
                onMoveUp: () => _setStatus('Shader effect moved up'),
                onMoveDown: () => _setStatus('Shader effect moved down'),
                onRemove: () => _setStatus('Shader effect removed'),
              ),
              BlenderShaderEffectDescriptor(
                id: 'shaderfx-colorize',
                name: 'Colorize',
                icon: BlenderGlyph.color,
                initiallyExpanded: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    BlenderPropertyRow(
                      label: 'Factor',
                      editor: BlenderNumberField(
                        value: .8,
                        min: 0,
                        max: 1,
                        step: .01,
                        onChanged: (_) {},
                      ),
                    ),
                    BlenderPropertyRow(
                      label: 'Blend Mode',
                      editor: BlenderDropdown<String>(
                        value: 'Multiply',
                        items: const <BlenderMenuItem<String>>[
                          BlenderMenuItem<String>(
                            value: 'Multiply',
                            label: 'Multiply',
                          ),
                          BlenderMenuItem<String>(
                            value: 'Screen',
                            label: 'Screen',
                          ),
                        ],
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
                onToggleEnabled: () => _setStatus('Colorize toggled'),
                onMoveUp: () => _setStatus('Colorize moved up'),
                onMoveDown: () => _setStatus('Colorize moved down'),
                onRemove: () => _setStatus('Colorize removed'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesColumn() {
    return Column(
      children: <Widget>[
        _buildPropertiesHeader(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              BlenderPropertyTabs(
                tabs: _propertyTabs,
                visibleTabIds: _visiblePropertyTabIds,
                onVisibilityChanged: _setVisiblePropertyTabs,
                selectedIndex: _propertyTab,
                onChanged: (value) {
                  _update(() => _propertyTab = value);
                  _application.editorSession.inspectPropertiesTarget(
                    'showcase',
                    _propertyTabs[value].id,
                  );
                  _setStatus('Properties tab changed');
                },
              ),
              Expanded(
                child: BlenderSplitter(
                  direction: BlenderSplitDirection.vertical,
                  initialFraction: .72,
                  first: BlenderPropertiesEditor(
                    groups: _visiblePropertyGroups,
                    searchController: _propertiesSearchController,
                    topContent:
                        _propertyTab == 1 ||
                            _propertyTab == 4 ||
                            _propertyTab == 5 ||
                            _propertyTab == 7 ||
                            _propertyTab == 13 ||
                            _propertyTab == 16 ||
                            _propertyTab == 3 ||
                            _propertyTab == 6 ||
                            _propertyTab == 17 ||
                            _propertyTab == 10 ||
                            _propertyTab == 14
                        ? _propertyTopContent
                        : null,
                    body: _propertyTab == 18
                        ? const BlenderStripProperties()
                        : _propertyTab == 15
                        ? _buildConstraintPropertiesBody(
                            title: 'Bone Constraints',
                          )
                        : _propertyTab == 12
                        ? _buildConstraintPropertiesBody()
                        : _propertyTab == 9
                        ? _buildShaderFxPropertiesBody()
                        : _propertyTab == 19
                        ? _buildModifierPropertiesBody(title: 'Strip Modifiers')
                        : _propertyTab == 8
                        ? _buildModifierPropertiesBody()
                        : _propertyTab == 0
                        ? _buildToolSettingsBody()
                        : null,
                    joinNavigationRail: true,
                    title: _propertiesContextTitle,
                    headerLeading: BlenderIcon(
                      _propertiesContextGlyph,
                      size: 18,
                      color: _propertyTab == 0 ? const Color(0xFFFFB84A) : null,
                    ),
                    headerActions: _propertyTab == 0
                        ? null
                        : <Widget>[
                            BlenderIconButton(
                              glyph: BlenderGlyph.pin,
                              selected: false,
                              onPressed: () => _setStatus('Properties pinned'),
                              tooltip: 'Pin Properties context',
                              size: 24,
                            ),
                          ],
                    contextMenuItemsBuilder: (property) =>
                        BlenderContextMenuCatalog.property(
                          animated:
                              property.state != BlenderPropertyState.normal,
                        ),
                    onContextMenuSelected: (property, action) =>
                        _setStatus('$action: ${property.label}'),
                  ),
                  second: BlenderPanel(
                    title: 'Quick Controls',
                    child: BlenderScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          BlenderButton(
                            label: 'Apply Modifier',
                            onPressed: () => _setStatus('Modifier applied'),
                          ),
                          const SizedBox(height: 6),
                          BlenderButton(
                            label: 'Add Keyframe',
                            onPressed: () => _setStatus('Keyframe added'),
                          ),
                          const SizedBox(height: 6),
                          BlenderButton(
                            label: 'Reset Object',
                            onPressed: () => _setStatus('Object reset'),
                          ),
                          const BlenderSeparator(),
                          Text(
                            'Viewport Display',
                            style: BlenderTheme.of(context).textTheme.heading,
                          ),
                          const SizedBox(height: 4),
                          BlenderSegmentedControl<String>(
                            value: _wireframe ? 'Wire' : 'Solid',
                            items: const <BlenderMenuItem<String>>[
                              BlenderMenuItem<String>(
                                value: 'Solid',
                                label: 'Solid',
                              ),
                              BlenderMenuItem<String>(
                                value: 'Wire',
                                label: 'Wire',
                              ),
                            ],
                            onChanged: (value) =>
                                _update(() => _wireframe = value == 'Wire'),
                          ),
                          const SizedBox(height: 6),
                          BlenderColorField(
                            label: 'Accent',
                            color: _accentColor,
                            onPressed: () => _setStatus('Color picker focused'),
                          ),
                          const SizedBox(height: 6),
                          BlenderColorPicker(
                            color: _accentColor,
                            onChanged: (value) =>
                                _update(() => _accentColor = value),
                          ),
                          const SizedBox(height: 6),
                          const BlenderProgressBar(
                            value: .68,
                            label: 'Preview 68%',
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Shortcuts',
                            style: BlenderTheme.of(context).textTheme.heading,
                          ),
                          const SizedBox(height: 4),
                          const Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: const <Widget>[
                              BlenderKeycap('G'),
                              SizedBox(width: 4),
                              Text('Move'),
                              BlenderKeycap('R'),
                              SizedBox(width: 4),
                              Text('Rotate'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPropertiesHeader() =>
      Builder(builder: (context) => _buildPropertiesHeaderForTheme(context));

  Widget _buildPropertiesHeaderForTheme(BuildContext context) {
    return BlenderAreaHeader(
      key: const ValueKey<String>('properties-area-header'),
      // Blender keeps the area-type selector separate from the Properties
      // context caption below it. Selecting another type swaps this area.
      height: 26,
      background: BlenderTheme.of(context).colors.propertiesBackground,
      editorType: _rightBottomEditorType,
      showEditorLabel: false,
      onEditorTypeChanged: _rightBottomEditorArea.select,
      leading: const <Widget>[],
      menus: const <Widget>[],
      center: SizedBox(
        // Blender's string-property search occupies six 20px widget units.
        width: 120,
        child: BlenderSearchField(
          controller: _propertiesSearchController,
          placeholder: 'Search',
        ),
      ),
      showBottomBorder: false,
      actions: <Widget>[_buildPropertiesContextOptions()],
    );
  }

  void _setVisiblePropertyTabs(Set<String> visible) {
    _update(() {
      _visiblePropertyTabIds = visible;
      if (!visible.contains(_propertyTabs[_propertyTab].id)) {
        _propertyTab = _propertyTabs.indexWhere(
          (tab) => visible.contains(tab.id),
        );
      }
    });
  }

  Widget _buildPropertiesContextOptions() => Builder(
    builder: (context) {
      final theme = BlenderTheme.of(context);
      return BlenderPopover(
        targetAnchor: Alignment.bottomRight,
        followerAnchor: Alignment.topRight,
        onOpenChanged: (open) =>
            _update(() => _propertiesContextMenuOpen = open),
        child: BlenderIconButton(
          key: const ValueKey<String>('properties-context-options-button'),
          glyph: BlenderGlyph.panelDisclosureDown,
          selected: _propertiesContextMenuOpen,
          tooltip: 'Properties context options',
          size: 20,
        ),
        popover: (context, close) => SizedBox(
          width: 320,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.menuBackground,
              border: Border.all(color: theme.colors.borderSubtle),
              borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x99000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Sync with Outliner',
                    style: theme.textTheme.body.copyWith(
                      color: theme.colors.foregroundMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BlenderSegmentedControl<String>(
                    value: _syncWithOutliner,
                    items: const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'Always', label: 'Always'),
                      BlenderMenuItem<String>(value: 'Never', label: 'Never'),
                      BlenderMenuItem<String>(value: 'Auto', label: 'Auto'),
                    ],
                    onChanged: (value) =>
                        _update(() => _syncWithOutliner = value),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
