# ADR-0006: Compose desktop applications through a reusable shell

Date: 2026-07-15

## Context

The package exposed individual controls, menus, docking, Preferences, state
stores, command registration, and service scopes, but every consumer still had
to discover and assemble the same lifecycle and widget hierarchy. The example
therefore rooted framework concerns in its own `State` object even though its
editor content was only one possible application composition.

## Decision

- Add `BlenderApplicationController<T>` as the explicit owner of a generic
  history store, command registry, service container, and docking controller.
- Add `BlenderWorkspaceShell<T>` as the public frame that provides `BlenderApp`,
  scoped services/state, the dockable workspace, top bar, and status bar.
- Keep menu contents, domain models, editor-area builders, persistence, and
  preference value changes caller-owned. The framework supplies structure and
  lifecycle, not an application data model.
- Represent the optional Preferences window with immutable
  `BlenderPreferencesConfiguration` descriptors and a public presentation
  helper. This allows a menu command, a temporary window, and an embedded
  editor to share the same preference descriptors.

## Consequences

Applications get a supported composition path without global state or a
mandatory third-party state-management package. The demo can focus on its
Blender-reference data and callbacks while still validating the package's
application framework. Apps that need a different navigation model can keep
using the lower-level widgets directly.

## Verification

Focused widget coverage proves that the shell scopes its state and command
services around a dockable area, and that the Preferences helper presents the
reusable descriptor-driven window.
