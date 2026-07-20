# Development history

This is the retained milestone record for BlenderUI. Superseded, task-by-task
parity notes were removed on 2026-07-17; their lasting architectural decisions
live in [the decision records](decisions/).

## 2026-07-20 — Established manual-wide UI/editor parity backlog

- Fetched the current Blender 4.5 LTS User Interface and Editors indexes,
  followed all 23 editor entries to their representative screenshots, and
  inspected the images in contact sheets.
- Cross-referenced every editor family with the local blenderapp source
  snapshot and the current reusable BlenderUI surface. Added the active
  [manual parity backlog](manual-ui-editor-parity-backlog.md), including one
  row per top-level interface topic and editor type.
- Accepted a strict ownership rule: shared chrome, controls, descriptors,
  models, layout, and interactions stay in the library; the example app keeps
  sample data, app state, callbacks, domain rendering, and composition.
- Moved the menu-descriptor factory used by nine app-owned header families into
  the public `BlenderEditorMenuCatalog` and added focused API coverage. This is
  the first extraction in the planned editor-family header migration.
- Added `BlenderUtilityEditorHeader` so Text, Console, Info, Outliner,
  File/Asset Browser, Spreadsheet, Project, Properties, and Preferences menu
  anatomy no longer lives in the example app. Data API mode and command
  execution remain app inputs.
- Closed the manual's generic Eyedropper gap with a reusable active/disabled
  `BlenderEyedropper`; screen sampling and document mutation remain host-owned.
- Added the public `BlenderImageEditorHeader` and immutable header state. It
  owns the source-conditioned Image/UV menus and separates each persistent
  toggle from its settings popover; the example now supplies state and command
  callbacks instead of duplicating the header.
- Added shared Image/UV region geometry and mode-aware tool shelves based on
  `space_toolsystem_toolbar.py`. Removed the unrelated View3D shelf from those
  editors, attached the brush asset shelf only in Paint mode, and removed the
  redundant internal editor-title row.
- Added deterministic 1200×700 Image and UV rendered references plus focused
  source-taxonomy, state-lifecycle, region-size, and app-integration coverage.
- Extracted immutable public header/state widgets for View3D, Dope
  Sheet/Timeline, Graph/Drivers, NLA, Sequencer, Clip, and Spreadsheet. Added
  keyed menu descriptors and an `editorSelector` override so embedded areas can
  reuse the same headers without losing application-specific area switching.
- Deleted the obsolete 557-line example `animation_menus.dart` and replaced
  the large app-owned animation, sequencer, clip, spreadsheet, and View3D
  header builders with concise state/callback wiring. Stable menu catalogs were
  split beside their owning library headers rather than weakening the
  repository's per-file architecture limit.
- Added reusable Graph/Drivers sidebars and driver-variable panels, the shared
  animation playback footer, and nullable body titles so extracted headers do
  not leave duplicate internal title bars.
- Added selected/query filtering, sortable columns, row selection/numeric
  alignment, row indices, and external horizontal/vertical controllers to the
  Spreadsheet. Visual review caught and fixed narrow tables centering in wide
  viewports.
- Added File Browser Name/Date/Size/Type sorting with folder-first semantics,
  structured metadata, and caller-supplied Asset Browser preview builders.
- Extended the existing generic tree drag/drop policy with host-owned
  range/toggle selection and arrow/Enter keyboard navigation. Extended the
  Node Editor with host-owned multi/box selection, grouped move transactions,
  and optional grid snapping, plus graph-model helpers that apply those
  transactions without putting documents in widget state.
- Completed reusable Node editing/group workflows with an overflow-safe
  immutable group breadcrumb path, host-generated subgraph duplication, a
  sampled Bézier cut-link operation, and a Cut Links canvas-tool stroke wired
  by the example app.
- Replaced repeated Node, Sequencer, and Clip annotation rows with one immutable
  `BlenderAnnotationSettingsPanel`. Added a Text status footer, Console command
  history navigation, and selectable/severity-filtered Info rows.
