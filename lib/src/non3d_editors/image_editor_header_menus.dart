part of '../non3d_editors.dart';

extension _BlenderImageEditorHeaderMenus on BlenderImageEditorHeader {
  Map<String, List<BlenderMenuItem<String>>> _menuDescriptors() =>
      <String, List<BlenderMenuItem<String>>>{
        'View': _viewMenu(),
        'Select': _selectMenu,
        'Image': _imageMenu(),
        'UV': _uvMenu,
      };

  List<BlenderMenuItem<String>> _viewMenu() => <BlenderMenuItem<String>>[
    for (final label in const <String>[
      'Toolbar',
      'Sidebar',
      'Tool Header',
      'Asset Shelf',
      'HUD',
      'Use Realtime Update',
      'Show Metadata',
    ])
      BlenderMenuItem<String>(value: label, label: label),
    if (_uvEditor)
      const BlenderMenuItem<String>(
        value: 'Frame Selected',
        label: 'Frame Selected',
      ),
    const BlenderMenuItem<String>(value: 'View All', label: 'View All'),
    const BlenderMenuItem<String>(
      value: 'Center View to Cursor',
      label: 'Center View to Cursor',
    ),
    const BlenderMenuItem<String>(
      value: 'Zoom',
      label: 'Zoom',
      submenu: <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: '12.5%', label: '12.5% (1:8)'),
        BlenderMenuItem<String>(value: '25%', label: '25% (1:4)'),
        BlenderMenuItem<String>(value: '50%', label: '50% (1:2)'),
        BlenderMenuItem<String>(value: '100%', label: '100% (1:1)'),
        BlenderMenuItem<String>(value: '200%', label: '200% (2:1)'),
        BlenderMenuItem<String>(value: '400%', label: '400% (4:1)'),
        BlenderMenuItem<String>(value: '800%', label: '800% (8:1)'),
        BlenderMenuItem<String>(value: 'Zoom In', label: 'Zoom In'),
        BlenderMenuItem<String>(value: 'Zoom Out', label: 'Zoom Out'),
        BlenderMenuItem<String>(value: 'Fit', label: 'Zoom to Fit'),
        BlenderMenuItem<String>(value: 'Region', label: 'Zoom Region...'),
      ],
    ),
    if (showRender) ...const <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Render Border', label: 'Render Border'),
      BlenderMenuItem<String>(
        value: 'Clear Render Border',
        label: 'Clear Render Border',
      ),
      BlenderMenuItem<String>(
        value: 'Render Slot Cycle Next',
        label: 'Render Slot Cycle Next',
      ),
      BlenderMenuItem<String>(
        value: 'Render Slot Cycle Previous',
        label: 'Render Slot Cycle Previous',
      ),
    ],
    const BlenderMenuItem<String>(value: 'Area', label: 'Area'),
  ];

  static const List<BlenderMenuItem<String>>
  _selectMenu = <BlenderMenuItem<String>>[
    BlenderMenuItem<String>(value: 'All', label: 'All'),
    BlenderMenuItem<String>(value: 'None', label: 'None'),
    BlenderMenuItem<String>(value: 'Invert', label: 'Invert'),
    BlenderMenuItem<String>(value: 'Box Select', label: 'Box Select'),
    BlenderMenuItem<String>(
      value: 'Box Select Pinned',
      label: 'Box Select Pinned',
    ),
    BlenderMenuItem<String>(value: 'Circle Select', label: 'Circle Select'),
    BlenderMenuItem<String>(value: 'Lasso Select', label: 'Lasso Select'),
    BlenderMenuItem<String>(value: 'More', label: 'More'),
    BlenderMenuItem<String>(value: 'Less', label: 'Less'),
    BlenderMenuItem<String>(value: 'Select Similar', label: 'Select Similar'),
    BlenderMenuItem<String>(
      value: 'Select Linked',
      label: 'Select Linked',
      submenu: <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Linked', label: 'Linked'),
        BlenderMenuItem<String>(value: 'Shortest Path', label: 'Shortest Path'),
      ],
    ),
    BlenderMenuItem<String>(value: 'Select Split', label: 'Select Split'),
    BlenderMenuItem<String>(
      value: 'Select All by Trait',
      label: 'Select All by Trait',
      submenu: <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Tile', label: 'Tile'),
        BlenderMenuItem<String>(value: 'Pinned', label: 'Pinned'),
        BlenderMenuItem<String>(value: 'Overlap', label: 'Overlap'),
        BlenderMenuItem<String>(value: 'Winding', label: 'Winding'),
      ],
    ),
  ];

  List<BlenderMenuItem<String>> _imageMenu() => <BlenderMenuItem<String>>[
    const BlenderMenuItem<String>(value: 'New...', label: 'New...'),
    const BlenderMenuItem<String>(value: 'Open...', label: 'Open...'),
    const BlenderMenuItem<String>(
      value: 'Read View Layers',
      label: 'Read View Layers',
    ),
    if (hasImage) ...<BlenderMenuItem<String>>[
      if (!showRender) ...const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Replace...', label: 'Replace...'),
        BlenderMenuItem<String>(value: 'Reload', label: 'Reload'),
      ],
      const BlenderMenuItem<String>(
        value: 'Edit Externally',
        label: 'Edit Externally',
      ),
    ],
    if (hasImageClipboard) ...const <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Copy', label: 'Copy'),
      BlenderMenuItem<String>(value: 'Paste', label: 'Paste'),
    ],
    if (hasImage) ...const <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Save', label: 'Save'),
      BlenderMenuItem<String>(value: 'Save As...', label: 'Save As...'),
      BlenderMenuItem<String>(value: 'Save a Copy...', label: 'Save a Copy...'),
    ],
    if (imageIsSequence)
      const BlenderMenuItem<String>(
        value: 'Save Sequence',
        label: 'Save Sequence',
      ),
    const BlenderMenuItem<String>(
      value: 'Save All Images',
      label: 'Save All Images',
    ),
    if (hasImage) ...<BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(
        value: 'Invert',
        label: 'Invert',
        submenu: <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Invert Image Colors',
            label: 'Invert Image Colors',
          ),
          BlenderMenuItem<String>(
            value: 'Invert Red Channel',
            label: 'Invert Red Channel',
          ),
          BlenderMenuItem<String>(
            value: 'Invert Green Channel',
            label: 'Invert Green Channel',
          ),
          BlenderMenuItem<String>(
            value: 'Invert Blue Channel',
            label: 'Invert Blue Channel',
          ),
          BlenderMenuItem<String>(
            value: 'Invert Alpha Channel',
            label: 'Invert Alpha Channel',
          ),
        ],
      ),
      const BlenderMenuItem<String>(value: 'Resize', label: 'Resize'),
      const BlenderMenuItem<String>(
        value: 'Transform',
        label: 'Transform',
        submenu: <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Flip Horizontally',
            label: 'Flip Horizontally',
          ),
          BlenderMenuItem<String>(
            value: 'Flip Vertically',
            label: 'Flip Vertically',
          ),
          BlenderMenuItem<String>(
            value: 'Rotate 90 Clockwise',
            label: 'Rotate 90° Clockwise',
          ),
          BlenderMenuItem<String>(
            value: 'Rotate 90 Counter-Clockwise',
            label: 'Rotate 90° Counter-Clockwise',
          ),
          BlenderMenuItem<String>(value: 'Rotate 180', label: 'Rotate 180°'),
        ],
      ),
      if (imagePacked && imageHasPath)
        const BlenderMenuItem<String>(value: 'Unpack', label: 'Unpack')
      else if (!imagePacked)
        const BlenderMenuItem<String>(value: 'Pack', label: 'Pack'),
      if (!_uvEditor)
        const BlenderMenuItem<String>(
          value: 'Extract Palette',
          label: 'Extract Palette',
        ),
    ],
  ];

  static const List<BlenderMenuItem<String>>
  _uvMenu = <BlenderMenuItem<String>>[
    BlenderMenuItem<String>(
      value: 'Transform',
      label: 'Transform',
      submenu: <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Move', label: 'Move'),
        BlenderMenuItem<String>(value: 'Rotate', label: 'Rotate'),
        BlenderMenuItem<String>(value: 'Scale', label: 'Scale'),
        BlenderMenuItem<String>(value: 'Shear', label: 'Shear'),
        BlenderMenuItem<String>(value: 'Vertex Slide', label: 'Vertex Slide'),
        BlenderMenuItem<String>(value: 'Edge Slide', label: 'Edge Slide'),
        BlenderMenuItem<String>(value: 'Randomize', label: 'Randomize'),
      ],
    ),
    BlenderMenuItem<String>(
      value: 'Mirror',
      label: 'Mirror',
      submenu: <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(
          value: 'Copy Mirrored UV Coordinates',
          label: 'Copy Mirrored UV Coordinates',
        ),
        BlenderMenuItem<String>(value: 'X Axis', label: 'X Axis'),
        BlenderMenuItem<String>(value: 'Y Axis', label: 'Y Axis'),
      ],
    ),
    BlenderMenuItem<String>(
      value: 'Snap',
      label: 'Snap',
      submenu: <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(
          value: 'Selected to Pixels',
          label: 'Selected to Pixels',
        ),
        BlenderMenuItem<String>(
          value: 'Selected to Cursor',
          label: 'Selected to Cursor',
        ),
        BlenderMenuItem<String>(
          value: 'Selected to Cursor Offset',
          label: 'Selected to Cursor (Offset)',
        ),
        BlenderMenuItem<String>(
          value: 'Selected to Adjacent Unselected',
          label: 'Selected to Adjacent Unselected',
        ),
        BlenderMenuItem<String>(
          value: 'Cursor to Pixels',
          label: 'Cursor to Pixels',
        ),
        BlenderMenuItem<String>(
          value: 'Cursor to Selected',
          label: 'Cursor to Selected',
        ),
        BlenderMenuItem<String>(
          value: 'Cursor to Origin',
          label: 'Cursor to Origin',
        ),
      ],
    ),
    BlenderMenuItem<String>(value: 'Round to Pixels', label: 'Round to Pixels'),
    BlenderMenuItem<String>(
      value: 'Constrain to Image Bounds',
      label: 'Constrain to Image Bounds',
    ),
    BlenderMenuItem<String>(value: 'Merge', label: 'Merge'),
    BlenderMenuItem<String>(value: 'Split', label: 'Split'),
    BlenderMenuItem<String>(value: 'Rip', label: 'Rip'),
    BlenderMenuItem<String>(value: 'Live Unwrap', label: 'Live Unwrap'),
    BlenderMenuItem<String>(
      value: 'Unwrap',
      label: 'Unwrap',
      submenu: <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(
          value: 'Unwrap Angle Based',
          label: 'Unwrap Angle Based',
        ),
        BlenderMenuItem<String>(
          value: 'Unwrap Conformal',
          label: 'Unwrap Conformal',
        ),
        BlenderMenuItem<String>(
          value: 'Unwrap Minimum Stretch',
          label: 'Unwrap Minimum Stretch',
        ),
        BlenderMenuItem<String>(
          value: 'Smart UV Project...',
          label: 'Smart UV Project...',
        ),
        BlenderMenuItem<String>(
          value: 'Lightmap Pack...',
          label: 'Lightmap Pack...',
        ),
        BlenderMenuItem<String>(
          value: 'Follow Active Quads...',
          label: 'Follow Active Quads...',
        ),
        BlenderMenuItem<String>(
          value: 'Cube Projection',
          label: 'Cube Projection',
        ),
        BlenderMenuItem<String>(
          value: 'Cylinder Projection',
          label: 'Cylinder Projection',
        ),
        BlenderMenuItem<String>(
          value: 'Sphere Projection',
          label: 'Sphere Projection',
        ),
      ],
    ),
    BlenderMenuItem<String>(value: 'Pin', label: 'Pin'),
    BlenderMenuItem<String>(value: 'Unpin', label: 'Unpin'),
    BlenderMenuItem<String>(value: 'Invert Pins', label: 'Invert Pins'),
    BlenderMenuItem<String>(value: 'Mark Seam', label: 'Mark Seam'),
    BlenderMenuItem<String>(value: 'Clear Seam', label: 'Clear Seam'),
    BlenderMenuItem<String>(
      value: 'Seams from Islands',
      label: 'Seams from Islands',
    ),
    BlenderMenuItem<String>(value: 'Pack Islands', label: 'Pack Islands'),
    BlenderMenuItem<String>(
      value: 'Average Islands Scale',
      label: 'Average Islands Scale',
    ),
    BlenderMenuItem<String>(value: 'Arrange Islands', label: 'Arrange Islands'),
    BlenderMenuItem<String>(
      value: 'Minimize Stretch',
      label: 'Minimize Stretch',
    ),
    BlenderMenuItem<String>(value: 'Stitch', label: 'Stitch'),
    BlenderMenuItem<String>(value: 'Align', label: 'Align'),
    BlenderMenuItem<String>(value: 'Align Rotation', label: 'Align Rotation'),
    BlenderMenuItem<String>(value: 'Move on Axis', label: 'Move on Axis'),
    BlenderMenuItem<String>(value: 'Copy UVs', label: 'Copy UVs'),
    BlenderMenuItem<String>(value: 'Paste UVs', label: 'Paste UVs'),
    BlenderMenuItem<String>(value: 'Show/Hide Faces', label: 'Show/Hide Faces'),
    BlenderMenuItem<String>(value: 'Reset', label: 'Reset'),
  ];
}
