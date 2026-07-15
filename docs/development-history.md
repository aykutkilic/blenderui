# Development history

## 2026-07-15 — Matched Image/UV editor source menus and panel regions

- Re-read Blender's local `space_image.py`. The Image/UV header exposes
  source-shaped View, Select, Image, and UV menus with nested Zoom, Select
  Linked, Select by Trait, Transform, Snap, and UV operation families.
- Added those menu descriptors and submenu arrows to the example header,
  including the source View/Zoom, image save/pack, and UV unwrap/seam/packing
  items. Added visual Snapping and Proportional Editing header popovers with
  the source settings rather than leaving them as inert icon buttons.
- Corrected the sidebar hierarchy: Scopes are separate Histogram, Waveform,
  Vectorscope, Sample Line, and Samples panels; Tiling is a sibling of Brush
  Settings; and UV header panels are no longer presented as sidebar cards.
- Refreshed and reviewed `showcase_image_editor.png` and
  `showcase_uv_editor.png`. The focused structural and golden regression passes.

## 2026-07-15 — Began catalog and editor-composition refactor

- Audited repeated property factories, sidebar forms, panel stacks, nested-tree
  algorithms, and inert APIs. The showcase state object is the remaining
  primary extraction target because it combines catalogs, state, menus, and
  editor composition.
- Added `BlenderPropertyFactory`, `BlenderSidebarSections`, and
  `BlenderStaticPropertyField`. Strip and Mask descriptor factories now use
  the shared property builder.
- Added `BlenderTreeState`, moved Node Interface, Bone Collection, and Grease
  Pencil layer traversal to it, and introduced `BlenderActionPanelStack` for
  Constraint and Shader Effect stacks.
- Unified the formerly separate Properties and Preferences overlay/localization
  fallbacks as `BlenderEnsureOverlay`, retaining embedded-editor support with
  one lifecycle implementation.
- Removed the unused Sequencer `onSelected` API, which was accepted and
  forwarded but never invoked. Added focused tests for property callback
  ownership and shared tree state.

## 2026-07-15 — Matched Preferences grouping and section ordering

- Re-read Blender's `rna_userdef.cc`, `space_userpref.py`, and the Input panel
  registration order. Preferences categories now use source-shaped groups, and
  Input sections appear as Keyboard, Mouse, Tablet, Touchpad, and NDOF.
- Added stable reorder handles and drag ordering to the reusable Preferences
  editor, while preserving section IDs when categories or descriptors change.
- Removed automatic tab-rail scrollbars, added resizable temporary Preferences
  windows, and aligned the content/navigation padding with Blender's layout.

## 2026-07-15 — Added conditional TextCurve Data panels

- Re-read `properties_data_curve.py`. Blender's Font, Transform, Paragraph,
  Alignment, Spacing, and Text Boxes panels are polled only for `TextCurve`,
  while ordinary Curve data keeps Shape, Geometry, and Path Animation.
- Added a distinct Text data-block selection path to the showcase and routed it
  to source-shaped Shape, Texture Space, Font/Transform, Paragraph with
  Alignment and Spacing children, Text Boxes, Animation, and Custom Properties
  descriptors. This keeps text-only controls out of the ordinary Curve path
  without adding an Outliner row that would destabilize existing scroll-based
  fixtures.
- Added a structural regression and a dedicated `showcase_text_data.png`
  baseline. The first focused run correctly reported the missing new golden;
  update mode created it, and the focused test then passed.
- A full compile surfaced an incomplete Preferences API in the dirty worktree:
  the category-group type was not exported consistently and the temporary
  window resize clamp inferred `num`. Restoring the barrel export and
  `categoryGroups` surface, then converting clamped dimensions to `double`,
  cleared the compile errors. The full suite also exposed two brittle fixtures:
  data-block menu taps for Bone/Text depended on the last row fitting in a
  short viewport, and a Preferences drag-icon count included nested panels.
  Those regressions now use the data-field callback and stable namespaced
  section-handle keys instead.

## 2026-07-15 — Audited the remaining core Data editor families

- Compared the local Blender registrations for Curves, Armature, Lattice,
  Metaball, Speaker, Volume, and Light Probe data with the existing visual
  descriptors and regressions. Their source panel order and nesting are
  already represented: Curves Surface/Attributes, Armature Pose/Viewport/Bone
  Collections/IK/Motion Paths/Selection Sets, Lattice, Metaball Texture Space
  and Active Element, Speaker Distance and Cone, Volume viewport Slicing, and
  Light Probe Probe/Visibility/Capture/Bake sub-panels.
- No visual implementation change was needed in this audit. The important
  source distinction is retained in the descriptors: nested panels such as
  Volume Slicing and Light Probe Bake Resolution/Capture/Offset/Clamping stay
  children of their registered parent rather than becoming flat top-level
  cards.

## 2026-07-15 — Matched Outliner mode-specific header controls

- Re-read `space_outliner.py` and `rna_space.cc` in the local Blender checkout.
  The header is not one generic filter row: DATA API, Sequence, Library
  Overrides, Blender File, View Layer, and Unused Data each add different
  controls.
- Replaced the reusable Outliner header's unconditional filter/plus controls
  with descriptor-driven branches for keying-set/keyframe actions, selection
  sync, ID filtering, override view mode, collection creation, and unused-data
  purging. The host still owns state and operator callbacks.
- Made the filter-text field a source-aware part of `BlenderOutliner`: it is
  shown in normal modes and Library Overrides Properties, but suppressed for
  lazy Library Overrides Hierarchies. Each embedding area supplies its own
  controller, so the reusable widget does not own filtering or persistence.
- Added a mode regression covering the visible controls and kept the existing
  normal View Layer presentation intact.
- A formatter invocation from the example package initially included the
  repository-relative `lib/src/editors.dart` path and reported it missing;
  the correct package-root formatter command then completed. The installed
  Dart binary still emits its known telemetry-file sandbox warning, but the
  requested files were formatted and all gates passed.

## 2026-07-15 — Matched Workspace add-on filtering anatomy

- Re-read `properties_workspace.py`. The Workspace tool panel's Filter
  Add-ons card has a header owner-filter toggle, source-shaped add-on rows
  with right-aligned enable states, and a distinct warning box for unknown
  owners; the previous showcase used three unlabeled left-side checkboxes.
- Added those visual states while keeping add-on discovery, owner filtering,
  enable/disable operators, and custom-property persistence caller-owned.
- Extended the existing Workspace tool regression to cover the warning and
  owner-filter surfaces.
- The focused test caught a 42 px overflow from the warning heading at the
  narrowest Tool sidebar; constraining the heading fixed the layout. The first
  full golden run then reported the four expected Tool-mode deltas, which were
  reviewed and refreshed after confirming they were the new Workspace rows.

## 2026-07-15 — Completed remaining Freestyle property families

- Re-read `properties_freestyle.py` and compared its registered panels with
  the existing View Layer and Material descriptors. The showcase had the
  major Freestyle line-style families but omitted Freestyle Alpha and
  Freestyle Animation, and the Material context omitted Freestyle Line.
- Added source-shaped base transparency/modifier affordances, animation
  action/slot selectors, and Material line color/priority controls. Operators,
  animation data, and renderer polling remain caller-owned.
- The source comparison also showed the line-style panels were incorrectly
  nested under the main Freestyle panel; they are now top-level siblings as
  Blender registers them, with only Edge Detection and Style Modules nested
  under Freestyle. A first focused test still queried the old parent and
  failed with `Bad state: No element`; the regression was updated to assert
  the corrected hierarchy. One retry used the example test path from the
  repository root and failed to load the file; the package-root rerun passed.

## 2026-07-15 — Matched the Status Bar source composition

- Re-read `space_statusbar.py` and the local `interface_template_status.cc`.
  Blender orders the status bar as input status, transient report banner,
  running jobs, and right-aligned status information; the showcase previously
  omitted the two middle regions.
- Added an explicit reusable center slot to `BlenderStatusBar`, then composed
  the existing `BlenderReportBanner` and `BlenderRunningJobsPanel` there with
  sample saved-report and asset-preview states. This keeps transient state and
  job ownership with the host while preserving Blender's visual ordering.
- Added boot assertions and refreshed the workspace baseline after visually
  checking the resulting status-bar density.

## 2026-07-15 — Filled remaining top-bar File and Edit submenu entries

- Compared the current `TOPBAR_MT_file` and `TOPBAR_MT_edit` registrations in
  `space_topbar.py` with the showcase menu descriptors. Added `Operator
  Search...`, the External Data path-repair/report actions, and both Purge and
  Manage Unused Data actions in source order. Also completed the Blender
  System submenu's redraw-timer and cleanup entries.
- Enumerated the local `bl_app_templates_system` directories and added the
  missing Storyboarding and VFX choices to File > New and Add Workspace.
- Extended the top-bar regression to verify those nested descriptors directly
  while keeping the menu's scrollable presentation unchanged.

## 2026-07-15 — Matched Properties rail scrolling and Output controls

- Replaced the visible Properties-tab scrollbar with edge fades that appear
  only when the rail has content above or below the viewport.
- Reduced panel and list resize grips while preserving their full drag hit
  areas, and added a filled range treatment to bounded numeric fields.
- Matched the Output group composition with a full-width path, Saving checkbox
  block, Color Depth choices, and Compression percentage control.

