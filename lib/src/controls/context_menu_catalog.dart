part of '../controls.dart';

/// Stable command identifiers used by Blender's common context-menu families.
abstract final class BlenderContextActionIds {
  static const copy = 'copy';
  static const paste = 'paste';
  static const cut = 'cut';
  static const duplicate = 'duplicate';
  static const delete = 'delete';
  static const deleteHierarchy = 'delete-hierarchy';
  static const rename = 'rename';
  static const select = 'select';
  static const selectHierarchy = 'select-hierarchy';
  static const deselect = 'deselect';
  static const unlink = 'unlink';
  static const newCollection = 'new-collection';
  static const markAsset = 'mark-asset';
  static const clearAsset = 'clear-asset';
  static const join = 'join';
  static const shadeAutoSmooth = 'shade-auto-smooth';
  static const shadeSmooth = 'shade-smooth';
  static const shadeFlat = 'shade-flat';
  static const setOrigin = 'set-origin';
  static const parent = 'parent';
  static const moveToCollection = 'move-to-collection';
  static const add = 'add';
  static const find = 'find';
  static const frameSelected = 'frame-selected';
  static const makeGroup = 'make-group';
  static const insertIntoGroup = 'insert-into-group';
  static const joinFrame = 'join-frame';
  static const removeFromFrame = 'remove-from-frame';
  static const back = 'back';
  static const forward = 'forward';
  static const parentDirectory = 'parent-directory';
  static const refresh = 'refresh';
  static const newFolder = 'new-folder';
  static const addBookmark = 'add-bookmark';
  static const display = 'display';
  static const sort = 'sort';
  static const resetDefault = 'reset-default';
  static const copyDataPath = 'copy-data-path';
  static const copyToSelected = 'copy-to-selected';
  static const insertKeyframe = 'insert-keyframe';
  static const deleteKeyframe = 'delete-keyframe';
  static const addFavorite = 'add-favorite';
  static const assignShortcut = 'assign-shortcut';
  static const onlineManual = 'online-manual';
  static const toolSettings = 'tool-settings';
  static const area = 'area';
  static const view = 'view';
  static const libraryOverride = 'library-override';
}

/// Source-shaped menu catalogs with caller-owned command execution.
///
/// These methods intentionally expose ordinary [BlenderMenuItem] descriptors:
/// applications may append domain actions without inheriting a command system.
abstract final class BlenderContextMenuCatalog {
  static BlenderMenuItem<String> _item(
    String value,
    String label, {
    BlenderGlyph? glyph,
    String? shortcut,
    String? description,
    bool enabled = true,
    List<BlenderMenuItem<String>>? submenu,
  }) => BlenderMenuItem<String>(
    value: value,
    label: label,
    icon: glyph == null ? null : BlenderIcon(glyph, size: 16),
    shortcut: shortcut,
    description: description,
    enabled: enabled,
    submenu: submenu,
  );

  static const BlenderMenuItem<String> _separator = BlenderMenuItem<String>(
    value: '',
    label: '',
    separator: true,
  );

  static List<BlenderMenuItem<String>> object({
    int selectedCount = 1,
    bool canPaste = true,
    bool isMesh = true,
  }) => <BlenderMenuItem<String>>[
    _item(
      BlenderContextActionIds.copy,
      'Copy',
      glyph: BlenderGlyph.duplicate,
      shortcut: '⌘ C',
      description: 'Copy selected objects to the clipboard.',
    ),
    _item(
      BlenderContextActionIds.paste,
      'Paste',
      glyph: BlenderGlyph.duplicate,
      shortcut: '⌘ V',
      enabled: canPaste,
      description: 'Paste objects from the clipboard.',
    ),
    _separator,
    _item(
      BlenderContextActionIds.duplicate,
      'Duplicate Objects',
      glyph: BlenderGlyph.duplicate,
      shortcut: '⇧ D',
    ),
    _item(
      BlenderContextActionIds.delete,
      'Delete',
      glyph: BlenderGlyph.deleteIcon,
      shortcut: 'X',
      description: 'Delete selected objects.',
    ),
    if (isMesh) ...<BlenderMenuItem<String>>[
      _separator,
      _item(BlenderContextActionIds.shadeAutoSmooth, 'Shade Auto Smooth'),
      _item(BlenderContextActionIds.shadeSmooth, 'Shade Smooth by Angle'),
      _item(BlenderContextActionIds.shadeFlat, 'Shade Flat'),
    ],
    _separator,
    _item(
      BlenderContextActionIds.join,
      'Join',
      shortcut: '⌘ J',
      enabled: selectedCount > 1,
    ),
    _item(
      BlenderContextActionIds.setOrigin,
      'Set Origin',
      submenu: <BlenderMenuItem<String>>[
        _item('origin-geometry', 'Geometry to Origin'),
        _item('origin-cursor', 'Origin to 3D Cursor'),
        _item('origin-center', 'Origin to Center of Mass'),
      ],
    ),
    _item(
      BlenderContextActionIds.parent,
      'Parent',
      submenu: <BlenderMenuItem<String>>[
        _item('parent-object', 'Object'),
        _item('parent-clear', 'Clear Parent'),
      ],
    ),
    _item(BlenderContextActionIds.moveToCollection, 'Move to Collection'),
  ];

