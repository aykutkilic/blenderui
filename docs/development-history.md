# Development history

## 2026-07-15 — Matched the Object Properties transform context

- Re-read Blender's `properties_object.py` and matched the Object context's
  active-object `template_ID`, active-object caption, Transform property split,
  location/rotation/scale vectors, rotation mode, unlocked decorators, and
  animation dots in the example application.
- Added source-ordered, default-collapsed Object sections. Delta Transform now
  uses a reusable `BlenderPropertyGroup.children` relationship, corresponding
  to Blender's `bl_parent_id`, so it remains inside Transform instead of being
  modeled as an unrelated reorderable top-level panel.
- Extended Properties filtering and expansion reconciliation recursively so
  nested panels remain searchable without losing their stored collapsed state.
  Because the nested content is part of the parent widget, existing measured
  reorder proxies also carry its true expanded height.
- Added the source `DECORATE_UNLOCKED` glyph mapping and optional numeric-field
  suffixes for meters and degrees. The Properties options trigger now uses the
  compact thin down-disclosure glyph rather than the generic filled chevron.
- Added Object-context interaction and golden coverage, then verified all 75
  package tests and all 7 example tests. An initial example test invocation
  from the repository root could not resolve `blender_ui_example`; rerunning
  from the example package root is the correct workspace procedure.

## 2026-07-15 — Matched submenu and Properties context-tab affordances

- Submenu rows now use Blender's thin right-disclosure glyph at 9px. Their
  parent row remains highlighted while the child submenu is open, matching
  Blender's menu navigation state.
- Properties context tabs now resolve icon colors from the shared Blender theme
  categories for scene, object, modifier, and shading contexts. The visible
  tabs control uses the same thin 9px down arrow and is laid out immediately
  after the final visible tab rather than pinned to the rail bottom.
- Added focused regressions for submenu hover persistence and the trailing
  Properties-tab disclosure placement.

## 2026-07-15 — Added Action mode and richer Timeline example data

- Re-read `space_dopesheet.py`, `space_time.py`, and the `space_action`
  sources. Blender treats Timeline as a special Dope Sheet subtype, while
  Action mode adds its mode/data-block selector, channel and key menus, and
  detailed animation channels.
- Added Action as a selectable bottom-editor mode alongside Timeline. Its
  header exposes a `CubeAction` data-block selector plus Channel and Key menus,
  and its body shows summary, location, and rotation channels with example
  keyframes.
- Expanded the Timeline example from Cube/Camera-only data to include the
  scene Light track. The models remain caller-owned, so the added detail does
  not couple the reusable editor widgets to the showcase scene.
- Added an example interaction test that switches from Timeline to Action and
  verifies the scene tracks, Action selector, mode controls, and channel model.

## 2026-07-15 — Connected Blender-style Properties search

- Re-read `space_properties.py`, `space_buttons.cc`, and the block-search path
  in `interface_layout.cc`. Blender places a normal string property between
  flexible header spacers, matches panel and button labels case-insensitively,
  and temporarily opens matching panels without overwriting their stored
  collapsed state.
- Standardized the example search field at six 20px widget units and connected
  its controller to `BlenderPropertiesEditor`. Searches now retain whole
  panels when their title matches, otherwise show only matching property rows
  and hide empty panels.
- Added controlled expansion support to `BlenderPanel` so search results can be
  forced open while the user's stable-ID expansion state remains untouched.
  Filtered reordering also maps visible group IDs back into the complete order
  rather than treating filtered indexes as global indexes.
- Added package and example interaction coverage for filtering, clearing,
  collapsed-state restoration, and the exact 120x20 header-field geometry.
  The in-app preview connection was unavailable in this session, so the
  repository's deterministic 720x700 visual baseline was used instead.

## 2026-07-15 — Matched selection, section, and outline disclosure arrows

- Reused the local Blender `select_*` SVG glyphs for the Tool Properties
  selection-operation controls and kept the group fluid up to Blender's
  compact 190px maximum.
- Standardized section-selection dropdowns and tree-view branch controls on
  Blender's thin `panelDisclosureDown`/`panelDisclosureRight` glyphs instead
  of the larger filled chevrons. Tree disclosures now use stable keys so the
  visual contract can be regression-tested directly.
- Matched the compact editor-type dropdown's down-arrow size to the 9px
  collapsed tree disclosure, removing the larger 11px trigger arrow.
- Applied the same 9px thin disclosure treatment to the Scene and View Layer
  data-block selectors in the top header.
- Reduced the Tool Properties reorder-grip visuals from 13px to the shared 9px
  compact handle size while retaining their full header drag targets.
- Added focused widget coverage for the selection controls and tree disclosure
  anatomy. The implementation intentionally keeps the glyph mapping in the
  shared controls and icon registry so future editors inherit the correction.
- The package suite had already passed before this focused assertion was added;
  a later full rerun reached all arrow tests but stopped in the concurrently
  changing template-controls test because `Location X` was not rendered.
  Focused dropdown and tree regressions pass independently, and the example
  suite passes after its intentional golden refresh.

## 2026-07-15 — Kept expanded panel drag previews at their live height

- Rechecked Blender's panel drag path in `interface_panel.cc`. It moves the
  existing `Panel` object and derives alignment gaps from
  `get_panel_real_size_y()`, so the carried panel and reorder preview always
  share the same live open/closed state and measured height.
- Fixed the Flutter divergence where a panel opened after initial construction
  was measured as expanded in the list, but rebuilt from stale
  `initiallyExpanded` data inside the drag overlay. `BlenderPanel` now reports
  expansion changes, and `BlenderPropertiesEditor` retains that state by group
  ID for both the list item and overlay proxy.
- Corrected descriptor reconciliation so ordinary parent rebuilds no longer
  reopen panels the user collapsed; only newly introduced groups apply their
  initial expansion value.
- Added an expanded, tall-content pointer-drag regression that checks the
  visible proxy height before and after crossing another panel. Analysis also
  exposed a concurrent `BlenderTemplateList` edit missing its local
  `layout.dart` import; the import was restored before verification.

## 2026-07-15 — Added Blender-style Properties panel reordering

- Re-read `interface_panel.cc`: Blender renders `ICON_GRIP` as a compact,
  half-alpha header affordance; during `PANEL_IS_DRAG_DROP`, it moves the
  panel's vertical offset, sorts by the live position, updates
  `Panel.sortorder`, and aligns the panel into its committed slot on release.
- Reduced Properties panel disclosure arrows and reorder grips to 9px. Added a
  dedicated header-handle slot so the generic panel owns only header anatomy,
  while the Properties editor owns ordering and drag behavior.
- Properties groups now reorder from the grip with a moving whole-panel proxy
  and animated insertion gap. The editor retains order by stable group ID
  across descriptor rebuilds and exposes `onGroupOrderChanged` for optional
  caller persistence.
- Kept standalone editor embedding working by supplying a local overlay and
  default widget localization only when the host does not already provide
  them. The first verification exposed both Flutter prerequisites; handling
  them locally avoided imposing a `Navigator` or app shell on package users.
- Added a real pointer-drag regression and refreshed the focused Properties
  visual baseline. During verification, a concurrent `internetOffline` glyph
  lacked its exhaustive fallback-painter switch case; the matching internet
  fallback was added to restore compilation. The full example gate also found
  its new file-browser hint overflowing in short hosts; its card body now
  scrolls within the available height instead of clipping or overflowing.

## 2026-07-15 — Matched Preferences asset-library settings

- Re-read `userpref_asset_libraries_list.cc` and its RNA definitions. The
  source uses disk-drive/internet icons, the `URL` and `Default Import Method`
  labels, vertical property rows, remote-library import filtering, and the
  fixed `All`/`Essentials` built-in entries.
- Added source SVG-backed `internet` and `diskDrive` glyphs, corrected the
  asset-library row identity, added the invalid URL field affordance, expanded
  the import choices, filtered out `Link` for remote libraries, and changed
  the settings layout to match Blender's vertical rows.
- Updated the example and focused regression data to use Blender's built-in
  labels. The state and preference persistence remain caller-owned.

## 2026-07-15 — Matched texture-user closed selector label

- Rechecked `uiTemplateTextureUser` in `buttons_texture.cc`: the closed menu
  button displays the user name, while the pulldown entries append the current
  texture datablock name after `" - "`.
- Added an optional selected-label override to `BlenderDropdown` and used the
  current user name for `BlenderTextureUserSelector`; menu entries retain their
  source-derived texture names and category headers.
- Package analysis and all 64 package tests pass; the example analysis and all
  5 smoke/visual-baseline tests pass. Existing non-fatal SVG parser warnings
  remain unchanged.

## 2026-07-15 — Matched filled 3D-view status warning

- The local `interface_template_status.cc` source uses
  `ICON_STATUS_WARNING_FILLED` for negative and non-uniform active-object
  scale warnings, distinct from the larger general warning icon.
- Added the source SVG-backed `warningFilled` glyph and switched the
  viewport-warning context variant to it; the existing warning glyph remains
  available for general notices.
- The first parallel example verification reported a transient duplicate
  `ids` declaration from the incremental compiler; the current source had one
  declaration and package analysis was clean. A serial `--update-goldens`
  rerun passed all five example tests and recorded the intended 0.45% warning
  glyph pixel delta.

## 2026-07-15 — Added asset-browser availability hint cards

- Audited `file_draw.cc` and found centered round-box states for missing online
  access and failed remote asset-library downloads. These are distinct from
  the file selector's operator panels and use multiline explanatory text plus
  optional action buttons.
- Added `BlenderFileBrowserHint` and `BlenderFileBrowserHintAction`, with
  source-backed `internetOffline` and `errorFilled` glyphs. The showcase now
  displays the exact “Internet Access Required” state with caller-owned
  “Continue Offline” and “Allow Online Access” actions; remote failure cards
  use the same component without actions.
- Added `BlenderFileBrowserLibraryPathHint` for the source's top-left
  “Path to asset library does not exist” state, including the info message and
  Preferences action.
- Added focused widget regressions for both centered availability cards and
  invalid local-library paths. Package analysis and all 66 package tests
  pass; the example analysis and all 5 smoke/visual-baseline tests pass.
