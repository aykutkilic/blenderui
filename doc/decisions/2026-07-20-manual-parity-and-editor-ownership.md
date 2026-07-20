# Manual parity inventory and editor ownership

Date: 2026-07-20

Status: Accepted

## Context

The Blender manual exposes 33 top-level interface topics and 23 editor types.
BlenderUI already represented most of their visible anatomy, but the evidence
was split across a source-family coverage map and app-owned header builders.
That made it difficult to prove editor-by-editor completion and allowed shared
menu construction to remain in the example app.

## Decision

1. Keep a manual-facing backlog with one row per documented editor and one row
   per top-level interface topic.
2. Treat official manual screenshots as visual requirements and the local
   blenderapp checkout as the implementation/anatomy source of truth.
3. Put reusable chrome, models, controls, panels, menus, and interactions in
   `blenderui`. The example app owns only sample data, app state, callbacks,
   scene/domain rendering, and composition.
4. Extract repeated constructs before adding another editor-specific copy.
   `BlenderEditorMenuCatalog` is the first extraction and is used by all nine
   existing non-node header builders. `BlenderUtilityEditorHeader` then owns
   the complete utility/data-editor menu family while accepting host mode and
   command callbacks.
5. Keep Blender's RNA, operators, evaluation, persistence, and runtime polling
   caller-owned. Visual parity does not justify coupling this Flutter package
   to Blender data structures.
6. Model platform-sensitive tools such as the eyedropper as reusable visual
   state and callbacks. Sampling the desktop and applying the sampled value are
   host responsibilities.
7. Model shared stateful editor chrome as one immutable public value plus a
   replacement callback. The Image/UV header is the first implementation: its
   mode, UV selection, snapping, proportional, pin, gizmo, and overlay values
   are host-owned without exposing the widget's popover lifecycle as state.
8. Treat toolbars, sidebars, and mode-specific asset shelves as editor regions,
   not application docks. `BlenderImageEditorLayout` is shared by Image and UV
   canvases, and `BlenderImageEditorToolShelf` owns the stable source taxonomy.
9. Apply the immutable public-state/replacement-callback pattern to every
   stateful header family: View3D, Dope Sheet/Timeline, Graph/Drivers, NLA,
   Sequencer, Clip, Image/UV, and Spreadsheet. Popover visibility remains
   transient widget state.
10. Keep embedded-area selectors composable. `BlenderAreaHeader.editorSelector`
    allows the bottom demo area to retain its app-specific tab selector while
    reusing the package's Dope/Timeline header; keyed menu descriptors preserve
    stable interaction tests after extraction.
11. Treat selection and transforms as reusable gesture policies whose results
    are host-owned. Trees emit complete selected-ID sets; the Node Editor emits
    selected-node sets and grouped node-to-position transactions.
12. Require one deterministic 1200×700 reference for each of the 23 documented
    editor types before the manual-facing row is marked Covered.
13. Represent nested Node Editor navigation as an immutable path supplied by
    the host. Duplicate and Cut Links produce graph transactions through
    callbacks; the package owns gesture policy and geometry, while identity
    allocation, persistence, evaluation, and undo remain host responsibilities.
14. Treat `minimumAreaExtent` as both a gesture clamp and a child-layout
    contract. When the complete window is smaller than the accumulated dock
    minima, keep each leaf's internal layout at that minimum and clip it to the
    real area instead of passing impossible constraints into editor Flex rows.
15. Use blenderapp's 11-point UI font constants as the shared typography
    baseline. Font assets remain independent, but editor-specific size
    compensation is rejected in favor of one source-backed token decision.
16. Start the example 3D View with its sidebar collapsed, matching Blender's
    factory workspace. The viewport owns its category-specific sidebar
    composition, so it does not expose an unused host-provided sidebar input.
17. Derive View3D chrome dimensions from blenderapp constants rather than
    screenshot-local magic numbers. The reusable toolbar uses the source's
    56 px column-plus-margin width, 40 px buttons, and 32 px toolbar glyphs;
    navigation uses the 80 px main gizmo and 28 px mini-gizmo baseline.
18. Keep app-wide UI preferences independent from editor-specific source
    geometry. A trial global 1.8 scale matched one Retina capture but broke
    minimum-area contracts across unrelated editors, so the app retains its
    user-controlled default while reusable controls scale from theme density.
19. An untitled `BlenderRegion` is an editor canvas and must remain flush with
    its neighboring header and borders. Panel padding is retained only for
    titled panel regions. At collapsed dock extents, headers preserve the
    editor selector and clip remaining chrome before fixed controls overflow.
20. Do not represent every header choice with `BlenderDropdown`. Blender's
    Object Mode control is an `operator_menu_enum` with mode icons and no
    checkmark column; Transform Orientations is a header `Panel` with a title,
    expanded connected rows, an anchored pointer, and a separate create
    action. These remain distinct reusable selectors with caller-owned values.

## Consequences

- Progress is measurable against the manual rather than against whichever
  implementation files were recently touched.
