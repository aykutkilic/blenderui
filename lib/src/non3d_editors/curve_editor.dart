part of '../non3d_editors.dart';

/// Reusable Graph Editor composed from Blender's Channels, Window, optional
/// Sidebar, and optional Footer regions.
class BlenderCurveEditor extends StatefulWidget {
  const BlenderCurveEditor({
    super.key,
    required this.channels,
    this.channelTree = const <BlenderGraphChannelNode>[],
    this.viewportController,
    this.currentFrame,
    this.currentFrameListenable,
    this.cursor = const Offset(1, 0),
    this.markers = const <BlenderGraphMarker>[],
    this.selectedKeyframes = const <BlenderGraphKeyframeRef>{},
    this.activeChannelId,
    this.onCurrentFrameChanged,
    this.onSelectionChanged,
    this.onKeyframeMoved,
    this.onChannelSelected,
    this.onChannelAction,
    this.contextMenuItems,
    this.onContextMenuSelected,
    this.showChannels = true,
    this.channelWidth = 260,
    this.showCursor = true,
    this.showCursorFrame = false,
    this.showHandles = true,
    this.showOnlySelectedHandles = false,
    this.showExtrapolation = true,
    this.normalize = false,
    this.frameRangeStart,
    this.frameRangeEnd,
    this.sidebar,
    this.sidebarWidth = 240,
    this.footer,
    this.title,
    this.dataRevision = 0,
  });

  final List<BlenderCurveChannel> channels;
  final List<BlenderGraphChannelNode> channelTree;
  final BlenderGraphViewportController? viewportController;
  final double? currentFrame;
  final ValueListenable<double>? currentFrameListenable;
  final Offset cursor;
  final List<BlenderGraphMarker> markers;
  final Set<BlenderGraphKeyframeRef> selectedKeyframes;
  final String? activeChannelId;
  final ValueChanged<double>? onCurrentFrameChanged;
  final ValueChanged<Set<BlenderGraphKeyframeRef>>? onSelectionChanged;
  final ValueChanged<BlenderGraphKeyframeMove>? onKeyframeMoved;
  final ValueChanged<String>? onChannelSelected;
  final ValueChanged<BlenderGraphChannelAction>? onChannelAction;
  final List<BlenderMenuItem<String>>? contextMenuItems;
  final ValueChanged<String>? onContextMenuSelected;
  final bool showChannels;
  final double channelWidth;
  final bool showCursor;
  /// Draw the cursor's vertical time axis, as Blender does in Drivers mode.
  final bool showCursorFrame;
  final bool showHandles;
  final bool showOnlySelectedHandles;
  final bool showExtrapolation;
  final bool normalize;
  final double? frameRangeStart;
  final double? frameRangeEnd;
  final Widget? sidebar;
  final double sidebarWidth;
  final Widget? footer;
  final String? title;

  /// Increment when channel or keyframe collections are mutated in place.
  final int dataRevision;

  @override
  State<BlenderCurveEditor> createState() => _BlenderCurveEditorState();
}

class _BlenderCurveEditorState extends State<BlenderCurveEditor> {
  late BlenderGraphViewportController _viewport;
  late bool _ownsViewport;

  @override
  void initState() {
    super.initState();
    _attachViewport(widget.viewportController);
  }

  @override
  void didUpdateWidget(BlenderCurveEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewportController != widget.viewportController) {
      if (_ownsViewport) _viewport.dispose();
      _attachViewport(widget.viewportController);
    }
  }

  void _attachViewport(BlenderGraphViewportController? supplied) {
    _ownsViewport = supplied == null;
    _viewport = supplied ?? BlenderGraphViewportController();
  }

  @override
  void dispose() {
    if (_ownsViewport) _viewport.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvas = BlenderPanel(
      title: widget.title,
      padding: EdgeInsets.zero,
      child: _BlenderGraphCanvas(
        channels: widget.channels,
        viewport: _viewport,
        currentFrame: widget.currentFrame,
        currentFrameListenable: widget.currentFrameListenable,
        cursor: widget.cursor,
        markers: widget.markers,
        selectedKeyframes: widget.selectedKeyframes,
        activeChannelId: widget.activeChannelId,
        onCurrentFrameChanged: widget.onCurrentFrameChanged,
        onSelectionChanged: widget.onSelectionChanged,
        onKeyframeMoved: widget.onKeyframeMoved,
        contextMenuItems: widget.contextMenuItems,
        onContextMenuSelected: widget.onContextMenuSelected,
        showCursor: widget.showCursor,
        showCursorFrame: widget.showCursorFrame,
        showHandles: widget.showHandles,
        showOnlySelectedHandles: widget.showOnlySelectedHandles,
        showExtrapolation: widget.showExtrapolation,
        normalize: widget.normalize,
        frameRangeStart: widget.frameRangeStart,
        frameRangeEnd: widget.frameRangeEnd,
        dataRevision: widget.dataRevision,
      ),
    );
    final graphAndChannels = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (widget.showChannels)
          SizedBox(
            key: const ValueKey<String>('graph-channels-region'),
            width: widget.channelWidth,
            child: BlenderGraphChannelsRegion(
              channels: widget.channels,
              roots: widget.channelTree,
              activeChannelId: widget.activeChannelId,
              onChannelSelected: widget.onChannelSelected,
              onAction: widget.onChannelAction,
            ),
          ),
        Expanded(
          child: KeyedSubtree(
            key: const ValueKey<String>('graph-window-region'),
            child: canvas,
          ),
        ),
      ],
    );
    final content = widget.sidebar == null
        ? graphAndChannels
        : Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(child: graphAndChannels),
              SizedBox(width: widget.sidebarWidth, child: widget.sidebar),
            ],
          );
    if (widget.footer == null) return content;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: content),
        widget.footer!,
      ],
    );
  }
}