- Added and visually inspected deterministic 1200×700 references for all 23
  manual editor types. Flutter's Ahem glyphs are used only as stable geometry
  evidence; official manual images remain the human text/typography reference.
- Final verification passed root and example analysis, the 301-file structural
  guard, all 223 package tests, and all 70 example-app tests.
- Recorded browser bootstrap failure, scoped manual download fallback, contact
  sheet warning, and the local blenderapp checkout's unusual read-only Git
  presentation in the
  [decision record](decisions/2026-07-20-manual-parity-and-editor-ownership.md).

## 2026-07-20 — Optimized node rendering, enabled port links, and unified icons

- Revisited blenderapp's node drawing and View2D implementation after the
  Geometry Node Editor showed poor interactive rendering. The audit confirmed
  view-rectangle rejection for nodes and frames, viewport-counted adaptive
  grid points, and batched socket/link submission.
- Replaced whole-document Flutter composition with viewport node culling,
  link-path rejection, viewport-only adaptive grid painting, per-node and
  wire-layer repaint boundaries, and transient editor-owned dragging that
  commits to the host once on release.
- Removed `InteractiveViewer` from gesture ownership after focused tests proved
  its scale recognizer competed with node and socket pans. The canvas now uses
  Blender-style middle-button panning and pointer-wheel zoom, leaving the
  primary button to node movement and socket connections.
- Added stable socket references, typed connection validation, single-input
  replacement, multi-input preservation, snapped link previews, and normalized
  output-to-input callbacks. The example now persists mutable link lists and a
  widget test performs a real Geometry Nodes reconnection.
- Researched current Material icon options and adopted the maintained Material
  Symbols package as the default semantic icon backend. A full
  `BlenderGlyph` mapping revamps existing application icons without copying
  Blender's GPL assets; variable font axes provide the compact outlined style,
  and the independent vector backend remains opt-in.
- Recorded source evidence, licensing boundaries, interaction failures, test
  corrections, and verification in
  [`2026-07-20-node-performance-connections-and-symbol-icons.md`](decisions/2026-07-20-node-performance-connections-and-symbol-icons.md).
- The example web server launched for a final visual inspection, but the in-app
  browser was unavailable because sandbox-policy metadata was missing. The
  server was stopped; full Flutter render/layout tests remained the verification
  source instead of switching to an unapproved browser surface.

## 2026-07-19 — Added source-shaped, target-aware context menus

- Traced blenderapp's common button popup assembly, region context operator,
  abstract-view target activation, and Outliner, View3D, Node, File Browser,
  property, tool, and area menu families.
- Added reusable viewport-constrained menu presentation, stable common action
  catalogs, and target-aware builders for trees/lists, Outliner, files, nodes,
  Properties, and tool shelves. Applications continue to own commands and
  mutations.
- Replaced the example app's generic three-action editor menu with active
  editor catalogs and per-entity routing. Secondary clicks now select the
  pointed entity before opening its menu.
- Added behavioral coverage for menu grouping and disabled state, window-edge
  placement, action selection, target ordering, and file/node identity. The
  source analysis and ownership boundary are retained in
  [context-menu parity](context-menu-parity.md) and the
  [context-menu ownership decision](decisions/2026-07-19-context-menu-ownership.md).
- Tooling note: Flutter's formatter/test runner needed access to its shared SDK
  cache outside the repository sandbox and was rerun with scoped permission.
- The focused showcase test initially assumed one rendered status label; the
  shell deliberately mirrors status in two surfaces. The assertion now checks
  that the routed entity/action message is present without coupling the test to
  that application-layout count.

## 2026-07-19 — Added Blender area-edge options to docking

- Traced blenderapp's `screen_area_options_invoke()`, edge selection, area
  join, and area swap operators, then added the matching titled divider menu:
  Vertical Split, Horizontal Split, directional Join actions, and Swap Areas.
