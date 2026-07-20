part of '../non3d_editors.dart';

/// Source-shaped Clip Editor sidebar panels from `space_clip.py`.
///
/// Tracking, solving, stabilization, footage, and mask data remain
/// caller-owned; this widget mirrors the visible panel families and density.
class BlenderClipEditorSidebar extends StatelessWidget {
  const BlenderClipEditorSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(6),
      children: <Widget>[
        BlenderStaticPropertyField.panel('Track', <Widget>[
          BlenderStaticPropertyField.menu('Active Track', 'Track', <String>[
            'Track',
            'No active track',
          ]),
          BlenderStaticPropertyField.checkbox('Lock Track', value: false),
          BlenderStaticPropertyField.checkbox('Red Channel'),
          BlenderStaticPropertyField.checkbox('Green Channel'),
          BlenderStaticPropertyField.checkbox('Blue Channel'),
          BlenderStaticPropertyField.checkbox(
            'Grayscale Preview',
            value: false,
          ),
          BlenderStaticPropertyField.checkbox('Alpha Preview', value: false),
          BlenderStaticPropertyField.number('Weight', 1),
          BlenderStaticPropertyField.number('Stabilization Weight', 1),
          BlenderStaticPropertyField.panel('Objects', <Widget>[
            BlenderStaticPropertyField.menu('Object', 'Camera', <String>[
              'Camera',
              'Object',
            ]),
            const BlenderButton(label: 'Add Object', onPressed: _noop),
          ]),
          BlenderStaticPropertyField.panel('Plane Track', <Widget>[
            BlenderStaticPropertyField.menu('Plane', 'Plane Track', <String>[
              'Plane Track',
              'None',
            ]),
            BlenderStaticPropertyField.checkbox('Auto Keying', value: false),
            BlenderStaticPropertyField.number('Opacity', .8),
          ]),
          BlenderStaticPropertyField.panel('Tracking Settings', <Widget>[
            BlenderStaticPropertyField.menu(
              'Motion Model',
              'Perspective',
              <String>['Translation', 'Affine', 'Perspective'],
            ),
            BlenderStaticPropertyField.menu('Match', 'Previous Frame', <String>[
              'Previous Frame',
              'Keyframe',
            ]),
            BlenderStaticPropertyField.checkbox('Brute', value: false),
            BlenderStaticPropertyField.checkbox('Normalization'),
            BlenderStaticPropertyField.panel(
              'Tracking Settings Extras',
              <Widget>[
                BlenderStaticPropertyField.number('Correlation Min', .75),
                BlenderStaticPropertyField.number('Margin', 5),
                BlenderStaticPropertyField.number('Frames Limit', 0),
                BlenderStaticPropertyField.number('Speed', 1),
              ],
            ),
          ]),
          BlenderStaticPropertyField.panel('Camera', <Widget>[
            BlenderStaticPropertyField.number('Sensor Width', 36),
            BlenderStaticPropertyField.number('Pixel Aspect', 1),
            BlenderStaticPropertyField.panel('Lens', <Widget>[
              BlenderStaticPropertyField.number('Focal Length', 50),
              BlenderStaticPropertyField.menu('Units', 'Millimeters', <String>[
                'Millimeters',
                'Pixels',
              ]),
              BlenderStaticPropertyField.number('Optical Center', 0),
              BlenderStaticPropertyField.menu(
                'Lens Distortion',
                'Polynomial',
                <String>['Polynomial', 'Division'],
              ),
            ]),
          ]),
          BlenderStaticPropertyField.panel('Marker', <Widget>[
            BlenderStaticPropertyField.number('Pattern Size', 11),
            BlenderStaticPropertyField.number('Search Size', 21),
          ]),
        ], expanded: true),
        BlenderStaticPropertyField.panel('Solve', <Widget>[
          BlenderStaticPropertyField.number('Frames', 8),
          BlenderStaticPropertyField.number('Error', .5),
          BlenderStaticPropertyField.checkbox('Refine Focal Length'),
          BlenderStaticPropertyField.checkbox(
            'Refine Optical Center',
            value: false,
          ),
          BlenderStaticPropertyField.panel('Cleanup', <Widget>[
            BlenderStaticPropertyField.number('Frames', 10),
            BlenderStaticPropertyField.number('Error Threshold', 1),
          ]),
          BlenderStaticPropertyField.panel('Geometry', <Widget>[
            BlenderStaticPropertyField.menu('Geometry', 'Tracks', <String>[
              'Tracks',
              'Plane',
            ]),
            BlenderStaticPropertyField.checkbox('Use Keyframe', value: false),
          ]),
        ]),
        BlenderStaticPropertyField.panel('2D Stabilization', <Widget>[
          BlenderStaticPropertyField.checkbox('Use 2D Stabilization'),
          BlenderStaticPropertyField.number('Anchor Frame', 1),
          BlenderStaticPropertyField.checkbox(
            'Stabilize Rotation',
            value: false,
          ),
          BlenderStaticPropertyField.checkbox('Stabilize Scale', value: false),
          BlenderStaticPropertyField.checkbox('Auto Scale'),
          BlenderStaticPropertyField.number('Influence Location', 1),
          BlenderStaticPropertyField.number('Influence Rotation', 1),
          BlenderStaticPropertyField.number('Influence Scale', 1),
        ]),
        BlenderStaticPropertyField.panel('View', <Widget>[
          BlenderStaticPropertyField.number('Cursor X', 0),
          BlenderStaticPropertyField.number('Cursor Y', 0),
        ]),
        const BlenderAnnotationSettingsPanel(
          state: BlenderAnnotationSettings(visible: false),
        ),
        BlenderStaticPropertyField.panel('Footage', <Widget>[
          BlenderStaticPropertyField.menu('Clip', 'Footage.mov', <String>[
            'Footage.mov',
            'No active movie clip',
          ]),
          BlenderStaticPropertyField.menu('Proxy Size', 'Scene', <String>[
            'None',
            'Scene',
            '50%',
          ]),
          BlenderStaticPropertyField.checkbox('Use Proxy', value: false),
          BlenderStaticPropertyField.panel('Proxy', <Widget>[
            BlenderStaticPropertyField.checkbox('Build Original', value: false),
            BlenderStaticPropertyField.checkbox(
              'Build Undistorted',
              value: false,
            ),
            BlenderStaticPropertyField.number('Quality', 90),
            const BlenderButton(label: 'Build Proxy', onPressed: _noop),
          ]),
          BlenderStaticPropertyField.panel('Animation', <Widget>[
            BlenderStaticPropertyField.menu('Action', 'ClipAction', <String>[
              'ClipAction',
              'None',
            ]),
          ]),
        ]),
        BlenderStaticPropertyField.panel('Mask', <Widget>[
          BlenderStaticPropertyField.checkbox('Use Mask', value: false),
          BlenderStaticPropertyField.menu('Active Mask', 'Roto Mask', <String>[
            'Roto Mask',
            'None',
          ]),
          BlenderStaticPropertyField.checkbox('Invert', value: false),
          BlenderStaticPropertyField.number('Feather', 1),
        ]),
      ],
    );
  }
}

