# blender_ui example

This is a runnable Blender-like desktop workspace for exercising `blender_ui`.
It intentionally uses a minimal custom-painted 3D view instead of a rendering
engine, so the controls and editor surfaces remain easy to inspect.

The sample includes:

- top-level file/workspace controls and search
- a vertical tool shelf and right-side Outliner/Properties column
- tool-option popovers with selection tool variants and contextual tooltips
- an orbitable perspective grid, shaded/wire cube, axes, and orientation gizmo
- corner-drag area splitting and edge/center docking with live previews
- properties with numeric fields, sliders, dropdowns, and checkboxes
- a resizable quick-controls sidebar
- timeline and shader-node tabs
- a UI Catalog tab covering reusable controls and templates
- a first-class Components workspace with searchable Overview, Controls,
  Layout, Data & Properties, Editors, and App Services categories
- live examples powered by the package's scoped state store, undo/redo history,
  dependency container, and command registry
- centered alert and operator-property dialogs in the UI Catalog
- operator redo popups with compact property rows and disabled-state styling
- collection importer/exporter panels with file paths, reordering, presets, and export actions
- palette management with selectable color swatches and sorting controls
- Action data-block selection and Cryptomatte eyedropper controls
- full data-block property fields with browse/search and lifecycle actions
- keymap item operator-property boxes with unset affordances
- resizable material/texture preview panes with preview controls
- icon-backed enum choices with Blender's eight-column preview popup
- searchable operator/collection menus with list and thumbnail-preview modes
- file-browser operator, execution, and asset-catalog side panels
- Preferences Asset Libraries with local/remote and built-in settings
- Properties texture-user selector and Texture-tab jump affordance
- severity-colored transient report banners linked to Info
- status-info text, version, extension-update, and warning states
- context-specific split/dock, resize, header, and viewport-warning status bars
- context-sensitive input/status rows for split, dock, pan, and warnings
- constraint, cache-file, light-linking, and Grease Pencil layer templates
- bone-collection trees, asset-shelf popovers, component menus, and compact lists
- secondary-click context menus and draggable node cards
- a single horizontally scrollable application header with edge fades and
  workspace hover tooltips

The default Layout workspace follows Blender's desktop composition: the top
application/workspace bar, compact viewport header, left tool shelf, right
Scene Collection and Properties column, and bottom Timeline. The viewport uses
a small perspective projection by design; it exercises orbit, zoom, gizmo, and
grid feedback without implementing a scene graph or detailed 3D renderer.

The Components workspace is the fastest way to evaluate the library. Its
left-hand search filters whole feature categories, each page contains focused
interactive examples, and every edit participates in a shared undoable demo
state. The App Services page demonstrates how the same command can be invoked
from several UI surfaces without introducing process-wide state.

Drag inside the viewport to orbit, scroll to zoom, and double-click to reset.
Drag from any editor corner to split that area or move it onto an edge or the
center of another area; existing divider lines remain directly resizable.

Run it from this directory with:

```sh
flutter run -d macos
```

That command opens the realistic Blender workspace. Select the far-right
**Components** workspace tab to open the searchable component workbench. The
workspace header scrolls horizontally when the tabs do not fit.

To launch the component workbench directly, use:

```sh
flutter run -d macos -t lib/components_demo.dart
```

Use `-d windows` or `-d linux` on the corresponding desktop platform.
