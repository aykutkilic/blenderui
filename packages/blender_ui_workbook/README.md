# BlenderUI Workbook

`blender_ui_workbook` is the reusable native-desktop extension behind math,
data, and AI notebook applications. It keeps CodeForge's Rust dependency out of
the web-compatible `blender_ui` core while providing:

- persistent Jupyter Server kernels over REST and WebSocket channels;
- typed stream, result, error, image, HTML, Markdown, and custom MIME outputs;
- the complete CodeForge configuration/controller surface, stdio or WebSocket
  LSP, and provider-neutral inline AI completion;
- interactive Flutter plots ported from the local `ploted` prototype.
- offline document sessions and `.ipynb` decoding that do not require a kernel;
- first-class Code, GitHub-flavored Markdown with LaTeX, and variable-backed
  Plot cells;
- application-history-aware source editing plus a reusable synchronized
  document Outline;
- an app-support-oriented, repairable managed Jupyter installer with observable
  progress.

## Minimal composition

Initialize CodeForge once before Flutter creates the editor:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeWorkbookEditor();
  runApp(const MyWorkbookApp());
}
```

Initialization is best-effort. If the native framework is unavailable,
`WorkbookCodeEditor` uses a plain editable fallback so the host can still open
and edit documents.

Create an offline session immediately, then attach a kernel only when the user
asks to connect:

```dart
final kernel = JupyterKernel(
  serverUri: Uri.parse('http://127.0.0.1:8899'),
  token: token,
);
final session = WorkbookSessionController(document: document);
await session.attachKernel(kernel);

WorkbookView(
  controller: session,
  lspConfig: pythonLsp,
  aiCompletionProvider: completionProvider,
);
```

The host owns credentials, process policy, application-support paths, and
document persistence. The extension owns reusable editor, kernel, runtime
installer, notebook decoding, output, and plot behavior. `runCell` provides a
friendly unavailable result while offline; reading, editing, and document
replacement continue normally.

Code cells retain the same editor widget, geometry, and text style when
selection changes. Markdown cells edit source and render GitHub-flavored
Markdown plus inline or block LaTeX locally. Plot cells retain a document-level
configuration for plot type, title, X variable, and one or more Y variables;
their variable picker derives candidates from code-cell assignments while
offline and executes through the same rich-plot helper when a kernel is
connected.

## Python rich plots

Install `python/requirements.txt` and put `python/blenderui_workbook.py` on the
kernel's import path. `xy`, `xyz`, `sankey`, or the general `plot` helper emits
`application/vnd.blenderui.plot+json`.

Supported renderers are oscilloscope, line, scatter, stacked area, bar,
histogram, waveform, candlestick, Sankey, Gantt, software-projected 3D, and XY
map. Shared manipulation includes wheel zoom, drag panning, Y-axis dragging,
legend visibility, keyboard pan/zoom, draggable vertical/band cursors,
double-click cursor creation, direct Sankey-node dragging, 3D camera rotation,
a secondary-click cursor menu, and reset.

## Managed and remote runtimes

`JupyterRuntimeInstaller` creates a virtual environment in the directory chosen
by the host and installs the runtime only after an explicit user action. It
uses `venv --without-pip` followed by the base interpreter's
`pip --python <managed-python>` so a macOS sandbox does not depend on venv's
nested ensurepip process. It also installs an app-owned Python startup shim to
avoid sandbox-forbidden system MIME probes; retrying repairs a partial
environment without pip. Hosts
should place it in platform application-support storage, expose progress and
errors in Preferences, and leave auto-connect off by default. Remote and
companion runtimes remain supported through `JupyterKernel` and
`python/lsp_ws_proxy.py`. See the
[workbook example](../../examples/workbook/README.md) for the complete host
policy.

On macOS, invoking a system/downloaded Python and its compiled extension
modules is a non-sandboxed host capability. An App Sandbox product should use a
remote companion or ship Python as signed nested app code.

## Verification

```bash
flutter analyze
flutter test
```

Set `WORKBOOK_LIVE_JUPYTER` to a Jupyter-capable Python and
`WORKBOOK_LIVE_LSP_URL` to the companion URL to include the real transport
tests. Set `WORKBOOK_INSTALL_BASE_PYTHON` to exercise creation and installation
of a complete temporary managed environment. Ordinary CI keeps those tests
explicitly skipped when the runtimes are not present.