- The initial 220px showcase slot overflowed by 38px because the source
  message wraps with two action buttons; increasing that demo slot to 270px
  removed the overflow, and the example golden was regenerated successfully.

## 2026-07-15 — Matched template-list filter anatomy

- Compared `interface_template_list.cc` with the reusable list surfaces. The
  default Blender list includes a bordered list box, a filter disclosure row,
  a resize grip, and—when expanded—a search field plus invert, alphabetical,
  and ascending/descending sort toggles. Sort controls disappear when sorting
  is locked.
- Added `BlenderTemplateList` and expanded `BlenderFilterBar` with the source
  glyphs and toggle states. Filtering and sorting remain caller-owned, while
  the widget preserves the complete visual composition.
- Added a focused regression. Package analysis and all 68 package tests pass;
  the example analysis and all 5 smoke/visual-baseline tests remain clean.
- The showcase selector assertion now checks the keyed operation group and its
  fixed-height responsive bounds instead of requiring a width that can exceed
  a narrow Properties region.
- Its icon assertions are scoped to that keyed group as well, avoiding
  collisions with the same selection glyphs in the neighboring tool shelf.

## 2026-07-15 — Matched matrix transform decomposition

- Re-read `interface_template_matrix.cc` and found that Blender's matrix
  template decomposes a 4x4 matrix into boxed Location, Rotation, Mode, and
  Scale rows; it is not the raw editable matrix grid represented by the
  existing generic `BlenderMatrixField`.
- Added `BlenderMatrixTransformValues` and `BlenderMatrixTransformPanel` with
  Euler, Quaternion, and Axis Angle row variants, a rotation-mode dropdown,
  fixed-precision decomposition labels, and the source `Matrix has a shear`
  warning. The existing raw matrix field remains available for generic data.
- Added the decomposition to the showcase and focused regression coverage;
  caller-owned matrix decomposition and mode changes remain non-functional.
  Package analysis and all 71 package tests pass; the example analysis and all
  6 smoke/visual-baseline tests pass.

## 2026-07-15 — Matched status-bar modifier glyph anatomy

- Re-read `interface_template_event.cc` and `interface_template_status.cc`.
  Blender renders split/dock modifier actions with dedicated Shift/Ctrl event
  icons followed by mouse-drag icons; these are not boxed text keycaps.
- Added source-backed key glyphs and optional modifier/event glyph lists to
  `BlenderInputStatusItem`. Existing string fields remain as a compatibility
  fallback for callers without Blender event metadata, while the built-in
  split/dock contexts now use the source glyphs.
- Runtime keymap polling and the source's conditional axis/plane collapse
  remain caller-owned; the visual descriptor can now represent the resulting
  grouped rows without coupling to Blender's window-manager types.
- Package analysis and all 71 package tests pass; the example suite and its 6
  smoke/visual-baseline tests pass without golden changes. The final example
  invocation briefly waited for Flutter's startup lock, then completed
  successfully; the existing non-fatal SVG parser warnings remain unchanged.

## 2026-07-15 — Matched Color Management property-row composition

- Re-read `interface_template_color_management.cc`: Blender draws Color Space,
  View, Look, Exposure, Gamma, curve-mapping, and white-balance controls as
  vertical split-property rows. Temperature and Tint also remain separate rows
  when white balance is enabled.
- Replaced the app's side-by-side Exposure/Gamma and Temperature/Tint groups
  with reusable `BlenderPropertyRow` composition. Checkbox labels now live in
  the split label column, matching Blender's property layout while preserving
  the existing immutable settings and callback API.
- Package analysis and all 71 package tests pass; the example analysis and all
  6 smoke/visual-baseline tests pass without golden changes.

## 2026-07-15 — Matched cache-file conditional property rows

- Re-read `interface_template_cache_file.cc`. Blender keeps the filepath and
  reload affordance in a split row, combines `Override Frame` with its frame
  value, and disables `Frame Offset` when `Is Sequence` is enabled.
- Updated `BlenderCacheFilePanel` to use the shared split-property row, expose
  the filepath label, keep the override checkbox and frame field together, and
  propagate the sequence-dependent disabled state to Frame Offset.
- Added a focused regression for the disabled frame fields. Package analysis
  and all 72 package tests pass; the example suite and all 6 visual-baseline
  tests pass without golden changes. Dart formatting caught a nested filepath
  row delimiter typo during the edit; it was corrected before analysis.

## 2026-07-15 — Matched scope resize anatomy

- Re-read `interface_template_scopes.cc`: Histogram, Waveform, and Vectorscope
  all use a bounded persisted height and a bottom `ICON_GRIP` resize control.
- Converted `BlenderScopeView` to a stateful bounded surface with configurable
  minimum/maximum height and a source-backed grip; the scope painter and
  caller-owned samples remain unchanged.
- Added a drag regression. During verification, a concurrent submenu test's
  unsupported `WidgetTester.hover` call was migrated to a supported mouse
  `TestGesture`, and accidental test-file delimiter edits were restored before
  formatting. Package analysis and all 74 package tests pass; the example
  analysis and all 7 smoke/visual-baseline tests pass after refreshing the
  intentional Properties-rail baseline.

## 2026-07-15 — Matched Recent Files row and tooltip anatomy

- Re-read `interface_template_recent_files.cc`. Blender displays each recent
  entry as a compact filename-only operator row with a `.blend` or backup file
  icon; directory, version, modified time, and size are supplied by the
  tooltip rather than a second visible text line.
- Added source-backed `fileBlend` and `fileBackup` glyphs and changed
  `BlenderRecentFiles` to keep path/details in a tooltip while deriving backup
  icon state from the descriptor or `.blendN` path suffix. Selection and clear
  callbacks remain unchanged.
- Extended the regression for both file icon variants and hidden path text.
  The showcase workspace, Output Properties, and Object Properties baselines
  were refreshed for the intentional row/icon change. Package analysis and
  all 74 package tests pass; the example analysis and all 7 tests pass.

## 2026-07-15 — Matched selector and Properties-tab states

- Reduced pane-section chevrons to 11px after comparing their rendered bounds
  with Blender's panel headers; the source-specific arrow assets remain
  unchanged.
- Added a reusable menu-trigger button state for editor-type selectors:
  `wcol_menu`-style `#282828` at rest, a translucent `#4772B3` while the
  popover is open, and Blender's `downarrow_hlt.svg` instead of a filled
  disclosure triangle.
- Changed selected/hovered Properties tabs from the raised `#3D3D3D` surface
  to Blender's `wcol_tab.inner_sel` value, `#303030`. The selected tile keeps
  its flat content-side edge, one-pixel dark edging, and the tab groups now
  receive a very small one-pixel shadow.
- The first selector-state test used a bare widget harness and could not open
  the route-backed popover because no `Navigator` existed. The regression was
  moved into the app harness and now verifies the trigger variant, arrow, and
  open/selected state.

## 2026-07-15 — Asset catalog tree special rows and affordances

- Compared `asset_catalog_tree_view.cc` with the file-browser catalog pane:
  Blender always adds an expanded `All` root and an `Unassigned` row, shows a
  catalog-add operator on hover, and exposes `New Catalog`, `Delete Catalog`,
  and `Rename` in the catalog context menu.
- Added those persistent rows to `BlenderFileAssetCatalogPanel`, plus
  caller-owned catalog context-menu callbacks. Extended `BlenderTree` with
  source-shaped hover action buttons, drop-target borders/hints, and context
  menu builders so the same anatomy can be reused by other specialized trees.
- Kept catalog drag/drop, rename persistence, and asset-library discovery
  outside the package. The example now exercises the add and context-menu
  callback seams, and the file-browser regression checks both special rows.
- Package analysis and all 64 package tests pass; the example analysis and all
  4 example smoke tests pass. Existing non-fatal SVG parser warnings remain
  unchanged.

## 2026-07-15 — Corrected panel icon identity and joined-pane margins

- Rechecked Blender's `interface_panel.cc` after the first size-only pass and
  found that panel headers use `ICON_RIGHTARROW` / `ICON_DOWNARROW_HLT`, backed
  by `rightarrow.svg` and `downarrow_hlt.svg`. The similarly named
  `disclosure_tri_*` assets are filled wedges and were the wrong visual family.
- Added panel-specific disclosure glyphs so dropdowns and other controls keep
  their existing triangle behavior while pane sections use Blender's narrow
  chevrons.
- Restored a 10px `UI_PANEL_MARGIN_X`-style inset for the context caption,
  optional top content, and section cards even when the Properties editor is
  joined to its tab rail. Joining now suppresses only the duplicate frame seam.
- Reduced the inter-section margin from 4px to 2px to match
  `UI_PANEL_MARGIN_Y`, and tightened action/drag-handle spacing for very narrow
  panes. A focused geometry assertion now protects the joined-pane inset.

## 2026-07-15 — Matched panel disclosure metrics

- Compared the section rows with Blender's `interface_panel.cc` and
  `interface_style.cc`: Blender panel titles use the 11px `paneltitle` style,
  while the app had been using the larger 13px body style.
- The initial pass retained Blender's local disclosure triangle SVGs, reduced
  their rendered size, and tightened the disclosure-to-title gap. A subsequent
  source audit showed that the panel renderer uses a different arrow family
  and smaller inter-panel margin; the correction is recorded above.
- Added the reusable `panelTitle` text token and refreshed focused/package
  and example visual baselines.

## 2026-07-15 — Closed the Properties header seam

- Removed the Properties area header's bottom outline so its search/header
  surface flows directly into the borderless, square-topped Properties body.
- At this stage the collapsible glyph was enlarged as a filled triangle. That
  size-only treatment was later superseded by the panel-specific chevrons
  documented above.
- Added a keyed regression for the header border state and refreshed the
  package/example visual baselines.

## 2026-07-15 — Flattened the Properties editor top edge

- Traced the dark horizontal seam above the Properties caption to the generic
  `BlenderEditorFrame` top outline being drawn in addition to the editor/header
  boundary.
- Added explicit `showTopBorder` and `squareTopCorners` frame options and
  disabled/squared only the top edge for `BlenderPropertiesEditor`; the side,
  bottom, and optional navigation-rail seams remain unchanged.
- Added a focused assertion and refreshed the package/example goldens. The
  package suite passes 59 tests and the example suite passes 4 tests.

