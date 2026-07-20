part of '../layout.dart';

class BlenderAreaHeader extends StatelessWidget {
  const BlenderAreaHeader({
    super.key,
    required this.editorType,
    this.onEditorTypeChanged,
    this.menus = const <Widget>[],
    this.menuDescriptors = const [],
    this.leading = const <Widget>[],
    this.actions = const <Widget>[],
    this.center,
    this.background,
    this.height,
    this.showEditorLabel = true,
    this.editorSelectorWidth,
    this.editorSelector,
    this.showBottomBorder = true,
    this.actionsScrollable = false,
  });

  final BlenderEditorType editorType;
  final ValueChanged<BlenderEditorType>? onEditorTypeChanged;
  final List<Widget> menus;
  final List<BlenderMenuDescriptorWidget> menuDescriptors;
  final List<Widget> leading;
  final List<Widget> actions;
  final Widget? center;
  final Color? background;
  final double? height;
  final bool showEditorLabel;
  final double? editorSelectorWidth;

  /// Replaces the standard editor-type selector for embedded or host-specific
  /// editor switchers while preserving the rest of the area-header anatomy.
  final Widget? editorSelector;
  final bool showBottomBorder;
  final bool actionsScrollable;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    // Blender's compact editor selector is two UI units: one icon unit and
    // one disclosure unit. Reserving the old 76 px slot left a conspicuous
    // empty gap before the mode selector.
    final densityScale = theme.density.controlHeight / 20;
    final selectorWidth =
        editorSelectorWidth ?? (showEditorLabel ? 132 : 32 * densityScale);
    final selector =
        editorSelector ??
        BlenderEditorTypeSelector(
          value: editorType,
          compact: !showEditorLabel,
          onChanged: onEditorTypeChanged,
        );
    return Container(
      height: math.max(height ?? 0, theme.density.headerHeight),
      padding: EdgeInsets.symmetric(horizontal: theme.density.panelPadding),
      decoration: BoxDecoration(
        color: background ?? theme.colors.surface,
        border: showBottomBorder
            ? Border(bottom: BorderSide(color: theme.colors.editorBorder))
            : const Border(),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // At a collapsed dock extent, preserve the editor selector and clip
          // the rest of the header before fixed leading controls can overflow.
          if (constraints.maxWidth <
              selectorWidth + theme.density.controlHeight) {
            return ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(width: constraints.maxWidth, child: selector),
              ),
            );
          }
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(width: selectorWidth, child: selector),
                  ...leading,
                  Expanded(
                    child: actionsScrollable
                        ? Row(
                            children: <Widget>[
                              Expanded(
                                child: _blenderHeaderScrollSurface(
                                  context,
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        for (final menu in menuDescriptors)
                                          menu.build(),
                                        ...menus,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: _blenderHeaderScrollSurface(
                                  context,
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: actions,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : _blenderHeaderScrollSurface(
                            context,
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  for (final menu in menuDescriptors)
                                    menu.build(),
                                  ...menus,
                                ],
                              ),
                            ),
                          ),
                  ),
                  if (!actionsScrollable) ...actions,
                ],
              ),
              if (center != null) Center(child: center),
            ],
          );
        },
      ),
    );
  }
}
