# File, Asset, and Video Sequencer editor regions

Date: 2026-07-20

## Source audit

The implementation was traced against Blender's local source rather than
inferred from screenshots alone:

- `space_file.cc`, `file_draw.cc`, and `space_filebrowser.py` register separate
  Header, Tools/source-list, UI/path, and Window regions. Asset Browser is a
  browse mode of the same editor, but has Catalog and Asset menus, import
  settings, a catalog tree, searchable previews, and asset-specific filters.
- `space_sequencer.cc`, `sequencer_channels_draw.cc`, and
  `space_sequencer.py` register Header, Tool Header, Footer, Channels, Window,
  Preview, Tools, and UI regions. Sequencer, Preview, and combined presentation
  are views of one editor rather than unrelated widgets.

## Decision

Browser and sequencer composition is represented by reusable regions with
host-owned immutable state:

- `BlenderFileBrowserHeaderState`, `BlenderFileBrowserHeader`, and
  `BlenderFileBrowserPathBar` separate editor menus/display/filter controls
  from directory navigation.
- `BlenderFileBrowserSourceList` models Bookmarks, System, Volumes, and other
  source sections without embedding platform paths in the library.
- `BlenderAssetBrowserCatalogRegion` reuses `BlenderAssetCatalog`; asset entries
  can declare catalog identity and previews, and catalog filtering happens in
  the browser rather than in example-only code.
- File list rows share the same flex columns as their sortable header, fixing
  the prior concatenated-metadata alignment approximation.
- `BlenderSequencerPreview` and `BlenderVideoSequencerWorkspace` compose the
  registered preview, tool-header, channels, window, and footer regions.
  `BlenderSequencerStripType` supplies source-shaped default colors, while
  handles and audio waveform hints stay in the retained strip painter.

The example owns filesystem fixtures, catalog choices, decoded preview
content, selected paths/strips, and command effects. It can switch File or
Asset Browser into animation-template main areas without bypassing the shared
editor surface.

## Performance

Directory and asset collections remain lazy `ListView.builder`/
`GridView.builder` surfaces. Sequencer strips, waveform hints, handles, and
grid are batched in one retained custom painter; live playback continues to
repaint only the isolated playhead layer. Preview content is independently
repaint-bounded so decoded frames do not invalidate the strip canvas.

## Experience retained

- An initial focused-test command guessed nonexistent filenames; `rg --files`
  identified the established parity test locations and the corrected focused
  suite passed.
- The installed Flutter wrapper attempted to update cache files outside the
  workspace during formatting and analysis. The commands were rerun with the
  approved SDK-cache permission rather than changing repository ownership.
- A later user-launched `flutter run --release` acquired Flutter's global
  startup lock while final golden rechecks were queued. Stale test processes
  created by the queue were stopped; the running application was left alone.
- The prior example test asserted the old generic right sidebar. It was
  updated to assert the source-shaped left source/catalog and path regions.
- Display and filter popovers were temporarily lost while removing obsolete
  browser chrome. Reintroducing them in the new header preserved the actual
  feature surface instead of weakening the test to accept missing behavior.
