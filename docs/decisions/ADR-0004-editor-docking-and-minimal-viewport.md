# ADR-0004: Use an immutable split tree and a minimal painted viewport

- Status: Accepted
- Date: 2026-07-14
- Local Blender reference: `../blender` `main` at
  `68bdd158cc49af6191f0d9480510f4c5214f2df5`

## Context

The showcase used a fixed `main`/`right`/`bottom` shell. Divider dragging could
resize those regions, but editor areas could not be created from a corner,
moved, replaced, or docked. The viewport was a static 2D cube illustration, so
it did not provide a useful feel for direct manipulation.

Blender represents the screen as areas connected by shared edges. Its corner
action zones begin a modal operation that becomes either a dominant-axis split
inside the source area or a join/dock operation over another area. Dock targets
use edge regions plus a center replacement target, and both split and dock
operations draw a translucent preview before committing.

## Decision

Represent the Flutter workspace as an immutable binary tree of area and split
nodes, owned by `BlenderDockingController`. Render split nodes with the existing
`BlenderSplitter`; render area nodes with four small corner action zones.

Keep gesture recognition, target calculation, preview painting, tree mutation,
and leaf construction in separate classes. A 20 logical-pixel threshold avoids
accidental splits. Dragging inside the source selects the dominant split axis;
dragging over another leaf chooses left, right, top, bottom, or center and only
mutates the tree on release.

Implement the sample viewport as an independent, minimal orbit camera and
custom-painted scene. It projects a finite ground grid, one cube, world axes,
an orientation gizmo, and a selected-object origin. Drag orbits, the wheel
zooms, and double-click restores the default camera. No scene graph, mesh
editing, lighting engine, or external 3D dependency is introduced.

## Consequences

- Split/dock state is testable without rendering and leaf widgets remain
  caller-owned.
- Existing resizable dividers are reused instead of introducing a second
  resizing system.
- Center docking replaces the target content; edge docking moves the source
  beside the target and collapses its old parent split.
- The viewport is intentionally illustrative. It supplies spatial feedback
  without turning this UI package into a rendering engine.
