# Runtime keymaps and Preferences

Date: 2026-07-21

## Context

The package had a runtime `ShortcutActivator -> command id` map and a separate
static Keymap editor. The editor could not alter application behavior, duplicate
keys were rejected even when they belonged to different editor contexts, and
there was no restore, conflict, search-by-binding, or persistence boundary.

Blender's `wmKeyMap`, `wmKeyMapItem`, and `wmKeyConfig` distinguish key
configuration, keymap (`idname`, space, region), item event data, inactive and
user-modified state. `rna_keymap_ui.py` edits that same model, filters by name or
event, exposes item and keymap restore, and delegates import/export to the host.
`WM_keymap_active` overlays user maps on the active preset, while
`WM_keymap_item_compare` compares event values and modifiers within applicable
contexts.

## Decision

- Keep command ids as the stable operation identity and enrich
  `BlenderCommandBinding` with keymap, context, event metadata, active/repeat,
  user-defined, and default-activator state.
- Make `BlenderCommandBindings` the single mutable source used by both Flutter
  `Shortcuts` and Preferences. Expose context-filtered dispatch, semantic chord
  comparison, conflict reporting, item/keymap restore, and a versioned JSON
  snapshot.
- Represent Blender's broader keyboard/mouse/NDOF/text/timer families in the
  model, but only serialize and dispatch Flutter's keyboard `SingleActivator`
  subset at the application scope. Editor-specific pointer and modal handlers
  remain host-owned.
- Turn `BlenderKeymapEditor` into a live Preferences surface when command and
  binding services are supplied, while retaining static entries as a migration
  path.
- Allow `BlenderApplicationController` to adopt an injected command registry.
  This avoids initialization cycles when a Preferences configuration is built
  before the controller assignment completes.

## Consequences

Changing a chord in Preferences immediately rebuilds the runtime shortcut map.
The same chord may be reused in non-overlapping contexts, while collisions in a
context are reported without silently replacing the existing command. Hosts
can persist/export the JSON snapshot and provide their own file picker and
storage policy. Pointer gestures, modal operator properties, and complete
Blender preset files remain deliberate extension points rather than UI-only
claims.
