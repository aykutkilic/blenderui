part of '../specialized_templates.dart';

/// A resizable material/texture preview property pane matching Blender's
/// `template_preview()` composition.
class BlenderPreviewPanel extends StatefulWidget {
  const BlenderPreviewPanel({
    super.key,
    required this.preview,
    this.title = 'Preview',
    this.height = 150,
    this.minHeight = 72,
    this.maxHeight = 360,
    this.previewModes = const <BlenderMenuItem<String>>[],
    this.previewMode,
    this.onPreviewModeChanged,
    this.usePreviewWorld = false,
    this.onUsePreviewWorldChanged,
    this.textureModes = const <BlenderMenuItem<String>>[],
    this.textureMode,
    this.onTextureModeChanged,
    this.usePreviewAlpha = false,
    this.onUsePreviewAlphaChanged,
  });

  final Widget preview;
  final String title;
  final double height;
  final double minHeight;
  final double maxHeight;
  final List<BlenderMenuItem<String>> previewModes;
  final String? previewMode;
  final ValueChanged<String>? onPreviewModeChanged;
  final bool usePreviewWorld;
  final ValueChanged<bool>? onUsePreviewWorldChanged;
  final List<BlenderMenuItem<String>> textureModes;
  final String? textureMode;
  final ValueChanged<String>? onTextureModeChanged;
  final bool usePreviewAlpha;
  final ValueChanged<bool>? onUsePreviewAlphaChanged;

  @override
  State<BlenderPreviewPanel> createState() => _BlenderPreviewPanelState();
}

class _BlenderPreviewPanelState extends State<BlenderPreviewPanel> {
  late double _height;

  @override
  void initState() {
    super.initState();
    _height = widget.height.clamp(widget.minHeight, widget.maxHeight);
  }

  @override
  void didUpdateWidget(BlenderPreviewPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.height != widget.height ||
        oldWidget.minHeight != widget.minHeight ||
        oldWidget.maxHeight != widget.maxHeight) {
      _height = widget.height.clamp(widget.minHeight, widget.maxHeight);
    }
  }

  void _resize(double delta) {
    setState(() {
      _height = (_height + delta).clamp(widget.minHeight, widget.maxHeight);
    });
  }

  Widget _previewSurface(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.textField,
        border: Border.all(color: theme.colors.editorBorder),
        borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
      ),
      child: SizedBox(
        height: _height,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Center(child: widget.preview),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (details) => _resize(details.delta.dy),
                child: SizedBox(
                  height: 10,
                  child: Center(
                    child: BlenderIcon(
                      BlenderGlyph.dragHandle,
                      size: 10,
                      color: theme.colors.foregroundMuted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controls(BuildContext context) {
    final children = <Widget>[
      if (widget.previewModes.isNotEmpty && widget.previewMode != null)
        BlenderSegmentedControl<String>(
          value: widget.previewMode!,
          items: widget.previewModes,
          expanded: true,
          onChanged: widget.onPreviewModeChanged ?? (_) {},
        ),
      if (widget.onUsePreviewWorldChanged != null)
        BlenderCheckbox(
          value: widget.usePreviewWorld,
          label: 'Use Preview World',
          onChanged: widget.onUsePreviewWorldChanged,
        ),
      if (widget.textureModes.isNotEmpty && widget.textureMode != null)
        BlenderSegmentedControl<String>(
          value: widget.textureMode!,
          items: widget.textureModes,
          expanded: true,
          onChanged: widget.onTextureModeChanged ?? (_) {},
        ),
      if (widget.onUsePreviewAlphaChanged != null)
        BlenderCheckbox(
          value: widget.usePreviewAlpha,
          label: 'Use Preview Alpha',
          onChanged: widget.onUsePreviewAlphaChanged,
        ),
    ];
    return SizedBox(
      width: 230,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (var index = 0; index < children.length; index++) ...<Widget>[
            if (index > 0) const SizedBox(height: 5),
            children[index],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlenderPanel(
      title: widget.title,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: _previewSurface(context)),
          if (widget.previewModes.isNotEmpty ||
              widget.textureModes.isNotEmpty ||
              widget.onUsePreviewWorldChanged != null ||
              widget.onUsePreviewAlphaChanged != null) ...<Widget>[
            const SizedBox(width: 6),
            _controls(context),
          ],
        ],
      ),
    );
  }
}
