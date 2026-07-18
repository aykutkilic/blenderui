part of '../showcase_app.dart';

extension _ShowcaseToolPanels on _ShowcaseAppState {
  Widget _buildToolSettingsPanel({
    required String title,
    required bool expanded,
    required VoidCallback onToggle,
    required Widget child,
    Widget? headerAction,
  }) => Builder(
    builder: (context) {
      final theme = BlenderTheme.of(context);
      return DecoratedBox(
        key: ValueKey<String>('showcase-tool-settings-panel-$title'),
        decoration: BoxDecoration(
          color: theme.colors.panelBackground,
          border: Border.all(color: theme.colors.panelOutline),
          borderRadius: BorderRadius.circular(theme.shapes.panelRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: SizedBox(
                height: theme.density.headerHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: <Widget>[
                      BlenderIcon(
                        key: ValueKey<String>(
                          'tool-settings-panel-disclosure-$title',
                        ),
                        expanded
                            ? BlenderGlyph.panelDisclosureDown
                            : BlenderGlyph.panelDisclosureRight,
                        size: 9,
                        color: theme.colors.foregroundMuted,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.body,
                        ),
                      ),
                      if (headerAction != null) headerAction,
                      BlenderIcon(
                        key: ValueKey<String>(
                          'tool-settings-drag-handle-$title',
                        ),
                        BlenderGlyph.dragHandle,
                        size: 9,
                        color: theme.colors.foregroundMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (expanded) child,
          ],
        ),
      );
    },
  );

  Widget _buildWorkspaceAddonRow({
    required String label,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) => Builder(
    builder: (context) {
      final theme = BlenderTheme.of(context);
      final active = _workspaceFilterByOwner;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.body.copyWith(
                  color: active
                      ? theme.colors.foreground
                      : theme.colors.foregroundDisabled,
                ),
              ),
            ),
            BlenderCheckbox(
              value: enabled,
              label: '',
              onChanged: active ? onChanged : null,
            ),
          ],
        ),
      );
    },
  );

  Widget _buildToolCheckbox({
    required bool value,
    required String label,
    required ValueChanged<bool> onChanged,
  }) => Builder(
    builder: (context) {
      final theme = BlenderTheme.of(context);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Row(
          children: <Widget>[
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: value
                    ? theme.colors.buttonSelected
                    : theme.colors.button,
                border: Border.all(
                  color: value
                      ? theme.colors.buttonSelected
                      : theme.colors.borderSubtle,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              child: value
                  ? const BlenderIcon(BlenderGlyph.check, size: 13)
                  : null,
            ),
            const SizedBox(width: 5),
            Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      );
    },
  );

  Widget _buildWorkspaceToolPanel() {
    final theme = BlenderTheme.of(context);
    return Container(
      color: theme.colors.panelSubSurface,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          BlenderPropertyRow(
            label: 'Pin Scene',
            editor: _buildToolCheckbox(
              value: _workspacePinScene,
              label: '',
              onChanged: (value) => _update(() => _workspacePinScene = value),
            ),
          ),
          BlenderPropertyRow(
            label: 'Mode',
            editor: BlenderDropdown<String>(
              key: const ValueKey<String>('tool-workspace-mode'),
              value: _workspaceMode,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'Object Mode',
                  label: 'Object Mode',
                ),
                BlenderMenuItem<String>(value: 'Edit Mode', label: 'Edit Mode'),
                BlenderMenuItem<String>(
                  value: 'Armature Edit',
                  label: 'Armature Edit',
                ),
                BlenderMenuItem<String>(
                  value: 'Sculpt Mode',
                  label: 'Sculpt Mode',
                ),
                BlenderMenuItem<String>(
                  value: 'Curves Sculpt',
                  label: 'Curves Sculpt',
                ),
                BlenderMenuItem<String>(value: 'Pose Mode', label: 'Pose Mode'),
                BlenderMenuItem<String>(
                  value: 'Weight Paint',
                  label: 'Weight Paint',
                ),
                BlenderMenuItem<String>(
                  value: 'Vertex Paint',
                  label: 'Vertex Paint',
                ),
                BlenderMenuItem<String>(
                  value: 'Texture Paint',
                  label: 'Texture Paint',
                ),
                BlenderMenuItem<String>(
                  value: 'Particle Edit',
                  label: 'Particle Edit',
                ),
                BlenderMenuItem<String>(
                  value: 'Grease Pencil Draw',
                  label: 'Grease Pencil Draw',
                ),
                BlenderMenuItem<String>(
                  value: 'Grease Pencil Sculpt',
                  label: 'Grease Pencil Sculpt',
                ),
                BlenderMenuItem<String>(
                  value: 'Grease Pencil Weight Paint',
                  label: 'Grease Pencil Weight Paint',
                ),
                BlenderMenuItem<String>(
                  value: 'Grease Pencil Vertex Paint',
                  label: 'Grease Pencil Vertex Paint',
                ),
              ],
              onChanged: (value) => _update(() => _workspaceMode = value),
            ),
          ),
          const BlenderPropertyRow(
            label: 'Sequencer Scene',
            editor: const BlenderDataBlockField<String>(
              value: 'Scene',
              icon: BlenderGlyph.scene,
              items: <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'Scene',
                  label: 'Scene',
                  icon: BlenderIcon(BlenderGlyph.scene, size: 14),
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
            ),
          ),
          BlenderPropertyRow(
            label: 'Scene Time Sync',
            editor: _buildToolCheckbox(
              value: _workspaceSyncTime,
              label: '',
              onChanged: (value) => _update(() => _workspaceSyncTime = value),
            ),
          ),
          const SizedBox(height: 6),
          _buildToolSettingsPanel(
            title: 'Filter Add-ons',
            expanded: _toolWorkspaceFilterExpanded,
            onToggle: () => _update(
              () =>
                  _toolWorkspaceFilterExpanded = !_toolWorkspaceFilterExpanded,
            ),
            headerAction: BlenderCheckbox(
              key: const ValueKey<String>('tool-workspace-filter-by-owner'),
              value: _workspaceFilterByOwner,
              label: '',
              onChanged: (value) =>
                  _update(() => _workspaceFilterByOwner = value),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildWorkspaceAddonRow(
                    label: 'Animation: Built-in',
                    enabled: _workspaceAnimationAddon,
                    onChanged: (value) =>
                        _update(() => _workspaceAnimationAddon = value),
                  ),
                  _buildWorkspaceAddonRow(
                    label: 'Modeling: Mesh Tools',
                    enabled: _workspaceModelingAddon,
                    onChanged: (value) =>
                        _update(() => _workspaceModelingAddon = value),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7, bottom: 3),
                    child: Row(
                      children: <Widget>[
                        BlenderIcon(
                          BlenderGlyph.warningFilled,
                          size: 14,
                          color: theme.colors.warning,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Unknown add-ons',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.caption.copyWith(
                              color: theme.colors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colors.panelSubSurface,
                      border: Border.all(color: theme.colors.panelOutline),
                    ),
                    child: _buildWorkspaceAddonRow(
                      label: 'legacy_tools',
                      enabled: _workspaceUnknownAddon,
                      onChanged: (value) =>
                          _update(() => _workspaceUnknownAddon = value),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          BlenderPanel(
            title: 'Custom Properties',
            disclosureKey: const ValueKey<String>(
              'tool-settings-nested-disclosure-Custom Properties',
            ),
            collapsible: true,
            expanded: false,
            onExpansionChanged: (_) =>
                _setStatus('Workspace custom properties'),
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildBrushAssetPanel() {
    return Container(
      color: BlenderTheme.of(context).colors.panelSubSurface,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: BlenderButton(
                  label: 'Sculpt Clay',
                  leading: const BlenderIcon(
                    BlenderGlyph.assetManager,
                    size: 14,
                  ),
                  variant: BlenderButtonVariant.toolbar,
                  onPressed: () => _setStatus('Brush asset selected'),
                ),
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.menu,
                size: 22,
                tooltip: 'Brush Asset menu',
                onPressed: () => _setStatus('Brush Asset menu opened'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrushSettingsPanel() {
    if (_workspaceMode.startsWith('Grease Pencil')) {
      return _buildGreasePencilBrushSettingsPanel();
    }
    final controls = _ShowcaseBrushControls(this);

    Widget nestedBrushPanel(String title) {
      Widget child = _buildPaintToolSubpanelContent(title);
      if (title == 'Stroke') {
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            child,
            controls.nested(
              'Stabilize Stroke',
              _buildPaintToolSubpanelContent('Stabilize Stroke'),
            ),
          ],
        );
      } else if (title == 'Falloff') {
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            child,
            controls.nested(
              'Front-Face Falloff',
              _buildPaintToolSubpanelContent('Front-Face Falloff'),
            ),
            controls.nested(
              'Normal Falloff',
              _buildPaintToolSubpanelContent('Normal Falloff'),
            ),
          ],
        );
      }
      return controls.nested(title, child);
    }

    return Container(
      color: BlenderTheme.of(context).colors.panelSubSurface,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          controls.dropdown('Tool', 'Draw', <String>['Draw', 'Smooth', 'Grab']),
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
          nestedBrushPanel('Color Picker'),
          const SizedBox(height: 3),
          nestedBrushPanel('Color Palette'),
          const SizedBox(height: 3),
          nestedBrushPanel('Clone from Paint Slot'),
          const SizedBox(height: 3),
          nestedBrushPanel('Cursor'),
          const SizedBox(height: 3),
          nestedBrushPanel('Texture'),
          const SizedBox(height: 3),
          nestedBrushPanel('Texture Mask'),
          const SizedBox(height: 3),
          nestedBrushPanel('Stroke'),
          const SizedBox(height: 3),
          nestedBrushPanel('Falloff'),
        ],
      ),
    );
  }
}