- Editor-family extractions can share one stateful library widget while keeping
  different sample documents in the app.
- The package public API grows only when a reusable source-shaped concept has
  been identified; temporary example helpers are not promoted blindly.
- Rendered evidence is still required before a row moves from Active to
  Covered.
- App-only header builders can be deleted rather than retained as forwarding
  wrappers. The animation migration removed `animation_menus.dart` and reduced
  the example header files to state wiring and composition.
- Browser sorting, asset preview construction, Spreadsheet filters/scrolling,
  tree selection, and Node selection/transforms are package policies, while
  filesystem, asset, geometry, and graph documents remain application data.

## Experience

- Direct browser automation failed twice because its execution context lacked
  sandbox-policy metadata. Direct official-document downloads succeeded after
  scoped network approval and retained the exact current HTML/image references.
- Top-level editor index pages do not always contain their representative
  screenshot. The screenshot often lives on the first Introduction page; Node
  Editor chrome is documented in the shared interface section.
- A first contact-sheet attempt emitted font warnings while labeling images,
  but the image montage itself was valid and sufficient for visual inspection.
- The local blenderapp checkout has an unusual index/worktree presentation in
  which tracked files appear deleted while replacement paths are untracked.
  Read-only source inspection remained valid; the checkout was not repaired or
  modified because that was outside this task.
- The first example header used popover open/close notifications as the snap
  and proportional values. Source inspection showed paired toggle and popover
  controls, so the reusable header separates persistent state from transient
  overlay lifecycle.
- A focused example test initially assumed render-only commands and UV snapping
  existed in Image View mode. Correcting the assertions exposed and retained
  Blender's `show_render` and `show_uvedit` conditions instead of preserving
  convenient but inaccurate demo behavior.
- Flutter widget-test goldens use deterministic test glyph metrics, so the
  committed Image/UV references are durable region, density, state, and overlay
  comparisons. Official manual screenshots remain the typography/content
  reference for human review.
- The architecture guard rejected the first 775-line Image header extraction.
  Splitting stable menu catalogs into `image_editor_header_menus.dart` kept the
  guard meaningful instead of weakening its limit. Dope Sheet and Sequencer
  use the same split.
- Removing the app animation menu file initially left Sequencer referencing
  `_animationMarkerMenuItems`. Moving that taxonomy into the reusable
  Sequencer menu catalog resolved the dependency instead of restoring a shared
  app helper.
- A focused example test fragment was invoked directly even though it is a
  Dart `part` without `main`; the package tests were valid, and the example
  path is intentionally verified through its aggregate suite.
- The grouped Node move helper initially used an invalid collection-expression
  pattern and failed at parse time. Replacing it with an explicit key check
  restored analysis before any runtime verification was accepted.
- Modifier-key Node selection needed a settled Focus frame in widget tests.
  The reusable canvas now owns an explicit FocusNode and caches modifier
  key-down/up state, matching the tree selection policy and avoiding dependence
  on incidental application focus.
- Visual inspection of the generated Spreadsheet reference found that a table
  narrower than its viewport centered itself. Expanding the shared content
  width to the viewport minimum restored Blender's left-aligned data grid and
  retained one horizontal controller for header/body synchronization.
- The final reference set covers all 23 manual editor types. Test glyphs remain
  a geometry baseline; the downloaded manual images remain the human
  typography and content-density comparison.
- Node-group breadcrumbs initially risked consuming the entire header for deep
  paths. A bounded horizontal viewport preserves the surrounding controls and
  lets callers expose arbitrary nesting without a second header variant.
- Cut Links uses the same resolved Bézier geometry as painting and samples it
  into line segments for hit testing. This keeps rendering and interaction in
  agreement without introducing a separate approximation owned by the app.
- macOS accessibility control was unavailable, so native window IDs were read
  through CoreGraphics and only the two requested application windows were
  captured. A full-desktop screenshot was rejected because it could include
  unrelated application content.
- `flutter run` did not propagate the controlled-size environment into the
  launched app, and state restoration initially replaced the runner's frame.
  The example runner now applies `BLENDERUI_WINDOW_SIZE` on the next main-loop
  turn with restoration disabled only for that verification launch.
- The first 420×300 pass exposed fourteen horizontal Flex overflows. Fixing
  each visible symptom alone would have left the dock contract false; enforcing
  a minimum internal leaf canvas resolved the vertical case and compact
  component policies resolved genuinely narrow horizontal content.
- The screenshot-sizing pass initially raised the example's global UI scale
  to 1.8. Native rendering looked plausible in isolation, but the full widget
  suite exposed widespread minimum-pane failures. Keeping source-sized View3D
  chrome separate from the user preference produced the durable solution.
- The in-app browser again could not start because its execution context lacked
  sandbox-policy metadata. Native validation used the already documented
  CoreGraphics window-ID capture path and never captured the full desktop.
- A later popup audit hit the same missing browser metadata, and synthetic
  native clicks did not reach Flutter reliably. Deterministic Navigator-overlay
  goldens now cover both open selector states instead of accepting an
  unverified native interaction.