- Added atomic controller operations that preserve Blender's directional join
  semantics and swap editor contents without changing geometry. Nested split
  edges resolve the two rendered leaf areas at the pointer rather than acting
  on whole subtrees.
- Wired the behavior through the reusable docking workspace, workspace host,
  and application shell, so the example app receives it without app-local
  menu code. Added package controller/widget coverage and a real showcase-path
  regression.
- Recorded source anchors, the centered-split adaptation, icon provenance, and
  the Flutter gesture-arena correction in
  [the area-edge options decision](decisions/2026-07-19-area-edge-options.md).
- Tooling note: wrapping a resize detector with the declarative context-menu
  widget did not receive secondary clicks because the drag recognizer won the
  gesture arena. A focused test drove the shared imperative presentation path.
  Formatter and tests again needed scoped Flutter SDK-cache access.

## 2026-07-17 — Audited source-size and duplication boundaries

- Measured the Dart tree and recorded the original 750-line cleanup plan. The
  completed plan was retired on 2026-07-19; its lasting rules are now in
  [reviewable codebase boundaries](decisions/2026-07-19-reviewable-codebase-boundaries.md).
- Identified repeated property-sidebar helpers, descriptor factories, category
  and tree navigation, menu overlay placement, persistence lifecycles, and
  status/report presentation as cleanup targets.
- Preserved the existing ownership rule: reusable shell and interaction
  mechanics belong to BlenderUI, while showcase data and domain examples stay
  in the example app. No runtime code was changed during this audit.

## 2026-07-17 — Audited example and library ownership boundaries

- Audited the example app's reusable editor chrome, service glue, property
  factories, viewport behavior, status composition, platform integration, and
  documentation utilities against the current public BlenderUI APIs.
- Added and completed a decision-ready framework extraction queue. The active
  ownership rules now live in
  [reviewable codebase boundaries](decisions/2026-07-19-reviewable-codebase-boundaries.md).
- Kept every extraction candidate proposed rather than treating the audit as
  implementation approval. Existing public APIs must be extended or
  consolidated before introducing parallel abstractions.

## 2026-07-17 — Matched Blender factor sliders and number handles

- Compared the Properties render controls with local blenderapp sources. The
  `shadow_resolution_scale` RNA property is a `PROP_FACTOR` in
  `rna_scene.cc`, which Blender routes to `ButtonType::NumSlider`; its
  `widget_numslider` paints the proportional fill and does not draw number
  arrows.
- Added `BlenderNumberField.showSteppers` so factor sliders can use the full
  field without increment handles, while ordinary number fields retain their
  hover controls. Replaced text chevrons with centered vector glyphs so their
  vertical alignment is independent of font metrics.
- Updated the live Properties and Showcase render examples to use the
  Blender-style `0..1` Resolution factor and added focused coverage for its
  fill and no-stepper behavior.
- Kept the factor fill behind the inline text editor as well, so the visual
  state does not disappear when a user clicks into the value.
- Corrected the shared fill geometry to occupy the full control height. The
  previous width-only fraction had a zero-height empty decoration at runtime,
  which made the widget present in tree tests but invisible in the example.
- Moved number-field content padding inside the text/stepper row so the range
  fill starts at the complete decorated slider surface, matching Blender's
  `widget_numslider` rectangle geometry.
- Removed the fill layer's independently rounded leading cap. Its separate
  anti-aliasing exposed the gray backdrop at the left edge even though its
  layout began at x=0. The complete number-field surface now owns clipping,
  while a square fill extends to that shared boundary in display and edit
  modes.
- Added a 2x render-level regression that samples the selected pixels at the
  leading edge, supplementing layout assertions with the painted result. The
  example catalog suite must be invoked from `example/`; running it from the
  package root cannot resolve the example package import.

## 2026-07-17 — Added universal interface preferences and Blender Light

