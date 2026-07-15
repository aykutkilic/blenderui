# ADR-0005: Scoped application services

Date: 2026-07-15

## Decision

Provide a small dependency-free application-services layer alongside the UI
widgets:

- `BlenderStateStore<T>` for observable immutable state
- `BlenderHistoryStore<T>` for bounded undo and redo
- `BlenderStateScope<T>` for typed widget-tree access
- `BlenderServiceContainer` and `BlenderServiceScope` for explicit dependency
  ownership and child scopes
- `BlenderCommandRegistry` for reusable commands shared by buttons, menus,
  shortcuts, and search surfaces

The services are optional. Controls continue to accept values and callbacks,
so applications can use Provider, Riverpod, Bloc, Redux, or another existing
architecture without adapters.

Service containers are never global singletons. The application or window
owns a root container, editor areas can create child containers, and only
retained services implementing `BlenderServiceDisposable` are disposed by the
container.

## Context

The package already makes dense controls and editor surfaces easier to build,
but applications still need repetitive glue for state ownership, undoable
editing, dependency lookup, and commands that appear in several UI surfaces.
A mandatory state framework would narrow the package's usefulness, while a
process-wide service locator would obscure lifetimes and make tests fragile.

Flutter's `ChangeNotifier`, `ValueListenable`, and inherited widgets provide a
small stable foundation for an optional built-in solution.

## Consequences

- Small applications can build a complete desktop architecture without adding
  another dependency.
- Larger applications can adopt only the service container or command registry
  and keep their preferred state framework.
- Immutable caller-owned domain state remains the package boundary.
- Undo history stores snapshots. Applications with very large state should
  store compact edit models or use a domain-specific command history.
- Registrations are keyed by Dart type. Applications needing multiple values
  of the same type should wrap them in distinct service classes.
