# Decision: Delay tooltip presentation

Date: 2026-07-16

## Context

`BlenderTooltip` showed its overlay immediately from `MouseRegion.onEnter`.
That made workspace tabs and compact toolbar controls display help text during
ordinary pointer movement, unlike the original Blender application.

Blender's `UI_TOOLTIP_DELAY` in
`source/blender/editors/include/UI_interface_c.hh` is 0.5 seconds.

## Decision

Make the reusable tooltip primitive schedule its overlay after 500ms. Cancel
the timer and remove any visible overlay when the pointer leaves. Keep the
delay configurable for specialised future surfaces, while retaining the
Blender-matching default for all existing callers.

## Consequences

- Moving across tabs and controls no longer causes immediate tooltip flashes.
- Existing tooltip call sites inherit the corrected behavior without edits.
- A specialised caller can choose a different delay explicitly if a future
  interaction requires it.

## Verification

The package widget suite verifies that the tooltip is hidden at 499ms, appears
at 500ms, and disappears when the pointer leaves.
