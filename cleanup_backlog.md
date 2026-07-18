# BlenderUI cleanup backlog

Structural complexity and duplication audit performed on 2026-07-17.

This file is an implementation backlog, not a request to delete functionality.
The intended end state is a smaller, composable BlenderUI framework with the
example app retaining only showcase-specific models, content, and adapters.

## Audit rules and evidence

- Scope: Dart source under `lib/`, `example/`, and `test/`.
- File sizes were measured with `wc -l` on the current checkout. Counts include
  comments and blank lines, because they still affect review and navigation.
- Declaration sizes are inclusive line ranges measured from the declaration to
  the next peer declaration. Getter-heavy catalogs and top-level test `main`
  functions are counted as declarations because they are the actual source of
  the maintenance cost.
- Hard rule: no source file, class, function, or widget should exceed 750 LOC.
  New extracted units should normally stay below 500 LOC so the next feature
  does not immediately recreate the same boundary problem.
- Complexity is also recorded below the hard-size violations when a unit has
  several independent responsibilities, large widget trees, rendering math,
  persistence, navigation, or a repeated implementation pattern.
- No runtime behavior was changed during this audit. Verification for this
  documentation-only change is limited to source measurement and reference
  inspection; implementation items must add focused tests as they are done.

## Priority and completion contract

- P0: exceeds 750 LOC or combines a complete application surface in one unit.
- P1: exact duplication or a parallel abstraction that can drift between
  callers.
- P2: complex but currently below the limit; split while the surrounding P0/P1
  work is in progress.
- P3: consolidation and follow-up documentation after the structural split.

The backlog is complete only when:

1. every Dart file is at or below 750 LOC;
2. every class, widget, function, getter, and test suite function is at or
   below 750 LOC;
3. repeated helper families have one shared implementation or an explicit
   documented reason to remain separate;
4. package/example ownership remains intact; and
5. focused package, example, and rendering tests pass after each migration.

## Decision record

The following decisions were made on 2026-07-17 after checking the proposed
boundaries against the current implementation. `Approved` items are part of
this cleanup; `Objected` items remain intentionally separate for the stated
reason.

| Item | Decision | Rationale |
| --- | --- | --- |
| P0 file and declaration limits | Approved | The measured violations are current and materially obstruct review. Splits must preserve library ownership and public API. |
| Generated numbered `parts/` layout | Objected | Names such as `specialized_templates_01_build_operator_properties.dart` expose mechanical split order instead of module responsibility. They make related code hard to browse, imply a false ordering dependency, and leave every domain in one flat dumping ground. Split libraries must use descriptive files inside domain folders such as `specialized_templates/operator_properties.dart`; numeric prefixes are prohibited. Dart `part` files may remain where same-library privacy is intentional, but their paths must still describe the feature boundary. |
| P1.1 property-sidebar primitives | Approved | The helper bodies are structurally identical and belong beside the existing property primitives. |
| P1.2 descriptor factories | Approved | Local wrappers only rename `BlenderPropertyFactory` and add no domain policy. |
| P1.3 showcase brush helpers | Approved | The repeated widget DSLs describe the same typed setting families and can be data-driven without moving sample state into the package. |
| P1.4 category navigation | Approved | Preferences and the component catalog are proven consumers of the same grouped navigation contract. |
| P1.5 tree flattening and rows | Approved | Expansion, visibility, and flattening are stable mechanics already represented by `BlenderTreeState`; feature rows remain specialized. |
| P1.6 collection, asset, and icon-list surfaces | Objected | These surfaces do not share one selection contract: file navigation, asset activation, enum choice, and compact data-block actions have different focus, activation, and overflow semantics. A generic item/tile layer would erase those distinctions and recreate a parallel collection API. Existing `BlenderListView` remains available where its contract actually fits. |
| P1.7 menu descriptor layers | Approved | Commands can adapt to the existing menu descriptor vocabulary; multi-column layout is presentation rather than a semantic model. |
| P1.8 menu overlay mechanics | Approved | Theme capture, anchored placement, and route dismissal are mechanical and can be shared while public activation/focus semantics stay separate. |
| Persistence coordinator | Approved, scoped | Coalescing, restore memoization, error capture, and flushing are shared. Serialization and schema validation remain service-owned. |
| Container/controller lifecycle clarification | Approved | The service container owns registered service disposal; the application controller owns composition and startup only. |
| Generic canvas/painter contract | Objected | The viewport shell already shares proven navigation/overlay mechanics. Image, UV, sequencer, node, and icon painters use incompatible coordinate, hit-testing, and repaint models; forcing them through a common renderer would add abstraction without eliminating behavior. |
| Unified status/report model | Objected | Status is replaceable transient state; reports are ordered retained history with identity and timestamps. Merging their storage model would make one lifecycle incorrect. Shared severity conversion and visual presets are appropriate and retained. |
| P2 composition splits | Approved | These are direct continuations of the P0 boundaries and keep application-specific commands and fixtures in the example app. |
| P3 structural tooling | Approved | A parser-backed declaration check and file-size gate make the cleanup enforceable rather than aspirational. |

