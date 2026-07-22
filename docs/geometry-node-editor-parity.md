# Geometry Node Editor parity

Date: 2026-07-19

Status: implemented

2026-07-20 follow-up: viewport rendering, port connection gestures, and the
example's mutable link document are now implemented. The accepted performance
and interaction decisions are recorded in
[`2026-07-20-node-performance-connections-and-symbol-icons.md`](decisions/2026-07-20-node-performance-connections-and-symbol-icons.md).

## Scope and source audit

This pass examined the original Blender checkout at
`/Users/aykutkilic/git/blender` before changing BlenderUI. It uses Blender's
anatomy and ownership boundaries as a clean-room reference; Blender source,
assets, and runtime code are not copied into this package.

The main source anchors were:

- `scripts/startup/bl_ui/space_node.py`: tree-specific header branches,
  View/Select/Add/Node menus, modifier/tool data-block controls, snapping,
  overlay settings, active-tool panels, and the Node/Tool/View/Group sidebar
  families;
- `scripts/startup/bl_ui/node_add_menu_geometry.py`: the nested Geometry Nodes
  Add taxonomy, including Attribute, Geometry, Curve, Grease Pencil,
  Instances, Mesh, Point, Volume, Simulation, Color, Texture, Utilities,
  Group, and Layout;
- `source/blender/editors/space_node/node_draw.cc`: basis-node headers and
  bodies, independently resolved socket locations, collapsed nodes, frames,
  reroutes, warnings, execution-time and named-attribute overlays;
- `source/blender/editors/space_node/drawnode.cc`: socket connection points,
  Bézier control points, typed wire colors, outline/inner wire passes, and
  dragged-link behavior;
- `source/blender/editors/space_node/node_relationships.cc`: link operations
  and the use of resolved socket geometry for relationship editing;
- `source/blender/editors/space_node/space_node.cc`: the editor-space context
  that selects a tree without taking ownership of the tree's evaluation.

## Findings

The old BlenderUI editor was a graph illustration, not a reusable node editor.
Links terminated at node centers, socket identifiers were not part of a link,
all nodes used the same panel treatment, and the Geometry Node Editor example
displayed a shader graph. Selection, frames, reroutes, typed ports, collapsed
nodes, muted state, overlays, and the Geometry Nodes Add hierarchy were absent.

The source audit produced four durable rules:

1. A node document and the editor-space presentation are separate. The host
   owns graph mutation, evaluation, undo, persistence, and command policy.
2. Sockets are first-class endpoints. Labels and controls may change without
   changing the stable socket ID used by a link.
3. Link painting consumes resolved socket geometry. It must not infer a node
   center after layout.
4. Frames and reroutes are node kinds with distinct rendering and hit regions,
   not ordinary nodes with unusual labels.

## Reusable library implementation

`BlenderNodeGraphModel` remains immutable and model-neutral. It now supports:

- typed socket data, shapes, connection/multi-input/enabled state, details,
  and descriptions;
- socket-specific link endpoints, wire style/color/selection/mute state, and
  graph validation;
- standard, frame, and reroute node kinds;
- node header color, custom label, parent frame, selection/active state,
  collapsed/muted state, warnings, and execution timing;
- selection operations, selected-node deletion with incident-link cleanup,
  frame-child movement, node/link mutation, graph bounds, and stable-ID
  lookup.
- stable `BlenderNodeSocketReference` values, typed compatibility checks,
  normalized link creation, single-input replacement, multi-input retention,
  and derived socket connection state.

`BlenderNodeEditor` owns renderer-independent editor mechanics:

- a zoomable/pannable dotted grid;
- socket-resolved, outlined typed Bézier wires;
- frame-behind-link-behind-node paint order;
- distinct standard/frame/reroute rendering;
- node selection, movement, collapse, socket, canvas, and context callbacks;
- optional caller-provided node body, transformation controller, toolbar,
  sidebar, canvas size, and overlay controls.
- View2D-style node and frame culling with overscan, link-path rejection,
  zoom-adaptive viewport-only grid dots, isolated repaint layers, editor-local
  drag positions, middle-button pan, and pointer-centered wheel zoom;
- bidirectional socket dragging, typed target snapping, a provisional wire,
  host validation, and an exact `onLinkCreated` callback.

