# Application and editor services

Date: 2026-07-17

## Context

High-density editor applications need more than standalone controls. They need
an app frame, workspace and docking coordination, commands and bindings,
history, status feedback, lifecycle presentation, Preferences, editor context,
and persistence. If these responsibilities live in each editor view, projects
repeat lifecycle code and cannot share consistent command or session behavior.

The blenderapp source establishes a useful ownership boundary:

- `scripts/startup/bl_ui/space_topbar.py` creates fixed menu/header regions and
  delegates workspace tabs to `template_ID_tabs` in
  `source/blender/editors/interface/templates/interface_template_id.cc`;
- workspace and screen data own layout/session state;
- the window manager owns operators and keymaps, including the splash/About
  presentation in `source/blender/windowmanager/intern/wm_splash_screen.cc`;
- `source/blender/editors/space_userpref/space_userpref.cc` implements
  Preferences as a dedicated space; and
- `scripts/startup/bl_ui/space_statusbar.py` presents status derived from
  application state.

## Decision

Keep BlenderUI services scoped by `BlenderApplicationController`, not global.
`BlenderWorkspaceShell` installs them around a dockable workspace and restores
or flushes persistence at the app lifecycle boundary.

| Concern | BlenderUI owner |
| --- | --- |
| Frame, workspaces, views, docking | `BlenderWorkspaceShell`, `BlenderWorkspaceService` |
| Menus and workspace bar | application menu/top-bar widgets and `BlenderCommandRegistry` |
| State and undo/redo | `BlenderHistoryStore` and controller-owned commands |
| Keyboard bindings | `BlenderCommandBindings` and `BlenderCommandBindingScope` |
| Preferences | optional `BlenderPreferencesService` |
| Status | `BlenderStatusService` and optional `BlenderApplicationStatusBar` |
| Splash and About | `BlenderApplicationPresentationService` |
| Editor views, Outliner, Properties context | `BlenderEditorSessionService` and `BlenderEditorSessionScope` |
| Persistent storage | app-provided `BlenderPersistentStorage` implementations |

`BlenderEditorSessionService` persists only stable string identifiers for the
active view in an area, selected Outliner item, and inspected Properties target.
It does not serialize domain objects or choose a storage package. An application
must resolve those identifiers against its own model and supply its own storage.
Editor widgets use `BlenderEditorSessionScope.watch` to rebuild when that shared
context changes and `.read` from event handlers.

The controller installs undo/redo bindings only when that shortcut is unbound,
so an application can provide a `BlenderCommandBindings` service with a
project-specific override without encountering duplicate keymap registration.

`BlenderApplicationScope` installs the same services for apps that retain
their own title bar, router, or frame. It lets those apps adopt the service
boundary without nesting a second dockable shell.

The shell does not inject a status-bar widget automatically: applications retain
control of chrome density and choose whether to use
`BlenderApplicationStatusBar` or a custom status surface.

## Consequences

- Menu actions, keyboard shortcuts, and command palettes can execute one
  command registration rather than independent callbacks.
- Editor surfaces receive shared context without knowing the app's lifecycle or
  storage implementation.
- Applications get a usable default app architecture while keeping domain
  models, storage technology, and concrete editor widgets outside BlenderUI.
- Persisted session IDs can be stale. Restoration remains non-blocking and
  applications must handle missing domain objects gracefully.

## Verification and experience

Focused service tests cover command dispatch, status changes, editor-session
persistence, and splash/About dialogs. A shell test confirms persisted editor
context is restored after the scoped services are installed. `flutter analyze
lib test` has no errors, with only existing `prefer_const_constructors` info
diagnostics. The full service suite and the focused shell tests pass. An earlier
multi-column menu geometry assertion was rechecked after responsive-menu work
and no longer reproduces. The complete UI suite is currently flaky in an
unrelated Properties test because `property-group-first` resolves both a
`KeyedSubtree` and `BlenderPanel` in the concurrently changed editor surface.
