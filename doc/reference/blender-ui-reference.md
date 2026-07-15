# Blender UI reference

Reference recorded: 2026-07-14

Current local source reference for the non-3D styling pass:
`../blender` `main` at `68bdd158cc49af6191f0d9480510f4c5214f2df5`.

The implementation uses the Blender `main` source tree as a living reference.
The exact source revision used for each visual update must be recorded in the
development history before implementation work begins. The package must not
copy Blender C/C++ implementation, Blender icons, fonts, logos, screenshots, or
other artwork.

Useful upstream areas include:

- `source/blender/editors/interface/interface_layout.cc` for rows, columns,
  panels, flow/grid layouts, boxes, splits, overlaps, and radial menus.
- `source/blender/editors/interface/interface_widgets.cc` for widget drawing
  and state-specific presentation.
- `source/blender/editors/interface/interface_handlers.cc` for pointer,
  keyboard, modal, and menu interaction behavior.
- `release/datafiles/userdef/userdef_default_theme.c` for semantic Properties,
  panel, sub-panel, tab, and outline colors.
- `source/blender/editors/interface/interface_panel.cc` for top-level versus
  nested panel backdrop composition.
- `source/blender/windowmanager/intern/wm_operator_props.cc` for the five
  Select Box operations and their ordering.
- `source/blender/editors/screen/area.cc` for the four editor-area corner
  action zones.
- `source/blender/editors/screen/screen_ops.cc` for split thresholds,
  dominant-axis selection, docking targets, and tree-changing operations.
- `source/blender/editors/screen/screen_draw.cc` for split, join, and dock
  preview anatomy.

The resulting Dart API is an independent implementation inspired by those
observations. It is unofficial and unaffiliated with Blender.

## Visual principles

- Dark, low-contrast surfaces with restrained borders.
- Dense rows and compact controls optimized for desktop work.
- Clear hover, active, selected, disabled, and focus states.
- Small independent vector glyphs instead of copied Blender icon assets.
- Keyboard and pointer interactions are first-class, not mobile adaptations.

The sample workspace applies these principles in the same major geometry as
Blender's desktop Layout workspace: application menus and workspace tabs span
the top, an area header sits above the main editor, the tool shelf is on the
left, the Outliner sits above Properties on the right, and the Timeline shares
the left/center width rather than extending below the Properties column.
Its editor geometry is stored in a caller-owned split tree: dividers resize
existing areas, while dragging from an area corner previews and commits a split
inside that area or a move/replace dock over another area.

## Current widget categories

The current source groups presentation into regular, label, toggle, checkbox,
radio, number, slider, execution, toolbar, tab, tooltip, name/link/file-name,
menu, icon, preview tile, swatch, color picker, unit-vector, box, scroll,
list-item, progress, node-socket, and view-item styles. The Flutter library
maps these into theme tokens and composable widgets; editor-specific surfaces
remain generic and do not model Blender data.

The default dark palette reference uses a blue active selection (`#4772B3`),
dark menu and text-field surfaces, a `#545454` regular button surface, compact
rounded controls, state colors for animation/keying/drivers/overrides, and
distinct semantic colors for scene, collection, object, data, modifier,
shading, and folder icons.

## Interaction mapping

The current clean-room mapping also covers the dense interaction patterns
around Blender's non-3D editors: selectable list items and view items,
search/filter bars, breadcrumbs, file-browser list/grid modes, selected menu
radio markers, node sockets,
shortcut keycaps, keymap rows, and category-based Preferences sections. These
are implemented as Flutter widgets in `lib/src/collections.dart`,
`lib/src/editors.dart`, and `lib/src/non3d_editors.dart`; they do not depend on
Blender data structures or copied source code.

The template layer in `lib/src/templates.dart` and
`lib/src/property_templates.dart` covers the corresponding curve-mapping,
curve-profile, color-ramp, vector/matrix/path, attribute-search, layer,
color-management, preview, scopes, recent-file, running-job, search-menu,
scrollbar, pie-menu, modifier-stack, and node-input patterns.
`BlenderPopover` uses explicit render-box anchoring so
interactive inspector content remains usable inside the core `WidgetsApp`
route model.

Centered dialogs use the same independently implemented popup surface as
menus and popovers, with Blender's title/message/icon arrangement, compact
action row, modal scrim, and viewport-safe centered placement. The local
source references for this family are `windowmanager/intern/wm_operators.cc`
(`wm_block_dialog_create`, `WM_operator_confirm_ex`, and
`WM_operator_props_dialog_popup`) plus
`editors/interface/regions/interface_region_popup.cc`.

The layout mapping includes dense box, flow, grid, overlap, split, panel,
toolbar, tab, region, scroll, and radial-menu composition. The editor mapping
now has a dedicated surface for every non-3D `BlenderEditorType` value exposed
by the package, including the Info report feed; the sample intentionally uses
abstract 2D/custom-painted data instead of a 3D renderer.

Property rows also expose Blender's decorated-state affordances: animated,
keyed, driven, overridden, and changed indicators, with optional keyframe and
reset actions. Outliner rows support optional visibility and lock columns while
leaving object state and persistence to the caller.
