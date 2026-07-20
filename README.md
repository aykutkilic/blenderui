# blender_ui

`blender_ui` is an unofficial, Blender-inspired UI library for Flutter desktop
applications. It provides dense controls, keyboard and mouse interactions,
resizable regions, and generic editor surfaces without depending on Material or
Cupertino.

<img width="1276" height="800" alt="image" src="https://github.com/user-attachments/assets/5821db20-4a98-48bc-8701-75ab79741f36" />


The package is implemented as ordinary Flutter widgets wherever possible. A
small number of dense surfaces use custom painting and viewport-aware layout so
large outliners, timelines, and node graphs remain responsive.

Grease Pencil applications can compose Blender's regions without adopting an
example-specific document model:

```dart
Column(
  children: [
    BlenderGreasePencilEditorHeader(state: headerState),
    BlenderGreasePencilToolHeader(brushes: brushes, state: toolState),
    Expanded(
      child: BlenderGreasePencilViewport(
        strokes: strokes,
        toolShelf: BlenderGreasePencilToolShelf(
          selectedTool: activeTool,
          onChanged: selectTool,
        ),
        assetShelf: BlenderGreasePencilBrushAssetShelf(brushes: brushes),
      ),
    ),
  ],
)
```

The host owns strokes, brushes, scenes, strips, undo, and persistence. BlenderUI
owns the reusable region anatomy, controls, interaction intents, and rendering.

For repository ownership, dependency direction, extension rules, and a guided
source map, start with the [architecture guide](doc/architecture.md).
The active screenshot/source comparison is tracked in the
[manual UI and editor parity backlog](doc/manual-ui-editor-parity-backlog.md).

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
All 23 editor types in the current Blender manual have a committed 1200×700
region/density reference under `test/goldens`; Blender runtime data,
evaluation, operators, and persistence intentionally remain host-owned.

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

### Animation playback state

`BlenderPlaybackController` keeps frequently changing frame and transport
state out of application-wide rebuilds. The host still owns animation
evaluation and scheduling.

```dart
final playback = BlenderPlaybackController(
  initialFrame: 24,
  rangeStart: 1,
  rangeEnd: 120,
);

BlenderTimeline(
  model: timelineModel,
  currentFrameListenable: playback,
  onCurrentFrameChanged: playback.seek,
);
```

Use `BlenderPlaybackBuilder` around headers or other small surfaces that read
`playing`, `recording`, the active range, or the current frame. Dispose the
controller with its owning application or document session.

### Node editor

The node canvas is tree-agnostic. Applications own the graph document and
commands; BlenderUI owns typed sockets, resolved links, node presentation,
click/box-selection gestures, and grouped movement transactions.

```dart
var graph = BlenderNodeGraphModel(
  nodes: const <BlenderGraphNode>[
    BlenderGraphNode(
      id: 'input',
      title: 'Group Input',
      position: Offset(40, 80),
      outputs: <BlenderNodeSocketDefinition>[
        BlenderNodeSocketDefinition(
          id: 'geometry',
          label: 'Geometry',
          dataType: BlenderNodeSocketDataType.geometry,
        ),
      ],
    ),
    BlenderGraphNode(
      id: 'output',
      title: 'Group Output',
      position: Offset(360, 80),
      inputs: <BlenderNodeSocketDefinition>[
        BlenderNodeSocketDefinition(
          id: 'geometry',
          label: 'Geometry',
          dataType: BlenderNodeSocketDataType.geometry,
        ),
      ],
    ),
  ],
  links: const <BlenderGraphLink>[
    BlenderGraphLink(
      from: 'input',
      fromSocket: 'geometry',
      to: 'output',
      toSocket: 'geometry',
    ),
  ],
);

BlenderNodeEditor(
  model: graph,
  onNodeMoved: (node, position) {
    graph = graph.moveNode(node.id, position);
  },
);
```

See the detailed example and source-audit notes in
[`geometry-node-editor-parity.md`](doc/geometry-node-editor-parity.md).

### Application framework

For a conventional desktop application, the library can compose the app shell,
top-level menus, dockable panes, scoped state/history, commands, and optional
Preferences window. The application supplies its domain state, area widgets,
menu descriptors, and persistence policy.

`BlenderApplicationController` also scopes reusable status, presentation,
keyboard-command-binding, and editor-session services. Use
`BlenderApplicationStatusBar` when the shell should render the current
`BlenderStatusService` message, and configure `BlenderEditorSessionPersistence`
with application-owned storage to retain editor area views, Outliner selection,
and Properties targets. The library stores only stable IDs; resolving them back
to project objects remains the application's responsibility. Editor widgets can
subscribe through `BlenderEditorSessionScope.watch(context)` or update it from
handlers with `BlenderEditorSessionScope.read(context)`.

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

For a reusable application command, create a `BlenderPreferencesService` from
that configuration and call `show(context)`. Its presentation is deliberately
deferred past menu-popover cleanup, so selecting Edit > Preferences cannot
immediately dismiss the new window.

`BlenderApplicationTopBar` owns the standard Blender order: fixed menu
dropdowns, a separator, a scrollable/fading workspace strip, and fixed global
actions on the right. Applications supply descriptors and callbacks rather
than rebuilding title-bar layout:

```dart
BlenderApplicationTopBar<String, String>(
  menus: fileEditWindowHelpMenus,
  workspaces: workspaceDescriptors,
  activeWorkspace: activeWorkspaceId,
  onWorkspaceSelected: selectWorkspace,
  workspaceActions: [addWorkspaceMenu],
  trailing: [aiActionGroup],
);
```