## 2026-07-15 — Stabilized the Preferences temporary-window route

- The focused regression showed that the Edit-menu callback was executing
  above `BlenderApp`'s `WidgetsApp`, so its state context could not push a
  dialog route. Added an optional navigator key to the reusable `BlenderApp`
  shell and used it for the showcase Preferences window.
- Kept the route push on the next frame because the source-shaped menu closes
  its popover in the same callback frame; this prevents popover cleanup from
  dismissing the newly opened temporary window.
- Refreshed the Preferences golden after the verified panel-navigation state
  changed its category labels. Flutter's formatter initially hit the SDK
  cache sandbox boundary; the installed Dart binary formatted the files, with
  only the known telemetry-file warning remaining.

## 2026-07-15 — Restored top-bar Edit menu completeness

- The complete example suite exposed a real source mismatch while validating
  the NLA work: local Blender's `TOPBAR_MT_edit` includes `Project Setup...`,
  but the showcase Edit menu stopped after Preferences. Restored the item in
  source order and confirmed the focused top-bar regression passes.
- The same gate surfaced two consistency issues in the existing dirty package
  changes: `BlenderMenuItem` consumers already used a `checked` field that its
  model lacked, and the newly registered undo/redo glyphs lacked painter
  cases. Added those missing visual-model cases and re-ran package analysis
  successfully.

## 2026-07-15 — Matched Edit menu and temporary Preferences window

- Read `TOPBAR_MT_edit` in `scripts/startup/bl_ui/space_topbar.py` and the
  Animation preference panels in `scripts/startup/bl_ui/space_userpref.py`
  from the local Blender checkout. The Edit menu's command order, separators,
  disabled Redo state, macOS shortcuts, Undo History submenu, checkbox, and
  Preferences action now follow that source arrangement.
- Added the reusable `checked` menu-item state and source-backed undo/redo
  glyphs. `Lock Object Modes` is now an actual persistent showcase toggle
  instead of an inert text item.
- Added `BlenderPreferencesWindow`, a temporary-window shell that reuses the
  existing category/section descriptors, owns its navigation and search state,
  and presents the source-shaped macOS title bar, sidebar, and scrollable
  panel content. The Edit menu opens it directly on Animation; Timeline,
  Keyframes, and F-Curves now use the fields from Blender's corresponding
  preference panels.
- The first menu integration attempted to push the temporary window before
  the Edit popover route had closed, so the popover cleanup dismissed the new
  route. Deferring the push by one frame and using the showcase navigator key
  makes the action reliable without coupling reusable menu controls to app
  navigation.
- Formatting first failed because the Flutter SDK cache is outside the
  workspace write sandbox. Re-running the same formatter with the required
  local SDK permission completed successfully; no source workaround was used.

## 2026-07-15 — Matched NLA header filters and playback footer

- Re-read `space_nla.py` and its shared `space_dopesheet.py`/`space_time.py`
  helpers in the local Blender checkout. The NLA header has inline selected,
  hidden, missing-strip, and error filters in addition to the Filters and
  Snapping popovers; the NLA editor also registers a separate footer with
  playback controls.
- Added those inline filter buttons and expanded the NLA Filters popover with
  F-Curve/collection search, type filters, transform/modifier filters, and
  data-block sorting. Added a reusable optional footer slot to
  `BlenderSequencerEditor` and `BlenderNLAEditor`, then wired source-shaped
  playback, frame, and playhead controls into the showcase NLA editor.
- Updated the focused NLA regression and golden. The initial footer patch put
  the optional field on the neighboring base editor constructor; the compile
  check caught that placement and the API was corrected before verification.

## 2026-07-15 — Matched main Timeline and Dope Sheet headers

- Re-read `space_dopesheet.py` and `space_time.py` in the local Blender
  checkout. The Dope Sheet header registers mode-specific View, Select,
  Marker, Channel, Key, and Action menus, while its header buttons expose
  Filters, Snapping, Proportional Editing, Action selection, and Overlays.
  Timeline adds Playback, Auto Keying, transport, frame, and Playhead
  snapping controls.
- Expanded the main Timeline/Dope Sheet editor header with those source-shaped
  menu families and controls. The existing bottom animation workbench already
  had a related surface and remains independently covered.
- The first implementation put the Action selector in the action scroll
  region, which squeezed its data-block field at narrow widths. Moving it to
  the fixed leading region preserves the source-visible selector and keeps
  the remaining menus/actions horizontally scrollable.
- Added a focused main-header regression and regenerated
  `showcase_main_animation_headers.png`.

## 2026-07-15 — Matched File Browser navigation header actions

- Re-read `FILEBROWSER_HT_header` in the local Blender checkout and compared
  its navigation/action cluster with the reusable `BlenderFileBrowser` header.
- Added visual Back, Forward, Parent Directory, Refresh, and New Folder
  controls to both File Browser and Asset Browser variants. Optional callbacks
  keep navigation, filesystem mutation, and status reporting owned by the
  embedding application.
- The focused File/Asset Browser regression initially attempted to find the
  wrapped tooltip widgets directly; the test now verifies the underlying
  source action glyphs instead. Both browser goldens were regenerated.

## 2026-07-15 — Revalidated standalone Properties panel composition

- Re-ran the focused `Output properties preserve Blender boolean row composition` golden after the editor source work.
- The failure was a stale checked-in golden containing only the panel header; the current bounded overlay/list layout rendered the complete Format panel with its numeric and boolean rows.
- Refreshed `test/goldens/output_format_properties.png` and confirmed the focused golden test passes. No functional Blender data-model behavior was introduced.

## 2026-07-15 — Reviewed residual Blender source-family boundaries

- Rechecked the coverage map against the local Blender source checkout after
  the Freestyle pass. The remaining `Partial` entries represent visual
  descriptors whose runtime polling, RNA/data ownership, persistence, or
  operator execution intentionally belongs to the embedding application.
- Documented that distinction in the coverage reference so future source
  audits can target genuinely missing visual anatomy instead of expanding the
  package into a Blender data-model implementation.

## 2026-07-15 — Added engine-aware Render Properties families

- Re-read `properties_render.py` and followed its engine polling: the existing
  Eevee-facing tree covered the `RENDER_PT_eevee_*` families, while the
  Workbench branch registers Sampling, Film, Lighting, Object Color, and
  Options panels alongside common Simplify, Color Management, and Freestyle.
- Made the Render Engine selector visual stateful. Selecting Workbench now
  replaces the Eevee-only Raytracing/Volumes tree with source-shaped Workbench
  groups and preserves the common panel hierarchy.
- Added a Workbench regression and golden. The example remains a visual
  descriptor surface; renderer selection and RNA ownership remain outside the
  showcase.

## 2026-07-15 — Corrected Preferences panel parent relationships

- Compared the Preferences panel registrations in `space_userpref.py` with
  the descriptor-backed category sections. Transparent Checkerboard is nested
  under Themes → User Interface → Editor & Widgets, while Auto Run Python
  Scripts is nested under Save & Load → Blend Files.
- Added the missing Transparent Checkerboard visual controls and moved Auto
  Run Python Scripts out of File Paths → Development into its source parent.
  The regression initially collapsed the already-expanded Blend Files card;
  removing that test-only tap verified the intended nested panel.

## 2026-07-15 — Matched Blender Properties context navigation

- Re-read `space_properties.py` and compared its `tabs_attr_infos` order with
  the showcase rail. The app was missing Particles, Bone, Bone Constraints,
  and Strip Modifiers, and its remaining context tiles were in a different
  order.
- Added the four missing visual contexts, moved the complete rail into
  Blender's source order, and routed Particles to the existing particle-system
  descriptor family. The dedicated Particles view unwraps the Physics-only
  Particle System container so its panels remain top-level. Bone, Bone
  Constraints, and Strip Modifiers reuse the existing source-shaped data,
  constraint, and modifier stacks.
- Added the source context rows that sit above those panels: the particle
  system list/actions, active-bone data field, and Add Object/Bone Constraint
  menus. A dense Bone Constraints header initially overflowed in the compact
  showcase; the shared panel header now bounds action clusters in a horizontal
  scroll surface.
- Rechecked the hidden-header context panels in the same source family and
  moved Render Engine and Scene selectors into their proper top rows instead
  of presenting Render Engine as a fabricated collapsible panel.
- Added a source-order regression, made offscreen tab tests scroll the actual
  Properties rail, and refreshed the affected showcase goldens. Data polling,
  tab persistence, and operators remain caller-owned.

## 2026-07-15 — Deepened Blender Particles context anatomy

- Re-read `properties_particle.py` after adding the dedicated Particles tab.
  The source makes Hair Dynamics a sibling of Emission, nests Collisions,
  Structure, and Volume below it, and nests each force-field Falloff panel
  below its Type 1 or Type 2 panel.
- Corrected those descriptor relationships and added representative source
  families for Vertex Groups, Textures, Hair Shape, Animation, and Custom
  Properties. The visual surface remains descriptor-driven; particle data,
  polling, animation, and operators remain caller-owned.
- Added descriptor-level regression assertions for the root families and the
  Hair Dynamics and force-field nesting. Full example/package suites and
  goldens remain the verification gates for this source pass.
- A first combined format/test command used example-relative paths from the
  example package directory; formatting reported no files before the test
  still ran. The formatter was rerun from the repository root successfully.

