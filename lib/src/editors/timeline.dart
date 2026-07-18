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
  });

  final double start;
  final double end;
  final double currentFrame;
  final List<BlenderTimelineTrack> tracks;
}

class BlenderTimeline extends StatelessWidget {
  const BlenderTimeline({
    super.key,
    required this.model,
    required this.onCurrentFrameChanged,
    this.title = 'Timeline',
    this.trackHeight = 24,
  });

  final BlenderTimelineModel model;
  final ValueChanged<double> onCurrentFrameChanged;
  final String? title;
  final double trackHeight;

  double _frameForPosition(double width, double x) {
    return model.start + (model.end - model.start) * (x / math.max(1, width));
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final height = math
        .max(64, model.tracks.length * trackHeight + 28)
        .toDouble();
    return BlenderPanel(
      title: title,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => onCurrentFrameChanged(
              _frameForPosition(constraints.maxWidth, details.localPosition.dx),
            ),
            onHorizontalDragUpdate: (details) => onCurrentFrameChanged(
              _frameForPosition(constraints.maxWidth, details.localPosition.dx),
            ),
            child: SizedBox(
              height: height,
              child: CustomPaint(
                painter: _BlenderTimelinePainter(
                  model: model,
                  trackHeight: trackHeight,
                  colors: theme.colors,
                  textTheme: theme.textTheme,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