## 2026-07-15 — Output Properties panel anatomy

- Compared the Output Properties implementation with the local Blender source
  in `scripts/startup/bl_ui/properties_output.py` and the interface panel
  layout/drawing code. The existing theme colors already match Blender's
  default `panel_header`, `panel_back`, `panel_sub_back`, and `panel_outline`
  values, so the fix kept those values and corrected composition instead of
  adding a second theme layer.
- Restored the Output context caption as the selected Properties context
  (icon plus `Output` title), rather than reusing Output sections under other
  context tabs. Format, Frame Range, Stereoscopy, and Output now follow the
  source panel expansion states and spacing; Stereoscopy exposes its header
  checkbox.
- Added the Format preset header action and anchored preset menu, including
  Blender's source `preset.svg` icon and the standard resolution preset names.
  The new `BlenderGlyph.preset` keeps the local SVG resolver and a clean-room
  painter fallback in sync.
- Added a focused example golden and interaction regression for the Output
  context, preset popover, and header checkbox lookup. Package analysis is
  clean; all 58 package tests and all 4 example tests pass. Flutter emitted
  only the existing harmless SVG warnings for unsupported `sodipodi` and
  `defs` elements.

## 2026-07-15 — Header scrollbar visibility correction

- Traced the gray strip under the sample's top workspace header to Flutter's
  desktop `ScrollBehavior`, which automatically decorates horizontal
  `SingleChildScrollView` instances with a `RawScrollbar`.
- Disabled only that automatic decoration for `BlenderToolbar`,
  `BlenderAreaHeader`, and `BlenderTabBar`. Header content remains horizontally
  scrollable by trackpad or gesture, while explicit `BlenderScrollbar` instances
  in editor bodies keep their intended visible thumb.
- Added a regression test covering the desktop header-scroll configuration.
- While verifying, restored a misplaced editor-type-menu `build` body and the
  splitter drag-surface wrapper that were preventing the existing source from
  compiling and its splitter regression from running.

## 2026-07-14 — Corrected boolean property-row composition

- Traced the detached checkbox labels in the Output Properties panel to the
  generic two-column row implementation.
- Matched Blender's `UILayout.prop()` exception for booleans: the checkbox and
  its label now remain together in the 60% value column, while numeric, enum,
  and text properties retain the standard 40/60 label/value split.
- Split property-row composition into focused label and value-column widgets
  and added geometry and visual regression tests for the responsive layout.
- Made built-in checkbox and radio labels flexible and ellipsis-safe after the
  full example interaction test exposed a narrow-column overflow.
- Verification initially waited on the Flutter startup lock held by the active
  sample app. The app was left running; tests were executed with Flutter's
  existing-lock flag instead of terminating the user's preview process.
- Final verification: package and example analysis are clean; all 48 package
  tests and all 3 example tests pass.

## 2026-07-14 — Removed Properties rail gutter

- Matched Blender's context-tab geometry by making the default tab tile fill
  the 36px navigation rail. The previous 28px tile left an unintended dark
  seam between the rail and the Properties content.
- Kept `tileSize` configurable for custom rails and added a geometry regression
  test for the default attached layout.
- Removed the final content-edge inset and rounded only the tile's outer
  corners; the right edge now meets the editor without a gap or a rounded cap.

## 2026-07-15 — Stabilized splitter resize cursors

- Kept the active horizontal or vertical resize cursor on the entire splitter
  surface while dragging. The divider itself moves during relayout, so letting
  its small `MouseRegion` own the cursor caused pointer-type flicker as it
  passed out from underneath the pointer.
- The cursor now returns to normal on pointer-up or drag cancellation, with a
  regression test covering movement across the moving divider.

## 2026-07-15 — Restored Tool Properties panel margin

- Traced the flush-left Select Box panels to the specialized Tool body
  bypassing `BlenderPropertiesEditor`'s normal list padding.
- Restored Blender's `UI_PANEL_MARGIN_X` equivalent as a 10px horizontal inset
  around the Tool panels, without shifting the editor context caption.
- Focused rail, boolean-row, and Properties golden tests pass, as do all 3
  example tests. A full package run still exposes an unrelated existing
  icon-preview test lookup failure (`BlenderButton` no longer opens the
  expected Collection popup); the rail change does not touch that code path.

## 2026-07-14 — Local Blender icon source

- Added a desktop-only development resolver for the local Blender checkout's
  `release/datafiles/icons_svg` directory, with environment-variable and API
  overrides for non-standard checkout locations.
- Kept the existing clean-room painter as the per-glyph fallback, so missing
  source files, unsupported platforms, and published builds remain portable.
- Added `flutter_svg` only for reading source SVGs at development time; no
  Blender assets were copied or bundled.
- The first focused widget-test run exposed an unexpected `isImage` semantics
  flag from source SVG widgets; decorative source icons now explicitly exclude
  themselves from semantics to preserve the existing control contract.
- Flutter/Dart verification required access to the local Flutter SDK cache
  outside the repository after the sandboxed attempt hit `Operation not
  permitted`; dependency resolution, formatting, analysis, and tests then ran
  successfully.
- Audited the available source names against Blender's `UI_icons.hh` and the
  toolbar definitions. Shared glyphs now use Blender's matching disclosure,
  add/remove, search, grip, time, file, fullscreen, and interaction SVGs;
  tool-shelf descriptors no longer use object/datablock icons for selection
  tools. Blender's generated `ops.*` toolbar geometry is absent from this
  checkout, so only those genuinely unavailable tool-specific shapes retain
  the package fallback.
- While exercising the corrected source icons at the example's deliberately
  narrow test width, made the compact tool headers and color swatch label
  ellipsis-safe instead of allowing icon-plus-label rows to overflow.
- Fixed the real macOS example path: sandboxed debug apps could not read the
  sibling Blender checkout even though VM tests could. Discovery now walks the
  built executable's ancestors, and only the example's debug entitlement is
  unsandboxed for local source access; release behavior remains fallback-safe.

## 2026-07-13 — Initial package foundation

- Started the repository as a new public Flutter package named `blender_ui`.
- Chose Flutter 3.41+ core primitives, a single package, and a layered widget
  plus dense-renderer architecture.
- Chose a clean-room Blender-inspired implementation with MIT licensing.
- Recorded Blender UI layout, widget, and event-handling source areas as
  references without copying their implementation or assets.
- The local Flutter checkout is on a beta branch and still exposes Material and
  Cupertino inside the framework. The Flutter version command could not finish
  in the restricted environment because the Flutter tool attempted to update
  SDK cache files outside the writable workspace.

## 2026-07-13 — Verification

- Flutter dependency resolution completed after allowing the Flutter tool to
  update its SDK cache.
- `flutter analyze` passed for the package and the example application.
- `flutter test` passed all five package widget tests.
- Direct Dart formatting succeeded; the Dart telemetry write remains blocked by
  the environment, but it does not affect formatted source or package output.

## 2026-07-13 — Desktop sample workspace

- Expanded `example/` into a runnable Blender-like desktop workspace with a
  top toolbar, tool shelf, outliner, abstract viewport, properties editor,
  timeline, and shader-node editor.
- Added macOS, Windows, and Linux runner projects so the sample can be used as
  a real desktop interaction harness rather than only as a widget-test fixture.
- Kept the viewport deliberately abstract: the sample exercises editor layout,
  dense controls, resizing, selection, context menus, and node dragging
  without introducing a 3D renderer into the UI-library test surface.
- The first sample smoke test exposed a missing core `WidgetsApp` route
  builder, generic property callback type erasure, narrow disclosure-button and
  toolbar overflows, incomplete slider semantics, and shared primary scroll
  controllers. Each was fixed in the reusable library code and the sample now
  passes its analyzer and widget test.

## 2026-07-13 — Blender widget fidelity pass

- Referenced Blender `main` at `e0bffa0a9a3bdc0440d700b1996841a600de0109`,
  including `interface_widgets.cc`, `interface_layout.cc`, the interface
  headers, `DNA_theme_types.h`, and `userdef_default_theme.c`.
- Reworked the default theme around Blender's current category palette:
  blue active selection, dark menu/text-field surfaces, `#545454` regular
  controls, compact density, panel/editor borders, axis colors, semantic icon
  colors, and animation/keying/driver state colors.
- Added control variants, segmented controls, disclosure controls, color
  swatches/fields, an HSV/RGB color picker, progress bars, separators, shortcut
  keycaps, and property state indicators.
- Added reusable editor headers, editor-type selection, breadcrumbs, status
  bars, tool shelves, and non-3D editor surfaces for console, text, image,
  spreadsheet, and assets.
- Added the vertical Properties tab rail and compact timeline playback control
  group to the sample and public widget API.
- Changed dropdown menus from centered dialogs to anchored overlay popovers,
  and made timeline input use its actual rendered width instead of a fixed
  coordinate assumption.
- A temporary source checkout encountered a missing optional Git-LFS font
  object while materializing theme data; the source-only checkout continued
  with `GIT_LFS_SKIP_SMUDGE=1`, and no Blender assets were copied into this
  package.

## 2026-07-13 — Collection and editor interaction pass

- Added lifecycle-safe selectable list primitives and a reusable filter bar
  with search, clear, filter, and sort affordances.
- Expanded the file-browser surface with breadcrumbs, list/grid presentation,
  selection and activation callbacks, and query filtering.
- Added first-class node socket definitions and compact input/output port rows
  to the generic node editor.
- Added reusable keymap and Preferences editor surfaces so dense shortcut
  tables and category-based settings can be composed without Material widgets.
- Extended the sample harness with a file-browser editor mode, visible node
  sockets, and a bottom Keymap tab. Added focused tests for list activation,
  file filtering, and socket rendering.

## 2026-07-13 — Template and editor coverage expansion

- Added reusable Blender template controls for vector fields, path fields,
  preview tiles, color ramps, curve mapping, narrow scrollbars, searchable
  operator menus, pie menus, and interactive anchored popovers.
- Added dedicated non-3D editor surfaces for UV editing, Dope Sheet, Graph
  Editor, NLA, Video Sequencer, Movie Clip tracking, and Preferences instead
  of routing those editor types to a generic placeholder.
- Integrated property animation/keying state indicators into property rows and
  exposed the corresponding descriptor state in the public model.
