# Decision: Keep shared tooltips clear of the mouse pointer

Date: 2026-07-27

## Context

`BlenderTooltip` placed its overlay 10 px below the target control. On compact
toolbar controls, the visible lower tip of the mouse pointer could still reach
the tooltip, obscuring its first pixels and making the text look clipped.

## Decision

Use a shared 16 px vertical clearance between the target control and tooltip.
Keep the value in the reusable tooltip primitive so all library consumers get
the same pointer-safe behavior without per-control adjustments.

## Consequences

- Tooltip text remains visible below compact controls when the pointer rests on
  the control.
- The overlay is slightly farther from its target, but remains within the
  spacing used by Blender's native tooltip placement.
- The tooltip geometry test now protects the pointer-clearance contract.

## Verification

The delayed-tooltip widget test verifies that the rendered tooltip starts at
least 16 px below its target after the standard delay.
