part of '../editors.dart';

class BlenderTimelineKeyframe {
  const BlenderTimelineKeyframe(this.frame, {this.color});

  final double frame;
  final Color? color;
}

class BlenderTimelineTrack {
  const BlenderTimelineTrack({
    required this.id,
    required this.label,
    this.keyframes = const <BlenderTimelineKeyframe>[],
  });

  final String id;
  final String label;
  final List<BlenderTimelineKeyframe> keyframes;
}

class BlenderTimelineModel {
  const BlenderTimelineModel({
    required this.start,
    required this.end,
    required this.currentFrame,
    this.tracks = const <BlenderTimelineTrack>[],
    this.dataRevision = 0,
  });

  final double start;
  final double end;
  final double currentFrame;
  final List<BlenderTimelineTrack> tracks;

  /// Increment when mutating track/keyframe collections in place.
  ///
  /// Prefer replacing [tracks] with an immutable list. The revision exists for
  /// high-frequency hosts that retain storage and need to invalidate the
  /// Timeline's prepared keylist without reallocating their whole model.
  final int dataRevision;
}

class _BlenderTimelineRenderTrack {
  const _BlenderTimelineRenderTrack(this.keyframes);

  final List<BlenderTimelineKeyframe> keyframes;
}

/// Prepared animation data shared by the static canvas and channel region.
///
/// Blender's `ChannelDrawList` similarly prepares direct-access key arrays
/// before drawing. This cache is rebuilt only when animation data changes,
/// never when the playhead advances.
class _BlenderTimelineRenderData {
  _BlenderTimelineRenderData._({required this.tracks, required this.labels});

  factory _BlenderTimelineRenderData.fromModel(BlenderTimelineModel model) {
    final tracks = <_BlenderTimelineRenderTrack>[];
    final labels = <String>[];
    for (final track in model.tracks) {
      var sorted = true;
      for (var index = 1; index < track.keyframes.length; index++) {
        if (track.keyframes[index - 1].frame > track.keyframes[index].frame) {
          sorted = false;
          break;
        }
      }
      final keys = sorted
          ? track.keyframes
          : (List<BlenderTimelineKeyframe>.of(track.keyframes)
              ..sort((a, b) => a.frame.compareTo(b.frame)));
      tracks.add(_BlenderTimelineRenderTrack(keys));
      labels.add(track.label);
    }
    return _BlenderTimelineRenderData._(tracks: tracks, labels: labels);
  }

  final List<_BlenderTimelineRenderTrack> tracks;
  final List<String> labels;
}

/// Blender's Timeline window region and optional animation-channel region.
///
/// The native Timeline is a specialized Dope Sheet presentation. Its ruler is
/// a dedicated time-scrub strip, while search and channel names live in a
/// separate region on the left. Keeping those regions here prevents hosts from
/// rebuilding the Timeline as a generic chart (or attaching View3D tools to
/// it).
class BlenderTimeline extends StatefulWidget {
  const BlenderTimeline({
    super.key,
    required this.model,
    required this.onCurrentFrameChanged,
    this.title,
    this.trackHeight = 20,
    this.channelWidth = 240,
    this.showChannels = true,
    this.summaryOnly = true,
    this.viewPaddingFraction = .125,
    this.currentFrameListenable,
  });

  final BlenderTimelineModel model;
  final ValueChanged<double> onCurrentFrameChanged;
  final String? title;
  final double trackHeight;

  /// Width of Blender's independently resizable Channels region.
  final double channelWidth;

  /// Mirrors `SpaceAction.show_region_channels`. Blender hides this region in
  /// a newly created Timeline, but it is visible in the canonical reference
  /// configuration and remains independently toggleable.
  final bool showChannels;

  /// Timeline collapses animation data into Summary; Dope Sheet callers can
  /// set this to false to expose the individual channel rows.
  final bool summaryOnly;

  /// Extra time visible outside the scene range, matching View2D framing.
  final double viewPaddingFraction;

  /// Optional fast-path playhead source.
  ///
  /// When supplied, frame changes repaint only the playhead layer without
  /// rebuilding [BlenderTimeline]. [BlenderPlaybackController] implements this
  /// contract directly.
  final ValueListenable<double>? currentFrameListenable;

  @override
  State<BlenderTimeline> createState() => _BlenderTimelineState();
}

class _BlenderTimelineState extends State<BlenderTimeline> {
  final TextEditingController _searchController = TextEditingController();
  late _BlenderTimelineRenderData _renderData;

  @override
  void initState() {
    super.initState();
    _renderData = _BlenderTimelineRenderData.fromModel(widget.model);
  }

