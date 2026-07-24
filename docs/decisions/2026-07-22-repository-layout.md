# Repository layout for library, extensions, and examples

## Context

The repository had one large `example/` application and a second top-level
`daw_example/` application. That made the component catalog look like part of
the Blender parity app, obscured the extension boundary, and left documentation
under a singular `doc/` directory.

## Decision

Use an explicit library-first layout:

```text
docs/                    architecture, references, decisions, history
lib/                     core BlenderUI package and shared services
packages/blender_ui_daw/ DAW-specific reusable extension
packages/blender_ui_workbook/ Jupyter/CodeForge/plot workbook extension
examples/blenderui/      main Blender-shaped application
examples/components/     standalone component/tutorial catalog
examples/daw/            DAW application composed from the extension
examples/workbook/       math and AI workbook host
test/                    core package contracts
```

Each application owns its native runners, fixtures, and composition. Shared
controls, editor contracts, services, and domain-neutral models stay in the
root package; reusable DAW models and surfaces stay in `packages/blender_ui_daw`.

## Consequences

- Examples can be built, documented, and tested independently.
- The component catalog no longer inflates the main parity application.
- Relative path dependencies are explicit and stable from every example.
- CI, structural checks, and documentation use the same directory vocabulary.
- Generated Flutter metadata remains local to each application and is ignored
  in the usual per-example locations.
