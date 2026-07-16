# Development history

This is the retained milestone record for BlenderUI. Superseded, task-by-task
parity notes were removed on 2026-07-17; their lasting architectural decisions
live in [the decision records](decisions/).

## 2026-07-17 — Consolidated app services and interactive documentation

- Added the reusable application/editor service layer so high-density editor
  apps can compose a dockable frame, workspaces, commands and bindings,
  history, Preferences, status feedback, splash/About presentation, and
  persistent editor context without adopting global state. The service boundary
  is documented in
  [`2026-07-17-application-editor-services.md`](decisions/2026-07-17-application-editor-services.md).
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
