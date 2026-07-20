# Universal Geometry Node Editor boundary

Date: 2026-07-19

Status: Accepted

## Context

The package exposed a small generic node graph, but its links targeted node
centers and its example used shader nodes for every node-editor type. Copying a
second Geometry-Nodes-only editor into the example would improve one screen
while leaving host applications without reusable mechanics.

## Decision

Use one universal node canvas and immutable graph model for Geometry, Shader,
Compositor, Texture, and custom node trees.

The library owns typed socket and link presentation, resolved canvas geometry,
pan/zoom/grid mechanics, node kinds, overlays, header/menu taxonomy, tool
presentation, and interaction callbacks. Host applications own the graph
document, selection policy, commands, evaluation, undo, persistence, and any
custom node controls.

Keep the original node-to-node link constructor compatible. Precise graphs add
optional stable socket IDs. Keep custom node bodies as a widget-builder hook,
not Widget values inside the immutable graph model.

## Consequences

- Geometry Nodes parity improves every node-tree host instead of creating a
  specialized branch.
- Applications can validate graph endpoints before rendering.
- Menu selection remains an operator request; it does not silently mutate the
  caller's graph.
- Blender evaluation, dependency graph, geometry algorithms, and Python/C++
  runtime behavior remain outside BlenderUI.
- The example is responsible for proving realistic composition and state
  mutation with package APIs.

The source audit, detailed API inventory, sample graph, failures, and
verification record are maintained in
[`geometry-node-editor-parity.md`](../geometry-node-editor-parity.md).
