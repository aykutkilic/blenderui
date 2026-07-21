# Blender UI coverage map

Reference snapshot: local Blender checkout,
`main` at `68bdd158cc49af6191f0d9480510f4c5214f2df5`.

This is a clean-room visual coverage map, not a claim that the Flutter
package implements Blender's data model or operator behavior. The source
paths identify the Blender surfaces that determine geometry, density, state
appearance, and composition.

The manual-facing status and next implementation step for every documented UI
topic and editor type live in the
[manual UI and editor parity backlog](../manual-ui-editor-parity-backlog.md).

## Reading the coverage status

`Partial` means that the visible Blender source anatomy is represented, while
runtime polling, RNA/data ownership, persistence, and operator execution stay
with the embedding application. This is an intentional clean-room boundary:
the package is a reusable visual surface, not a replacement Blender data
model. The remaining partial rows have been reviewed against their local
source files and are retained where the missing behavior is functional rather
than visual.

## Shared interface surfaces

| Blender source family | Package surface | Status |
| --- | --- | --- |
| `interface_layout.cc` | `BlenderBox`, `BlenderFlow`, `BlenderGrid`, `BlenderOverlap`, `BlenderPanel`, `BlenderRegion`, `BlenderSplitter`, and dock leaves with a clipped minimum internal layout canvas | Implemented, including extreme window/pane sizing |
| `interface_widgets.cc`, `interface_style.cc` | `BlenderTheme` with source-aligned 11-point UI typography, controls, property indicators, semantic glyphs | Implemented |
| `interface_region_menu_popup.cc`, `interface_context_menu.cc`, `screen_ops.cc` | `BlenderMenu`, `BlenderDropdown`, `BlenderMenuButton`, `BlenderContextMenu`, `BlenderContextMenuCatalog` | Implemented presentation and target routing; operator execution is host-owned |
| `interface_region_popover.cc` | `BlenderPopover` and anchored template popovers | Implemented |
| `wm_operators.cc` (`wm_block_dialog_create`) | `showBlenderDialog`, `BlenderDialog`, `BlenderAlertDialog` with source-shaped two-column Cancel/Confirm actions | Implemented |
| `wm_operators.cc` (`wm_block_create_redo`, `WM_operator_props_dialog_popup`) | `BlenderOperatorRedoPopup`, `BlenderOperatorPropertiesDialog` | Implemented |
| `interface_region_menu_pie.cc` | `BlenderPieMenu` | Implemented |
| `interface_region_tooltip.cc` | `BlenderTooltip` | Implemented |
| `interface_region_search.cc` and `interface_template_search_menu.cc` | `BlenderSearchMenu`, search fields, filter bars | Implemented |
| `interface_region_color_picker.cc` | `BlenderColorPicker`, color fields, swatches and crypto picker | Implemented |
| `interface_template_operator_property.cc` | `BlenderDialog` property content, `BlenderPropertyRow`, collection importer/exporter panels | Implemented |
| `interface_template_constraint.cc` | `BlenderConstraintStack` | Implemented |
| `interface_template_cache_file.cc` | `BlenderCacheFilePanel` | Implemented |
| `interface_template_attribute_search.cc` | `BlenderAttributeSearch` | Implemented |
| `interface_template_color_management.cc` | `BlenderColorManagement` | Implemented |
| `interface_template_color_picker.cc` | `BlenderColorPicker`, `BlenderColorPalette` | Implemented |
| `interface_template_color_ramp.cc` | `BlenderColorRamp` | Implemented |
| `interface_template_curve_mapping.cc` | `BlenderCurveMapping` | Implemented |
| `interface_template_curve_profile.cc` | `BlenderCurveProfile` | Implemented |
| `interface_template_event.cc` | `BlenderInputStatus`, source-backed modifier/event glyphs, `BlenderKeycap` fallback | Partial |
| `interface_template_shader_fx.cc` | `BlenderShaderEffectStack` | Implemented |
| `interface_template_node_tree_interface.cc` | `BlenderNodeTreeInterface` | Implemented |
| `interface_template_node_inputs.cc` | `BlenderNodeInputs` | Implemented |
| `interface_template_light_linking.cc` | `BlenderLightLinkingCollection` | Implemented |
| `interface_template_grease_pencil_layer_tree.cc`, `interface_template_grease_pencil_layer_search.cc` | `BlenderGreasePencilLayerTree` | Implemented |
| `interface_template_id.cc` | `BlenderDataBlockField`, `BlenderActionSelector` plus compact `BlenderDataBlockGroup` | Implemented |
| `UI_icons.hh`, `interface_template_icon.cc` | Semantic `BlenderGlyph` catalog rendered with Apache-licensed Material Symbols by default, independently drawn vector compatibility backend, `BlenderIconView`, and `BlenderPreviewTile`; no Blender icon assets copied | Implemented |
| `interface_template_layers.cc` | `BlenderLayerSelector` | Implemented |
| `interface_template_keymap.cc` | `BlenderKeymapItemProperties` | Implemented |
| `interface_template_matrix.cc` | `BlenderMatrixTransformPanel`, `BlenderMatrixField` | Implemented |
| `interface_template_modifiers.cc` | `BlenderModifierStack` | Implemented |
| `interface_template_list.cc` | `BlenderTemplateList`, `BlenderListView`, `BlenderCompactList` | Implemented |
| `interface_template_preview.cc` | `BlenderPreviewPanel` plus `BlenderPreviewTile` | Implemented |
| `interface_template_recent_files.cc` | `BlenderRecentFiles` | Implemented |
| `interface_template_running_jobs.cc` | `BlenderJobProgress`, `BlenderRunningJobsPanel` | Implemented |
| `interface_template_scopes.cc` | `BlenderScopeView` | Implemented |
| `interface_template_search.cc`, `interface_template_search_menu.cc` | `BlenderSearchField`, `BlenderSearchMenu` list and preview modes | Implemented |
| `interface_template_search_operator.cc` | `BlenderSearchMenu` | Implemented |
| `interface_template_status.cc`, `space_statusbar.py` | `BlenderInputStatus`, `BlenderStatusContextBar`, `BlenderStatusBar`, `BlenderStatusInfo`, `BlenderInfoEditor`, `BlenderReportBanner`, and `BlenderRunningJobsPanel` with source-ordered input/report/job/status-info regions | Partial |
| `space_topbar.py` | Source-shaped Blender, File (including External Data/Clean Up submenus), Edit (including undo/redo states, history submenu, Operator Search, shortcuts, toggle, and temporary Preferences action), Render, Window, Help, workspace, scene, and view-layer top-bar families | Partial |
| `space_outliner.py`, `rna_space.cc` | `BlenderOutliner` mode-specific headers plus shared range/toggle selection, arrow/Enter navigation, drag payload/acceptance hooks, and insertion markers | Presentation and interaction implemented; data mutation caller-owned |
| `interface_template_strip_modifiers.cc` | `BlenderModifierStack` visual anatomy | Implemented |
| `interface_template_bone_collection_tree.cc` | `BlenderBoneCollectionTree` | Implemented |
| `interface_template_asset_shelf_popover.cc`, `asset_shelf_popover.cc`, `asset_shelf_catalog_selector.cc` | `BlenderAssetShelfPopover`, `BlenderAssetShelfCatalogSelector` with library selector, active catalog tree, catalog visibility tree, search, previews, and asset activation | Implemented; asset discovery/loading remains caller-owned |
| `interface_template_component_menu.cc` | `BlenderComponentMenu` | Implemented |
| `interface_template_list.cc` (compact layout) | `BlenderCompactList` | Implemented |
| `space_file/file_panels.cc` execution panel | `BlenderFileExecutionPanel` | Implemented |
| `space_file/file_panels.cc` operator panel | `BlenderFileOperatorPanel` | Implemented |
| `space_file/file_panels.cc` asset-catalog panel | `BlenderFileAssetCatalogPanel` composed into the Asset Browser Tools region | Partial |
| `space_file/file_draw.cc` asset-browser and library availability hints | `BlenderFileBrowserHint`, `BlenderFileBrowserLibraryPathHint`, `BlenderFileBrowserUnreadableLibraryHint` | Implemented |
| `space_filebrowser.py` | `BlenderFileBrowser` navigation/actions, folder-first sortable Name/Date/Size/Type columns, caller preview builder, and source File/Asset sidebars | Presentation and interaction implemented; IO/catalog persistence caller-owned |
| `space_view3d.py`, `space_view3d_sidebar.py`, `space_view3d_toolbar.py` | `BlenderView3dEditorHeader`, viewport shell/sidebar, grouped tool shelf, orientation gizmo, and source-shaped tool/property families | Presentation and navigation implemented; rendering and operators caller-owned |
| `space_node.py`, `node_add_menu_geometry.py`, `node_draw.cc`, `drawnode.cc`, `view2d.cc` | Universal Node Editor/Shader/Geometry/Compositor/Texture header and canvas with nested menus, typed links, culling, node variants, shared annotation/sidebar regions, immutable node-group breadcrumbs, host-owned multi/box selection, grouped transforms, snapping, duplicate transactions, and cut-link strokes | Presentation and interaction implemented; evaluation/undo caller-owned |
| `space_image.py` | Source-shaped Image/UV header, menus, immutable state, shared toolbar/sidebar/asset-shelf regions, and mode-specific canvas anatomy | Presentation and interaction implemented; image/UV mutation caller-owned |
| `space_sequencer.py` | `BlenderSequencerEditorHeader`, Sequencer/Preview branches, menus/state, sidebar families, shared annotation panel, strip canvas and playback footer | Presentation and interaction implemented; media evaluation caller-owned |
| `space_nla.py` | `BlenderNlaEditorHeader`, menus/filter/snap state, playback footer, strip canvas and NLA sidebar families | Presentation and interaction implemented; animation data caller-owned |
| `space_userpref/userpref_asset_libraries_list.cc` | `BlenderAssetLibrariesPreferencesPanel` | Partial |
| `space_userpref.py` | `BlenderPreferencesEditor` and temporary `BlenderPreferencesWindow` with source-ordered Interface, Editing, Animation, System, Viewport, Themes, File Paths, Save & Load, Input, Navigation, Keymap, Extensions, Add-ons, Assets, Lights, Developer Tools, and Experimental categories; Animation Timeline, Keyframes, and F-Curves; and nested Transparent Checkerboard and Auto Run Python Scripts panels | Partial |
| `space_buttons/buttons_texture.cc` | `BlenderTextureUserSelector` in Texture Properties and the reusable texture-user surface | Partial |
| `space_buttons/space_buttons.cc`, `space_properties.py`, `interface_layout.cc` | `BlenderPropertiesEditor` with Blender-ordered Tool, Render, Output, View Layer, Scene, World, Collection, Object, Modifiers, Effects, Particles, Physics, Constraints, Data, Bone, Bone Constraints, Material, Texture, Strip, and Strip Modifiers contexts, plus panel/property filtering and search-state expansion | Implemented |
| `scripts/startup/bl_ui/properties_render.py` | source-ordered Render Properties panel tree with Eevee and Workbench engine-specific families, common Simplify/Color Management/Freestyle panels, and the hidden-header engine selector | Partial |
| `scripts/startup/bl_ui/properties_output.py` | source-ordered Output Properties format, output, metadata, encoding, audio, and stamp panels | Partial |
| `scripts/startup/bl_ui/properties_scene.py` | source-ordered Scene Properties panel tree and example Scene context | Partial |
| `scripts/startup/bl_ui/properties_world.py` | source-ordered World Properties panel tree and example World context | Partial |
| `scripts/startup/bl_ui/properties_data_modifier.py` | source-backed Add Modifier categories and example modifier stack | Partial |
| `scripts/startup/bl_ui/properties_material.py` | source-ordered Material Properties panel tree and material-slot context | Partial |
| `scripts/startup/bl_ui/properties_material_gpencil.py` | legacy Grease Pencil material Surface, Stroke, Randomize, Fill, Preview, Settings, Animation, and Custom Properties panels | Partial through Material context |
| `scripts/startup/bl_ui/properties_object.py` | nested `BlenderPropertyGroup` panels and example Object identity/Transform context | Partial |
| `scripts/startup/bl_ui/properties_data_mesh.py` | source-ordered Mesh Data panels, data-block header, and list-based geometry data surfaces | Partial |
| `scripts/startup/bl_ui/properties_data_camera.py` | dynamic Camera Data context with lens, DOF, background, display, safe-area, and animation panels | Partial |
| `scripts/startup/bl_ui/properties_data_light.py` | dynamic Light Data context with preview, light/shadow/influence, beam-shape, animation, and custom-property panels | Partial |
| `scripts/startup/bl_ui/properties_data_curve.py` | conditional Curve/Text Data contexts with shape, texture-space, geometry/bevel, path-animation, Font/Transform, Paragraph/Alignment/Spacing, Text Boxes, animation, and custom-property panels | Partial |
| `scripts/startup/bl_ui/properties_data_curves.py` | dynamic Curves Data context with surface, attribute-list, animation, and custom-property panels | Partial |
| `scripts/startup/bl_ui/properties_data_pointcloud.py` | dynamic Point Cloud Data context with attribute-list and custom-property panels | Partial |
| `scripts/startup/bl_ui/properties_data_speaker.py` | dynamic Speaker Data context with sound, distance, cone, animation, and custom-property panels | Partial |
| `scripts/startup/bl_ui/properties_data_volume.py` | dynamic Volume Data context with OpenVDB file, grids, render, viewport/slicing, animation, and custom-property panels | Partial |
| `scripts/startup/bl_ui/properties_data_lightprobe.py` | dynamic Light Probe Data context with Probe/Visibility, Capture, Bake sub-panels, Custom Parallax, Viewport Display, and Animation | Partial |
| `scripts/startup/bl_ui/properties_data_grease_pencil.py` | dynamic Grease Pencil Data context with Layers and nested layer panels, Onion Skinning, Settings, Attributes, Animation, and Custom Properties | Partial |
| `scripts/startup/bl_ui/properties_data_bone.py` | active Bone Properties context with Transform, Bendy Bones, Relations/Bone Collections, Viewport Display/Custom Shape, Inverse Kinematics, Deform, and Custom Properties | Partial |
| `scripts/startup/bl_ui/properties_data_shaderfx.py` | ShaderFX Properties context with an Effects add menu and stacked, reorderable effect panels | Partial |
| `scripts/startup/bl_ui/properties_view_layer.py` | View Layer Properties context with View Layer, Passes and nested render-pass groups, Filter, Override, and Custom Properties | Partial |
| `scripts/startup/bl_ui/properties_collection.py` | Collection Properties context with Visibility/View Layer flags, Importer, Exporters, Instancing, Line Art, and Custom Properties | Partial |
| `scripts/startup/bl_ui/properties_texture.py` | Texture Properties context with Preview, Texture/Node, procedural type, Mapping, Influence, Colors/Color Ramp, Animation, and Custom Properties | Partial |
| `scripts/startup/bl_ui/properties_constraint.py` | Object/Bone Constraints context with instanced constraint cards, enable/menu/reorder/remove actions, and representative target/settings panels | Partial |
| `scripts/startup/bl_ui/properties_physics_common.py`, `properties_physics_cloth.py`, `properties_physics_softbody.py`, `properties_physics_fluid.py`, `properties_physics_dynamicpaint.py`, `properties_physics_field.py`, `properties_physics_rigidbody.py`, `properties_physics_rigidbody_constraint.py`, `properties_particle.py` | Physics context with source-shaped add-physics controls, detailed Cloth hierarchy, and nested Soft Body, Fluid, Dynamic Paint, Force Field, Rigid Body, Rigid Body Constraint, and Particle System families | Partial |
| `scripts/startup/bl_ui/properties_physics_geometry_nodes.py` | Physics Simulation Nodes panel with enabled state and simulation node-group selector | Partial through Physics context |
| `scripts/startup/bl_ui/properties_particle.py` | Dedicated Particles context with source-shaped particle type, emission/hair-dynamics, cache, velocity, rotation, physics, render, viewport-display, children, field-weights, force-field, vertex-group, texture, hair-shape, animation, and custom-property families | Partial through Particles context |
| `scripts/startup/bl_ui/properties_strip.py`, `properties_strip_modifier.py` | Sequencer Strip Properties and Strip Modifiers panel families, including source/effect/time/adjustment branches and modifier stack | Partial through Strip context |
| `scripts/startup/bl_ui/properties_paint_common.py`, `scripts/startup/bl_ui/space_view3d_toolbar.py` | View3D Tool Brush Asset and Brush Settings panels with nested Advanced, Color Picker, Color Palette, Clone from Paint Slot, Cursor, Texture, Texture Mask, Stroke/Stabilize Stroke, and Falloff sub-panels, plus Texture Paint Texture Slots, Canvas, Color Attributes, Vertex Groups, Masking, Stencil Mask, and Cavity Mask families, and Grease Pencil Draw/Weight/Vertex Paint brush, color, palette, falloff, stroke, and options families | Partial through Tool sidebar |
| `scripts/startup/bl_ui/properties_workspace.py` | Tool-sidebar Workspace panel with scene pinning, mode/scene synchronization, owner-filter toggle, right-aligned add-on enable rows, unknown-owner warning box, and custom-properties disclosure | Partial |
| `scripts/startup/bl_ui/properties_freestyle.py` | Render, View Layer, and Material Freestyle panels with source-shaped edge detection, Python style modules, line-set visibility/types, stroke chaining/splitting/sorting/selection/dashes, alpha/animation, line color/priority, and color/thickness/geometry/texture modifier families | Partial |
| `scripts/startup/bl_ui/properties_animviz.py` | Shared Motion Paths and Display anatomy consumed by Object and Armature Properties | Implemented through host contexts |
| `scripts/startup/bl_ui/properties_grease_pencil_common.py` | Shared Grease Pencil annotation, brush, layer, material, and snap helpers consumed by the Grease Pencil surfaces | Partial through host contexts |
| `bl_app_templates_system/2D_Animation`, `bl_app_templates_system/Storyboarding`, packaged template `startup.blend`, `space_view3d.py`, `space_toolsystem_toolbar.py` | Actionable startup-template chooser; 2D Animation, 2D Full Canvas, Storyboarding, and Video Editing workspace compositions; reusable GP Draw Header, Tool Header, tool shelf, Brush Asset Shelf, camera canvas, Dope Sheet Sidebar, and scene-strip Sequencer regions | Presentation, workspace composition, navigation, selection, and edit intents implemented; drawing engine, datablocks, scene evaluation, undo, and persistence caller-owned |
| `scripts/startup/bl_ui/properties_mask_common.py` | Mask Settings, Layers, Active Spline/Point, Animation, Display, Transforms, Tools, and mask menus for clip/mask editing | Implemented through Clip Editor |
| `scripts/startup/bl_ui/properties_data_empty.py` | dynamic Empty Data context with display-as, image-display, depth, visibility, opacity, and image panels | Partial |
| `scripts/startup/bl_ui/properties_data_lattice.py` | dynamic Lattice Data context with resolution/interpolation, outside/vertex-group, animation, and custom-property panels | Partial |
| `scripts/startup/bl_ui/properties_data_metaball.py` | dynamic Metaball Data context with metaball, texture-space, active-element, animation, and custom-property panels | Partial |
| `scripts/startup/bl_ui/properties_data_armature.py` | dynamic Armature Data context with pose, viewport, bone-collection, IK, motion-path, selection-set, animation, and custom-property panels | Partial |
| `space_action`, `space_dopesheet.py`, `space_time.py`, `time_scrub_ui.cc` | Shared immutable Dope/Timeline header state, source menus/popovers, independently clipped Channels/Search/Summary and scrub/window regions, numbered playhead, retained/cullable keylists, isolated current-frame overlay, Action sidebar and playback footer | Presentation and interaction implemented; animation data caller-owned |
| `space_graph.py`, `space_graph.cc`, `graph_draw.cc`, `graph_view.cc`, `graph_select.cc` | `BlenderGraphEditorHeader`, independent searchable Channels/shared View2D Window regions, recursive channel tree, frame/value F-curves, constant/linear/Bezier drawing, handles, extrapolation, cursor/markers/range/normalization, selection/edit transactions, Graph/Drivers sidebars and playback footer | Presentation, navigation, selection, and edit transactions implemented; curve evaluation, modifiers, drivers, undo, and persistence caller-owned |
| `space_text.py` | Utility header, `BlenderTextEditor`, Text/Find sidebar, and reusable line/column/syntax/insert-mode footer | Presentation implemented; document IO/execution caller-owned |
| `space_project.py` | `BlenderProjectEditor` with Navigation, General/Project settings, No Project, and Save Project surfaces | Partial |
| `space_clip.py` | `BlenderClipEditorHeader`, Tracking/Mask and Clip/Graph/Dope branches, menus/state, tracking canvas/sidebar, mask properties, and shared annotation settings | Presentation and interaction implemented; tracking/solving caller-owned |
| `space_spreadsheet.py` | Immutable header state plus left-aligned filterable/sortable table, row selection, numeric alignment, row indices, and hostable horizontal/vertical controllers | Presentation and interaction implemented; data extraction caller-owned |
| `space_console.py` | Python Console utility header, typed line states, prompt, and caller-owned command-history navigation | Presentation and interaction implemented; execution caller-owned |
| `space_info.py` | Info utility header plus severity filtering, row selection, timestamps, dismissal, and notice state | Presentation and interaction implemented; report lifetime caller-owned |