  @override
  void didUpdateWidget(BlenderTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.model.tracks, widget.model.tracks) ||
        oldWidget.model.dataRevision != widget.model.dataRevision) {
      _renderData = _BlenderTimelineRenderData.fromModel(widget.model);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double get _visibleStart {
    final range = math.max(.0001, widget.model.end - widget.model.start);
    return widget.model.start - range * widget.viewPaddingFraction;
  }

  double get _visibleEnd {
    final range = math.max(.0001, widget.model.end - widget.model.start);
    return widget.model.end + range * widget.viewPaddingFraction;
  }

  double _frameForPosition(double width, double x) {
    return _visibleStart +
        (_visibleEnd - _visibleStart) * (x / math.max(1, width));
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final scale = theme.density.interfaceScale;
    final trackHeight = widget.trackHeight * scale;
    final channelWidth = widget.channelWidth * scale;
    final scrubHeight = 28 * scale;
    final rowCount = widget.summaryOnly
        ? 1
        : math.max(1, widget.model.tracks.length);
    final minimumHeight = scrubHeight + rowCount * trackHeight;
    final body = LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.hasBoundedHeight
              ? constraints.maxHeight
              : math.max(64, minimumHeight.toDouble()),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (widget.showChannels)
                RepaintBoundary(
                  child: SizedBox(
                    key: const ValueKey<String>('timeline-channels-region'),
                    width: channelWidth,
                    child: _BlenderTimelineChannels(
                      searchController: _searchController,
                      labels: _renderData.labels,
                      trackHeight: trackHeight,
                      scrubHeight: scrubHeight,
                      summaryOnly: widget.summaryOnly,
                    ),
                  ),
                ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, timelineConstraints) => GestureDetector(
                    key: const ValueKey<String>('timeline-window-region'),
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) => widget.onCurrentFrameChanged(
                      _frameForPosition(
                        timelineConstraints.maxWidth,
                        details.localPosition.dx,
                      ),
                    ),
                    onHorizontalDragUpdate: (details) =>
                        widget.onCurrentFrameChanged(
                          _frameForPosition(
                            timelineConstraints.maxWidth,
                            details.localPosition.dx,
                          ),
                        ),
                    child: Stack(
                      key: const ValueKey<String>('timeline-canvas'),
                      fit: StackFit.expand,
                      children: <Widget>[
                        RepaintBoundary(
                          child: CustomPaint(
                            key: const ValueKey<String>(
                              'timeline-static-canvas',
                            ),
                            painter: _BlenderTimelineStaticPainter(
                              renderData: _renderData,
                              trackHeight: trackHeight,
                              scrubHeight: scrubHeight,
                              colors: theme.colors,
                              textTheme: theme.textTheme,
                              visibleStart: _visibleStart,
                              visibleEnd: _visibleEnd,
                              summaryOnly: widget.summaryOnly,
                            ),
                            isComplex: true,
                            willChange: false,
                          ),
                        ),
                        RepaintBoundary(
                          child: CustomPaint(
                            key: const ValueKey<String>(
                              'timeline-playhead-canvas',
                            ),
                            painter: _BlenderTimelinePlayheadPainter(
                              currentFrame: widget.model.currentFrame,
                              currentFrameListenable:
                                  widget.currentFrameListenable,
                              colors: theme.colors,
                              textTheme: theme.textTheme,
                              visibleStart: _visibleStart,
                              visibleEnd: _visibleEnd,
                              scrubHeight: scrubHeight,
                            ),
                            willChange: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    return BlenderPanel(
      title: widget.title,
      padding: EdgeInsets.zero,
      child: body,
    );
  }
}

class _BlenderTimelineChannels extends StatelessWidget {
  const _BlenderTimelineChannels({
    required this.searchController,
    required this.labels,
    required this.trackHeight,
    required this.scrubHeight,
    required this.summaryOnly,
  });

  final TextEditingController searchController;
  final List<String> labels;
  final double trackHeight;
  final double scrubHeight;
  final bool summaryOnly;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final visibleLabels = summaryOnly ? const <String>['Summary'] : labels;
    return LayoutBuilder(
      builder: (context, constraints) {
        final visibleRowCount = math.min(
          visibleLabels.length,
          math.max(
            0,
            ((constraints.maxHeight - scrubHeight) / trackHeight).ceil(),
          ),
        );
        return DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.canvas,
            border: Border(right: BorderSide(color: theme.colors.border)),
          ),
          // Native regions clip their fixed-height rows when a dock split is
          // collapsed. Only construct rows intersecting this viewport.
          child: ClipRect(
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    key: const ValueKey<String>('timeline-channel-search'),
                    height: scrubHeight,
                    padding: EdgeInsets.fromLTRB(
                      3 * theme.density.interfaceScale,
                      3 * theme.density.interfaceScale,
                      3 * theme.density.interfaceScale,
                      4 * theme.density.interfaceScale,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colors.surface,
                      border: Border(
                        bottom: BorderSide(color: theme.colors.borderSubtle),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: BlenderSearchField(
                            controller: searchController,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const BlenderIconButton(
                          glyph: BlenderGlyph.arrowLeftRight,
                          tooltip: 'Filter channels',
                          size: 21,
                        ),
                      ],
                    ),
                  ),
                ),
                for (var index = 0; index < visibleRowCount; index++)
                  Positioned(
                    top: scrubHeight + index * trackHeight,
                    left: 0,
                    right: 0,
                    child: Container(
                      key: ValueKey<String>('timeline-channel-$index'),
                      height: trackHeight,
                      padding: EdgeInsets.symmetric(
                        horizontal: 5 * theme.density.interfaceScale,
                      ),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: index == 0
                            ? Color.alphaBlend(
                                theme.colors.error.withValues(alpha: .36),
                                theme.colors.canvas,
                              )
                            : theme.colors.canvas,
                        border: Border(
                          bottom: BorderSide(color: theme.colors.borderSubtle),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          const BlenderIcon(
                            BlenderGlyph.panelDisclosureDown,
                            size: 10,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            visibleLabels[index],
                            style: theme.textTheme.caption,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
