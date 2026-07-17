# BlenderUI backlog

This backlog records reusable framework work discovered while auditing the
example app against the public BlenderUI package on 2026-07-17. It is an
implementation record. All items were approved by the request to implement
this backlog and completed on 2026-07-17.

The governing boundary is:

- BlenderUI owns reusable high-density editor structure, presentation,
  interaction contracts, and application services.
- Host applications own domain models, documents, commands, data, and native
  runner implementations.
- The example app owns tutorial content, sample state, and Blender-imitation
  data used only to demonstrate the package.
- Existing public surfaces should be extended or consolidated before a new
  parallel abstraction is introduced.

## Decision summary

| ID | Candidate | Recommendation | Effort | Depends on | Decision |
| --- | --- | --- | --- | --- | --- |
| BLUI-001 | Editor-area host and session binding | Carry now | L | — | Completed |
| BLUI-002 | Command-backed UI descriptors | Carry now | M | — | Completed |
| BLUI-003 | Descriptor-driven area headers | Carry now | M | BLUI-002 | Completed |
| BLUI-004 | Standard editor-chrome presets | Carry selectively | L | BLUI-002, BLUI-003 | Completed |
| BLUI-005 | Complete `BlenderPropertyFactory` and migrate the example | Carry now | M | — | Completed |
| BLUI-006 | Unified application top-bar composition | Carry now | L | BLUI-002 | Completed |
| BLUI-007 | Job and report data services | Carry now | L | — | Completed |
| BLUI-008 | Immutable node-graph update utilities | Carry now | S | — | Completed |
| BLUI-009 | Native window-appearance adapter contract | Carry contract only | M | — | Completed |
| BLUI-010 | Generic viewport shell and controller | Carry foundation only | L | — | Completed |
| BLUI-011 | Standard popover-panel presentation | Carry selectively | S | — | Completed |
| BLUI-012 | Syntax-highlighted code block | Developer tooling only | M | — | Completed |
| BLUI-013 | Searchable category/detail browser | Carry after Preferences comparison | M | — | Completed |

All thirteen items were delivered as one coordinated extraction so the example could be migrated without maintaining parallel framework layers.

## Completed work

## Implementation result

The completed extraction introduced one coherent set of framework surfaces:

- session-backed editor areas and descriptor/command-backed headers;
- typed editor-chrome presets, property factories, immutable graph updates,
  and reusable viewport/popover composition;
- unified application top-bar, job/report, and native-appearance services;
- an optional developer-tools library for source snippets; and
- shared category navigation used by both Preferences and the component
  catalog.

The example now consumes these public surfaces while retaining its sample
models, concrete renderer, runner channel, and tutorial content. Focused
contract tests live in `test/framework_backlog_test.dart`; existing behavioral
widget tests remain, while screenshot/golden assets and comparisons were
removed in favor of the live examples requested for the catalog.

### BLUI-001 — Editor-area host and session binding

**Problem**

The example separately stores each area's selected `BlenderEditorType`, renders
it through local switches, and mirrors every change into
`BlenderEditorSessionService`. This creates two sources of truth and repeats
the same synchronization for the main, Outliner, and Properties areas.

**Implemented library shape**

- Add a controller or host such as `BlenderEditorAreaController` or
  `BlenderEditorAreaHost`.
- Bind a stable `workspaceId` and `areaId` to the editor-session service.
- Accept an application-owned registry of editor builders keyed by stable view
  identifiers or `BlenderEditorType`.
- Restore the persisted view before rendering and provide a defined fallback
  when an identifier is no longer registered.
- Keep editor models, commands, and domain state application-owned.

**Acceptance criteria**

- An app can declare an editor area without maintaining duplicate local and
  session selection state.
- Main, side, and bottom editor areas use the same API.
- Selection restoration, fallback behavior, and changes are covered by widget
  and service tests.
- The example removes `_setMainEditorType`, `_setRightTopEditorType`, and
  `_setRightBottomEditorType`-style synchronization.

**Do not carry**

- The example's area identifiers, selected sample objects, or editor-specific
  models.

### BLUI-002 — Command-backed UI descriptors

