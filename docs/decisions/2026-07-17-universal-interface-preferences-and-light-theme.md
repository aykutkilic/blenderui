# Universal interface preferences and Blender Light

Date: 2026-07-17

## Context

The blenderapp Interface preference panels distinguish reusable user-interface
choices from domain-specific editor settings. The source of truth is
`scripts/startup/bl_ui/space_userpref.py`, backed by `PreferencesView` in
`source/blender/makesrna/intern/rna_userdef.cc`:

- Display exposes UI scale, line width, splash, developer extras, and
  tooltips.
- Editors exposes region overlap, corner handles, numeric arrows, navigation
  controls, border width, color-picker presentation, and factor formatting.
- The `Blender_Light.xml` interface-theme preset defines a proper light
  Blender palette; it is not a generic high-key application theme.

The prior example app visually copied many of these controls but used fixed
values and callbacks that discarded changes. That made the preferences window
look complete without giving other BlenderUI applications a durable service.

## Decision

BlenderUI provides an app-scoped `BlenderInterfacePreferencesService` with an
immutable `BlenderInterfacePreferences` value and optional host-provided
`BlenderPersistentStorage`. It owns only portable interface choices:

| Setting group | BlenderUI behavior |
| --- | --- |
| Theme, UI scale, line width | Applied live by `BlenderInterfaceTheme` to the package palette, text, density, icon size, and outline widths. |
| Splash | Read at app-scope startup before presenting a configured splash. |
| Tooltips, developer extras, editor affordances | Shared preferences available to applications and individual surfaces; each surface opts in only where the preference has a meaningful effect. |
| Color picker and factor display | Shared presentation policy for an application's controls, not a replacement for application data. |

`BlenderApplicationController` accepts the service, scopes it in the existing
service container, restores and flushes it with the editor session, and wraps
the application content in `BlenderInterfaceTheme`. Apps outside the dockable
shell can use the same controller scope or wrap a window directly.

`blenderInterfacePreferenceSections()` supplies Display, Editors, and Themes
sections for an existing `BlenderPreferencesConfiguration`. This preserves
application ownership of categories, additional sections, and persistence
technology while eliminating duplicated inert controls. The example app now
uses those sections.

## Light-theme transcription

`BlenderColorScheme.light` is transcribed from blenderapp's
`scripts/presets/interface_theme/Blender_Light.xml`:

- the base editor/panel grays, selection blue, outline tones, icon colors, and
  axis colors follow the source preset;
- the toolbar stays dark (`#434343`) and menus/panels remain Blender-neutral
  gray, matching the preset's contrast strategy; and
- BlenderUI maps the dark source text-field treatment to a light field because
  the current generic text-field API has one shared foreground color. A future
  per-widget foreground token can make that last detail exact without changing
  the public preference model.

No blenderapp implementation, runtime code, or assets are imported; the
library retains its clean-room, MIT implementation boundary.

## Consequences

- New desktop editor apps get real persisted UI-scale and theme preferences
  without introducing global state or a storage package dependency.
- Existing apps can adopt individual sections instead of a monolithic
  preferences screen.
- Viewport overlays, rendering settings, add-on controls, platform metrics,
  and scene statistics remain app-owned because they do not generalize across
  editor applications.
- The library now treats a preference as an executable policy only where it
  owns the effect; otherwise it exposes the policy so the host can apply it
  deliberately.

## Verification and experience

Focused service tests cover JSON persistence of interface values. Widget tests
verify that a scoped preference service selects Blender Light, scales compact
control density from 20 to 25 at 1.25x, applies the thick outline multiplier,
and is available through the app service container. Focused package tests pass
(130 tests). Flutter commands had to run through the installed SDK snapshot
with the SDK's telemetry/cache path approved outside the repository; the stock
wrapper could not write its engine cache in the workspace sandbox.