- Examined blenderapp's Interface Display and Editors panels plus its
  `Blender_Light.xml` theme preset, then added a persistable, app-scoped
  interface-preferences service to BlenderUI. It supplies reusable Display,
  Editors, and Themes preference sections while retaining application-owned
  storage and domain settings.
- Added live Blender Dark/Light palette selection, resolution scaling, and
  line-width policy through the application scope. The example app now uses
  the shared sections instead of its inert copied Interface controls.
- Recorded the ownership boundary, source mapping, light-theme transcription,
  and the sandboxed Flutter cache workaround in
  [`2026-07-17-universal-interface-preferences-and-light-theme.md`](decisions/2026-07-17-universal-interface-preferences-and-light-theme.md).

## 2026-07-17 — Added Blender-compatible portable theme service

- Examined blenderapp's Themes preference preset menu, XML reader/writer, and
  install operator. Added the app-scoped `BlenderThemeService`, a safe portable
  `ThemeUserInterface`/widget XML mapping, custom-theme persistence, and live
  palette application through the existing application scope.
- Added a reusable Themes preferences surface with Blender-style preset,
  create/remove/save/install/reset actions. Host apps provide platform file
  actions while BlenderUI owns XML content, validation, state, and persistence.
- Documented compatibility limits, source mapping, lifecycle ownership, test
  coverage, and the SDK formatter lesson in
  [`2026-07-17-blender-compatible-theme-service.md`](decisions/2026-07-17-blender-compatible-theme-service.md).
- Fixed theme propagation across route-owned menus and application-owned
  Properties subsections. The library now captures the initiating theme for
  popovers/dialogs, while the example resolves custom panel colors beneath the
  app scope; compact icon actions also keep the Themes header usable at narrow
  Preferences widths.
- Corrected the remaining live-update gap in the temporary Preferences route.
  `BlenderThemeScope` now carries an observable theme source into overlays, so
  an open Preferences window repaints as its theme is edited instead of
  retaining the palette captured when it opened. The reusable embedded window
  now supports title-bar drag, resize, close, minimize/restore, and
  maximize/restore controls, with host callbacks for native minimize/maximize
  ownership.
- Followed the actual example `Edit > Preferences` launch path and fixed its
  remaining root-Navigator theme gap: the app controller now binds the live
  theme source directly to the Preferences presentation service. The temporary
  window also gained visible right/bottom resize zones and a larger diagonal
  corner grip, replacing its hard-to-discover invisible 18px target.
- Corrected the Blender Light top-bar mapping from blenderapp's
  `ThemeTopBar` instead of its separate dark toolbar-item color. File/Edit and
  View/Select/Add now use the source light menu surface; the example macOS
  runner also follows the active palette with its native title-bar appearance.
- Fixed the final live-dialog inheritance layer: open Preferences routes now
  update their inherited foreground text style together with their palette,
  so unstyled labels no longer retain dark-theme white after selecting Light.

## 2026-07-17 — Consolidated app services and interactive documentation

### Reorganized the framework by durable feature boundaries

- Replaced the mechanically generated, flat, numbered part-file layout with
  descriptive domain folders across controls, layout, editors, templates,
  services, application composition, icons, demos, the showcase, and tests.
  Parent libraries now act as small ownership-preserving entry points rather
  than mixed implementation files.
- Split the showcase state and its large render, physics, view-layer, gallery,
  header, editor-area, and Preferences catalogs into app-owned feature parts.
  The package continues to own reusable mechanics; example values and actions
  remain in `example/`.
- Consolidated exact duplication through shared property-form primitives,
  descriptor factories, category navigation, `BlenderTreeState`, menu
  presentation, an example-owned brush control catalog, and the public
  `BlenderPersistenceCoordinator`. Added explicit lifecycle documentation and
  tests for container-adopted services.