## Implementation outcome — 2026-07-17

All approved items are complete. Objected items remain separate for the
reasons in the decision record and the expanded non-duplicate notes below.

| Backlog area | Outcome |
| --- | --- |
| P0 files and declarations | Completed. Parent libraries are thin entry points and implementation parts now live in descriptive domain folders. The showcase, examples, icon painter, and both test suites were split by responsibility. No numeric part names or flat `lib/src/parts/` directory remain. |
| P1.1 property sidebars | Completed with `BlenderStaticPropertyField` and `blenderFormColumn`; local sidebar helper families were removed. |
| P1.2 descriptor factories | Completed. Strip and Mask catalogs use `BlenderPropertyFactory` directly. The showcase Preferences catalog uses the shared static fields and `BlenderPreferenceSection.form`. |
| P1.3 brush controls | Completed with the example-owned `_ShowcaseBrushControls`; sample state remains outside the package. |
| P1.4 category navigation | Completed with `BlenderCategoryNavigation`; Preferences retains only section filtering/reordering policy. |
| P1.5 tree mechanics | Completed by extending and consuming `BlenderTreeState` for generic, node-interface, bone-collection, and Grease Pencil trees. Specialized rows remain domain-owned. |
| P1.7/P1.8 menus | Completed. Application menus use the shared descriptor vocabulary and dropdown/context menus share anchored overlay presentation while retaining distinct activation semantics. |
| Persistence and lifecycle | Completed with `BlenderPersistenceCoordinator`. Four services retain their own schemas, while the coordinator owns restore memoization, coalesced writes, flushing, and errors. Container adoption/disposal ownership is documented and tested. |
| P2 composition | Completed. Application/layout/control surfaces and example headers, editor areas, property catalogs, Preferences domains, gallery content, and demo pages are separated by responsibility. |
| P3 enforcement | Completed. CI runs the Analyzer-backed structural guard; it checks file/declaration size, rejects numeric/flat generated parts, and reports known exact helper duplication. Tests are split by feature. |

Final verification:

- `dart analyze lib test example/lib example/test tool`: no issues;
- `dart run tool/structural_guard.dart`: 261 Dart files passed, with every
  file and declaration at or below 750 lines;
- package `flutter test`: 149 tests passed;
- example `flutter test`: 67 tests passed.

The temporary AST and list-splitting migration programs were intentionally
removed after the rewrite. Keeping one-off source rewriters would create an
unsupported maintenance surface; `tool/structural_guard.dart` is the durable
tool because it enforces an ongoing architectural invariant.

## P0 — files over 750 LOC