  static List<BlenderMenuItem<String>> outliner({
    bool isAsset = false,
    bool canPaste = true,
  }) => <BlenderMenuItem<String>>[
    _item(
      BlenderContextActionIds.copy,
      'Copy',
      glyph: BlenderGlyph.duplicate,
      shortcut: '⌘ C',
    ),
    _item(
      BlenderContextActionIds.paste,
      'Paste',
      glyph: BlenderGlyph.duplicate,
      shortcut: '⌘ V',
      enabled: canPaste,
    ),
    _separator,
    _item(
      BlenderContextActionIds.delete,
      'Delete',
      glyph: BlenderGlyph.deleteIcon,
      shortcut: 'X',
    ),
    _item(
      BlenderContextActionIds.deleteHierarchy,
      'Delete Hierarchy',
      description: 'Delete selected objects and collections.',
    ),
    _separator,
    _item(BlenderContextActionIds.select, 'Select'),
    _item(BlenderContextActionIds.selectHierarchy, 'Select Hierarchy'),
    _item(BlenderContextActionIds.deselect, 'Deselect'),
    _separator,
    _item(BlenderContextActionIds.unlink, 'Unlink'),
    _separator,
    _item(BlenderContextActionIds.newCollection, 'New Collection'),
    _item(
      'id-data',
      'ID Data',
      submenu: <BlenderMenuItem<String>>[
        _item('id-remap', 'Remap Users'),
        _item('id-make-local', 'Make Local'),
      ],
    ),
    _separator,
    _item(
      BlenderContextActionIds.markAsset,
      'Mark as Asset',
      glyph: BlenderGlyph.assetManager,
      enabled: !isAsset,
    ),
    _item(BlenderContextActionIds.clearAsset, 'Clear Asset', enabled: isAsset),
    _separator,
    _item(
      BlenderContextActionIds.libraryOverride,
      'Library Override',
      submenu: <BlenderMenuItem<String>>[
        _item('override-create', 'Make'),
        _item('override-reset', 'Reset'),
      ],
    ),
    _separator,
    _item(
      BlenderContextActionIds.view,
      'View',
      submenu: <BlenderMenuItem<String>>[
        _item(BlenderContextActionIds.frameSelected, 'Show Active'),
        _item('show-hierarchy', 'Show Object Hierarchy'),
        _item('show-one-level', 'Show One Level'),
        _item('hide-one-level', 'Hide One Level'),
      ],
    ),
    _item(BlenderContextActionIds.area, 'Area', submenu: area()),
  ];

  static List<BlenderMenuItem<String>> node({bool hasSelection = true}) =>
      hasSelection
      ? <BlenderMenuItem<String>>[
          _item(BlenderContextActionIds.cut, 'Cut', shortcut: '⌘ X'),
          _item(BlenderContextActionIds.copy, 'Copy', shortcut: '⌘ C'),
          _item(BlenderContextActionIds.paste, 'Paste', shortcut: '⌘ V'),
          _item(
            BlenderContextActionIds.duplicate,
            'Duplicate',
            shortcut: '⇧ D',
          ),
          _separator,
          _item(BlenderContextActionIds.rename, 'Rename Active Node...'),
          _item(
            BlenderContextActionIds.delete,
            'Delete',
            glyph: BlenderGlyph.deleteIcon,
            shortcut: 'X',
          ),
          _separator,
          _item(BlenderContextActionIds.makeGroup, 'Make Group'),
          _item(BlenderContextActionIds.insertIntoGroup, 'Insert Into Group'),
          _separator,
          _item(BlenderContextActionIds.joinFrame, 'Join in New Frame'),
          _item(BlenderContextActionIds.removeFromFrame, 'Remove from Frame'),
        ]
      : <BlenderMenuItem<String>>[
          _item(BlenderContextActionIds.add, 'Add', glyph: BlenderGlyph.plus),
          _item(BlenderContextActionIds.paste, 'Paste', shortcut: '⌘ V'),
          _separator,
          _item(
            BlenderContextActionIds.find,
            'Find...',
            glyph: BlenderGlyph.search,
          ),
          _separator,
          _item('cut-links', 'Cut Links'),
          _item('mute-links', 'Mute Links'),
        ];