## Editor and pane surfaces

The editor shell maps Blender's area/header/region ownership into a reusable
Flutter composition. The public `BlenderEditorType` catalog currently covers
3D View, Image/UV, node families, Timeline/Dope Sheet/Graph/NLA/Drivers,
Sequencer/Clip, Text/Console/Info, Outliner, Properties, Preferences, File and
Asset Browser, and Spreadsheet. Dedicated bodies live in `editors.dart` and
`non3d_editors.dart`; unsupported data-specific behavior is intentionally
represented with caller-owned descriptors or abstract sample data.

The local `space_*` sources used for the current shell pass are:

- `space_view3d`, `space_image`, `space_node`, `space_action`, `space_graph`,
  `space_nla`, `space_sequencer`, and `space_clip` for editor headers and
  viewport/body geometry.
- `space_outliner/outliner_draw.cc`, `outliner_utils.cc`, and
  `space_outliner.cc` for hierarchy guides, restriction columns, display mode,
  and filter controls.
- `space_filebrowser.py` for the File Browser and Asset Browser header/sidebar
  panel families. The example now exposes source-shaped Directory Path,
  bookmark/filter, library/catalog tree, asset metadata, import, preview, and
  tag surfaces; file operations, asset catalog mutation, and metadata
  persistence remain caller-owned.
