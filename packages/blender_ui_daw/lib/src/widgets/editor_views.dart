import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

enum DawEditorView {
  arrangement('arrangement', 'Arrangement', BlenderGlyph.sequence),
  pianoRoll('piano-roll', 'Piano Roll', BlenderGlyph.action),
  wave('wave', 'Wave Editor', BlenderGlyph.speaker),
  automation('automation', 'Automation', BlenderGlyph.curve),
  mixer('mixer', 'Mixer', BlenderGlyph.volume),
  pluginBrowser('plugin-browser', 'Plug-in Browser', BlenderGlyph.folder),
  pluginRack('plugin-rack', 'Plug-in Rack', BlenderGlyph.node),
  effectChain('effect-chain', 'Effect Chain', BlenderGlyph.modifier),
  audioGraph('audio-graph', 'Audio Routing', BlenderGlyph.node);

  const DawEditorView(this.id, this.label, this.glyph);

  final String id;
  final String label;
  final BlenderGlyph glyph;
}

final BlenderEditorViewCodec<DawEditorView> dawEditorViewCodec =
    BlenderEditorViewCodec<DawEditorView>(
      encode: (value) => value.id,
      decode: (id) {
        for (final value in DawEditorView.values) {
          if (value.id == id) return value;
        }
        return null;
      },
    );

class DawEditorAreaScope extends InheritedWidget {
  const DawEditorAreaScope({
    super.key,
    required this.view,
    required this.onViewSelected,
    required super.child,
  });

  final DawEditorView view;
  final ValueChanged<DawEditorView> onViewSelected;

  static DawEditorAreaScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DawEditorAreaScope>();

  @override
  bool updateShouldNotify(DawEditorAreaScope oldWidget) =>
      oldWidget.view != view || oldWidget.onViewSelected != onViewSelected;
}

class DawEditorViewSelector extends StatefulWidget {
  const DawEditorViewSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DawEditorView value;
  final ValueChanged<DawEditorView> onChanged;

  @override
  State<DawEditorViewSelector> createState() => _DawEditorViewSelectorState();
}

class _DawEditorViewSelectorState extends State<DawEditorViewSelector> {
  bool _open = false;

  @override
  Widget build(BuildContext context) => BlenderPopover(
    key: const ValueKey<String>('daw-editor-view-selector'),
    onOpenChanged: (value) => setState(() => _open = value),
    child: IgnorePointer(
      child: BlenderIconButton(
        glyph: widget.value.glyph,
        tooltip: widget.value.label,
        selected: _open,
        size: 28,
      ),
    ),
    popover: (context, close) => SizedBox(
      width: 230,
      child: BlenderMenu<DawEditorView>(
        title: 'Editor Type',
        items: <BlenderMenuItem<DawEditorView>>[
          for (final view in DawEditorView.values)
            BlenderMenuItem<DawEditorView>(
              value: view,
              label: view.label,
              selected: view == widget.value,
              icon: BlenderIcon(view.glyph),
            ),
        ],
        onSelected: (item) {
          widget.onChanged(item.value);
          close();
        },
      ),
    ),
  );
}