**Problem**

Menus and toolbars repeat command labels, shortcuts, enabled state, and
callbacks even though `BlenderCommandRegistry` already owns commands and
keyboard execution.

**Implemented library shape**

- Add a command-to-menu/button adapter rather than a second command registry.
- Derive label, shortcut, enabled state, and invocation from one registered
  command.
- Support command-backed nested menu entries and toolbar/icon actions.
- Keep purely presentational menu items available for choices that are not
  commands.

**Acceptance criteria**

- Changing a command's enabled state updates every bound menu and toolbar
  action.
- Pointer and keyboard activation execute the same registered command.
- Menu descriptors do not duplicate command labels or shortcuts.
- Missing command identifiers fail visibly in debug builds and degrade safely
  in release builds.

**Do not carry**

- The example's fake command results or `_setStatus` callbacks.

### BLUI-003 — Descriptor-driven area headers

**Problem**

`BlenderAreaHeader` accepts lists of already-built menu widgets, forcing every
editor to recreate identical `BlenderMenuButton` mapping logic. Application
menus use a separate descriptor type for essentially the same concern.

**Implemented library shape**

- Introduce one generic menu descriptor usable by application and area
  headers, or generalize the existing descriptor without breaking callers.
- Let `BlenderAreaHeader` build menus from descriptors while retaining widget
  slots for genuinely custom controls.
- Route command-backed descriptors through BLUI-002.
- Consolidate shared menu geometry and enabled/selected behavior in one place.

**Acceptance criteria**

- The example deletes `_editorMenus()`.
- Area and application headers share the same descriptor semantics.
- Existing custom leading, center, action, and scrolling slots remain
  available.
- No third parallel menu-description API is introduced.

### BLUI-004 — Standard editor-chrome presets

**Problem**

The example contains source-shaped but reusable header anatomy for View3D,
Image/UV, Clip, NLA, Graph, Sequencer, Node, Spreadsheet, Timeline, and utility
editors, including many repeated overlay, snapping, filter, gizmo, and playback
popovers.

**Implemented library shape**

- Add optional editor-header presets after BLUI-002 and BLUI-003 establish the
  underlying contracts.
- Presets own standard Blender-style ordering, labels, glyphs, menu hierarchy,
  and command identifiers.
- Applications supply presentation state and registered command
  implementations.
- Keep presets separate from the minimal `BlenderAreaHeader` primitive so apps
  can build non-Blender editor types without inheriting irrelevant menus.

**Acceptance criteria**

- At least two materially different editor headers prove the preset contract.
- Presets contain no sample state and do not call showcase callbacks.
- Overlay, snapping, gizmo, filter, and playback settings are typed rather than
  passed as unstructured widget lists.
- The example removes corresponding copied menu and popover definitions as
  each preset is adopted.

**Do not carry**

- Application-specific command implementations or fake menu outcomes.

### BLUI-005 — Complete `BlenderPropertyFactory` and migrate the example

**Problem**

The example declares 23 number, 22 boolean, and 21 enum helper functions while
the existing `BlenderPropertyFactory` is not used there. The factory lacks a
few options needed by those call sites.

**Implemented library shape**

- Extend the existing factory; do not create another property-builder layer.
- Add `showSteppers` to numeric descriptors.
- Add a generic typed `choice<T>` helper instead of limiting menus to `String`.
- Add panel `enabled` support and preserve existing header-leading/actions
  behavior.
- Add vector or custom-action helpers only where repeated call sites prove a
  stable contract.

**Acceptance criteria**

- The example has no local boolean, number, enum, or panel factory that merely
  recreates library descriptors.
- Existing callbacks, enabled states, suffixes, ranges, and factor fills remain
  functional.
- Factory methods remain thin constructors over public descriptor/control
  types.
- Focused tests cover every newly supported option.

**Do not carry**

- The example's Render, World, Material, Object, or Data property values and
  panel catalogs.

### BLUI-006 — Unified application top-bar composition

**Problem**

The example manually combines the app menu, File/Edit/Render/Window/Help,
workspace tabs, workspace actions, and Scene/View Layer controls in one shared
scroll surface. The library's application menu bar and top bar implement
overlapping but incompatible layout policies.

