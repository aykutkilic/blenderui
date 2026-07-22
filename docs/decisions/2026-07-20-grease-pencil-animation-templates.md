# Grease Pencil animation templates and reusable regions

Date: 2026-07-20

## Context and source audit

Blender's 2D Animation and Storyboarding entries are application templates,
not cosmetic workspace labels. Their Python initialization lives in
`scripts/startup/bl_app_templates_system/2D_Animation/__init__.py` and
`Storyboarding/__init__.py`; the editor splits, scenes, objects, brushes, and
workspace defaults are stored in each packaged `startup.blend`.

The installed Blender 5.1.2 was queried in background mode with each app
template so the saved layouts could be measured without opening a GUI:

- 2D Animation owns `2D Animation` and `2D Full Canvas` workspaces. The first
  is View3D plus a 176-pixel Grease Pencil Dope Sheet and a 330-pixel
  Outliner/Tool Properties column. Full Canvas keeps View3D and a compact Dope
  Sheet. Both View3D screens expose Header, Tool Header, Tools, Asset Shelf,
  Asset Shelf Header, and Window regions.
- Storyboarding owns `Storyboarding` and `Video Editing` workspaces. Its main
  screen adds a 171-pixel Sequencer below the GP Dope Sheet. The Edit scene
  contains `Shot.001` and `Shot.002` scene strips at frames 1-49 and 49-97;
  shot scenes span frames 1-48. Video Editing uses a Sequencer Preview,
  Sequencer, and Strip Properties layout.
- Both templates start with `Fills` and `Lines` layers, select `Lines`, set
  onion keyframe type to All, and package Pencil, Eraser Soft, and Paint
  brushes. Auto keying is enabled for 2D Animation and Storyboarding shot
  scenes but disabled for Storyboarding's Edit scene.

View3D Grease Pencil behavior was also traced through `space_view3d.py`,
`space_toolsystem_toolbar.py`, `properties_grease_pencil_common.py`, and
`properties_data_grease_pencil.py`; animation and strip chrome was checked
against `space_dopesheet.py` and `space_sequencer.py`.

## Decision

The library now exposes reusable, host-controlled regions rather than a single
hard-coded template screen:

- `BlenderGreasePencilEditorHeader` and immutable header state for Draw menus,
  placement, axis, stroke presentation, overlays, gizmos, multi-frame, additive
  drawing, auto merge, weight data, and draw-on-back controls;
- `BlenderGreasePencilToolHeader` and immutable brush settings for brush asset,
  material, radius, strength, pressure, and popover actions;
- `BlenderAssetShelfPopover` now follows Blender's 10-unit catalog column and
  50-unit searchable asset-view composition. Grease Pencil brush selection
  uses that reusable surface instead of a conventional dropdown, while the
  shelf header owns the distinct multi-select catalog-visibility popup;
- `BlenderGreasePencilMaterialSelector` follows
  `TOPBAR_PT_grease_pencil_materials` with the material-slot list,
  visibility/lock/isolation actions, and stroke/fill color fields;
- `BlenderGreasePencilToolShelf`, `BlenderGreasePencilBrushAssetShelf`, and
  `BlenderGreasePencilViewport` for source tool taxonomy, searchable/category
  brush assets, camera framing, normalized host strokes, onion presentation,
  caption, navigation, and orientation controls;
- `BlenderGreasePencilDopeSheetSidebar` and a reusable Dope Sheet mode selector;
- Sequencer Channels, seconds display, strip selection semantics, and an
  isolated playhead repaint layer;
- `BlenderStartupTemplateEntry` and `BlenderStartupTemplateChooser` for
  application-owned startup template selection.

The example declares template dock trees and scene fixtures. Splash selection
switches to the correct editor composition and template-only workspace tabs.
Library widgets never create or mutate Grease Pencil datablocks, scenes,
strokes, brushes, or strips: the host owns domain state, undo, persistence, and
actual drawing/evaluation.

## Performance and accessibility

High-frequency Sequencer playhead updates repaint a separate overlay through a
`ValueListenable<double>` and do not rebuild the strip canvas or Channels
region. Brush assets use a horizontal lazy list. Painted Sequencer strip labels
are mirrored into semantics so assistive technology and tests can identify
scene strips without coupling to painter internals.

## Experience retained

- The source checkout contains template initialization Python but not the
  packaged `startup.blend`; background inspection of the installed application
  supplied the missing saved-layout evidence. An initial query incorrectly
  assumed `Screen.workspace`, and a Storyboarding strip query used the removed
  `sequences_all`; corrected queries enumerated screens directly and used
  `SequenceEditor.strips_all`.
- The first visual pass retained General workspace tabs. The packaged template
  evidence showed this was structurally wrong, so template-specific primary and
  secondary workspaces replaced them.
- Custom-painted strip labels were not discoverable with widget text finders.
  Adding semantics fixed the accessibility gap rather than weakening the test.
- Treating brush and material selectors as ordinary dropdown menus was visibly
  incorrect. `template_asset_shelf_popover()` and
  `GreasePencilMaterialsPanel` showed that they are separate anchored editor
  surfaces with different state and sizing; the generic asset shelf was moved
  out of specialized templates so editor headers can reuse it without a
  circular dependency.