- `space_view3d.py`, `space_view3d_sidebar.py`, and
  `space_view3d_toolbar.py` for 3D Viewport N-panel and Tool families. The
  reusable Viewport sidebar now exposes View, View Lock, 3D Cursor,
  Collections, Item/Transform, and Global Transform surfaces.
  `BlenderView3dToolShelf` owns the standard grouped Object Mode tools and
  `BlenderViewportOrientationGizmo` owns the renderer-independent axis overlay.
  The header also
  follows Blender's transform, gizmo, overlay, X-ray, and four-mode shading
  sequence with anchored visual popovers; viewport state, object transforms,
  collections, shading evaluation, and animation operators remain caller-owned.
- `space_node.py`, `node_add_menu_geometry.py`, `node_draw.cc`, and
  `drawnode.cc` for the universal node-editor surface. The reusable editor now
  follows Shader/Geometry/Compositor/Texture header branches, nested Geometry
  Nodes Add categories, typed socket geometry, socket-specific layered Bézier
  links, frames, reroutes, collapsed/muted/selected nodes, warnings, timings,
  named-attribute overlays, floating tools, and active-node sidebar families.
  The canvas owns click/extend/toggle and box-selection gestures, grouped move
  transactions, and optional grid snapping while selected IDs, node-tree
  evaluation, undo, persistence, and operators remain caller-owned.