| Priority | File | LOC | Main problem | Proposed split |
| --- | --- | ---: | --- | --- |
| P0 | `example/lib/showcase/showcase_app.dart` | 21,597 | One state object owns application wiring, all sample data, every Properties catalog, preferences, editor headers, docking composition, and the component gallery. | Keep a thin `ShowcaseApp`; move state/models, property catalogs by context, editor-header/menu builders, shell composition, preferences, and gallery examples into feature files. |
| P0 | `test/blender_ui_test.dart` | 5,229 | One `main()` contains the broad behavioral suite for unrelated controls, editors, services, menus, docking, and widgets. | Split by contract: controls, layout/editor shell, menus/overlays, services/persistence, editors, and framework extraction regressions. |
| P0 | `lib/src/specialized_templates.dart` | 4,818 | A single library file contains node interfaces, bone collections, assets, data blocks, reports/status, file browser hints, preferences, cache files, light linking, and Grease Pencil trees. | Split by domain: node/bone trees, assets/data blocks, reports/status, file-browser/preferences, cache/light linking, and Grease Pencil. |
| P0 | `lib/src/non3d_editors.dart` | 4,233 | Console, text, spreadsheet, image, asset, keymap, preferences, project, curve, animation, sequencer, UV, and clip editors share one file and repeated sidebar helpers. | One file per editor family, with shared sidebar/property primitives extracted first. |
| P0 | `example/test/widget_test.dart` | 4,108 | One `main()` owns the example boot test, catalog, Preferences, editor switching, menus, and many interaction flows. | Split into example boot/shell, catalog, Preferences, editor interactions, and menu/overlay suites. |
| P0 | `lib/src/editors.dart` | 3,161 | Properties, generic trees, Outliner, file browser, timeline, node graph, viewport sidebar, and node editor are coupled in one module. | Split into properties, tree/outliner, file browser, timeline, graph/node, and viewport-sidebar modules. |
| P0 | `lib/src/controls.dart` | 2,380 | Primitive buttons/fields, number sliders, dialogs, tooltips, popovers, dropdowns, menus, and context menus are all implemented together. | Split primitives, numeric/text controls, modal/overlay presentation, and menu controls. Keep shared overlay positioning in one internal service. |
| P0 | `lib/src/layout.dart` | 2,343 | Panels, toolbars, editor-type selection, multi-column menus, area headers, data blocks, status bars, tool shelves, tabs, splitters, scrolling, and editor shells share one file. | Split panel/toolbar layout, editor-type/menu/header chrome, docking/splitter primitives, scrolling/status, and editor frame/shell. |
| P0 | `lib/src/templates.dart` | 1,871 | Fields, transform panels, notices, paths, previews, scopes, jobs, color ramps, curve mapping, scrollbars, search menus, and pie menus are mixed. | Split property/transform templates, preview/scope/feedback templates, color/curve editors, and menus. |
| P0 | `example/lib/demo/component_catalog.dart` | 1,661 | The catalog route, component metadata, preview registry, preview rendering, tutorial content, and service demonstrations are coupled. | Separate catalog navigation/detail, component metadata, preview builders by family, and service previews. |
| P0 | `lib/src/icons.dart` | 1,637 | A single `CustomPainter.paint` switch contains every glyph's vector drawing. | Keep the public glyph enum/widget small; move glyph families or data-driven path builders into separate files. Preserve the clean-room vector implementation. |
| P0 | `example/lib/demo/demo_workbench.dart` | 1,308 | Navigation, mutable demo state, page routing, and all overview/controls/layout/data/editors/services demo pages are one file. | Split shell/state, navigation primitives, and one file per demo page family. |
| P0 | `lib/src/services.dart` | 1,243 | Preferences persistence, status, jobs, reports, state/history, editor sessions, service scopes, commands, and bindings are in one module. | Split persistence/state, feedback jobs/reports, editor session, service container/scope, and commands/bindings. |
| P0 | `lib/src/advanced_controls.dart` | 1,113 | Color picker/painters, property tabs, playback, and time-jump controls are unrelated feature groups. | Split color controls, property-tab navigation, and animation controls. |
| P0 | `lib/src/application.dart` | 1,047 | Top-bar/menu/workspace composition, Preferences/presentation services, status bar, controller, scopes, and workspace shell are coupled. | Split top-bar chrome, presentation/status, application controller/scope, and workspace shell. |
| P0 | `lib/src/property_templates.dart` | 787 | Attribute search, layer selector, color management, and curve profile are unrelated property domains. | Split attribute/layer selectors, color management, and curve profile/painter. |