**Implemented library shape**

- Consolidate both public widgets around one internal top-bar layout engine.
- Add explicit leading/app-menu and fixed context-control slots.
- Add a documented overflow policy, including shared scrolling and
  workspace-only scrolling.
- Preserve edge fades and keyboard/pointer behavior.
- Integrate command-backed menus through BLUI-002.

**Acceptance criteria**

- The example uses the public top-bar API instead of rebuilding its container,
  border, toolbar, and scrolling behavior.
- Menus, workspaces, and fixed context groups remain reachable at narrow
  widths.
- Both overflow policies have focused layout tests.
- Existing `BlenderApplicationMenuBar` and `BlenderApplicationTopBar` callers
  have a migration or compatibility path.

**Do not carry**

- The example's exact menu contents, workspace names, Scene values, or View
  Layer values.

### BLUI-007 — Job and report data services

**Problem**

The package has job/report presentation widgets and a one-message status
service, but the example must construct job widgets and report banners itself.
Presentation widgets currently double as the job data model.

**Implemented library shape**

- Introduce immutable `BlenderJob` and `BlenderReport` data models.
- Add observable services for registering, updating, canceling, completing,
  and removing jobs and reports.
- Let status-bar and running-jobs widgets render service data.
- Keep execution, scheduling, and domain-specific cancellation implementation
  in the host application.

**Acceptance criteria**

- A background operation can update progress without knowing which status-bar
  widget renders it.
- Cancellation has explicit requested/canceling/completed states.
- Reports support severity and bounded history.
- Multiple jobs and report changes have deterministic ordering and tests.

**Do not carry**

- The showcase's fake asset-preview job, scene statistics, version text, or
  saved-file message.

### BLUI-008 — Immutable node-graph update utilities

**Problem**

Moving one node requires reconstructing every `BlenderGraphNode` field in the
example because the public immutable model has no update helpers.

**Implemented library shape**

- Add `BlenderGraphNode.copyWith()`.
- Add immutable `BlenderNodeGraphModel` operations such as `moveNode`,
  `replaceNode`, `removeNode`, and link updates where required by existing
  editor callbacks.
- Preserve stable node and socket identifiers.

**Acceptance criteria**

- The example's `_moveNode()` does not reconstruct a node manually.
- Operations preserve untouched node fields and return unmodifiable or safely
  owned collections.
- Missing identifiers have documented no-op or error behavior.
- Unit tests cover node and link updates.

### BLUI-009 — Native window-appearance adapter contract

**Problem**

Theme changes need to update native title-bar appearance, but the example
currently owns a hardcoded method-channel name and calls it directly.

**Implemented library shape**

- Add a small platform-appearance adapter interface or application-controller
  callback.
- Translate active Blender theme luminance or preset into a platform-neutral
  light/dark appearance request.
- Keep concrete method-channel and runner registration in a host adapter or
  optional platform plugin.
- Treat native appearance updates as best effort and non-fatal.

**Acceptance criteria**

- The core package has no dependency on the example's channel name.
- A host can inject a macOS, Windows, Linux, or no-op adapter.
- Theme changes update the adapter once and failures do not interrupt editing.
- Adapter lifecycle and error handling are tested without a native runner.

**Do not carry**

- `MainFlutterWindow.swift` or other concrete runner code into the portable
  core library.

### BLUI-010 — Generic viewport shell and controller

**Problem**

The example's viewport combines reusable orbit/zoom/reset interaction,
overlay placement, sidebar attachment, grid/axis presentation, and an
orientation gizmo with a demo-only cube renderer.

**Implemented library shape**

- Add a `BlenderViewportController` for orbit, pan, zoom, reset, and camera
  limits.
- Add a canvas/shell with background, scene, overlay, gizmo, caption, footer,
  and sidebar slots.
- Consider optional reusable grid, world-axis, and orientation-gizmo painters
  only after their coordinate contracts are independent of the demo scene.
- Keep rendering extensible rather than embedding a fixed scene model.

**Acceptance criteria**