- `space_image.py` and `space_toolsystem_toolbar.py` for Image/UV Editor header,
  tool, image, view, scope, UV, paint, and mask families. The reusable
  `BlenderImageEditorHeader` owns source-conditioned View/Select/Image/UV menu
  taxonomy, UV modes, snapping, proportional, pin, gizmo, and overlay state.
  `BlenderImageEditorLayout` and `BlenderImageEditorToolShelf` share the 42 px
  toolbar, 240 px sidebar, Paint-only asset shelf, and mode-specific tools
  across Image and UV surfaces. Image loading, paint operations, UV editing,
  scopes, and mask data remain caller-owned.
- `space_sequencer.py` and `space_nla.py` for Sequencer/NLA headers and sidebar
  panel families. The reusable Sequencer sidebar now covers cache, proxy,
  preview/view, safe-area, composition-guide, annotation, strip, action, and
  transform surfaces. Its main header follows the source Sequencer/Preview
  branches with View/Select/Marker/Add/Strip/Image menus, view-mode and scene
  controls, snapping, display/channel, gizmo, and nested overlay families;
  media evaluation, proxy generation, strip operations, and animation data
  remain caller-owned.
- `space_dopesheet.py` and `space_time.py` for Dope Sheet/Action and Timeline
  headers, filters, snapping, and Action sidebar panels. The reusable Dope
  Sheet sidebar now exposes Action, Slot, View, Shape Key, and Custom
  Properties surfaces. Its bottom-editor header follows Blender's conditional
  Timeline versus Action menu families and exposes source-shaped playback,
  auto-keying, playhead snapping, filtering, proportional, and overlay
  popovers; keyframe editing, action datablocks, and playback settings remain
  caller-owned.