### P0 file acceptance criteria

- Every split has a clear public/private ownership boundary and does not add a
  second API for an existing surface.
- Extracted files live in a descriptive domain folder beside their library
  entry point (for example, `lib/src/controls/number_field.dart`). File names
  describe responsibilities; generated parent-name prefixes and numeric
  ordering prefixes are not accepted.
- A source-splitting tool must derive stable descriptive names, refuse naming
  collisions, and never encode declaration order in the path. Mechanical
  line-count chunks are only an intermediate migration aid and must not remain
  in the finished tree.
- `example/` continues to own sample state and fake results; `lib/` owns
  reusable presentation, contracts, and model-neutral services.
- Imports remain acyclic and barrel exports expose only intentional public
  surfaces.
- Every moved file gets focused tests at the new boundary before the old file
  is removed.

## P0 — classes, widgets, and functions over 750 LOC

| Priority | Declaration | Approx. LOC | Why it is a separate cleanup item |
| --- | --- | ---: | --- |
| P0 | `example/lib/showcase/showcase_app.dart:20` — `_ShowcaseAppState` | 21,578 | A single `State` object is the composition root, domain fixture, editor factory, Properties catalog, Preferences catalog, header factory, and gallery. It prevents local reasoning and makes every unrelated change rebuild the same unit. |
| P0 | `lib/src/icons.dart:170` — `_BlenderIconPainter` | 1,467 | The class is effectively one giant glyph switch; adding or correcting one icon requires navigating a monolithic painter. |
| P0 | `example/lib/demo/component_catalog.dart:322` — `_ComponentCatalogExampleState` | 856 | One state owns preview selection/status plus a large switch-backed preview catalog. |
| P0 | `test/blender_ui_test.dart:28` — top-level `main()` | 5,092 | The test suite function contains unrelated widget and service contracts. The test runner can still discover split `main()` functions in separate files. |
| P0 | `example/test/widget_test.dart:37` — top-level `main()` | 4,072 | Example boot, shell, catalog, Preferences, menus, and editor interactions are coupled into one suite function. |
| P0 | `example/lib/showcase/showcase_app.dart:9411` — `_physicsPropertyGroups` getter | 2,056 | A getter builds a large physics/fluid/particle property catalog and contains many independent subdomains. |
| P0 | `example/lib/showcase/showcase_app.dart:20445` — `_buildControlGallery()` | 1,152 | The interactive catalog gallery is a long sequential widget tree. Each component family should be independently discoverable and testable. |
| P0 | `example/lib/showcase/showcase_app.dart:1842` — `_renderPropertyGroups` getter | 914 | Render settings, color management, output, animation, and cache panels are all assembled in one getter. |
| P0 | `lib/src/icons.dart:177` — `_BlenderIconPainter.paint()` | 1,455 | This is the concrete hard-limit violation inside the icon class. Split by glyph family or dispatch to smaller painters/builders. |

### P0 declaration split order

1. Extract `_ShowcaseAppState` composition and state boundaries first, without
   changing the visible example.
2. Split the two large test `main()` functions by feature so every later
   migration has a focused regression suite.
3. Extract icon painter families and add a glyph coverage test.
4. Move the three large showcase catalogs into dedicated catalog modules;
   then apply the same rule to every remaining catalog getter.

## P2 — complex units below 750 LOC

These do not currently violate the hard limit, but they combine enough
responsibilities that extracting only the largest files will leave the same
architecture problem in smaller form.

