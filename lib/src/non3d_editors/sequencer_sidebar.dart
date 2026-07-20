part of '../non3d_editors.dart';

/// Source-shaped Sequencer and NLA sidebar panels from `space_sequencer.py`
/// and `space_nla.py`.
///
/// This is a visual hierarchy only. Media caching, proxy generation, strip
/// evaluation, and animation data remain owned by the embedding application.
class BlenderSequencerSidebar extends StatelessWidget {
  const BlenderSequencerSidebar({super.key, this.nlaEditor = false});

  final bool nlaEditor;

  @override
  Widget build(BuildContext context) {
    final panels = nlaEditor
        ? <Widget>[
            BlenderStaticPropertyField.panel('Strip', <Widget>[
              BlenderStaticPropertyField.panel('Action', <Widget>[
                BlenderStaticPropertyField.menu(
                  'Action',
                  'Walk Cycle',
                  <String>['Walk Cycle', 'Idle', 'None'],
                ),
                BlenderStaticPropertyField.number('Frame Start', 1),
                BlenderStaticPropertyField.number('Frame End', 120),
                BlenderStaticPropertyField.checkbox('Use Frame Range'),
                BlenderStaticPropertyField.checkbox('Cyclic'),
              ], expanded: true),
              BlenderStaticPropertyField.panel('Slot', <Widget>[
                BlenderStaticPropertyField.menu('Name', 'Walk Cycle', <String>[
                  'Walk Cycle',
                  'None',
                ]),
                BlenderStaticPropertyField.menu('Type', 'Object', <String>[
                  'Object',
                  'World',
                  'Scene',
                ]),
              ]),
            ], expanded: true),
          ]
        : <Widget>[
            BlenderStaticPropertyField.panel('Active Tool', <Widget>[
              BlenderStaticPropertyField.menu('Tool', 'Select', <String>[
                'Select',
                'Move',
                'Trim',
              ]),
              BlenderStaticPropertyField.checkbox('Transform Gizmo'),
            ], expanded: true),
            BlenderStaticPropertyField.panel('Cache Settings', <Widget>[
              BlenderStaticPropertyField.checkbox('Prefetch'),
              BlenderStaticPropertyField.checkbox('Raw'),
              BlenderStaticPropertyField.checkbox('Final'),
              BlenderStaticPropertyField.panel('Display', <Widget>[
                BlenderStaticPropertyField.checkbox('Raw', value: false),
                BlenderStaticPropertyField.checkbox('Final', value: true),
                BlenderStaticPropertyField.number('Current Cache Size', 128),
              ]),
            ], expanded: true),
            BlenderStaticPropertyField.panel('Proxy Settings', <Widget>[
              BlenderStaticPropertyField.menu('Storage', 'Project', <String>[
                'Project',
                'Per Strip',
              ]),
              BlenderStaticPropertyField.menu(
                'Directory',
                '/project/proxy',
                <String>['/project/proxy', '/tmp/proxy'],
              ),
              const BlenderButton(label: 'Enable Proxies', onPressed: _noop),
              const SizedBox(height: 4),
              const BlenderButton(label: 'Rebuild Proxy', onPressed: _noop),
              BlenderStaticPropertyField.panel('Strip Proxy', <Widget>[
                BlenderStaticPropertyField.checkbox('Use Proxy', value: false),
                BlenderStaticPropertyField.menu('Resolutions', '50%', <String>[
                  '25%',
                  '50%',
                  '75%',
                  '100%',
                ]),
                BlenderStaticPropertyField.number('Quality', 90),
              ]),
            ]),
            BlenderStaticPropertyField.panel('View', <Widget>[
              BlenderStaticPropertyField.panel('Scene Strip Display', <Widget>[
                BlenderStaticPropertyField.menu(
                  'Shading',
                  'Material Preview',
                  <String>['Solid', 'Wireframe', 'Material Preview'],
                ),
              ]),
              BlenderStaticPropertyField.panel('View Settings', <Widget>[
                BlenderStaticPropertyField.menu(
                  'Proxy Render Size',
                  'Scene',
                  <String>['None', 'Scene', '25%', '50%'],
                ),
                BlenderStaticPropertyField.checkbox(
                  'Use Proxies',
                  value: false,
                ),
                BlenderStaticPropertyField.number('Channel', 1),
                BlenderStaticPropertyField.checkbox(
                  'Missing Media',
                  value: false,
                ),
              ]),
              BlenderStaticPropertyField.panel('2D Cursor', <Widget>[
                BlenderStaticPropertyField.number('X', 0),
                BlenderStaticPropertyField.number('Y', 0),
              ]),
              BlenderStaticPropertyField.panel('Frame Overlay', <Widget>[
                BlenderStaticPropertyField.checkbox(
                  'Show Overlay Frame',
                  value: false,
                ),
                BlenderStaticPropertyField.number('Frame Offset', 0),
                BlenderStaticPropertyField.checkbox(
                  'Lock Overlay',
                  value: false,
                ),
              ]),
              BlenderStaticPropertyField.panel('Safe Areas', <Widget>[
                BlenderStaticPropertyField.checkbox(
                  'Show Safe Areas',
                  value: false,
                ),
                BlenderStaticPropertyField.number('Title', .8),
                BlenderStaticPropertyField.number('Action', .9),
                BlenderStaticPropertyField.panel(
                  'Center-Cut Safe Areas',
                  <Widget>[
                    BlenderStaticPropertyField.checkbox(
                      'Show Center-Cut',
                      value: false,
                    ),
                    BlenderStaticPropertyField.number('Title Center', .8),
                    BlenderStaticPropertyField.number('Action Center', .9),
                  ],
                ),
              ]),
              BlenderStaticPropertyField.panel('Composition Guides', <Widget>[
                BlenderStaticPropertyField.checkbox('Thirds', value: false),
                BlenderStaticPropertyField.checkbox('Center', value: false),
                BlenderStaticPropertyField.checkbox('Diagonal', value: false),
              ]),
              const BlenderAnnotationSettingsPanel(
                state: BlenderAnnotationSettings(visible: false),
              ),
            ], expanded: true),
            BlenderStaticPropertyField.panel('Strip', <Widget>[
              BlenderStaticPropertyField.panel('Custom Properties', <Widget>[
                BlenderStaticPropertyField.number('example_value', 1),
              ], expanded: true),
            ]),
          ];
    return ListView(padding: const EdgeInsets.all(6), children: panels);
  }
}