### Context menus

Use `BlenderContextMenu<T>` for a custom command family, or start from
`BlenderContextMenuCatalog` for Blender-shaped Object, Outliner, Node, File
Browser, Property, Tool, and Area menus. Catalogs describe presentation and
stable action IDs; the application executes the selected command.

Target-aware surfaces such as `BlenderOutliner`, `BlenderFileBrowser`,
`BlenderNodeEditor`, `BlenderPropertiesEditor`, and `BlenderToolShelf` accept
context-menu builders. Their callbacks include the exact entity under the
pointer, and selectable targets become active before their menu opens. See
[the source and ownership analysis](doc/context-menu-parity.md).

### Multiple dockable workspaces

Use `BlenderWorkspaceService` when an application has Blender-style
perspectives: each named workspace receives its own retained docking layout.
The application owns the labels, switcher, and editor widgets; BlenderUI owns
the live layout service and host.

```dart
final workspaces = BlenderWorkspaceService<String>(
  workspaces: const <BlenderWorkspaceDefinition<String>>[
    BlenderWorkspaceDefinition(
      id: 'folders',
      layout: BlenderDockAreaNode(id: 'outliner', value: 'folder-outliner'),
    ),
    BlenderWorkspaceDefinition(
      id: 'authoring',
      layout: BlenderDockAreaNode(id: 'page', value: 'page-editor'),
    ),
  ],
);

// The workspace switcher calls `workspaces.selectWorkspace('authoring')`.
final app = BlenderApplicationController<ProjectState>(
  initialState: const ProjectState(),
  workspaceService: workspaces,
);

BlenderWorkspaceHost<String>(
  service: app.workspaces,
  areaBuilder: (context, area) => buildEditor(area.value),
);
```

### Retained workspace screens

Use `BlenderWorkspaceScreenHost` for the top-level workspace tabs themselves.
It lazily mounts each screen on its first visit and offstages it when inactive,
so switching tabs does not recreate the screen's local state.

```dart
BlenderWorkspaceScreenHost<String>(
  activeWorkspaceId: activeWorkspaceId,
  screens: [
    BlenderWorkspaceScreen(id: 'folders', builder: (_) => FoldersScreen()),
    BlenderWorkspaceScreen(id: 'dictionaries', builder: (_) => DictionariesScreen()),
  ],
);
```

This is in-process retention; combine it with the durable session service
below for relaunch restoration.

### Durable workspace sessions

Give the service a `BlenderWorkspacePersistence` to retain the active
perspective, editor choices, split tree, and divider fractions across launches.
The library exposes a small storage interface instead of depending on a
specific settings package; adapt the storage already used by the host app.

```dart
final workspaces = BlenderWorkspaceService<EditorKind>(
  workspaces: workspaceDefinitions,
  persistence: BlenderWorkspacePersistence<EditorKind>(
    storage: appSettingsStorage,
    storageKey: 'com.example.authoring.workspace-session',
    valueCodec: BlenderWorkspaceValueCodec<EditorKind>(
      toJson: (view) => view.name,
      fromJson: (value) => EditorKind.values.byName(value as String),
    ),
  ),
);
```

`BlenderWorkspaceShell` restores a configured session after first paint and
flushes it when the app is backgrounded or the shell is disposed. Use
`await workspaces.flush()` before a host-controlled shutdown, and
`clearPersistedSession()` for a Reset Workspace Layout command.

To persist application context within one perspective, attach a typed
`BlenderWorkspaceState` to its definition. For example, an Outliner can store
its selected folder ID without making that domain model part of BlenderUI:

```dart
final selectedFolder = BlenderWorkspaceState<String?>(
  value: null,
  codec: BlenderWorkspaceValueCodec<String?>(
    toJson: (id) => id,
    fromJson: (value) => value as String?,
  ),
);

final folders = BlenderWorkspaceDefinition<EditorKind>(
  id: 'folders',
  layout: foldersLayout,
  sessionState: selectedFolder,
);
```

Changing `selectedFolder.value` is observed and saved with the dock session;
the application resolves the restored ID through its own data store.

See [`ADR-0007`](doc/decisions/ADR-0007-workspace-layout-service.md) and
[`ADR-0008`](doc/decisions/ADR-0008-retained-workspace-screens.md) for the
workspace ownership and retention policies.

## Sample application

The repository includes a small Blender-like desktop workspace with a minimal
orbitable grid/cube viewport. See [`example/README.md`](example/README.md)
or run it from `example/` with:

```sh
flutter run -d macos
```

Try the live [web demo](https://aykutkilic.github.io/blenderui/) in your
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

## Icon rendering

BlenderUI maps its semantic `BlenderGlyph` catalog to the outlined Material
Symbols font by default. The compact default uses variable weight, grade, fill,
and optical-size axes through `BlenderIconThemeData`; applications can opt into
the original independently drawn vector renderer with
`BlenderIconRenderer.blenderVector` for compatibility. The package does not
locate, load, bundle, or expose Blender source icon assets.

## Reference and licensing

This is not an official Blender project and does not embed Blender source
code, icons, fonts, logos, or artwork. Blender is used as a documented visual
and interaction reference only. The package and its independently created
assets are MIT licensed. See `doc/reference/blender-ui-reference.md` for the
reference snapshot and provenance notes.
