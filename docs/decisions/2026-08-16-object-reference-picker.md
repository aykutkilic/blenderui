# Object-reference picker ownership

Date: 2026-08-16

## Decision

`BlenderObjectPicker<T>` is the shared BlenderUI primitive for ordinary typed
object references. It follows blenderapp's pointer-property `prop_search`
control rather than the larger `template_ID` data-block lifecycle control.

The widget owns compact field geometry, search/filter presentation, selected
and unresolved-reference labels, typed icons, clearing, accessibility, and the
active eyedropper affordance. Hosts own the object catalog, persisted value,
and modal sampling because only the embedding application can resolve an
Outliner or viewport click to a domain object.

## Source evidence

blenderapp's `interface_layout.cc` configures pointer properties as searchable
collection controls. `interface.cc` replaces the eyedropper extra icon with a
clear action once the search field contains a linked value, while
`eyedropper_datablock.cc` resolves compatible objects from the 3D View or
Outliner. BlenderUI preserves those ownership boundaries without importing
Blender's RNA or editor model.

## Consequences

- `BlenderDataBlockField` remains the full data-block lifecycle template.
- Broken persisted references stay visible and clearable until a host repairs
  them; a missing catalog item is never silently presented as `null`.
- Eyedropper activation is a callback, not a platform or document-model
  assumption in the library.
