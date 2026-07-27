# Decision: Compact dropdowns retain their selected value

Date: 2026-07-27

## Context

`BlenderDropdown.compact` removed the selected label unconditionally. Header
callers commonly assigned widths between 72 and 142 px but supplied no item
icons, producing an empty button with only a disclosure arrow. The same flag
also left those header controls with ordinary property-button colors and no
visual open state.

Blender's header selectors stay dense while showing the active value and its
semantic icon. Only a small subset of selectors are intentionally icon-only.

## Decision

- Compact mode controls header density and toolbar styling; it does not remove
  the selected value.
- The selected item's label and icon are rendered in the closed trigger.
- The trigger uses its selected state while the menu is open.
- Callers that truly require an icon-only control opt into `iconOnly`.
- Triggers are vertically centered in their header row. Generic menus use one
  scaled control-height per row, content-aware width with Blender's 180 px
  minimum, gray hover versus blue selection, and a floating menu shadow.
- Header pulldowns use a flat trigger on the header surface, with the same gray
  raised state for hover and open menus instead of a bordered blue button.
- Toolbars coordinate their direct pulldown peers. While one is open, moving
  the pointer onto another peer closes the current route and opens the hovered
  menu; nested submenu popovers remain independently owned by their parent.

## Consequences

- Existing wide compact dropdowns become self-describing without call-site
  workarounds.
- Narrow icon-only selectors remain available through an explicit contract.
- Mode and data-block selectors inherit consistent Blender-like closed and
  open presentation.

## Verification

Focused widget tests cover selected label/icon rendering, open-state styling,
selection changes, explicit icon-only behavior, flat pulldown triggers, and
hover switching between sibling toolbar menus.
