part of '../specialized_templates.dart';

/// A user-preference asset-library descriptor.
@immutable
class BlenderAssetLibraryPreference {
  const BlenderAssetLibraryPreference({
    required this.id,
    required this.name,
    this.path = '',
    this.remoteUrl = '',
    this.isRemote = false,
    this.isEssentials = false,
    this.builtIn = false,
    this.enabled = true,
    this.invalid = false,
    this.importMethod = 'Link',
    this.useRelativePath = false,
    this.includeOnlineEssentials = false,
    this.onlineEssentialsEnabled = true,
  });

  final String id;
  final String name;
  final String path;
  final String remoteUrl;
  final bool isRemote;
  final bool isEssentials;
  final bool builtIn;
  final bool enabled;
  final bool invalid;
  final String importMethod;
  final bool useRelativePath;
  final bool includeOnlineEssentials;
  final bool onlineEssentialsEnabled;
}

/// Blender Preferences' Asset Libraries panel.
class BlenderAssetLibrariesPreferencesPanel extends StatefulWidget {
  const BlenderAssetLibrariesPreferencesPanel({
    super.key,
    required this.libraries,
    this.selectedId,
    this.onSelected,
    this.onEnabledChanged,
    this.onPathChanged,
    this.onImportMethodChanged,
    this.onRelativePathChanged,
    this.onIncludeOnlineEssentialsChanged,
    this.onAdd,
    this.onRemove,
    this.libraryListHeight = 140,
    this.title = 'Asset Libraries',
  });

  final List<BlenderAssetLibraryPreference> libraries;
  final String? selectedId;
  final ValueChanged<BlenderAssetLibraryPreference>? onSelected;
  final void Function(BlenderAssetLibraryPreference, bool)? onEnabledChanged;
  final void Function(BlenderAssetLibraryPreference, String)? onPathChanged;
  final void Function(BlenderAssetLibraryPreference, String)?
  onImportMethodChanged;
  final void Function(BlenderAssetLibraryPreference, bool)?
  onRelativePathChanged;
  final ValueChanged<bool>? onIncludeOnlineEssentialsChanged;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final double libraryListHeight;
  final String title;

  @override
  State<BlenderAssetLibrariesPreferencesPanel> createState() =>
      _BlenderAssetLibrariesPreferencesPanelState();
}