- `space_graph.py` for Graph Editor and Drivers headers, curve controls, and
  footer behavior. `BlenderGraphEditorHeader`, immutable state, the shared
  curve editor, Graph/driver-variable sidebars, and playback footer expose the
  source families; curve evaluation, driver execution, and playback remain
  caller-owned.
- `space_text.py` for Text Editor header, footer, Text Properties, and Find &
  Replace panels. The reusable Text Editor sidebar exposes margin, font,
  tab/indentation, search, replacement, and search-option surfaces, while the
  footer exposes cursor, selection, syntax, and insert/overwrite state; text
  datablocks, editing, and search execution remain caller-owned.
- `space_project.py` for the Project editor header, Navigation section,
  General/Project settings, No Project state, and Save Project execution
  area. The example now exposes those visual surfaces; project discovery,
  saving, and filesystem operations remain caller-owned.
- `space_text.py`, `space_console.py`, `space_info.py`, `space_spreadsheet.py`,
  and `space_project.py` also provide the source header-menu inventories used
  by the example utility editor headers. `space_outliner.py` is kept separate:
  its normal View Layer header is represented by the dedicated display-mode,
  filter, and search controls, while its mode-specific branches expose the
  source-shaped DATA API keying-set/keyframe actions, Sequence sync, ID filter
  selectors, Library Overrides view mode, collection creation, and Unused Data
  purge controls. Menu and operator actions remain visual descriptors and
  report through the showcase status surface only.
- `space_clip.py` for Movie Clip Editor tracking, solving, stabilization,
  footage, view, and mask surfaces. The example now follows the source
  Tracking/Mask and Clip/Graph/Dope Sheet header branches with their menu
  families and gizmo/overlay/proportional controls. The existing mask
  properties stay composable with the tracking sidebar; clip loading,
  tracking, solving, and mask operations remain caller-owned.
- `space_spreadsheet.py` for Spreadsheet header filters and the tabular data
  region. The immutable header and table expose Only Selected/query filtering,
  sortable columns, numeric alignment, row selection, row indices, and
  hostable synchronized scroll controllers; data extraction remains
  caller-owned.
- `space_buttons/space_buttons.cc` and `buttons_context.cc` for the
  Properties header, context rail, and panel ownership.
- `space_statusbar.py` and `interface_template_status.cc` for the status-bar
  input-status, report/job, and status-info ordering. `BlenderStatusBar` now
  has an explicit center region, and the showcase places a report banner and
  running-job progress row between the input status and right-aligned status
  info; report lifetime, job polling, and cancellation remain caller-owned.
- `space_topbar.py` for the global Blender application menu and the File, Edit,
  Render, Window, Help, workspace, scene, and view-layer top-bar families. The
  showcase exposes source-ordered menu entries and submenus; command execution,
  workspace mutation, and scene/view-layer ownership remain caller-owned.
- `space_userpref.py` and `userpref_asset_libraries_list.cc` for the
  Preferences navigation bar and source-ordered
  category/panel families. The example now exposes all current preference
  categories, including nested Interface, Editing, Animation, System,
  Viewport, Themes, paths, input/navigation, extensions, add-ons, assets,
  lights, developer, and experimental panels. The Assets category includes
  the selectable built-in, local, and remote Asset Libraries panel;
  preference persistence and runtime settings remain caller-owned.
- `scripts/startup/bl_ui/properties_object.py` for the source-ordered Object
  Properties panel family. The example now covers the nested visual anatomy
  from Transform through Custom Properties, including the linking, motion-path,
  visibility, and line-art child panels; Blender RNA, polling, and operator
  ownership remain caller responsibilities.
- `scripts/startup/bl_ui/properties_render.py` for the Render Properties panel
  family. The hidden-header Render Engine selector remains in the source top
  row, followed by the current Eevee-facing source order and nested
  child panels, while engine polling, preset operators, and renderer settings
  remain caller responsibilities.
- `scripts/startup/bl_ui/properties_output.py` for Output Properties. The
  existing Output context follows the source format, output, post-processing,
  metadata/note/burn, views, color-management, pixel-density, encoding/video,
  audio, and stamp panel order; file writing and codec ownership remain caller
  responsibilities.
- `scripts/startup/bl_ui/properties_scene.py` for the Scene Properties panel
  family. The hidden-header Scene data-block selector is shown above the
  source-ordered scene, units, keying, audio,
  physics, simulation, rigid-body, light-probe, animation, and custom-property
  panels; scene data and operator execution remain caller responsibilities.
- `scripts/startup/bl_ui/properties_world.py` for the World Properties panel
  family. The example covers source-ordered surface, volume, mist, Eevee
  settings, viewport, animation, and custom-property panels, including nested
  sun/shadow settings and the world data-block selector.
