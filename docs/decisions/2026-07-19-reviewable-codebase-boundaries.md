# Reviewable codebase boundaries

Date: 2026-07-19

Status: Accepted

## Context

The 2026-07-17 structural and framework-extraction backlogs were completed,
but both documents retained hundreds of lines of old file paths, proposed
names, and pre-split line counts. They had become historical implementation
plans rather than useful guidance for a reviewer of the current tree.

A follow-up audit covered every Dart file under `lib/`, `examples/blenderui/lib/`,
`test/`, `examples/blenderui/test/`, and `tool/`, plus all maintained Markdown documents.
The structural guard reported 261 Dart files with no file or declaration above
750 lines.

## Decision

Use these ownership rules when changing the repository:

- `lib/` owns reusable presentation, editor chrome, interaction mechanics,
  descriptors, state/service contracts, and renderer-independent viewport
  controls.
- `examples/blenderui/` owns imitation data, tutorial prose, fake command outcomes,
  concrete platform adapters, and renderer-specific scene geometry.
- Reusable behavior proven in the example moves into an existing library
  surface before a new abstraction is considered.
- Thin adapters that only rename an existing public factory are removed.
- Same-library `part` files are allowed for private implementation sharing,
  but filenames must describe a responsibility rather than declaration order.
- Files and declarations remain below 750 lines; new focused units should
  normally remain below 500 lines.
- Completed plans are not kept as active backlogs. Decisions and dated outcomes
  belong in `docs/decisions/` and `docs/development-history.md`.

## Current examples/blenderui/library split

The follow-up extraction moved the standard Object Mode tool taxonomy and the
renderer-independent orientation gizmo from the example into BlenderUI as
`BlenderView3dToolShelf` and `BlenderViewportOrientationGizmo`. The example now
supplies selected-tool state, callbacks, orbit angles, and its cube scene only.

The following remain intentionally example-owned:

- cube/grid projection and painting;
- sample scene, Properties, Preferences, and editor content;
- tutorial/catalog copy and fake status results;
- the macOS appearance method-channel implementation.

## Rejected consolidations

- Do not merge transient status with retained report history; their lifecycles
  differ.
- Do not force image, node, sequencer, viewport, and icon painters through a
  generic canvas contract; their coordinates and hit testing differ.
- Do not create a generic collection/tile API across file navigation, asset
  activation, enum choice, and compact data-block actions.
- Do not replace application-specific detailed menu contents with placeholder
  preset commands merely to reduce example line count.

## Enforcement and verification

- `tool/structural_guard.dart` enforces size, descriptive split paths, and
  known exact-duplication rules.
- Package and example analysis must pass from their respective package roots.
- Package and example widget suites verify the public boundaries and the
  imitation app integration.
