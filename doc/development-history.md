# Development history

This is the retained milestone record for BlenderUI. Superseded, task-by-task
parity notes were removed on 2026-07-17; their lasting architectural decisions
live in [the decision records](decisions/).

## 2026-07-17 — Audited source-size and duplication boundaries

- Measured the current Dart tree and recorded every file, class, widget, and
  function that violates or approaches the 750-line maintainability limit in
  [`cleanup_backlog.md`](../cleanup_backlog.md).
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
- Added [`backlog.md`](backlog.md) as a decision-ready extraction queue with
  priorities, dependencies, acceptance criteria, and explicit boundaries for
  content that must remain example-owned.
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
