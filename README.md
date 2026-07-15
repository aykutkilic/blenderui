# blender_ui

`blender_ui` is an unofficial, Blender-inspired UI library for Flutter desktop
applications. It provides dense controls, keyboard and mouse interactions,
resizable regions, and generic editor surfaces without depending on Material or
Cupertino.

<img width="1276" height="800" alt="image" src="https://github.com/user-attachments/assets/5821db20-4a98-48bc-8701-75ab79741f36" />


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
It also includes optional observable state, undo/redo, scoped dependency, and
command services for applications that do not need a larger framework.

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

### Optional application services

The built-in services are scoped rather than global, and controls continue to
accept ordinary values and callbacks.

```dart
final state = BlenderHistoryStore<AppState>(const AppState());
final commands = BlenderCommandRegistry();
final services = BlenderServiceContainer()
  ..registerSingleton<BlenderHistoryStore<AppState>>(state)
  ..registerSingleton<BlenderCommandRegistry>(commands);

commands.register(
  BlenderCommand(
    id: 'save',
    label: 'Save',
    shortcut: 'Ctrl S',
    execute: saveDocument,
  ),
);

BlenderServiceScope(
  services: services,
  child: BlenderStateScope<AppState>(
    store: state,
    child: const Workspace(),
  ),
);
```

Use `BlenderStateScope.watch<T>(context)` to rebuild with state and
`BlenderStateScope.read<T>(context)` in event handlers. See
[`ADR-0005`](doc/decisions/ADR-0005-application-services.md) for ownership and
lifecycle decisions.

### Application framework

For a conventional desktop application, the library can compose the app shell,
top-level menus, dockable panes, scoped state/history, commands, and optional
Preferences window. The application supplies its domain state, area widgets,
menu descriptors, and persistence policy.

```dart
final app = BlenderApplicationController<ProjectState>(
  initialState: const ProjectState(),
  workspace: const BlenderDockAreaNode<String>(
    id: 'main',
    value: 'editor',
  ),
);

BlenderWorkspaceShell<ProjectState>(
  controller: app,
  topBar: BlenderApplicationMenuBar<String>(
    menus: <BlenderApplicationMenu<String>>[
      BlenderApplicationMenu<String>(
        label: 'File',
        items: fileMenuItems,
        onSelected: handleFileCommand,
      ),
    ],
  ),
  areaBuilder: (context, area) => switch (area.value) {
    'editor' => const ProjectEditor(),
    _ => const SizedBox(),
  },
);
```

Use `BlenderPreferencesConfiguration` with
`showBlenderPreferencesWindow(...)` when a menu command opens Preferences.
The framework deliberately does not persist preferences or define a project
model; that data remains application-owned.

## Sample application

The repository includes a small Blender-like desktop workspace with a minimal
orbitable grid/cube viewport. See [`example/README.md`](example/README.md)
or run it from `example/` with:

```sh
flutter run -d macos
```

Try the live [web demo](https://aykutkilic.github.io/flutterui/) in your
browser. It is built from the same `example/` application and deployed from
`main` with GitHub Pages.

The source-driven visual coverage map is maintained in
[`doc/reference/blender-ui-coverage.md`](doc/reference/blender-ui-coverage.md).

The sample also includes Windows and Linux runners.
Open its **Components** workspace for a searchable workbench covering controls,
layouts, data surfaces, editors, and application services.

Launch that workbench directly from `example/` with:

```sh
flutter run -d macos -t lib/components_demo.dart
```

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
assets are MIT licensed. See `doc/reference/blender-ui-reference.md` for the
reference snapshot and provenance notes.
