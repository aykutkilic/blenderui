# Development history

This is the retained milestone record for BlenderUI. Superseded, task-by-task
parity notes were removed on 2026-07-17; their lasting architectural decisions
live in [the decision records](decisions/).

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

## 2026-07-17 — Consolidated app services and interactive documentation

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
