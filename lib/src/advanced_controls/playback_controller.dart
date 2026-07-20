part of '../advanced_controls.dart';

/// Reusable owner for the fast-changing playback state shared by animation
/// headers, footers, and editor canvases.
///
/// The controller deliberately does not run a timer or evaluate animation.
/// Applications retain those policies while BlenderUI provides consistent
/// seeking, bounded stepping, range updates, and narrow listenable rebuilds.
class BlenderPlaybackController extends ChangeNotifier
    implements ValueListenable<double> {
  BlenderPlaybackController({
    double initialFrame = 1,
    double rangeStart = 1,
    double rangeEnd = 250,
    bool playing = false,
    bool recording = false,
  }) : assert(rangeStart <= rangeEnd),
       _currentFrame = initialFrame,
       _rangeStart = rangeStart,
       _rangeEnd = rangeEnd,
       _playing = playing,
       _recording = recording;

  double _currentFrame;
  double _rangeStart;
  double _rangeEnd;
  bool _playing;
  bool _recording;

  @override
  double get value => _currentFrame;
  double get currentFrame => _currentFrame;
  double get rangeStart => _rangeStart;
  double get rangeEnd => _rangeEnd;
  bool get playing => _playing;
  bool get recording => _recording;

  /// Seeks without clamping by default, matching Blender's ability to place
  /// the playhead outside the scene range in a padded View2D.
  void seek(double frame, {bool clampToRange = false}) {
    final next = clampToRange
        ? frame.clamp(_rangeStart, _rangeEnd).toDouble()
        : frame;
    if (_currentFrame == next) return;
    _currentFrame = next;
    notifyListeners();
  }

  /// Moves by [frames] and clamps to the configured playback range.
  void step(double frames) => seek(_currentFrame + frames, clampToRange: true);

  void stepBackward([double frames = 1]) => step(-frames.abs());
  void stepForward([double frames = 1]) => step(frames.abs());
  void jumpToStart() => seek(_rangeStart);
  void jumpToEnd() => seek(_rangeEnd);

  void setPlaying(bool value) {
    if (_playing == value) return;
    _playing = value;
    notifyListeners();
  }

  void togglePlaying() => setPlaying(!_playing);

  void setRecording(bool value) {
    if (_recording == value) return;
    _recording = value;
    notifyListeners();
  }

  void toggleRecording() => setRecording(!_recording);

  /// Updates the scene/preview range and optionally brings the playhead back
  /// inside it. One notification covers the complete atomic update.
  void setRange(double start, double end, {bool clampCurrentFrame = true}) {
    assert(start <= end);
    final nextFrame = clampCurrentFrame
        ? _currentFrame.clamp(start, end).toDouble()
        : _currentFrame;
    if (_rangeStart == start &&
        _rangeEnd == end &&
        _currentFrame == nextFrame) {
      return;
    }
    _rangeStart = start;
    _rangeEnd = end;
    _currentFrame = nextFrame;
    notifyListeners();
  }
}

typedef BlenderPlaybackWidgetBuilder =
    Widget Function(
      BuildContext context,
      BlenderPlaybackController controller,
      Widget? child,
    );

/// Rebuilds only playback-dependent UI below this point.
class BlenderPlaybackBuilder extends StatelessWidget {
  const BlenderPlaybackBuilder({
    super.key,
    required this.controller,
    required this.builder,
    this.child,
  });

  final BlenderPlaybackController controller;
  final BlenderPlaybackWidgetBuilder builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    child: child,
    builder: (context, child) => builder(context, controller, child),
  );
}
