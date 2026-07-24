# Architecture guide

This guide is the shortest path for a third-party reviewer entering BlenderUI.

## Repository map

| Path | Responsibility |
| --- | --- |
| `lib/blender_ui.dart` | Supported runtime public API. Its explicit `show` lists make public ownership reviewable. |
| `lib/blender_ui_devtools.dart` | Optional developer/documentation widgets that should not enlarge the runtime surface. |
| `lib/src/application/` | Application controller, shell, top bar, presentation, and Preferences composition. |
| `lib/src/controls/` | Primitive buttons, fields, menus, tooltips, and overlay mechanics. |
| `lib/src/layout/` | Region/header/panel/tab/splitter/tool-shelf layout primitives. |
| `lib/src/editors/` | Generic editor surfaces such as Properties, Outliner, trees, nodes, files, timelines, and View3D sidebars. |
| `lib/src/non3d_editors/` | Complete non-3D editor families and their domain-neutral descriptors. |
| `lib/src/services/` | Scoped commands, persistence, feedback, editor sessions, and service lifecycles. |
| `lib/src/templates/`, `property_templates/`, `specialized_templates/` | Reusable compound controls grouped by stable UI domain. |
| `examples/blenderui/lib/showcase/` | Blender-application imitation composed from the public package. It owns fixtures and fake outcomes. |
| `examples/components/` | Standalone searchable component tutorials and API demonstrations. |
| `examples/daw/` | DAW application composition using the `blender_ui_daw` extension package. |
| `packages/blender_ui_workbook/` | Offline workbook sessions plus optional Jupyter, CodeForge/fallback editing, AI completion, and native plots. |
| `examples/workbook/` | Thin offline-first math and AI host composing shared application services and persisted dock workspaces while owning files, editor vocabulary, and runtime policy. |
| `test/`, `examples/*/test/` | Package contracts and application integration/visual-baseline behavior. |
| `tool/structural_guard.dart` | Enforces reviewability invariants across source and test files. |

Parent files such as `controls.dart`, `layout.dart`, and `editors.dart` are
same-library entry points. Their descriptive `part` files preserve private
sharing without turning implementation files into public libraries.

The [naming and ownership map](naming-and-ownership.md) distinguishes related
`Data`, `State`, `Controller`, `Service`, `Persistence`, `Host`, and `Shell`
types and records the theme, workspace, editor, application, DAW, and workbook
boundaries in one place.

## Dependency direction

```text
theme/icons/services
        ↓
controls and layout
        ↓
templates and generic editors
        ↓
application composition
        ↓
example app and host applications
```

Lower layers must not import the example. Editors may depend on controls,
layout, templates, theme, and domain-neutral services. Application composition
may assemble all package layers but must not acquire host data models.

## State and ownership

- Widgets accept values and callbacks; domain state stays with the host.
- Optional services are scoped through `BlenderServiceContainer`, never global.
- The container owns disposal of registered services. Application controllers
  own composition and startup, not a second disposal path.
- Persistence coordinators own scheduling, flushing, and error capture. Each
  service owns its schema and validation.
- Renderers remain host-owned. `BlenderViewportShell` owns navigation and
  overlay composition but not scene geometry.

## How to extend the package

1. Search the public barrel and the relevant domain folder for an existing
   surface.
2. Extend that surface when the behavior has the same ownership and lifecycle.
3. Prove reuse in both a package test and either the example or another host.
4. Keep sample values, fake statuses, and tutorial prose out of `lib/`.
5. Run the structural guard, analysis, and both test suites.
6. Record a lasting boundary change in `docs/decisions/` and the dated outcome
   in `docs/development-history.md`.

## Deliberate non-unifications

Status and reports, different painter families, and collection-like editor
surfaces remain separate because their lifecycles, coordinate systems, or
activation semantics differ. See
[reviewable codebase boundaries](decisions/2026-07-19-reviewable-codebase-boundaries.md)
for the rationale.
