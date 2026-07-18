part of '../component_catalog.dart';

const List<_CatalogComponent> _catalog = <_CatalogComponent>[
  _CatalogComponent(
    id: 'button',
    category: 'Inputs',
    label: 'Button',
    description:
        'Compact action control with Blender toolbar and tab variants.',
    glyph: BlenderGlyph.pointer,
    api: 'BlenderButton(label: "Apply", onPressed: applyChanges)',
    tutorial:
        'Use buttons for explicit user actions. Keep domain work in the callback.',
    compose:
        'Choose a label and a BlenderButtonVariant for the visual context.',
    state: 'Use selected and enabled to reflect caller-owned state.',
    callback:
        'Call a command, update a store, or open a dialog from onPressed.',
    keywords: 'action control click toolbar tab',
  ),
  _CatalogComponent(
    id: 'checkbox',
    category: 'Inputs',
    label: 'Checkbox & Toggle',
    description:
        'Boolean controls for persistent settings and immediate switches.',
    glyph: BlenderGlyph.check,
    api: 'BlenderCheckbox(value: enabled, onChanged: setEnabled)',
    tutorial:
        'Use a checkbox for a property and a toggle when the change is immediate.',
    compose: 'Provide the current boolean value and an optional label.',
    state: 'Keep the boolean in the feature or form state, not in the control.',
    callback: 'Persist the new value in onChanged and rebuild the caller.',
    keywords: 'boolean toggle switch selection',
  ),
  _CatalogComponent(
    id: 'slider',
    category: 'Inputs',
    label: 'Slider & Number Field',
    description:
        'Dense numeric input that supports direct editing and dragging.',
    glyph: BlenderGlyph.transform,
    api: 'BlenderSlider(value: amount, onChanged: updateAmount)',
    tutorial:
        'Pair a slider with a bounded number field when precision matters.',
    compose: 'Set value, min, max, and a step that matches the domain.',
    state: 'The caller owns the numeric value and validation policy.',
    callback: 'Clamp or persist the value in the onChanged callback.',
    keywords: 'number range drag precision input',
  ),
  _CatalogComponent(
    id: 'text-field',
    category: 'Inputs',
    label: 'Text Field',
    description:
        'Single-line dense editor for names, paths, and free-form values.',
    glyph: BlenderGlyph.text,
    api: 'BlenderTextField(controller: controller)',
    tutorial: 'Use a controller when the field is part of a longer-lived form.',
    compose:
        'Pass a TextEditingController or use the field as a small form row.',
    state: 'Dispose controllers in the owning State object.',
    callback: 'Read the committed text when the surrounding action executes.',
    keywords: 'text input field form edit',
  ),
  _CatalogComponent(
    id: 'dropdown',
    category: 'Inputs',
    label: 'Dropdown',
    description: 'Anchored choice menu for compact enum and mode selection.',
    glyph: BlenderGlyph.panelDisclosureDown,
    api: 'BlenderDropdown(value: mode, items: modes, onChanged: selectMode)',
    tutorial:
        'Use a dropdown when the available values are known and mutually exclusive.',
    compose: 'Map domain values to BlenderMenuItem descriptors.',
    state: 'Store the selected value in the caller and derive the label.',
    callback: 'Switch the active mode or update a property from onChanged.',
    keywords: 'select enum menu choice',
  ),
  _CatalogComponent(
    id: 'multi-column-menu',
    category: 'Inputs',
    label: 'Multi-column Dropdown',
    description:
        'Responsive Blender-style grouped dropdown that becomes vertical when space is tight.',
    glyph: BlenderGlyph.menu,
    api:
        'BlenderMultiColumnMenu<String>(groups: groups, selected: selected, onSelected: select)',
    tutorial:
        'Use grouped choices for editor types; the menu automatically becomes vertical when its available width is too narrow for all columns.',
    compose:
        'Group related choices and place the menu inside BlenderPopover for an anchored dropdown.',
    state: 'Store the selected domain value and pass it back as selected.',
    callback: 'Close the popover and update the active editor from onSelected.',
    keywords: 'multi column dropdown editor type grouped menu picker',
  ),
  _CatalogComponent(
    id: 'search-field',
    category: 'Inputs',
    label: 'Search Field',
    description:
        'Compact filter input for catalogs, outliners, and property lists.',
    glyph: BlenderGlyph.search,
    api: 'BlenderSearchField(controller: search, onChanged: filter)',
    tutorial:
        'Keep search local to the list it filters so the UI remains explainable.',
    compose: 'Give the field a controller and a useful placeholder.',
    state: 'Normalize the query before filtering caller-owned items.',
    callback: 'Rebuild the visible list from the query in onChanged.',
    keywords: 'find filter query catalog',
  ),
  _CatalogComponent(
    id: 'list-view',
    category: 'Data display',
    label: 'List View',
    description:
        'Dense selectable rows with icons, detail text, and activation.',
    glyph: BlenderGlyph.grid,
    api: 'BlenderListView(items: entries, selectedId: selected)',
    tutorial:
        'Use lists for flat collections where row density matters more than hierarchy.',
    compose: 'Describe each row with a BlenderListItem.',
    state: 'Keep selectedId and activation state in the parent model.',
    callback:
        'Use onSelected for focus and onActivated for double-click behavior.',
    keywords: 'rows collection selection list data',
  ),
  _CatalogComponent(
    id: 'tree',
    category: 'Data display',
    label: 'Tree',
    description:
        'Hierarchical rows with disclosure, selection, visibility, and lock affordances.',
    glyph: BlenderGlyph.outliner,
    api: 'BlenderTree(roots: nodes, selectedId: selected)',
    tutorial:
        'Use a tree when the relationship between items is part of the task.',
    compose: 'Build recursive BlenderTreeNode values with stable IDs.',
    state:
        'Own expansion and selection in the domain model or tree state service.',
    callback:
        'React to node selection without coupling the tree to your model.',
    keywords: 'hierarchy outliner disclosure collection',
  ),
  _CatalogComponent(
    id: 'properties-editor',
    category: 'Data display',
    label: 'Properties Editor',
    description:
        'Nested Blender-style property panels with header enable controls and bounded range fields.',
    glyph: BlenderGlyph.properties,
    api: 'BlenderPropertiesEditor(groups: propertyGroups)',
    tutorial:
        'Use child groups for Blender-style subsections such as Viewport, Render, Shadows, and Advanced.',
    compose:
        'Create groups with children, headerLeading checkboxes, and bounded BlenderNumberField editors.',
    state:
        'Keep expansion, enable flags, and range values in the caller-owned state.',
    callback:
        'Route header and property callbacks to state updates; disabled bodies stay visible but inert.',
    keywords:
        'property form groups inspector settings nested sections checkbox range',
  ),
  _CatalogComponent(
    id: 'notice',
    category: 'Feedback',
    label: 'Notice & Progress',
    description: 'Transient status messaging and compact progress feedback.',
    glyph: BlenderGlyph.info,
    api: 'BlenderNoticeBanner(message: message, level: level)',
    tutorial:
        'Use notices for user-visible status and progress for work with a measurable range.',
    compose: 'Choose the notice level that matches the severity.',
    state: 'Keep asynchronous job state outside the presentation widget.',
    callback: 'Update the banner or progress value as work reports status.',
    keywords: 'alert feedback status progress success warning',
  ),
  _CatalogComponent(
    id: 'tooltip',
    category: 'Feedback',
    label: 'Tooltip',
    description:
        'Delayed contextual help for dense controls and unfamiliar icons.',
    glyph: BlenderGlyph.info,
    api: 'BlenderTooltip(message: help, child: control)',
    tutorial:
        'Tooltips use Blender’s 500ms hover delay so pointer movement stays calm.',
    compose: 'Wrap the control with a concise message.',
    state: 'The tooltip owns only its delayed overlay lifecycle.',
    callback: 'Keep the actionable behavior on the wrapped child.',
    keywords: 'help hover hint delay',
  ),
  _CatalogComponent(
    id: 'popover',
    category: 'Feedback',
    label: 'Popover',
    description:
        'Anchored contextual surface for settings, menus, and compact inspectors.',
    glyph: BlenderGlyph.more,
    api: 'BlenderPopover(child: trigger, popover: buildPopover)',
    tutorial: 'Use a popover when the interaction belongs next to its trigger.',
    compose:
        'Return the surface from the popover builder and close it explicitly.',
    state: 'Keep open state and domain edits in the caller when they matter.',
    callback: 'Use the provided close callback after an action completes.',
    keywords: 'overlay anchored menu inspector contextual',
  ),
  _CatalogComponent(
    id: 'panel',
    category: 'Surfaces',
    label: 'Panel',
    description: 'Collapsible Blender surface for grouping related controls.',
    glyph: BlenderGlyph.panelDisclosureDown,
    api: 'BlenderPanel(title: "Transform", child: content)',
    tutorial:
        'Panels establish the visual and information hierarchy of dense pages.',
    compose: 'Give each panel one clear responsibility and a compact child.',
    state: 'Let the caller decide initial expansion and persist it if needed.',
    callback:
        'Place control callbacks in the child content, not in the panel shell.',
    keywords: 'surface group collapse section card',
  ),
  _CatalogComponent(
    id: 'tabs',
    category: 'Navigation & layout',
    label: 'Tabs',
    description:
        'Blender workspace-style navigation with selected and overflow states.',
    glyph: BlenderGlyph.grid,
    api: 'BlenderTabBar(tabs: labels, selectedIndex: index)',
    tutorial:
        'Use tabs when each destination is a sibling view of the same task.',
    compose: 'Provide ordered labels and the active index.',
    state: 'Persist the active index in the owning workspace or route.',
    callback:
        'Switch content from onChanged without coupling the tab row to it.',
    keywords: 'workspace navigation selected overflow',
  ),
  _CatalogComponent(
    id: 'breadcrumbs',
    category: 'Navigation & layout',
    label: 'Breadcrumbs',
    description: 'Compact path navigation for nested data and editor context.',
    glyph: BlenderGlyph.chevronRight,
    api: 'BlenderBreadcrumbs(items: path, onSelected: navigate)',
    tutorial:
        'Use breadcrumbs to make the current nesting and escape route visible.',
    compose: 'Pass the current path in display order.',
    state: 'Derive the path from the active document or selection.',
    callback: 'Navigate to the selected ancestor in onSelected.',
    keywords: 'path navigation hierarchy location',
  ),
  _CatalogComponent(
    id: 'splitter',
    category: 'Navigation & layout',
    label: 'Splitter',
    description:
        'Resizable two-region layout primitive for desktop workspaces.',
    glyph: BlenderGlyph.split,
    api: 'BlenderSplitter(first: main, second: inspector)',
    tutorial:
        'Use a splitter when both regions are first-class and need independent space.',
    compose: 'Provide two region widgets and an initial fraction.',
    state:
        'Persist the fraction in the workspace layout when the split is durable.',
    callback:
        'Listen to onFractionChanged to save or coordinate adjacent regions.',
    keywords: 'resize divider pane docking layout',
  ),
  _CatalogComponent(
    id: 'toolbar',
    category: 'Navigation & layout',
    label: 'Toolbar',
    description:
        'Scrollable dense row for editor actions and workspace chrome.',
    glyph: BlenderGlyph.menu,
    api: 'BlenderToolbar(children: actions, background: color)',
    tutorial:
        'Use a toolbar to group immediate editor actions without adding panel weight.',
    compose:
        'Order controls from global to local and supply tooltips for icons.',
    state: 'Let each action read the active editor or workspace state.',
    callback: 'Connect buttons to commands or local state transitions.',
    keywords: 'header actions editor chrome row',
  ),
  _CatalogComponent(
    id: 'timeline',
    category: 'Editors',
    label: 'Timeline',
    description:
        'Compact frame range and keyframe surface for animation workflows.',
    glyph: BlenderGlyph.timeline,
    api: 'BlenderTimeline(model: timeline, onCurrentFrameChanged: seek)',
    tutorial:
        'Use a timeline model to keep frame semantics separate from painting.',
    compose: 'Describe tracks and keyframes with BlenderTimelineModel.',
    state: 'Own currentFrame and playback state in the application.',
    callback: 'Seek or update the active frame from onCurrentFrameChanged.',
    keywords: 'animation frames keyframes playback editor',
  ),
  _CatalogComponent(
    id: 'node-editor',
    category: 'Editors',
    label: 'Node Editor',
    description:
        'Pan-and-zoom graph surface with typed input and output sockets.',
    glyph: BlenderGlyph.node,
    api: 'BlenderNodeEditor(model: BlenderNodeGraphModel)',
    tutorial:
        'Use a graph model so node identity and links remain application-owned.',
    compose: 'Define node positions, sockets, and links in the model.',
    state: 'Persist positions and selection in your graph document.',
    callback: 'Use node selection and movement callbacks to mutate the graph.',
    keywords: 'nodes graph links sockets editor',
  ),
  _CatalogComponent(
    id: 'file-browser',
    category: 'Editors',
    label: 'File Browser',
    description:
        'Dense path, search, list, and selection surface for files and assets.',
    glyph: BlenderGlyph.folder,
    api: 'BlenderFileBrowser(entries: files, selectedPath: path)',
    tutorial:
        'Use the file browser as a presentation layer over your storage adapter.',
    compose: 'Describe entries with stable paths and optional details.',
    state: 'Keep filesystem permissions and persistence outside the widget.',
    callback: 'Open or select entries through the supplied callbacks.',
    keywords: 'files folders assets path browser search',
  ),
  _CatalogComponent(
    id: 'spreadsheet',
    category: 'Editors',
    label: 'Spreadsheet Editor',
    description:
        'Scrollable columnar data surface for inspecting generated values.',
    glyph: BlenderGlyph.spreadsheet,
    api: 'BlenderSpreadsheetEditor(columns: columns, rows: rows)',
    tutorial:
        'Use a spreadsheet for inspection and filtering, not as your source of truth.',
    compose: 'Map data fields to columns and stable row IDs.',
    state: 'Generate rows from the active object or computation.',
    callback: 'Coordinate filters and selection from the containing editor.',
    keywords: 'table rows columns data inspect editor',
  ),
  _CatalogComponent(
    id: 'history-store',
    category: 'App services',
    label: 'History Store',
    description:
        'Scoped immutable state with undo and redo for editor workflows.',
    glyph: BlenderGlyph.undo,
    api: 'BlenderHistoryStore<AppState>(initialState)',
    tutorial:
        'Use a history store when edits should be reversible without global state.',
    compose: 'Create the store at the application or workspace boundary.',
    state: 'Expose the current value through BlenderStateScope.',
    callback: 'Call update, undo, and redo from normal UI actions.',
    keywords: 'state undo redo immutable store',
  ),
  _CatalogComponent(
    id: 'command-registry',
    category: 'App services',
    label: 'Command Registry',
    description:
        'Shared command descriptors for menus, shortcuts, and buttons.',
    glyph: BlenderGlyph.modifier,
    api: 'BlenderCommandRegistry()..register(command)',
    tutorial:
        'Use commands to keep execution semantics shared across multiple surfaces.',
    compose:
        'Register a label, shortcut, enabled predicate, and execute callback.',
    state:
        'Let commands read scoped services rather than process-wide singletons.',
    callback: 'Invoke the same command from buttons, menus, and keymaps.',
    keywords: 'commands menu shortcuts registry actions',
  ),
];
