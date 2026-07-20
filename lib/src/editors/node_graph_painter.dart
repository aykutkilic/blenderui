part of '../editors.dart';

abstract final class _BlenderNodeGeometry {
  static const double headerHeight = 26;
  static const double socketRowHeight = 22;
  static const double socketTop = 4;
  static const double labeledNodeInset = 18;
  static const double socketCenterInset = 8;

  static Offset socketPosition(
    BlenderGraphNode node,
    String? socketId, {
    required bool output,
    Offset? position,
  }) {
    final nodePosition = position ?? node.position;
    if (node.kind == BlenderGraphNodeKind.reroute) {
      return nodePosition + node.visibleSize.center(Offset.zero);
    }
    if (node.collapsed) {
      return nodePosition +
          Offset(output ? node.visibleSize.width : 0, headerHeight / 2);
    }
    final sockets = output ? node.outputs : node.inputs;
    final index = socketId == null
        ? -1
        : sockets.indexWhere((socket) => socket.id == socketId);
    if (index < 0) {
      return nodePosition +
          Offset(
            output ? node.visibleSize.width : 0,
            node.visibleSize.height / 2,
          );
    }
    return nodePosition +
        Offset(
          output
              ? node.visibleSize.width - socketCenterInset
              : socketCenterInset,
          headerHeight +
              socketTop +
              (node.label == null ? 0 : labeledNodeInset) +
              (index * socketRowHeight) +
              (socketRowHeight / 2),
        );
  }
}

class _BlenderNodeGridPainter extends CustomPainter {
  const _BlenderNodeGridPainter({
    required this.minorColor,
    required this.majorColor,
    required this.scale,
    required this.translation,
  });

  final Color minorColor;
  final Color majorColor;
  final double scale;
  final Offset translation;

  @override
  void paint(Canvas canvas, Size size) {
    var sceneStep = 24.0;
    while (sceneStep * scale < 12) {
      sceneStep *= 5;
    }
    for (var level = 0; level < 3; level++) {
      final screenStep = sceneStep * scale * math.pow(5, level);
      if (screenStep > math.max(size.width, size.height) * 2) break;
      final startX = _positiveModulo(translation.dx, screenStep);
      final startY = _positiveModulo(translation.dy, screenStep);
      final paint = Paint()
        ..color = (level == 0 ? minorColor : majorColor).withAlpha(
          level == 0
              ? (minorColor.a * 255).round()
              : (majorColor.a * 255 / (level + 1)).round(),
        );
      final radius = level == 0 ? .65 : 1.15;
      for (var x = startX; x <= size.width; x += screenStep) {
        for (var y = startY; y <= size.height; y += screenStep) {
          canvas.drawCircle(Offset(x, y), radius, paint);
        }
      }
    }
  }

  double _positiveModulo(double value, double divisor) =>
      ((value % divisor) + divisor) % divisor;

  @override
  bool shouldRepaint(_BlenderNodeGridPainter oldDelegate) =>
      minorColor != oldDelegate.minorColor ||
      majorColor != oldDelegate.majorColor ||
      scale != oldDelegate.scale ||
      translation != oldDelegate.translation;
}

class _BlenderGraphPainter extends CustomPainter {
  _BlenderGraphPainter({
    required this.model,
    required this.theme,
    required this.wireColors,
    required this.visibleRect,
    required this.nodePositions,
  });

  final BlenderNodeGraphModel model;
  final BlenderThemeData theme;
  final bool wireColors;
  final Rect visibleRect;
  final Map<String, Offset> nodePositions;

  @override
  void paint(Canvas canvas, Size size) {
    final nodesById = <String, BlenderGraphNode>{
      for (final node in model.nodes) node.id: node,
    };
    for (final link in model.links) {
      final from = nodesById[link.from];
      final to = nodesById[link.to];
      if (from == null || to == null) continue;
      final path = _linkPath(
        _BlenderNodeGeometry.socketPosition(
          from,
          link.fromSocket,
          output: true,
          position: nodePositions[from.id],
        ),
        _BlenderNodeGeometry.socketPosition(
          to,
          link.toSocket,
          output: false,
          position: nodePositions[to.id],
        ),
        link.style,
      );
      if (!path.getBounds().inflate(8).overlaps(visibleRect)) continue;
      _drawPath(canvas, path, link, from: from, outline: true);
      _drawPath(canvas, path, link, from: from, outline: false);
    }
  }

  void _drawPath(
    Canvas canvas,
    Path path,
    BlenderGraphLink link, {
    required BlenderGraphNode from,
    required bool outline,
  }) {
    final color = outline
        ? theme.colors.editorBorder.withAlpha(220)
        : _linkColor(link, from);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = outline
          ? (link.selected ? 6 : 4)
          : (link.selected ? 3 : 2)
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
  }

  Color _linkColor(BlenderGraphLink link, BlenderGraphNode from) {
    if (link.muted) return theme.colors.foregroundDisabled.withAlpha(150);
    if (link.selected) return theme.colors.foreground;
    if (link.color != null) return link.color!;
    if (wireColors && link.fromSocket != null) {
      for (final socket in from.outputs) {
        if (socket.id == link.fromSocket)
          return _nodeSocketColor(socket, theme);
      }
    }
    return theme.colors.link;
  }

  @override
  bool shouldRepaint(_BlenderGraphPainter oldDelegate) =>
      model != oldDelegate.model ||
      theme != oldDelegate.theme ||
      wireColors != oldDelegate.wireColors ||
      visibleRect != oldDelegate.visibleRect ||
      nodePositions != oldDelegate.nodePositions;
}

Path _linkPath(Offset start, Offset end, BlenderGraphLinkStyle style) {
  final path = Path()..moveTo(start.dx, start.dy);
  if (style == BlenderGraphLinkStyle.straight) {
    return path..lineTo(end.dx, end.dy);
  }
  final distance = (end.dx - start.dx).abs();
  final handle = math.max(42.0, distance * .5);
  return path..cubicTo(
    start.dx + handle,
    start.dy,
    end.dx - handle,
    end.dy,
    end.dx,
    end.dy,
  );
}

class _BlenderConnectionPreviewPainter extends CustomPainter {
  const _BlenderConnectionPreviewPainter({
    required this.start,
    required this.end,
    required this.color,
    required this.snapped,
  });

  final Offset start;
  final Offset end;
  final Color color;
  final bool snapped;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _linkPath(start, end, BlenderGraphLinkStyle.bezier);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xCC111111)
        ..style = PaintingStyle.stroke
        ..strokeWidth = snapped ? 6 : 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = snapped ? 3 : 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_BlenderConnectionPreviewPainter oldDelegate) =>
      start != oldDelegate.start ||
      end != oldDelegate.end ||
      color != oldDelegate.color ||
      snapped != oldDelegate.snapped;
}