`BlenderNodeEditorHeader`, `BlenderNodeEditorMenuCatalog`, and
`BlenderNodeToolShelf` move the stable node-editor chrome out of the example.
They cover every public node-editor type while exposing values and callbacks
instead of application state. The Geometry Nodes Add menu preserves Blender's
nested category shape and representative current node labels.

The sidebar can now describe the active node, its actual input sockets,
evaluation time, named attributes, and tree name. It still does not evaluate a
node tree or edit arbitrary application values.

## Detailed example implementation

The example app owns a Geometry Nodes modifier document called
`Scatter Pebbles`. It contains:

- a labeled frame;
- Group Input with geometry, selection, Poisson distance, and radius inputs;
- Distribute Points on Faces in Poisson Disk mode;
- an Icosphere instance source;
- Instance on Points and Realize Instances;
- a geometry reroute and Group Output;
- eleven exact socket-to-socket links, typed socket colors, multi-input shape,
  active selection, and evaluation timings.

The sample uses the public header, menu catalog, tool shelf, editor, graph
model, and sidebar. The app retains node and link lists, selected-node identity,
command dispatch, move/collapse behavior, socket feedback, context deletion,
and status reporting. A completed socket drag mutates that app-owned graph
through `connectSockets`; Select All/None/Invert and Delete demonstrate how a
host can apply public immutable graph operations without placing application
state in the package.

## Decisions and experience

- Existing `BlenderNodeGraphModel` and `BlenderNodeEditor` were extended. A
  parallel Geometry-Nodes-only graph API was rejected because shader,
  compositor, texture, and custom graphs share the same canvas mechanics.
- Link endpoints use `from`/`to` node IDs plus optional socket IDs. This keeps
  old node-to-node callers source-compatible while giving new callers precise
  ports.
- Domain-specific values stay serializable presentation data (`detail`) or a
  caller-provided node body. The graph model does not contain Widgets.
- The first analyzer pass exposed a missing same-package import for the shared
  popover panel and required callbacks on static checkboxes. Both were fixed
  at the composition boundary.
- Flutter initially could not refresh its SDK cache outside the repository.
  The verification commands succeeded after granting the SDK-cache operation;
  no project files were written outside the workspace.
- The first rendered Geometry Nodes test exposed a four-pixel reroute overflow:
  a reroute had reused a complete labeled socket row. A dedicated 18 by 18
  marker fixed both the geometry and the abstraction.
- A test initially expected one `Named Attributes` label, but the source-shaped
  composition intentionally exposes it in both the overlay settings and the
  sidebar. The assertion now verifies presence without forbidding both owners.
- In-app browser bootstrap failed before navigation because required
  sandbox-policy metadata was absent. Per the browser-control instructions,
  no alternate browser automation surface was substituted. Render verification
  continued through Flutter's widget layout and maintained visual-baseline
  workflow.

## Verification record

- `dart run tool/structural_guard.dart`: passed for 271 Dart files.
- `flutter analyze lib test` in the package: passed.
- `flutter analyze lib test` in `examples/blenderui/`: passed.
- Complete package `flutter test`: passed, 162 tests, including new graph
  validation, Geometry Nodes menu, frame, reroute, grid, and link contracts.
- Complete example `flutter test`: passed, 70 tests. The Geometry Nodes case
  rendered the complete sample without overflow after the reroute correction,
  and the maintained workspace/component visual-baseline cases also passed.

### 2026-07-20 verification addendum

- `flutter analyze`: passed in the package and example.
- Complete package `flutter test`: passed, 167 tests. New coverage exercises
  connection direction/type/input policy, real handle dragging, off-screen
  node culling, one-shot node-move commits, Material Symbols defaults, and the
  vector compatibility backend.
- Complete example `flutter test`: passed. The Geometry Nodes scenario drags a
  Group Input socket onto Instance on Points and verifies the app-owned link
  document changed.
- `dart run tool/structural_guard.dart`: passed for 274 Dart files.
- The first interaction test reproduced the reported failure: the generic
  `InteractiveViewer` recognizer claimed node drags. Replacing its gesture
  ownership with explicit Blender-style viewport navigation fixed both node
  movement and socket completion.