## 2026-07-15 — Matched View3D Tool paint panel hierarchy

- Re-read the shared brush definitions in `properties_paint_common.py` and
  their registrations in `space_view3d_toolbar.py`. In the View3D Tool
  sidebar, Brush Asset and Brush Settings are the peer panels; Advanced,
  Color Picker, Color Palette, Clone from Paint Slot, Cursor, Texture,
  Texture Mask, Stroke, and Falloff are nested below Brush Settings, with
  Stabilize Stroke below Stroke and Front-Face/Normal Falloff below Falloff.
- Corrected the initial shared-panel interpretation to match that actual
  View3D hierarchy. Clone Layer remains a context menu, not a panel, and the
  implementation retains representative source-shaped controls.
- The first asset selector used a data-block field inside a split property row
  and overflowed by 4.6 px at the narrow Properties widths. Replaced it with a
  compact asset button matching Blender's brush selector anatomy, then
  refreshed the workspace golden.
- The first full golden run also exposed two existing global-text assertions
  (`Tool` and `Brush Settings`) after the Tool context became richer; those
  checks now scope themselves to the Node and Image editor sidebars.

## 2026-07-15 — Added View3D Tool mode-specific panels

- Re-read the mode branches in `space_view3d_toolbar.py`. The source changes
  the Tool region by mode: mesh Edit Options contain Transform and UVs, Pose
  has Pose Options, Sculpt has Dyntopo, Remesh, Options/Gravity, and
  Symmetry, paint modes have symmetry/options families, and Particle Edit has
  Particle Tool plus nested cut/display options.
- Connected the existing showcase Mode selector to source-shaped visual state.
  Object Mode keeps Options/Transform; the other available modes now expose
  their matching panel labels, nesting, and representative controls without
  claiming Blender runtime mode or operator behavior.
- Added a sculpt-mode golden and regression coverage. A first focused run
  correctly reached the new state but reported the expected missing golden;
  the golden was then generated and the full example suite passed.
- One verification attempt used example-relative paths from the repository
  root and reported a missing-file diagnostic; rerunning from the example
  package root passed. The example analyzer also surfaced three new
  `prefer_const_constructors` infos, which were fixed before the final clean
  analyzer run.

## 2026-07-15 — Added View3D Grease Pencil Tool families

- Re-read the Grease Pencil registrations in `space_view3d_toolbar.py`.
  Draw mode keeps Advanced and Stroke families under Brush Settings, with
  Post-Processing, Randomize, and Stabilize Stroke below Stroke; Color is a
  peer with Palette below it. Weight Paint keeps Falloff under Brush Settings
  and exposes Options; Vertex Paint exposes Color/Palette and Falloff peers.
- Added explicit Grease Pencil Draw, Sculpt, Weight Paint, and Vertex Paint
  mode choices with representative material, brush, color, palette, falloff,
  cursor, stroke, and option controls. The implementation remains visual and
  does not claim Blender mode, brush, material, or paint-data behavior.
- Added Draw and Vertex Paint goldens plus focused hierarchy regressions. An
  initial Draw test exposed that the Stroke disclosure was below the viewport;
  the test now uses the sidebar's scroll-aware visibility step before tapping.

## 2026-07-15 — Covered remaining basic View3D Tool branches

- Compared the armature-edit and curves-sculpt registrations in
  `space_view3d_toolbar.py`. Armature Edit contributes an Options panel with
  X-axis mirror; Curves Sculpt contributes a Symmetry panel with X/Y/Z mirror
  controls.
- Added explicit Armature Edit and Curves Sculpt mode choices and their
  source-shaped panel bodies, with regression coverage for their collapsed
  disclosure state and child controls.

## 2026-07-15 — Added View3D Texture Paint utility panels

- Re-read the registration and draw code for `VIEW3D_PT_slots_projectpaint`,
  `VIEW3D_PT_slots_paint_canvas`, `VIEW3D_PT_slots_color_attributes`,
  `VIEW3D_PT_slots_vertex_groups`, `VIEW3D_PT_mask`,
  `VIEW3D_PT_stencil_projectpaint`, and the Image Paint Cavity Mask panel.
- Added the source-shaped Texture Slots, Canvas, Color Attributes, and
  Vertex Groups peer panels, plus Masking with nested Stencil Mask and Cavity
  Mask panels. The controls are representative visual surfaces; list data,
  image persistence, UV state, and paint operators remain caller-owned.
- Added a Texture Paint regression and golden. The focused test initially
  caught that this repository's `BlenderDataBlockField` requires an explicit
  item list; both placeholder data-block fields now provide one.

## 2026-07-15 — Kept status notification badges above the status surface

- Traced the extension-count badge being obscured to its negative-positioned
  overflow outside the status button, where the status bar scroll viewport
  could clip it.
- Kept the badge as the last child in the icon stack while allocating its
  bounds inside the 24px button, ensuring it remains visible and topmost next
  to editor panes.

## 2026-07-15 — Added a direct Components workbench entry point

- Kept `example/lib/main.dart` as the realistic Blender-style workspace, where
  the component catalog is available from the far-right `Components` tab.
- Added `example/lib/components_demo.dart` so the searchable workbench can be
  launched directly with `flutter run -d macos -t lib/components_demo.dart`.
- Documented both launch paths because the horizontally scrollable workspace
  header can place the Components tab outside a narrow window's initial view.

## 2026-07-15 — Kept compact search text inside field bounds

- Traced the data-block search clipping to the shared single-line text field:
  its 20px control height and 3px vertical inset left less room than the body
  text line after the border was applied.
- Reduced only the vertical inset to 1px, retaining the compact control height
  and horizontal padding while allowing search and text-field labels to fit.

## 2026-07-15 — Normalized disclosure arrow geometry

- Compared the local Blender disclosure SVGs and found that their landscape
  and portrait viewBoxes produce different painted bounds when both are fitted
  into the same square icon slot.
- Routed panel disclosure arrows through the package painter and made the down
  and right chevrons rotationally symmetric so collapsed and expanded states
  have the same visual scale.

## 2026-07-15 — Expanded top-bar menu families

- Re-read `scripts/startup/bl_ui/space_topbar.py` in the local Blender
  checkout, including the Blender application menu and the File, Edit, Render,
  Window, and Help menus.
- Expanded the showcase top bar with source-ordered command families,
  separators, New File and Recover submenus, screenshot/workspace commands,
  and the Blender System submenu.
- Added a regression that opens each top-bar family and checks representative
  source labels; the existing File/Import flow remains covered as well.

## 2026-07-15 — Matched the normal Outliner header

- Re-read `scripts/startup/bl_ui/space_outliner.py` and confirmed that the
  editor-menu row is conditional on the DATA API display mode.
- Removed the generic View/Select/Collection/Object menu row from the normal
  showcase Outliner area; its source-shaped display mode, filter, search, and
  restriction controls remain owned by `BlenderOutliner`.
- Preserved the source exception by exposing the Edit menu when the Outliner
  switches to DATA API mode, with keying-set and driver command entries.

## 2026-07-15 — Matched 3D Viewport transform header controls

- Re-read `scripts/startup/bl_ui/space_view3d.py`, especially
  `VIEW3D_HT_header.draw_xform_template`.
- Added source-ordered Transform Orientation, Pivot Point, Snap, and
  Proportional Editing controls to the showcase View3D header before its
  existing grid/wireframe controls.
- Added explicit widget keys and regression assertions for the four controls;
  transform state remains host-owned visual state.

## 2026-07-15 — Matched 3D Viewport display header controls

- Re-read the remainder of `VIEW3D_HT_header.draw` in the local Blender
  checkout, including object visibility, gizmo, overlay, X-ray, and shading
  controls and their source SVG assets.
- Added source-shaped gizmo and overlay popovers, X-Ray, Wireframe/Solid/
  Material Preview/Rendered controls, shading options, and the object
  visibility affordance to the showcase View3D header.
- Added the missing source icon mappings, focused widget assertions, and a
  regenerated viewport golden; shading selection only drives the showcase
  renderer's existing visual wireframe state.
- Added an opt-in scrollable menu/action layout to `BlenderAreaHeader` so the
  dense View3D header remains usable at the narrow editor widths covered by
  the example suite; the default layout for other editors is unchanged.
- The first focused example-test invocation from the repository root could not
  resolve `package:blender_ui_example`; the verified command runs from the
  `example` package root. The full suite then caught the narrow-header overflow
  and confirmed the scrollable layout fix across all example surfaces.

## 2026-07-15 — Matched Timeline and Dope Sheet header families

- Re-read `scripts/startup/bl_ui/space_dopesheet.py` and
  `scripts/startup/bl_ui/space_time.py` in the local Blender checkout,
  including the conditional Timeline versus Action menu and header-control
  branches.
- Replaced the bottom editor's generic animation menu inventory with source-
  ordered Timeline View/Marker and Action View/Select/Marker/Channel/Key/Action
  families, expanded the source item lists, and kept Action playback controls
  out of the Action header.
- Added source-shaped Playback, Auto Keying, Playhead, Dope Sheet Snapping,
  Proportional Editing, Filter, and Overlay popovers with focused assertions;
  the horizontal toolbar remains scrollable when the source menu families are
  wider than the available editor width.

