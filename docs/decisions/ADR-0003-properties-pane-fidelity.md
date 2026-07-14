# ADR-0003: Model Properties surfaces by semantic role

- Status: Accepted
- Date: 2026-07-14
- Local Blender reference: `../blender` `main` at
  `68bdd158cc49af6191f0d9480510f4c5214f2df5`

## Context

The sample Properties pane used generic raised and surface colors for several
different Blender regions. That made the editor backdrop too light, the nested
panel body too dark, and panel outlines too prominent. Header content was also
laid out as a conventional left/right toolbar, which packed the search field
against the trailing menu instead of centering it in the area. Segmented mode
controls compounded their one-pixel group gap with a border on every button,
creating thick black seams.

The first generic property-row implementation also treated every property as
the same two-column form. This detached boolean labels from their checkboxes,
leaving the name in the label column and a lone control in the value column.

Blender's default theme and panel drawing code distinguish these roles:

- the Properties region background is opaque `#303030`;
- top-level panel headers and bodies are opaque `#3D3D3D`;
- nested panel bodies apply black at alpha `0x1F` over their parent panel;
- panel outlines apply white at alpha `0x11`;
- the header search is centered independently of the leading editor selector
  and trailing context menu;
- selection-operation segments are separate, borderless buttons with only the
  group background visible between them.
- ordinary properties use a 40/60 label/value split, while boolean properties
  keep their checkbox and name together in the value column.

## Decision

Expose semantic Properties background, panel background, nested-panel overlay,
and panel-outline tokens in `BlenderColorScheme`. Panels consume those tokens
instead of approximating them with generic surface or editor-border colors.

Allow `BlenderAreaHeader` to host a centered overlay independently from its
leading and trailing rows. This keeps the reusable header responsive while
matching Blender's area-header composition.

Keep navigation-rail width separate from tab-tile size. Keep segmented-button
borders configurable so a group can own its spacing and silhouette without
stacked per-button outlines.

Represent property-label placement as an explicit row policy. Descriptors
select Blender's boolean exception automatically from their value type, while
allowing callers to override the policy for specialized controls.

## Consequences

- Alpha theme tokens preserve Blender's backdrop composition when callers
  customize the parent panel color.
- Properties styling remains reusable instead of being embedded in the sample.
- Existing header and button call sites retain their current behavior because
  the new center slot and border override are opt-in.
- Custom color schemes can override the new semantic roles explicitly.
- Boolean property composition stays correct in every Properties panel rather
  than being patched into individual example rows.
