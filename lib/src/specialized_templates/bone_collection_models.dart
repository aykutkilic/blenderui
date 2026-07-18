part of '../specialized_templates.dart';

/// A nested armature bone-collection descriptor.
@immutable
class BlenderBoneCollection {
  const BlenderBoneCollection({
    required this.id,
    required this.name,
    this.children = const <BlenderBoneCollection>[],
    this.active = false,
    this.hasSelectedBones = false,
    this.visible = true,
    this.solo = false,
    this.initiallyExpanded = true,
    this.enabled = true,
    this.onActivate,
    this.onVisibilityChanged,
    this.onSoloChanged,
    this.onRemove,
  });

  final String id;
  final String name;
  final List<BlenderBoneCollection> children;
  final bool active;
  final bool hasSelectedBones;
  final bool visible;
  final bool solo;
  final bool initiallyExpanded;
  final bool enabled;
  final VoidCallback? onActivate;
  final ValueChanged<bool>? onVisibilityChanged;
  final ValueChanged<bool>? onSoloChanged;
  final VoidCallback? onRemove;
}

/// Blender's nested bone-collection tree with active/used, visibility, and
/// solo columns.
class BlenderBoneCollectionTree extends StatefulWidget {
  const BlenderBoneCollectionTree({
    super.key,
    required this.collections,
    this.title = 'Bone Collections',
    this.emptyLabel = 'No bone collections',
    this.showPanel = true,
  });

  final List<BlenderBoneCollection> collections;
  final String title;
  final String emptyLabel;
  final bool showPanel;

  @override
  State<BlenderBoneCollectionTree> createState() =>
      _BlenderBoneCollectionTreeState();
}
