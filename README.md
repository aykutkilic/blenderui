# blender_ui

`blender_ui` is an unofficial, Blender-inspired UI library for Flutter desktop
applications. It provides dense controls, keyboard and mouse interactions,
resizable regions, and generic editor surfaces without depending on Material or
Cupertino.

The package is implemented as ordinary Flutter widgets wherever possible. A
small number of dense surfaces use custom painting and viewport-aware layout so
large outliners, timelines, and node graphs remain responsive.

The public API includes Blender-style control variants, property decorators,
color/curve/property templates, matrices, scopes, attribute and layer
selectors, recent-file and running-job rows,
modifier stacks and grouped node-input panels,
anchored popovers, pulldown and pie menus, dense editor layouts, mutable
corner-split/docking workspaces,
and dedicated non-3D surfaces for files, text, console, image, UV, animation,
nodes, sequencing, clips, spreadsheets, keymaps, reports, and Preferences.

## Status

This repository is the initial `0.1.0` public package foundation. The API is
usable but will continue to evolve before a `1.0.0` release.

## Usage

```dart
import 'package:blender_ui/blender_ui.dart';

BlenderApp(
  home: BlenderTheme(
    child: BlenderPanel(
      title: 'Object',
      child: BlenderButton(
        label: 'Apply',
        onPressed: () {},
      ),
    ),
  ),
);
```

All controls can also be used below an existing `WidgetsApp` by placing a
`BlenderTheme` above them.

## Sample application

The repository includes a small Blender-like desktop workspace with a minimal
orbitable grid/cube viewport. See [`example/README.md`](example/README.md)
or run it from `example/` with:

```sh
flutter run -d macos
```

The source-driven visual coverage map is maintained in
[`docs/reference/blender-ui-coverage.md`](docs/reference/blender-ui-coverage.md).

The sample also includes Windows and Linux runners.

## Local Blender icon development

When running on desktop from this workspace, the library automatically uses
matching SVG icons from `../blender/release/datafiles/icons_svg` when that
checkout is available. It falls back to the package's built-in vector glyphs
when it is not. Set `BLENDER_SOURCE_DIR` or call
`BlenderIconSource.setDirectory(...)` to point at a different local checkout;
the Blender SVGs are never bundled into the package. The example's macOS
debug runner is intentionally unsandboxed so it can read this sibling checkout;
release builds retain the fallback behavior.

## Reference and licensing

This is not an official Blender project and does not embed Blender source
code, icons, fonts, logos, or artwork. Blender is used as a documented visual
and interaction reference only. The package and its independently created
assets are MIT licensed. See `docs/reference/blender-ui-reference.md` for the
reference snapshot and provenance notes.