- The popover implementation was verified against a tight core `WidgetsApp`
  route: a render-proxy anchor preserves the trigger's natural size while the
  dialog route supplies finite popup geometry.

## 2026-07-13 — Widget category completion pass

- Added alpha-aware color-picker fields and corrected channel edits to use the
  current picker color rather than a stale parent value.
- Added unit-vector, icon-label/link, operator-button, notice-banner, and
  Blender-style box/flow/grid/overlap layout primitives.
- Added Outliner visibility and lock columns with caller-owned callbacks,
  completing the main scene-tree affordances used by the sample.
- Re-ran package and sample analysis/tests after each interaction change; the
  final package suite contains 19 passing widget tests and the sample smoke
  test passes.
- Upgraded the Image Editor from a static checker surface to a bounded
  pan/zoom canvas with reset and fit-view header affordances.
- Added an Info editor with severity-aware reports and a sample report feed.

## 2026-07-13 — Control catalog and template interaction pass

- Corrected color-picker channel and swatch readouts to use the current local
  HSV state before the parent rebuilds.
- Added draggable color-ramp stops plus optional caller-owned add/remove
  actions, matching the editable template behavior used by Blender's property
  panels.
- Added a scrollable UI Catalog tab to the desktop sample so the dense core
  controls and template widgets can be exercised without switching editors.
- Added focus-border styling to text fields and exported the state/property
  builder typedefs needed for custom control integrations.
- Added reusable anchored pulldown menu buttons and replaced the sample's
  top-bar and area-menu click placeholders with real menu surfaces.
- Added selected-item markers to the shared menu model and made dropdowns
  derive their current selection automatically.
- Added the matrix field template and dedicated pointer-link glyph after
  comparing the API against Blender's interface template and widget-style
  inventories.
- Added data-oriented waveform, histogram, and vectorscope surfaces for the
  Image/Compositor template family.
- Fixed titled panels inside vertical scroll views to avoid flex children under
  unbounded height constraints; the sample smoke test caught this regression
  immediately after the scope catalog integration.
- A first test command used an incorrect local Flutter path; the same package
  suite was rerun with the configured SDK path and passed.

## 2026-07-14 — Status-template coverage pass

- Added the recent-files template used by Blender's file and splash menus,
  including empty-state, file metadata, clear, and selection behavior.
- Added a data-only running-job row with Blender-style icon, percentage,
  canceling state, progress bar, and caller-owned cancellation callback.
- Integrated both templates into the sample UI Catalog so file and status
  surfaces can be exercised without a 3D renderer.
- Rechecked the clean-room mapping against Blender's
  `interface_template_recent_files.cc` and
  `interface_template_running_jobs.cc`; the package remains independent of
  Blender source and assets.
- The package analyzer and 22 focused widget tests pass. The example analyzer
  and desktop smoke test also pass. Dart formatting succeeded; the SDK emitted
  its known non-blocking telemetry-session permission warning outside the
  workspace.

## 2026-07-14 — Property-template coverage pass

- Added `BlenderAttributeSearch` with domain/name/type filtering, existing
  attribute selection, clear behavior, and caller-owned attribute creation.
- Added grouped `BlenderLayerSelector` controls with active/used states and
  shift-click multi-selection behavior based on Flutter's hardware keyboard
  state.
- Added immutable color-management settings and a composable template for
  color space, view transform, look, exposure, gamma, curve mapping, and
  white-balance controls.
- Added an editable curve-profile template with preset menus, reset behavior,
  selected points, and bounded zoom controls.
- Kept the new property templates in their own source layer so they compose
  existing controls without coupling the library to Blender data structures.
- Integrated every new template into the sample UI Catalog and added focused
  package tests for selection and rendering behavior.

## 2026-07-14 — Modifier and node-input template pass

- Added descriptor-driven modifier stacks with collapsible Blender-style
  panels and caller-owned enable, viewport, render, reorder, and remove
  actions.
- Added grouped node-input panels that distinguish editable socket controls
  from linked inputs and preserve the compact property-row treatment.
- Integrated both templates into the sample UI Catalog and added a focused
  render test.
- The package analyzer and 26 focused widget tests pass; the example analyzer
  and smoke test pass as well. The original constant-expression diagnostic was
  traced to a missing `templates.dart` import in the new editor-template layer,
  then verified cleanly in both package and example targets.

## 2026-07-14 — Reference-driven sample shell pass

- Reworked the sample application bar to use Blender's menu order and
  workspace-tab treatment: File, Edit, Render, Window, Help, then Layout,
  Modeling, Sculpting, UV Editing, Texture Paint, Shading, Animation,
  Rendering, Compositing, and Geometry Nodes.
- Reshaped the desktop shell so the left tool shelf and center editor own the
  bottom Timeline, while the right column keeps its full-height Outliner-over-
  Properties split like the reference Layout workspace.
- Added compact editor-type selection, a separate Object Mode selector, area
  menus, Scene selection, pin/save/operator actions, and Outliner/Properties
  search affordances.
- Added top-bar styling and responsive horizontal toolbar behavior; numeric
  fields now accept compact widths so the catalog remains usable in narrow
  desktop windows without Flex overflow.
- Updated the sample smoke test to exercise the editor menu and open the UI
  Catalog from the Blender-like bottom editor selector.
- Package analysis and 26 widget tests pass; example analysis and smoke test
  pass. The SDK's Dart formatter still emits its known telemetry-session
  permission warning outside the workspace after formatting succeeds.

## 2026-07-14 — Reference shell alignment follow-up

- Moved the sample's area header above the combined tool-shelf and viewport
  region so the editor selector begins at the left edge, matching Blender's
  area ownership model.
- Tuned the sample shell to a compact desktop composition with a 30 px
  application bar, 30 px area header, 235 px right column, and 90 px bottom
  editor region; the right column remains full height while the Timeline spans
  only the left and center editors.
- Added viewport-safe clamping to anchored popovers, allowing pulldown menus
  opened from the compact bottom editor header to remain inside the visible
  route instead of rendering below the window.
- Changed the narrow Quick Controls shortcut row to wrap rather than produce a
  RenderFlex overflow at the sample test size.
- Re-ran package and example analysis, all 26 package widget tests, and the
  example smoke test successfully.

## 2026-07-14 — Properties tab rail seam alignment

- Removed the top inset from the attached Properties context-tab rail so its
  first tab begins on the same plane as the editor caption and content.
- Widened the tab tiles by two logical pixels while preserving a one-pixel
  side seam, matching the adjacent pane's edge treatment without introducing a
  second border or gutter.

## 2026-07-14 — Grouped editor-type menu pass

- Replaced the sample's flat editor-type dropdown with a reusable
  `BlenderEditorTypeSelector` and grouped menu matching Blender's General,
  Animation, Scripting, and Data columns.
- Added editor glyphs, keyboard shortcuts, selected/hover states, compact
  menu density, and the rich editor-description tooltip shown when the area
  editor control is hovered.
- Added Drivers and Asset Browser editor types to the public editor model and
  mapped them to lightweight sample surfaces so every menu entry remains
  interactive without detailed 3D rendering.
- Routed selector activation through the popover instead of the nested button
  gesture, preventing the child button from consuming the menu-opening tap.
- Added sample smoke-test coverage for all four menu categories and verified
  the package and example targets after the sizing correction for the compact
  76 px editor selector.

## 2026-07-14 — Blender menu scale alignment

- Compared the rendered editor menu against the supplied desktop Blender
  screenshot and found that the first implementation expanded to the full
  route width and used oversized rows for a native desktop window.
- Bounded the grouped menu to 820 logical pixels, reduced rows to 24 pixels,
  reduced menu-local typography and glyphs, and tightened outer/column padding.
  This preserves the four-column structure while leaving the viewport visible
  behind the popup at the reference window size.
- The example smoke test remains green after the compact scaling pass.

## 2026-07-14 — Header scrolling and tool-option interaction pass

- Changed `BlenderToolbar` into a stateful horizontal surface with a shared
  scroll controller and scroll-aware left/right gradient fades.
- Added a non-scrollable mode to `BlenderTabBar` so the sample's workspace tabs
  participate in the application's single top-level scroll surface instead of
  scrolling independently from File/Edit/Render and scene controls.
- Added workspace hover descriptions, including the active-workspace tooltip
  used by Blender's tabs.
- Added reusable tool-option descriptors and popovers to `BlenderToolShelf`,
  including selected/hovered rows, shortcuts, and contextual descriptions.
  The sample's Select tool now exposes Tweak, Select Box, Select Circle, and
  Select Lasso options.
- Added smoke-test coverage for the tool popup, File menu, Import submenu,
  grouped editor menu, and compact header interactions.

## 2026-07-14 — Properties sizing and delayed submenu pass

- Changed property rows from a fixed-width editor slot to a responsive 2:3
  label/control allocation, keeping Blender-style fields usable while the
  Properties region is resized.
- Number fields without an explicit width now fill their allocated property
  control area; explicit `fieldWidth` values remain available for compact
  standalone forms and compatibility with existing callers.
- Added reusable delayed hover opening to `BlenderPopover`, defaulting to a
  200 ms delay, and applied it to submenu rows while retaining tap opening.
- Added the Scene and View Layer groups to the sample's single scrollable
  application header so right-aligned controls participate in the same
  trackpad scroll surface as menus and workspace tabs.

## 2026-07-14 — Properties reference alignment follow-up

- Added reusable panel header leading widgets, title styles, and background
  colors so editor contexts can reproduce Blender's icon-plus-context headers
  without special-casing the panel implementation.
- Updated the sample Properties area to use a compact editor header, Scene
  context title, pin action, raised grey numeric fields, right-aligned normal
  labels, separated rounded property groups, and Blender-like group typography.
- Grouped Scene and View Layer controls now use contiguous internal rows with
  context icons, matching Blender's right-aligned top-bar sections while still
  participating in the shared invisible scroll surface.
- Re-ran package and example analysis plus the package and example widget
  tests after correcting the compact Properties header for narrow panes.

## 2026-07-14 — Properties interaction and overflow hardening

- Hardened horizontally scrollable toolbars with unconstrained horizontal
  content sizing so compact panes scroll instead of producing RenderFlex
  overflow exceptions.
