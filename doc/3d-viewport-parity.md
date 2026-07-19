# 3D Viewport parity analysis and implementation backlog

Date: 2026-07-19

## Scope and source of truth

This pass compares the example app with the 3D Viewport in the local
`blenderapp` checkout at `/Users/aykutkilic/git/blender`. The Flutter scene
renderer remains intentionally lightweight; the target is the editor chrome,
region hierarchy, sizing, placement, state, and interaction model.

The primary source anchors are:

- `scripts/startup/bl_ui/space_view3d.py`: `VIEW3D_HT_header` builds the editor
  type, mode selector, contextual selection modes, collapsible View/Select/Add/
  Object menus, transform controls, two spacer boundaries, visibility, gizmo,
  overlay, X-Ray, the four shading radio buttons, and the shading popover.
- `scripts/startup/bl_ui/space_view3d.py`: `VIEW3D_HT_tool_header` owns active
  tool settings. It is a separate region and must not be confused with the
  primary header.
- `scripts/startup/bl_ui/space_toolsystem_toolbar.py`:
  `VIEW3D_PT_tools_active` supplies the left toolbar. Object Mode orders the
  selection group, Cursor, a separated transform group, a separated annotation
  and Measure group, and an Add primitive group. `None` entries are visual
  group breaks rather than blank, full-width rows.
- `scripts/startup/bl_ui/space_view3d.py`:
  `VIEW3D_PT_view3d_properties`, `VIEW3D_PT_view3d_cursor`, and the Item-category
  panels define the N-panel content. `space_view3d_sidebar.py` contributes the
  Global Transform panels.
- `source/blender/editors/space_view3d`: the navigation gizmo and region setup
  establish these as viewport overlays. They do not reserve a permanent opaque
  toolbar column.

## Findings

### Region hierarchy

The old example composed the toolbar as a sibling before the viewport. That
made it an opaque, full-height editor region and shifted the scene. Blender's
toolbar, selection-operation strip, axis/navigation gizmos, Options control,
and N-panel tabs belong to the viewport overlay hierarchy. Only the expanded
N-panel content should reduce the scene width.

### Header anatomy

The existing 30 logical-pixel `BlenderAreaHeader` is an appropriate compact
base. Its ordering already follows the source: editor type, 118-pixel mode
selector, View/Select/Add/Object menus, transform orientation/pivot/snap/
proportional editing, then visibility/gizmo/overlay/X-Ray/shading. The important
source detail is grouping: transform and display controls are separated by
spacers, aligned controls behave as button groups, and shading is a four-value
radio group followed by a popover. This pass preserves that source-shaped order
and moves the missing selection operation strip into the viewport.

### Left tools

The prior 48-pixel shelf had a continuous background, no group breaks, and a
generic Add/Pan/Zoom/Settings list. Blender uses compact square overlay buttons
and meaningful group separation. Object Mode needs Select (with Tweak/Box/
Circle/Lasso options), Cursor, Move, Rotate, Scale, Annotate, Measure, and Add
Cube. View navigation does not belong in this shelf.

### Right overlays

The axis gizmo is followed vertically by circular Zoom, Camera, and
Perspective/Orthographic controls. These are translucent viewport overlays,
not header actions. The Options button is also an overlay at the upper-right.
The N-panel uses narrow vertical Item/Tool/View/Animation tabs. Clicking a new
tab opens that category; clicking the active tab collapses the panel.

### N-panel content

The old example permanently displayed a generic list mixing View, Item, and
Global Transform. The new contract keeps category content separate. Item opens
Transform, Tool opens active-tool settings, View opens focal length, clipping,
view locks, cursor, and collections, and Animation opens Global Transform.

### Reuse boundary

Renderer-specific geometry stays in `example/lib/showcase_viewport.dart`.
Reusable chrome belongs in `blenderui`: selection modes, navigation controls,
vertical sidebar tabs, viewport gizmo offsets, and floating tool-shelf styling.
This avoids a showcase-only imitation and lets host applications place the
same chrome around their own renderer.

## Implementation backlog

- [x] P0: Move the Object Mode tool shelf into the viewport overlay and stop
  reserving a permanent left editor region for View3D.
- [x] P0: Match the source Object Mode tool order and add visual group breaks.
- [x] P0: Add the Set/Extend/Subtract/Difference/Intersect selection-mode radio
  group below the header with caller-owned state.
- [x] P0: Keep the source-shaped mode/menu/transform/display/shading header
  ordering and existing interactive state.
- [x] P1: Add source-positioned Options, orientation gizmo, Zoom, Camera, and
  Perspective/Orthographic overlay controls.
- [x] P1: Implement Item/Tool/View/Animation vertical N-panel tabs with active
  tab collapse and category switching.
- [x] P1: Split N-panel content by category instead of showing every family at
  once; default to the screenshot's expanded Item/Transform category.
- [x] P1: Make gizmo inset configurable so overlay controls can stack without
  renderer-specific positioning hacks.
- [x] P2: Export the new chrome primitives from the public package API and keep
  the example app as the stateful composition layer.
- [x] P2: Preserve old `ShowcaseViewport` construction for focused interaction
  tests through optional chrome inputs.
- [x] P2: Update source-parity widget tests for floating tools and collapsible
  category behavior.
- [x] P3: Run package and example analysis, package regressions, focused example
  tests, and rendered-app verification; record failures and outcomes below.

## Decisions and experience

- `BlenderViewportShell` remains renderer-agnostic. It gained only configurable
  gizmo offsets; application state and scene rendering were not pushed into the
  package.
- `BlenderToolShelf` gained a floating presentation rather than a second,
  View3D-only tool widget. Tool group breaks are descriptor data because they
  come from the source tool list.
- The first Flutter command failed because the SDK attempted to update files
  outside the repository sandbox. Re-running with explicit Flutter SDK cache
  permission succeeded. This is an environment permission issue, not a Dart or
  layout failure.
- Running `flutter test` with `part of` registration files as independent test
  targets produced expected “Missing definition of main” load errors. The
  correct regression entry point is `example/test/widget_test.dart`.
- The initial focused example run also exposed stale assumptions: it expected a
  permanent mixed sidebar and located the first tool via an unkeyed shelf. The
  tests now target the keyed viewport shelf and exercise the N-panel categories.
- The in-app browser connection could not start because the browser runtime was
  not given the required sandbox policy metadata. Visual verification therefore
  used the example app's maintained workspace visual-baseline test rather than
  claiming a live browser inspection.

## Verification record

- `flutter analyze lib test` in the package: passed.
- `flutter analyze lib test` in `example/`: passed.
- `flutter test test/blender_ui_test.dart`: passed, 125 tests.
- `flutter test test/widget_test.dart`: passed, 64 tests, including the showcase
  workspace visual baseline and the View3D category interaction regression.
