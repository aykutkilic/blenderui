# Blender-compatible theme service

Date: 2026-07-17

## Context

blenderapp presents interface themes as XML presets rather than as an
application-specific color-scheme format. Its Themes preferences header offers
a preset selector, add/remove/save controls, an `Install...` action, and a
reset action. The relevant local source is:

- `scripts/startup/bl_ui/space_userpref.py`, where the preset map contains
  `preferences.themes[0] -> Theme` and
  `preferences.ui_styles[0] -> ThemeStyle`;
- `scripts/startup/bl_operators/presets.py`, which writes and applies XML
  presets and only permits a fixed set of theme RNA types while reading;
- `scripts/startup/bl_operators/userpref.py`, which installs an XML file into
  Blender's user preset directory before applying it; and
- `scripts/modules/_rna_xml.py`, which serializes the `<bpy>`, `<Theme>`, and
  `<ThemeStyle>` XML structure and decodes colors as `#RRGGBBAA`.

The full Blender theme model includes every editor's region palette and UI
style data. BlenderUI must not claim that it can apply those editor-specific
settings when it has no equivalent surface. It does, however, need a portable
theme service that lets every BlenderUI application share the compatible UI
palette, editable Preferences, and host-owned save/load behavior.

## Decision

`BlenderThemeService` is the app-scoped theme registry. It exposes Blender
Dark and the source-matched Blender Light as protected built-ins, supports
custom/imported definitions, persists custom themes through the existing
`BlenderPersistentStorage` contract, and is registered by
`BlenderApplicationController` alongside the other app services.

Editing a built-in creates a custom copy first. Removing a built-in is
rejected. Reset selects Blender Dark without deleting custom or installed
themes, matching Blender's distinction between choosing the default and
managing preset files.

`BlenderThemeXmlCodec` reads and writes a deliberately portable Blender XML
subset:

| Blender XML area | BlenderUI palette roles |
| --- | --- |
| `ThemeUserInterface` | editor borders/outlines, cursor, links, and panel colors |
| `wcol_regular`, `wcol_text`, `wcol_toolbar_item`, `wcol_menu_back`, `wcol_tab`, `wcol_list_item` | controls, fields, menus, tabs, selection, and text |
| `wcol_state` | warning, error, success |
| `ThemePreferences` | main canvas/background |

Exports use the Blender `<bpy><Theme>...<ThemeStyle /></bpy>` shape and
`#RRGGBBAA` colors, so Blender can apply the values it recognizes. Imports
ignore unknown Blender regions rather than serializing misleading substitute
state. This is compatibility for the shared UI palette, not a promise of
lossless round-tripping for arbitrary Blender editors or future XML fields.

`BlenderThemePreferencesEditor` and
`blenderThemePreferenceSection()` supply the common Themes-category surface.
`BlenderThemeFileActions` deliberately leaves file picking and writing with
the host app: desktop sandbox entitlements, a file-picker package, browser
downloads, and a user preset directory are platform/application concerns.
The service owns XML content, validation, state, and persistence; the host
only supplies `onInstall` and `onSave` callbacks. The standard
`blenderInterfacePreferenceSections()` accepts those actions so an app can
adopt the complete interface/theme Preferences composition in one call.

## Consequences

- A BlenderUI app receives a live theme palette, persisted custom themes, and
  Blender-compatible XML import/export without a global registry or a required
  filesystem dependency.
- Apps retain control of where files come from and go to, which is necessary
  for native sandboxed, web, and embedded environments.
- A Blender XML import applies only tokens BlenderUI renders; unsupported
  regions are safely ignored and are not preserved on a subsequent export.
- `BlenderInterfacePreferencesService` remains responsible for scale and
  display metrics. When a theme service is present, it supplies the palette,
  while those interface preferences continue to scale it live.

## Verification and experience

Focused tests use Blender-shaped XML with `Theme`, `ThemeStyle`,
`ThemeUserInterface`, widget colors, state colors, and preferences. They cover
decode/encode/decode behavior, custom-theme persistence, protected built-ins,
and live application-scope palette changes. The focused package test command
completed with 135 passing tests. The targeted example Preferences test also
passes with its intentional golden baseline updated.

The initial formatter attempt used the Flutter command wrapper, which has no
`format` subcommand. Formatting must use the SDK's `dart format`; Flutter is
used for analysis and tests. This is recorded here so future maintenance does
not repeat the failed invocation. The example is its own Flutter package, so
its tests must run from `example/`; invoking `example/test/widget_test.dart`
from the library root makes `package:blender_ui_example` imports fail before
any test executes. The full example golden suite currently has broad unrelated
visual-baseline drift, so verification was intentionally limited to the
changed Preferences scenario rather than rebaselining unrelated editor views.

## Follow-up: scoped theme propagation

Route-based menus, dropdowns, popovers, context menus, and dialogs are built
by Flutter above the application page. Without explicitly capturing inherited
themes, they read BlenderUI's root default palette instead of the active
interface theme. `controls.dart` now uses `InheritedTheme.captureAll()` when
creating those routes, so the surface inherits the initiating control's theme.

The example's custom Tool Settings panels had a separate ownership error: the
`ShowcaseApp` state context sits above `BlenderApplicationScope`, so reading
`BlenderTheme.of(context)` while assembling panel decorations froze them at the
root dark palette. The affected helpers now resolve colors inside a descendant
`Builder`, where the active scoped theme is available. This is the durable
pattern for application-owned widget factories that need an inherited service.

The regression test exposed a 45px overflow in the initial text-button Themes
header at narrow Preferences widths. The header now follows Blender's compact
icon action pattern for new/remove/save/install/reset. Tests cover route-menu
palette capture, XML `ThemeProperties` background mapping, and a real example
theme change reaching the Properties subsection.
