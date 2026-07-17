# Framework extraction from the example

Date: 2026-07-17

Status: Accepted

## Context

The example app had become the proving ground for application chrome,
session-aware editor areas, property catalogs, background activity, viewport
navigation, documentation tooling, and category navigation. Many of those
implementations were reusable, but leaving them in the example forced real
applications to copy behavior and created parallel sources of truth.

The local blenderapp checkout remained the visual and behavioral reference.
The extraction does not copy Blender implementation code or domain models; it
translates stable ownership and composition boundaries into Flutter APIs.

## Decision

BlenderUI owns reusable editor-framework contracts and presentation:

- `BlenderEditorAreaController` and `BlenderEditorAreaHost` bind stable area
  IDs to persisted view selection while applications provide editor builders.
- `BlenderMenuDescriptor`, command-backed controls, and
  `BlenderEditorHeaderPreset` share menu semantics without replacing the
  command registry.
- `BlenderApplicationTopBar`, job/report services, and the appearance adapter
  consolidate application chrome and lifecycle services.
- `BlenderPropertyFactory`, immutable graph operations,
  `BlenderViewportShell`, and `BlenderPopoverPanel` own repeatable interaction
  and layout contracts while host data and rendering stay outside the package.
- `blender_ui_devtools.dart` isolates code-snippet tooling from the normal
  runtime barrel.
- category navigation is shared by Preferences and the component catalog.

Concrete platform channels, sample jobs/reports, cube geometry, tutorial prose,
and source-shaped sample property values remain in the example.

## Migration and compatibility

Existing widget menu slots remain available alongside descriptor slots.
Application menu bar callers retain their public API. Property factory changes
are additive, including typed choices, panel enabled/toggle state, and numeric
stepper options. Arbitrary popover builders and custom viewport renderers remain
supported.

The example was migrated in the same change so no duplicate local framework
implementation remains. Screenshot golden assertions and PNGs were removed;
behavioral widget tests and live component examples are now the maintained
documentation path.

## Tooling and failures

- The installed Flutter SDK attempted to update files in its shared cache;
  formatting and verification therefore required approved access outside the
  repository sandbox.
- The first devtools code block used Material `SelectionArea`, which failed in
  the package's widget-only application shell due to missing
  `MaterialLocalizations`. It was replaced with a widget-layer
  `SelectableRegion` using empty platform controls, preserving selection
  without adding a Material application dependency.
- Initial editor-header preset adoption replaced richer Image/UV menu content.
  The migration was narrowed to preserve source-shaped application menus while
  still proving presets on materially different editor headers.
- The property catalog migration was a mechanical rewrite across hundreds of
  call sites. Analysis exposed two unrelated local UI helpers with overlapping
  names; those remain explicitly example-owned under distinct names.

## Verification

- `dart analyze` for the package and example.
- Full package Flutter test suite.
- Full example behavioral Flutter test suite after removal of golden-only
  assertions.
- Focused contracts for editor restoration/fallback, commands, property
  options, graph updates, jobs/reports, both top-bar overflow policies, and
  viewport navigation.
- A rendered browser check was attempted against the locally served Flutter
  web app, but the in-app browser connection lacked its required sandbox-policy
  metadata. The served build and behavioral tests remained available; no
  alternate browser automation stack was introduced.