## 2026-07-15 — Matched Graph Editor and Drivers header families

- Re-read `scripts/startup/bl_ui/space_graph.py` in the local Blender
  checkout, including the shared Graph/Drivers header and its distinct menu,
  normalization, ghost-curve, filter, pivot, snapping, and proportional
  branches.
- Added a dedicated Graph/Drivers header path instead of routing those editor
  types through the generic animation header. It exposes source-shaped
  View/Select/Marker/Channel/Key menus, with the Marker family omitted for
  Drivers mode, plus the source curve-control affordances and popovers.
- Added focused menu/control assertions and a Graph Editor golden; curve
  evaluation, driver execution, and playback remain host-owned visual state.

## 2026-07-15 — Matched Sequencer and Preview header families

- Re-read `scripts/startup/bl_ui/space_sequencer.py` in the local Blender
  checkout, including the view-type branches, source menu families, scene and
  overlap controls, snapping, display/channel controls, gizmos, and nested
  overlay panels.
- Added a dedicated Sequencer/Video Editing header path with Sequencer,
  Preview, and combined view choices; source View/Select/Marker/Add/Strip/Image
  menu inventories; scene, overlap, snapping, display, channel, gizmo, and
  overlay controls; and source-shaped overlay subfamilies.
- Extended the existing Sequencer regression and regenerated its golden;
  strip evaluation, media loading, and playback remain host-owned visual state.

## 2026-07-15 — Matched NLA Editor header families

- Re-read `scripts/startup/bl_ui/space_nla.py` in the local Blender checkout,
  including the source View/Select/Marker/Add/Track/Strip menus and Filters/
  Snapping header controls.
- Added a dedicated NLA header path with source menu inventories, filter and
  snapping popovers, and focused assertions while keeping action clips, tracks,
  and strip operations caller-owned.
- Regenerated the NLA golden after the header change; the focused regression
  passed alongside the existing Sequencer coverage.

## 2026-07-15 — Matched Clip Editor header families

- Re-read `scripts/startup/bl_ui/space_clip.py` in the local Blender checkout,
  including the Tracking/Mask mode branches and Clip/Graph/Dope Sheet view
  menu conditions.
- Added source-shaped Clip Editor mode/view selectors, tracking and masking
  menu families, lock/gizmo/overlay controls, and mask proportional editing;
  clip tracking and mask operations remain caller-owned.
- Extended the Clip Editor regression and regenerated its golden after the
  header pass.

## 2026-07-15 — Matched Image and UV Editor header families

- Re-read `scripts/startup/bl_ui/space_image.py` in the local Blender checkout,
  including its shared Image/UV menu conditions and transform/display header
  controls.
- Expanded the shared Image/UV header with source View/Select/Image/UVs menus,
  UV sync and selection controls, snapping, proportional editing, image pin,
  gizmo, and overlay controls while keeping image and UV data caller-owned.
- Extended the Image/UV regression and regenerated both editor goldens.

## 2026-07-15 — Matched Spreadsheet header family

- Re-read `scripts/startup/bl_ui/space_spreadsheet.py` in the local Blender
  checkout and confirmed that Spreadsheet has a View-only menu row followed by
  Only Selected and Use Filter controls.
- Routed the showcase Spreadsheet through a dedicated header, removed its
  generic Select menu, and added focused menu/control assertions.


## 2026-07-15 — Matched Asset Browser catalog tree

- Re-read `source/blender/editors/space_file/file_panels.cc` and the asset
  catalog tree surface in the local Blender checkout.
- Composed `BlenderFileAssetCatalogPanel` into the actual Asset Browser Tools
  sidebar, including library selection, refresh/bundle actions, and nested
  Environment/Studio Lighting/Outdoor catalog rows.
- Bounded the catalog panel within the scrolling sidebar after verification
  caught the source tree's expected finite-height requirement.

## 2026-07-15 — Expanded Output Properties panel families

- Re-read `scripts/startup/bl_ui/properties_output.py` in the local Blender
  checkout, including Post Processing, Metadata children, Views, output Color
  Management, Pixel Density, and conditional Encoding/Video/Audio panels.
- Added those source-ordered visual groups to the Output Properties context;
  output writing, codec selection, and engine polling remain caller-owned.
- Extended the focused Output regression to verify the lower panels through the
  editor's scroll surface and regenerated its golden.

## 2026-07-15 — Matched status-bar composition

- Re-read `scripts/startup/bl_ui/space_statusbar.py` and
  `source/blender/editors/interface/templates/interface_template_status.cc`
  in the local Blender checkout.
- Replaced the showcase footer's custom Global Search/F3 treatment with
  source-shaped input-status and status-info surfaces, retaining the live
  showcase message as host-owned state.
- Made `BlenderStatusBar` bound its left and right children through horizontal
  scroll surfaces; narrow shells no longer overflow when source status items
  and version/extension info are both visible.

## 2026-07-15 — Matched Texture User context

- Re-read `scripts/startup/bl_ui/properties_texture.py` and
  `source/blender/editors/space_buttons/buttons_texture.cc` in the local
  Blender checkout.
- Added Blender's source-shaped Texture User selector, with grouped Material
  and Modifier users, to the Texture Properties context. Texture datablock
  selection and user mutation remain caller-owned.
- Extended the Texture Properties regression and regenerated its golden.

## 2026-07-15 — Matched Preferences Asset Libraries

- Re-read `scripts/startup/bl_ui/space_userpref.py` and
  `source/blender/editors/space_userpref/userpref_asset_libraries_list.cc` in
  the local Blender checkout.
- Replaced the Preferences Assets section's generic buttons and path with the
  source-shaped selectable Asset Libraries panel, including built-in
  libraries, local/remote rows, enable state, path or repository URL, import
  method, relative paths, and Online Essentials.
- Extended the Preferences regression to enter the Assets category and verify
  these controls before returning to the existing golden state.

## 2026-07-15 — Matched File Browser header popovers

- Re-read `scripts/startup/bl_ui/space_filebrowser.py` in the local Blender
  checkout, including the File Browser and Asset Browser Display/Filter
  popovers and their source-specific property rows.
- Added source-shaped Display Settings and Filter Settings popovers to
  `BlenderFileBrowser`, with the Asset Browser variants for display type,
  asset-ID filters, and remote access. File enumeration and asset filtering
  remain caller-owned.
- Extended the File/Asset Browser regression to open both popover families;
  the focused golden and assertions pass.

## 2026-07-15 — Removed remaining showcase placeholders

- Replaced the Text Editor sidebar's literal `TODO` sample with a second
  source-neutral search value, changed the Image Editor caption to its actual
  editor name, and made utility-menu fallback labels use the selected editor's
  presentation name.
- The Image Editor golden was updated for the intentional caption change;
  library analysis and the complete example suite remain clean.

## 2026-07-15 — Matched Spreadsheet header controls

- Re-read `scripts/startup/bl_ui/space_spreadsheet.py` in the local Blender
  checkout, including selection filtering, generic filtering, and Internal
  Attributes visibility.
- Added Spreadsheet header controls for Use Filter, Only Selected, and
  Internal Attributes state, with a golden/regression covering the updated
  grid composition. Spreadsheet data extraction and filtering remain
  caller-owned.
- During narrow Components-workbench verification, the long Internal
  Attributes status initially overflowed the header; bounded it with a
  flexible ellipsized label so the source-shaped header remains responsive.

## 2026-07-15 — Matched utility editor menu contents

- Re-read the current `space_text.py`, `space_console.py`, `space_info.py`,
  `space_outliner.py`, `space_spreadsheet.py`, and `space_project.py` header
  menus in the local Blender checkout.
- Replaced the example's single placeholder option per utility menu with
  source-shaped entries for navigation, text editing, console operations,
  report actions, outliner modes, spreadsheet display, and project save/load.
  These entries remain visual descriptors and dispatch only showcase status.

## 2026-07-15 — Matched Movie Clip Editor sidebar families

- Re-read `scripts/startup/bl_ui/space_clip.py` in the local Blender checkout,
  including Track, Solve, 2D Stabilization, View, Footage/Proxy, Animation,
  and Mask panels.
- Added reusable `BlenderClipEditorSidebar` and composed it with the existing
  `BlenderMaskProperties` surface. Clip loading, tracking, solving, and mask
  operations remain caller-owned.
- Updated the Clip Editor golden/regression to cover the new source families.

## 2026-07-15 — Matched 3D Viewport sidebar families

- Re-read `scripts/startup/bl_ui/space_view3d.py`,
  `scripts/startup/bl_ui/space_view3d_sidebar.py`, and
  `scripts/startup/bl_ui/space_view3d_toolbar.py` in the local Blender
  checkout, including View, View Lock, 3D Cursor, Collections, Item/Transform,
  Tool, and Global Transform families.
- Added reusable `BlenderViewportSidebar` and wired it into the showcase 3D
  Viewport. Viewport state, object transforms, collections, and animation
  operators remain caller-owned.
- Added a focused 3D Viewport golden/regression covering the source sidebar
  families.

## 2026-07-15 — Matched Project editor surfaces

- Re-read `scripts/startup/bl_ui/space_project.py` in the local Blender
  checkout, including Navigation, General/Project settings, No Project, and
  Save Project execution surfaces.
- Added `BlenderProjectEditor`, added Project to the editor selector, and
  added a golden/regression. Project discovery, saving, and filesystem
  operations remain caller-owned.

