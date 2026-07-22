# BlenderUI examples

The repository keeps host applications separate from the reusable package.
Each example is a standalone Flutter application with its own `pubspec.yaml`.

| Directory | Purpose |
| --- | --- |
| `blenderui/` | The main Blender-shaped workbench and parity showcase. |
| `components/` | A focused catalog of reusable controls, editors, templates, and tutorials. |
| `daw/` | A DAW host built on the `blender_ui_daw` extension package. |

Run an example from its directory:

```sh
cd examples/blenderui   # or components, or daw
flutter pub get
flutter run -d macos
```

The root package remains the library consumed by all three applications.
Application-specific models, fixtures, native runners, and composition belong
under the relevant example or extension package rather than in `lib/`.
