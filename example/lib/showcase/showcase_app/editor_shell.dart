part of '../showcase_app.dart';

extension _ShowcaseEditorShell on _ShowcaseAppState {
  Widget _buildDockedArea(
    BuildContext context,
    BlenderDockAreaNode<String> area,
  ) {
    return switch (area.value) {
      'main' => _buildEditorAreaHost(_mainEditorArea, _buildMainEditor),
      'bottom' => _buildBottomEditor(),
      'right-top' => _buildEditorAreaHost(
        _rightTopEditorArea,
        _buildRightTopArea,
      ),
      'right-bottom' => _buildEditorAreaHost(
        _rightBottomEditorArea,
        _buildRightBottomArea,
      ),
      _ => _buildEditorAreaHost(_mainEditorArea, _buildMainEditor),
    };
  }

  Widget _buildEditorAreaHost(
    BlenderEditorAreaController<BlenderEditorType> controller,
    Widget Function() builder,
  ) => BlenderEditorAreaHost<BlenderEditorType>(
    controller: controller,
    views: <BlenderEditorAreaView<BlenderEditorType>>[
      for (final type in BlenderEditorType.values)
        BlenderEditorAreaView<BlenderEditorType>(
          value: type,
          builder: (_) => builder(),
        ),
    ],
  );

  Widget _buildMainToolbar() =>
      Builder(builder: (context) => _buildMainToolbarForTheme(context));

  Widget _buildLeftSidebar() {
    return BlenderToolShelf(
      width: 48,
      tools: const <BlenderToolDefinition>[
        BlenderToolDefinition(
          glyph: BlenderGlyph.pointer,
          tooltip: 'Select tool',
          options: <BlenderToolOption>[
            BlenderToolOption(
              label: 'Tweak',
              glyph: BlenderGlyph.pointer,
              shortcut: 'Space Bar',
              description: 'Select and transform elements directly.',
            ),
            BlenderToolOption(
              label: 'Select Box',
              glyph: BlenderGlyph.selectBox,
              shortcut: 'W',
              description: 'Select elements inside a rectangular region.',
            ),
            BlenderToolOption(
              label: 'Select Circle',
              glyph: BlenderGlyph.radio,
              shortcut: 'C',
              description: 'Select elements inside a circular region.',
            ),
            BlenderToolOption(
              label: 'Select Lasso',
              glyph: BlenderGlyph.pointer,
              shortcut: 'Ctrl Space',
              description: 'Select elements inside a freeform region.',
            ),
          ],
        ),
        BlenderToolDefinition(glyph: BlenderGlyph.plus, tooltip: 'Add tool'),
        BlenderToolDefinition(
          glyph: BlenderGlyph.transform,
          tooltip: 'Move tool',
        ),
        BlenderToolDefinition(
          glyph: BlenderGlyph.rotate,
          tooltip: 'Rotate tool',
        ),
        BlenderToolDefinition(glyph: BlenderGlyph.scale, tooltip: 'Scale tool'),
        BlenderToolDefinition(glyph: BlenderGlyph.pan, tooltip: 'Pan tool'),
        BlenderToolDefinition(glyph: BlenderGlyph.zoom, tooltip: 'Zoom tool'),
        BlenderToolDefinition(
          glyph: BlenderGlyph.tool,
          tooltip: 'Tool settings',
        ),
      ],
      selectedIndex: _toolIndex,
      onChanged: (value) {
        _update(() => _toolIndex = value);
        _setStatus('Tool changed');
      },
      onOptionSelected: (option) => _setStatus('Tool: ${option.label}'),
    );
  }

