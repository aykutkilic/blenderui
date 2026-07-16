# Decision: Model workspace tabs as a dedicated Blender control

Date: 2026-07-16

## Context

Blender creates workspace tabs through `template_ID_tabs`, which maps each
workspace to the dedicated `ButtonType::Tab` widget. The widget has its own
theme colors, selected/inactive text colors, dimensions, radius, and aligned
layout. BlenderUI had been rendering the showcase row with the generic
top-bar button variant, producing a raised active fill and uniform bright text.

The source trace was made against the local Blender checkout:

- `scripts/startup/bl_ui/space_topbar.py`
- `source/blender/editors/interface/templates/interface_template_id.cc`
- `source/blender/editors/interface/interface_widgets.cc`
- `release/datafiles/userdef/userdef_default_theme.c`

## Decision

Use explicit `topBar`, `tabText`, and `tabTextSelected` theme colors. Render
workspace tabs with the tab variant, use the native 22px row height and 4px
radius, and remove explicit inter-tab spacing for tab rows. Keep generic
top-bar buttons separate for menus and other application chrome.

## Consequences

- Workspace tabs match Blender's `#1D1D1D` / `#303030` surfaces and
  `#989898` / `#FFFFFF` text hierarchy.
- The tab primitive is reusable for other source-shaped tab families rather
  than encoding workspace-specific colors in the showcase.
- Existing overflow and pointer-scroll behavior remains application-owned.

## Verification

The package widget suite covers tab colors, text colors, and 22px geometry;
the example workspace regression continues to cover selection and overflow.
