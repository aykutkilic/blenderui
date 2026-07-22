# ADR-0007: Workspace layouts are a shared application service

**Date:** 2026-07-16

## Context

`BlenderDockingWorkspace` already provides the low-level Blender interaction:
areas can be split from their corners, docked onto another area, and resized at
their shared seam. Applications nevertheless had to create and retain a
`BlenderDockingController` themselves. That made a multi-workspace application
either rebuild a controller on every workspace switch or reimplement a layout
registry locally. It also encouraged editor-type selectors to keep a second,
unsynchronised copy of an area's selected view.

## Decision

BlenderUI owns a small generic workspace-layout service:

- `BlenderWorkspaceDefinition<T>` declares an application-owned workspace ID
  and immutable default dock tree.
- `BlenderWorkspaceService<T>` creates one controller for every definition,
  selects the active workspace, retains each live layout, and can reset a
  single layout to its declared default.
- `BlenderWorkspaceHost<T>` renders the active controller and rebuilds when
  the workspace changes, while the application still supplies the editor-area
  builder and any clone policy.
- `BlenderDockingController.replaceAreaValue` changes an editor area through
  the dock tree itself rather than through selector-local state.

`BlenderApplicationController` accepts this service for multi-perspective
applications and creates a single default one for its existing `workspace`
constructor. Its original `docking` getter remains a compatibility surface.

## Consequences

Application workspaces are compositions of views, not route changes or special
screens. Switching perspectives preserves a user's layout in each perspective,
and the reusable docking behavior remains in BlenderUI instead of being copied
into every client app. Domain state, actual editor widgets, and workspace labels
continue to belong to the application.

## Durable sessions

The service also accepts an optional `BlenderWorkspacePersistence<T>`. It owns
the versioned session shape (active workspace, every dock tree, and optional
application workspace state) and the automatic write lifecycle. A definition
can attach `BlenderWorkspaceState<T>` or another observable
`BlenderWorkspaceSessionState` for contextual application state such as an
Outliner selection. The host owns the concrete storage adapter and typed
codecs. This means applications can use their existing settings or file service
while BlenderUI remains independent of SharedPreferences, desktop file paths,
and browser APIs.

Malformed or obsolete session data is ignored as a complete session; entries
for removed workspaces are ignored. Declared layouts remain the reliable
migration fallback. `BlenderWorkspaceShell` restores the session after first
paint and flushes it on lifecycle transitions. Hosts that own their shutdown
should await `flush()` explicitly.
