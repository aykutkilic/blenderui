part of '../editors.dart';

class BlenderFileEntry {
  const BlenderFileEntry({
    required this.path,
    required this.name,
    this.isDirectory = false,
    this.detail,
    this.modified,
    this.modifiedLabel,
    this.sizeBytes,
    this.sizeLabel,
    this.typeLabel,
    this.catalogId,
    this.preview,
    this.asset = false,
  });

  final String path;
  final String name;
  final bool isDirectory;
  final String? detail;
  final DateTime? modified;
  final String? modifiedLabel;
  final int? sizeBytes;
  final String? sizeLabel;
  final String? typeLabel;
  final String? catalogId;
  final Widget? preview;
  final bool asset;
}

enum BlenderFileBrowserMode { files, assets }

enum BlenderFileDisplayMode { listVertical, listHorizontal, thumbnails }

@immutable
class BlenderFileBrowserHeaderState {
  const BlenderFileBrowserHeaderState({
    this.displayMode = BlenderFileDisplayMode.listVertical,
    this.showSourceList = true,
    this.showPath = true,
    this.showHidden = false,
    this.filterEnabled = true,
    this.importMethod = 'Append (Reuse Data)',
  });

  final BlenderFileDisplayMode displayMode;
  final bool showSourceList;
  final bool showPath;
  final bool showHidden;
  final bool filterEnabled;
  final String importMethod;

  BlenderFileBrowserHeaderState copyWith({
    BlenderFileDisplayMode? displayMode,
    bool? showSourceList,
    bool? showPath,
    bool? showHidden,
    bool? filterEnabled,
    String? importMethod,
  }) => BlenderFileBrowserHeaderState(
    displayMode: displayMode ?? this.displayMode,
    showSourceList: showSourceList ?? this.showSourceList,
    showPath: showPath ?? this.showPath,
    showHidden: showHidden ?? this.showHidden,
    filterEnabled: filterEnabled ?? this.filterEnabled,
    importMethod: importMethod ?? this.importMethod,
  );
}

@immutable
class BlenderFileSourceSection {
  const BlenderFileSourceSection({
    required this.id,
    required this.label,
    required this.entries,
    this.initiallyExpanded = true,
    this.allowAdd = false,
  });

  final String id;
  final String label;
  final List<BlenderFileSourceEntry> entries;
  final bool initiallyExpanded;
  final bool allowAdd;
}

@immutable
class BlenderFileSourceEntry {
  const BlenderFileSourceEntry({
    required this.id,
    required this.label,
    this.icon = BlenderGlyph.folder,
  });

  final String id;
  final String label;
  final BlenderGlyph icon;
}

enum BlenderFileBrowserSortColumn { name, modified, size, type }

enum BlenderFileBrowserSortDirection { ascending, descending }

typedef BlenderFileBrowserPreviewBuilder =
    Widget Function(BuildContext context, BlenderFileEntry entry);
