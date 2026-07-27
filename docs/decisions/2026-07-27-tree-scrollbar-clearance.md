# Decision: Reserve a clear right edge for tree content

Date: 2026-07-27

## Context

Blender's Outliner computes a right-column width for restriction and row
controls, subtracts that width from the tree drawing range, and scissored tree
content before the column. BlenderUI's `RawScrollbar` is painted over the
scroll viewport, while collapsed-child summaries and row actions were laid
out to the viewport edge. Their icons could therefore sit underneath the
scrollbar thumb.

## Decision

`BlenderTree` reserves an 8-pixel, interface-scaled content inset on the right
before building its scrollable list. The inset is owned by the shared tree
primitive so Outliner and File Browser callers receive the same safe geometry;
it is not implemented as a host-specific padding workaround.

## Consequences

- Trailing summaries and row actions remain visually and interactively clear
  of the overlaid scrollbar.
- Labels receive slightly less width when the tree is narrow, preserving the
  same ellipsis behavior as the original Blender right-column mask.
- Golden coverage for the Outliner and File Browser records the corrected
  right-edge geometry, and a focused widget test protects collapsed summaries.
