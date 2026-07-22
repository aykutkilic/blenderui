import 'dart:math' as math;

import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

import 'editor_views.dart';

class DawEditorHeader extends StatelessWidget {
  const DawEditorHeader({
    super.key,
    required this.title,
    this.menus = const <String>['View', 'Select'],
    this.actions = const <Widget>[],
    this.leading = const <Widget>[],
    this.onMenuSelected,
  });

  final String title;
  final List<String> menus;
  final List<Widget> actions;
  final List<Widget> leading;
  final ValueChanged<String>? onMenuSelected;

  @override
  Widget build(BuildContext context) {
    final area = DawEditorAreaScope.maybeOf(context);
    return BlenderAreaHeader(
      editorType: BlenderEditorType.timeline,
      showEditorLabel: false,
      editorSelectorWidth: 30,
      editorSelector: area == null
          ? Center(child: BlenderIcon(_glyphForTitle(title), size: 15))
          : DawEditorViewSelector(
              value: area.view,
              onChanged: area.onViewSelected,
            ),
      leading: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(title, style: BlenderTheme.of(context).textTheme.label),
        ),
        ...leading,
      ],
      menus: <Widget>[
        for (final menu in menus)
          BlenderButton(
            label: menu,
            variant: BlenderButtonVariant.menu,
            onPressed: onMenuSelected == null
                ? null
                : () => onMenuSelected!(menu),
          ),
      ],
      actions: actions,
      actionsScrollable: true,
    );
  }
}

BlenderGlyph _glyphForTitle(String title) {
  final normalized = title.toLowerCase();
  if (normalized.contains('mixer')) return BlenderGlyph.speaker;
  if (normalized.contains('piano') || normalized.contains('midi')) {
    return BlenderGlyph.action;
  }
  if (normalized.contains('wave')) return BlenderGlyph.speaker;
  if (normalized.contains('plugin')) return BlenderGlyph.node;
  if (normalized.contains('automation')) return BlenderGlyph.curve;
  return BlenderGlyph.sequence;
}

double dawBeatForX(double x, double pixelsPerBeat) =>
    math.max(0, x / math.max(1, pixelsPerBeat));

void paintDawTimeGrid(
  Canvas canvas,
  Size size, {
  required double pixelsPerBeat,
  required int beatsPerBar,
  required BlenderColorScheme colors,
  double startY = 0,
  double subdivision = .25,
}) {
  final minor = Paint()
    ..color = colors.borderSubtle.withValues(alpha: .35)
    ..strokeWidth = 1;
  final beat = Paint()
    ..color = colors.borderSubtle.withValues(alpha: .65)
    ..strokeWidth = 1;
  final bar = Paint()
    ..color = colors.border
    ..strokeWidth = 1;
  final step = pixelsPerBeat * subdivision;
  final count = (size.width / math.max(1, step)).ceil();
  for (var index = 0; index <= count; index++) {
    final x = index * step;
    final beatIndex = index * subdivision;
    final wholeBeat = (beatIndex - beatIndex.round()).abs() < .0001;
    final wholeBar = wholeBeat && beatIndex.round() % beatsPerBar == 0;
    canvas.drawLine(
      Offset(x, startY),
      Offset(x, size.height),
      wholeBar ? bar : (wholeBeat ? beat : minor),
    );
  }
}

void paintDawPlayhead(
  Canvas canvas,
  Size size, {
  required double beat,
  required double pixelsPerBeat,
  required Color color,
}) {
  final x = beat * pixelsPerBeat;
  canvas.drawLine(
    Offset(x, 0),
    Offset(x, size.height),
    Paint()
      ..color = color
      ..strokeWidth = 2,
  );
  final marker = Path()
    ..moveTo(x - 5, 0)
    ..lineTo(x + 5, 0)
    ..lineTo(x, 7)
    ..close();
  canvas.drawPath(marker, Paint()..color = color);
}
