part of '../layout.dart';

class BlenderPanel extends StatelessWidget {
  const BlenderPanel({
    super.key,
    this.title,
    this.child,
    this.headerActions,
    this.padding,
    this.backgroundColor,
    this.headerLeading,
    this.headerTitleStyle,
    this.headerHandle,
    this.showHandle = false,
    this.disclosureKey,
    this.collapsible = false,
    this.initiallyExpanded = true,
    this.expanded,
    this.onExpansionChanged,
  });

  final String? title;
  final Widget? child;
  final List<Widget>? headerActions;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Widget? headerLeading;
  final TextStyle? headerTitleStyle;
  final Widget? headerHandle;
  final bool showHandle;
  final Key? disclosureKey;
  final bool collapsible;
  final bool initiallyExpanded;
  final bool? expanded;
  final ValueChanged<bool>? onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final content = child == null
        ? const SizedBox.shrink()
        : Padding(
            padding: padding ?? EdgeInsets.all(theme.density.panelPadding),
            child: child,
          );
    if (title == null) return content;
    if (!collapsible) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final body = constraints.hasBoundedHeight
              ? Flexible(child: content)
              : content;
          return ClipRRect(
            borderRadius: BorderRadius.circular(theme.shapes.panelRadius),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor ?? theme.colors.panelBackground,
                border: Border.all(color: theme.colors.panelOutline),
                borderRadius: BorderRadius.circular(theme.shapes.panelRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  BlenderPanelHeader(
                    title: title!,
                    actions: headerActions,
                    leading: headerLeading,
                    titleStyle: headerTitleStyle,
                    handle: headerHandle,
                    showHandle: showHandle,
                    disclosureKey: disclosureKey,
                  ),
                  body,
                ],
              ),
            ),
          );
        },
      );
    }
    return _CollapsiblePanel(
      title: title!,
      actions: headerActions,
      content: content,
      initiallyExpanded: initiallyExpanded,
      expanded: expanded,
      backgroundColor: backgroundColor,
      leading: headerLeading,
      titleStyle: headerTitleStyle,
      handle: headerHandle,
      showHandle: showHandle,
      disclosureKey: disclosureKey,
      onExpansionChanged: onExpansionChanged,
    );
  }
}

class BlenderPanelHeader extends StatelessWidget {
  const BlenderPanelHeader({
    super.key,
    required this.title,
    this.actions,
    this.onTap,
    this.expanded = true,
    this.leading,
    this.titleStyle,
    this.handle,
    this.showHandle = false,
    this.disclosureKey,
  });

  final String title;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final bool expanded;
  final Widget? leading;
  final TextStyle? titleStyle;
  final Widget? handle;
  final bool showHandle;
  final Key? disclosureKey;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: theme.density.headerHeight,
        decoration: BoxDecoration(color: theme.colors.panelHeader),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            if (!width.isFinite || width <= 0) return const SizedBox.shrink();
            final horizontalPadding = math.min(
              theme.density.panelPadding,
              width / 2,
            );
            final innerWidth = width - horizontalPadding * 2;
            if (innerWidth < 9) return const SizedBox.shrink();

            final showTitle = innerWidth >= (onTap == null ? 18 : 30);
            final showLeading = showTitle && innerWidth >= 72;
            final showActions = showTitle && innerWidth >= 40;
            final showTrailingHandle = showTitle && innerWidth >= 52;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                children: <Widget>[
                  if (onTap != null)
                    BlenderIcon(
                      key: disclosureKey,
                      expanded
                          ? BlenderGlyph.panelDisclosureDown
                          : BlenderGlyph.panelDisclosureRight,
                      size: 9,
                      color: theme.colors.foregroundMuted,
                    ),
                  if (onTap != null && showTitle)
                    SizedBox(width: theme.density.spacing / 2),
                  if (showLeading && leading != null) ...<Widget>[
                    leading!,
                    SizedBox(width: theme.density.spacing),
                  ],
                  if (showTitle)
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle ?? theme.textTheme.panelTitle,
                      ),
                    )
                  else
                    const Spacer(),
                  if (showActions && actions != null && actions!.isNotEmpty)
                    Flexible(
                      fit: FlexFit.loose,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: actions!,
                        ),
                      ),
                    ),
                  if (showTrailingHandle)
                    if (handle != null)
                      handle!
                    else if (showHandle)
                      Padding(
                        padding: EdgeInsets.only(
                          left: theme.density.spacing / 2,
                        ),
                        child: BlenderIcon(
                          BlenderGlyph.dragHandle,
                          size: 7,
                          color: theme.colors.foreground.withAlpha(128),
                        ),
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CollapsiblePanel extends StatefulWidget {
  const _CollapsiblePanel({
    required this.title,
    required this.content,
    required this.initiallyExpanded,
    this.expanded,
    this.actions,
    this.leading,
    this.titleStyle,
    this.handle,
    this.backgroundColor,
    this.showHandle = false,
    this.disclosureKey,
    this.onExpansionChanged,
  });

  final String title;
  final Widget content;
  final bool initiallyExpanded;
  final bool? expanded;
  final List<Widget>? actions;
  final Widget? leading;
  final TextStyle? titleStyle;
  final Widget? handle;
  final Color? backgroundColor;
  final bool showHandle;
  final Key? disclosureKey;
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<_CollapsiblePanel> createState() => _CollapsiblePanelState();
}

class _CollapsiblePanelState extends State<_CollapsiblePanel> {
  late bool _expanded = widget.initiallyExpanded;

  bool get _effectiveExpanded => widget.expanded ?? _expanded;

  void _toggleExpanded() {
    final expanded = !_effectiveExpanded;
    if (widget.expanded == null) {
      setState(() => _expanded = expanded);
    }
    widget.onExpansionChanged?.call(expanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final radius = BorderRadius.circular(theme.shapes.panelRadius);
    return ClipRRect(
      borderRadius: radius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? theme.colors.panelBackground,
          border: Border.all(color: theme.colors.panelOutline),
          borderRadius: radius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlenderPanelHeader(
              title: widget.title,
              actions: widget.actions,
              expanded: _effectiveExpanded,
              leading: widget.leading,
              titleStyle: widget.titleStyle,
              handle: widget.handle,
              showHandle: widget.showHandle,
              disclosureKey: widget.disclosureKey,
              onTap: _toggleExpanded,
            ),
            if (_effectiveExpanded) widget.content,
          ],
        ),
      ),
    );
  }
}
