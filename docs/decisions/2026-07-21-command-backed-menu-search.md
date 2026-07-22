# Command-backed Menu Search

Date: 2026-07-21

## Source audit

Blender's `WM_OT_search_menu` creates a centered popup block with an activated
search button and a result area. `interface_template_search_menu.cc` extracts
operators and property actions from nested menus together with their full menu
ancestry, icons, enabled state, context, and weights. `BLI_string_search.hh`
then ranks normalized word groups, prioritizes the highlighted group, retains a
logical recent-use timestamp, and keeps deprecated entries below normal ones.

This is distinct from a generic searchable enum or asset picker: selecting a
result executes the same operation that owns the corresponding menu entry.

## Decision

- `BlenderCommand` now carries optional menu ancestry, search aliases, weight,
  icon, searchable/deprecated state, and continues to own its enabled and
  execution callbacks.
- `BlenderCommandRegistry.search` performs deterministic multi-token matching
  over labels, ancestry, descriptions, and aliases. Exact, prefix, word-prefix,
  substring, and subsequence matches are ordered in that sequence. Successful
  execution updates a bounded recent-command order used as a tie breaker;
  otherwise results use Blender's full-path alphabetical order.
- `BlenderMenuSearch` is the reusable interactive surface. It owns only query,
  highlighted-row, focus, and scroll state; the registry owns results and
  execution. It supports pointer hover/click, Up/Down, Enter, Escape, disabled
  entries, icons, shortcuts, and empty results.
- `showBlenderMenuSearch` owns the centered, theme-retaining popup route.
- `BlenderCommandBindingScope` now establishes a default focus descendant so
  global bindings such as F3 work before another control has requested focus.
  Focused text editors remain descendants and therefore keep their own key
  handling precedence.

The example registers source-shaped Add commands and application/editor
commands, opens the same surface from Edit > Menu Search and Operator Search,
and binds F3 to the registered menu-search command.

## Performance

Search iterates the in-memory command registry and caps returned rows. Result
rows use a lazy fixed-extent list, and query/selection updates do not rebuild
the workspace behind the popup. The recent cache is a bounded list of 32 ids.

## Experience retained

- The repository already had `BlenderSearchMenu`, but it was a generic
  substring-filtered picker. Reusing it directly would have hidden command
  ancestry, recent ordering, execution, and global shortcut semantics.
- The first F3 integration test did not open the popup because the command
  shortcut tree had no initial focus descendant. Fixing focus ownership in
  `BlenderCommandBindingScope` corrected all application-level shortcuts
  instead of adding an example-only raw keyboard listener.
- The first example assertion matched the existing Outliner Camera labels as
  well as the popup row. Scoping the assertion to `BlenderMenuSearch` retained
  the correct integration boundary.