- Corrected menu leading slots for items that combine a selection checkmark
  with an icon; the slot now reserves the required width without affecting
  ordinary icon-only menu alignment.
- Added optional Blender-style two-column grip handles to panel headers and
  enabled them for Properties groups.
- Improved numeric fields with centered values, raised grey entry surfaces,
  and hover-only left/right step controls that adjust by the configured step
  and respect min/max clamping.
- Extended the dropdown test with an icon-bearing selected item to protect the
  previously failing menu layout path.
- Replaced the sample's short Transform demo with Format, Frame Range, Time
  Stretching, Stereoscopy, and Output groups so the reference scrolling and
  numeric-control behavior can be exercised in the running app.

## 2026-07-14 — Pane resizing and scrollbar fidelity pass

- Changed splitter visuals to a dark one-pixel divider centered inside a
  four-pixel drag target, matching Blender's subtle pane boundary while
  retaining precise mouse resizing.
- Added the public `BlenderScrollbar` primitive with a 3 px thumb, rounded
  corners, small margins, and an invisible comfortable interaction area.
- Applied the narrow scrollbar to the generic scroll view, Outliner tree, and
  Properties group list so long panels scroll without a heavy native-looking
  bar.
- Re-ran package and example analysis plus all package and example smoke tests.

## 2026-07-14 — Properties editor anatomy alignment

- Moved the Properties editor-type selector and search field into a full-width
  editor toolbar, then placed the vertical context-tab rail below it. This
  mirrors Blender's header ownership: the toolbar belongs to the area, while
  the tabs belong to its editor content.
- Added a `topContent` composition slot to `BlenderPropertiesEditor` and used
  it for the active Select Box context, its yellow tool glyph, and the compact
  selection-mode control. The sample now changes the context title and groups
  when the Properties rail changes instead of always showing Scene settings.
- Reduced the property-tab rail to the reference-like compact width and kept
  the editor content independently scrollable beside it.
- Made `BlenderButton` gracefully collapse to a fitted icon when an editor
  header allocates less than one normal control width. This fixes the narrow
  Flex overflow discovered by the sample widget test without caller-specific
  layout workarounds.
- Package and example analysis pass; all 26 package tests and the example
  widget test pass after the regression fix.

## 2026-07-14 — Properties tab and caption fidelity pass

- Replaced the generic panel-header treatment for Properties contexts with a
  dedicated, quiet caption row: icon, context name, and pin action now sit on
  the editor surface, as in Blender, rather than inside a high-contrast header
  strip.
- Added the public `BlenderPropertyTabVisibilityMenu`. It opens after the
  shared 200 ms hover delay (and on click), lists context tabs with icons and
  checkboxes, and keeps at least one tab visible.
- Added an optional tab-group index to `BlenderPropertyTab`; the tab rail now
  renders restrained gaps between semantic groups instead of treating every
  icon as one uninterrupted button stack.
- Added a focused regression test for the visible-tabs popover and its state
  update. The first version of the test intentionally revealed that anchored
  popovers require a Navigator; it was moved from the minimal theme harness to
  `BlenderApp`, which is now the established harness for route-backed controls.

## 2026-07-14 — Properties arrow ownership correction

- Corrected an interaction mismatch found during visual comparison: Blender's
  top-right Properties arrow is a context-options popup, while the visible-tab
  selector belongs to the fixed arrow at the bottom of the vertical tab rail.
- The sample top-arrow now offers Sync with Outliner (Always, Never, Auto) and
  Selectable. The rail arrow remains hover-opened and controls visible tabs,
  preserving the original caller-owned visibility state.
- Kept the rail selector outside the tab list's scrolling region so it remains
  anchored at the bottom of the editor, including when the full tab set is
  longer than the pane.

## 2026-07-14 — Local-source tab and panel styling pass

- Established the local Blender checkout as the preferred Blender-source
  reference for this project, replacing network lookups for source
  inspection when it is available.
- Matched the local default theme's tab palette: `#1D1D1D` inactive tabs,
  `#303030` selected tabs, and restrained outlines. The Properties rail now
  builds separate dark group backdrops with individual selected-tab capsules
  instead of one continuous bordered icon column.
- Applied Blender's faint `panel_outline` treatment to panels and the active
  Properties region, replaced unchecked option fields with the regular raised
  control surface, and added the one-pixel black text shadow used by Blender's
  default widget, group-label, and panel-title styles.
- Source references: `release/datafiles/userdef/userdef_default_theme.c`,
  `source/blender/editors/interface/interface_style.cc`, and
  `source/blender/editors/interface/interface_widgets.cc` in the local Blender
  checkout. Library and sample analyses, all 26 library tests, and the sample
  widget test pass.

## 2026-07-14 — Local-source Outliner structure pass

- Reworked `BlenderTree` flattening to preserve ancestor continuation metadata,
  allowing it to render Blender-style hierarchy guide lines instead of only
  indentation. Added the local default theme's subtle `row_alternate` striping.
- Replaced the generic titled Outliner panel with a toolbar-first Outliner
  shell, then moved `Scene Collection` into the sample tree hierarchy where it
  belongs. Restriction controls remain aligned at the trailing edge of rows.
- Added an anchored filter popover with restriction-toggle, sorting, sync,
  mode-column, and object-type filter controls, based on the filter and
  restriction layout in the local Outliner implementation.
- Source references: `outliner_draw.cc`, `outliner_utils.cc`,
  `space_outliner.cc`, and `userdef_default_theme.c` in the local Blender
  checkout. Added a focused test covering the Outliner filter popup; all 27
  library tests and the sample widget test pass.

## 2026-07-14 — Outliner object/data fidelity follow-up

- Corrected the restriction-column treatment: visible and unlocked state now
  controls the icon/action without applying the generic blue selected-button
  fill. This matches Blender's independently drawn restriction columns.
- Added semantic Camera and Light glyphs plus expanded sample object-data
  branches for Camera, Cube/Mesh/Material, and Light. The showcase now exposes
  the same object-to-data hierarchy used in the Blender reference.
- Refined hierarchy guides from the local `outliner_draw.cc`: reduced alpha,
  row-end padding, and structural continuation geometry replace the previous
  full-height guides.
- Package and example analysis, all 27 library tests, and the example widget
  test pass.

## 2026-07-14 — Outliner display-mode architecture pass

- Added public `BlenderOutlinerDisplayMode` and presentation metadata for
  Scenes, View Layer, Video Sequencer, Blender File, Data API, Library
  Overrides, and Unused Data. The compact mode selector now presents the
  Blender-style display-mode menu with semantic icons.
- Wired the sample mode selector to distinct data trees, making it a genuine
  view switch rather than a static tree with a changing dropdown label.
- Added collapsed-tree summaries that aggregate contained item glyphs and
  counts, following Blender's compact closed-collection icon-row behavior.
- Added focused regression coverage for display-mode selection. All 28 library
  tests and the sample widget test pass.

## 2026-07-14 — Local-source area splitter affordance pass

- Reworked `BlenderSplitter` to keep a four-pixel interaction target while
  painting only a single, screen-edge-style divider. The divider brightens
  only while hovered or dragged, avoiding a permanently heavy gutter between
  editors.
- Mapped vertical pane edges to Flutter's column-resize cursor and horizontal
  pane edges to its row-resize cursor, which preserves Blender's horizontal
  and vertical split semantics on each platform.
- Added a regression test that drags the directional divider and verifies that
  the split fraction changes.
- Source references: `screen_draw.cc` and `wm_cursors.cc` in the local
  Blender checkout. Flutter does not expose Blender's SVG cursor registration,
  so the implementation deliberately uses the matching platform-native resize
  cursor shapes.
- Added a transient, high-contrast split handle rendered only during dragging.
  It fades in on pickup and fades out after release, with directional chevrons
  around the divider to make the resize axis immediately legible.

## 2026-07-14 — Resizable editor-shell boundaries

- Replaced `BlenderEditorShell`'s fixed right-area `SizedBox` boundary with a
  horizontal `BlenderSplitter`; `rightWidth` is now the initial width rather
  than a permanent constraint. The analogous bottom-area boundary now uses the
  vertical splitter, with `bottomHeight` preserved as its initial size.
- This closes the gap between the reusable splitter controls and the actual
  sample workspace layout: Outliner/Properties can now be widened or narrowed
  directly at their shared edge.
- Added a focused shell-level regression test that drags the right-area edge
  and asserts that the right editor becomes wider.

## 2026-07-14 — Active resize guides and numeric-input behavior

- Separated the inactive editor boundary from the active resize guide. Dragging
  now fades a brighter two-pixel, full-length guide in and out together with
  the directional handle; the idle boundary remains a restrained hairline.
- Reworked `BlenderNumberField` into Blender-like display and edit modes:
  horizontal dragging changes the value, Shift enables fine adjustment, a
  normal click opens exact text entry, and a double click selects the value for
  replacement. Hover-only increment/decrement affordances remain compact.
- Adapted the numeric drag response from the local Blender implementation:
  small integer ranges move at fine increments, medium and large ranges become
  progressively faster, bounded values clamp without getting stuck, and
  decimal precision is normalized during drag updates.
- Source references: `screen_draw.cc`, `wm_cursors.cc`, and
  `interface_handlers.cc` (`numedit_but_NUM`) in the local Blender checkout.

## 2026-07-14 — Editor chrome and identifier-group fidelity

- Corrected the shared editor-outline tokens to the local default theme values:
  idle `#ffffff15` and hovered active `#ffffff2a`. Added `BlenderEditorFrame`
  so editor areas gain that fine active border on hover rather than relying on
  panel borders alone.
- Reassigned the default toolbar surface to Blender's header surface, keeping
  editor bodies darker and making header/body boundaries match the reference.
- Added an alternating-row painter behind `BlenderTree`, so the Outliner keeps
  its subtle row cadence through blank space as Blender does.
- Reworked the sample Scene and View Layer identifiers into icon-selector,
  name, and compact action segments instead of one oversized dropdown.
- Source references: `userdef_default_theme.c`, `screen_draw.cc`, `area.cc`,
  `outliner_draw.cc`, and `space_buttons.cc` in the local Blender checkout.

## 2026-07-14 — Properties header anatomy follow-up

