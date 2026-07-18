part of '../layout.dart';

class BlenderBox extends StatelessWidget {
  const BlenderBox({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderColor,
    this.radius,
  });

  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final Color? borderColor;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? theme.colors.panelSubSurface,
        border: Border.all(color: borderColor ?? theme.colors.editorBorder),
        borderRadius: BorderRadius.circular(radius ?? theme.shapes.panelRadius),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(theme.density.panelPadding),
        child: child,
      ),
    );
  }
}

class BlenderFlow extends StatelessWidget {
  const BlenderFlow({
    super.key,
    required this.children,
    this.spacing = 4,
    this.runSpacing = 4,
    this.alignment = WrapAlignment.start,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      children: children,
    );
  }
}

class BlenderGrid extends StatelessWidget {
  const BlenderGrid({
    super.key,
    required this.children,
    this.minItemWidth = 100,
    this.itemHeight = 80,
    this.spacing = 4,
  });

  final List<Widget> children;
  final double minItemWidth;
  final double itemHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = math.max(
          1,
          (constraints.maxWidth / minItemWidth).floor(),
        );
        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: itemHeight,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

class BlenderOverlap extends StatelessWidget {
  const BlenderOverlap({
    super.key,
    required this.children,
    this.fit = StackFit.loose,
  });

  final List<Widget> children;
  final StackFit fit;

  @override
  Widget build(BuildContext context) {
    return Stack(fit: fit, children: children);
  }
}
