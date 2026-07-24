# Reviewability and ownership-oriented naming

## Context

A repository-wide scan found several genuinely overloaded classes among many
files that are large for legitimate reasons. Generated project metadata,
explicit export barrels, Blender source-shaped descriptor catalogs, and retained
history should not be churned solely to reduce line counts. The workbook host
and node editor were different: each mixed several independent lifecycles or
interaction policies in one state class.

Related public types also use dense families of `Theme`, `Workspace`, `Editor`,
`Controller`, `Service`, `Host`, and `State` names. Most represent distinct
layers, but those distinctions were distributed across decision records rather
than available in one entry-point document. `BlenderNLAEditor` additionally
used an acronym style inconsistent with `BlenderNlaEditorHeader`.

## Decision

- Extract `WorkbookRuntimeController` in the workbook example. It owns optional
  Python/Jupyter installation and connection, local server and language-tool
  lifecycles, runtime settings, application-support paths, and installer job
  projection. The application state remains responsible for shell composition
  and the workbook session remains independently offline.
- Keep document file selection in the host and shadow-file synchronization in
  the existing host-owned manager. Runtime preparation invokes that boundary
  but does not make files part of the reusable workbook package.
- Separate node pointer/gesture policy into
  `node_editor_interactions.dart`. The state object retains lifecycle and
  rendering composition and exposes one private mutation gateway so interaction
  code cannot bypass Flutter's protected `setState` ownership.
- Canonicalize the NLA surface as `BlenderNlaEditor`. Retain
  `BlenderNLAEditor` as a deprecated compatibility alias.
- Publish `docs/naming-and-ownership.md` as the terminology map for suffixes and
  the theme, workspace, editor, application, DAW, and workbook families.
- Do not cosmetically split `DawSessionController`. Its next reduction must
  extract pure/domain command services with explicit transaction, selection,
  and undo semantics.

## Consequences

The workbook application's state class no longer owns runtime protocols and
processes. Node rendering can be read independently of node/socket/canvas
gesture policy. Existing NLA callers continue to compile while new code uses
consistent Dart acronym casing. Reviewers have one map for similarly named
layers, and large intentional catalogs remain stable.

## Experience

The first node-interaction extraction called `setState` from an extension.
Static analysis correctly rejected that use because extensions are not
`State` subclasses even when they share a Dart library. A private
state-owned `_updateInteractionState` gateway resolved the boundary without an
ignore directive and keeps mounted-state mutation in the lifecycle owner.

The complete core test run passed 249 behavioral tests but reported four
pre-existing small golden drifts: UV Editor (0.10%), NLA and Video Sequencer
(0.02% each), and Movie Clip Editor (0.06%). The focused node, NLA composition,
workbook, and extension-package suites passed. Goldens were not rewritten
because the refactor does not intentionally change those pixels and accepting
unrelated baselines would hide the distinction between structural work and
visual changes.
