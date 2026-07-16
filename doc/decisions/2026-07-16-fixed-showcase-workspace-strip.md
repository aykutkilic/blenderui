# Decision: Share the showcase header navigation surface

Date: 2026-07-16

## Context

Blenderapp builds its left top-bar region as one layout: application menus,
separator, workspace tabs, and the Add Workspace action. The region owns the
single View2D navigation surface; the workspace-tab template only contributes
native tab buttons to that layout.

The example instead placed an independently scrolling `BlenderTabBar` inside
an already scrolling `BlenderToolbar`, and constrained it to 560px. This made
the workspace row pan separately from the menus and Add Workspace control.

## Decision

Use the outer `BlenderToolbar` as the example header's only horizontal
viewport. Configure the workspace `BlenderTabBar` with `scrollable: false` and
remove its fixed-width wrapper, so its tabs participate in the toolbar's
natural-width content alongside the menus and Add Workspace action.

## Consequences

- The header moves as one coherent surface when its contents overflow.
- Workspace tabs cannot move independently from their neighboring header
  controls.
- `BlenderTabBar` retains its generic standalone scrolling capability for
  applications that do not compose it into a shared header viewport.

## Verification

Run `flutter test test/widget_test.dart` from `example/`. The Components
workspace regression verifies that only the outer header scroll surface owns
the tab row.
