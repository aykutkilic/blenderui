part of '../advanced_controls.dart';

class BlenderPropertyTab {
  const BlenderPropertyTab({
    required this.id,
    required this.label,
    required this.glyph,
    this.group = 0,
  });

  final String id;
  final String label;
  final BlenderGlyph glyph;

  /// Consecutive groups are separated by Blender-style breathing room.
  final int group;
}

Color _propertyTabIconColor(BlenderColorScheme colors, BlenderGlyph glyph) {
  switch (glyph) {
    case BlenderGlyph.tool:
    case BlenderGlyph.modifier:
      return colors.iconModifier;
    case BlenderGlyph.object:
      return colors.iconObject;
    case BlenderGlyph.material:
      return colors.iconShading;
    case BlenderGlyph.render:
    case BlenderGlyph.output:
    case BlenderGlyph.scene:
    case BlenderGlyph.world:
      return colors.iconScene;
    default:
      return colors.foregroundMuted;
  }
}