class BlenderClipEditor extends StatelessWidget {
  const BlenderClipEditor({
    super.key,
    this.image,
    this.markers = const <BlenderClipMarker>[],
    this.selectedId,
    this.onSelected,
    this.maskSidebar,
    this.sidebar,
    this.sidebarWidth = 280,
    this.title = 'Movie Clip Editor',
  });

  final Widget? image;
  final List<BlenderClipMarker> markers;
  final String? selectedId;
  final ValueChanged<BlenderClipMarker>? onSelected;
  final Widget? maskSidebar;
  final Widget? sidebar;
  final double sidebarWidth;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final editor = BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          image ??
              ColoredBox(
                color: theme.colors.canvas,
                child: Center(
                  child: Text(
                    'No Clip',
                    style: theme.textTheme.body.copyWith(
                      color: theme.colors.foregroundMuted,
                    ),
                  ),
                ),
              ),
          for (final marker in markers)
            Positioned(
              left: marker.position.dx,
              top: marker.position.dy,
              child: GestureDetector(
                onTap: onSelected == null ? null : () => onSelected!(marker),
                child: Container(
                  width: marker.id == selectedId ? 14 : 10,
                  height: marker.id == selectedId ? 14 : 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: marker.color ?? theme.colors.accent,
                    border: Border.all(color: theme.colors.foreground),
                  ),
                ),
              ),
            ),
          if (maskSidebar case final sidebar?)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: sidebarWidth,
              child: sidebar,
            ),
        ],
      ),
    );
    if (sidebar == null) return editor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: editor),
        SizedBox(width: sidebarWidth, child: sidebar),
      ],
    );
  }
}
