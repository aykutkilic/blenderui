# Decision: Treat viewport sidebars as inset UI regions

Date: 2026-07-27

## Context

Blender registers the 3D View sidebar as a right-aligned UI region. Its tab
rail and panel content are inset from the viewport's top and bottom edges;
they do not become one uninterrupted full-height panel. BlenderUI's
`BlenderViewportShell` previously placed the supplied sidebar directly in the
right-hand row, allowing hosts to render a solid panel from edge to edge.

## Decision

The shared viewport shell applies a vertically scaled 8-pixel inset around a
docked sidebar by default and top-aligns the region so its content keeps its
natural height. The inset is configurable through `sidebarPadding`, while the
default remains vertical-only so a collapsed 29-pixel tab rail still fits in a
narrow sidebar. Sidebar rails use shrink-wrapped scrolling: they size to their
tabs when there is room and scroll only when the host actually constrains
their height.

Page Editor region toggles follow Blender's `show_region_toolbar` and
`show_region_ui` model: toolbar visibility is independent from viewport
overlay visibility, and `T`/`N` are real editor shortcuts as well as displayed
menu shortcuts.