- Kept collection surfaces, editor canvas renderers, and status/report storage
  separate after review because their activation, coordinate, and lifecycle
  contracts differ. Shared lower-level presentation remains in use where the
  behavior is actually identical.
- Added an Analyzer-backed structural guard and CI workflow. The guard rejects
  files or declarations over 750 lines, numeric generated part names, a flat
  `lib/src/parts/` directory, and recurring exact helper families. Final
  verification passed for 261 Dart files, all 149 package tests, and all 67
  example tests.
- Tooling lesson: an initial brace-counting Ruby rewrite confused closure
  braces with declaration bodies and truncated several sidebar helpers. Those
  files were repaired and subsequent declaration moves used Analyzer-backed or
  marker-validated migrations with dry runs. Other corrections caught during
  the migration included an Analyzer API cast for `BlockClassBody`, extension
  access to protected `setState`, an icon painter context color dependency, a
  duplicate part directive, and an off-by-one Preferences catalog boundary.
- Environment lesson: `dart format` attempted to refresh Flutter SDK cache
  files outside the repository and failed under the workspace sandbox. The
  command was rerun with the required SDK-cache permission. Temporary migration
  rewriters were removed after use; only the durable structural guard remains.

- Completed the reusable-framework backlog discovered during the example
  audit. Session-bound editor hosts, command/menu descriptors, typed header
  presets, a complete property factory, unified top-bar composition, job and
  report services, immutable graph updates, native appearance adapters,
  viewport/popover shells, developer code blocks, and shared category browsing
  now live in the package.
- Migrated the example away from duplicate editor-selection synchronization,
  direct method-channel theme listeners, hand-built app chrome, local property
  descriptor factories, viewport navigation state, status job/report models,
  and catalog navigation/highlighting.
- Removed screenshot golden comparisons and PNG baselines in favor of live,
  interactive examples plus behavioral widget tests and code snippets.
- Recorded architecture, compatibility boundaries, source-reference policy,
  SDK cache permissions, the Material-localization failure, and migration
  corrections in
  [`2026-07-17-framework-extraction-from-example.md`](decisions/2026-07-17-framework-extraction-from-example.md).
- Attempted a rendered web verification against the local example server. The
  in-app browser could not initialize because required sandbox-policy metadata
  was absent, so verification stayed with the successful web build and full
  behavioral widget suites rather than introducing an unapproved automation
  path.

- Added the reusable application/editor service layer so high-density editor
  apps can compose a dockable frame, workspaces, commands and bindings,
  history, Preferences, status feedback, splash/About presentation, and
  persistent editor context without adopting global state. The service boundary
  is documented in
  [`2026-07-17-application-editor-services.md`](decisions/2026-07-17-application-editor-services.md).
- Migrated the example app onto those services for Preferences, splash/About,
  status reporting, and the active main/Outliner/Properties editor context.
  Its showcase-specific data model and individual editor widgets remain local
  to the example app.
- Focused example behavior and catalog tests passed. The broad screenshot suite
  was not rebased because the concurrently changed factor-number control
  produced widespread golden diffs; generated failure images were discarded so
  the service migration does not hide an unrelated visual-baseline decision.
- Added a live Components tutorial catalog and interactive examples, keeping
  application-specific demonstrations in `example/` while public primitives
  remain in the library.
- Refined the example app's Blender-style workspace chrome: one shared header
  scrolling surface, native workspace tabs, delayed tooltips, and responsive
  multi-column editor menus.
- Added a nested, interactive Properties demonstration that follows blenderapp
  panel hierarchy and enabled-state behavior.

## 2026-07-16 — Made the desktop shell durable and source-faithful

- Promoted docking layouts, retained workspace screens, and application state
  into reusable framework services with host-owned persistence.
- Established the top-bar ownership rule: menus, workspace tabs, and workspace
  actions share one header surface; individual tabs must not scroll themselves.
- Replaced temporary source-asset coupling with package-owned vector assets so
  the runnable example remains self-contained.

