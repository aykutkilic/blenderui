# Math and AI Workbook example

This native example opens as an offline workbook first. Reading and editing
`.ipynb`, `.py`, and `.txt` files does not require Python, Jupyter, a network
connection, or a language server. Code execution is an optional runtime
capability configured from **Edit > Preferences**.

The host uses BlenderUI's application stack directly. Workbook, Scripting, and
Inspect are persistent docking workspaces; every area can switch among the
Workbook, Document Outline, Python Runtime, and Info/Reports editors. Source
editing uses shared application undo/redo, while runtime output stays outside
document history.

The document toolbar adds Code, Markdown, and Plot cells. Markdown supports
GitHub-flavored tables and inline or block LaTeX without connecting a runtime.
Plot cells expose the local `ploted`-based renderers, discover assignment names
from code cells, and let the author select an optional X variable plus one or
more Y series. Running a Plot cell resolves those names in the active Python
kernel and produces the same native interactive MIME output as `xy(...)`.
Changing focus never replaces a code editor with a differently styled preview,
so its font and measured height remain stable.

## Run

```bash
flutter run -d macos
```

The default persisted runtime mode is **Offline** and auto-connect is off. The
status bar reports runtime failures without replacing the workbook.

## Runtime Preferences

The Runtime category supports four explicit modes:

- **Offline** — read and edit documents without starting any service.
- **Managed local Jupyter** — create an isolated virtual environment inside
  the platform application-support directory, install Jupyter, ipykernel,
  WebSockets, and basedpyright, then connect it.
- **Custom local Python** — inspect the chosen Python for Jupyter and start a
  local authenticated server only when Connect is requested.
- **Remote Jupyter Server** — connect to a supplied server URL and in-memory
  token without owning a Python process.

**Install Jupyter and Connect** is deliberately explicit because package
installation downloads software and can take time. Runtime choices and
auto-connect are persisted in application support storage. Access tokens are
not persisted. The managed environment and writable cell shadows also live in
application support storage; the app never assumes a repository-relative
`.venv` or a particular launch directory.

On macOS, installation avoids venv's sandbox-sensitive nested `ensurepip`
step. It creates the app-owned environment with `--without-pip`, bootstraps pip
into that interpreter from the selected base Python, installs a small managed
startup compatibility module that avoids sandbox-forbidden system MIME probes,
and then installs the managed package set. Retrying also repairs an older
partial environment that has Python but no pip. Jupyter Server starts through
its module entry point rather than the PATH-scanning command dispatcher.

## Application Preferences and keybindings

Preferences contains Runtime, Interface, Themes, and Keymap categories. The
workspace dock trees, selected workspace, editor type per area, selected
document context, interface preferences, themes, and keymap are stored under
application support. Built-in keybindings include Cmd+O, Cmd+,, Cmd+Z,
Cmd+Shift+Z, Cmd+Shift+Enter, and Escape, and can be edited through the shared
BlenderUI keymap editor.

The macOS example retains App Sandbox. Offline and Remote modes are supported;
Managed Local and Custom Python fail fast with an actionable diagnostic because
system/downloaded Python extension modules are not valid nested executable code
for this sandboxed host. Local execution requires an explicitly non-sandboxed
host policy or a complete Python distribution bundled and signed as nested app
code.

Environment overrides remain useful for automation:

```bash
JUPYTER_SERVER_URL=http://127.0.0.1:8899 \
JUPYTER_TOKEN=blenderui-workbook-dev \
flutter run -d macos
```

`WORKBOOK_PYTHON` chooses a custom local Python. AI inline completion remains
opt-in through `WORKBOOK_AI_PROVIDER`, `WORKBOOK_AI_MODEL`,
`WORKBOOK_AI_BASE_URL`, and `WORKBOOK_AI_API_KEY`.

`WORKBOOK_AUTOINSTALL_MANAGED=1` is an opt-in native smoke-test hook that runs
the same Preferences install-and-connect command after application-support
setup. It is never enabled during normal startup.

The app copies the package's `blenderui_workbook.py` helper into its persistent
workspace. `xy(...)` emits `application/vnd.blenderui.plot+json`, which the
workbook presents as a native interactive plot rather than a browser view.

If CodeForge's native Rust framework cannot load, the workbook reports the
failure to the debug log and uses its plain editable fallback. Editor
acceleration, like Jupyter, is not allowed to prevent the application shell
from opening.