| Location | Approx. LOC | Complexity to remove |
| --- | ---: | --- |
| `lib/src/non3d_editors.dart:2309` — `BlenderStripProperties` and `_groups()` | 496 / 482 | Large descriptor catalog plus local property factories; the widget is a complete editor-specific domain surface. |
| `lib/src/non3d_editors.dart:1284` — `_BlenderPreferencesWindowState` | 424 | Temporary-window lifecycle, category selection, drag, resize, minimize/maximize, and route presentation. |
| `lib/src/editors.dart:827` — `_BlenderTreeState<T>` | 375 | Tree flattening, expansion state, keyboard/scroll behavior, row rendering, guides, and hit testing. |
| `lib/src/editors.dart:332` — `_BlenderPropertiesEditorState` | 315 | Context selection, group ordering, scroll state, and property rendering. |
| `lib/src/docking.dart:34` — `_BlenderDockingWorkspaceState<T>` | 306 | Dock-tree rendering, drag lifecycle, target math, preview state, and gesture handling. |
| `lib/src/theme_service.dart:397` — `BlenderThemeService` | 298 | Theme registry, selection, custom-theme mutation, XML import/export, persistence, and notifications. |
| `lib/src/controls.dart:876` — `_BlenderNumberFieldState` | 268 | Text editing, steppers, range fill, focus, formatting, and input synchronization. |
| `lib/src/workspaces.dart:126` — `BlenderWorkspaceService<T>` | 244 | Workspace selection, dock controllers, session state, serialization, persistence, and lifecycle. |
| `lib/src/editors.dart:1318` — `BlenderOutliner<T>` | 309 | Tree data presentation, search/filter, selection, context actions, and header controls. |
| `lib/src/editors.dart:1800` — `BlenderFileBrowser` | 231 | File list, selection, path/navigation header, and browser popovers. |
| `lib/src/application.dart:657` — `BlenderApplicationController<T>` | 195 | Application-wide service construction, child scope, persistence startup, and disposal. |
| `lib/src/advanced_controls.dart:733` — `_BlenderPropertyTabsState` | 191 | Tab visibility, overflow/fade measurement, selection, scrolling, and persistence callbacks. |
| `lib/src/specialized_templates.dart:958`, `1189`, `4615` — node, bone, and Grease Pencil tree states | 169 / 144 / 198 | Three widgets independently flatten hierarchical data, track expansion, build rows, and manage visibility/search. |
| `example/lib/demo/component_catalog.dart:404` — `_buildPreview()` | 561 | A large preview dispatcher still mixes unrelated component families even after the state class is split. |
| `example/lib/showcase/showcase_app.dart:15126` — `_buildMainToolbarForTheme()` | 700 | Near the hard limit; combines menu, workspace, context, theme, and window controls. |
| `example/lib/showcase/showcase_app.dart:12835` — `_preferenceSections` getter | 652 | Preference navigation plus many categories and local helper builders are still app-specific monolith code. |
| `example/lib/demo/demo_workbench.dart:13` — `_DemoWorkbenchState` | 207 | Owns navigation, filtering, state mutation, page selection, and route composition; it is a smaller version of the showcase composition problem. |

## P1 — exact duplicate helper families

### P1.1 — Property sidebar primitives

The same `_body`, `_panel`, `_check`, `_number`, and `_choice` helpers are
redeclared across the package:

- `lib/src/non3d_editors.dart:338-366` — `BlenderTextEditorSidebar`;
- `lib/src/non3d_editors.dart:2206-2246` — `BlenderDopeSheetSidebar`;
- `lib/src/non3d_editors.dart:2907-2947` — `BlenderSequencerSidebar`;
- `lib/src/non3d_editors.dart:3423-3463` — `BlenderImageEditorSidebar`;
- `lib/src/non3d_editors.dart:3987-4027` — `BlenderClipEditorSidebar`;
- `lib/src/editors.dart:2153-2183` — `BlenderFileBrowserSidebar`;
- `lib/src/editors.dart:2680-2720` — `BlenderViewportSidebar`;
- `lib/src/editors.dart:2925-2965` — `BlenderNodeEditorSidebar`.

The bodies are exact or differ only in the no-op callback and number precision.
Create one private/shared property-sidebar builder or descriptor utility with
explicit callback and formatting options. Migrate every caller and delete the
local copies. Do not create another public property API beside
`BlenderPropertyFactory`.

