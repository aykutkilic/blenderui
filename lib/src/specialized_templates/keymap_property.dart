part of '../specialized_templates.dart';

/// A single operator-property box used by Blender's keymap-item template.
@immutable
class BlenderKeymapProperty {
  const BlenderKeymapProperty({
    required this.id,
    required this.label,
    required this.editor,
    this.isSet = true,
    this.enabled = true,
    this.onUnset,
  });

  final String id;
  final String label;
  final Widget editor;
  final bool isSet;
  final bool enabled;
  final VoidCallback? onUnset;
}
