# Changelog

- Added reusable Grease Pencil Draw-mode headers, brush/tool state, source tool
  shelf, searchable Brush Asset Shelf, camera canvas, host stroke model, and
  Grease Pencil Dope Sheet Sidebar.
- Added actionable 2D Animation and Storyboarding splash templates with their
  2D Full Canvas and Video Editing workspaces in the example.
- Expanded the Sequencer with Channels, seconds display, strip-selection
  semantics, and a playhead-only repaint path.
- Replaced Grease Pencil brush/material dropdown approximations with Blender's
  reusable asset-shelf and material-slot popovers, including catalog filtering,
  brush previews, visibility/lock actions, and stroke/fill color fields.

- Rebuilt the Graph Editor as reusable Blender-shaped Channels and shared
  time/value Window regions with recursive F-curve hierarchy, keyframe and
  viewport models, Bezier/linear/constant interpolation, handles,
  extrapolation, markers, cursor, normalization, selection and move
  transactions, Graph/Drivers sidebars, and a playback-isolated overlay.
- Added viewport-culling and dense-key rendering optimizations and migrated the
  example Graph and Drivers surfaces to the shared library contracts.

## Unreleased

- Rebuilt Timeline as Blender's Dope Sheet subtype with independently clipped
  Channels/Search/Summary and window/scrub regions, source-ordered playback and
  frame-range controls, padded View2D framing, and a numbered playhead flag.
- Optimized Timeline scrubbing with prepared sorted keylists, horizontal and
  vertical viewport culling, batched canvas paths, static/playhead repaint
  layers, and example-workspace frame-state isolation.
- Extracted reusable playback ownership from the example into
  `BlenderPlaybackController` and `BlenderPlaybackBuilder`; Timeline and Dope
  Sheet can now repaint their playheads directly from any frame listenable.
- Removed the example's cross-editor View3D tool-shelf injection so each editor
  surface exclusively owns the tools and side regions registered for it.
- Added a manual-facing parity backlog for all 33 top-level interface topics
  and 23 documented editor types, and moved shared editor menu construction
  from the example app into the public `BlenderEditorMenuCatalog`.
- Added `BlenderUtilityEditorHeader` for library-owned Text, Console, Info,
  Outliner, File/Asset Browser, Spreadsheet, Project, Properties, and
  Preferences menu anatomy.
- Added a reusable active/disabled `BlenderEyedropper` control while keeping
  platform sampling and document mutation host-owned.
- Added a reusable, source-conditioned Image/UV header with immutable
  host-owned state, full Select/Image/UV menu taxonomy, and independent
  snapping, proportional, pin, gizmo, and overlay controls.
- Added shared Image/UV region geometry and mode-aware tool shelves, including
  a Paint-only brush asset shelf and committed 1200×700 rendered references.
- Added reusable immutable headers for View3D, Dope Sheet/Timeline,
  Graph/Drivers, NLA, Sequencer, Movie Clip, and Spreadsheet editors; the
  example now owns only their state, callbacks, and composition.
- Added Graph/Drivers sidebars, a shared animation playback footer, and stable
  keyed menu descriptors plus an overridable embedded-area editor selector.
- Added one deterministic 1200×700 rendered reference for every one of the 23
  editor types documented by the Blender manual.
- Added native matched-window and extreme-size verification, source-aligned
  11-point typography, overflow-safe scrolling rails, compact tree/property
  chrome, and a dock-level minimum child-layout contract.
- Added host-owned tree range/toggle selection and keyboard navigation on top
  of the existing generic drag/drop policy.
- Added Node Editor multi/box selection, grouped multi-node movement, optional
  scene-grid snapping, and graph-model helpers for applying host-owned
  selection and movement transactions.
- Added immutable nested-node-group breadcrumb navigation, selected-subgraph
  duplication with host-generated IDs, and a Bézier-sampled Cut Links canvas
  workflow.
- Added sortable File Browser Name/Date/Size/Type columns, structured file
  metadata, folder-first ordering, and caller-supplied Asset Browser previews.
- Added Spreadsheet selected/query filtering, sortable columns, row selection,
  numeric alignment, row indices, and hostable synchronized scroll state.
- Added a shared immutable Annotation settings panel, Text Editor status
  footer, Console command-history navigation, and selectable/severity-filtered
  Info rows.
- Optimized the universal Node Editor with viewport node/link culling,
  zoom-adaptive viewport-only grid painting, repaint isolation, cached link
  lookup per paint, and editor-local transient node movement.
- Added typed drag-to-connect sockets, connection validation, single- versus
  multi-input link policy, snapped wire previews, reverse input-to-output
  dragging, and example-owned persistent graph mutation.
- Replaced the application-wide hand-painted default icon backend with compact
  outlined Material Symbols while preserving the vector renderer as an
  explicit theme compatibility option.
- Rebuilt the generic Node Editor around typed, socket-specific graph data,
  resolved Bézier links, grid navigation, frames, reroutes, selection,
  collapsed/muted nodes, warnings, and evaluation overlays.
- Added reusable Node Editor headers, tree-specific nested menu catalogs,
  Geometry Nodes taxonomy, floating tools, and an active-node-aware sidebar.
- Replaced the example's shared shader fixture with a detailed, interactive
  Geometry Nodes modifier graph while keeping document state and commands in
  the example app.
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
- Aligned View3D chrome with blenderapp's source geometry: a 56 px toolbar,
  40 px tool buttons, 32 px toolbar glyphs, an 80 px orientation gizmo, and
  four 28 px navigation controls, with density-aware headers and icon buttons.
- Removed the untitled-region inset from editor canvases, repositioned View3D
  overlays to avoid collisions, restored the Pan control, and made collapsed
  headers preserve their editor selector without overflowing.
- Replaced the generic View3D mode and transform-orientation dropdowns with
  source-shaped selectors: the mode operator menu now carries Blender's six
  visible mode choices and icon-only selection treatment, while Transform
  Orientations uses a titled arrowed panel, connected property rows, and a
  separate create-orientation action.
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
