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
}

enum BlenderFileBrowserSortColumn { name, modified, size, type }

enum BlenderFileBrowserSortDirection { ascending, descending }

typedef BlenderFileBrowserPreviewBuilder =
    Widget Function(BuildContext context, BlenderFileEntry entry);
