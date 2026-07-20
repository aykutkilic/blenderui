part of '../editors.dart';

enum BlenderGreasePencilTool {
  draw,
  erase,
  fill,
  tint,
  box,
  circle,
  line,
  polyline,
  arc,
  curve,
  interpolate,
  eyedropper,
  trim,
}

enum BlenderGreasePencilBrushPreviewKind { stroke, soft, eraser, fill }

@immutable
class BlenderGreasePencilBrush {
  const BlenderGreasePencilBrush({
    required this.id,
    required this.label,
    this.category = 'Draw',
    this.glyph = BlenderGlyph.greasepencil,
    this.color,
    this.preview,
  });

  final String id;
  final String label;
  final String category;
  final BlenderGlyph glyph;
  final Color? color;
  final Widget? preview;
}

@immutable
class BlenderGreasePencilMaterial {
  const BlenderGreasePencilMaterial({
    required this.id,
    required this.label,
    this.strokeColor = const Color(0xFF111111),
    this.fillColor = const Color(0xFFB8B8B8),
    this.visible = true,
    this.locked = false,
  });

  final String id;
  final String label;
  final Color strokeColor;
  final Color fillColor;
  final bool visible;
  final bool locked;

  BlenderGreasePencilMaterial copyWith({
    String? id,
    String? label,
    Color? strokeColor,
    Color? fillColor,
    bool? visible,
    bool? locked,
  }) => BlenderGreasePencilMaterial(
    id: id ?? this.id,
    label: label ?? this.label,
    strokeColor: strokeColor ?? this.strokeColor,
    fillColor: fillColor ?? this.fillColor,
    visible: visible ?? this.visible,
    locked: locked ?? this.locked,
  );
}

@immutable
class BlenderGreasePencilStroke {
  const BlenderGreasePencilStroke({
    required this.points,
    this.color = const Color(0xFF202020),
    this.width = 4,
    this.opacity = 1,
    this.onionSkin = false,
  });

  /// Camera-frame normalized points. Hosts retain ownership of stroke data.
  final List<Offset> points;
  final Color color;
  final double width;
  final double opacity;
  final bool onionSkin;
}

@immutable
class BlenderGreasePencilHeaderState {
  const BlenderGreasePencilHeaderState({
    this.mode = 'Draw Mode',
    this.placement = 'Origin',
    this.viewAxis = 'Front (X-Z)',
    this.strokePlacement = 'Lines',
    this.overlays = true,
    this.gizmos = true,
    this.materialPreview = true,
    this.multiFrame = false,
    this.additiveDrawing = false,
    this.autoMerge = false,
    this.addWeightData = false,
    this.drawOnBack = false,
  });

  final String mode;
  final String placement;
  final String viewAxis;
  final String strokePlacement;
  final bool overlays;
  final bool gizmos;
  final bool materialPreview;
  final bool multiFrame;
  final bool additiveDrawing;
  final bool autoMerge;
  final bool addWeightData;
  final bool drawOnBack;

  BlenderGreasePencilHeaderState copyWith({
    String? mode,
    String? placement,
    String? viewAxis,
    String? strokePlacement,
    bool? overlays,
    bool? gizmos,
    bool? materialPreview,
    bool? multiFrame,
    bool? additiveDrawing,
    bool? autoMerge,
    bool? addWeightData,
    bool? drawOnBack,
  }) => BlenderGreasePencilHeaderState(
    mode: mode ?? this.mode,
    placement: placement ?? this.placement,
    viewAxis: viewAxis ?? this.viewAxis,
    strokePlacement: strokePlacement ?? this.strokePlacement,
    overlays: overlays ?? this.overlays,
    gizmos: gizmos ?? this.gizmos,
    materialPreview: materialPreview ?? this.materialPreview,
    multiFrame: multiFrame ?? this.multiFrame,
    additiveDrawing: additiveDrawing ?? this.additiveDrawing,
    autoMerge: autoMerge ?? this.autoMerge,
    addWeightData: addWeightData ?? this.addWeightData,
    drawOnBack: drawOnBack ?? this.drawOnBack,
  );
}

@immutable
class BlenderGreasePencilToolSettings {
  const BlenderGreasePencilToolSettings({
    this.brushId = 'pencil',
    this.material = 'Solid Stroke',
    this.radius = .02,
    this.strength = .6,
    this.usePressureRadius = true,
    this.usePressureStrength = true,
    this.pinMaterial = false,
  });

  final String brushId;
  final String material;
  final double radius;
  final double strength;
  final bool usePressureRadius;
  final bool usePressureStrength;
  final bool pinMaterial;

  BlenderGreasePencilToolSettings copyWith({
    String? brushId,
    String? material,
    double? radius,
    double? strength,
    bool? usePressureRadius,
    bool? usePressureStrength,
    bool? pinMaterial,
  }) => BlenderGreasePencilToolSettings(
    brushId: brushId ?? this.brushId,
    material: material ?? this.material,
    radius: radius ?? this.radius,
    strength: strength ?? this.strength,
    usePressureRadius: usePressureRadius ?? this.usePressureRadius,
    usePressureStrength: usePressureStrength ?? this.usePressureStrength,
    pinMaterial: pinMaterial ?? this.pinMaterial,
  );
}
