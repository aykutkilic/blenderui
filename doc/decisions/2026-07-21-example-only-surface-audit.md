# Example-only surface audit

## Context

The showcase contains a large number of panels, dialogs, galleries, and
workspaces. Some are intended to demonstrate BlenderUI controls rather than
represent Blender application regions. The most misleading case was a
Properties-editor child pane titled “Quick Controls”.

## Findings

- Blender’s local `scripts/startup/bl_ui/space_properties.py` defines the
  Properties header, navigation bar, options/visibility popovers, and
  context-specific property panels. It does not define a generic Quick
  Controls region or a vertical child editor below Properties.
- The removed example pane combined unrelated actions and widget previews,
  making it look like a real Blender editor region in screenshots.
- The Components workspace and UI Catalog are deliberate documentation
  surfaces. They remain useful, but are explicitly example-only and must not
  drive library architecture or parity claims.

## Decision

Remove the synthetic Quick Controls pane and leave the Properties editor as a
single source-shaped region. Keep the Components/UI Catalog surfaces isolated
as opt-in showcase workspaces and track remaining branding/fixture differences
in the manual parity backlog.
