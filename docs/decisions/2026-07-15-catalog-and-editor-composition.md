# Catalog and editor composition boundaries

Date: 2026-07-15

## Context

The showcase accumulated editor state, Blender-reference property descriptors,
menus, viewport composition, dialogs, and widget construction in one state
object. The library also repeated descriptor factories, panel-stack rendering,
and nested-tree traversal across independent editor surfaces.

## Decision

- Keep public widgets source-compatible while moving repeated visual plumbing
  into reusable primitives.
- Treat property catalogs as declarative domain data; widgets receive
  `BlenderPropertyGroup` descriptors and caller-owned callbacks.
- Use `BlenderPropertyFactory` for boolean, number, menu, and panel
  descriptors, and `BlenderTreeState` for tree expansion/flattening.
- Use `BlenderActionPanelStack` for constraint/effect/modifier-like stacks.
- Keep semantic facades such as `BlenderNLAEditor`; delegation is not harmful
  duplication when it provides a stable domain API.

## Planned module boundaries

`lib/src/application.dart` owns the reusable application composition seam:
controller lifecycle, scoped state/services, docking, and Preferences
presentation. `examples/blenderui/lib/` keeps source-shaped catalogs, application data,
editor composition, and menu callbacks. Future feature extraction moves public
exports and focused tests with the feature.

## Verification and tooling notes

`dart format` and Flutter verification require the local Flutter SDK to write
its cache outside the repository sandbox. The formatter and focused tests were
rerun with that narrowly scoped permission; no generated or cache files are
tracked.