  Widget _buildMainEditor() {
    return Column(
      children: <Widget>[
        _buildMainEditorHeader(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildLeftSidebar(),
              Expanded(child: _buildMainEditorSurface()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainEditorHeader() {
    return switch (_mainEditorType) {
      BlenderEditorType.view3d => _buildView3dHeader(),
      BlenderEditorType.imageEditor ||
      BlenderEditorType.uvEditor => _buildImageEditorHeader(_mainEditorType),
      BlenderEditorType.timeline || BlenderEditorType.dopeSheet =>
        _buildAnimationEditorHeader(_mainEditorType),
      BlenderEditorType.nlaEditor => _buildNlaEditorHeader(),
      BlenderEditorType.graphEditor ||
      BlenderEditorType.drivers => _buildGraphEditorHeader(_mainEditorType),
      BlenderEditorType.sequencer || BlenderEditorType.videoEditing =>
        _buildSequencerEditorHeader(_mainEditorType),
      BlenderEditorType.shaderEditor ||
      BlenderEditorType.geometryNodeEditor ||
      BlenderEditorType.compositor ||
      BlenderEditorType.textureNodeEditor => _buildNodeEditorHeader(
        _mainEditorType,
      ),
      BlenderEditorType.clipEditor => _buildClipEditorHeader(),
      BlenderEditorType.spreadsheet => _buildSpreadsheetEditorHeader(),
      _ => _buildUtilityEditorHeader(_mainEditorType),
    };
  }

  Widget _buildView3dHeader() {
    return BlenderAreaHeader(
      height: 30,
      editorType: _mainEditorType,
      showEditorLabel: false,
      onEditorTypeChanged: _mainEditorArea.select,
      actionsScrollable: true,
      leading: <Widget>[
        SizedBox(
          width: 118,
          child: BlenderDropdown<String>(
            value: 'Object Mode',
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Object Mode',
                label: 'Object Mode',
              ),
              BlenderMenuItem<String>(value: 'Edit Mode', label: 'Edit Mode'),
              BlenderMenuItem<String>(
                value: 'Sculpt Mode',
                label: 'Sculpt Mode',
              ),
            ],
            onChanged: (value) => _setStatus('$value selected'),
          ),
        ),
      ],
      menuDescriptors: _editorHeaderPresets[BlenderEditorType.view3d]!
          .menuDescriptors(_application.commands),
      actions: <Widget>[
        SizedBox(
          width: 88,
          child: BlenderDropdown<String>(
            key: const ValueKey<String>('viewport-transform-orientation'),
            value: _transformOrientation,
            compact: true,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Global', label: 'Global'),
              BlenderMenuItem<String>(value: 'Local', label: 'Local'),
              BlenderMenuItem<String>(value: 'Normal', label: 'Normal'),
              BlenderMenuItem<String>(value: 'View', label: 'View'),
              BlenderMenuItem<String>(value: 'Cursor', label: 'Cursor'),
            ],
            onChanged: (value) => _update(() => _transformOrientation = value),
          ),
        ),
        BlenderIconButton(
          key: const ValueKey<String>('viewport-transform-pivot'),
          glyph: BlenderGlyph.transform,
          selected: _transformPivot == 'Median Point',
          onPressed: () => _update(
            () => _transformPivot = _transformPivot == 'Median Point'
                ? 'Individual Origins'
                : 'Median Point',
          ),
          tooltip: 'Pivot Point: $_transformPivot',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('viewport-snap'),
          glyph: BlenderGlyph.snap,
          selected: _snapEnabled,
          onPressed: () => _update(() => _snapEnabled = !_snapEnabled),
          tooltip: 'Snap',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('viewport-proportional-editing'),
          glyph: BlenderGlyph.transform,
          selected: _proportionalEditing,
          onPressed: () =>
              _update(() => _proportionalEditing = !_proportionalEditing),
          tooltip: 'Proportional Editing',
        ),
        const BlenderIconButton(
          key: const ValueKey<String>('viewport-object-visibility'),
          glyph: BlenderGlyph.eye,
          tooltip: 'Object visibility',
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('viewport-gizmo'),
            glyph: BlenderGlyph.gizmo,
            selected: _showGizmos,
            onPressed: () => _update(() => _showGizmos = !_showGizmos),
            tooltip: 'Toggle gizmos',
          ),
          popover: (context, close) =>
              _buildViewportPopoverPanel('Gizmo Display', <Widget>[
                BlenderCheckbox(
                  value: _showGizmos,
                  label: 'Show Gizmos',
                  onChanged: (value) => _update(() => _showGizmos = value),
                ),
                BlenderCheckbox(
                  value: true,
                  label: 'Navigate Gizmo',
                  onChanged: (value) => _setStatus('Navigate gizmo toggled'),
                ),
                BlenderCheckbox(
                  value: true,
                  label: 'Tool Gizmos',
                  onChanged: (value) => _setStatus('Tool gizmos toggled'),
                ),
              ]),
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('viewport-overlays'),
            glyph: BlenderGlyph.overlay,
            selected: _showOverlays,
            onPressed: () => _update(() => _showOverlays = !_showOverlays),
            tooltip: 'Toggle overlays',
          ),
          popover: (context, close) =>
              _buildViewportPopoverPanel('Overlays', <Widget>[
                BlenderCheckbox(
                  value: _showOverlays,
                  label: 'Show Overlays',
                  onChanged: (value) => _update(() => _showOverlays = value),
                ),
                BlenderCheckbox(
                  value: true,
                  label: 'Floor',
                  onChanged: (value) => _setStatus('Floor overlay toggled'),
                ),
                BlenderCheckbox(
                  value: true,
                  label: 'Relationship Lines',
                  onChanged: (value) =>
                      _setStatus('Relationship lines toggled'),
                ),
                BlenderCheckbox(
                  value: true,
                  label: 'Text Info',
                  onChanged: (value) => _setStatus('Text info toggled'),
                ),
              ]),
        ),
        BlenderIconButton(
          key: const ValueKey<String>('viewport-xray'),
          glyph: BlenderGlyph.xray,
          selected: _showXray,
          onPressed: () => _update(() => _showXray = !_showXray),
          tooltip: 'X-Ray',
        ),
        for (final shading in const <String>[
          'Wireframe',
          'Solid',
          'Material Preview',
          'Rendered',
        ])
          BlenderIconButton(
            key: ValueKey<String>(
              'viewport-shading-${shading.toLowerCase().replaceAll(' ', '-')}',
            ),
            glyph: switch (shading) {
              'Wireframe' => BlenderGlyph.wireframe,
              'Solid' => BlenderGlyph.solid,
              'Material Preview' => BlenderGlyph.materialPreview,
              _ => BlenderGlyph.rendered,
            },
            selected: _viewportShading == shading,
            onPressed: () => _update(() {
              _viewportShading = shading;
              _wireframe = shading == 'Wireframe';
            }),
            tooltip: shading,
          ),
        BlenderPopover(
          child: const BlenderIconButton(
            key: const ValueKey<String>('viewport-shading-options'),
            glyph: BlenderGlyph.settings,
            tooltip: 'Viewport shading options',
          ),
          popover: (context, close) => _buildViewportPopoverPanel(
            'Shading',
            <Widget>[
              BlenderDropdown<String>(
                value: _viewportShading,
                items: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Wireframe',
                    label: 'Wireframe',
                  ),
                  BlenderMenuItem<String>(value: 'Solid', label: 'Solid'),
                  BlenderMenuItem<String>(
                    value: 'Material Preview',
                    label: 'Material Preview',
                  ),
                  BlenderMenuItem<String>(value: 'Rendered', label: 'Rendered'),
                ],
                onChanged: (value) => _update(() {
                  _viewportShading = value;
                  _wireframe = value == 'Wireframe';
                }),
              ),
              const SizedBox(height: 6),
              BlenderCheckbox(
                value: _showXray,
                label: 'X-Ray',
                onChanged: (value) => _update(() => _showXray = value),
              ),
              BlenderCheckbox(
                value: true,
                label: 'Cavity',
                onChanged: (value) => _setStatus('Cavity toggled'),
              ),
              BlenderCheckbox(
                value: true,
                label: 'Outline',
                onChanged: (value) => _setStatus('Outline toggled'),
              ),
            ],
          ),
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Area options',
        ),
      ],
    );
  }

  Widget _buildViewportPopoverPanel(String title, List<Widget> children) {
    return BlenderPopoverPanel(
      title: title,
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  BlenderAreaHeader _buildImageEditorHeader(BlenderEditorType type) {
    final uvEditor = type == BlenderEditorType.uvEditor;
    final menus = <String>['View', 'Select', 'Image', if (uvEditor) 'UVs'];
    final menuItems = <String, List<String>>{
      'View': <String>[
        'Toolbar',
        'Sidebar',
        'Tool Header',
        'Asset Shelf',
        'HUD',
        'Use Realtime Update',
        'Show Metadata',
        'Frame Selected',
        'View All',
        'Center View to Cursor',
        'Zoom',
        'Render Border',
        'Clear Render Border',
        'Render Slot Cycle Next',
        'Render Slot Cycle Previous',
        'Area',
      ],
      'Select': <String>[
        'All',
        'None',
        'Invert',
        'Box Select',
        'Circle Select',
        'Lasso Select',
        'Select Linked',
      ],
      'Image': <String>[
        'New...',
        'Open...',
        'Replace...',
        'Reload',
        'Save',
        'Save As...',
        'Pack',
        'Unpack',
      ],
      'UVs': <String>[
        'Transform',
        'Mirror',
        'Snap',
        'Merge',
        'Split',
        'Unwrap',
        'Pack Islands',
        'Average Islands Scale',
        'Show/Hide Faces',
      ],
    };
    final detailedMenus = <String, List<BlenderMenuItem<String>>>{
      'View': <BlenderMenuItem<String>>[
        for (final label in menuItems['View']!)
          if (label == 'Zoom')
            const BlenderMenuItem<String>(
              value: 'Zoom',
              label: 'Zoom',
              submenu: <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: '12.5%', label: '12.5% (1:8)'),
                BlenderMenuItem<String>(value: '25%', label: '25% (1:4)'),
                BlenderMenuItem<String>(value: '50%', label: '50% (1:2)'),
                BlenderMenuItem<String>(value: '100%', label: '100% (1:1)'),
                BlenderMenuItem<String>(value: '200%', label: '200% (2:1)'),
                BlenderMenuItem<String>(value: 'Fit', label: 'Zoom to Fit'),
                BlenderMenuItem<String>(
                  value: 'Region',
                  label: 'Zoom Region...',
                ),
              ],
            )
          else
            BlenderMenuItem<String>(value: label, label: label),
      ],
    };
    return BlenderAreaHeader(
      height: 30,
      editorType: type,
      showEditorLabel: false,
      onEditorTypeChanged: _mainEditorArea.select,
      leading: <Widget>[
        SizedBox(
          width: 86,
          child: BlenderDropdown<String>(
            key: const ValueKey<String>('image-display-source'),
            value: uvEditor ? 'UV Map' : 'Image',
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Image', label: 'Image'),
              BlenderMenuItem<String>(value: 'UV Map', label: 'UV Map'),
            ],
            onChanged: _setStatus,
          ),
        ),
      ],
      menuDescriptors: _editorMenuDescriptors(
        menus,
        menuItems: menuItems,
        menuDescriptors: detailedMenus,
      ),
      actions: <Widget>[
        if (uvEditor)
          BlenderIconButton(
            key: const ValueKey<String>('image-uv-sync-button'),
            glyph: BlenderGlyph.link,
            selected: _imageUvSync,
            onPressed: () => _update(() => _imageUvSync = !_imageUvSync),
            tooltip: 'UV selection sync',
          ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('image-snap-button'),
            glyph: BlenderGlyph.snap,
            selected: _imageSnap,
            tooltip: 'UV snapping',
          ),
          onOpenChanged: (open) => _update(() => _imageSnap = open),
          popover: (context, close) => _buildAnimationPopoverPanel(
            'Snapping',
            <Widget>[
              Text(
                'Snap Target',
                style: BlenderTheme.of(context).textTheme.caption,
              ),
              BlenderDropdown<String>(
                value: 'Vertex',
                items: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Vertex', label: 'Vertex'),
                  BlenderMenuItem<String>(value: 'Edge', label: 'Edge'),
                  BlenderMenuItem<String>(value: 'Face', label: 'Face'),
                  BlenderMenuItem<String>(
                    value: 'Increment',
                    label: 'Increment',
                  ),
                ],
                onChanged: (_) {},
              ),
              const SizedBox(height: 6),
              Text(
                'Snap Base',
                style: BlenderTheme.of(context).textTheme.caption,
              ),
              BlenderDropdown<String>(
                value: 'Median',
                items: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Median', label: 'Median'),
                  BlenderMenuItem<String>(value: 'Closest', label: 'Closest'),
                  BlenderMenuItem<String>(value: 'Active', label: 'Active'),
                ],
                onChanged: (_) {},
              ),
              const SizedBox(height: 6),
              BlenderCheckbox(value: true, label: 'Move', onChanged: (_) {}),
              BlenderCheckbox(value: false, label: 'Rotate', onChanged: (_) {}),
              BlenderCheckbox(value: false, label: 'Scale', onChanged: (_) {}),
            ],
          ),
        ),
        if (uvEditor)
          BlenderPopover(
            child: BlenderIconButton(
              key: const ValueKey<String>('image-proportional-button'),
              glyph: BlenderGlyph.transform,
              selected: _imageProportional,
              tooltip: 'Proportional editing',
            ),
            onOpenChanged: (open) => _update(() => _imageProportional = open),
            popover: (context, close) =>
                _buildAnimationPopoverPanel('Proportional Editing', <Widget>[
                  BlenderCheckbox(
                    value: true,
                    label: 'Connected',
                    onChanged: (_) {},
                  ),
                  Text(
                    'Falloff',
                    style: BlenderTheme.of(context).textTheme.caption,
                  ),
                  BlenderDropdown<String>(
                    value: 'Smooth',
                    items: const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'Smooth', label: 'Smooth'),
                      BlenderMenuItem<String>(value: 'Sphere', label: 'Sphere'),
                      BlenderMenuItem<String>(value: 'Sharp', label: 'Sharp'),
                    ],
                    onChanged: (_) {},
                  ),
                ]),
          ),
        const BlenderIconButton(
          key: const ValueKey<String>('image-pin-button'),
          glyph: BlenderGlyph.pin,
          tooltip: 'Pin image',
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('image-gizmo-button'),
            glyph: BlenderGlyph.gizmo,
            selected: _imageGizmos,
            tooltip: 'Image gizmos',
          ),
          popover: (context, close) =>
              _buildAnimationPopoverPanel('Gizmos', <Widget>[
                BlenderCheckbox(
                  value: _imageGizmos,
                  label: 'Show Gizmos',
                  onChanged: (value) => _update(() => _imageGizmos = value),
                ),
                BlenderCheckbox(
                  value: true,
                  label: 'Navigate Gizmo',
                  onChanged: (_) {},
                ),
              ]),
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('image-overlay-button'),
            glyph: BlenderGlyph.overlay,
            selected: _imageOverlays,
            tooltip: 'Image overlays',
          ),
          popover: (context, close) =>
              _buildAnimationPopoverPanel('Overlays', <Widget>[
                BlenderCheckbox(
                  value: _imageOverlays,
                  label: 'Show Overlays',
                  onChanged: (value) => _update(() => _imageOverlays = value),
                ),
                BlenderCheckbox(
                  value: true,
                  label: 'Image Metadata',
                  onChanged: (_) {},
                ),
                BlenderCheckbox(value: true, label: 'Grid', onChanged: (_) {}),
              ]),
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }

  BlenderAreaHeader _buildSpreadsheetEditorHeader() {
    return BlenderAreaHeader(
      height: 30,
      editorType: BlenderEditorType.spreadsheet,
      showEditorLabel: false,
      onEditorTypeChanged: _mainEditorArea.select,
      menuDescriptors: _editorMenuDescriptors(
        const <String>['View'],
        menuItems: const <String, List<String>>{
          'View': <String>['Toolbar', 'Sidebar', 'Internal Attributes', 'Area'],
        },
      ),
      actions: <Widget>[
        BlenderIconButton(
          key: const ValueKey<String>('spreadsheet-only-selected-button'),
          glyph: BlenderGlyph.eye,
          selected: _spreadsheetOnlySelected,
          onPressed: () => _update(
            () => _spreadsheetOnlySelected = !_spreadsheetOnlySelected,
          ),
          tooltip: 'Only Selected',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('spreadsheet-filter-button'),
          glyph: BlenderGlyph.filter,
          selected: _spreadsheetFilter,
          onPressed: () =>
              _update(() => _spreadsheetFilter = !_spreadsheetFilter),
          tooltip: 'Use Filter',
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }
}