## 2026-07-15 — Matched Text Editor sidebar families

- Re-read `scripts/startup/bl_ui/space_text.py` in the local Blender checkout,
  including Text Properties and Find & Replace panel contents.
- Added reusable `BlenderTextEditorSidebar` and wired it into the example Text
  Editor. The editor canvas remains independently composable while text
  datablocks, editing, and search execution remain caller-owned.
- Added a Text Editor golden/regression covering margin, font, indentation,
  find/replace, and search-option surfaces.

## 2026-07-15 — Matched Dope Sheet and Action sidebar families

- Re-read `scripts/startup/bl_ui/space_dopesheet.py` and
  `scripts/startup/bl_ui/space_time.py` in the local Blender checkout,
  including Action, Slot, View, Shape Key, Custom Properties, filters, and
  snapping families.
- Added reusable `BlenderDopeSheetSidebar` to the Dope Sheet/Action surface.
  The timeline canvas remains independent while keyframe editing, action
  datablocks, slots, and playback settings remain caller-owned.
- Updated the existing Action golden/regression to cover the new sidebar.

## 2026-07-15 — Matched Sequencer and NLA sidebar families

- Re-read `scripts/startup/bl_ui/space_sequencer.py` and
  `scripts/startup/bl_ui/space_nla.py` in the local Blender checkout,
  including cache, proxy, preview/view, safe-area, composition-guide,
  annotation, strip, action, and transform panel families.
- Added reusable `BlenderSequencerSidebar` and wired it into Video Sequencer
  and NLA surfaces. The timeline canvas stays independently composable while
  media evaluation, proxy generation, strip operations, and animation data
  remain caller-owned.
- Added Sequencer and NLA goldens/regressions and recorded the initial
  formatting telemetry filesystem limitation encountered during verification.

## 2026-07-15 — Matched Blender Preferences navigation and panels

- Re-read `scripts/startup/bl_ui/space_userpref.py` in the local Blender
  checkout, including its navigation bar and all current preference contexts.
- Replaced the example's four generic Preferences categories with the source
  category set and source-ordered panel families for Interface, Editing,
  Animation, System, Viewport, Themes, File Paths, Save & Load, Input,
  Navigation, Keymap, Extensions, Add-ons, Assets, Lights, Developer Tools,
  and Experimental.
- Added a Preferences golden/regression. Preference persistence and runtime
  configuration remain outside the visual package.

## 2026-07-15 — Matched File Browser and Asset Browser side panels

- Re-read `scripts/startup/bl_ui/space_filebrowser.py` in the local Blender
  checkout, including File Browser bookmarks/filter/path panels and Asset
  Browser library/catalog/metadata/import/preview/tag panels.
- Added reusable `BlenderFileBrowserSidebar` and wired it into both example
  browser modes. Nested browser lists use static rows inside the owning sidebar
  scroll region so the composition matches Blender's region ownership without
  introducing nested unbounded viewports.
- Added File Browser and Asset Browser goldens/regressions. File operations,
  asset catalogs, and metadata persistence remain caller-owned.

## 2026-07-15 — Matched Node Editor sidebar families

- Re-read `scripts/startup/bl_ui/space_node.py` in the local Blender checkout,
  including Tool, Node, View, Options, and Group sidebar panels.
- Added reusable `BlenderNodeEditorSidebar` and wired it into shader,
  compositor, geometry-node, and texture-node editor variants. The canvas and
  sidebar remain independently composable while node-tree behavior stays
  caller-owned.
- Added a Node Editor golden/regression covering the source sidebar families.

## 2026-07-15 — Matched Node Editor header families

- Re-read `scripts/startup/bl_ui/space_node.py` in the local Blender checkout,
  including the source-specific Shader, Geometry, Compositor, and Texture
  header branches and the View/Select/Add/Node menu families.
- Added source-shaped node-tree context/data-block controls, pin and snapping
  controls, compositor backdrop/gizmo controls, and a nested Node Editor
  Overlays popover while keeping node-tree behavior caller-owned.
- Added focused menu/control assertions and regenerated the Node Editor golden.
  The first pass also caught and fixed an unconstrained data-block dropdown in
  the shared header action row; the focused test and full example suite pass.

## 2026-07-15 — Matched Image and UV Editor sidebar families

- Re-read `scripts/startup/bl_ui/space_image.py` in the local Blender checkout,
  including shared paint/tool panels, image/render-slot/UDIM panels, View and
  Scopes families, UV controls, and image-editor mask panels.
- Added reusable `BlenderImageEditorSidebar` and wired it into both Image and
  UV Editor surfaces. The image/UV canvas remains independently composable;
  image data, paint operations, scopes, UV editing, and masks remain
  caller-owned.
- Added Image and UV Editor goldens/regressions covering the source sidebar
  families.

## 2026-07-15 — Deepened Physics Properties hierarchies

- Re-read the local Blender `properties_particle.py` and the Soft Body, Fluid,
  Dynamic Paint, Rigid Body, and Rigid Body Constraint source families.
- Replaced placeholder physics child headers with source-ordered nested panels
  and representative visual controls, including particle emission, velocity,
  physics, render, children, and force-field branches plus the soft-body goal,
  edges, and solver tree.
- Kept simulation state, modifier creation, polling, and operator execution
  outside the visual package. The focused Physics regression and golden pass.

## 2026-07-15 — Deepened Paint Common tool panels

- Re-read the source brush panels in `properties_paint_common.py`, including
  palette, clone, texture mask, stroke, stabilization, falloff, cursor, and
  clone-layer controls.
- Replaced the Tool sidebar's header-only brush sections with expandable,
  source-shaped visual controls while keeping brush assets, image layers, and
  paint operators caller-owned.
- Extended the Tool regression to open the Stroke panel and verify its spacing
  and input-sample controls.

## 2026-07-15 — Matched Sequencer Strip Properties anatomy

- Re-read `scripts/startup/bl_ui/properties_strip.py` and
  `properties_strip_modifier.py` in the local Blender checkout.
- Added reusable `BlenderStripProperties` with source-ordered Crop, Effect
  Strip and text Layout/Style/Outline/Shadow/Box children, Source, Movie Clip,
  Scene, Sound, Mask, Time, adjustment, Compositing, Transform, Video, Color,
  Custom Properties, and Modifiers panels.
- Added the Strip Properties regression and golden. Media loading, strip
  evaluation, and modifier execution remain caller-owned.

## 2026-07-15 — Audited remaining source-family boundaries

- Added explicit coverage entries for Output, Geometry Nodes physics, Strip,
  Strip Modifiers, Paint Common, and legacy Grease Pencil Material sources.
- Integrated the Geometry Nodes Simulation Nodes panel into the Physics context.
- Added the source-shaped Brush Asset panel and paint child-panel headers to
  the Tool sidebar. Paint mode state and brush operators remain caller-owned.

## 2026-07-15 — Matched Clip/Mask editor anatomy

- Re-read `scripts/startup/bl_ui/properties_mask_common.py` in the local
  Blender checkout, including Mask Settings, Mask Layers, Active Spline,
  Active Point, Animation, Mask Display, Transforms, Mask Tools, and the mask
  menu families.
- Added reusable `BlenderMaskProperties` and an optional sidebar slot on
  `BlenderClipEditor`. The example now wires the source-shaped Mask sidebar
  into its Clip Editor context, including bounded layer-list actions and the
  source panel nesting.
- Added package and example regressions plus the Clip/Mask golden. Mask
  geometry, tracking, and operator execution remain caller-owned.

## 2026-07-15 — Matched legacy Grease Pencil Material anatomy

- Re-read `scripts/startup/bl_ui/properties_material_gpencil.py` and its
  shared Grease Pencil material helpers in the local Blender checkout.
- Added the source-shaped Grease Pencil material branch beneath Material
  Properties, including Surface, Stroke, Randomize, and Fill panels with
  stroke mode/style and fill color controls. Legacy material polling, slots,
  drawing data, and operators remain caller-owned.
- Extended the Material Properties regression; the existing golden will be
  refreshed with the next full showcase run.

## 2026-07-15 — Audited shared animation, Grease Pencil, and mask helpers

- Re-read `properties_animviz.py`, `properties_grease_pencil_common.py`, and
  `properties_mask_common.py` in the local Blender checkout.
- Confirmed Motion Paths/Display is already represented through the Object and
  Armature contexts, and the Grease Pencil shared layer/material anatomy is
  represented through the Grease Pencil Data and Material branches.
- Recorded the mask helper as the final shared source family audited in this
  pass; it is now represented by the reusable Clip/Mask sidebar.
- Verification note: adding Physics to the existing context group initially
  pushed the Effects tab below the compact showcase rail. Physics now uses a
  separate rail group, preserving the established context order; the full
  golden refresh passes. The remaining SVG loader messages for Blender's
  `sodipodi:namedview`, `defs`, and `inkscape:path-effect` elements are
  non-fatal source-icon warnings.

## 2026-07-15 — Matched Freestyle Properties anatomy

- Re-read `scripts/startup/bl_ui/properties_freestyle.py` in the local Blender
  checkout. The source contributes a Render Freestyle panel and a nested View
  Layer line-set/style hierarchy.
