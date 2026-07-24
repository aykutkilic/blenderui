# Math and AI workbook extension architecture

## Context

BlenderUI needs a dedicated math and AI workbook application. Python code must
execute in a persistent Jupyter kernel, rich outputs must remain typed, editing
must retain CodeForge's complete native editing surface, AI inline completion
must be replaceable, and engineering plots must be interactive Flutter widgets
based on the behavior of the local `ploted` prototype.

The root package still supports web applications. CodeForge 10.8.0 uses a Rust
FFI backend and explicitly does not support Flutter web. Putting it in the root
package would therefore make an unrelated native editor dependency part of
every BlenderUI application.

## Decision

Add `packages/blender_ui_workbook` as a reusable, desktop-oriented extension and
`examples/workbook` as its thin application host.

The extension is split into stable boundaries:

```text
workbook document and output models
        ↓
kernel contract ← Jupyter Server REST + WebSocket channels adapter
        ↓
workbook session controller
        ↓
CodeForge editor adapter + typed output presenters + Flutter plot editor
        ↓
examples/workbook application composition
```

### Kernel boundary

`WorkbookKernel` is transport-neutral and exposes lifecycle state, execution,
interrupt, and restart. `JupyterKernel` implements the normal Jupyter Server
API instead of inventing a second Python execution protocol. Message routing is
keyed by Jupyter `parent_header.msg_id`, allowing multiple cell executions to
remain deterministic even when IOPub traffic is interleaved.

The application may connect to an existing authenticated server or own a local
`JupyterServerProcess`. Process startup uses `python -m jupyter_server`, a
generated token, and a selected workspace directory. The token is never stored
in a workbook document.

The session owns the document independently of the kernel. It is constructed
offline, may replace its document while disconnected, and can attach or detach
a `WorkbookKernel` later. Runtime loss therefore disables execution controls
but never destroys the shell, document, or file workflow.

### Offline-first host boundary

The example constructs its application controller, document session, and
workbook view synchronously. Jupyter discovery and connection are lazy
capabilities. Failure is reported in the status service and Runtime
Preferences; it cannot replace the application with a startup-error screen.

Runtime mode, auto-connect, Python path, and server URL are application
preferences. Offline is the default and auto-connect is false. Access tokens
remain memory-only. For a managed runtime, `JupyterRuntimeInstaller` creates an
isolated virtual environment under the platform application-support directory
and installs Jupyter only after the user selects **Install Jupyter and
Connect**. Repository-relative `.venv` discovery and current-working-directory
coupling are prohibited.

The macOS sandbox cannot reliably complete `python -m venv`'s nested
`ensurepip` subprocess. Managed installation therefore creates the environment
with `--without-pip`, then asks the base interpreter's pip to target the
managed interpreter with `pip --python`. A managed `sitecustomize.py` prevents
Python's MIME discovery from probing sandbox-forbidden Apache configuration
paths. The same path repairs a partially-created environment whose interpreter
exists but whose pip does not. Direct `jupyter_server` module startup avoids
the Jupyter command dispatcher's PATH scan.

Those mitigations allow package installation to finish, but do not make an
external Python distribution a valid nested executable for an App Sandbox
host. Native verification stalled when Jupyter imported compiled extension
modules through `dlopen`; the inherited sandbox blocked dyld validation. The
example retains App Sandbox and fails fast for local managed/custom modes until
the host policy is explicitly changed. It remains fully usable offline or with
a remote service. Local execution requires either an explicitly non-sandboxed
host or a complete Python distribution shipped as properly signed nested app
code.

File opening is also independent. The native picker accepts `.ipynb`, `.py`,
and `.txt`; `JupyterNotebookCodec` reads notebook source and common typed
outputs without a server. macOS grants only user-selected read access.

### Application-shell boundary

The example is composition over BlenderUI's application layer, not a bespoke
workbook scaffold. `BlenderApplicationController` scopes history, commands,
keybindings, workspaces, editor sessions, status, reports, jobs, interface
preferences, themes, Preferences, and presentation services. Workbook source
edits participate in the application history; kernel state and execution
outputs remain transient.

