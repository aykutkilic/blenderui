part of '../layout.dart';

class BlenderToolbar extends StatefulWidget {
  const BlenderToolbar({
    super.key,
    required this.children,
    this.height,
    this.scrollable = false,
    this.background,
    this.edgeFade = true,
  });

  final List<Widget> children;
  final double? height;
  final bool scrollable;
  final Color? background;
  final bool edgeFade;

  @override
  State<BlenderToolbar> createState() => _BlenderToolbarState();
}

Widget _blenderHeaderScrollSurface(BuildContext context, Widget child) {
  return ScrollConfiguration(
    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
    child: child,
  );
}

class _BlenderToolbarState extends State<BlenderToolbar> {
  late final ScrollController _scrollController;
  bool _showLeftFade = false;
  bool _showRightFade = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_syncFadeState);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFadeState());
  }

  void _syncFadeState() {
    if (!_scrollController.hasClients) return;
    final showLeft = _scrollController.offset > 1;
    final showRight =
        _scrollController.offset <
        _scrollController.position.maxScrollExtent - 1;
    if (showLeft == _showLeftFade && showRight == _showRightFade) return;
    if (!mounted) return;
    setState(() {
      _showLeftFade = showLeft;
      _showRightFade = showRight;
    });
  }

  Widget _content(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final row = Row(
      mainAxisSize: widget.scrollable ? MainAxisSize.min : MainAxisSize.max,
      children: <Widget>[
        for (var i = 0; i < widget.children.length; i++) ...<Widget>[
          if (i > 0) SizedBox(width: theme.density.spacing),
          widget.children[i],
        ],
      ],
    );
    if (!widget.scrollable) return row;
    return UnconstrainedBox(
      alignment: Alignment.centerLeft,
      constrainedAxis: Axis.vertical,
      child: row,
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_syncFadeState)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    // Blender headers use the themed header surface (`#303030` in the default
    // dark theme), not the darker editor body behind them.
    final background = widget.background ?? theme.colors.surfaceElevated;
    final content = widget.scrollable
        ? _blenderHeaderScrollSurface(
            context,
            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: _content(context),
            ),
          )
        : _content(context);
    return Container(
      height: widget.height ?? theme.density.headerHeight,
      padding: EdgeInsets.symmetric(horizontal: theme.density.panelPadding),
      decoration: BoxDecoration(
        color: background,
        border: Border(bottom: BorderSide(color: theme.colors.editorBorder)),
      ),
      child: widget.scrollable && widget.edgeFade
          ? Stack(
              fit: StackFit.expand,
              children: <Widget>[
                content,
                if (_showLeftFade)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 28,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              background,
                              background.withAlpha(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_showRightFade)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 28,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: <Color>[
                              background,
                              background.withAlpha(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : content,
    );
  }
}