- `scripts/startup/bl_ui/properties_data_modifier.py` for the Modifiers
  context and Add Modifier menu families. The example covers the source
  category menus and representative stack/header controls; actual modifier
  RNA panels and object-type polling remain host-owned.
- `scripts/startup/bl_ui/properties_material.py` for the Material Properties
  panel family. The example covers material slots, the active material field,
  source-ordered shader/settings/viewport/line-art panels, the legacy
  Grease Pencil Surface/Stroke/Randomize/Fill hierarchy, and
  animation/custom property rows; node-tree data and material operators remain
  host-owned.
- `scripts/startup/bl_ui/properties_data_mesh.py` for the Mesh Data context.
  The example covers the source-ordered data-block header, Vertex Groups,
  Shape Keys, UV Maps, Color Attributes, Attributes, Texture Space, Remesh,
  Geometry Data, Animation, and Custom Properties panels. Mesh RNA, list
  mutation, and mode-dependent polling remain caller-owned.
- `scripts/startup/bl_ui/properties_data_camera.py` for the dynamic Camera Data
  context. The example follows the selected object and covers Lens,
  Stereoscopy, Camera, Depth of Field/Aperture, Background Images, Viewport
  Display/Composition Guides, Safe Areas, Animation, and Custom Properties;
  camera RNA, image loading, and engine-dependent polling remain caller-owned.
- `scripts/startup/bl_ui/properties_data_light.py` for the dynamic Light Data
  context. The example covers Preview, Light, Shadow, Influence, Custom
  Distance, Beam Shape, Animation, and Custom Properties; light-node data,
  engine-dependent branches, and operator ownership remain caller-owned.
- `scripts/startup/bl_ui/properties_data_curve.py` for the dynamic Curve Data
  context. The example covers Shape, Texture Space, Geometry with Bevel and
  Start & End Mapping children, Path Animation, Animation, and Custom
  Properties. Curve/text subtype polling, spline data, and font ownership
  remain caller-owned.
- `scripts/startup/bl_ui/properties_data_curves.py` for the dynamic Curves
  Data context. The example covers Surface, the source-style Attributes list
  with add/remove actions, Animation, and Custom Properties; surface binding,
  attribute domains, and geometry-node ownership remain caller-owned.
- `scripts/startup/bl_ui/properties_data_pointcloud.py` for the dynamic Point
  Cloud Data context. The example covers the source-style Attributes list with
  radius, color, id, and velocity rows plus add/remove actions and Custom
  Properties; point data and attribute mutation remain caller-owned.
- `scripts/startup/bl_ui/properties_data_speaker.py` for the dynamic Speaker
  Data context. The example covers Sound, Distance, Cone, Animation, and
  Custom Properties; sound loading, playback, and engine polling remain
  caller-owned.
- `scripts/startup/bl_ui/properties_data_volume.py` for the dynamic Volume Data
  context. The example covers OpenVDB File, Grids, Render, Viewport Display
  with Slicing, Animation, and Custom Properties; grid loading, engine
  branches, and volume playback remain caller-owned.
- `scripts/startup/bl_ui/properties_data_lightprobe.py` for the dynamic Light
  Probe Data context. The example covers Probe with nested Visibility, Capture,
  Bake with Resolution/Capture/Offset/Clamping children, Custom Parallax,
  Viewport Display, Animation, and Custom Properties; probe capture, baking,
  engine polling, and light-probe data remain caller-owned.
- `scripts/startup/bl_ui/properties_data_grease_pencil.py` for the dynamic
  Grease Pencil Data context. The example covers Layers with nested Masks,
  Transform, Adjustments, Relations, and Display panels, Onion Skinning with
  Custom Colors/Display children, Settings, Attributes, Animation, and Custom
  Properties; layer trees, stroke data, and drawing operators remain
  caller-owned.
- `scripts/startup/bl_ui/properties_data_bone.py` for the active Bone
  Properties context. The example covers Transform, Bendy Bones, Relations
  with Bone Collections, Viewport Display with Custom Shape, Inverse
  Kinematics, Deform, and Custom Properties; pose/edit mode polling, bone
  transforms, and armature operators remain caller-owned.
- `scripts/startup/bl_ui/properties_data_shaderfx.py` for the ShaderFX
  Properties context. The example covers the source's hidden-header Effects
  panel, Add Effect menu, and stacked Drop Shadow/Colorize effect cards with
  enable, reorder, and remove affordances; shader effect data and operators
  remain caller-owned.
- `scripts/startup/bl_ui/properties_view_layer.py` for the View Layer
  Properties context. The example covers View Layer, Passes with Data, Light,
  Shader AOV, Cryptomatte, and Light Groups children, plus Filter, Override,
  and Custom Properties; view-layer render-pass state and operators remain
  caller-owned.
- `scripts/startup/bl_ui/properties_collection.py` for the Collection
  Properties context. The example covers Visibility with nested View Layer
  flags, Importer, Exporters, Instancing, Line Art, and Custom Properties;
  collection membership, import/export execution, and line-art data remain
  caller-owned.
- `scripts/startup/bl_ui/properties_texture.py` for the Texture Properties
  context. The example covers Preview, Texture/Node, a procedural Clouds type
  panel, Mapping, Influence, Colors with Color Ramp, Animation, and Custom
  Properties; texture slots, procedural evaluation, and node ownership remain
  caller-owned.
- `scripts/startup/bl_ui/properties_constraint.py` for the Object/Bone
  Constraints contexts. The example uses the shared constraint stack for Copy
  Location, Child Of, Follow Path, Limit Rotation, and Armature cards with
  source-style enable, menu, reorder, remove, target, and influence controls;
  constraint evaluation and owner polling remain caller-owned.
- `scripts/startup/bl_ui/properties_physics_common.py` and the physics panel
  families for the Physics context. The example follows the source add-physics
  grid, the complete Cloth panel nesting, and nested Soft Body, Fluid, Dynamic
  Paint, Force Field, Rigid Body, Rigid Body Constraint, and Particle System
  panels. Simulation data, modifier creation, polling, and operators remain
  caller-owned.
- `scripts/startup/bl_ui/properties_physics_geometry_nodes.py` for the
  source-ordered Simulation Nodes panel represented in the Physics context;
  node-group evaluation and simulation state remain caller-owned.
