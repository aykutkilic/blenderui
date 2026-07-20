part of '../editors.dart';

/// Draw-mode View3D header following `VIEW3D_HT_header` Grease Pencil branches.
class BlenderGreasePencilEditorHeader extends StatelessWidget {
  const BlenderGreasePencilEditorHeader({
    super.key,
    this.state = const BlenderGreasePencilHeaderState(),
    this.onStateChanged,
    this.onEditorTypeChanged,
    this.onCommand,
  });

  final BlenderGreasePencilHeaderState state;
  final ValueChanged<BlenderGreasePencilHeaderState>? onStateChanged;
  final ValueChanged<BlenderEditorType>? onEditorTypeChanged;
  final ValueChanged<String>? onCommand;

  void _update(BlenderGreasePencilHeaderState next) =>
      onStateChanged?.call(next);

  @override
  Widget build(BuildContext context) => BlenderAreaHeader(
    height: 30,
    editorType: BlenderEditorType.view3d,
    showEditorLabel: false,
    onEditorTypeChanged: onEditorTypeChanged,
    actionsScrollable: true,
    leading: <Widget>[
      SizedBox(
        width: 136,
        child: BlenderView3dModeSelector(
          value: state.mode,
          onChanged: (value) => _update(state.copyWith(mode: value)),
        ),
      ),
    ],
    menuDescriptors: BlenderEditorMenuCatalog.build(
      const <String>['View', 'Draw'],
      menuItems: _menus,
      onSelected: onCommand,
    ),
    actions: <Widget>[
      _dropdown(
        state.placement,
        const <String>['Origin', 'Cursor', 'Surface', 'Stroke'],
        BlenderGlyph.transform,
        (value) => _update(state.copyWith(placement: value)),
        width: 118,
      ),
      _dropdown(
        state.viewAxis,
        const <String>['Front (X-Z)', 'Side (Y-Z)', 'Top (X-Y)', 'View'],
        BlenderGlyph.camera,
        (value) => _update(state.copyWith(viewAxis: value)),
        width: 132,
      ),
      _dropdown(
        state.strokePlacement,
        const <String>['Lines', 'Dots', 'Boxes'],
        BlenderGlyph.greasepencil,
        (value) => _update(state.copyWith(strokePlacement: value)),
        width: 100,
      ),
      BlenderIconButton(
        key: const ValueKey<String>('gp-multiframe'),
        glyph: BlenderGlyph.keyframe,
        selected: state.multiFrame,
        onPressed: () => _update(state.copyWith(multiFrame: !state.multiFrame)),
        tooltip: 'Multi-frame Editing',
      ),
      BlenderIconButton(
        key: const ValueKey<String>('gp-additive-drawing'),
        glyph: BlenderGlyph.plus,
        selected: state.additiveDrawing,
        onPressed: () =>
            _update(state.copyWith(additiveDrawing: !state.additiveDrawing)),
        tooltip: 'Additive Drawing',
      ),
      BlenderIconButton(
        key: const ValueKey<String>('gp-auto-merge'),
        glyph: BlenderGlyph.snap,
        selected: state.autoMerge,
        onPressed: () => _update(state.copyWith(autoMerge: !state.autoMerge)),
        tooltip: 'Auto Merge Strokes',
      ),
      BlenderIconButton(
        key: const ValueKey<String>('gp-add-weight-data'),
        glyph: BlenderGlyph.plus,
        selected: state.addWeightData,
        onPressed: () =>
            _update(state.copyWith(addWeightData: !state.addWeightData)),
        tooltip: 'Add Weight Data',
      ),
      BlenderIconButton(
        key: const ValueKey<String>('gp-draw-on-back'),
        glyph: BlenderGlyph.viewLayer,
        selected: state.drawOnBack,
        onPressed: () => _update(state.copyWith(drawOnBack: !state.drawOnBack)),
        tooltip: 'Draw Strokes on Back',
      ),
      BlenderIconButton(
        glyph: BlenderGlyph.gizmo,
        selected: state.gizmos,
        onPressed: () => _update(state.copyWith(gizmos: !state.gizmos)),
        tooltip: 'Gizmos',
      ),
      BlenderIconButton(
        glyph: BlenderGlyph.overlay,
        selected: state.overlays,
        onPressed: () => _update(state.copyWith(overlays: !state.overlays)),
        tooltip: 'Overlays',
      ),
      BlenderIconButton(
        glyph: BlenderGlyph.materialPreview,
        selected: state.materialPreview,
        onPressed: () =>
            _update(state.copyWith(materialPreview: !state.materialPreview)),
        tooltip: 'Material Preview',
      ),
    ],
  );

