# ADR-0001: Foundation and provenance

Date: 2026-07-13

## Decision

Build one public `blender_ui` package on Flutter's core widget, rendering,
painting, foundation, and services APIs. Material and Cupertino are not package
dependencies. Controls are composable widgets; dense editor surfaces may use
custom render objects or painters after profiling demonstrates the need.

Editor widgets receive immutable, caller-owned descriptor models and callbacks.
They do not model Blender data or communicate with a Blender process.

The implementation is clean-room inspired. Blender source is consulted for
behavior and visual observations, but Blender implementation code and Blender
assets are not copied into this repository. The package and original icon set
use the MIT license.

## Context

The repository started empty. Flutter's Material/Cupertino extraction is an
ongoing upstream effort, so coupling this package to an in-transition package
would make the foundation fragile. Blender's UI source separates layout,
widget drawing, and event handling; the same separation is useful here.

## Consequences

- The library remains usable with future Flutter design-system package changes.
- Applications can compose the controls with their own domain models.
- Blender implementation and data-model parity remain out of scope, but
  visual and interaction parity for Blender's controls, templates, layouts,
  and non-3D editors is the long-term target. Detailed 3D rendering is not
  part of this package.
- Dense editor surfaces require benchmark coverage and careful repaint bounds.