Workbook, Scripting, and Inspect are persisted
`BlenderWorkspaceDefinition<String>` dock trees hosted by
`BlenderWorkspaceShell`. Each dock area uses
`BlenderEditorAreaController<WorkbookEditorView>` and can switch among the
Workbook, Document Outline, Python Runtime, and Info/Reports views. The view
enum and data remain host-owned; the dock tree, workspace lifecycle, editor
session, area header, and persistence mechanics remain reusable BlenderUI.

Application-support storage persists workspace layouts, editor-area choices,
selected Outliner/Properties context, interface preferences, themes, and the
live keymap. Preferences exposes Runtime, Interface, Themes, and Keymap using
the same service instances scoped to the shell.

### Output boundary

Kernel messages become immutable `WorkbookOutput` values. Stream text, errors,
execution results, display data, and status remain distinct. MIME bundles are
preserved so future presenters can be added without changing the kernel.

Interactive plots use `application/vnd.blenderui.plot+json`. A small Python
helper emits that MIME type from a notebook. Static `image/png` output remains
supported for ordinary matplotlib usage.

### Editing boundary

`WorkbookCodeEditor` composes CodeForge rather than copying its editor. It
enables folding, gutters, indentation guides, suggestions, keyboard
suggestions, search/replace, undo/redo, multi-cursor editing, and the complete
controller API. Every CodeForge layout, scrolling, styling, finder, snippet,
keyboard, selection, and suggestion option remains forwardable. Callers retain
access to the CodeForge controllers and can provide either stdio or WebSocket
`LspConfig` with all LSP client capabilities.

Hosts may use the loopback-only Python companion shipped with the extension.
It validates WebSocket JSON, translates to Content-Length framed stdio, and
owns one language-server process per client. For a sandboxed UI it must run as
an external companion rather than as an inherited child process.

AI completion is an application service. The editor adapter translates
provider responses into CodeForge ghost text; credentials and model selection
stay out of the widget and document model.

CodeForge acceleration is best-effort. Initialization failures are recorded,
not thrown through application startup. `WorkbookCodeEditor` falls back to a
plain editable Flutter surface with the same document and file-persistence
callbacks, preserving the offline contract when the native framework is
missing.

### Plot boundary

The Flutter port keeps `ploted` concepts—series, independent axes, view ranges,
vertical/band cursors, visibility, pan, zoom, axis manipulation, legend state,
and multiple renderers—but uses immutable Dart models, a controller, gestures,
and `CustomPainter`. The React component and browser canvas are not embedded.
This makes plot state serializable in notebook MIME output and lets hosts
persist user manipulation separately from source data.

The port has distinct oscilloscope, line, scatter, stacked-area, bar,
histogram, waveform-envelope, OHLC candlestick, Sankey, Gantt, software 3D, and
XY-map render paths. Complex renderer kinds never silently fall back to a line.

## Consequences

- Core BlenderUI remains usable on web and does not inherit Rust build tooling.
- Workbook applications are native desktop applications and initialize
  CodeForge's Rust library before creating widgets when available; a plain
  editable fallback preserves startup when it is unavailable.
- A Jupyter installation and a Python LSP server are runtime capabilities with
  explicit diagnostics, not hidden package assumptions.
- Opening, reading, and editing never mandate a Jupyter connection. Installing
  packages or auto-connecting requires an explicit persisted user choice.
- This sandboxed example supports Offline and Remote modes. Managed/custom
  local execution is rejected with an actionable diagnostic until the host is
  explicitly unsandboxed or gains a separately shipped and signed runtime.
- The example exercises BlenderUI's workspace, docking, history, command,
  keymap, editor-session, feedback, interface-preference, and theme services
  instead of maintaining parallel app-local substitutes.
- AI providers can be local or remote and are testable without network calls.
- New plot renderers can share axes, navigation, cursors, and selection rather
  than duplicating interaction state.

## Source and tool notes

- CodeForge 10.8.0 documentation was inspected on 2026-07-22. Its documented
  feature set includes LSP completion, diagnostics, semantic tokens, hover,
  signatures, actions, inlay hints, highlights, colors, definition, rename,
  folding, search/replace, multi-cursor editing, and ghost-text AI completion.