class _BlenderSequencerPainter extends CustomPainter {
  _BlenderSequencerPainter({
    required this.strips,
    required this.start,
    required this.end,
    required this.selectedId,
    required this.colors,
    required this.textTheme,
    required this.showSeconds,
    required this.framesPerSecond,
  });

  final List<BlenderSequencerStrip> strips;
  final double start;
  final double end;
  final String? selectedId;
  final BlenderColorScheme colors;
  final BlenderTextTheme textTheme;
  final bool showSeconds;
  final double framesPerSecond;

  @override
  void paint(Canvas canvas, Size size) {
    final range = math.max(.0001, end - start).toDouble();
    const header = 28.0;
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.canvas);
    final grid = Paint()
      ..color = colors.borderSubtle
      ..strokeWidth = 1;
    for (var frame = start.ceilToDouble(); frame <= end; frame += 10) {
      final x = (frame - start) / range * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
      final text = TextPainter(
        text: TextSpan(
          text: showSeconds
              ? _formatSeconds(frame / math.max(.001, framesPerSecond))
              : frame.toStringAsFixed(0),
          style: textTheme.caption.copyWith(color: colors.foregroundMuted),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(x + 2, 5));
    }
    canvas.drawLine(const Offset(0, header), Offset(size.width, header), grid);
    for (final strip in strips) {
      final y = header + strip.channel * 28.0 + 3;
      final left = ((strip.start - start) / range * size.width)
          .clamp(0, size.width)
          .toDouble();
      final right = ((strip.end - start) / range * size.width)
          .clamp(0, size.width)
          .toDouble();
      final rect = Rect.fromLTRB(
        left,
        y,
        math.max(left + 4, right).toDouble(),
        y + 21,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()
          ..color = strip.muted
              ? colors.foregroundDisabled
              : strip.color ?? _stripColor(strip.type),
      );
      if (strip.showWaveform && rect.width > 20) {
        final waveform = Paint()
          ..color = colors.foreground.withValues(alpha: .5)
          ..strokeWidth = 1;
        final center = rect.center.dy;
        for (var x = rect.left + 5; x < rect.right - 5; x += 4) {
          final amplitude = 2 + ((x - rect.left) % 11) * .35;
          canvas.drawLine(
            Offset(x, center - amplitude),
            Offset(x, center + amplitude),
            waveform,
          );
        }
      }
      if (strip.showHandles && rect.width > 12) {
        final handle = Paint()
          ..color = colors.foreground.withValues(alpha: .65)
          ..strokeWidth = 2;
        canvas.drawLine(
          Offset(rect.left + 3, rect.top + 3),
          Offset(rect.left + 3, rect.bottom - 3),
          handle,
        );
        canvas.drawLine(
          Offset(rect.right - 3, rect.top + 3),
          Offset(rect.right - 3, rect.bottom - 3),
          handle,
        );
      }
      final text = TextPainter(
        text: TextSpan(
          text: strip.label,
          style: textTheme.caption.copyWith(color: colors.foreground),
        ),
        textDirection: TextDirection.ltr,
        ellipsis: '…',
      )..layout(maxWidth: math.max(0, rect.width - 8));
      text.paint(canvas, Offset(rect.left + 4, rect.top + 4));
      if (strip.id == selectedId) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          Paint()
            ..color = colors.focus
            ..style = PaintingStyle.stroke,
        );
      }
    }
  }

  Color _stripColor(BlenderSequencerStripType type) => switch (type) {
    BlenderSequencerStripType.movie => const Color(0xFF6B67B7),
    BlenderSequencerStripType.image => const Color(0xFF6E73A8),
    BlenderSequencerStripType.sound => const Color(0xFF3E8B62),
    BlenderSequencerStripType.scene => const Color(0xFF7B6797),
    BlenderSequencerStripType.color => const Color(0xFFB08C47),
    BlenderSequencerStripType.effect => const Color(0xFF8F5E82),
    BlenderSequencerStripType.transition => const Color(0xFF8A6262),
  };

  String _formatSeconds(double seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds - minutes * 60;
    return '$minutes:${remainder.toStringAsFixed(1).padLeft(4, '0')}';
  }

  @override
  bool shouldRepaint(_BlenderSequencerPainter oldDelegate) {
    return strips != oldDelegate.strips ||
        start != oldDelegate.start ||
        end != oldDelegate.end ||
        selectedId != oldDelegate.selectedId ||
        showSeconds != oldDelegate.showSeconds ||
        framesPerSecond != oldDelegate.framesPerSecond ||
        colors != oldDelegate.colors;
  }
}

class _BlenderSequencerPlayheadPainter extends CustomPainter {
  _BlenderSequencerPlayheadPainter({
    required this.start,
    required this.end,
    required this.currentFrame,
    required this.currentFrameListenable,
    required this.colors,
  }) : super(repaint: currentFrameListenable);

  final double start;
  final double end;
  final double? currentFrame;
  final ValueListenable<double>? currentFrameListenable;
  final BlenderColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = currentFrameListenable?.value ?? currentFrame;
    if (frame == null) return;
    final range = math.max(.0001, end - start);
    final x = (frame - start) / range * size.width;
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height),
      Paint()
        ..color = colors.focus
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_BlenderSequencerPlayheadPainter oldDelegate) =>
      start != oldDelegate.start ||
      end != oldDelegate.end ||
      currentFrameListenable != oldDelegate.currentFrameListenable ||
      (currentFrameListenable == null &&
          currentFrame != oldDelegate.currentFrame) ||
      colors != oldDelegate.colors;
}
