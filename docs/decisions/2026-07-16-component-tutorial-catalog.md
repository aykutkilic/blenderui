# Decision: Build a live component tutorial catalog

Date: 2026-07-16

## Context

The existing Components workspace grouped examples into six broad feature
pages. That was useful for exploration, but it did not provide the per-
component navigation, tutorial guidance, or source-code surface
needed for a library documentation experience. Material UI's all-components
page provides the reference information architecture: categorized discovery
followed by dedicated component pages.

## Decision

Add `ComponentCatalogPage` as a standalone `examples/components` application. It owns a
searchable categorized index and a stable component ID for each tutorial page.
Each page contains:

- the real component as a live interactive preview;
- a minimal code snippet for that preview;
- compose/state/callback tutorial steps; and
- the public API expression used by the preview.

Keep the existing full BlenderUI application in `examples/blenderui` and its
broader Components workspace intact. The standalone Components application is
the focused documentation entry point, while the BlenderUI example remains the
realistic Blender application composition.

## Consequences

- New components can be added by extending one metadata entry and one live
  preview branch; the code snippet stays next to its tutorial metadata.
- The catalog is useful without requiring the full editor workspace to be
  mounted first.
- Preview state remains local to the example host, while callbacks visibly
  report their effects. This keeps the catalog representative of normal
  application-owned state without adding demo-specific behavior to library
  widgets.
- The multi-column menu example uses the public menu as popover content rather
  than duplicating dropdown geometry, keeping the example aligned with the
  library's editor-type selector composition.
- The example also documents the menu's responsive behavior: groups stay
  columnar when the available width supports them and stack vertically when it
  does not.
- The Properties example follows Blender's source ownership model: nested
  groups describe panel hierarchy, header widgets own feature toggles, and
  group `enabled` state controls only the body. Bounded numeric values use the
  shared number-field range fill rather than a demo-only progress treatment.
  Factor values such as render shadow resolution disable number steppers,
  matching Blender's `NumSlider` control.

## Verification

- `flutter test test/component_catalog_test.dart` from `examples/components`
  passes catalog browsing and
  verifies a live Button callback, the Tree page, the code example, and
  multi-column dropdown selection, and nested Properties interaction.
- `flutter analyze` reports no errors or warnings for the example package.
