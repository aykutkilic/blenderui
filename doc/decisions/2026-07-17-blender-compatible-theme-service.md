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

## Follow-up: live temporary Preferences windows

blenderapp's `SCREEN_OT_userpref_show` calls
`ED_screen_temp_space_open(... SPACE_USERPREF,
U.preferences_display_type, false)`. The screen implementation delegates the
window display mode to `WM_window_open_temp()` or opens a temporary fullscreen
space. Preferences therefore belongs to the same temporary-editor/window
lifecycle as other Blender editors, rather than being a one-shot painted
dialog.

BlenderUI retains a dependency-free embedded temporary-window presenter, but
now gives it the corresponding interaction contract: its title bar drags,
its resize grip resizes, and its close/minimize/maximize controls are real
actions. The default presenter closes its route, collapses a minimized window
to its title bar, and fills the safe viewport when maximized. Hosts that own a
native temporary window can delegate minimize/maximize through
`BlenderPreferencesConfiguration`; the library does not impose a window-plugin
dependency or platform-specific window API.

The earlier `InheritedTheme.captureAll()` change was only a snapshot of the
theme at route creation. That correctly fixed overlays opening in the root
dark palette, but it could not repaint an already-open Preferences route when
the theme service changed. `BlenderThemeController` and `BlenderThemeScope`
now carry the live theme source across route boundaries. Dialog/popup routes
still capture ordinary inherited themes, then install a live inner
`BlenderTheme` that listens to the scoped source. This preserves route
isolation while ensuring theme editing immediately updates the Preferences
window itself.

Focused widget tests cover live dialog palette updates plus move, minimize,
restore, and close actions. An initial drag assertion looked at the window
root's `RenderTransform`, which reports its layout origin rather than the
translated child position; the final test asserts the content position, the
observable behavior users see.

## Follow-up: root-Navigator presentation and discoverable resize

The example app opens its global Edit > Preferences command through its root
`Navigator` key. That context intentionally sits above `BlenderApplicationScope`,
so neither `BlenderThemeScope` nor any other inherited application service is
visible there. The first live-route bridge therefore worked for locally
presented dialogs but still left the real temporary Preferences window frozen
on the palette that was active at opening.

`BlenderApplicationController` now owns a live `BlenderThemeController` for
the registered interface/theme services and binds it to
`BlenderPreferencesService`. The presenter passes that explicit controller to
the route, independent of the context used to dispatch the command. This is
the appropriate service boundary for global menu commands: the application
owns the live state; the navigator only presents it.

The old resize affordance was an invisible 18px bottom-right hit target. It
was easy to miss and did not offer native-window-like edge behavior. The
temporary window now exposes right and bottom edge targets plus a visible,
larger diagonal corner grip. The grip resizes both dimensions while each edge
resizes one axis. Focused example coverage exercises `Edit > Preferences`,
selects Blender Light, asserts the dialog surface palette, and drags the
visible corner grip.

The complete service suite also caught an initialization oversight in the
first controller implementation: applications that do not opt into Interface
preferences still dispose an application controller, so its optional live
theme controller must be initialized to `null`, not left as an unset `late`
field. The no-preferences path is now covered by the existing broad service
and widget suite.

## Follow-up: ThemeTopBar and native title-bar appearance

The local blenderapp `Blender_Light.xml` distinguishes the light application
top bar from its intentionally dark toolbar-item widgets: `ThemeTopBar` has
`ThemeSpaceGeneric.back="#b3b3b3"`, while `wcol_toolbar_item.inner` is
`#434343`. BlenderUI had incorrectly mapped the latter to its `topBar` role,
which kept File/Edit menus and View/Select/Add area menus dark after choosing
Blender Light. The portable codec now reads and writes `ThemeTopBar`, and the
built-in light palette uses its source `#B3B3B3` value. A widget regression
asserts the View-style `topBar` menu background, and the XML round-trip test
covers `ThemeTopBar`.

Flutter widgets cannot recolor macOS's native title bar. The example's macOS
runner therefore exposes a narrow `blender_ui/window_chrome` method channel.
The showcase listens to the active theme and requests `NSAppearance.aqua` or
`NSAppearance.darkAqua` from the runner based on the active palette's canvas
luminance. The bridge is explicitly best effort on non-desktop hosts and is
kept in the example runner rather than forcing a native-window dependency on
BlenderUI applications. A macOS debug build completed after the change.

## Follow-up: live overlay text style

`InheritedTheme.captureAll()` also retains the initiating route's
`DefaultTextStyle`. Updating only the live `BlenderTheme` therefore corrected
the Preferences background while leaving unstyled text inherited from the
dark route. The dialog bridge now installs a live `DefaultTextStyle` alongside
the live `BlenderTheme`, using the current palette's foreground. The
root-Navigator Preferences regression asserts both the updated canvas and the
resolved default text color after selecting Blender Light.
