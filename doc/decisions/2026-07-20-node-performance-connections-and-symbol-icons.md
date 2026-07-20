# Node viewport performance, connections, and semantic icons

Date: 2026-07-20

Status: Accepted

## Context

The universal Geometry Node Editor had the correct static anatomy but rebuilt
the example's full application state on every drag update and composed every
node, frame, link, and grid point regardless of the visible viewport. Socket
rows only exposed click callbacks, so links could not be created. The broader
application also used a growing catalog of independently painted icons whose
quality and visual consistency varied.

## Blender source findings

The local blenderapp checkout remains the clean-room behavior reference:

- `source/blender/editors/space_node/node_draw.cc` rejects basis nodes,
  frames, overlays, and zone labels whose draw bounds do not intersect
  `region.v2d.cur` (`BLI_rctf_isect` around lines 2863, 3751, 3777, and 3811).
- `node_draw_nodetree` starts and ends batched link drawing around the tree's
  links; socket drawing similarly uses `nodesocket_batch_start/end`.
- `source/blender/editors/interface/view2d/view2d.cc` computes grid starts and
  counts from the current view, changes the grid level by zoom, and stops when
  alpha becomes insignificant. It does not rasterize an unbounded document.
- Blender relationship editing resolves real socket positions and maintains a
  temporary dragged link before committing a typed node-tree link.
- `source/blender/editors/include/UI_icons.hh` is a semantic catalog consumed
  throughout the application. That semantic indirection, not Blender's icon
  artwork or code points, is the reusable design lesson.

## Decisions

1. Keep one renderer-independent `BlenderNodeGraphModel` and one node editor
   for Geometry, Shader, Compositor, Texture, and custom trees.
2. Cull node widgets against the inverse-transformed viewport with configurable
   overscan. Reject link paths outside that rectangle and paint visible links
   in a single outline/inner pass with one node lookup table per paint.
3. Paint the dotted grid in viewport coordinates. Choose the visible step from
   zoom and enumerate only points that can appear on screen.
4. Keep high-frequency node positions and provisional links inside editor
   state. Commit one host callback at gesture end; the host remains responsible
   for persistence, undo, evaluation, and application rebuilds.
5. Give primary-button drags exclusively to nodes and sockets. Middle-button
   movement pans the canvas and pointer-wheel movement zooms around the cursor,
   matching Blender's desktop interaction model and avoiding Flutter gesture
   arena competition.
6. Represent endpoints with stable `BlenderNodeSocketReference` values. The
   default policy rejects self-links, same-direction or disabled sockets, and
   incompatible concrete types; `custom` is a deliberate wildcard. Normal
   inputs replace an existing incoming link while multi-input sockets retain
   all links. Hosts may add stricter validation.
7. Render the existing `BlenderGlyph` semantic API with Material Symbols by
   default. Use outlined variable-font axes tuned for dense dark UI. Preserve
   the independent vector painter behind `BlenderIconRenderer.blenderVector`
   so existing hosts have an explicit compatibility path.

## Icon research and licensing

Google's [Material Symbols guide](https://developers.google.com/fonts/docs/material_symbols)
documents the fill, weight, grade, and optical-size axes and the Apache 2.0
license. The [official icon repository](https://github.com/google/material-design-icons)
identifies Material Symbols as the current catalog while classic Material
Icons are no longer updated. Flutter's built-in
[`Icons` API](https://api.flutter.dev/flutter/material/Icons-class.html) covers
the older Material set. The maintained
[`material_symbols_icons`](https://pub.dev/packages/material_symbols_icons)
package supplies the current Symbol fonts and tree-shakable `IconData` API for
Flutter.

No Blender source icon, SVG, font, code point, or runtime asset is copied. The
mapping follows meaning (for example collection to folder copy, modifier to
construction, node tree to account tree). The dependency's Apache license
remains its own; BlenderUI source remains MIT licensed.

## Consequences

- Work scales primarily with visible node widgets and visible raster paths,
  rather than document canvas area. Link endpoint inspection remains linear in
  link count, as it is in Blender's draw traversal, but off-screen paths do not
  reach the raster stage.
- Node movement no longer rebuilds an application shell for every pointer
  event. A host receives a stable final position once.
- Link gestures work from either an input or output and always emit a normalized
  output-to-input link.
- Canvas navigation is intentionally desktop-first. Touch hosts that need
  pinch gestures can provide higher-level controls through the existing
  transformation controller without reintroducing competing primary drags.
- Material Symbols make the application coherent and maintainable, but some
  Blender-specific concepts are semantic approximations rather than traced
  silhouettes.

## Experience and failures

- The first focused test command incorrectly targeted a part file without its
  own `main`; the package's aggregate test library is the correct entry point.
- Initial connection preview rendering worked, but completion and node movement
  were unreliable because `InteractiveViewer`'s scale recognizer competed in
  the gesture arena. Disabling its pan was insufficient. Removing its gesture
  ownership and retaining only an explicit transform resolved the root cause.
- The first public model test exposed that `BlenderNodeSocketReference` had not
  been exported from `blender_ui.dart`; the universal API export was added.
- The example's part-based test library used a narrow Flutter import list and
  initially omitted `GestureDetector`; the test import was corrected.
- Flutter dependency resolution, formatting, analysis, and tests needed scoped
  access to the shared SDK/package cache outside the workspace.
- A final rendered web inspection launched the example successfully at a local
  URL, but the in-app browser could not initialize because its required
  sandbox-policy metadata was absent. The server was stopped and verification
  remained with the complete Flutter render/layout suites; no alternate browser
  automation surface was substituted.

## Verification

- Package and example `flutter analyze`: no issues.
- Complete package suite: 167 tests passed.
- Complete example suite: 70 tests passed, including a real Geometry Nodes
  reconnection.
- Structural guard: passed for 274 Dart files after the new presentation and
  fixture parts were split to retain the 750-line reviewability boundary.