## 2026-07-15 — Expanded reusable editor composition

- Introduced the library-owned application shell, Preferences service, menu
  composition, workspace service, and compact editor-type picker. ADRs
  `0005` through `0008` record their lifecycle and ownership boundaries.
- Broadened reusable non-3D editors, Properties, Outliner, file-browser,
  status, template, dialog, and menu surfaces from local blenderapp anatomy.
- Prepared the package and its GitHub Pages showcase for public use while
  retaining an application-agnostic data and callback model.

## 2026-07-13 to 2026-07-14 — Established the foundation

- Created BlenderUI as a clean-room, MIT-licensed Flutter package inspired by
  Blender's visual language and interaction density. Domain data, operators,
  and persistence remain application-owned.
- Built the initial theme, controls, docking/editor shell, Properties rail,
  Outliner, menus, popovers, status bars, and desktop example runners.
- Chose a semantic, descriptor-driven widget API over copied Blender code or
  Blender runtime dependencies. See
  [`ADR-0001`](decisions/ADR-0001-foundation.md) through
  [`ADR-0004`](decisions/ADR-0004-editor-docking-and-minimal-viewport.md).

## Durable development lessons

- Start BlenderUI parity work from the local blenderapp checkout. Reuse visual
  anatomy and ownership boundaries, never Blender implementation or assets.
- Keep library services scoped and model-neutral; applications provide domain
  state, stable-ID resolution, storage, and concrete editor widgets.
- Verify screenshot-sensitive UI in the rendered example as well as tests.
  Header scrollbars and nested horizontal scroll views are architectural issues,
  not merely pointer-event bugs.
- The installed Flutter SDK may need permission to refresh its cache outside
  the repository before formatting or verification. This does not alter project
  source, but it should be surfaced when it blocks a command.

## 2026-07-19 — 3D Viewport editor-chrome parity

- Audited the example app against the local `blenderapp` View3D header, tool
  system, navigation gizmo, and sidebar sources.
- Replaced the permanent left toolbar region with a floating, grouped Object
  Mode shelf and added the missing selection-operation radio group.
- Added reusable navigation overlays and collapsible vertical N-panel tabs,
  separated Item/Tool/View/Animation content, and made gizmo positioning part
  of the renderer-neutral viewport shell contract.
- Documented source anchors, architecture decisions, full backlog, failures,
  and verification in `doc/3d-viewport-parity.md`.

## 2026-07-19 — Retired completed plans and extracted remaining View3D chrome

- Re-audited all 261 Dart files and the maintained documentation for current
  ownership, duplication, obsolete guidance, and reviewability.
- Moved the standard Object Mode tool shelf and orientation gizmo from the
  example app into public BlenderUI widgets; the example retains only state,
  callbacks, and renderer-specific scene geometry.
- Removed the completed structural and framework-extraction backlog documents,
  which contained obsolete paths and duplicated accepted decisions.
- Consolidated current ownership rules, rejected abstractions, size limits,
  and verification expectations in a single decision record.

## 2026-07-19 — Made the Geometry Node Editor universal

- Audited `space_node.py`, `node_add_menu_geometry.py`, and the Node Editor C++
  draw/relationship implementation in the local blenderapp checkout.
- Extended the public graph model with typed ports, exact socket links, node
  kinds, overlays, validation, selection, deletion, and frame-child movement.
- Rebuilt the reusable canvas with Blender-shaped grid, layered Bézier wires,
  frames, reroutes, node states, callbacks, header menus, tool shelf, and
  active-node sidebar data.
- Replaced the example's shader stand-in with an app-owned eight-node
  `Scatter Pebbles` Geometry Nodes modifier and eleven precise links.
- Recorded architecture, source anchors, tool failures, render fixes, and
  verification in [`geometry-node-editor-parity.md`](geometry-node-editor-parity.md)
  and the accepted universal-editor decision.