  Widget _dropdown(
    String value,
    List<String> values,
    BlenderGlyph glyph,
    ValueChanged<String> onChanged, {
    required double width,
  }) => SizedBox(
    width: width,
    child: BlenderDropdown<String>(
      value: value,
      items: <BlenderMenuItem<String>>[
        for (final item in values)
          BlenderMenuItem<String>(
            value: item,
            label: item,
            icon: BlenderIcon(glyph, size: 14),
          ),
      ],
      onChanged: onChanged,
    ),
  );

  static const Map<String, List<String>> _menus = <String, List<String>>{
    'View': <String>[
      'Toolbar',
      'Sidebar',
      'Tool Header',
      'Asset Shelf',
      'Camera',
      'Viewpoint',
      'Navigation',
      'Frame Selected',
      'Frame All',
      'Playback',
      'Area',
    ],
    'Draw': <String>[
      'Animation',
      'Interpolate',
      'Duplicate Active Keyframe',
      'Clean Up',
      'Delete Active Keyframe',
    ],
  };
}

/// Tool Header region: active brush, material, radius and strength controls.
class BlenderGreasePencilToolHeader extends StatelessWidget {
  const BlenderGreasePencilToolHeader({
    super.key,
    required this.brushes,
    this.materials = const <BlenderGreasePencilMaterial>[
      BlenderGreasePencilMaterial(id: 'Solid Stroke', label: 'Solid Stroke'),
      BlenderGreasePencilMaterial(
        id: 'Solid Fill',
        label: 'Solid Fill',
        strokeColor: Color(0xFFB8B8B8),
      ),
      BlenderGreasePencilMaterial(id: 'Line', label: 'Line'),
    ],
    this.state = const BlenderGreasePencilToolSettings(),
    this.onChanged,
    this.onMaterialChanged,
    this.onCommand,
  });

  final List<BlenderGreasePencilBrush> brushes;
  final List<BlenderGreasePencilMaterial> materials;
  final BlenderGreasePencilToolSettings state;
  final ValueChanged<BlenderGreasePencilToolSettings>? onChanged;
  final ValueChanged<BlenderGreasePencilMaterial>? onMaterialChanged;
  final ValueChanged<String>? onCommand;

