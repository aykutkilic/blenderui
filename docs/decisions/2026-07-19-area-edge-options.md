# Area-edge options belong to docking

Date: 2026-07-19

## Decision

`BlenderDockingWorkspace` owns the context menu on a rendered dock divider.
`BlenderDockingController` owns the corresponding immutable tree mutations,
and applications receive the behavior through `BlenderWorkspaceHost` and
`BlenderWorkspaceShell` without rebuilding the menu themselves.

The public `BlenderSplitter` remains a geometry primitive. It exposes the
divider identity and secondary-click event needed by docking, while the menu
catalog and command routing stay out of the splitter.

## Blender source mapping

The implementation follows the local blenderapp checkout:

- `source/blender/editors/screen/screen_ops.cc`,
  `screen_area_options_invoke()`, builds `Area Options` in this order:
  Vertical Split, Horizontal Split, directional joins, and Swap Areas.
- `screen_area_edge_from_cursor()` selects the areas immediately across the
  clicked edge. On a vertical edge its first area is on the right; on a
  horizontal edge its first area is above.
- `area_join_apply()` and `screen_area_join_aligned()` retain the source area
  and remove the target area. Consequently, `Join Right` retains the left
  editor and absorbs the right, while `Join Up` retains the lower editor and
  absorbs the upper.
- `area_swap_exec()` calls `ED_area_swapspace()`: editor contents exchange
  positions but the screen geometry does not move.
- `SCREEN_OT_area_split` supplies the tooltip text `Split selected area into
  new windows`. Blender's touch menu executes a centered `0.49999` split; the
  Flutter command uses a centered `0.5` split because it has no separate modal
  split-line placement phase.
- The menu glyphs are small vector transcriptions of
  `release/datafiles/icons_svg/split_horizontal.svg`,
  `split_vertical.svg`, `area_join*.svg`, and `area_swap.svg`. They remain
  package-native and do not create a runtime dependency on a Blender checkout.

## Tree and geometry boundary

A split-tree node can separate two nested subtrees, so its edge does not imply
one fixed leaf pair. At menu-open time the workspace resolves the nearest leaf
on each side whose rendered rectangle crosses the pointer. Commands therefore
operate on the same two visible editors the user pointed at, including along a
segmented edge in a nested layout.

`joinAreas()` intentionally accepts retained and removed area ids. Directional
meaning is established by the rendered workspace, where adjacency is known;
the model validates identity and existence, removes one leaf, collapses its
now-redundant ancestors, and notifies once. `swapAreaValues()` similarly
updates both leaves and notifies once.

## Interaction lesson

The first implementation wrapped the divider's drag detector in
`BlenderContextMenu`. The focused widget test showed that Flutter's horizontal
or vertical drag recognizer won the secondary-button gesture arena, so the
menu never opened. The retained solution lets the existing divider detector
receive `onSecondaryTapDown` directly and calls the shared imperative
`showBlenderContextMenu()` presentation function. Ordinary content should
continue to use the declarative `BlenderContextMenu` wrapper.

Formatting and Flutter tests also required scoped access to Flutter's shared
SDK cache because `update_engine_version.sh` writes outside the repository.
