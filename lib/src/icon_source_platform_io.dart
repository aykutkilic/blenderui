import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

String? _configuredDirectory;
String? _discoveredDirectory;
final Map<String, String?> _pathCache = <String, String?>{};

String? get blenderIconSourceDirectory {
  if (_configuredDirectory != null) {
    return _normaliseIconDirectory(_configuredDirectory!);
  }

  return _discoveredDirectory ??= _discoverIconDirectory();
}

void setBlenderIconSourceDirectory(String? path) {
  _configuredDirectory = path;
  _discoveredDirectory = null;
  _pathCache.clear();
}

String? blenderIconPath(String fileName) {
  final cached = _pathCache[fileName];
  if (cached != null || _pathCache.containsKey(fileName)) {
    return cached;
  }

  final directory = blenderIconSourceDirectory;
  final path = directory == null
      ? null
      : _existingFilePath(_join(directory, fileName));
  _pathCache[fileName] = path;
  return path;
}

Widget buildBlenderIcon({
  required String path,
  required double size,
  required Color color,
}) {
  return SvgPicture.file(
    File(path),
    width: size,
    height: size,
    fit: BoxFit.contain,
    excludeFromSemantics: true,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );
}

String? _discoverIconDirectory() {
  final candidates = <String>[];
  final configuredRoot = Platform.environment['BLENDER_SOURCE_DIR'];
  if (configuredRoot != null && configuredRoot.isNotEmpty) {
    // An explicit path is also an explicit opt-in. This makes it possible to
    // force the bundled fallback in CI or while comparing icon renderers.
    return _normaliseIconDirectory(configuredRoot);
  }

  _addWorkspaceCandidates(candidates, Directory.current.absolute);
  _addWorkspaceCandidates(
    candidates,
    File(Platform.resolvedExecutable).parent.absolute,
  );

  for (final candidate in candidates) {
    final directory = _normaliseIconDirectory(candidate);
    if (directory != null) {
      return directory;
    }
  }
  return null;
}

void _addWorkspaceCandidates(List<String> candidates, Directory start) {
  var current = start;
  for (var depth = 0; depth < 10; depth++) {
    candidates.add(current.path);
    candidates.add(_join(current.path, 'blender'));
    final parent = current.parent;
    if (parent.path == current.path) break;
    current = parent;
  }
}

String? _normaliseIconDirectory(String root) {
  final absolute = Directory(root).absolute.path;
  final direct = Directory(absolute);
  if (_isIconDirectory(direct)) {
    return direct.path;
  }

  final nested = Directory(
    _join(absolute, 'release', 'datafiles', 'icons_svg'),
  );
  return _isIconDirectory(nested) ? nested.path : null;
}

bool _isIconDirectory(Directory directory) {
  return directory.existsSync() &&
      File(_join(directory.path, 'plus.svg')).existsSync();
}

String? _existingFilePath(String path) {
  final file = File(path);
  return file.existsSync() ? file.path : null;
}

String _join(String first, [String? second, String? third, String? fourth]) {
  final parts = <String>[first];
  if (second != null) parts.add(second);
  if (third != null) parts.add(third);
  if (fourth != null) parts.add(fourth);
  return parts.join(Platform.pathSeparator);
}
