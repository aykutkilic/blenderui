# ADR-0008: Keep visited workspace screens mounted

**Date:** 2026-07-16

## Context

Persisting a dock tree is necessary for relaunch, but it is not sufficient for
switching between workspace tabs in one running window. A conditional Flutter
branch disposes the inactive subtree. Returning to that tab then recreates its
editor state, scroll positions, in-flight forms, and subscriptions.

The local Blender source makes the distinction explicit:

- `DNA_workspace_types.h` defines a `WorkSpaceLayout` wrapper around a retained
  `bScreen` and documents a per-workspace/per-window relation.
- `workspace_edit.cc` selects the layout previously active for the target
  workspace before changing the window screen; it does not construct a new
  workspace UI every time.
- `workspace.cc` stores that relation through `WorkSpaceInstanceHook` and
  `WorkSpaceDataRelation`.

## Decision

Add `BlenderWorkspaceScreen<T>` and `BlenderWorkspaceScreenHost<T>` to the
application framework.

- The host lazily creates a screen widget on its first activation.
- Visited inactive screens remain mounted in `Offstage` with tickers disabled.
- A stable workspace ID owns the retained screen; the screen is disposed only
  when its definition is removed from the host.
- `BlenderWorkspaceService` continues to own durable dock/layout and
  application-session state. The screen host owns in-process widget lifetime.

## Consequences

Applications must use the retained host for application-level workspace tabs,
rather than conditionally returning one screen from a switch statement. This
preserves live work immediately; durable sessions still restore the same work
after a relaunch. The two layers are intentionally separate, mirroring
Blender's persistent screen/layout objects and per-window active hook.

## Verification

A widget regression increments state in a Folders screen, switches to
Dictionaries, and confirms the original Folders state remains when returning.
