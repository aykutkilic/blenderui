import 'dart:math' as math;

import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

import '../controllers/session_controller.dart';
import '../model/project.dart';
import 'editor_shared.dart';

class DawWaveEditor extends StatefulWidget {
  const DawWaveEditor({super.key, required this.session, this.clip});

  final DawSessionController session;
  final DawAudioClip? clip;

  @override
  State<DawWaveEditor> createState() => _DawWaveEditorState();
}

class _DawWaveEditorState extends State<DawWaveEditor> {
  double? _selectionStart;
  double? _selectionEnd;

  DawAudioClip? get _clip {
    if (widget.clip case final clip?) return clip;
    final selected = widget.session.selectedClip;
    return selected is DawAudioClip ? selected : null;
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.session,
    builder: (context, _) {
      final clip = _clip;
      return BlenderEditorFrame(
        child: Column(
          children: <Widget>[
            DawEditorHeader(
              title: 'Wave Editor',
              menus: const <String>['View', 'Select', 'Process', 'Markers'],
              actions: <Widget>[
                BlenderButton(
                  label: 'Normalize',
                  enabled: clip != null,
                  onPressed: clip == null
                      ? null
                      : () => widget.session.normalizeAudioClip(clip.id),
                ),
                BlenderButton(
                  label: 'Reverse',
                  enabled: clip != null,
                  selected: clip?.reversed ?? false,
                  onPressed: clip == null
                      ? null
                      : () => widget.session.toggleAudioClipReverse(clip.id),
                ),
                BlenderButton(
                  label: 'Fade In',
                  enabled: clip != null,
                  selected: (clip?.fadeInBeats ?? 0) > 0,
                  onPressed: clip == null
                      ? null
                      : () => widget.session.setAudioClipFades(
                          clip.id,
                          fadeInBeats: _selectionLength(clip),
                        ),
                ),
                BlenderButton(
                  label: 'Fade Out',
                  enabled: clip != null,
                  selected: (clip?.fadeOutBeats ?? 0) > 0,
                  onPressed: clip == null
                      ? null
                      : () => widget.session.setAudioClipFades(
                          clip.id,
                          fadeOutBeats: _selectionLength(clip),
                        ),
                ),
              ],
            ),
            Expanded(
              child: clip == null
                  ? const Center(
                      child: Text('Select an audio clip in Arrangement'),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) => GestureDetector(
                        key: const ValueKey<String>('daw-wave-editor-canvas'),
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) => widget.session.playback.seek(
                          clip.startBeat +
                              details.localPosition.dx /
                                  math.max(1, constraints.maxWidth) *
                                  clip.lengthBeats,
                        ),
                        onHorizontalDragStart: (details) => setState(() {
                          _selectionStart =
                              details.localPosition.dx /
                              math.max(1, constraints.maxWidth);
                          _selectionEnd = _selectionStart;
                        }),
                        onHorizontalDragUpdate: (details) => setState(() {
                          _selectionEnd =
                              (details.localPosition.dx /
                                      math.max(1, constraints.maxWidth))
                                  .clamp(0, 1);
                        }),
                        child: CustomPaint(
                          painter: _DawWavePainter(
                            clip: clip,
                            playheadBeat: widget.session.playback.currentFrame,
                            selectionStart: _selectionStart,
                            selectionEnd: _selectionEnd,
                            colors: BlenderTheme.of(context).colors,
                            textTheme: BlenderTheme.of(context).textTheme,
                          ),
                          size: Size.infinite,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      );
    },
  );

  double _selectionLength(DawAudioClip clip) {
    final start = _selectionStart;
    final end = _selectionEnd;
    if (start == null || end == null) return math.min(1, clip.lengthBeats);
    return (end - start).abs() * clip.lengthBeats;
  }
}

class _DawWavePainter extends CustomPainter {
  const _DawWavePainter({
    required this.clip,
    required this.playheadBeat,
    required this.selectionStart,
    required this.selectionEnd,
    required this.colors,
    required this.textTheme,
  });

  final DawAudioClip clip;
  final double playheadBeat;
  final double? selectionStart;
  final double? selectionEnd;
  final BlenderColorScheme colors;
  final BlenderTextTheme textTheme;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.canvas);
    const rulerHeight = 28.0;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, rulerHeight),
      Paint()..color = colors.panelHeader,
    );
    for (var beat = 0; beat <= clip.lengthBeats.ceil(); beat++) {
      final x = beat / clip.lengthBeats * size.width;
      canvas.drawLine(
        Offset(x, rulerHeight),
        Offset(x, size.height),
        Paint()..color = colors.borderSubtle,
      );
      final label = TextPainter(
        text: TextSpan(text: '$beat', style: textTheme.caption),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(x + 3, 7));
    }
    if (selectionStart != null && selectionEnd != null) {
      final left = math.min(selectionStart!, selectionEnd!) * size.width;
      final right = math.max(selectionStart!, selectionEnd!) * size.width;
      canvas.drawRect(
        Rect.fromLTRB(left, rulerHeight, right, size.height),
        Paint()..color = colors.selection.withValues(alpha: .45),
      );
    }
    final peaks = clip.waveform.peaks;
    final center = (size.height + rulerHeight) / 2;
    final availableHeight = (size.height - rulerHeight) * .44;
    final path = Path();
    for (var x = 0; x < size.width.floor(); x++) {
      final index = (x / math.max(1, size.width) * peaks.length)
          .floor()
          .clamp(0, math.max(0, peaks.length - 1))
          .toInt();
      final amplitude = peaks.isEmpty
          ? 0.0
          : peaks[index].abs() * availableHeight * clip.gain;
      path.moveTo(x.toDouble(), center - amplitude);
      path.lineTo(x.toDouble(), center + amplitude);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Color(clip.colorValue)
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(0, center),
      Offset(size.width, center),
      Paint()..color = colors.border,
    );
    final localPlayhead = playheadBeat - clip.startBeat;
    if (localPlayhead >= 0 && localPlayhead <= clip.lengthBeats) {
      paintDawPlayhead(
        canvas,
        size,
        beat: localPlayhead,
        pixelsPerBeat: size.width / clip.lengthBeats,
        color: colors.cursor,
      );
    }
  }

  @override
  bool shouldRepaint(_DawWavePainter oldDelegate) =>
      clip != oldDelegate.clip ||
      playheadBeat != oldDelegate.playheadBeat ||
      selectionStart != oldDelegate.selectionStart ||
      selectionEnd != oldDelegate.selectionEnd ||
      colors != oldDelegate.colors;
}
