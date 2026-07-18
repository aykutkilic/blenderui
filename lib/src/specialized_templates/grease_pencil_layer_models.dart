part of '../specialized_templates.dart';

/// A nested Grease Pencil layer/group descriptor.
@immutable
class BlenderGreasePencilLayer {
  const BlenderGreasePencilLayer({
    required this.id,
    required this.name,
    this.children = const <BlenderGreasePencilLayer>[],
    this.isGroup = false,
    this.active = false,
    this.initiallyExpanded = true,
    this.useMasks = false,
    this.useOnionSkinning = false,
    this.hidden = false,
    this.locked = false,
    this.enabled = true,
    this.onActivate,
    this.onMasksChanged,
    this.onOnionSkinningChanged,
    this.onHiddenChanged,
    this.onLockedChanged,
  });

  final String id;
  final String name;
  final List<BlenderGreasePencilLayer> children;
  final bool isGroup;
  final bool active;
  final bool initiallyExpanded;
  final bool useMasks;
  final bool useOnionSkinning;
  final bool hidden;
  final bool locked;
  final bool enabled;
  final VoidCallback? onActivate;
  final ValueChanged<bool>? onMasksChanged;
  final ValueChanged<bool>? onOnionSkinningChanged;
  final ValueChanged<bool>? onHiddenChanged;
  final ValueChanged<bool>? onLockedChanged;
}

class BlenderGreasePencilLayerTree extends StatefulWidget {
  const BlenderGreasePencilLayerTree({
    super.key,
    required this.layers,
    this.searchController,
    this.title = 'Grease Pencil Layers',
    this.emptyLabel = 'No layers',
  });

  final List<BlenderGreasePencilLayer> layers;
  final TextEditingController? searchController;
  final String title;
  final String emptyLabel;

  @override
  State<BlenderGreasePencilLayerTree> createState() =>
      _BlenderGreasePencilLayerTreeState();
}
