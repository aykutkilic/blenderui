part of '../non3d_editors.dart';

/// Source-shaped Image/UV Editor sidebar panels from `space_image.py`.
///
/// Image loading, paint tools, UV editing, scopes, and mask operators remain
/// caller-owned; this widget supplies the visual panel hierarchy and density.
class BlenderImageEditorSidebar extends StatelessWidget {
  const BlenderImageEditorSidebar({super.key, this.uvEditor = false});

  final bool uvEditor;

  @override
  Widget build(BuildContext context) {
    final toolPanels = <Widget>[
      BlenderStaticPropertyField.panel('Brush Asset', <Widget>[
        BlenderStaticPropertyField.menu('Asset', 'Basic Brush', <String>[
          'Basic Brush',
          'Draw',
          'Erase',
        ]),
      ], expanded: true),
      BlenderStaticPropertyField.panel('Brush Settings', <Widget>[
        BlenderStaticPropertyField.number('Radius', 50),
        BlenderStaticPropertyField.number('Strength', .5),
        BlenderStaticPropertyField.panel('Advanced', <Widget>[
          BlenderStaticPropertyField.checkbox('Pressure Size'),
          BlenderStaticPropertyField.checkbox('Pressure Strength'),
          BlenderStaticPropertyField.number('Jitter', 0),
        ]),
        BlenderStaticPropertyField.panel('Color Picker', <Widget>[
          BlenderStaticPropertyField.menu('Mode', 'Mix', <String>[
            'Mix',
            'Add',
            'Subtract',
          ]),
          BlenderStaticPropertyField.checkbox('Use Unified Color'),
        ]),
        BlenderStaticPropertyField.panel('Color Palette', <Widget>[
          BlenderStaticPropertyField.checkbox('Show Palette'),
          BlenderStaticPropertyField.number('Color Saturation', 1),
        ]),
        BlenderStaticPropertyField.panel('Clone from Image/UV Map', <Widget>[
          BlenderStaticPropertyField.menu('Clone Mode', 'Material', <String>[
            'Material',
            'Image/UV Map',
          ]),
          BlenderStaticPropertyField.number('Alpha', 1),
        ]),
        BlenderStaticPropertyField.panel('Cursor', <Widget>[
          BlenderStaticPropertyField.checkbox('Show Cursor'),
          BlenderStaticPropertyField.checkbox('Show Outline'),
        ]),
        BlenderStaticPropertyField.panel('Texture', <Widget>[
          BlenderStaticPropertyField.menu('Texture', 'None', <String>[
            'None',
            'Noise',
            'Image',
          ]),
          BlenderStaticPropertyField.number('Angle', 0),
          BlenderStaticPropertyField.number('Scale', 1),
        ]),
        BlenderStaticPropertyField.panel('Texture Mask', <Widget>[
          BlenderStaticPropertyField.menu('Mask', 'None', <String>[
            'None',
            'Noise',
            'Voronoi',
          ]),
          BlenderStaticPropertyField.number('Mask Angle', 0),
        ]),
        BlenderStaticPropertyField.panel('Stroke', <Widget>[
          BlenderStaticPropertyField.menu('Method', 'Space', <String>[
            'Space',
            'Airbrush',
            'Dots',
          ]),
          BlenderStaticPropertyField.number('Spacing', 10),
          BlenderStaticPropertyField.panel('Stabilize Stroke', <Widget>[
            BlenderStaticPropertyField.checkbox('Smooth Stroke'),
            BlenderStaticPropertyField.number('Radius', .5),
          ]),
        ]),
        BlenderStaticPropertyField.panel('Falloff', <Widget>[
          BlenderStaticPropertyField.menu('Shape', 'Smooth', <String>[
            'Smooth',
            'Sphere',
            'Root',
            'Sharp',
          ]),
          BlenderStaticPropertyField.number('Radius', .5),
        ]),
      ]),
      BlenderStaticPropertyField.panel('Tiling', <Widget>[
        BlenderStaticPropertyField.checkbox('X'),
        BlenderStaticPropertyField.checkbox('Y', value: false),
        BlenderStaticPropertyField.checkbox('Z', value: false),
      ]),
    ];

    final imagePanels = <Widget>[
      BlenderStaticPropertyField.panel('Image', <Widget>[
        BlenderStaticPropertyField.menu('Source', 'Generated', <String>[
          'Generated',
          'Viewer Node',
          'Sequence',
        ]),
        BlenderStaticPropertyField.number('Resolution X', 2048),
        BlenderStaticPropertyField.number('Resolution Y', 2048),
        BlenderStaticPropertyField.checkbox('Half Float'),
      ], expanded: true),
      BlenderStaticPropertyField.panel('Render Slots', <Widget>[
        BlenderStaticPropertyField.menu('Slot', 'Slot 1', <String>[
          'Slot 1',
          'Slot 2',
          'Slot 3',
        ]),
      ]),
      BlenderStaticPropertyField.panel('UDIM Tiles', <Widget>[
        BlenderStaticPropertyField.menu('Tile', '1001', <String>[
          '1001',
          '1002',
          '1011',
        ]),
        BlenderStaticPropertyField.number('Tile Count', 1),
      ]),
    ];

    final viewPanels = <Widget>[
      BlenderStaticPropertyField.panel('Display', <Widget>[
        BlenderStaticPropertyField.menu('Aspect Ratio', '1:1', <String>[
          '1:1',
          '2:1',
          'Custom',
        ]),
        BlenderStaticPropertyField.checkbox('Repeat Image'),
        if (uvEditor) BlenderStaticPropertyField.checkbox('Pixel Coordinates'),
      ], expanded: true),
      BlenderStaticPropertyField.panel('2D Cursor', <Widget>[
        BlenderStaticPropertyField.number('Location X', .5),
        BlenderStaticPropertyField.number('Location Y', .5),
      ]),
      BlenderStaticPropertyField.panel('Histogram', <Widget>[
        BlenderStaticPropertyField.checkbox('Full Resolution'),
        BlenderStaticPropertyField.menu('Accuracy', '1.0', <String>[
          '1.0',
          '0.5',
          '0.25',
        ]),
      ]),
      BlenderStaticPropertyField.panel('Waveform', <Widget>[
        BlenderStaticPropertyField.checkbox('Full Resolution'),
        BlenderStaticPropertyField.menu('Channels', 'Luma', <String>[
          'Luma',
          'RGB',
          'Red',
          'Green',
          'Blue',
        ]),
      ]),
      BlenderStaticPropertyField.panel('Vectorscope', <Widget>[
        BlenderStaticPropertyField.checkbox('Full Resolution'),
        BlenderStaticPropertyField.menu('Channels', 'Saturation', <String>[
          'Saturation',
          'Color',
        ]),
      ]),
      BlenderStaticPropertyField.panel('Sample Line', <Widget>[
        BlenderStaticPropertyField.checkbox('Show Sample Line'),
        BlenderStaticPropertyField.number('Position', .5),
      ]),
      BlenderStaticPropertyField.panel('Samples', <Widget>[
        BlenderStaticPropertyField.number('Sample Count', 8),
        BlenderStaticPropertyField.checkbox('Full Resolution'),
      ]),
    ];

    final maskPanels = <Widget>[
      BlenderStaticPropertyField.panel('Mask', <Widget>[
        BlenderStaticPropertyField.checkbox('Show Mask'),
        BlenderStaticPropertyField.menu('Mode', 'Combined', <String>[
          'Combined',
          'Alpha',
          'Outline',
        ]),
      ]),
      BlenderStaticPropertyField.panel('Mask Layers', <Widget>[
        BlenderStaticPropertyField.menu('Active Layer', 'Mask Layer', <String>[
          'Mask Layer',
          'Layer 2',
        ]),
      ]),
      BlenderStaticPropertyField.panel('Active Spline', <Widget>[
        BlenderStaticPropertyField.number('Feather', .5),
        BlenderStaticPropertyField.checkbox('Cyclic'),
      ]),
      BlenderStaticPropertyField.panel('Active Point', <Widget>[
        BlenderStaticPropertyField.number('Weight', 1),
        BlenderStaticPropertyField.number('Radius', 1),
      ]),
      BlenderStaticPropertyField.panel('Animation', <Widget>[
        BlenderStaticPropertyField.checkbox('Animated'),
        BlenderStaticPropertyField.number('Frame', 1),
      ]),
    ];

    return ListView(
      padding: const EdgeInsets.all(4),
      children: <Widget>[
        ...toolPanels,
        ...imagePanels,
        ...viewPanels,
        ...maskPanels,
      ],
    );
  }
}
