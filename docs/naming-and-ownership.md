# Naming and ownership map

BlenderUI uses similar terms for related layers. This map distinguishes them
without forcing callers to infer ownership from file location or implementation
details.

## Suffix rules

| Suffix | Meaning |
| --- | --- |
| `Definition` | Immutable declaration supplied by an application. |
| `Data` | Immutable runtime values without persistence or lifecycle. |
| `State` | Observable or serializable values for one bounded surface. |
| `Controller` | Imperative interaction API with a caller-owned lifecycle. |
| `Service` | Application-scoped capability shared by multiple surfaces. |
| `Persistence` | Storage configuration or schema boundary, not the live service. |
| `Codec` | Pure conversion between a typed value and an external representation. |
| `Host` | Widget that connects a reusable surface to caller-owned state. |
| `Shell` | Top-level composition that scopes several application services. |
| `Editor` | User-facing editor surface; it does not imply document ownership. |

New public names use Dart-style acronym casing: `Nla`, `Xml`, `Ai`, `Http`, and
`Id`. Compatibility aliases may retain an older spelling during migration.

## Theme family

| Type | Responsibility |
| --- | --- |
| `BlenderThemeData` | Immutable colors, typography, density, shapes, and icons used for rendering. |
| `BlenderTheme` | Inherited widget that exposes `BlenderThemeData`. |
| `BlenderThemeController` | Live bridge used when overlay routes must follow a changing theme. |
| `BlenderThemeDefinition` | Named, editable theme preset suitable for persistence. |
| `BlenderThemeService` | Application-scoped preset selection, editing, import/export, and persistence. |
| `BlenderInterfacePreferences` | Non-palette interface metrics and behavior selected by the user. |
| `BlenderInterfacePreferencesService` | Application-scoped lifecycle and persistence for those preferences. |

Theme rendering belongs to `theme.dart`; preset storage and editing belong to
`theme_service.dart`. Interface preferences may transform a theme but are not a
second theme catalog.

## Workspace and docking family

| Type | Responsibility |
| --- | --- |
| `BlenderDockingController<T>` | Mutable dock tree for one workspace. |
| `BlenderDockingWorkspace<T>` | Gesture/rendering widget for that dock tree. |
| `BlenderWorkspaceDefinition<T>` | Stable workspace ID plus its initial dock layout. |
| `BlenderWorkspaceService<T>` | Owns all named workspace controllers and the active selection. |
| `BlenderWorkspaceSessionState` | Optional application context saved beside layouts. |
| `BlenderWorkspacePersistence<T>` | Storage and value-codec configuration. |
| `BlenderWorkspaceHost<T>` | Renders the active workspace controller. |
| `BlenderWorkspaceShell<T>` | Application frame combining service scopes, top/status bars, Preferences, and the workspace host. |

A workspace is the named application concept. Docking is the layout mechanism
inside one workspace. A screen is a retained application view and should not be
used as a synonym for either.

## Editor family

| Type | Responsibility |
| --- | --- |
| `BlenderEditorAreaController<T>` | Selected editor type for one dock area. |
| `BlenderEditorAreaHost<T>` | Switches the area's visible editor without owning its document. |
| `BlenderEditorSessionService` | Persists editor-area choices and shared Outliner/Properties context. |
| `BlenderEditorViewCodec<T>` | Converts host-owned editor vocabulary to persistence values. |
| `BlenderEditorFrame` | Common region chrome around an editor. |

An editor area is a dock slot. An editor session is cross-area application
context. Neither owns the application's domain document.

## Application family

`BlenderApplicationController<T>` composes history, commands, services, and
workspace selection for a host-owned document type. `BlenderApplicationScope`
publishes that composition. `BlenderApplicationPresentationService` owns
temporary About, splash, quit, and Preferences presentation; it does not own
application state.

## Extension-package boundaries

- `DawSessionController` is the current public façade over DAW document
  history, selection, view state, transport, and edit commands. Its distinct
  notification channels are intentional. A future split must extract real
  document command services while preserving transaction and undo boundaries;
  moving the same methods into cosmetic `part` files is not sufficient.
- `WorkbookSessionController` owns workbook authoring and transient execution
  state. `WorkbookRuntimeController` belongs to the example host and owns the
  optional Python/Jupyter, language-server, AI-provider, and application-support
  lifecycle. Offline document construction never depends on it.
- `WorkbookKernel` is the transport-neutral execution contract.
  `JupyterKernel` implements it; `JupyterServerProcess` owns an optional local
  server process; `JupyterRuntimeInstaller` owns installation and repair.

## Deliberately large files

The following size does not by itself justify refactoring:

- generated Xcode project files;
- public export barrels with explicit `show` lists;
- same-library entry points whose `part` files need private sharing;
- source-shaped property descriptor catalogs that mirror Blender panels;
- the chronological development history required for repository traceability.

Refactor a large file when it mixes lifecycles, mutation policies, protocols,
or coordinate systems—not merely when it crosses a line-count threshold.