  static List<BlenderMenuItem<String>> fileBrowser() =>
      <BlenderMenuItem<String>>[
        _item(
          BlenderContextActionIds.back,
          'Back',
          glyph: BlenderGlyph.arrowLeftRight,
        ),
        _item(BlenderContextActionIds.forward, 'Forward'),
        _item(BlenderContextActionIds.parentDirectory, 'Go to Parent'),
        _item(
          BlenderContextActionIds.refresh,
          'Refresh',
          glyph: BlenderGlyph.refresh,
        ),
        _separator,
        _item(BlenderContextActionIds.rename, 'Rename'),
        _separator,
        _item(
          BlenderContextActionIds.newFolder,
          'New Folder',
          glyph: BlenderGlyph.folder,
        ),
        _item(BlenderContextActionIds.addBookmark, 'Add Bookmark'),
        _separator,
        _item(
          BlenderContextActionIds.display,
          'Display',
          submenu: <BlenderMenuItem<String>>[
            _item('display-list', 'Vertical List'),
            _item('display-grid', 'Thumbnails'),
          ],
        ),
        _item(
          BlenderContextActionIds.sort,
          'Sort By',
          submenu: <BlenderMenuItem<String>>[
            _item('sort-name', 'Name'),
            _item('sort-date', 'Modified Date'),
            _item('sort-size', 'Size'),
          ],
        ),
        _separator,
        _item(
          BlenderContextActionIds.delete,
          'Delete',
          glyph: BlenderGlyph.deleteIcon,
        ),
      ];

  static List<BlenderMenuItem<String>> property({
    bool animated = false,
    bool hasShortcut = false,
    bool developerMode = false,
  }) => <BlenderMenuItem<String>>[
    _item(BlenderContextActionIds.copyDataPath, 'Copy Data Path'),
    _item(BlenderContextActionIds.copyToSelected, 'Copy to Selected'),
    _separator,
    _item(
      animated
          ? BlenderContextActionIds.deleteKeyframe
          : BlenderContextActionIds.insertKeyframe,
      animated ? 'Delete Keyframe' : 'Insert Keyframe',
      glyph: BlenderGlyph.keyframe,
    ),
    _item(BlenderContextActionIds.resetDefault, 'Reset to Default Value'),
    _separator,
    _item(BlenderContextActionIds.addFavorite, 'Add to Quick Favorites'),
    _item(
      BlenderContextActionIds.assignShortcut,
      hasShortcut ? 'Change Shortcut...' : 'Assign Shortcut...',
    ),
    _separator,
    _item(BlenderContextActionIds.onlineManual, 'Online Manual'),
    if (developerMode) ...<BlenderMenuItem<String>>[
      _item('copy-python', 'Copy Python Command'),
      _item('edit-source', 'Edit Source'),
    ],
  ];

  static List<BlenderMenuItem<String>> tool() => <BlenderMenuItem<String>>[
    _item(BlenderContextActionIds.toolSettings, 'Tool Settings'),
    _separator,
    _item(BlenderContextActionIds.addFavorite, 'Add to Quick Favorites'),
    _item(BlenderContextActionIds.assignShortcut, 'Assign Shortcut...'),
    _separator,
    _item(BlenderContextActionIds.onlineManual, 'Online Manual'),
  ];

  static List<BlenderMenuItem<String>> area() => <BlenderMenuItem<String>>[
    _item('split-horizontal', 'Horizontal Split'),
    _item('split-vertical', 'Vertical Split'),
    _item('duplicate-area', 'Duplicate Area into New Window'),
    _separator,
    _item('maximize-area', 'Maximize Area', shortcut: 'Ctrl Space'),
    _item('close-area', 'Close Area'),
  ];
}