### P1.2 — Property descriptor factories

`BlenderStripProperties._groups()` at `lib/src/non3d_editors.dart:2328-2377`
and `BlenderMaskProperties._groups()` at `lib/src/non3d_editors.dart:3662-3695`
both define local `booleanProperty`, `numberProperty`, `enumProperty`, and
`panel` wrappers that immediately delegate to `BlenderPropertyFactory`.
`example/lib/showcase/showcase_app.dart:12835-12914` repeats the same idea with
`body`, `check`, `number`, `preferenceChoice`, `preferencePanel`, and `section`.

Use the existing factory directly or add one narrowly scoped catalog builder
that is shared by package templates and the example. The cleanup must remove
wrappers whose only purpose is renaming an existing factory call.

### P1.3 — Showcase brush-control helpers

`example/lib/showcase/showcase_app.dart:14554-14663`,
`:14665-14861`, and `:14863-15016` each define local `number`, `dropdown`,
checkbox/nested-panel, and content-building helpers. The Grease Pencil and
paint tool branches should use typed reusable brush-setting descriptors or a
single builder with explicit mode data instead of three similar widget DSLs.

## P1 — overlapping navigation, tree, and selection widgets

### P1.4 — Category navigation and Preferences navigation

The generic implementation is in `lib/src/category_browser.dart:43-228`:
`BlenderCategoryNavigation`, `_BlenderCategoryButton`, and
`BlenderCategoryBrowser`. Preferences still carries its own category model and
adapter in `lib/src/non3d_editors.dart:1001-1135`, and the temporary window has
another category presentation at `lib/src/non3d_editors.dart:1849-1890`.

Consolidate the category item/group model and selected-category button. Keep
Preferences-specific section filtering and reorder behavior, but make it feed
the shared category browser rather than maintaining another navigation surface.
The example catalog at `example/lib/demo/component_catalog.dart:67` should
remain a consumer of the shared browser.

### P1.5 — Hierarchical tree flattening and rows

The generic tree utility already exists in `lib/src/tree_state.dart`. However,
three specialized widgets still repeat the same expansion/flatten/visible-row
pattern:

- `lib/src/specialized_templates.dart:970-1111` — node interface tree;
- `lib/src/specialized_templates.dart:1200-1316` — bone collection tree;
- `lib/src/specialized_templates.dart:4646-4772` — Grease Pencil layer tree;
- `lib/src/editors.dart:868-1201` — generic tree/outliner path.

Introduce a typed tree-row composition contract so flattening, expansion,
search, and row selection are shared while each feature supplies its row
widget and restrictions. Preserve the existing `BlenderTreeState` utilities;
extend them instead of adding a second tree state system.

### P1.6 — Collection, asset, and icon-list surfaces

The following widgets overlap in tile/list selection and popup presentation:

- `lib/src/collections.dart:28-350` — `BlenderListView`, filter bar, and
  template list;
- `lib/src/specialized_templates.dart:1363-1632` — asset shelf popover,
  component menu, and compact list;
- `lib/src/specialized_templates.dart:2095-2238` — icon view;
- `lib/src/editors.dart:1800-2142` — file-browser list and popover;
- `lib/src/non3d_editors.dart:759-836` — asset shelf.

Define shared selection, item, tile, and overflow contracts. Keep distinct
visual presets, but remove repeated item-selection and list/popup plumbing.

## P1 — overlapping menus and overlays

### P1.7 — Menu descriptor layers

These types represent closely related menu concepts:

- `lib/src/controls.dart:1900-1979` — `BlenderMenuItem<T>` and
  `BlenderMenuDescriptor<T>`;
- `lib/src/application.dart:24-35` — `BlenderApplicationMenu<T>`;
- `lib/src/command_widgets.dart:10-216` — command menu entries, command
  buttons, and `BlenderCommandMenuDescriptor`;
- `lib/src/layout.dart:849-1099` — multi-column menu groups/items and menu
  rendering;