- A host can render its own scene while reusing navigation and overlay layout.
- Pointer and scroll interactions can be configured or disabled.
- The controller is testable independently of a `CustomPainter`.
- The example retains only the cube geometry, projection, and sample caption.

### BLUI-011 — Standard popover-panel presentation

**Problem**

The example repeats fixed-width `SizedBox` → `BlenderPanel` → `Column`
composition for viewport and animation popovers.

**Implemented library shape**

- Add a named `BlenderPopover.panel(...)` constructor or a panel-content option
  to the existing popover API.
- Standardize width constraints, title, padding, and scroll behavior.
- Avoid introducing a standalone wrapper that duplicates both existing
  components.

**Acceptance criteria**

- Viewport and animation popovers share one public composition path.
- Tall content remains within the safe viewport and becomes scrollable.
- Existing arbitrary popover builders continue to work.

### BLUI-012 — Syntax-highlighted code block

**Problem**

The component catalog owns a fixed-font, horizontally scrollable,
syntax-highlighted code block that is useful for documentation and developer
surfaces but not required by ordinary editor applications.

**Implemented library shape**

- Place `BlenderCodeBlock` in a devtools/docs layer or optional package.
- Accept a token-span provider or language strategy rather than hardcoding a
  fragile Dart-only regular expression into the runtime core.
- Preserve theme-aware colors, fixed-size font metrics, selection, and
  horizontal scrolling.

**Acceptance criteria**

- Catalog snippets use the extracted component.
- Syntax treatment is pluggable and plain-text fallback is supported.
- The core runtime package does not gain an unnecessary parser dependency.

### BLUI-013 — Searchable category/detail browser

**Problem**

The catalog implements a searchable categorized sidebar and detail surface
similar to Preferences navigation, but there is not yet enough evidence for a
stable general-purpose API.

**Implementation decision**

The existing Preferences editor supplied the required second,
non-documentation consumer. `BlenderCategoryNavigation` now owns grouped,
searchable navigation and `BlenderCategoryBrowser` adds the optional detail
surface. Tutorial metadata remains example-owned.

## Existing library surfaces to adopt in the example

These are cleanup tasks, not reasons to add new public APIs:

- Replace `_buildNestedToolPanel` and `_buildNestedToolHeader` with
  `BlenderPanel` and `BlenderPanelHeader` where the existing behavior is
  sufficient.
- Use `BlenderSidebarSections` for repeated collapsible editor sidebars.
- Compose status content from `BlenderApplicationStatusBar`,
  `BlenderInputStatus`, `BlenderRunningJobsPanel`, and `BlenderStatusInfo`.
- Keep using `BlenderApplicationController`, `BlenderApplicationScope`,
  `BlenderWorkspaceShell`, workspace persistence, Preferences, history,
  undo/redo, commands, status, and editor-session services instead of adding
  wrappers around them.
- After BLUI-005, use `BlenderPropertyFactory` in catalog dialogs and all
  source-shaped property groups.

## Explicitly outside the library boundary

The following remain example-owned unless BlenderUI's product scope changes
from reusable editor framework to a Blender application clone:

- Fake scenes, objects, materials, files, nodes, timelines, and property
  values.
- The copied Render, World, Material, Object, and Data settings catalogs.
- Application-specific menu commands and command implementations.
- The cube renderer, demo projection, sample viewport caption, and help text.
- `DemoState`, tutorial prose, component metadata, feature cards, and preview
  state.
- Hardcoded scene statistics, Blender version, sample jobs, and sample reports.
- Catalog alert/dialog scenarios.
- Concrete native runner and method-channel implementations.

## Completion policy

When an item is approved:

1. Change its decision to `Approved` and record any scope adjustment.
2. Add an ADR when the item introduces or consolidates a public architectural
   boundary.
3. Implement the public surface and focused tests before migrating the example.
4. Migrate every relevant example call site; do not leave the old and new
   abstractions in parallel.
5. Update `doc/development-history.md` with the date, purpose, source evidence,
   failures or constraints encountered, and verification performed.
6. Mark the item `Completed` only after API documentation, tests, example
   adoption, analysis, and rendered behavior have been verified.