- `scripts/startup/bl_ui/properties_strip.py` and
  `properties_strip_modifier.py` for the Sequencer Strip context. The
  reusable `BlenderStripProperties` follows Crop, Effect Strip and text child
  panels, Source, Movie Clip, Scene, Sound, Mask, Time, adjustment, Transform,
  Video, Color, Custom Properties, and a source-shaped Modifiers section;
  media data, strip evaluation, and modifier operators remain caller-owned.
- `scripts/startup/bl_ui/properties_paint_common.py` is represented in the
  Tool sidebar through the source-shaped Brush Asset panel and its Color
  Palette, Clone, Texture Mask, Stroke, Stabilize Stroke, Falloff, Brush
  Cursor, and Clone Layer child panels. Paint mode state and brush operators
  remain caller-owned.
- `scripts/startup/bl_ui/properties_workspace.py` for the Workspace panel in
  the Tool sidebar. The example now exposes scene pinning, mode and sequencer
  scene controls, scene-time synchronization, the nested Filter Add-ons list,
  and a Custom Properties disclosure; workspace ownership and add-on
  registration remain caller-owned.
- `scripts/startup/bl_ui/properties_freestyle.py` for the Render and View
  Layer Freestyle families. The example adds the source-shaped Render
  Freestyle toggle and line-thickness controls plus the View Layer Freestyle,
  Edge Detection, Style Modules, Line Set, Strokes, Color, Thickness,
  Geometry, and Texture hierarchy; Freestyle engine polling, line-set data,
  and style operators remain caller-owned.
- `scripts/startup/bl_ui/properties_animviz.py` is covered through the existing
  Object and Armature Motion Paths/Display child panels. The shared helper is
  intentionally expressed as host-owned property groups rather than a second
  context.
- `scripts/startup/bl_ui/properties_grease_pencil_common.py` is covered where
  its shared layer/material anatomy feeds the Grease Pencil Data and Material
  surfaces.
- `scripts/startup/bl_ui/properties_mask_common.py` is covered through the
  reusable `BlenderMaskProperties` sidebar, wired into `BlenderClipEditor`.
  It follows the source panel order for Mask Settings, Mask Layers, Active
  Spline, Active Point, Animation, Mask Display, Transforms, and Mask Tools;
  spline editing, tracking, and mask operators remain caller-owned.
- `scripts/startup/bl_ui/properties_data_empty.py` for the dynamic Empty Data
  context. The example covers Empty display type/size, image offsets, depth,
  visibility, opacity, and the conditional Image panel; image loading and
  viewport object ownership remain caller-owned.
- `scripts/startup/bl_ui/properties_data_lattice.py` for the dynamic Lattice
  Data context. The example covers Lattice resolution/interpolation, Outside,
  Vertex Group, Animation, and Custom Properties; lattice point data, shape
  keys, and deformation operators remain caller-owned.
- `scripts/startup/bl_ui/properties_data_metaball.py` for the dynamic Metaball
  Data context. The example covers Metaball, Texture Space, Active Element,
  Animation, and Custom Properties; element selection, meta-ball topology, and
  edit/update polling remain caller-owned.
- `scripts/startup/bl_ui/properties_data_armature.py` for the dynamic Armature
  Data context. The example covers Pose, Viewport Display, Bone Collections,
  Inverse Kinematics, Motion Paths/Display, Selection Sets, Animation, and
  Custom Properties. Bone data, mode polling, and pose/selection operators
  remain caller-owned; the compact Bone Collections columns adapt to narrow
  Properties panes while preserving Blender's status, visibility, and solo
  affordances.
- `space_file`, `space_text`, `space_console`, `space_info`,
  `space_spreadsheet`, and `space_userpref` for the dedicated non-3D bodies.

## Property and template surfaces

The reusable property layer covers vectors, matrices, paths, color ramps,
curve mapping/profile, scopes, attribute search, layers, color management,
modifiers, node inputs, recent files, running jobs, keymaps, previews, and
status/report rows. These map primarily to the `interface_template_*.cc`
files under `editors/interface/templates` and deliberately accept plain Dart
descriptors instead of Blender RNA pointers.

The major shared panel, tree, popover, icon-view, and compact-list anatomies now
have independent descriptor-driven surfaces in `specialized_templates.dart`.
The remaining backlog is narrower: runtime area/region selection and keymap
polling for context-sensitive status rows, richer drag/drop and context-menu
behavior for specialized trees, additional asset preview states, and
data-specific variants whose visual anatomy is not yet represented by a stable
package descriptor.

The corresponding local source references are:

- `interface_template_constraint.cc` for the icon/name/enabled/menu/delete
  constraint header and instanced collapsible panel stack.
- `interface_template_cache_file.cc` for the path/reload row, manual scale,
  time settings, and velocity fields.
- `interface_template_light_linking.cc` for the collection field, tree rows,
  and include/exclude state control.
- `interface_template_grease_pencil_layer_tree.cc` and
  `interface_template_grease_pencil_layer_search.cc` for nested layer/group
  rows, masks/onion-skin/visibility/lock columns, disclosure state, and search.
- `interface_template_shader_fx.cc` for the effect stack's enabled,
  reorder, remove, and collapsible panel treatment.
- `interface_template_node_tree_interface.cc` for nested declaration panels,
  input/output socket dots, active rows, and disclosure state.
- `interface_template_id.cc` for the full data-block field: browse/search,
  rename/value display, New/Open, duplicate and user-count actions, linked or
  overridden state, fake-user retention, and unlink controls. The compact
  header-only Scene/View Layer composition remains `BlenderDataBlockGroup`;
  `BlenderActionSelector` specializes the same anatomy for animation Actions.
- `interface_template_keymap.cc` for the two-column operator-property boxes,
  inactive/unset visual state, nested editor boundary, and per-property unset
  action.
- `wm_operators.cc` for the regular redo popup and explicit property
  confirmation dialog; both package surfaces accept the same property
  descriptors while leaving operator execution, undo, and popup positioning
  to the host.
- `interface_template_operator_property.cc` for collection importer/exporter
  panels: add/remove or reorder controls, active file-handler panels, filepath
  rows, presets/export actions, and caller-owned operator properties.
