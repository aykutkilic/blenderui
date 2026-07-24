# Workbook authoring cells and stable editor presentation

## Context

The workbook used a different presentation for a selected code cell and an
unselected code cell. Losing focus therefore replaced the native/fallback
editor with a read-only text surface whose metrics, padding, and font differed.
That made source visibly jump even though the document had not changed.

The document model also distinguished only code and Markdown and did not offer
a Markdown renderer or an authoring surface for the reusable Flutter port of
the local `/Users/aykutkilic/git/ploted` behavior. Authors need prose, formulas,
and variable-driven plots without weakening the offline-first lifecycle.

## Decision

Treat Code, Markdown, and Plot as first-class authoring cell kinds owned by the
reusable `blender_ui_workbook` extension.

### Stable code cells

A code cell always retains the same `WorkbookCodeEditor` subtree and stable key.
Selection changes only focus and border state. One source-line-derived height
and one text style are applied in both states. This preserves CodeForge state,
scroll position, geometry, and typography instead of attempting to recreate an
editor from a display-only widget.

### Markdown and formula cells

Markdown cells store plain source in `WorkbookCell.source`. The selected state
shows a source editor and live preview; the unselected state shows the same
rendered document. Rendering uses GitHub-flavored Markdown plus inline `$...$`
and block `$$...$$` LaTeX. It is entirely local and never checks for a kernel.

`flutter_markdown_plus` is used rather than the original
`flutter_markdown`: dependency resolution identified the latter as
discontinued. `flutter_markdown_plus_latex` supplies syntax and builders backed
by Flutter-native math layout. The package boundary remains in the native
workbook extension rather than the web-compatible BlenderUI core.

### Variable-backed plot cells

A plot cell stores `WorkbookPlotCellConfiguration` alongside the cell. The
configuration contains its title, a renderer supported by the existing
`ploted`-derived Flutter surface, an optional X variable, and one or more Y
variables. These authoring changes use the host's `BlenderHistoryStore` just as
source changes do.

The variable picker discovers simple assignment targets from code source. This
is intentionally static: it works offline, does not execute user code, and
does not make a Jupyter namespace query part of layout. When the user runs the
plot, the configuration produces Python that resolves the selected names in the
already-active kernel and emits `application/vnd.blenderui.plot+json` through
the existing helper. An incomplete configuration becomes a typed cell error
without invoking the kernel.

Notebook decoding recognizes an optional `metadata.blenderui.plot` object so
hosts that persist this metadata can restore the authoring configuration. The
metadata is additive and ordinary Jupyter readers can continue treating the
cell as code.

## Consequences

- Selection no longer changes code editor size, font, or widget identity.
- Markdown prose, tables, and formulas are available while fully offline.
- Plot selection and editing are available offline; only plot execution needs
  a connected kernel and previously evaluated variables.
- Static assignment discovery may list a name that has not yet been evaluated
  or omit dynamically-created names. Runtime namespace inspection can be added
  later behind a kernel capability without changing the document model.
- Complex plot specifications such as Sankey graphs or 3D triples remain
  available through Python helpers; the variable picker intentionally exposes
  the series-oriented renderer subset that maps cleanly to X/Y variables.

## Verification and experience

- A widget regression test records a code editor's size and text style, changes
  selection, and verifies that both and the widget identity remain stable.
- Focused widget coverage renders a GitHub-flavored table with inline and block
  LaTeX without initializing a kernel.
- Controller tests cover offline variable discovery, history-backed plot
  configuration, generated kernel source, and invalid configurations.
- Notebook codec coverage restores the additive BlenderUI plot metadata.
- The first dependency pass used `flutter_markdown`; `flutter pub get` warned
  that it was discontinued. It was removed immediately in favor of the
  maintained successor rather than accepting a new obsolete dependency.
- The first full-host widget run found that wrapping the preview in Flutter's
  `SelectionArea` implicitly requires `MaterialLocalizations`. The workbook is
  hosted by `BlenderApp`, so the wrapper was removed instead of adding a
  Material-shell dependency to the application architecture.