  @override
  Widget build(BuildContext context) {
    assert(brushes.isNotEmpty, 'At least one brush is required.');
    return BlenderToolbar(
      key: const ValueKey<String>('gp-tool-header'),
      height: 30,
      scrollable: true,
      children: <Widget>[
        SizedBox(
          width: 178,
          child: BlenderGreasePencilBrushSelector(
            brushes: brushes,
            selectedId: state.brushId,
            onSelected: (brush) =>
                onChanged?.call(state.copyWith(brushId: brush.id)),
          ),
        ),
        SizedBox(
          width: 190,
          child: BlenderGreasePencilMaterialSelector(
            materials: materials,
            selectedId: state.material,
            enabled: !state.pinMaterial,
            onSelected: (material) =>
                onChanged?.call(state.copyWith(material: material.id)),
            onChanged: onMaterialChanged,
          ),
        ),
        BlenderIconButton(
          glyph: BlenderGlyph.pin,
          selected: state.pinMaterial,
          onPressed: () =>
              onChanged?.call(state.copyWith(pinMaterial: !state.pinMaterial)),
          tooltip: 'Pin Material',
        ),
        SizedBox(
          width: 150,
          child: BlenderNumberField(
            label: 'Size',
            value: state.radius,
            min: .001,
            max: 1,
            step: .01,
            suffix: 'm',
            onChanged: (value) =>
                onChanged?.call(state.copyWith(radius: value)),
          ),
        ),
        BlenderIconButton(
          glyph: BlenderGlyph.curve,
          selected: state.usePressureRadius,
          onPressed: () => onChanged?.call(
            state.copyWith(usePressureRadius: !state.usePressureRadius),
          ),
          tooltip: 'Pressure affects radius',
        ),
        SizedBox(
          width: 168,
          child: BlenderNumberField(
            label: 'Strength',
            value: state.strength,
            min: 0,
            max: 1,
            step: .05,
            onChanged: (value) =>
                onChanged?.call(state.copyWith(strength: value)),
          ),
        ),
        BlenderIconButton(
          glyph: BlenderGlyph.curve,
          selected: state.usePressureStrength,
          onPressed: () => onChanged?.call(
            state.copyWith(usePressureStrength: !state.usePressureStrength),
          ),
          tooltip: 'Pressure affects strength',
        ),
        for (final label in const <String>['Advanced', 'Stroke', 'Display'])
          BlenderButton(
            label: label,
            variant: BlenderButtonVariant.toolbar,
            onPressed: () => onCommand?.call(label),
          ),
      ],
    );
  }
}

/// Header trigger backed by Blender's full asset-shelf popup, not a menu.
class BlenderGreasePencilBrushSelector extends StatelessWidget {
  const BlenderGreasePencilBrushSelector({
    super.key,
    required this.brushes,
    this.selectedId,
    this.onSelected,
  });

  final List<BlenderGreasePencilBrush> brushes;
  final String? selectedId;
  final ValueChanged<BlenderGreasePencilBrush>? onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = brushes
        .where((brush) => brush.id == selectedId)
        .firstOrNull;
    final categories = <String>{for (final brush in brushes) brush.category};
    return BlenderAssetShelfPopover(
      key: const ValueKey<String>('gp-brush-selector'),
      label: selected?.label ?? brushes.firstOrNull?.label ?? 'Brush',
      icon: selected?.glyph ?? BlenderGlyph.greasepencil,
      preview: selected?.preview,
      selectedId: selectedId,
      width: 980,
      height: 270,
      big: true,
      catalogs: <BlenderAssetCatalog>[
        BlenderAssetCatalog(
          id: 'brushes',
          label: 'Brushes',
          children: <BlenderAssetCatalog>[
            BlenderAssetCatalog(
              id: 'grease-pencil-draw',
              label: 'Grease Pencil Draw',
              children: <BlenderAssetCatalog>[
                for (final category in categories)
                  BlenderAssetCatalog(
                    id: category.toLowerCase(),
                    label: category,
                  ),
              ],
            ),
          ],
        ),
      ],
      assets: <BlenderAssetShelfPopoverItem>[
        for (final brush in brushes)
          BlenderAssetShelfPopoverItem(
            id: brush.id,
            label: brush.label,
            catalogId: brush.category.toLowerCase(),
            preview: brush.preview,
            color: brush.color,
          ),
      ],
      onSelected: (asset) {
        final brush = brushes.where((item) => item.id == asset.id).firstOrNull;
        if (brush != null) onSelected?.call(brush);
      },
    );
  }
}

/// `TOPBAR_PT_grease_pencil_materials`: material slots plus color controls.
class BlenderGreasePencilMaterialSelector extends StatelessWidget {
  const BlenderGreasePencilMaterialSelector({
    super.key,
    required this.materials,
    this.selectedId,
    this.onSelected,
    this.onChanged,
    this.enabled = true,
  });

