# Context-menu parity

This document records how context menus are composed in the local blenderapp
snapshot and how BlenderUI carries that interaction into reusable Flutter
surfaces. The reference revision is `68bdd158cc49af6191f0d9480510f4c5214f2df5`.

## Blender source analysis

Blender does not have one universal list of context-menu commands. It has a
shared popup mechanism and lets the region or target contribute commands from
its current context:

- `source/blender/editors/interface/interface_context_menu.cc`, especially
  `popup_context_menu_for_button`, assembles button/property actions. It derives
  a title from the target, omits mutation commands for disabled values, and adds
  animation, driver, data-path, quick-favorite, shortcut, documentation, and
  developer actions according to the active button.
- The abstract-view path activates the item under the pointer before building
  its menu. That ordering matters in trees and lists: commands must apply to the
  row that was secondary-clicked, not a previously selected row.
- `source/blender/editors/screen/screen_ops.cc` registers
  `SCREEN_OT_region_context_menu` for Header, Tool Header, Footer, and navigation
  regions. Area operations therefore remain available even without an entity
  target.
- `scripts/startup/bl_ui/space_outliner.py` defines
  `OUTLINER_MT_context_menu` and `OUTLINER_MT_context_menu_view`. Their sections
  cover clipboard and deletion, hierarchy selection, unlinking and collection
  creation, ID data, asset state, library overrides, view, and area commands.
- `scripts/startup/bl_ui/space_view3d.py` defines
  `VIEW3D_MT_object_context_menu` plus mode-specific mesh, curve, armature,
  particle, pose, grease-pencil, and other variants. Object type and selection
  count determine whether commands such as shading and Join appear or are
  enabled.
- `scripts/startup/bl_ui/space_node.py` defines `NODE_MT_context_menu`. Empty
  canvas and selected-node contexts differ; selected nodes receive clipboard,
  duplicate/delete, group, and frame operations.
- `scripts/startup/bl_ui/space_filebrowser.py` defines
  `FILEBROWSER_MT_context_menu`, with navigation, rename, folder/bookmark,
  display/sort, and deletion groups.
- `scripts/startup/bl_ui/space_view3d_toolbar.py` supplies brush/tool-specific
  context actions.

The resulting visual grammar is consistent even though command inventories are
not: a subdued target title, thin separators, optional leading icons or state
markers, right-aligned shortcuts, disabled rows, nested-menu arrows, and delayed
operator help. Popups are placed from the pointer and constrained to the window.

## BlenderUI design

`BlenderContextMenu<T>` owns only interaction and presentation:

- secondary click and optional long press;
- pointer-relative, viewport-constrained placement;
- target title, separators, icons, checks, shortcuts, disabled rows, submenus,
  and delayed descriptions;
- callbacks before open, after open/close, and after command selection.

`BlenderContextMenuCatalog` provides source-shaped common command descriptors
for Object, Outliner, Node, File Browser, Property, Tool, and Area contexts.
Stable IDs live in `BlenderContextActionIds`. Catalogs do not execute commands
or own application state. A host can pass context flags, append domain actions,
replace a family completely, and route the selected ID through its own command
system.

Target-aware reusable widgets expose builders rather than embedding sample
commands:

| Surface | Target passed to the host |
| --- | --- |
| `BlenderTree` / `BlenderOutliner` | `BlenderTreeNode<T>` |
| `BlenderListView` | `BlenderListItem<T>` |
| `BlenderFileBrowser` | `BlenderFileEntry` |
| `BlenderNodeEditor` | `BlenderGraphNode` |
| `BlenderPropertiesEditor` | `BlenderPropertyDescriptor<dynamic>` |
| `BlenderToolShelf` / `BlenderView3dToolShelf` | tool descriptor and index |

Trees, lists, files, and nodes activate the pointed target before displaying
the menu, matching blenderapp's abstract-view behavior. The example app only
chooses catalogs and reports selected command IDs; reusable gesture, layout,
catalog, and identity-routing behavior remains in the package.

## Deliberate boundary

BlenderUI is a UI library, not Blender's RNA/operator system. It therefore does
not infer object types, inspect a clipboard, mutate scene graphs, resolve
library overrides, open documentation, or register keyboard shortcuts. Hosts
provide those facts and execute actions. This keeps disabled and conditional
states truthful without coupling the package to one application's model.

## Implementation backlog

- [x] Audit shared popup dispatch and editor-specific menu sources.
- [x] Add target titles, help descriptions, disabled states, and viewport-safe
      placement to the reusable menu primitive.
- [x] Add source-shaped common catalogs with stable action IDs.
- [x] Select the pointed view item before opening its context menu.
- [x] Expose target-aware context menus from Outliner/tree, lists, files,
      nodes, properties, and tool shelves.
- [x] Replace the example's single generic menu with editor- and target-aware
      catalogs while keeping action execution example-owned.
- [x] Add behavioral tests for grouping/state, edge placement, selection
      ordering, action routing, and entity identity.
- [x] Update the coverage map, decision record, changelog, and development
      history.

## Verification and implementation notes

- Package analysis and the complete package widget suite are the primary
  regression checks; the example has its own analyzer and test suite.
- `dart format` and Flutter commands attempted to update the shared Flutter SDK
  cache outside the workspace sandbox. They were rerun with narrowly scoped
  permission for the SDK cache; no application files outside this repository
  were changed.
- Menu placement reuses the package's existing anchored-popover delegate. A
  second context-only positioning implementation was intentionally avoided.
