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
    return Container(
      height: height ?? theme.density.headerHeight,
      padding: EdgeInsets.symmetric(horizontal: theme.density.panelPadding),
      decoration: BoxDecoration(
        color: background ?? theme.colors.surface,
        border: showBottomBorder
            ? Border(bottom: BorderSide(color: theme.colors.editorBorder))
            : const Border(),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(
                width: editorSelectorWidth ?? (showEditorLabel ? 132 : 76),
                child:
                    editorSelector ??
                    BlenderEditorTypeSelector(
                      value: editorType,
                      compact: !showEditorLabel,
                      onChanged: onEditorTypeChanged,
                    ),
              ),
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
                              for (final menu in menuDescriptors) menu.build(),
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
      ),
    );
  }
}
