# Context-menu ownership and command boundary

Date: 2026-07-19

Status: accepted

## Context

The example app had one three-command context menu around its main editor. It
could not identify an Outliner row, file, node, property, or tool, and its
command inventory did not reflect the active editor. blenderapp instead shares
popup mechanics while regions and targets build context-dependent menus.

## Decision

- BlenderUI owns popup gestures, viewport placement, menu rendering, common
  source-shaped catalogs, and target-aware callback contracts.
- Target widgets expose descriptor builders and return both target identity and
  selected action ID.
- A secondary click selects the target before menu construction.
- Applications own domain state, conditional facts that are not represented by
  the widget, command dispatch, side effects, undo, and persistence.
- Common catalogs remain ordinary `BlenderMenuItem<String>` lists. They can be
  extended without requiring an application to adopt a package command bus.

## Consequences

Other applications can reuse Blender-shaped menus without copying example
widgets or accepting showcase behavior. Menu state remains explicit and
testable. New editor-specific families can be added to the catalog without
changing the popup primitive, while highly domain-specific menus can bypass the
catalog and use the same target-aware builders.

The package intentionally does not promise Blender operator parity. A visible
item is a command descriptor until its host supplies execution.
