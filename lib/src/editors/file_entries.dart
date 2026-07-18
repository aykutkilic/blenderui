part of '../editors.dart';

class BlenderFileEntry {
  const BlenderFileEntry({
    required this.path,
    required this.name,
    this.isDirectory = false,
    this.detail,
  });

  final String path;
  final String name;
  final bool isDirectory;
  final String? detail;
}