- `lib/src/application.dart:38-78` and `:133-355` — application menu bar and
  top-bar menu/workspace composition.

Choose one descriptor vocabulary and make command-backed menus an adapter over
it. Keep multi-column menus as a presentation variant, not a second semantic
menu model. `BlenderApplicationMenu` should remain a compatibility alias only
if callers require it; otherwise remove the redundant subtype.

### P1.8 — Repeated menu overlay presentation

`BlenderDropdown._open()` at `lib/src/controls.dart:2009-2037` and
`BlenderContextMenu._show()` at `lib/src/controls.dart:2339-2371` both use
`showGeneralDialog`, `InheritedTheme.captureAll`, `Stack`, `Positioned`, and
`BlenderMenu` to place a menu. Extract a common menu presenter that accepts
anchor/position, dismissal policy, and selection behavior. Keep dropdown and
context-menu semantics at their public edges.

The same audit should check `BlenderDialog`, `BlenderAlertDialog`, and
`BlenderPopover` for shared theme capture, dismissal, and positioning code;
centralize only the mechanics, not their distinct accessibility and focus
contracts.

## P1 — repeated persistence and service lifecycles

The following services independently implement `_restore`, `flush`, pending
write serialization, error capture, and persisted-state deletion:

- `lib/src/services.dart:252-353` — `BlenderInterfacePreferencesService`;
- `lib/src/services.dart:702-871` — `BlenderEditorSessionService`;
- `lib/src/workspaces.dart:126-369` — `BlenderWorkspaceService<T>`;
- `lib/src/theme_service.dart:397-625` — `BlenderThemeService`.

Extract a generic persistence coordinator or carefully scoped mixin/helper for
write coalescing, restore memoization, error state, disposal, and storage
access. Each service must retain its own serialization schema and validation.
Add versioning/error tests for every service before migration. Do not hide
service ownership in global state.

Related lifecycle overlap exists between `BlenderServiceContainer` and
`BlenderApplicationController` in `lib/src/services.dart:962-1080` and
`lib/src/application.dart:657-851`. Clarify that the container owns registry
and disposal while the application controller owns composition and startup;
remove any duplicate child-scope or disposal path.

## P1 — repeated canvas and painter responsibilities

Canvas entrypoints are repeated across editor implementations:

- `lib/src/non3d_editors.dart:690-720` — image canvas;
- `lib/src/non3d_editors.dart:2854-2894` — sequencer canvas;
- `lib/src/non3d_editors.dart:3302-3338` — UV canvas;
- `lib/src/editors.dart:2866-2907` — node graph canvas;
- `example/lib/showcase_viewport.dart:124-152` — example scene painter;
- `lib/src/icons.dart:177-1631` — glyph painter.

These are not all exact duplicates, but they repeat `LayoutBuilder`,
`InteractiveViewer`, gesture-to-model conversion, `CustomPaint`, and theme
plumbing. Extract a small renderer/canvas contract and reusable interaction
helpers where the behavior is truly common. Keep domain-specific paint methods
and the example's concrete scene renderer separate from the package shell.

## P1 — feedback/status presentation overlap

`BlenderStatusService` and `BlenderReportService` in `lib/src/services.dart`
both own transient user feedback, while `BlenderReportBanner` and
`BlenderLatestReportBanner` at `lib/src/specialized_templates.dart:2503-2621`
provide overlapping report presentation. Define one message/report model with
severity, timestamp/ordering, dismissal, and source metadata; provide separate
compact banner and latest-report visual presets over that model.

## P2 — application and example composition hotspots

The following units are below 750 LOC but should be split or simplified as the
P0 work lands:

- `lib/src/application.dart:133-355` — top bar and workspace strip;
- `lib/src/application.dart:461-656` — presentation/status service and widget;
- `lib/src/application.dart:869-1047` — application scope and workspace shell;
- `lib/src/layout.dart:665-1099` — editor-type selector and multi-column menu;
- `lib/src/layout.dart:1805-2264` — splitter, scroll, frame, and shell;
- `lib/src/controls.dart:1586-1784` — popover anchor/render-object mechanics;
- `lib/src/non3d_editors.dart:1038-1227` — Preferences navigation/reorder;
- `lib/src/non3d_editors.dart:1284-1707` — embedded Preferences window;
- `example/lib/showcase/showcase_app.dart:15927-18044` — editor header/menu
  factories for View3D, image, clip, animation, sequencer, node, and utility
  editors;
- `example/lib/showcase/showcase_app.dart:18064-20347` — main/right/bottom
  editor areas, Properties panels, and animation popovers.

The showcase header factories should become data-driven presets or separate
feature builders. The library shell should own layout mechanics while the
example supplies commands and sample state.

## P3 — test and tooling cleanup

- Add a lightweight CI check that reports Dart files over 750 LOC and fails on
  new violations.
- Make the structural guard reject generated numeric part names and a flat
  `lib/src/parts/` directory, so the temporary mechanical layout cannot return.
- Add a declaration-size check for classes/functions/widgets. A parser-backed
  check is preferred over regex so multiline signatures and nested functions
  are measured correctly.
- Keep test files split by feature; avoid replacing one giant test function
  with multiple giant groups in a single file.
- Add duplication checks for the known exact-helper names (`_body`, `_panel`,
  `_check`, `_number`, `_choice`, `_flatten`) while the migration is underway.
  `_buildCanvas` and `_groups` are excluded because the declarations with those
  names own different editor coordinate systems and different domain catalogs;
  matching private names alone is not duplication evidence.
- Update `doc/development-history.md` when each structural batch is completed,
  recording the reason, ownership decision, verification, and any failed tool
  path or SDK/environment lesson.

## Deliberate non-duplicates

These pairs should not be merged merely because their names or widget trees
look similar:

- `BlenderViewportShell` and `ShowcaseViewport`: the former is reusable shell
  and controller composition; the latter is example-owned scene rendering.
- `BlenderCategoryBrowser` and a Preferences detail surface: share navigation
  mechanics, but Preferences still owns section filtering and reordering.
- `BlenderMenuButton`, `BlenderDropdown`, and `BlenderContextMenu`: share menu
  presentation mechanics but have different activation, focus, and dismissal
  semantics.
- Sample property values and domain models in `example/`: they must stay
  example-owned even when their layout uses `BlenderPropertyFactory`.
- Specialized Canvas painters: share infrastructure only where interaction or
  theme plumbing is genuinely identical; do not force unrelated domain paint
  models into one abstraction.
- Editor `_buildCanvas` methods: image, UV, sequencer, and node editors retain
  separate coordinate conversion, interaction, and repaint contracts. Their
  common private name does not imply a safe shared renderer.
- Catalog `_groups` getters: the component catalog categories, Strip
  properties, and Mask properties describe unrelated domain data. They use
  shared property factories, but their catalogs remain with their owners.

## Recommended implementation batches

### Batch 1 — protect the boundary

Split the two giant test suites, add the size checks, and extract the showcase
composition root. This makes every later change reviewable.

### Batch 2 — remove exact duplication

Consolidate property sidebar helpers, descriptor factories, category buttons,
menu overlays, and persistence lifecycle mechanics. Add regression tests before
deleting each local copy.

### Batch 3 — split package feature modules

Split `icons.dart`, `controls.dart`, `layout.dart`, `editors.dart`,
`non3d_editors.dart`, `specialized_templates.dart`, `templates.dart`, and
`services.dart` by responsibility. Update barrel exports only after focused
imports and tests are stable.

### Batch 4 — split catalogs and gallery content

Move showcase Properties, headers, Preferences, component gallery, and demo
pages into app-specific feature files. Keep the example launcher thin and keep
the package free of sample state.

### Batch 5 — verify and document

Run focused `flutter analyze`/`flutter test` commands from the package root and
the `example/` package root, then run the size/duplication checks. Record the
final ownership decisions and any environment/tooling failures in the history.