- Added source-shaped Freestyle controls to Render and View Layer Properties:
  the render toggle and line-thickness fields, then Edge Detection, Style
  Modules, Freestyle Line Set, Visibility, Edge Type, Freestyle Strokes,
  Color, Thickness, Geometry, and Texture families. The stroke branch now
  includes chaining, splitting, sorting, selection, and dashed-line controls;
  the modifier branches include the source targets, ranges, and sampling
  fields that define their visible anatomy.
- Extended the Render and View Layer regressions with descriptor-level checks
  for the lazy-built Freestyle hierarchy and refreshed the View Layer golden.
  The first attempt to scroll to the offscreen Freestyle header failed because
  the lazy property list had not mounted that item; descriptor-level checks
  keep the regression deterministic without changing the runtime list.
  Freestyle engine polling, line-set data, and operators remain caller-owned.

## 2026-07-15 — Matched Tool-sidebar Workspace anatomy

- Re-read `scripts/startup/bl_ui/properties_workspace.py` in the local Blender
  checkout. The source panel is owned by the 3D View Tool sidebar and nests
  Filter Add-ons and Custom Properties below Workspace settings.
- Filled the existing Workspace panel with source-shaped scene pinning, mode,
  sequencer scene, scene-time synchronization, add-on filter rows, and custom
  property disclosure controls. Workspace ownership, add-on registration, and
  filtering remain caller-owned.
- Extended the Tool Properties regression to verify the nested Workspace
  anatomy. The example suite remains at 37 tests.

## 2026-07-15 — Matched Physics Properties anatomy

- Re-read `scripts/startup/bl_ui/properties_physics_common.py` and the local
  Blender Cloth, Soft Body, Fluid, Dynamic Paint, Force Field, Rigid Body,
  Rigid Body Constraint, and Particle source families.
- Added the `physics` glyph and Physics Properties context. The source-shaped
  add-physics grid is followed by the complete Cloth hierarchy, including
  Physical Properties, Stiffness, Damping, Internal Springs, Pressure, Cache,
  Shape, Collisions, Property Weights, and Field Weights. The other physics
  families are represented in source order as collapsed visual panels; physics
  modifier creation, simulation state, polling, and operators remain
  caller-owned.
- Added the Physics regression and golden. The example suite now passes all
  37 tests.

## 2026-07-15 — Matched Constraint Properties anatomy

- Re-read `scripts/startup/bl_ui/properties_constraint.py` in the local
  Blender checkout. The source uses a hidden-header Object/Bone Constraints
  context and instanced type-specific constraint panels.
- Added a Constraints Properties context using the shared
  `BlenderConstraintStack` for Copy Location, Child Of, Follow Path, Limit
  Rotation, and Armature cards, including source-style enable, menu, reorder,
  remove, target, and influence controls.
- Added the Constraint regression and golden. The example suite now passes all
  36 tests.

## 2026-07-15 — Matched Texture Properties anatomy

- Re-read `scripts/startup/bl_ui/properties_texture.py` in the local Blender
  checkout. The source order is Preview, Texture/Node, a type-specific panel,
  Mapping, Influence, Colors with Color Ramp, Animation, and Custom Properties.
- Added a Texture Properties context with source-shaped preview/type controls,
  procedural Clouds settings, mapping coordinates, influence factors, color
  processing, and Color Ramp nesting. Texture slots, procedural evaluation,
  and node ownership remain caller-owned.
- Added the Texture regression and golden. The example suite now passes all
  35 tests.

## 2026-07-15 — Matched Collection Properties anatomy

- Re-read `scripts/startup/bl_ui/properties_collection.py` in the local
  Blender checkout. The source order is Visibility with nested View Layer
  flags, Importer, Exporters, Instancing, Line Art, and Custom Properties.
- Added a Collection Properties context with source-shaped visibility flags,
  importer/exporter path controls, instancing offsets, and Line Art masks.
  Collection membership, import/export execution, and line-art data remain
  caller-owned.
- Added the Collection regression and golden. The example suite now passes
  all 34 tests.

## 2026-07-15 — Matched View Layer Properties anatomy

- Re-read `scripts/startup/bl_ui/properties_view_layer.py` in the local
  Blender checkout. The source order is View Layer, Passes with nested Data,
  Light, Shader AOV, Cryptomatte, and Light Groups panels, followed by Filter,
  Override, and Custom Properties.
- Added the `viewLayer` glyph and a dedicated View Layer Properties context
  with a source-shaped view-layer selector, bounded AOV/light-group lists, and
  render-pass controls. Render-layer state, engine polling, and operators
  remain caller-owned.
- Added the View Layer regression and golden. The example suite now passes
  all 33 tests.

## 2026-07-15 — Matched ShaderFX Properties anatomy

- Re-read `scripts/startup/bl_ui/properties_data_shaderfx.py` in the local
  Blender checkout. The source is a hidden-header Effects panel with an
  operator enum menu followed by the shader-effect template stack.
- Added the `shaderfx` glyph, an Effects Properties tab, and a source-shaped
  Add Effect menu with stacked Drop Shadow and Colorize cards. The shared
  `BlenderShaderEffectStack` supplies Blender's enable, reorder, remove, and
  collapsible-panel anatomy while effect data and operators remain
  caller-owned.
- Added the ShaderFX regression and golden. The example suite now passes all
  32 tests.

## 2026-07-15 — Matched active Bone Properties anatomy

- Re-read `scripts/startup/bl_ui/properties_data_bone.py` in the local Blender
  checkout. The source order is Transform, Bendy Bones, Relations with Bone
  Collections, Viewport Display with Custom Shape, Inverse Kinematics, Deform,
  and Custom Properties.
- Added the `bone` glyph and an active Bone visual state beneath the Armature
  hierarchy. The data context preserves the source panel nesting while pose,
  edit-mode polling, bone transforms, and armature operators remain
  caller-owned.
- Added the Bone Properties regression and golden. The example suite now
  passes all 31 tests.

## 2026-07-15 — Matched dynamic Grease Pencil Data anatomy

- Re-read `scripts/startup/bl_ui/properties_data_grease_pencil.py` in the
  local Blender checkout. The source order is Layers with nested Masks,
  Transform, Adjustments, Relations, and Display panels, Onion Skinning with
  Custom Colors/Display children, Settings, Animation, Custom Properties, and
  Attributes.
- Added the `greasepencil` glyph, a Grease Pencil object/data path, and the
  descriptor-driven Grease Pencil Data context. The compact Layers list keeps
  Blender's action-column anatomy while layer trees, drawing data, and
  operators remain caller-owned.
- Added the Grease Pencil Data regression and golden. The example suite now
  passes all 30 tests.

## 2026-07-15 — Matched dynamic Light Probe Data anatomy

- Re-read `scripts/startup/bl_ui/properties_data_lightprobe.py` in the local
  Blender checkout. The source order is Probe with nested Visibility, Capture,
  Bake with Resolution/Capture/Offset/Clamping children, Custom Parallax,
  Viewport Display, Animation, and Custom Properties.
- Added the `lightprobe` glyph, a Light Probe object/data path, and the
  descriptor-driven Light Probe Data context. Nested bake controls and
  source-default-collapsed display/parallax sections remain visual-only;
  probe capture, baking, engine polling, and RNA ownership remain caller-owned.
- Added the Light Probe Data regression and golden. The example suite now
  passes all 29 tests.

## 2026-07-15 — Matched Mesh Data Properties anatomy

- Re-read `scripts/startup/bl_ui/properties_data_mesh.py` in the local Blender
  checkout. The source order is a data-block header followed by Vertex Groups,
  Shape Keys, UV Maps, Color Attributes, Attributes, Texture Space, Remesh,
  Geometry Data, Animation, and Custom Properties.
- Added the `mesh` glyph and a Mesh Data Properties tab to the showcase. Added
  source-shaped list panels with action columns and reusable
  `BlenderPropertyGroup.content` support so list/tree anatomy remains separate
  from scalar property descriptors.
- Added the Mesh Data golden and regression. The first visual run exposed a
  four-pixel overflow in the five-button list action column; increasing the
  source-equivalent list slot resolved it. The final example suite passes all
  17 tests, including the refreshed Mesh Data baseline.

## 2026-07-15 — Matched dynamic Camera Data anatomy

- Re-read `scripts/startup/bl_ui/properties_data_camera.py`. Blender changes
  the Data context with the selected object and exposes Lens, Stereoscopy,
  Camera, Depth of Field/Aperture, Background Images, Viewport Display with
  Composition Guides, Safe Areas with Center-Cut Safe Areas, Animation, and
  Custom Properties.
- Made the showcase Data tab dynamic: the selected Camera now changes the data
  header icon/title and uses a source-ordered Camera panel tree, while the
  default Cube continues to use Mesh Data. This keeps the context-dependent
  tab model aligned with Blender rather than adding unrelated permanent tabs.
- Added a Camera Data regression and golden. The example suite now passes all
  18 tests; camera data and image/operator ownership remain caller-owned.

## 2026-07-15 — Matched dynamic Light Data anatomy

- Re-read `scripts/startup/bl_ui/properties_data_light.py`. The Light Data
  source order is Preview, Light, nested Shadow/Influence/Custom Distance/Beam
  Shape panels, Animation, and Custom Properties.
