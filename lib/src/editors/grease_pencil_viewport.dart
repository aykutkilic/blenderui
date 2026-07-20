part of '../editors.dart';

/// Grease Pencil Draw-mode tool taxonomy from `space_toolsystem_toolbar.py`.
class BlenderGreasePencilToolShelf extends StatelessWidget {
  const BlenderGreasePencilToolShelf({
    super.key,
    required this.selectedTool,
    required this.onChanged,
    this.onOptionSelected,
    this.floating = true,
  });

  final BlenderGreasePencilTool selectedTool;
  final ValueChanged<BlenderGreasePencilTool> onChanged;
  final ValueChanged<BlenderToolOption>? onOptionSelected;
  final bool floating;

  static const List<BlenderToolDefinition> tools = <BlenderToolDefinition>[
    BlenderToolDefinition(glyph: BlenderGlyph.greasepencil, tooltip: 'Draw'),
    BlenderToolDefinition(glyph: BlenderGlyph.deleteIcon, tooltip: 'Erase'),
    BlenderToolDefinition(glyph: BlenderGlyph.color, tooltip: 'Fill'),
    BlenderToolDefinition(glyph: BlenderGlyph.eyedropper, tooltip: 'Tint'),
    BlenderToolDefinition(
      glyph: BlenderGlyph.plus,
      tooltip: 'Primitives',
      groupBreakBefore: true,
      options: <BlenderToolOption>[
        BlenderToolOption(label: 'Box', glyph: BlenderGlyph.selectBox),
        BlenderToolOption(label: 'Circle', glyph: BlenderGlyph.radio),
        BlenderToolOption(label: 'Line', glyph: BlenderGlyph.curve),
        BlenderToolOption(label: 'Polyline', glyph: BlenderGlyph.curve),
        BlenderToolOption(label: 'Arc', glyph: BlenderGlyph.curve),
        BlenderToolOption(label: 'Curve', glyph: BlenderGlyph.curve),
      ],
    ),
    BlenderToolDefinition(
      glyph: BlenderGlyph.action,
      tooltip: 'Interpolate',
      groupBreakBefore: true,
    ),
    BlenderToolDefinition(
      glyph: BlenderGlyph.eyedropper,
      tooltip: 'Eyedropper',
    ),
    BlenderToolDefinition(glyph: BlenderGlyph.deleteIcon, tooltip: 'Trim'),
  ];

  static const List<BlenderGreasePencilTool> _toolValues =
      <BlenderGreasePencilTool>[
        BlenderGreasePencilTool.draw,
        BlenderGreasePencilTool.erase,
        BlenderGreasePencilTool.fill,
        BlenderGreasePencilTool.tint,
        BlenderGreasePencilTool.box,
        BlenderGreasePencilTool.interpolate,
        BlenderGreasePencilTool.eyedropper,
        BlenderGreasePencilTool.trim,
      ];

  int get _selectedIndex => switch (selectedTool) {
    BlenderGreasePencilTool.box ||
    BlenderGreasePencilTool.circle ||
    BlenderGreasePencilTool.line ||
    BlenderGreasePencilTool.polyline ||
    BlenderGreasePencilTool.arc ||
    BlenderGreasePencilTool.curve => 4,
    _ => math.max(0, _toolValues.indexOf(selectedTool)),
  };

  BlenderGreasePencilTool _primitiveFor(String label) => switch (label) {
    'Circle' => BlenderGreasePencilTool.circle,
    'Line' => BlenderGreasePencilTool.line,
    'Polyline' => BlenderGreasePencilTool.polyline,
    'Arc' => BlenderGreasePencilTool.arc,
    'Curve' => BlenderGreasePencilTool.curve,
    _ => BlenderGreasePencilTool.box,
  };

