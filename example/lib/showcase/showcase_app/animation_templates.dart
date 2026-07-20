part of '../showcase_app.dart';

/// Source-shaped startup artwork for the showcase. Blender's native splash is
/// an image-backed popup with version text, file templates, and getting-started
/// links. The example keeps those surfaces actionable while using a portable
/// painter when Blender's packaged splash asset is unavailable to the host.
class _ShowcaseSplashContent extends StatelessWidget {
  const _ShowcaseSplashContent({
    required this.onTemplateSelected,
    required this.onStatus,
  });

  final ValueChanged<BlenderStartupTemplateEntry> onTemplateSelected;
  final ValueChanged<String> onStatus;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 270,
          child: CustomPaint(
            painter: _ShowcaseSplashPainter(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const BlenderIcon(BlenderGlyph.cube, size: 42),
                      const SizedBox(width: 10),
                      Text(
                        'blender',
                        style: theme.textTheme.heading.copyWith(
                          color: const Color(0xFFF5F5F5),
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '5.1.2',
                        style: theme.textTheme.body.copyWith(
                          color: const Color(0xFFF5F5F5),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'studio.blender.org',
                    style: theme.textTheme.body.copyWith(
                      color: const Color(0xFFF5F5F5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        BlenderStartupTemplateChooser(
          templates: _startupTemplates,
          resources: _startupResources,
          onTemplateSelected: onTemplateSelected,
          onResourceSelected: (entry) => onStatus('${entry.label} selected'),
        ),
      ],
    );
  }
}

class _ShowcaseSplashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          colors: <Color>[
            Color(0xFF13263D),
            Color(0xFF38205C),
            Color(0xFF102A3A),
          ],
        ).createShader(rect),
    );
    final blobs = <(Offset, double, Color)>[
      (
        Offset(size.width * .18, size.height * .35),
        80,
        const Color(0x664B9AC0),
      ),
      (
        Offset(size.width * .54, size.height * .58),
        130,
        const Color(0x665E35A5),
      ),
      (
        Offset(size.width * .86, size.height * .22),
        100,
        const Color(0x664A7EBC),
      ),
    ];
    for (final (center, radius, color) in blobs) {
      canvas.drawCircle(center, radius, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_ShowcaseSplashPainter oldDelegate) => false;
}

enum _ShowcaseTemplateMode { general, twoDAnimation, storyboarding }

const List<BlenderStartupTemplateEntry> _startupTemplates =
    <BlenderStartupTemplateEntry>[
      BlenderStartupTemplateEntry(
        id: 'general',
        label: 'General',
        glyph: BlenderGlyph.plus,
      ),
      BlenderStartupTemplateEntry(
        id: '2d-animation',
        label: '2D Animation',
        glyph: BlenderGlyph.greasepencil,
      ),
      BlenderStartupTemplateEntry(
        id: 'sculpting',
        label: 'Sculpting',
        glyph: BlenderGlyph.tool,
      ),
      BlenderStartupTemplateEntry(
        id: 'storyboarding',
        label: 'Storyboarding',
        glyph: BlenderGlyph.sequence,
      ),
      BlenderStartupTemplateEntry(
        id: 'vfx',
        label: 'VFX',
        glyph: BlenderGlyph.node,
      ),
      BlenderStartupTemplateEntry(
        id: 'video-editing',
        label: 'Video Editing',
        glyph: BlenderGlyph.movie,
      ),
    ];

const List<BlenderStartupTemplateEntry> _startupResources =
    <BlenderStartupTemplateEntry>[
      BlenderStartupTemplateEntry(
        id: 'manual',
        label: 'Manual',
        glyph: BlenderGlyph.internet,
      ),
      BlenderStartupTemplateEntry(
        id: 'support',
        label: 'Support',
        glyph: BlenderGlyph.internet,
      ),
      BlenderStartupTemplateEntry(
        id: 'communities',
        label: 'User Communities',
        glyph: BlenderGlyph.internet,
      ),
      BlenderStartupTemplateEntry(
        id: 'involved',
        label: 'Get Involved',
        glyph: BlenderGlyph.internet,
      ),
      BlenderStartupTemplateEntry(
        id: 'whats-new',
        label: "What's New",
        glyph: BlenderGlyph.internet,
      ),
      BlenderStartupTemplateEntry(
        id: 'donate',
        label: 'Donate to Blender',
        glyph: BlenderGlyph.material,
      ),
    ];

extension _ShowcaseAnimationTemplates on _ShowcaseAppState {
  List<BlenderApplicationWorkspace<int>> get _templateWorkspaces =>
      switch (_templateMode) {
        _ShowcaseTemplateMode.twoDAnimation =>
          const <BlenderApplicationWorkspace<int>>[
            BlenderApplicationWorkspace<int>(value: 20, label: '2D Animation'),
            BlenderApplicationWorkspace<int>(
              value: 21,
              label: '2D Full Canvas',
            ),
          ],
        _ShowcaseTemplateMode.storyboarding =>
          const <BlenderApplicationWorkspace<int>>[
            BlenderApplicationWorkspace<int>(value: 30, label: 'Storyboarding'),
            BlenderApplicationWorkspace<int>(value: 31, label: 'Video Editing'),
          ],
        _ShowcaseTemplateMode.general =>
          const <BlenderApplicationWorkspace<int>>[
            BlenderApplicationWorkspace<int>(value: 0, label: 'Layout'),
            BlenderApplicationWorkspace<int>(value: 1, label: 'Modeling'),
            BlenderApplicationWorkspace<int>(value: 2, label: 'Sculpting'),
            BlenderApplicationWorkspace<int>(value: 3, label: 'UV Editing'),
            BlenderApplicationWorkspace<int>(value: 4, label: 'Texture Paint'),
            BlenderApplicationWorkspace<int>(value: 5, label: 'Shading'),
            BlenderApplicationWorkspace<int>(value: 6, label: 'Animation'),
            BlenderApplicationWorkspace<int>(value: 7, label: 'Rendering'),
            BlenderApplicationWorkspace<int>(value: 8, label: 'Compositing'),
            BlenderApplicationWorkspace<int>(value: 9, label: 'Geometry Nodes'),
            BlenderApplicationWorkspace<int>(value: 10, label: 'Components'),
          ],
      };

  static const List<BlenderGreasePencilBrush> _brushes =
      <BlenderGreasePencilBrush>[
        BlenderGreasePencilBrush(
          id: 'airbrush',
          label: 'Airbrush',
          preview: BlenderGreasePencilBrushPreview(
            kind: BlenderGreasePencilBrushPreviewKind.soft,
          ),
        ),
        BlenderGreasePencilBrush(
          id: 'ink-pen',
          label: 'Ink Pen',
          preview: BlenderGreasePencilBrushPreview(seed: 1),
        ),
        BlenderGreasePencilBrush(
          id: 'ink-pen-rough',
          label: 'Ink Pen Rough',
          preview: BlenderGreasePencilBrushPreview(seed: 2),
        ),
        BlenderGreasePencilBrush(
          id: 'marker-bold',
          label: 'Marker Bold',
          preview: BlenderGreasePencilBrushPreview(
            kind: BlenderGreasePencilBrushPreviewKind.soft,
            color: Color(0xFF555555),
            seed: 3,
          ),
        ),
        BlenderGreasePencilBrush(
          id: 'marker-chisel',
          label: 'Marker Chisel',
          preview: BlenderGreasePencilBrushPreview(seed: 4),
        ),
        BlenderGreasePencilBrush(
          id: 'pen',
          label: 'Pen',
          preview: BlenderGreasePencilBrushPreview(seed: 5),
        ),
        BlenderGreasePencilBrush(
          id: 'pencil',
          label: 'Pencil',
          preview: BlenderGreasePencilBrushPreview(
            color: Color(0xFF555555),
            seed: 6,
          ),
        ),
        BlenderGreasePencilBrush(
          id: 'pencil-soft',
          label: 'Pencil Soft',
          preview: BlenderGreasePencilBrushPreview(
            kind: BlenderGreasePencilBrushPreviewKind.soft,
            seed: 7,
          ),
        ),
        BlenderGreasePencilBrush(
          id: 'tint',
          label: 'Tint',
          preview: BlenderGreasePencilBrushPreview(
            color: Color(0xFF111111),
            accentColor: Color(0xFF8DB9E8),
            seed: 8,
          ),
        ),
        BlenderGreasePencilBrush(
          id: 'paint',
          label: 'Paint',
          preview: BlenderGreasePencilBrushPreview(
            color: Color(0xFFFF6E40),
            seed: 9,
          ),
        ),
        BlenderGreasePencilBrush(
          id: 'eraser-soft',
          label: 'Eraser Soft',
          category: 'Erase',
          glyph: BlenderGlyph.deleteIcon,
          preview: BlenderGreasePencilBrushPreview(
            kind: BlenderGreasePencilBrushPreviewKind.eraser,
            seed: 10,
          ),
        ),
        BlenderGreasePencilBrush(
          id: 'eraser-hard',
          label: 'Eraser Hard',
          category: 'Erase',
          glyph: BlenderGlyph.deleteIcon,
          preview: BlenderGreasePencilBrushPreview(
            kind: BlenderGreasePencilBrushPreviewKind.eraser,
            color: Color(0xFF333333),
            seed: 11,
          ),
        ),
        BlenderGreasePencilBrush(
          id: 'fill',
          label: 'Fill',
          category: 'Utilities',
          glyph: BlenderGlyph.color,
          preview: BlenderGreasePencilBrushPreview(
            kind: BlenderGreasePencilBrushPreviewKind.fill,
            color: Color(0xFF8EDC91),
          ),
        ),
      ];

  static const List<BlenderGreasePencilStroke> _strokes =
      <BlenderGreasePencilStroke>[
        BlenderGreasePencilStroke(
          points: <Offset>[
            Offset(.18, .62),
            Offset(.26, .42),
            Offset(.36, .58),
            Offset(.47, .30),
            Offset(.58, .56),
            Offset(.72, .38),
            Offset(.82, .60),
          ],
          color: Color(0xFF202020),
          width: 6,
        ),
      ];

  void _launchStartupTemplate(BlenderStartupTemplateEntry entry) {
    _navigatorKey.currentState?.pop();
    switch (entry.id) {
      case '2d-animation':
        _activateAnimationTemplate(_ShowcaseTemplateMode.twoDAnimation);
      case 'storyboarding':
        _activateAnimationTemplate(_ShowcaseTemplateMode.storyboarding);
      default:
        _update(() {
          _templateMode = _ShowcaseTemplateMode.general;
          _templateSecondaryWorkspace = false;
          _workspaceIndex = 0;
        });
        _application.docking.replaceRoot(_generalTemplateLayout);
        _setStatus('${entry.label} template selected');
    }
  }

  void _activateAnimationTemplate(_ShowcaseTemplateMode mode) {
    _update(() {
      _templateMode = mode;
      _templateSecondaryWorkspace = false;
      _workspaceIndex = mode == _ShowcaseTemplateMode.storyboarding ? 30 : 20;
      _workspaceMode = 'Grease Pencil Draw';
      _propertyTab = 0;
      _selectedObject = mode == _ShowcaseTemplateMode.storyboarding
          ? 'Stroke.001'
          : 'Stroke';
      _animationHeaderState = _animationHeaderState.copyWith(
        autoKeying: mode == _ShowcaseTemplateMode.twoDAnimation,
      );
    });
    _mainEditorArea.select(BlenderEditorType.view3d);
    _rightTopEditorArea.select(BlenderEditorType.outliner);
    _rightBottomEditorArea.select(BlenderEditorType.properties);
    _application.docking.replaceRoot(
      mode == _ShowcaseTemplateMode.storyboarding
          ? _storyboardingTemplateLayout
          : _twoDAnimationTemplateLayout,
    );
    _setStatus(
      mode == _ShowcaseTemplateMode.storyboarding
          ? 'Storyboarding template loaded'
          : '2D Animation template loaded',
    );
  }

  void _selectTemplateWorkspace(int value) {
    final secondary = value == 21 || value == 31;
    _update(() {
      _workspaceIndex = value;
      _templateSecondaryWorkspace = secondary;
      if (_templateMode == _ShowcaseTemplateMode.storyboarding && secondary) {
        _propertyTab = _propertyTabs.indexWhere((tab) => tab.id == 'strip');
      } else {
        _propertyTab = 0;
      }
    });
    _application.docking.replaceRoot(switch (value) {
      21 => _twoDFullCanvasTemplateLayout,
      31 => _videoEditingTemplateLayout,
      30 => _storyboardingTemplateLayout,
      _ => _twoDAnimationTemplateLayout,
    });
  }

  Widget _buildGreasePencilMainEditor() {
    if (_templateMode == _ShowcaseTemplateMode.storyboarding &&
        _templateSecondaryWorkspace) {
      return _buildVideoEditingPreview();
    }
    return Column(
      children: <Widget>[
        BlenderGreasePencilEditorHeader(
          state: _greasePencilHeaderState,
          onStateChanged: (value) =>
              _update(() => _greasePencilHeaderState = value),
          onEditorTypeChanged: _mainEditorArea.select,
          onCommand: _setStatus,
        ),
        BlenderGreasePencilToolHeader(
          brushes: _brushes,
          materials: _greasePencilMaterials,
          state: _greasePencilToolSettings,
          onChanged: (value) =>
              _update(() => _greasePencilToolSettings = value),
          onMaterialChanged: (material) => _update(() {
            _greasePencilMaterials = <BlenderGreasePencilMaterial>[
              for (final current in _greasePencilMaterials)
                if (current.id == material.id) material else current,
            ];
          }),
          onCommand: _setStatus,
        ),
        Expanded(
          child: BlenderGreasePencilViewport(
            strokes: _strokes,
            objectName: _selectedObject,
            layerName: 'Lines',
            toolShelf: BlenderGreasePencilToolShelf(
              selectedTool: _greasePencilTool,
              onChanged: (value) => _update(() => _greasePencilTool = value),
              onOptionSelected: (value) => _setStatus(value.label),
            ),
            assetShelf: BlenderGreasePencilBrushAssetShelf(
              brushes: _brushes,
              selectedId: _greasePencilToolSettings.brushId,
              onSelected: (brush) => _update(
                () => _greasePencilToolSettings = _greasePencilToolSettings
                    .copyWith(brushId: brush.id),
              ),
            ),
            onCommand: _setStatus,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoEditingPreview() => BlenderVideoSequencerWorkspace(
    headerState: _sequencerHeaderState.copyWith(viewType: 'Preview'),
    onHeaderStateChanged: (value) =>
        _update(() => _sequencerHeaderState = value),
    onCommand: _setStatus,
    strips: _storyboardStrips,
    start: 1,
    end: 97,
    currentFrame: _frame,
    currentFrameListenable: _playback,
    onCurrentFrameChanged: _playback.seek,
    preview: const BlenderGreasePencilViewport(
      strokes: _strokes,
      objectName: 'Shot.001',
      layerName: 'Preview',
    ),
    showChannels: false,
    showToolHeader: false,
  );

  Widget _buildGreasePencilDopeSheetArea() => Column(
    children: <Widget>[
      BlenderDopeSheetEditorHeader(
        editorType: BlenderEditorType.dopeSheet,
        state: _animationHeaderState,
        modeValue: 'Grease Pencil',
        modeItems: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Grease Pencil',
            label: 'Grease Pencil',
            icon: BlenderIcon(BlenderGlyph.greasepencil, size: 16),
          ),
          BlenderMenuItem<String>(value: 'Dope Sheet', label: 'Dope Sheet'),
          BlenderMenuItem<String>(
            value: 'Action Editor',
            label: 'Action Editor',
          ),
        ],
        onModeChanged: (value) => _setStatus('Dope Sheet mode: $value'),
        onStateChanged: (value) => _update(() => _animationHeaderState = value),
        onCommand: _setStatus,
      ),
      Expanded(
        child: BlenderDopeSheetEditor(
          model: _greasePencilTimelineModel,
          onCurrentFrameChanged: _playback.seek,
          currentFrameListenable: _playback,
          sidebar: BlenderGreasePencilDopeSheetSidebar(onCommand: _setStatus),
        ),
      ),
      BlenderAnimationPlaybackFooter(
        state: _animationHeaderState,
        onStateChanged: (value) => _update(() => _animationHeaderState = value),
        playing: _playback.playing,
        onFirst: _playback.jumpToStart,
        onPrevious: _playback.stepBackward,
        onPlay: _playback.togglePlaying,
        onNext: _playback.stepForward,
        onLast: _playback.jumpToEnd,
        onRecord: () => _setStatus('Record toggled'),
        frame: _frame,
        frameMax: _templateMode == _ShowcaseTemplateMode.storyboarding
            ? 48
            : 250,
        onFrameChanged: _playback.seek,
        keyPrefix: 'gp-playback',
      ),
    ],
  );

  Widget _buildStoryboardSequencerArea() => BlenderVideoSequencerWorkspace(
    headerState: _sequencerHeaderState.copyWith(
      viewType: 'Sequencer',
      scene: 'Scene',
    ),
    onHeaderStateChanged: (value) =>
        _update(() => _sequencerHeaderState = value),
    onCommand: _setStatus,
    strips: _storyboardStrips,
    start: 1,
    end: 97,
    currentFrame: _frame,
    currentFrameListenable: _playback,
    onCurrentFrameChanged: _playback.seek,
    selectedId: _selectedStoryboardStrip,
    onStripSelected: (strip) =>
        _update(() => _selectedStoryboardStrip = strip.id),
    channelLabels: const <int, String>{0: 'Channel 1', 1: 'Channel 2'},
    showChannels: true,
    showSeconds: true,
    framesPerSecond: 24,
    footer: BlenderAnimationPlaybackFooter(
      state: _animationHeaderState,
      onStateChanged: (value) => _update(() => _animationHeaderState = value),
      playing: _playback.playing,
      onFirst: _playback.jumpToStart,
      onPrevious: _playback.stepBackward,
      onPlay: _playback.togglePlaying,
      onNext: _playback.stepForward,
      onLast: _playback.jumpToEnd,
      onRecord: () => _setStatus('Record toggled'),
      frame: _frame,
      frameMax: 97,
      onFrameChanged: _playback.seek,
      keyPrefix: 'storyboard-playback',
    ),
  );

  BlenderTimelineModel get _greasePencilTimelineModel => BlenderTimelineModel(
    start: 1,
    end: _templateMode == _ShowcaseTemplateMode.storyboarding ? 48 : 250,
    currentFrame: _frame,
    tracks: const <BlenderTimelineTrack>[
      BlenderTimelineTrack(
        id: 'stroke',
        label: 'Stroke',
        keyframes: <BlenderTimelineKeyframe>[
          BlenderTimelineKeyframe(1),
          BlenderTimelineKeyframe(24),
          BlenderTimelineKeyframe(48),
        ],
      ),
      BlenderTimelineTrack(
        id: 'lines',
        label: 'Lines',
        keyframes: <BlenderTimelineKeyframe>[
          BlenderTimelineKeyframe(1),
          BlenderTimelineKeyframe(24),
        ],
      ),
    ],
  );

  static const List<BlenderSequencerStrip> _storyboardStrips =
      <BlenderSequencerStrip>[
        BlenderSequencerStrip(
          id: 'shot-001',
          label: 'Shot.001',
          start: 1,
          end: 49,
          channel: 0,
          color: Color(0xFF6D65B5),
        ),
        BlenderSequencerStrip(
          id: 'shot-002',
          label: 'Shot.002',
          start: 49,
          end: 97,
          channel: 0,
          color: Color(0xFF6D65B5),
        ),
      ];
}

const BlenderDockNode<String> _generalTemplateLayout =
    BlenderDockSplitNode<String>(
      id: 'workspace-columns',
      direction: BlenderSplitDirection.horizontal,
      fraction: .80,
      first: BlenderDockSplitNode<String>(
        id: 'main-stack',
        direction: BlenderSplitDirection.vertical,
        fraction: .84,
        first: BlenderDockAreaNode<String>(id: 'main-area', value: 'main'),
        second: BlenderDockAreaNode<String>(id: 'bottom-area', value: 'bottom'),
      ),
      second: BlenderDockSplitNode<String>(
        id: 'right-stack',
        direction: BlenderSplitDirection.vertical,
        fraction: .27,
        first: BlenderDockAreaNode<String>(
          id: 'outliner-area',
          value: 'right-top',
        ),
        second: BlenderDockAreaNode<String>(
          id: 'properties-area',
          value: 'right-bottom',
        ),
      ),
    );

const BlenderDockNode<String> _twoDAnimationTemplateLayout =
    BlenderDockSplitNode<String>(
      id: '2d-columns',
      direction: BlenderSplitDirection.horizontal,
      fraction: .83,
      first: BlenderDockSplitNode<String>(
        id: '2d-main-stack',
        direction: BlenderSplitDirection.vertical,
        fraction: .82,
        first: BlenderDockAreaNode<String>(id: 'main-area', value: 'main'),
        second: BlenderDockAreaNode<String>(id: 'bottom-area', value: 'bottom'),
      ),
      second: BlenderDockSplitNode<String>(
        id: '2d-right-stack',
        direction: BlenderSplitDirection.vertical,
        fraction: .18,
        first: BlenderDockAreaNode<String>(
          id: 'outliner-area',
          value: 'right-top',
        ),
        second: BlenderDockAreaNode<String>(
          id: 'properties-area',
          value: 'right-bottom',
        ),
      ),
    );

const BlenderDockNode<String>
_storyboardingTemplateLayout = BlenderDockSplitNode<String>(
  id: 'story-columns',
  direction: BlenderSplitDirection.horizontal,
  fraction: .83,
  first: BlenderDockSplitNode<String>(
    id: 'story-upper-lower',
    direction: BlenderSplitDirection.vertical,
    fraction: .66,
    first: BlenderDockAreaNode<String>(id: 'main-area', value: 'main'),
    second: BlenderDockSplitNode<String>(
      id: 'story-animation-stack',
      direction: BlenderSplitDirection.vertical,
      fraction: .52,
      first: BlenderDockAreaNode<String>(id: 'bottom-area', value: 'bottom'),
      second: BlenderDockAreaNode<String>(
        id: 'story-sequencer-area',
        value: 'story-sequencer',
      ),
    ),
  ),
  second: BlenderDockSplitNode<String>(
    id: 'story-right-stack',
    direction: BlenderSplitDirection.vertical,
    fraction: .18,
    first: BlenderDockAreaNode<String>(id: 'outliner-area', value: 'right-top'),
    second: BlenderDockAreaNode<String>(
      id: 'properties-area',
      value: 'right-bottom',
    ),
  ),
);

const BlenderDockNode<String> _twoDFullCanvasTemplateLayout =
    BlenderDockSplitNode<String>(
      id: '2d-full-stack',
      direction: BlenderSplitDirection.vertical,
      fraction: .91,
      first: BlenderDockAreaNode<String>(id: 'main-area', value: 'main'),
      second: BlenderDockAreaNode<String>(id: 'bottom-area', value: 'bottom'),
    );

const BlenderDockNode<String> _videoEditingTemplateLayout =
    BlenderDockSplitNode<String>(
      id: 'video-columns',
      direction: BlenderSplitDirection.horizontal,
      fraction: .83,
      first: BlenderDockSplitNode<String>(
        id: 'video-preview-sequencer',
        direction: BlenderSplitDirection.vertical,
        fraction: .73,
        first: BlenderDockAreaNode<String>(id: 'main-area', value: 'main'),
        second: BlenderDockAreaNode<String>(
          id: 'story-sequencer-area',
          value: 'story-sequencer',
        ),
      ),
      second: BlenderDockAreaNode<String>(
        id: 'properties-area',
        value: 'right-bottom',
      ),
    );