- Extended the dynamic Data context for selected lights with preview, energy,
  temperature, shadow, influence, distance, beam-shape, animation, and custom
  property rows. The context keeps engine and light-type branches visually
  represented without taking ownership of light data.
- Added a Light Data regression and golden. The example suite now passes all
  19 tests; the baseline has no layout overflow.

## 2026-07-15 — Matched dynamic Armature Data anatomy

- Re-read `scripts/startup/bl_ui/properties_data_armature.py` in the local
  Blender checkout. The source order is Pose, Viewport Display, Bone
  Collections, Inverse Kinematics, Motion Paths with Display, Selection Sets,
  Animation, and Custom Properties.
- Added the Armature data glyph, an Armature object/data path in the showcase,
  and a source-ordered Armature Data context. Bone Collections reuses the
  package tree template inside the Properties panel, preserving its status,
  visibility, solo, and action-column anatomy without coupling it to Blender's
  armature model.
- While refreshing the visual suite, the new outliner node exposed two real
  narrow-layout defects: nested expansion state was incorrectly discarded on
  parent rebuilds, and the Bone Collections columns needed a compact layout.
  The shared tree now reconciles expansion IDs recursively, and the bone
  collection template tightens indentation and restriction buttons only below
  the narrow-pane threshold. The example suite now passes all 20 tests with a
  refreshed Armature Data golden.

## 2026-07-15 — Matched dynamic Curve Data anatomy

- Re-read `scripts/startup/bl_ui/properties_data_curve.py` in the local
  Blender checkout. For a regular Curve data-block, the source order is Shape,
  Texture Space, Geometry with Bevel and Start & End Mapping children, Path
  Animation, Animation, and Custom Properties; text-only font and paragraph
  panels remain subtype-specific.
- Added the `curve` glyph, a Curve object/data path in the showcase, and a
  source-ordered Curve Data context. The visual descriptors represent curve
  dimensions, resolution, twist/fill, taper/bevel, path timing, and action
  selection without taking ownership of curve RNA or spline operators.
- Added the Curve Data regression and golden. The outliner-driven test scrolls
  to the source row at compact heights, and the example suite now passes all
  21 tests.

## 2026-07-15 — Matched dynamic Lattice Data anatomy

- Re-read `scripts/startup/bl_ui/properties_data_lattice.py` in the local
  Blender checkout. The source exposes one Lattice panel with U/V/W
  resolution, interpolation, Outside, and Vertex Group rows, followed by
  Animation and Custom Properties.
- Added the `lattice` glyph, a Lattice object/data path in the showcase, and a
  descriptor-driven Lattice Data context. The panel keeps Blender's split-row
  anatomy while leaving lattice points, shape keys, and deformation operators
  to the host.
- Added the Lattice Data regression and golden. The example suite now passes
  all 22 tests.

## 2026-07-15 — Matched dynamic Metaball Data anatomy

- Re-read `scripts/startup/bl_ui/properties_data_metaball.py` in the local
  Blender checkout. The source order is Metaball, Texture Space, Active
  Element, Animation, and Custom Properties, with element-type-dependent size
  rows represented in the active-element group.
- Added the `metaball` glyph, a Metaball object/data path in the showcase, and a
  descriptor-driven Metaball Data context. Visual controls remain host-owned;
  the context does not model meta-ball topology or edit/update execution.
- Added the Metaball Data regression and golden. The example suite now passes
  all 23 tests.

## 2026-07-15 — Matched dynamic Curves Data anatomy

- Re-read `scripts/startup/bl_ui/properties_data_curves.py` in the local
  Blender checkout. The source order is Surface, Attributes, Animation, and
  Custom Properties; the Attributes panel is a list with add, remove, and
  specials actions.
- Added the `curves` glyph, a Curves object/data path in the showcase, and a
  descriptor-driven Curves Data context with a representative source-style
  attribute list. Surface binding and attribute domain/type ownership remain
  outside the visual layer.
- Added the Curves Data regression and golden. The example suite now passes
  all 24 tests.

## 2026-07-15 — Matched dynamic Point Cloud Data anatomy

- Re-read `scripts/startup/bl_ui/properties_data_pointcloud.py` in the local
  Blender checkout. The source exposes Attributes and Custom Properties; the
  attribute list includes radius, color, id, velocity, add/remove, and specials
  affordances.
- Added the `pointcloud` glyph, a Point Cloud object/data path, and the
  descriptor-driven Point Cloud Data context. The shared list row now truncates
  detail text responsively, and the expanded attribute list uses a bounded
  compact viewport so Properties panels do not nest unbounded scrollables.
- Added the Point Cloud Data regression and golden. The example suite now
  passes all 25 tests.

## 2026-07-15 — Matched dynamic Speaker Data anatomy

- Re-read `scripts/startup/bl_ui/properties_data_speaker.py` in the local
  Blender checkout. The source order is Sound, Distance, Cone, Animation, and
  Custom Properties, with the Distance and Cone panels closed by default.
- Added the `speaker` glyph, a Speaker object/data path, and the
  descriptor-driven Speaker Data context with sound, attenuation, distance,
  cone, and action controls. Audio loading and playback remain host-owned.
- Added the Speaker Data regression and golden. The example suite now passes
  all 26 tests.

## 2026-07-15 — Matched dynamic Volume Data anatomy

- Re-read `scripts/startup/bl_ui/properties_data_volume.py` in the local
  Blender checkout. The source order is OpenVDB File, Grids, Render, Viewport
  Display with Slicing, Animation, and Custom Properties.
- Added the `volume` glyph, a Volume object/data path, and the
  descriptor-driven Volume Data context. The Grids list is bounded for the
  Properties viewport, while OpenVDB loading and engine-dependent branches
  remain host-owned.
- Added the Volume Data regression and golden. The example suite now passes
  all 27 tests.

## 2026-07-15 — Matched dynamic Empty Data anatomy

- Re-read `scripts/startup/bl_ui/properties_data_empty.py` in the local Blender
  checkout. The source exposes Empty display controls and a conditional Image
  panel with offsets, depth, side, visibility, and opacity settings.
- Added the `empty` glyph, an Empty object/data path, and the descriptor-driven
  Empty Data context. The image-specific settings are represented visually
  without owning image loading or viewport display behavior.
- Added the Empty Data regression and golden. The example suite now passes all
  28 tests.

## 2026-07-15 — Matched Timeline and Action editor controls

- Re-read `space_time.py` and `space_dopesheet.py`. The bottom animation
  editor now exposes source-shaped Filters, Snapping, Overlays, and Action-mode
  Proportional Editing popovers alongside the existing View, Marker, Select,
  Channel, Key, Action, Playback, and transport controls.
- Added source labels for summary/selection/error filters, datablock-type
  filters, snap targets, playhead snapping, overlay visibility, and
  proportional falloff/size. These controls are visual descriptors; Blender
  operator execution and animation-state ownership remain host responsibilities.
- Added `showcase_action_editor.png` and expanded the animation regression to
  open and verify the Filters and Snapping popovers. Example analysis and the
  focused golden test pass.

## 2026-07-15 — Matched Material Properties panel anatomy

- Re-read `scripts/startup/bl_ui/properties_material.py` and replaced the
  Material context placeholder with material-slot controls, active material
  selection, Preview, Surface, Volume, Displacement, Thickness, Settings,
  Viewport Display, Line Art, Animation, and Custom Properties panels.
- Added nested material Settings Surface/Volume controls and representative
  shader-link, render-method, culling, displacement, viewport, line-art, and
  animation rows. The slot and selector controls stay descriptor-driven while
  Blender node ownership and material operators remain host responsibilities.
- Added `showcase_material_properties.png` and a regression for the complete
  panel tree and source material-slot selector. The first baseline exposed a
  too-short slot-action column; increasing it to the source-equivalent list
  height removed the overflow.
- Focused example analysis and the Material Properties golden test pass.

## 2026-07-15 — Matched Modifiers Properties anatomy

- Re-read `scripts/startup/bl_ui/properties_data_modifier.py` and replaced the
  Modifiers context placeholder with the source Add Modifier menu categories:
  Edit, Generate, Deform, Normals, Physics, and Color.
- Connected those categories to the existing visual `BlenderModifierStack`
  with Bevel and Subdivision Surface panels, preserving Blender's enabled,
  viewport, render, reorder, and remove header affordances and representative
  settings rows.
- Added `showcase_modifier_properties.png` and a desktop-width regression. A
  first narrow-pane run correctly exposed dense modifier-header overflow; the
  baseline now uses a desktop-width Properties pane where Blender's full action
  anatomy is representable.
- Focused example analysis and the Modifier Properties golden test pass.

## 2026-07-15 — Matched World Properties panel anatomy

- Re-read `scripts/startup/bl_ui/properties_world.py` and replaced the World
  context placeholder with Surface, Volume, Mist Pass, Settings, Viewport
  Display, Animation, and Custom Properties panels.
- Added nested Light Probe, Sun, and Shadow settings plus the source data-block
  selector in the Properties header. World node links, renderer polling, and
  conversion operators remain visual descriptors owned by the host.
- Added `showcase_world_properties.png` and a regression for the complete panel
  tree, nested settings, and header selector. The focused test and example
  analysis pass.

## 2026-07-15 — Matched Scene Properties panel anatomy