- Corrected the Properties header to use a dedicated space icon, Blender's
  raised header background, and a separate far-right context-options control.
  The previous compact dropdown duplicated the affordance that belongs to the
  Outliner display-mode selector and made the header visibly unlike Blender.
- Increased the header band and aligned the search/control dimensions with the
  `HEADERY`-based header-region treatment in the local editor sources.

## 2026-07-14 — Editor-type-aware area headers

- Revisited the Properties-header conclusion after comparing the actual area
  controls in `space_view3d.cc`, `space_outliner.cc`, and `space_buttons.cc`.
  Every Blender area starts with an area-type selector; its icon is not a
  properties-only static button. The sample now models that relationship
  explicitly.
- Refactored `BlenderAreaHeader` into fixed selector/action regions around a
  scrollable menu region. This preserves the right-side controls while allowing
  the area menus to scroll in constrained widths, matching Blender's editor
  header behavior.
- Added editor-family header specifications for the sample's 3D, image/UV,
  animation, node, and utility editors. Each type now receives relevant menus
  and controls instead of retaining the 3D Object Mode controls after an area
  type changes.
- Added independent area-type state to the right Outliner and Properties
  regions. The Outliner now exposes its area selector before its distinct
  display-mode selector; Properties exposes its area selector, search, and
  context menu in the same header. Selecting another type swaps that sidebar
  area to a generic editor surface until a specialised body is assigned.

## 2026-07-14 — Fixed data-block groups in the application header

- Split the sample application header into two ownership regions after
  reviewing the real Blender workspace strip: application menus, workspace
  tabs, and the add-workspace button live in one horizontally scrollable
  region; Scene and View Layer data-block groups stay anchored at the right.
- Added the missing add-workspace button with a compact popover for standard
  workspace templates and Duplicate Current. Scene and View Layer no longer
  scroll away with the workspace tabs.
- This intentionally uses a fixed outer header and the existing fade-aware
  `BlenderToolbar` only for the left region, so scrolling behavior follows
  Blender's ownership model rather than clipping unrelated controls.

## 2026-07-14 — Header fade and ID-template refinement

- Restored visible workspace-strip edge fades. The initial fixed-header change
  had passed a transparent background to the nested scrolling toolbar, which
  also made its fade gradients transparent. The toolbar now receives the real
  header background while the outer row remains responsible for the fixed
  Scene and View Layer region.
- Added public `BlenderDataBlockGroup`, based on Blender's local
  `template_ID()` implementation in
  `source/blender/editors/interface/templates/interface_template_id.cc`. It
  composes the browse selector, name field, optional embedded pin, duplicate,
  and close controls as one compact ID-template surface.
- Replaced the sample's oversized ad-hoc Scene/View Layer buttons with that
  shared component. The Scene pin now lives inside its name field, as in
  Blender's scene-specific template width/pin treatment.

## 2026-07-14 — Compact ID-template visual calibration

- Calibrated `BlenderDataBlockGroup` against the Blender header reference:
  22px-high low-radius segments, a narrow browse selector, left-aligned ID
  name text, and muted compact duplicate/close actions.
- Moved the pin hit target into a 20px trailing inset of the name field. This
  removes the visually separate pin button and preserves the intended
  `template_ID()` grouping.

## 2026-07-14 — ID-template segment and header cleanup

- Reduced joins between the selector, ID field, and actions to one pixel;
  lowered border contrast; made the duplicate segment subtly raised; and made
  the close action deliberately muted. The name text is now left aligned with
  regular weight.
- Updated the Scene glyph to a compact scene-data mark instead of a target
  reticle and rotated the pin to match Blender's diagonal push-pin treatment.
- Taught compact icon-plus-chevron buttons to scale their paired contents at
  narrow widths. This prevents the scene selector chevron from disappearing
  and fixes the resulting `RenderFlex` overflow.
- Removed the unrelated Preferences/operator-search and Save buttons from the
  fixed right end of the sample header; the header now ends with View Layer as
  in Blender's data-block region.

## 2026-07-14 — Unified flat ID-template container

- Replaced independently decorated Scene/View Layer sub-buttons with one flat
  rounded ID-template outline and internal one-pixel divider lines. The
  selector, editable-name region, pin, duplicate, and close controls now have
  zero inter-segment gaps and share a single border, matching Blender's
  `template_ID()` appearance.
- Kept the selector interactive through an anchored `BlenderPopover` and its
  existing `BlenderMenu`, so the visual consolidation did not trade away the
  data-block browse behavior.

## 2026-07-14 — Tool Settings property-context hierarchy

- Added an optional specialised scroll body to `BlenderPropertiesEditor` so
  editor contexts can render Blender-specific panel hierarchies without
  distorting the reusable descriptor-driven Properties implementation.
- Rebuilt the sample Tool context around Select Box: compact select-mode
  segments, Options, nested Transform, Affect Only checkboxes, and a separate
  Workspace disclosure panel. The former placeholder Select Through/Overlap
  rows were removed.
- Added `selectBox` and corrected Properties glyph treatments for the matching
  context caption/header visuals. Tool checkboxes use an overflow-safe compact
  row so the sidebar remains usable at constrained widths.

## 2026-07-14 — Properties tab-rail calibration

- Refined the shared `BlenderPropertyTabs` rail to use a dark continuous rail,
  low-contrast group backing strips, tighter inter-group spacing, and smaller
  selected-tab outlines. Inactive tabs are now flat rather than individually
  boxed.
- Replaced the magnifier-like Tool glyph with a compact wrench mark so the
  first Properties tab reads as Tool in the same way as Blender's tab rail.

## 2026-07-14 — Flat Properties tab-rail treatment

- Rechecked the local Blender default theme's `wcol_tab` values before
  refining the shared rail: unselected tabs use the same dark outline and
  fill, while selection is expressed only through a lighter inner fill.
- Removed rounded group containers and visible selected-tab outlines from
  `BlenderPropertyTabs`. Groups now use spacing only; selected and hovered
  tiles are inset by one logical pixel so the surrounding flat rail remains
  visible as Blender's subtle border/shadow treatment.
- Added a restrained rail-edge shadow rather than a bright divider. This keeps
  the tab strip visually attached to the Properties editor instead of reading
  as a separate stack of panels.

## 2026-07-14 — Joined Properties navigation rail

- Added `showLeftBorder` to `BlenderEditorFrame` and
  `joinNavigationRail` to `BlenderPropertiesEditor`. A navigation rail can now
  supply the only leading seam, avoiding doubled borders and the exposed
  parent-colour gap caused by independently framed widgets.
- Applied the joined treatment to the sample Properties column. The API stays
  opt-in so standalone editors retain their normal complete outlines.

## 2026-07-14 — Edge-aligned tabbed Properties content

- Traced the remaining apparent rail-to-panel gap to inherited content padding,
  not the editor border. Added rail-aware caption/list insets to
  `BlenderPropertiesEditor` so a joined editor can keep a small caption inset
  while its panels begin at the frame edge.
- Removed the sample Tool Settings body's redundant side padding. This makes
  its select modes and disclosure panels align with Blender's tabbed
  Properties-region geometry.

## 2026-07-14 — Joined Properties rail final seam pass

- Removed the remaining joined-caption inset so the Properties pane begins
  directly against its context-tab rail.
- Changed selected and hovered context-tab tiles to use the pane surface color;
  the rail remains dark while active tabs visually belong to the pane.

## 2026-07-14 — Properties surface, density, and segment fidelity

- Compared the sample against the local Blender checkout at
  `68bdd158cc49af6191f0d9480510f4c5214f2df5`, specifically the default theme,
  panel backdrop renderer, and selection-operation definitions.
- Traced the background mismatch to generic Flutter surface tokens: the
  Properties region, top-level panel, nested panel body, and outline each have
  distinct compositing roles in Blender.
- Traced the heavy Select Box separators to two stacked mechanisms: a group
  gap plus the full border drawn by every regular button. The reusable segment
  path now owns the thin gap and suppresses redundant per-button outlines.
- Chose semantic color tokens, a reusable centered area-header slot, and
  independent navigation-rail/tile sizing as the long-term layout fix.
- Confirmed from `WM_operator_properties_select_operation` that Select Box has
  five ordered modes: Set, Extend, Subtract, Difference, and Intersect.

## 2026-07-14 — Corner splitting, area docking, and orbitable viewport

- Examined the local Blender source revision
  `68bdd158cc49af6191f0d9480510f4c5214f2df5` in `area.cc`, `screen_ops.cc`,
  and `screen_draw.cc`. The useful transferable behavior was the four corner
  action zones, 20-pixel activation threshold, dominant-axis split selection,
  center/edge dock targets, and commit-on-release preview flow.
- Added immutable `BlenderDockAreaNode`/`BlenderDockSplitNode` models,
  `BlenderDockingController`, and `BlenderDockingWorkspace`. Existing
  `BlenderSplitter` widgets render and resize the tree; focused corner-handle,
  target calculation, preview, and controller classes keep the implementation
  decomposed.
- Replaced the sample's fixed main/right/bottom composition with an initial
  four-area docking tree. Dragging a corner within its area splits and clones
  its content; dragging to another area moves it to an edge or replaces the
  center target.
- Extracted the static viewport from the large sample state into
  `example/lib/showcase_viewport.dart`. The minimal scene now has an orbit
  camera, perspective grid, shaded/wire cube, world-axis gizmos, orientation
  widget, wheel zoom, and double-click reset.
- Added a stable 1200×800 workspace golden at
  `example/test/goldens/showcase_workspace.png`, controller/corner gesture
  tests, semantic color and segmented-border tests, and an orbit interaction
  test.
- Verification completed with `flutter analyze` (no issues), 42 package tests,
  and 3 example tests. Pixel sampling of the golden confirmed the Properties
  backdrop at `#303030`, panel at `#3D3D3D`, and nested body at composited
  `#363636`.
- Tool experience: the first `dart format` attempt could not update Flutter's
  SDK cache outside the workspace and was rerun through the managed approval
  path. Two specialized-template call sites used the stale `leading` panel
  parameter and were corrected to `headerLeading`. The first orbit test left
  Flutter's 40 ms double-tap timer pending; a 100 ms settle made the gesture
  test deterministic.
