import 'package:flutter/widgets.dart';

import 'icon_source_platform.dart'
    if (dart.library.io) 'icon_source_platform_io.dart'
    as platform;

/// Resolves optional Blender SVG icons for local desktop development.
///
/// The default resolver looks for a sibling `blender` checkout. The source
/// directory can also be configured explicitly when the application is
/// launched from a different working directory. No Blender files are bundled
/// into the package, and callers can always rely on the built-in icon painter.
class BlenderIconSource {
  const BlenderIconSource._();

  /// The currently configured Blender checkout or icon directory, if found.
  static String? get directory => platform.blenderIconSourceDirectory;

  /// Overrides automatic discovery for the current process.
  ///
  /// Pass the Blender checkout root, its `release/datafiles/icons_svg`
  /// directory, or `null` to return to automatic discovery. A non-existent
  /// directory simply causes the built-in icon painter to be used.
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
