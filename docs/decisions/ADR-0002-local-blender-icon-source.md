# ADR-0002: Use the local Blender icon source during development

Date: 2026-07-14

## Decision

On desktop platforms, `blender_ui` automatically looks for a sibling Blender
checkout at `../blender/release/datafiles/icons_svg` (and nearby workspace
locations) and uses its SVGs for matching `BlenderGlyph` values. Applications
can set `BLENDER_SOURCE_DIR` or call `BlenderIconSource.setDirectory` when the
checkout is elsewhere.

The package never bundles or copies Blender icons. If the checkout, a specific
SVG, or local-file support is unavailable, `BlenderIcon` uses the existing
clean-room `CustomPainter` implementation. Source SVGs are decorative and are
excluded from the semantics tree so the source-backed path has the same
accessibility behavior as the bundled painter.

## Context

The local Blender source checkout is the most useful visual reference while
developing this package, but a published Flutter package must remain usable
without that checkout and on platforms where `dart:io` is unavailable.

## Consequences

- Desktop development can immediately reflect Blender's current icon artwork.
- The package remains portable and does not redistribute Blender assets.
- `flutter_svg` is an optional implementation detail of the desktop source
  path; unsupported platforms compile to the existing painter-only behavior.
- A missing or renamed Blender SVG affects only that glyph, not the whole icon
  system.