- The local `/Users/aykutkilic/git/ploted` React source was used as the behavior
  reference. It currently contains oscilloscope, stacked area, bar, histogram,
  waveform, candlestick, Sankey, Gantt, 3D, and XY-map renderers plus cursor,
  axis, panning, zooming, legend, and context-menu interactions.
- The installed `/opt/homebrew/bin/jupyter` launcher currently has a stale
  Python 3.9 shebang, and no `basedpyright-langserver` was found on `PATH`.
  These are environment setup failures to report in-app; neither changes the
  reusable architecture.
- Flutter 3.45 initially selected CodeForge's SwiftPM target and produced a
  bundle containing only `code_forge.o`; `RustLib.init()` then failed because
  `code_forge.framework/code_forge` was absent. The workbook host disables
  SwiftPM project-locally so CodeForge 10.8 uses its CocoaPods Rust build phase.
- The CocoaPods build then exposed CodeForge's transitive Rust requirement for
  edition 2024. Rust 1.83 failed before compilation; the verified host toolchain
  is stable Rust 1.97.1.
- A real native render exposed a Material/Blender theme boundary: notebook
  cards were light and CodeForge identifiers inherited black. A centralized
  workbook palette now maps all editor, output, plot, and overlay colors from
  `BlenderTheme`, and the rendered app was recaptured after the correction.
- The first direct WebSocket LSP test stalled because basedpyright requested
  `workspace/configuration` before answering completion. CodeForge normally
  handles this server request; the transport test now mirrors that response and
  verifies a real `math.sin` completion plus all enabled client capabilities.
- macOS denied assistive-access automation for clicking the native Run button.
  Verification uses an explicit `WORKBOOK_AUTORUN_FIRST_CELL=1` smoke option;
  normal startup remains idle and never executes workbook code implicitly.
- The first in-container managed installation left a valid Python interpreter
  without pip because venv's nested `ensurepip --upgrade --default-pip`
  process exited with code 1. The first replacement reached pip but then MIME
  discovery attempted `/etc/apache2/mime.types`, which App Sandbox denied. A
  fresh live installation and signed-app retry verified the two-stage
  `--without-pip`, base-pip targeting, and managed-startup compatibility path;
  the opt-in
  `WORKBOOK_AUTOINSTALL_MANAGED=1` launch hook exercises the same repair path
  in the signed native app without changing normal startup.
- Importing `ipykernel` as an availability probe left inherited output handles
  open, so inspection now reads its installed distribution metadata. Native
  connection also exposed the Jupyter PATH command dispatcher's sandbox scan;
  server startup now invokes the `jupyter_server` module directly.
- The first host implementation looked only for `.venv` under
  `Directory.current` and otherwise launched the system Python. A real launch
  from another directory selected `/Library/Frameworks/Python.framework/...`
  and replaced the entire UI with “No module named jupyter.” That failure
  established the offline-first lifecycle and app-support runtime decision.
- Signed-app verification then showed Jupyter stuck in dyld validation while
  importing a compiled Python extension: an app-downloaded/system Python is not
  valid nested executable code for App Sandbox. Removing the sandbox was not
  authorized, so the example retains it and fails fast for local modes rather
  than downloading packages and hanging. Remote authenticated servers remain
  available; a future local mode needs an explicit sandbox-policy decision or a
  bundled, signed Python runtime.
- Flutter widget tests do not contain CodeForge's macOS framework. The first
  offline shell test therefore exposed another hidden startup dependency.
  Converting native editor initialization to best-effort fallback made the test
  pass and made production startup resilient to the same packaging failure.
- Docking the workbook beside its Outline exposed a toolbar overflow below 700
  pixels, so toolbar actions now collapse to icons at narrow area widths. The
  first shared-selection implementation also notified the editor-session
  during build; initializing selection in the session controller removed that
  frame-time mutation while keeping all docked views synchronized.
- A live installer test created a fresh temporary environment from the same
  system Python shown in the original failure, installed the complete managed
  package set, inspected it, and removed it afterward. A separate live kernel
  test started Jupyter, executed Python, and received the custom rich-plot MIME
  output.