  final List<BlenderGreasePencilMaterial> materials;
  final String? selectedId;
  final ValueChanged<BlenderGreasePencilMaterial>? onSelected;
  final ValueChanged<BlenderGreasePencilMaterial>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = materials
        .where((material) => material.id == selectedId)
        .firstOrNull;
    final trigger = BlenderButton(
      key: const ValueKey<String>('gp-material-selector-button'),
      label: active?.label ?? materials.firstOrNull?.label ?? 'Material',
      leading: _materialSwatch(active?.strokeColor ?? const Color(0xFF111111)),
      trailing: const BlenderIcon(BlenderGlyph.chevronDown, size: 11),
      enabled: enabled,
      onPressed: enabled ? () {} : null,
    );
    if (!enabled) return trigger;
    return BlenderPopover(
      key: const ValueKey<String>('gp-material-selector'),
      child: IgnorePointer(child: trigger),
      popover: (context, close) => _materialPopup(context, close, active),
    );
  }

  Widget _materialPopup(
    BuildContext context,
    VoidCallback close,
    BlenderGreasePencilMaterial? active,
  ) {
    final theme = BlenderTheme.of(context);
    return SizedBox(
      key: const ValueKey<String>('gp-material-popover'),
      width: 420,
      height: 390,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.menuBackground,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x66000000), blurRadius: 12),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colors.canvas,
                          border: Border.all(color: theme.colors.borderSubtle),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(5),
                          itemCount: materials.length,
                          itemBuilder: (context, index) =>
                              _materialRow(context, materials[index], close),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 34,
                      child: Column(
                        children: <Widget>[
                          BlenderIconButton(
                            glyph: BlenderGlyph.chevronDown,
                            onPressed: () {},
                            tooltip: 'Material Specials',
                          ),
                          const SizedBox(height: 10),
                          BlenderIconButton(
                            glyph: BlenderGlyph.chevronUp,
                            onPressed: () {},
                            tooltip: 'Move Material Up',
                          ),
                          BlenderIconButton(
                            glyph: BlenderGlyph.chevronDown,
                            onPressed: () {},
                            tooltip: 'Move Material Down',
                          ),
                          const Spacer(),
                          BlenderIconButton(
                            glyph: BlenderGlyph.eye,
                            onPressed: () {},
                            tooltip: 'Isolate Visibility',
                          ),
                          BlenderIconButton(
                            glyph: BlenderGlyph.lock,
                            onPressed: () {},
                            tooltip: 'Isolate Lock',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text('Stroke Color:', style: theme.textTheme.label),
              const SizedBox(height: 4),
              BlenderColorField(
                color: active?.strokeColor ?? const Color(0xFF111111),
                onPressed: active == null
                    ? null
                    : () => onChanged?.call(active),
              ),
              const SizedBox(height: 8),
              Text('Fill Color:', style: theme.textTheme.label),
              const SizedBox(height: 4),
              BlenderColorField(
                color: active?.fillColor ?? const Color(0xFFB8B8B8),
                onPressed: active == null
                    ? null
                    : () => onChanged?.call(active),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _materialRow(
    BuildContext context,
    BlenderGreasePencilMaterial material,
    VoidCallback close,
  ) {
    final theme = BlenderTheme.of(context);
    final selected = material.id == selectedId;
    return GestureDetector(
      key: ValueKey<String>('gp-material-${material.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onSelected?.call(material);
        close();
      },
      child: Container(
        height: 31,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: selected ? theme.colors.selection : null,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: <Widget>[
            _materialSwatch(material.strokeColor),
            const SizedBox(width: 8),
            Expanded(child: Text(material.label, style: theme.textTheme.body)),
            BlenderIconButton(
              glyph: BlenderGlyph.material,
              selected: selected,
              onPressed: () {},
              tooltip: 'Use Material',
              size: 24,
            ),
            BlenderIconButton(
              glyph: BlenderGlyph.eye,
              selected: material.visible,
              onPressed: () => onChanged?.call(
                material.copyWith(visible: !material.visible),
              ),
              tooltip: 'Show Material',
              size: 24,
            ),
            BlenderIconButton(
              glyph: material.locked ? BlenderGlyph.lock : BlenderGlyph.unlock,
              onPressed: () =>
                  onChanged?.call(material.copyWith(locked: !material.locked)),
              tooltip: 'Lock Material',
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _materialSwatch(Color color) => Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xFF080808), width: 2),
    ),
  );
}
