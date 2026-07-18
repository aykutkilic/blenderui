part of '../specialized_templates.dart';

/// A caller-owned constraint panel descriptor.
@immutable
class BlenderConstraintDescriptor {
  const BlenderConstraintDescriptor({
    required this.id,
    required this.name,
    required this.child,
    this.icon = BlenderGlyph.link,
    this.enabled = true,
    this.initiallyExpanded = true,
    this.onToggleEnabled,
    this.onMoveUp,
    this.onMoveDown,
    this.onRemove,
    this.onMenu,
  });

  final String id;
  final String name;
  final Widget child;
  final BlenderGlyph icon;
  final bool enabled;
  final bool initiallyExpanded;
  final VoidCallback? onToggleEnabled;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onRemove;
  final VoidCallback? onMenu;
}