- Re-read `scripts/startup/bl_ui/properties_scene.py` and replaced the Scene
  context placeholder with source-ordered panels for Scene, Units, Keying Sets,
  Audio, Gravity, Simulation, Rigid Body World, Light Probes, Animation, and
  Custom Properties.
- Added nested Keyframing Settings, Active Keying Set, and Rigid Body World
  Settings/Cache/Field Weights panels, along with source-shaped unit, audio,
  gravity-vector, simulation-range, cache, and animation controls.
- Kept body operators such as Bake Animation, Remove, and Bake All Light Probe
  Volumes in descriptor rows rather than panel headers after the focused visual
  test exposed narrow-Properties header overflow. This matches Blender's
  source placement and keeps the pane responsive.
- Added `showcase_scene_properties.png` and a regression for the full top-level
  tree and rigid-body child panels. Example analysis and the focused test pass.

## 2026-07-15 — Matched Render Properties panel anatomy

- Re-read `scripts/startup/bl_ui/properties_render.py` and replaced the
  Render-context placeholder with a source-ordered Eevee-facing panel tree:
  Render Engine, Sampling, Light Paths, Raytracing, Volumes, Depth of Field,
  Motion Blur, Film, Curves, Performance, Grease Pencil, Simplify, and Color
  Management.
- Preserved Blender's nested panel relationships and header-toggle treatment
  for Sampling children, Raytracing features, volume range, Motion Blur,
  Performance compositor settings, Simplify, and Color Management. The
  descriptor controls are intentionally visual-only; engine polling and RNA
  ownership remain outside the example.
- Added `showcase_render_properties.png` and a regression covering the complete
  top-level tree, Sampling children, Color Management children, and visible
  engine/sample controls. The focused test and example analysis pass.

## 2026-07-15 — Matched Object Properties panel anatomy

- Re-read `scripts/startup/bl_ui/properties_object.py` and aligned the example
  Object context with Blender's panel family: Transform, Delta Transform,
  Parent Inverse, Relations, Collections, Instancing, Motion Paths, Viewport
  Display, Shading, Visibility, Line Art, Animation, and Custom Properties.
- Added source-shaped descriptor rows for parent/display/axis enums, collection
  membership, instance offset, motion-path display, linking and terminator
  subpanels, visibility flags, line-art overrides, and custom-property values.
  The descriptors keep data/RNA ownership with the caller while matching the
  panel nesting, labels, controls, and source order.
- Extended the Object Properties regression to inspect the complete descriptor
  tree, scroll the lazy reorderable list to later rendered headers, and refresh
  `showcase_object_properties.png`. A deterministic drag sequence is used
  because rebuilding the lazy list makes `scrollUntilVisible` re-resolve more
  than one scrollable during the test.
- Focused example analysis and the Object Properties widget/golden test pass.

## 2026-07-15 — Added the comprehensive Components workbench and app services

- Promoted component discovery from the long bottom-editor catalog into a
  first-class `Components` workspace. The workbench provides searchable
  Overview, Controls, Layout, Data & Properties, Editors, and App Services
  pages while preserving the realistic dockable Layout workspace.
- Decomposed the new workbench into focused page and section widgets rather
  than adding more responsibilities to the existing showcase state class.
- Added optional, dependency-free application infrastructure:
  `BlenderStateStore`, bounded `BlenderHistoryStore`, typed state and service
  scopes, a parent-aware `BlenderServiceContainer`, and a reusable
  `BlenderCommandRegistry`.
- Used the services to power the workbench itself. All category controls edit
  one immutable state model, page-header undo/redo acts across categories, and
  command definitions are shared by direct actions and the Services page.
- Added package lifecycle, history, scope, circular-dependency, and command
  tests plus example navigation, search, service interaction, and golden
  coverage. The first golden run exposed an 11px feature-card text overflow;
  increasing the responsive grid extent and bounding secondary text fixed it.
- A workspace integration assertion initially appeared to show failed tab
  dispatch. The selected index was correct; the test had loaded
  `DemoWorkbench` through a relative URI while the app used its package URI,
  producing two Dart type identities. Canonicalizing the test import fixed the
  assertion. The tab loop now also uses explicit indexed entries and has a
  direct callback regression.
- Recorded the optional-service boundary and lifecycle rules in ADR-0005 and
  added root/example usage documentation.
- Final verification completed with clean package and example analysis, all 86
  package tests, all 10 example tests, and the Components visual baseline.

## 2026-07-15 — Matched texture-user jump-button visibility

- Re-read `buttons_texture.cc`. Blender only draws the “Show texture in
  texture tab” Properties button when a texture is assigned and the current
  Properties editor is not already on the Texture context.
- Added `hasTexture` and `inTextureProperties` descriptors to
  `BlenderTextureUserSelector`, preserving caller-owned disabled behavior while
  matching Blender's source-level omission states.
- Extended the texture-user regression for the hidden no-texture state;
  package analysis and the focused test pass.

## 2026-07-15 — Matched Preferences asset-library row states

- Re-read `userpref_asset_libraries_list.cc`. Blender keeps the fixed
  `All`/`Essentials` rows visually distinct from custom libraries, uses
  source-specific local/remote indicators and labels, disables removal for
  fixed rows, and disables Online Essentials when internet access is not
  available.
- Updated `BlenderAssetLibrariesPreferencesPanel` for source-backed built-in
  row anatomy, filled invalid-library indicators, `Repository URL`, `Import
  Method`, and `Use Relative Path` labels, fixed-row removal state, and
  caller-owned Online Essentials enablement.
- Extended the regression for local and remote settings. The focused package
  test passes. Package analysis and all 78 package tests pass; the example
  analysis and all 7 tests pass without golden changes.

## 2026-07-15 — Matched status-info issue and extension states

- Re-read `interface_template_status.cc`. Blender distinguishes blocked
  extensions from updates, uses `internet_offline.svg` and `uv_sync_select.svg`
  for offline/checking states, and composes warning text/tooltips for newer
  files, asset-edit files, and missing color-management configuration.
- Added the source-backed `sync` glyph and extended `BlenderStatusInfo` with
  blocked/offline/checking/update visual states plus caller-owned file-issue
  descriptors. Warning-only issues keep Blender's icon segment without forcing
  a fabricated message; runtime status discovery and operators remain outside
  the widget.
- Expanded the status regression to cover blocked extensions, generated
  warning text, and the asset-system tooltip. Dart formatting initially caught
  a delimiter mismatch during the edit; the affected operator-dialog nesting
  was restored before analysis. Package analysis and all 78 package tests pass;
  example analysis and all 7 tests pass without golden changes.

## 2026-07-15 — Matched the running-jobs status strip

- Re-read `interface_template_running_jobs.cc`. Blender's template combines a
  job name/icon with a progress-and-stop row, adds elapsed/remaining timing in
  the progress tooltip, and can append animation-player and remote asset
  download rows.
- Extended `BlenderJobProgress` with the source timing tooltip, optional
  operation-icon action, exact canceling label, and source stop tooltip.
  Added `BlenderRunningJobsPanel` for the animation stop control and the
  separate `Downloading Assets` progress anatomy, plus the source-backed
  `asset_manager.svg` glyph with a built-in fallback drawing.
- Added a focused regression for all of these visual states. Early assertions
  exposed both the stop-action tooltip and the progress-bar status text as
  additional source-backed surfaces; the test was corrected to assert those
  intentional duplicates. Package analysis and all 78 package tests pass;
  example analysis and all 7 tests pass without golden changes. The expected
  local Blender SVG parser warnings remain non-fatal.

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
- Added Object-context interaction and golden coverage, then verified all 78
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

## 2026-07-15 — Matched unreadable file-library diagnostics

- Compared `file_draw_invalid_library_hint()` in `space_file/file_draw.cc` with
  the existing centered asset-availability cards. Blender uses a separate
  top-left diagnostic layout for unreadable `.blend` libraries: a heading,
  path, and one icon-marked report row per non-info report.
- Added `BlenderFileBrowserUnreadableLibraryHint` and the immutable
  `BlenderFileBrowserReport` descriptor. The host still owns file loading and
  report generation; the package only preserves the source-defined layout and
  severity icon mapping.
- Added a showcase state and a focused widget regression. The package and
  example verification remain the required gates for this visual-only change;
  the final run passed all 88 package tests and all 16 example tests.

## 2026-07-15 — Preserved texture-jump disabled reasons

- Rechecked `uiTemplateTextureShow()` in `buttons_texture.cc`. Blender keeps
  the Properties jump button visible when a texture exists but distinguishes
  the disabled tooltip for a missing unpinned Properties editor from a missing
  texture-user match.
- Added `showTextureDisabledTooltip` to `BlenderTextureUserSelector`, keeping
  the visual button state and the caller-owned reason separate. The default
  remains the package's existing generic message for compatibility, while
  callers can provide Blender's source-specific text.
- Extended the focused texture-user regression to verify the disabled reason
  through the public semantics contract.

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
## 2026-07-15 — Matched utility editor menu families

- Compared `space_console.py` and `space_info.py` in the local Blender checkout
  with the showcase utility-editor header.
- Replaced the simplified Info menu with Blender's Select All, Deselect All,
  Invert Selection, Toggle Selection, Select Box, Delete, and Copy commands.
- Added the Console delete-word commands and its Area entry to the source-order
  View/Console families.
- Recorded the source paths in `docs/reference/blender-ui-coverage.md`.
