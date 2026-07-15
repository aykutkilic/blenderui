# Blender UI coverage map

Reference snapshot: local Blender checkout,
`main` at `68bdd158cc49af6191f0d9480510f4c5214f2df5`.

This is a clean-room visual coverage map, not a claim that the Flutter
package implements Blender's data model or operator behavior. The source
paths identify the Blender surfaces that determine geometry, density, state
appearance, and composition.

## Shared interface surfaces

| Blender source family | Package surface | Status |
| --- | --- | --- |
| `interface_layout.cc` | `BlenderBox`, `BlenderFlow`, `BlenderGrid`, `BlenderOverlap`, `BlenderPanel`, `BlenderRegion`, `BlenderSplitter` | Implemented |
| `interface_widgets.cc`, `interface_style.cc` | `BlenderTheme`, controls, property indicators, semantic glyphs | Implemented |
| `interface_region_menu_popup.cc` | `BlenderMenu`, `BlenderDropdown`, `BlenderMenuButton`, `BlenderContextMenu` | Implemented |
| `interface_region_popover.cc` | `BlenderPopover` and anchored template popovers | Implemented |
| `wm_operators.cc` (`wm_block_dialog_create`) | `showBlenderDialog`, `BlenderDialog`, `BlenderAlertDialog` | Implemented |
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
| `interface_template_icon.cc` | `BlenderIcon`, `BlenderIconView`, `BlenderPreviewTile` | Implemented |
| `interface_template_layers.cc` | `BlenderLayerSelector` | Implemented |
| `interface_template_keymap.cc` | `BlenderKeymapItemProperties` | Implemented |
| `interface_template_matrix.cc` | `BlenderMatrixTransformPanel`, `BlenderMatrixField` | Implemented |
| `interface_template_modifiers.cc` | `BlenderModifierStack` | Implemented |
| `interface_template_list.cc` | `BlenderTemplateList`, `BlenderListView`, `BlenderCompactList` | Implemented |
| `interface_template_preview.cc` | `BlenderPreviewPanel` plus `BlenderPreviewTile` | Implemented |
| `interface_template_recent_files.cc` | `BlenderRecentFiles` | Implemented |
| `interface_template_running_jobs.cc` | `BlenderJobProgress` | Implemented |
| `interface_template_scopes.cc` | `BlenderScopeView` | Implemented |
| `interface_template_search.cc`, `interface_template_search_menu.cc` | `BlenderSearchField`, `BlenderSearchMenu` list and preview modes | Implemented |
| `interface_template_search_operator.cc` | `BlenderSearchMenu` | Implemented |
| `interface_template_status.cc` | `BlenderInputStatus`, `BlenderStatusContextBar`, `BlenderStatusBar`, `BlenderStatusInfo`, `BlenderInfoEditor`, `BlenderReportBanner` | Partial |
| `interface_template_strip_modifiers.cc` | `BlenderModifierStack` visual anatomy | Implemented |
| `interface_template_bone_collection_tree.cc` | `BlenderBoneCollectionTree` | Implemented |
| `interface_template_asset_shelf_popover.cc` | `BlenderAssetShelfPopover` | Implemented |
| `interface_template_component_menu.cc` | `BlenderComponentMenu` | Implemented |
| `interface_template_list.cc` (compact layout) | `BlenderCompactList` | Implemented |
| `space_file/file_panels.cc` execution panel | `BlenderFileExecutionPanel` | Implemented |
| `space_file/file_panels.cc` operator panel | `BlenderFileOperatorPanel` | Implemented |
| `space_file/file_panels.cc` asset-catalog panel | `BlenderFileAssetCatalogPanel` | Partial |
| `space_file/file_draw.cc` asset-browser availability hints | `BlenderFileBrowserHint`, `BlenderFileBrowserLibraryPathHint` | Implemented |
| `space_userpref/userpref_asset_libraries_list.cc` | `BlenderAssetLibrariesPreferencesPanel` | Partial |
| `space_buttons/buttons_texture.cc` | `BlenderTextureUserSelector` | Partial |
| `space_buttons/space_buttons.cc`, `space_properties.py`, `interface_layout.cc` | `BlenderPropertiesEditor` panel/property filtering and search-state expansion | Implemented |
| `scripts/startup/bl_ui/properties_object.py` | nested `BlenderPropertyGroup` panels and example Object identity/Transform context | Partial |
| `space_action`, `space_dopesheet.py`, `space_time.py` | `BlenderTimeline`, `BlenderDopeSheetEditor`, example Timeline/Action mode composition | Partial |

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
- `space_buttons/space_buttons.cc` and `buttons_context.cc` for the
  Properties header, context rail, and panel ownership.
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
  extension states, report editor, severity-colored transient report banner,
  notice banners, and descriptor-driven context-sensitive input-status rows.
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
  thumbnail tiles.
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
  remote import filtering and vertical property layout; runtime preference
  storage and library polling remain caller-owned.
- `space_buttons/buttons_texture.cc` for texture-user context selection and
  the adjacent jump-to-Texture-Properties button. The package now covers the
  source/category selector, closed-button user label, grouped menu headers,
  texture-name menu entries, and disabled jump state;
  Blender's texture-user discovery and Properties context switching remain
  outside the visual layer.

The remaining source-driven backlog should be added as independent
descriptor-driven templates when the corresponding visual anatomy is mapped,
without coupling the package to Blender source or data structures.

## Verification notes

- `flutter analyze` passes for the package and example.
- Package widget suite passes with 74 tests; the example smoke suite passes
  with 7 tests.
- The Flutter SDK can emit non-fatal SVG parser warnings for the existing
  custom glyph test fixtures.
- The configured Flutter/Dart tools may need permission to update SDK cache
  files outside this workspace before verification can run.