- Browser verification could not start because the in-app browser connector
  rejected its own request metadata with a missing `sandboxPolicy` field before
  navigation. The fallback stayed local and non-browser: Flutter rendered the
  golden, which was then inspected directly. No external page was opened.

## 2026-07-14 — Centered dialog surface pass

- Audited the local Blender checkout at
  `68bdd158cc49af6191f0d9480510f4c5214f2df5` after finding that the package
  had anchored menus and popovers but no centered modal dialog family.
- Added `showBlenderDialog`, `BlenderDialog`, and `BlenderAlertDialog` with a
  Blender-style popup surface, modal scrim, centered placement, optional
  alert icon, multi-line message body, custom property content, and compact
  Cancel/confirm actions.
- Matched the source dialog anatomy from `wm_block_dialog_create`: large and
  small padding modes, title before message, optional content below a quiet
  separator, and confirmation actions grouped at the lower right.
- Added the dialog API to the public export and documented the source mapping.
- Added alert and operator-property dialog examples to the sample UI Catalog,
  including compact frame-range fields and a preview-range checkbox.
- The refreshed Flutter SDK exposed a decorative-glyph accessibility flag in
  the existing checkbox test; the check mark now uses `ExcludeSemantics` so
  the checkbox keeps only its intended checked-state semantics.
- The sample smoke test exposed a 4-pixel narrow-header overflow in the
  existing data-block selector; its icon/chevron pair now uses a fitted group
  at constrained widths. Both regressions are fixed in shared primitives and
  documented in `docs/reference/blender-ui-coverage.md`.
- The example analyzer also caught two stale `const` separators that depended
  on the runtime Blender theme; those separators are now non-const while
  unrelated constant header controls remain const.

## 2026-07-14 — Specialized property-template pass

- Compared the local Blender source revision
  `68bdd158cc49af6191f0d9480510f4c5214f2df5` in
  `interface_template_constraint.cc`, `interface_template_cache_file.cc`,
  `interface_template_light_linking.cc`, and the Grease Pencil layer tree and
  search templates.
- Added descriptor-driven `BlenderConstraintStack` with icon/name,
  enabled/menu/reorder/remove actions and collapsible child panels.
- Added `BlenderCacheFilePanel` with cache path/reload controls, manual scale,
  time settings, frame override, velocity name, and velocity unit controls.
- Added `BlenderLightLinkingCollection` with a collection ID field and compact
  include/exclude tree rows, plus `BlenderGreasePencilLayerTree` with nested
  groups, search, disclosure state, and masks/onion-skin/visibility/lock
  columns.
- Added `BlenderShaderEffectStack` and `BlenderNodeTreeInterface` for the
  matching shader-effect panel and nested socket/panel declaration tree
  surfaces from the same source family.
- Kept these surfaces in `specialized_templates.dart` and used caller-owned
  descriptors/callbacks so the visual layer remains independent of Blender's
  RNA and tree data structures.

## 2026-07-14 — Remaining template edge-family pass

- Compared the local Blender checkout at
  `68bdd158cc49af6191f0d9480510f4c5214f2df5` in
  `interface_template_bone_collection_tree.cc`,
  `interface_template_asset_shelf_popover.cc`,
  `interface_template_component_menu.cc`, and `interface_template_list.cc`.
- Added `BlenderBoneCollectionTree` with nested disclosure rows, active and
  selected-bone markers, visibility and solo controls, and optional remove
  actions.
- Added `BlenderAssetShelfPopover` with Blender's large/non-header and compact
  trigger variants, bounded preview grid, selected-tile treatment, and close
  after selection.
- Added `BlenderComponentMenu` and `BlenderCompactList` for the expanded
  component-choice and compact current-item/count navigation anatomies.
- Kept all four surfaces descriptor-driven and independent of Blender RNA;
  the package owns only the visual state and callback boundaries.
- Added UI Catalog examples and focused widget coverage. The compact-list
  navigation buttons now expose one explicit semantics node each; their nested
  tooltip semantics are excluded to avoid duplicate accessibility targets.
- Verification: package `flutter analyze` and all 43 package widget tests pass;
  the three example smoke tests pass. The first full-suite attempt reported a
  docking assertion after the new test ran, but the docking test passed in
  isolation and in the final full suite, so no unrelated docking code was
  changed. Flutter's existing SVG loader continues to emit non-fatal warnings
  for `sodipodi:namedview` and `defs` elements during icon tests.

## 2026-07-14 — Full data-block property-template pass

- Re-audited `interface_template_id.cc` after confirming that the existing
  `BlenderDataBlockGroup` only represented Blender's compact Scene/View Layer
  header composition.
- Added `BlenderDataBlockField` with the recurring Properties-panel anatomy:
  browse/search popover, optional preview grid, selected value/icon, New/Open,
  duplicate, user count, linked/override indicators, fake-user retention, and
  unlink actions.
- Kept the API descriptor-driven (`BlenderMenuItem<T>` plus explicit callbacks)
  so it can render materials, meshes, images, node groups, and other ID types
  without coupling the package to Blender RNA or ID ownership.
- Added the field to the UI Catalog, public exports, coverage map, README, and
  the focused widget test. Direct Dart analysis passes with no issues.
- Tool note: the managed Flutter wrapper began waiting behind a long-lived
  `flutter run` process in the shared SDK cache. The process was left intact;
  direct SDK analysis and formatting were used while the test gate is retried
  through the Flutter snapshot.

## 2026-07-14 — Keymap operator-property box pass

- Compared `interface_template_keymap.cc` in the local Blender checkout. Its
  visual contract is a two-column flow of boxed operator properties, with
  unset properties dimmed and set properties carrying a trailing unset button.
- Added `BlenderKeymapProperty` and `BlenderKeymapItemProperties` as a plain
  descriptor/editor boundary, including empty-state text and per-property
  unset callbacks.
- Added the surface to the UI Catalog, public exports, coverage map, and
  example documentation. Direct Dart analysis remains clean; Flutter widget
  execution is still being retried around the shared SDK lock described above.

## 2026-07-14 — Resizable preview-template pass

- Compared `interface_template_preview.cc` in the local Blender checkout. The
  source uses a large preview canvas with a bottom resize grip and a compact
  control column for render type, preview world, texture/material selection,
  and alpha preview.
- Added `BlenderPreviewPanel` as a stateful visual template with bounded
  resizing and caller-owned preview/control descriptors. It is intentionally
  separate from `BlenderPreviewTile`, which represents a selectable grid tile.
- Added the panel to the UI Catalog, public exports, coverage map, README, and
  the example smoke path. The nested-scroll regression from the keymap flow
  was fixed before this pass was accepted: keymap property boxes now use a
  non-scrollable responsive `Wrap` inside the catalog's existing scroll view.
- Final verification passed: package suite 49 tests, example smoke suite 3
  tests, and package/example Flutter analysis with no issues. The existing
  non-fatal SVG parser warnings remain limited to the icon fixtures.

## 2026-07-14 — Transient report-banner pass

- Compared the report-banner section of `interface_template_status.cc` in the
  local Blender checkout: a severity-colored icon block is joined to a muted
  message block and opens the Info editor when activated.
- Added `BlenderReportBanner` with info/success/warning/error colors and icons,
  bounded message layout, and an optional activation callback. It remains
  separate from `BlenderNoticeBanner`, which is a persistent in-panel notice.
- Added the banner to the UI Catalog, public exports, coverage map, README, and
  widget coverage. The context-sensitive input-status rows from the same
  source remain explicitly tracked as the next partial status family.
- Final verification after this pass: package suite 50 tests, example smoke
  suite 3 tests, and package/example Flutter analysis with no issues.

## 2026-07-14 — Context-sensitive input-status pass

- Compared `interface_template_event.cc` and the `uiTemplateInputStatus*`
  branches in `interface_template_status.cc` against the local Blender
  checkout. The shared visual language is modifier/event tokens followed by a
  compact label, with optional warning color and drag-event tokens.
- Added `BlenderInputStatusItem` and `BlenderInputStatus` for split/dock,
  duplicate-window, swap-area, header pan/options, modal, and viewport-warning
  variants. The descriptors keep context selection outside the visual layer.
- Added representative status rows to the UI Catalog, public exports, coverage
  map, README, and widget coverage. Blender's exact runtime area/region polling
  and axis/plane collapse rules remain intentionally tracked as partial source
  behavior rather than being guessed in the package.
- Final verification after this pass: package suite 51 tests, example smoke
  suite 3 tests, and package analysis with no issues.

## 2026-07-14 — Modal event-group fidelity pass

- Revisited the known collapse branches in `interface_template_event.cc`:
  Axis X/Y/Z, Plane X/Y/Z, and Proportional Size up/down/center are rendered
  as compact event-token groups when their modifiers match.
- Extended `BlenderInputStatusItem` with grouped `events` so the same visual
  composition can be represented without embedding Blender's keymap objects.
  Added Axis, Plane, and Proportional Size examples and focused assertions.
- The visual grouping is now covered; runtime polling and the decision to omit
  a third event remain outside the package's visual-only scope and are kept as
  the documented partial boundary.

## 2026-07-14 — Icon-view enum popup pass

- Compared `template_icon_view` in `interface_template_icon.cc` with the local
  Blender checkout: an icon-only selected trigger opens a bounded pulldown with
  eight columns, optional labels, and selected/disabled enum tiles.
- Added descriptor-driven `BlenderIconViewItem` and `BlenderIconView`, keeping
  enum values and icon widgets caller-owned while preserving Blender's popup
  geometry and interaction boundary.
- Added the icon-view example, public exports, coverage-map entry, README note,
  and a popup-selection regression test.
- The first focused test exposed two integration details: the nested button
  would win the popover gesture unless it was wrapped in `IgnorePointer`, and
  the popover test needed the Navigator supplied by `BlenderApp` rather than
  the lightweight widget harness. Both were fixed without changing the shared
  popover implementation.
- Verification after this pass: package suite 53 tests, example smoke suite 3
  tests, and direct Dart analysis with no issues. Existing non-fatal SVG parser
  warnings remain limited to the icon fixtures.

## 2026-07-15 — Search-template preview-grid pass

