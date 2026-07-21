# Blender manual UI and editor parity backlog

Date: 2026-07-20

Reference manual: Blender 4.5 LTS, `latest` pages fetched on 2026-07-20.

Source snapshot: local blenderapp checkout,
`68bdd158cc49af6191f0d9480510f4c5214f2df5`.

This is the active requirement-by-requirement backlog for the manual's
[User Interface](https://docs.blender.org/manual/en/latest/interface/index.html)
and [Editors](https://docs.blender.org/manual/en/latest/editors/index.html)
indexes. The broader [coverage map](reference/blender-ui-coverage.md) records
low-level source families; this file records the user-visible manual surfaces,
their representative screenshots, and the next concrete parity work.

## Status and ownership rules

- **Covered**: reusable presentation exists in `blenderui`; host data and
  operator execution may intentionally remain caller-owned.
- **Active**: a reusable surface exists, but the screenshot/source audit found
  presentation or ownership work still to land.
- **Open**: no adequate reusable package surface exists yet.
- The example app may provide sample data, mutable demo state, callbacks, and
  composition. Shared chrome, menus, panels, controls, models, layout, and
  interactions belong in `blenderui`.
- A row is not complete merely because its editor type appears in the selector.
  Completion needs source-shaped regions and a rendered comparison at an
  appropriate editor size.

## User Interface backlog

## Example-only surface audit

The example contains both a Blender-shaped application workspace and an
interactive component showcase. These surfaces must not be mistaken for
Blender regions when reviewing screenshots or adding library APIs.

| Surface | Evidence | Decision | Follow-up |
| --- | --- | --- | --- |
| Properties “Quick Controls” split pane | `example/lib/showcase/showcase_app/properties_surface.dart` previously placed a vertical `BlenderSplitter` below the Properties editor with unrelated modifier, keyframe, viewport, color, progress, and shortcut controls. Blender’s `space_properties.py` registers only the header, navigation bar, header popovers, and context panels. | **Removed 2026-07-21** | Keep the Properties area as one source-shaped editor region. |
| Components workspace | `animation_templates.dart` labels workspace `10` as `Components`; it hosts `DemoWorkbench`, not a Blender startup workspace. | Intentional documentation surface | Keep available as an explicit example-only workspace; do not use it as parity evidence. |
| UI Catalog surface | `gallery_controls.dart` builds a catalog of reusable controls, dialogs, importers, and property templates. No corresponding Blender editor exists. | Intentional documentation surface | Keep isolated from the default Blender workspace and document it in screenshots/tests. |
| Bottom “UI Catalog” selector item | `bottom_graph_editor.dart` exposes the catalog beside Timeline, Action, Shader Editor, Spreadsheet, and Keymap. Blender's editor selector contains editor types only. | **Aligned 2026-07-21** | The item is now visible only while the explicit Components workspace is active. |
| Bottom “Keymap” selector item | The example exposed the Preferences Keymap editor beside timeline/node editors. Blender registers Keymap under the Preferences window, not as an editor type. | **Aligned 2026-07-21** | The item is now visible only in the explicit Components workspace; the reusable Keymap editor remains available to documentation surfaces. |
| Showcase splash branding/content | `animation_templates.dart` supplies custom BlenderUI branding and template cards. Blender’s splash is a native startup screen with Blender release artwork and recent-file/template data. | Approximation with host-owned branding | Recheck artwork, recent-file rows, and spacing against `wm_splash_screen.cc` before claiming exact parity. |
| Synthetic status/job fixtures | `showcase_status_bar.dart` supplies sample jobs, reports, and messages. Blender has the same status-bar families, but these values are not Blender runtime state. | Host fixture, not a pane mismatch | Keep data host-owned; compare only region anatomy and ordering. |

| Manual surface | Current reusable surface | Status | Remaining work |
| --- | --- | --- | --- |
| Window System / Introduction | `BlenderWorkspaceShell`, `BlenderEditorFrame` | Covered | Keep window composition host-owned. |
| Splash Screen | `BlenderSplashScreenConfiguration`, presentation service | Covered | Recheck current 4.5 spacing and recent-file layout in a rendered pass. |
| Topbar | `BlenderApplicationTopBar`, source menu bar, workspace strip and Scene/View Layer controls | Covered | Fixed/scroll overflow policies and the rendered showcase baseline are tested; commands/workspaces remain host-owned. |
| Workspaces | workspace definitions, screens, service, tab bar | Covered | Workspace content and persistence remain host-owned. |
| Status Bar | input status, context, jobs, reports, version/warning surfaces | Covered | Source-ordered regions and descriptors are reusable; Blender context polling stays host-owned. |
| Areas | docking model, splitter, area-edge options, editor frame | Covered | Recheck minimum sizes and edge hit zones under scaled UI. |
| Regions | header, toolbar, sidebar, tool shelf, asset shelf, footer primitives | Covered | All documented editor-header families and the shared animation/Text footers are library-owned. |
| Tabs & Panels | tab bar, vertical property tabs, panels and subpanels | Covered | Add reorder grip behavior only where a host supplies persistence. |
| Keymap | command bindings, keymap editor, keycaps and input status | Covered | Editing/presentation are reusable; built-in Blender/Industry keymap datasets and import remain host-owned. |
| Buttons | buttons, icon buttons, toggles, segmented controls | Covered | Continue screenshot checks for state contrast and compact geometry. |
| Input Fields | text, number, slider, property and vector/matrix fields | Covered | Validate drag editing and unit formatting across scale factors. |
| Menus | dropdown, popup, nested/context/pie/multi-column menus | Covered | Operator execution remains host-owned. |
| Eyedropper | `BlenderEyedropper` plus specialized crypto picker | Covered | Sampling and cancellation remain host-owned. |
| Decorators | `BlenderPropertyIndicator`, property state | Covered | Validate animated/driven/overridden colors against the active theme. |
| Data-Block Menu | data-block group/field and action selector | Covered | Host owns lookup, user counts, linking, and mutation. |
| List View | list, template list, compact list | Covered | Rich drag/drop policies remain descriptor-driven follow-up work. |
| Tree View | generic tree, Outliner, specialized trees | Covered | Generic trees share expansion, drag/drop targets and insertion markers, range/toggle selection, and arrow/Enter keyboard navigation. |
| Color Picker | picker, field, swatch, crypto picker | Covered | Add remaining manual picker-shape variants only when backed by a stable descriptor. |
| Color Ramp Widget | `BlenderColorRamp` | Covered | Host owns domain interpolation/evaluation. |
| Color Palette | `BlenderColorPalette` | Covered | Host owns palette persistence. |
| Curve Widget | curve mapping/profile surfaces | Covered | Host owns curve evaluation. |
| Tool System | toolbar, generic and View3D/Node/Image tool shelves | Covered | Stable editor tool taxonomies live in the package; active tool state and execution remain host-owned. |
| Operators | commands, operator properties dialog | Covered | Operator polling/execution and undo remain host-owned. |
| Undo & Redo | state store, command registry, redo popup | Covered | Verify grouped history labels when the host supplies them. |
| Annotations | `BlenderAnnotationSettingsPanel` and editor tool entries | Covered | One immutable shared settings surface now replaces Node, Sequencer, and Clip sidebar copies. |
| Selecting | selection callbacks, context routing, reusable tree/node policies | Covered | Tree range/toggle/keyboard selection and Node click/box selection report complete host-owned ID sets. |
| Node Editors | universal node header, canvas, sidebar and tool shelf | Covered | Evaluation, undo, and persistence remain host-owned. |
| Node Parts | typed sockets, node bodies, labels, states and previews | Covered | Add new Blender node body variants through the existing body builder. |
| Selecting Nodes | host-owned selected IDs, click/extend/toggle and box selection | Covered | Selection remains in the graph document; the canvas emits immutable replacement sets. |
| Arranging Nodes | node drag, frames, reroutes, grouped transforms and snapping | Covered | The canvas emits one grouped move transaction and supports an optional scene-space snap increment. |
| Editing Nodes | validated connections, deletion, duplicate and cut-link workflows | Covered | Cut strokes and duplicate IDs are host-driven; evaluation/undo remain caller-owned. |
| Common Nodes | generic node model/body builder | Covered | Individual domain node catalogs are application data. |
| Node Groups | immutable group-path navigation, breadcrumbs and interface trees | Covered | Enter/exit/jump state is reusable; node-tree lookup remains caller-owned. |

## Editor backlog

The screenshot column names the representative image linked by the current
manual page. Some index pages delegate their image to an Introduction page;
Geometry Nodes uses the shared Node Editors header image.

| Editor | Manual screenshot | blenderapp source | Current package surface | Status and next work |
| --- | --- | --- | --- | --- |
| 3D Viewport | `editors_3dview_introduction_3d-view-header-object-mode.png` | `space_view3d.py`, `space_view3d/` | `BlenderView3dEditorHeader`, viewport shell/sidebar/tool shelf; example scene renderer | **Covered:** source-shaped header/state, renderer-independent navigation, gizmo and regions have a 1200×700 reference; scene projection remains host-owned. |
| Image Editor | `editors_image_introduction_main.png` | `space_image.py`, `space_toolsystem_toolbar.py` | `BlenderImageEditorHeader`, `BlenderImageEditor`, shared regions/sidebar/tool shelf | **Covered:** source-conditioned View/Image menus, persistent header state, 42 px toolbar, 240 px sidebar, Paint-only asset shelf, and a 1200×700 rendered reference live in the library. Image IO and paint execution remain host-owned. |
| UV Editor | `editors_uv_introduction_main.png` | `space_image.py`, `space_toolsystem_toolbar.py` | shared header/state/regions/tool shelf, `BlenderUVEditor` | **Covered:** source Select/UV taxonomy, independent snapping/proportional controls, UV selection modes, overlay canvas, sidebar, and a 1200×700 rendered reference are reusable. UV mutation remains host-owned. |
| Compositor | `compositing_types_distort_map-uv_example-2.png` | `space_node.py`, `space_node/` | universal `BlenderNodeEditor` | **Covered:** keep compositor backdrop/gizmo state caller-owned; add compositor fixtures as data only. |
| Texture Nodes | `editors_texture-node_introduction_types-combined.png` | `space_node.py`, `space_node/` | universal `BlenderNodeEditor` | **Covered:** legacy texture node catalog remains caller-owned. |
| Geometry Node Editor | `interface_controls_nodes_introduction_header.png` | `space_node.py`, `node_add_menu_geometry.py`, `space_node/` | universal node header, host, graph, sidebar, shelf | **Covered:** current active node pass adds culling, typed link gestures, source menu taxonomy, overlays, frames and reroutes. |
| Shader Editor | `editors_shader-editor_main.png` | `space_node.py`, `space_node/` | universal `BlenderNodeEditor` | **Covered:** shader data and evaluation remain caller-owned. |
| Video Sequencer | `editors_vse_overview.svg` | `space_sequencer.py`, `space_sequencer/` | `BlenderSequencerEditorHeader`, editor/sidebar/strip models | **Covered:** source view-mode branches, menus, state, sidebar geometry, and strip canvas have a rendered reference; media evaluation remains host-owned. |
| Movie Clip Editor | `editors_clip_introduction_example.png` | `space_clip.py`, `space_clip/` | `BlenderClipEditorHeader`, editor/sidebar and mask properties | **Covered:** Tracking/Mask branches and preview/sidebar ratios have a rendered reference; tracking and solving remain host-owned. |
| Dope Sheet | `editors_dope-sheet_introduction_overview.png` | `space_dopesheet.py`, `space_action/` | shared Dope/Timeline header, editor, sidebar and playback footer | **Covered:** Action controls, channel/key regions, sidebar, and rendered reference are reusable. |
| Timeline | `editors_timeline_interface.png` | `space_time.py`, `space_action/`, `time_scrub_ui.cc` | shared Dope/Timeline header, `BlenderTimeline`, playback footer | **Covered:** independent Channels/Search/Summary and window/scrub regions, source-ordered transport/range controls, padded View2D framing, numbered playhead, collapsed-region clipping, retained keylists, viewport culling, overlay repaint isolation, and a rendered reference are committed. |
| Graph Editor | `editors_graph-editor_introduction_example.png` | `space_graph.py`, `space_graph/` | `BlenderGraphEditorHeader`, curve editor/sidebar/footer | **Covered:** curve/channel/sidebar geometry and source header state have a rendered reference. |
| Drivers Editor | `editors_drivers_introduction_example.png` | `space_graph.py`, `space_graph/` | Graph-family header/editor plus driver-variable sidebar | **Covered:** driver-variable descriptors and a distinct rendered reference are committed. |
| Nonlinear Animation | `editors_nla_introduction_example.png` | `space_nla.py`, `space_nla/` | `BlenderNlaEditorHeader`, editor/sidebar/footer | **Covered:** source filter/snap/header state and strip density have a rendered reference. |
| Text Editor | `editors_text-editor_header-loaded.png` | `space_text.py`, `space_text/` | utility header, editor/sidebar and `BlenderTextEditorFooter` | **Covered:** status footer, line region and sidebar have a rendered reference; document IO/execution remain host-owned. |
| Python Console | `editors_python-console_default.png` | `space_console.py`, `space_console/` | utility header and `BlenderConsoleEditor` | **Covered:** typed line presentation and caller-owned command history navigation have a rendered reference. |
| Info Editor | `editors_info-editor_ui.png` | `space_info.py`, `space_info/` | utility header and `BlenderInfoEditor` | **Covered:** severity filters, selection state, timestamps and a rendered reference are reusable. |
| Outliner | `editors_outliner_introduction_interface.png` | `space_outliner.py`, `space_outliner/` | `BlenderOutliner`, tree selection/drop policies and source headers | **Covered:** keyboard/range selection, existing drag/drop indicators, display branches, and a rendered reference are reusable. |
| Properties Editor | `editors_properties-editor_interface.png` | `space_properties.py`, `properties_*.py`, `space_buttons/` | `BlenderPropertiesEditor` and reusable property/template widgets | **Covered:** responsive narrow-width panel geometry and a rendered reference are reusable; context RNA/polling stays in the host. |
| File Browser | `editors_file-browser_editor.png` | `space_filebrowser.py`, `space_file/` | `BlenderFileBrowser`, sortable columns, sidebar and execution templates | **Covered:** folder-first sorting, Name/Date/Size/Type columns, modal-region composition, and a rendered reference are reusable. |
| Asset Browser | `asset_browser-gold-material.png` | `space_filebrowser.py`, `space_file/` | asset browser mode, catalogs, caller preview builder and metadata sidebar | **Covered:** caller-supplied previews replace generic icons and a rendered asset layout is committed. |
| Spreadsheet | `editors_spreadsheet_interface.png` | `space_spreadsheet.py`, `space_spreadsheet/` | header/state and filterable/sortable `BlenderSpreadsheetEditor` | **Covered:** selected/query row filters, host-owned sort/selection, synchronized scroll controllers, left-aligned expansion, and a rendered reference are reusable. |
| Preferences | `editors_preferences_section_interface.webp` | `space_userpref.py`, `space_userpref/` | `BlenderPreferencesEditor`, grouped categories/sections and temporary window | **Covered:** all source categories remain descriptor-driven, responsive sections and a rendered reference are committed; settings persistence remains host-owned. |

## Cross-cutting implementation order

1. Finish and verify the active universal node-editor pass without regressing
   its public model or interaction behavior.
2. Eliminate example-owned shared header construction. The first landed steps
   are `BlenderEditorMenuCatalog`, which replaces the private descriptor
   factory across nine header families, and `BlenderUtilityEditorHeader`, which
   owns the Text, Console, Info, Outliner, File/Asset Browser, Spreadsheet,
   Project, Properties, and Preferences menu anatomy.
3. Extract stateful header widgets by shared source family. Image/UV,
   animation, Sequencer, Clip, View3D, Spreadsheet, and utility families are
   complete and integrated by the example app.
4. Fill the shared-interface gaps. Annotation settings, tree/node selection,
   tree drag/drop, grouped node movement, file sorting/previews, Spreadsheet
   synchronization, and the eyedropper now have reusable host-driven APIs.
5. Maintain one 1200×700 rendered reference fixture for every documented
   editor type. All 23 are committed; Flutter test glyphs validate durable
   region/density/state geometry while manual images remain the human text and
   typography reference.
6. Re-audit all rows against current code and rendered evidence. Move completed
   decisions into a dated decision record; never convert caller-owned Blender
   data/evaluation into package state merely to make a row appear complete.

## Native runtime comparison and resize audit

On 2026-07-20 the macOS example and Blender 5.1.2 were launched at matching
1280×801 outer-window dimensions and captured by their individual
CoreGraphics window IDs. The captures remain temporary comparison evidence;
Blender screenshots are not copied into this repository.

- BlenderUI had visibly larger default text and menu labels. The local source
  defines `UI_DEFAULT_TEXT_POINTS` as 11, so the shared text tokens and menu
  rows now use the same 11-point baseline and all 23 editor references were
  regenerated.
- The example viewport was lighter than Blender's factory viewport and opened
  Tool Properties by default. It now uses the darker raised-surface token and
  opens Object Properties for the selected cube with the 3D View sidebar
  collapsed.
- At a native 640×420 window, the floating View3D tool shelf and N-panel tab
  rail overflowed vertically. Both reusable rails now scroll without injecting
  desktop scrollbar chrome.
- At a native 420×300 window, narrow Outliner, Properties, area-header, color,
  and tool-panel rows overflowed horizontally. Shared headers, trees, property
  captions/rows, and the docking minimum-layout contract now degrade through
  progressive disclosure rather than emitting invalid Flex layouts.
- Automated divider drags now verify both horizontal and vertical leaf areas
  at their minimum extents. The dock keeps a minimum internal layout canvas
  clipped to the real area, so an undersized window cannot force child editors
  below their declared layout contract.
- A follow-up screenshot audit aligned the 3D View's toolbar to blenderapp's
  56 px region, 40 px buttons, and 32 px tool icons; restored the Pan mini
  gizmo; removed the canvas gutter; and separated source geometry from the
  user-controlled global UI scale. Collapsed headers now keep only their
  editor selector before fixed leading controls can overflow.

The remaining intentional differences are domain boundaries: BlenderUI's
viewport is a lightweight example renderer rather than Blender's draw engine,
Material Symbols replace GPL Blender icon assets, and operator/RNA evaluation
remains host-owned.

## Tooling evidence and limitations

- The official manual pages and their image assets were downloaded successfully
  with `curl` after sandboxed DNS access failed.
- The in-app browser could not initialize because required sandbox-policy
  metadata was absent. The manual images were instead downloaded to temporary
  storage and inspected in four contact sheets; no image assets are committed.
- The local blenderapp worktree presents its source files as deleted/untracked
  relative to its Git index, but the requested source snapshot is readable and
  matches the revision already recorded by this repository. This audit did not
  modify blenderapp.
- Root and example `flutter analyze` pass, the structural guard passes for 303
  Dart files, the package suite passes 228 tests (including all 23 editor
  references), and the example suite passes 72 tests.
