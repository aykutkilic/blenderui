import 'package:flutter/widgets.dart';

import 'icon_source_platform.dart'
    if (dart.library.io) 'icon_source_platform_io.dart'
    as platform;

/// Resolves optional Blender SVG icons for local desktop development.
///
/// Source SVG rendering is opt-in through [setDirectory] or
/// `BLENDER_SOURCE_DIR`. This keeps package consumers and deterministic tests
/// on the built-in icon painter; some source SVG constructs are intentionally
/// outside Flutter SVG's supported subset. No Blender files are bundled into
/// the package.
class BlenderIconSource {
  const BlenderIconSource._();

  /// The currently configured Blender checkout or icon directory, if found.
  static String? get directory => platform.blenderIconSourceDirectory;

  /// Overrides automatic discovery for the current process.
  ///
  /// Pass the Blender checkout root or its `release/datafiles/icons_svg`
  /// directory. Pass `null` to use the built-in icon painter unless
  /// `BLENDER_SOURCE_DIR` is set. A non-existent directory also uses the
  /// built-in painter.
  static void setDirectory(String? path) {
    platform.setBlenderIconSourceDirectory(path);
  }

  /// Returns the source SVG path when that icon is available locally.
  static String? pathFor(String fileName) {
    return platform.blenderIconPath(fileName);
  }

  /// Builds a source SVG widget on platforms that can read local files.
  static Widget? buildIcon({
    required String path,
    required double size,
    required Color color,
  }) {
    return platform.buildBlenderIcon(path: path, size: size, color: color);
  }
}