- `interface_template_color_management.cc` for the vertical split-property
  rows for Color Space, View, Look, Exposure, Gamma, curve mapping, and white
  balance; the package keeps those optional sections caller-owned.
- `interface_template_color_picker.cc` for palette management controls,
  responsive color-swatch rows, selection state, and hue/saturation/value/
  luminance sorting affordances; the compact `BlenderCryptoPicker` covers the
  source-level eyedropper operator button.
- `interface_template_preview.cc` for the large bounded preview surface,
  resize grip, preview render-type controls, preview-world toggle, texture or
  material mode row, and preview-alpha toggle. `BlenderPreviewTile` remains the
  separate grid-tile anatomy used by asset and ID browsers.
- `interface_template_scopes.cc` for histogram, waveform, and vectorscope
  surfaces with Blender's bounded height and bottom resize grip; scope samples
  remain caller-owned.
- `interface_template_recent_files.cc` for the compact filename-only recent
  file rows, `.blend`/backup file icons, and path/metadata tooltip content;
  file existence and metadata remain caller-owned.
- `interface_template_event.cc` for modal keymap/status event composition; the
  package now covers reusable modifier/event/label rows, source-backed
  Shift/Ctrl/Option/Command/Windows glyphs, and compact grouped Axis, Plane,
  and Proportional Size tokens through `BlenderInputStatus`, but not the
  source-level keymap polling that decides when groups collapse.
- `interface_template_status.cc` for status-bar and report content; the
  package now covers the persistent bar, status-info text/version and
  extension states (including blocked, offline, checking, and update states),
  source-backed file-issue warnings/tooltips, report editor, severity-colored
  transient report banner, notice banners, and descriptor-driven
  context-sensitive input-status rows.
  `BlenderStatusContextBar` includes source-defined split/dock, resize,
  header, viewport-warning (including the filled warning glyph), and
  editor-border variants; Blender's runtime area/region selection still
  remains caller-owned.
- `interface_template_icon.cc` for icon-backed enum choices; `BlenderIconView`
  preserves the selected icon trigger, eight-column popup grid, optional
  labels, and selected/disabled tile states.
- `interface_template_search.cc` and `interface_template_search_menu.cc` for
  searchable collection/operator menus; `BlenderSearchMenu` now preserves both
  the compact list and preview-grid forms, including filtered results and
  thumbnail tiles. Application-wide Menu Search is separately represented by
  `BlenderMenuSearch` and `BlenderCommandRegistry.search`, including nested
  menu ancestry, fuzzy multi-token ranking, recent use, command enablement,
  keyboard navigation, execution, and the F3 application binding.
- `interface_template_bone_collection_tree.cc` for nested collection rows,
  active/selected-bone markers, visibility and solo columns, disclosure state,
  and optional remove actions.
- `interface_template_asset_shelf_popover.cc` for the large non-header and
  compact header trigger variants, scaled preview grid, selection state, and
  popover sizing.
- `interface_template_component_menu.cc` for the expanded component choice
  row used in popup blocks.
- `interface_template_list.cc` for the compact current-item, count, and
  previous/next navigation layout; the default list rows remain covered by
  `BlenderListView`.
- `space_file/file_panels.cc` for the file selector's filename/overwrite
  execution row, active operator-property pane, and asset-library/catalog side
  panel. The package now covers those visual panes with caller-owned
  descriptors, including the source-defined `All` and `Unassigned` rows,
  catalog hover-add affordance, drop-target marker, and catalog context-menu
  slots; Blender's operator RNA property population, drag/drop execution, and
  asset-library polling remain outside the package.
- `space_userpref/userpref_asset_libraries_list.cc` for the Preferences asset
  library list: built-in/custom rows, local/remote icons, enabled/error
  indicators, add/remove controls, and selected-library path, URL, default
  import-method, and relative-path settings. The package follows Blender's
  fixed Built-In rows, source labels (`Repository URL`, `Import Method`, and
  `Use Relative Path`), disabled fixed-row removal, and online-essentials
  enablement; runtime preference storage and library polling remain caller-owned.
- `space_buttons/buttons_texture.cc` for texture-user context selection and
  the adjacent jump-to-Texture-Properties button. The package now covers the
  source/category selector, closed-button user label, grouped menu headers,
  texture-name menu entries, and source visibility when the texture is missing
  or the Texture Properties context is already active;
  Blender's texture-user discovery and Properties context switching remain
  outside the visual layer.
- `interface_template_running_jobs.cc` for the header/status running-jobs
  strip. `BlenderJobProgress` covers the source progress tooltip, optional
  operation icon, active/canceling state, and stop action; `BlenderRunningJobsPanel`
  adds the animation-player stop row and remote asset-download progress row.
  Job discovery, timing calculation, cancellation ownership, and interface-lock
  state remain caller-owned.
- `space_time.py` and `space_dopesheet.py` for Timeline/Action header menus,
  playback, filter, snapping, overlay, and proportional-edit popovers. The
  example now covers those source-defined controls; animation data, keying
  operators, and editor polling remain caller-owned.
- `rna_keymap_ui.py`, `space_userpref.py`, `DNA_windowmanager_types.h`, and
  `wm_keymap.cc` for Preferences key configurations and runtime event matching.
  The package now shares one context-aware command-binding service between
  dispatch and Preferences; covers active, repeat, modified/default,
  user-defined, conflict, restore, Name/Key-Binding filter, capture, and
  versioned JSON boundaries. Flutter keyboard chords are dispatched directly;
  Blender modal maps, pointer/NDOF events, operator RNA properties, and preset
  file I/O remain host/editor integrations.

The remaining source-driven backlog should be added as independent
descriptor-driven templates when the corresponding visual anatomy is mapped,
without coupling the package to Blender source or data structures.

## Verification notes

- `flutter analyze` passes for the package and example.
- Package widget and service suite passes with 170 tests; the example smoke and
  golden suite passes with 70 tests.
- The Flutter SDK can emit non-fatal SVG parser warnings for the existing
  custom glyph test fixtures.
- The configured Flutter/Dart tools may need permission to update SDK cache
  files outside this workspace before verification can run.
