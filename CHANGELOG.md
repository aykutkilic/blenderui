# Changelog

## Unreleased

- Added Blender-style `Area Options` context menus to dock dividers with
  centered vertical/horizontal splits, directional joins, and content swaps.
- Added atomic dock-controller join and swap operations plus nested-edge leaf
  targeting, shared menu command presentation, and source-shaped area glyphs.
- Added viewport-safe, titled Blender context menus with disabled states,
  shortcuts, nested commands, delayed help, and secondary-click/long-press
  lifecycle callbacks.
- Added reusable Object, Outliner, Node, File Browser, Property, Tool, and Area
  context-menu catalogs with stable action IDs.
- Added target-aware context-menu builders to tree/list, Outliner, file, node,
  Properties, and tool-shelf surfaces; the example now routes commands with
  the exact entity under the pointer.
- Moved the standard grouped Object Mode tool shelf and orientation gizmo from
  the example into reusable View3D package widgets.
- Added the shared `BlenderPopoverPanel.settings` composition and removed
  repeated example-only editor-popover builders.
- Replaced completed, obsolete backlog documents with a current architecture
  guide and ownership decision record.

## 0.1.0 — 2026-07-15

Initial public release, prepared for publication on pub.dev.

- Initial Blender-inspired Flutter desktop UI toolkit.
- Added theme tokens, independent vector icons, core controls, layout
  primitives, and generic editor surfaces.
- Added Blender-style control variants, HSV/RGB color picker, property tabs,
  playback controls, anchored dropdowns, and console/text/image/spreadsheet
  editor surfaces.
- Added reusable selectable/filterable lists, file-browser breadcrumbs and
  list/grid modes, node socket rows, keymap editor, and Preferences editor.
- Added vector/path fields, color ramps, curve mapping, preview tiles,
  scrollbars, searchable operator menus, pie menus, anchored popovers, and
  dedicated UV/Dope Sheet/Graph/NLA/Sequencer/Clip editor surfaces.
- Added alpha-aware color fields, property keyframe/reset decorations, and
  Outliner visibility/lock columns, plus the severity-aware Info report editor.
- Added anchored pulldown menu buttons for Blender-style top-bar and area menus,
  plus a sample UI Catalog for exercising the control and template surface.
- Added a dense matrix field and a dedicated pointer-link glyph for Blender
  transform/data templates.
- Added normalized waveform, histogram, and vectorscope templates for image
  and compositor-style non-3D panels.
- Added recent-file and running-job templates for file menus and status areas,
  including selection and cancellation callbacks.
- Added attribute search/create menus, grouped layer selectors with shift
  selection, color-management settings, and editable curve profiles with
  presets and zoom controls.
- Added descriptor-driven modifier stacks and grouped node-input panels with
  linked-input treatment and modifier visibility, render, reorder, and remove
  actions.
- Reworked the sample shell to mirror Blender's desktop geometry: application
  menus and workspace tabs at the top, a compact editor header, left tool
  shelf, right Outliner-over-Properties column, and Timeline below only the
  left/center editor region.
- Added a reusable grouped editor-type selector with General, Animation,
  Scripting, and Data columns, Blender-style shortcuts, selected/hover states,
  editor descriptions, and viewport-safe anchored placement.
- Tuned the grouped editor menu to Blender desktop proportions with a bounded
  width, compact row height, reduced typography, and restrained padding so the
  workspace remains visible behind the popup.
- Added scroll-aware toolbar edge fades and workspace-tab tooltips; the sample
  application header now scrolls as one surface so trackpad gestures move file
  menus, workspace tabs, and scene controls together.
- Added reusable tool-option popovers to the tool shelf with selected options,
  hover descriptions, shortcuts, and compact Blender-style rows.
- Added responsive Properties panel sizing, Blender-style Scene context
  headers, raised numeric fields, right-aligned labels, and separated rounded
  property groups.
- Aligned the Properties area anatomy with Blender: a full-width editor
  toolbar, content-level context tab rail, active tool settings, and
  overflow-safe collapsed icon controls for very narrow panes.
- Added grouped Properties context tabs, Blender-style context captions, and
  a hover-opened visible-tabs menu with caller-owned visibility state.
- Corrected Properties arrow ownership: context options live in the header;
  visible-tab selection is anchored at the bottom of the tab rail.
- Refined default Blender visual fidelity for Properties tabs, panel outlines,
  option boxes, and text shadows using the local Blender theme/widget sources.
- Reworked the Outliner shell with hierarchy guides, alternating rows,
  restriction columns, and a Blender-style filter/restriction popover.
- Added semantic Outliner camera/light data rows and corrected restriction
  controls so visibility and lock state do not render as selected blue buttons.
- Added public Outliner display modes, real sample tree switching, and compact
  collapsed-item glyph/count summaries.
- Added Blender-style pane splitter affordances: a hairline edge with a wider
  drag target, directional resize cursors, hover/drag feedback, and a
  transient directional drag handle.
- Made `BlenderEditorShell` right and bottom editor boundaries resizable while
  retaining their configured dimensions as initial sizes.
- Added fading active resize guides and Blender-like numeric-field drag and
  precise text-edit interactions.
- Refined editor chrome, blank Outliner row alternation, and segmented Scene /
  View Layer identifier controls to match Blender's default UI theme.
- Corrected Properties header control anatomy and header-surface styling.
- Added per-editor area headers and independent editor-type selection for the
  main, Outliner, and Properties areas; Outliner keeps area type and display
  mode as separate controls.
- Split the application toolbar into a scrolling menu/workspace region and
  fixed Scene/View Layer groups, with an Add Workspace control.
- Restored workspace-strip edge fades and added a reusable compact Blender
  data-block group with an embedded Scene pin action.
- Tightened Scene/View Layer ID-template sizing, alignment, and action
  segmentation to match Blender's header controls.
- Refined ID-template icon, borders, pin/action states, and removed unrelated
  fixed right-header actions.
- Unified Scene/View Layer controls into flat zero-gap bordered ID templates.
- Added Blender-style specialised Tool Settings content and Properties editor
  body support for context-specific panel hierarchies.
- Refined the Properties tab rail grouping, spacing, selected state, and Tool
  glyph.
- Made Properties context tabs flat and inset-selected, replacing the visible
  group and button borders with Blender-style rail spacing and a quiet edge
  shadow.
- Added a joined Properties-navigation-rail option so the rail and content
  frame share one quiet seam instead of a double border and visible gutter.
- Aligned joined Properties panels to the frame edge while retaining a compact
  caption inset.