- Rechecked `template_search_preview` and `template_common_search_menu` in the
  local Blender checkout at `68bdd158cc49af6191f0d9480510f4c5214f2df5`.
  Blender exposes the same searchable collection surface in either a compact
  list or a bounded thumbnail grid controlled by preview rows and columns.
- Extended `BlenderSearchMenu` with opt-in preview rows/columns, reusing the
  package preview-tile anatomy for filtered, clickable results. The default
  list mode remains unchanged.
- Added a catalog example, README/coverage entries, and a regression test for
  the preview grid.
- Verification after this pass: package suite 54 tests, example smoke suite 3
  tests, and package/example analysis with no issues. Existing non-fatal SVG
  parser warnings remain limited to the icon fixtures.

## 2026-07-15 — Status-info strip pass

- Audited `uiTemplateStatusInfo` in the local Blender status template. Its
  visible anatomy includes status text, optional version text, extension
  offline/checking/update indicators with an update count, and a warning block
  for file or color-management issues.
- Added descriptor-driven `BlenderStatusInfo` and
  `BlenderExtensionStatus`, with compact separators, extension count badges,
  warning tooltip/callback support, and the same split warning treatment used
  by Blender's status strip.
- Added the catalog example, public exports, coverage/README documentation,
  and a focused regression test. Runtime context derivation remains outside
  the visual descriptor boundary.
- The first full catalog smoke run exposed a compact-width overflow when the
  status text, extension badge, version, and warning were shown together.
  Bounded ellipsis widths for the long status and warning segments fixed the
  issue while retaining Blender's single-line composition.
- Final verification after this pass: package suite 55 tests, example smoke
  suite 3 tests, and package/example analysis with no issues. Existing
  non-fatal SVG parser warnings remain limited to the icon fixtures.

## 2026-07-15 — File-browser side-panel pass

- Audited `file_panels.cc` in the local Blender checkout at
  `68bdd158cc49af6191f0d9480510f4c5214f2df5`. The file selector exposes a
  filename/overwrite execution row with cancel/execute actions and an Asset
  Catalogs tools pane with library selection, refresh/bundle actions, and a
  nested catalog tree.
- Added descriptor-driven `BlenderFileExecutionPanel` and
  `BlenderFileAssetCatalogPanel`, reusing the package text, dropdown, tree,
  and panel primitives while keeping operator/RNA and asset-library state
  caller-owned.
- Added catalog examples, exports, coverage/README documentation, and a
  focused widget test. The existing workspace golden was refreshed because
  its right Properties pane baseline lagged the current rendered source; the
  isolated diff was confined to that pane.
- Final verification after this pass: package suite 57 tests, example smoke
  suite 3 tests, package/example analysis with no issues, and the refreshed
  workspace golden passes. Existing non-fatal SVG parser warnings remain
  limited to the icon fixtures.

## 2026-07-15 — Preferences Asset Libraries pass

- Audited `userpref_asset_libraries_list.cc` in the local Blender checkout at
  `68bdd158cc49af6191f0d9480510f4c5214f2df5`. The source has a flat library
  tree with built-in labels, local/remote drive icons, enable checkboxes,
  invalid-remote warnings, add/remove buttons, and selected-library settings
  for essentials, repository URLs, paths, import method, and relative paths.
- Added descriptor-driven `BlenderAssetLibraryPreference` and
  `BlenderAssetLibrariesPreferencesPanel`, including the selected-library
  settings boundary and caller-owned callbacks for all visible controls.
- Added catalog coverage, public exports, README/history entries, and a
  focused widget test. The first test assertion used visible text for a
  `BlenderTextField` label even though the shared control exposes that label
  through semantics; the assertion was corrected to use the public semantics
  contract.
- Matched Blender's five-row default tree density with an explicit
  `libraryListHeight` so the pane remains safe when embedded in an unbounded
  Preferences scroll view instead of relying on an ancestor's `Expanded`
  constraint.
- Final verification after this pass: package suite 58 tests, example smoke
  suite 3 tests, package/example analysis with no issues, and the workspace
  golden passes. Existing non-fatal SVG parser warnings remain limited to the
  icon fixtures.

## 2026-07-15 — Properties texture-user selector pass

- Audited `buttons_texture.cc` in the local Blender checkout at
  `68bdd158cc49af6191f0d9480510f4c5214f2df5`. The source exposes the active
  texture user as an icon/text pulldown and places a separate Properties icon
  beside it to show the texture in the Texture context, with explicit empty
  and unavailable states.
- Added descriptor-driven `BlenderTextureUser` and
  `BlenderTextureUserSelector`, plus the source-matched `texture` glyph, and
  added the catalog example, exports, coverage/README documentation, and a
  focused widget test.
- The expanded Output Properties example gate exposed narrow-pane overflow in
  the shared color and number fields. Responsive fitting and flexible field
  bounds were added, and the Output Properties golden was refreshed for the
  corrected compact rendering. A transient analyzer run also reported stale
  callback diagnostics; the clean rerun confirmed no remaining issues.
- Final verification after this pass: package suite 59 tests, example suite 4
  tests including both workspace goldens, and package/example analysis with no
  issues. Existing non-fatal SVG parser warnings remain limited to the icon
  fixtures.

## 2026-07-15 — Operator popup and property-dialog pass

- Audited `wm_block_create_redo` and `wm_block_dialog_create` in
  `wm_operators.cc` from the local Blender checkout at
  `68bdd158cc49af6191f0d9480510f4c5214f2df5`. The sources distinguish a
  regular anchored redo popup (operator title, separator, compact properties)
  from a centered confirmation dialog (optional message/icon and Cancel/OK
  actions).
- Added descriptor-driven `BlenderOperatorRedoPopup`,
  `BlenderOperatorPropertiesDialog`, and
  `showBlenderOperatorPropertiesDialog`, reusing the package property-row
  boundary while keeping operator execution, undo, and positioning caller-owned.
- Added the UI Catalog example, public exports, coverage/README/history
  documentation, and a focused widget test for both popup families.
- Final verification after the compact boolean-row correction: package suite
  60 tests, example suite 4 tests, package/example analysis with no issues, and
  refreshed workspace and Output Properties goldens. Existing non-fatal SVG
  parser warnings remain limited to the icon fixtures.

## 2026-07-15 — Collection importer/exporter template pass

- Audited `template_collection_importer` and `template_collection_exporters`
  in `interface_template_operator_property.cc` from the local Blender
  checkout. The source exposes configured/undefined importer headers, filepath
  and operator-property bodies, exporter lists, add/remove/reorder controls,
  presets, export actions, and an active exporter panel.
- Added descriptor-driven `BlenderCollectionImporterPanel` and
  `BlenderCollectionExportersPanel`, plus the source-matched export glyph.
  File handlers, RNA properties, operator execution, and collection state
  remain caller-owned.
- Added the UI Catalog example, public exports, coverage/README/history
  documentation, and a focused widget test for the importer/exporter anatomy.

## 2026-07-15 — File-browser operator pane pass

- Audited `FILE_PT_operator` in `space_file/file_panels.cc`. Blender keeps the
  active file operator's remaining properties in a separate collapsible pane,
  excluding filepath, directory, filename, and file-list fields already owned
  by the execution row.
- Added descriptor-driven `BlenderFileOperatorPanel`, catalog coverage, public
  exports, documentation, and a focused side-panel test.
- Verification for the combined collection/file-browser pass is complete after
  the final suite run: package 61 tests, example 4 tests, and clean analysis
  for both package and example. Existing SVG fixture parser warnings remain
  non-fatal.

## 2026-07-15 — Color palette template pass

- Audited `template_palette` in `interface_template_color_picker.cc`. Blender
  presents palette add/delete/reorder controls, a sort menu for Hue,
  Saturation, Value, and Luminance, and a responsive grid of selectable color
  swatches.
- Added descriptor-driven `BlenderColorPalette`, catalog coverage, public
  export, documentation, and a focused swatch-selection test. Palette storage,
  sorting, and color editing remain caller-owned.
- Final verification after this pass: package suite 62 tests, example suite 4
  tests, and clean package/example analysis. Existing SVG fixture parser
  warnings remain non-fatal.

## 2026-07-15 — Action and Cryptomatte template pass

- Audited `template_action`, `template_greasepencil_color_preview`, and
  `template_crypto_picker` in Blender's ID and color-picker template sources.
  The Action form is a specialized ID row with New/browse/rename/unlink
  affordances; the crypto form is a compact eyedropper operator button.
- Added `BlenderActionSelector` over the full data-block field and
  `BlenderCryptoPicker`, with the source-matched Action glyph, catalog entries,
  exports, documentation, and focused coverage. The existing preview-capable
  ID field remains the shared basis for Grease Pencil color previews.
- Final verification after this pass: package suite 63 tests, example suite 4
  tests, and clean package/example analysis. Existing SVG fixture parser
  warnings remain non-fatal.

## 2026-07-15 — Texture-user category grouping pass

- Rechecked `uiTemplateTextureUser` in `buttons_texture.cc`. Its pulldown
  inserts category labels before grouped texture users, while the adjacent
  Texture Properties jump remains available or disabled according to context.
- Updated `BlenderTextureUserSelector` to preserve those disabled category
  rows and expanded the focused test to verify the generated menu anatomy.
- Final verification passes: package suite 63 tests, example suite 4 tests,
  and clean package/example analysis. Existing non-fatal SVG fixture warnings
  are unchanged.
- A first parallel verification launcher failed with a local orchestration
  syntax error before starting any repository command; the checks were rerun
  independently and completed successfully with no worktree impact.

## 2026-07-15 — Context-sensitive status-bar pass

- Audited `uiTemplateInputStatus` in `interface_template_status.cc`. Blender
  has distinct visible status compositions for workspace text, split/dock
  action zones, quadrant/region resizing, editor borders, headers, viewport
  warnings, modal keymaps, and cursor actions.
- Added `BlenderStatusContextKind` and `BlenderStatusContextBar` with source
  labels, mouse glyphs, modifier tokens, hidden-region wording, and warning
  treatment. Runtime area/region/keymap selection remains caller-owned.
- Added catalog examples, mouse glyph assets, public exports, documentation,
  and focused status-context coverage.
- Final verification after this pass: package suite 64 tests, example suite 4
  tests, and clean package/example analysis. Existing SVG fixture parser
  warnings remain non-fatal.