  @override
  Widget build(BuildContext context) => BlenderToolShelf(
    tools: tools,
    selectedIndex: _selectedIndex,
    onChanged: (index) => onChanged(_toolValues[index]),
    onOptionSelected: (option) {
      if (_selectedIndex == 4) onChanged(_primitiveFor(option.label));
      onOptionSelected?.call(option);
    },
    width: 56,
    buttonExtent: 42,
    iconSize: 28,
    floating: floating,
  );
}

/// Compact horizontal Brush Asset Shelf used by Grease Pencil startup files.
class BlenderGreasePencilBrushAssetShelf extends StatefulWidget {
  const BlenderGreasePencilBrushAssetShelf({
    super.key,
    required this.brushes,
    this.selectedId,
    this.onSelected,
    this.initialCategory = 'All',
    this.libraryLabel = 'All Libraries',
    this.onRefresh,
  });

  final List<BlenderGreasePencilBrush> brushes;
  final String? selectedId;
  final ValueChanged<BlenderGreasePencilBrush>? onSelected;
  final String initialCategory;
  final String libraryLabel;
  final VoidCallback? onRefresh;

  @override
  State<BlenderGreasePencilBrushAssetShelf> createState() =>
      _BlenderGreasePencilBrushAssetShelfState();
}

class _BlenderGreasePencilBrushAssetShelfState
    extends State<BlenderGreasePencilBrushAssetShelf> {
  late String _category = widget.initialCategory;
  late final Set<String> _enabledCategories = <String>{
    for (final brush in widget.brushes) brush.category,
  };
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final categories = <String>{
      'All',
      for (final brush in widget.brushes)
        if (_enabledCategories.contains(brush.category)) brush.category,
    };
    final visible = widget.brushes.where(
      (brush) =>
          (_category == 'All' || brush.category == _category) &&
          brush.label.toLowerCase().contains(_query.toLowerCase()),
    );
    return SizedBox(
      key: const ValueKey<String>('gp-brush-asset-shelf'),
      height: 108,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.canvas,
          border: Border(top: BorderSide(color: theme.colors.border)),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 30,
              child: Row(
                children: <Widget>[
                  BlenderAssetShelfCatalogSelector(
                    catalogs: <BlenderAssetCatalog>[
                      BlenderAssetCatalog(
                        id: 'brushes',
                        label: 'Brushes',
                        children: <BlenderAssetCatalog>[
                          BlenderAssetCatalog(
                            id: 'grease-pencil-draw',
                            label: 'Grease Pencil Draw',
                            children: <BlenderAssetCatalog>[
                              for (final category in <String>{
                                for (final brush in widget.brushes)
                                  brush.category,
                              })
                                BlenderAssetCatalog(
                                  id: category.toLowerCase(),
                                  label: category,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                    enabledIds: <String>{
                      'brushes',
                      'grease-pencil-draw',
                      for (final category in _enabledCategories)
                        category.toLowerCase(),
                    },
                    libraryLabel: widget.libraryLabel,
                    onRefresh: widget.onRefresh,
                    onEnabledChanged: (id, enabled) {
                      final category = widget.brushes
                          .map((brush) => brush.category)
                          .where((value) => value.toLowerCase() == id)
                          .firstOrNull;
                      if (category == null) return;
                      setState(() {
                        if (enabled) {
                          _enabledCategories.add(category);
                        } else {
                          _enabledCategories.remove(category);
                          if (_category == category) _category = 'All';
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                  for (final category in categories)
                    BlenderButton(
                      label: category,
                      selected: category == _category,
                      variant: BlenderButtonVariant.tab,
                      onPressed: () => setState(() => _category = category),
                    ),
                  const Spacer(),
                  BlenderIconButton(
                    glyph: BlenderGlyph.assetManager,
                    onPressed: () {},
                    tooltip: 'Display Settings',
                    size: 28,
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 210,
                    child: BlenderSearchField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(4, 2, 4, 4),
                children: <Widget>[
                  for (final brush in visible) _brushTile(context, brush),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _brushTile(BuildContext context, BlenderGreasePencilBrush brush) {
    final theme = BlenderTheme.of(context);
    final selected = brush.id == widget.selectedId;
    return GestureDetector(
      key: ValueKey<String>('gp-brush-${brush.id}'),
      onTap: widget.onSelected == null ? null : () => widget.onSelected!(brush),
      child: Container(
        width: 78,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: selected ? theme.colors.selection : theme.colors.surface,
          border: Border.all(
            color: selected ? theme.colors.focus : theme.colors.borderSubtle,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child:
                  brush.preview ??
                  ColoredBox(
                    color: brush.color ?? theme.colors.surfaceRaised,
                    child: Center(child: BlenderIcon(brush.glyph, size: 28)),
                  ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              child: Text(
                brush.label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lightweight brush thumbnail fallback for hosts without packaged previews.
class BlenderGreasePencilBrushPreview extends StatelessWidget {
  const BlenderGreasePencilBrushPreview({
    super.key,
    this.kind = BlenderGreasePencilBrushPreviewKind.stroke,
    this.color = const Color(0xFF101010),
    this.accentColor = const Color(0xFFFF7655),
    this.seed = 0,
  });

  final BlenderGreasePencilBrushPreviewKind kind;
  final Color color;
  final Color accentColor;
  final int seed;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _BlenderGreasePencilBrushPreviewPainter(
      kind: kind,
      color: color,
      accentColor: accentColor,
      seed: seed,
    ),
    child: const SizedBox.expand(),
  );
}

class _BlenderGreasePencilBrushPreviewPainter extends CustomPainter {
  const _BlenderGreasePencilBrushPreviewPainter({
    required this.kind,
    required this.color,
    required this.accentColor,
    required this.seed,
  });

  final BlenderGreasePencilBrushPreviewKind kind;
  final Color color;
  final Color accentColor;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFB8B8B8),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (kind == BlenderGreasePencilBrushPreviewKind.fill) {
      final path = Path()
        ..moveTo(size.width * .25, size.height * .2)
        ..lineTo(size.width * .75, size.height * .2)
        ..lineTo(size.width * .68, size.height * .65)
        ..quadraticBezierTo(
          size.width * .55,
          size.height * .88,
          size.width * .42,
          size.height * .65,
        )
        ..close();
      canvas.drawPath(path, Paint()..color = color);
      return;
    }
    final passes = kind == BlenderGreasePencilBrushPreviewKind.soft ? 7 : 3;
    for (var index = 0; index < passes; index++) {
      final phase = ((seed + index) % 5) * .035;
      final path = Path()
        ..moveTo(size.width * (.13 + phase), size.height * (.68 - index * .035))
        ..cubicTo(
          size.width * .30,
          size.height * (.12 + phase),
          size.width * .48,
          size.height * (.92 - phase),
          size.width * .83,
          size.height * (.28 + index * .025),
        );
      paint
        ..strokeWidth = kind == BlenderGreasePencilBrushPreviewKind.soft
            ? size.shortestSide * .13
            : size.shortestSide * (.045 + index * .012)
        ..color = kind == BlenderGreasePencilBrushPreviewKind.soft
            ? color.withValues(alpha: .14)
            : color;
      canvas.drawPath(path, paint);
    }
    if (kind == BlenderGreasePencilBrushPreviewKind.eraser) {
      canvas.drawLine(
        Offset(size.width * .18, size.height * .22),
        Offset(size.width * .82, size.height * .78),
        Paint()
          ..color = accentColor
          ..strokeWidth = size.shortestSide * .045,
      );
    }
  }

  @override
  bool shouldRepaint(_BlenderGreasePencilBrushPreviewPainter oldDelegate) =>
      kind != oldDelegate.kind ||
      color != oldDelegate.color ||
      accentColor != oldDelegate.accentColor ||
      seed != oldDelegate.seed;
}

/// Reusable camera-canvas region for 2D Animation and Storyboarding templates.
class BlenderGreasePencilViewport extends StatelessWidget {
  const BlenderGreasePencilViewport({
    super.key,
    this.strokes = const <BlenderGreasePencilStroke>[],
    this.cameraAspectRatio = 16 / 9,
    this.cameraView = true,
    this.objectName = 'Stroke',
    this.layerName = 'Lines',
    this.toolShelf,
    this.assetShelf,
    this.onCommand,
  });

  final List<BlenderGreasePencilStroke> strokes;
  final double cameraAspectRatio;
  final bool cameraView;
  final String objectName;
  final String layerName;
  final Widget? toolShelf;
  final Widget? assetShelf;
  final ValueChanged<String>? onCommand;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Column(
      children: <Widget>[
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CustomPaint(
                key: const ValueKey<String>('gp-camera-canvas'),
                painter: _BlenderGreasePencilCanvasPainter(
                  colors: theme.colors,
                  strokes: strokes,
                  aspectRatio: cameraAspectRatio,
                  cameraView: cameraView,
                ),
              ),
              Positioned(
                left: 82,
                top: 12,
                child: Text(
                  'Camera Perspective\n(1) $objectName | $layerName',
                  style: theme.textTheme.body.copyWith(
                    color: theme.colors.foreground,
                  ),
                ),
              ),
              if (toolShelf != null)
                Positioned(left: 10, top: 12, bottom: 10, child: toolShelf!),
              const Positioned(
                right: 12,
                top: 12,
                child: BlenderViewportOrientationGizmo(yaw: 0, pitch: 0),
              ),
              Positioned(
                right: 12,
                top: 118,
                child: BlenderViewportNavigationControls(
                  onZoom: () => onCommand?.call('Zoom'),
                  onPan: () => onCommand?.call('Pan'),
                  onCamera: () => onCommand?.call('Camera View'),
                  onPerspective: () => onCommand?.call('Perspective'),
                ),
              ),
            ],
          ),
        ),
        if (assetShelf != null) assetShelf!,
      ],
    );
  }
}

class _BlenderGreasePencilCanvasPainter extends CustomPainter {
  const _BlenderGreasePencilCanvasPainter({
    required this.colors,
    required this.strokes,
    required this.aspectRatio,
    required this.cameraView,
  });

  final BlenderColorScheme colors;
  final List<BlenderGreasePencilStroke> strokes;
  final double aspectRatio;
  final bool cameraView;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = colors.surfaceElevated,
    );
    final margin = math.min(size.width, size.height) * .09;
    var camera = Rect.fromLTWH(
      margin,
      margin,
      size.width - margin * 2,
      size.height - margin * 2,
    );
    if (cameraView) {
      if (camera.width / camera.height > aspectRatio) {
        final width = camera.height * aspectRatio;
        camera = Rect.fromCenter(
          center: camera.center,
          width: width,
          height: camera.height,
        );
      } else {
        final height = camera.width / aspectRatio;
        camera = Rect.fromCenter(
          center: camera.center,
          width: camera.width,
          height: height,
        );
      }
    }
    canvas.drawRect(camera, Paint()..color = const Color(0xFFF4F4F4));
    canvas.drawRect(
      camera,
      Paint()
        ..color = colors.foregroundDisabled
        ..style = PaintingStyle.stroke,
    );
    canvas.save();
    canvas.clipRect(camera);
    for (final stroke in strokes) {
      if (stroke.points.length < 2) continue;
      final path = Path();
      for (var index = 0; index < stroke.points.length; index++) {
        final point = Offset(
          camera.left + stroke.points[index].dx * camera.width,
          camera.top + stroke.points[index].dy * camera.height,
        );
        if (index == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = stroke.color.withValues(
            alpha: stroke.onionSkin ? stroke.opacity * .3 : stroke.opacity,
          )
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = stroke.width,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BlenderGreasePencilCanvasPainter oldDelegate) =>
      colors != oldDelegate.colors ||
      strokes != oldDelegate.strokes ||
      aspectRatio != oldDelegate.aspectRatio ||
      cameraView != oldDelegate.cameraView;
}
