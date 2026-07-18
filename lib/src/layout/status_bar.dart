part of '../layout.dart';

class BlenderStatusBar extends StatelessWidget {
  const BlenderStatusBar({
    super.key,
    this.left = const <Widget>[],
    this.center = const <Widget>[],
    this.right = const <Widget>[],
    this.height,
  });

  final List<Widget> left;
  final List<Widget> center;
  final List<Widget> right;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Container(
      height: height ?? theme.density.headerHeight,
      padding: EdgeInsets.symmetric(horizontal: theme.density.panelPadding),
      decoration: BoxDecoration(
        color: theme.colors.canvas,
        border: Border(top: BorderSide(color: theme.colors.editorBorder)),
      ),
      child: DefaultTextStyle(
        style: theme.textTheme.caption.copyWith(
          color: theme.colors.foregroundMuted,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: ClipRect(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(mainAxisSize: MainAxisSize.min, children: left),
                ),
              ),
            ),
            if (center.isNotEmpty) ...<Widget>[
              SizedBox(width: theme.density.spacing),
              Flexible(
                child: Align(
                  alignment: Alignment.center,
                  child: ClipRect(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (right.isNotEmpty) ...<Widget>[
              SizedBox(width: theme.density.spacing),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ClipRect(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: right,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
