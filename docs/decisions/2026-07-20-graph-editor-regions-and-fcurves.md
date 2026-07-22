# Graph Editor regions and F-curve ownership

Date: 2026-07-20

## Context

The earlier curve surface treated each curve as a separate normalized row. That
was convenient for a chart, but it did not model Blender's Graph Editor. The
local blenderapp sources define independent Header, Channels, Window, Sidebar,
and Footer regions, with all visible F-curves sharing one time/value `View2D`.

The implementation was audited against:

- `source/blender/editors/space_graph/space_graph.cc` for region ownership,
  drawing order, View2D, scrub, markers, cursor, and scrollbars;
- `source/blender/editors/space_graph/graph_draw.cc` for F-curve ordering,
  interpolation, handles, extrapolation, muting/locking, and visible-key work;
- `source/blender/editors/space_graph/graph_view.cc` and `graph_select.cc` for
  framing and selection behavior;
- `scripts/startup/bl_ui/space_graph.py` for Graph/Drivers headers, menus,
  filters, Sidebar panels, and footer differences.

## Decision

`BlenderCurveEditor` composes reusable region components around a shared
`BlenderGraphViewportController`. Application animation data is expressed as
immutable `BlenderCurveChannel`, `BlenderGraphKeyframe`, recursive
`BlenderGraphChannelNode`, marker, selection, and edit-transaction values.

The library owns presentation and direct manipulation:

- adaptive time/value grids, ruler and value gutter;
- constant, linear, and Bezier curves with automatic or explicit handles;
- selection, box selection, dragging, scrubbing, zooming, markers, cursor,
  normalization bounds, extrapolation, frame-range shading, mute/lock styling;
- recursive searchable Channels rows and channel action transactions;
- Graph and Drivers sidebars, headers, menus, and optional playback footer.

The host owns curve evaluation, drivers, modifiers, undo, document mutation,
and persistence. Drag and channel controls therefore emit semantic transactions
rather than mutating an opaque application model.

Legacy normalized `points` remain readable for source compatibility. New code
uses frame/value `keyframes`; the compatibility path can be removed in a future
major release.

## Rendering and invalidation

The static grid/curve layer and dynamic playhead/selection layer are separate
repaint boundaries. A playback `ValueListenable<double>` repaints only the
overlay. Curve drawing uses binary frame-range lookup, retains the segment just
outside each viewport edge for continuity, and suppresses unselected control
points closer than three screen pixels. Keyframes are an ascending-frame input
invariant, avoiding per-repaint sorting. Channels use lazy list construction.
In-place data mutation requires `dataRevision`; immutable list replacement is
preferred.

## Experience retained

- Flutter's `onPanStart` fires after touch slop. Hit testing compact keys there
  loses the original target, so the pointer-down target is retained for drag.
- `PointerScrollEvent` requires the explicit gestures import in this library
  barrel.
- A const set cannot contain a value type that overrides equality; tests build
  keyframe-reference sets at runtime.
- The sandboxed Flutter wrapper attempted SDK-cache writes. Verification used
  approved Flutter commands with SDK-cache access rather than changing SDK
  ownership.
- The complete library run retained two unrelated visual-baseline differences:
  UV Editor at 0.10 percent and Movie Clip Editor at 0.06 percent. Their
  references were deliberately not rewritten as part of this decision.
