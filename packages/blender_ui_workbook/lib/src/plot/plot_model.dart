import 'dart:ui';

enum WorkbookPlotKind {
  oscilloscope,
  line,
  scatter,
  bar,
  histogram,
  stackedArea,
  waveform,
  candlestick,
  sankey,
  gantt,
  threeDimensional,
  xyMap,
}

enum WorkbookPlotAxisSide { left, right, top, bottom }

enum WorkbookPlotCursorKind { vertical, band }

final class WorkbookPlotPoint {
  const WorkbookPlotPoint({
    required this.x,
    required this.y,
    this.z,
    this.open,
    this.high,
    this.low,
    this.close,
    this.label,
  });

  final double x;
  final double y;
  final double? z;
  final double? open;
  final double? high;
  final double? low;
  final double? close;
  final String? label;

  factory WorkbookPlotPoint.fromJson(Object? value) {
    if (value is List && value.length >= 2) {
      return WorkbookPlotPoint(x: _double(value[0]), y: _double(value[1]));
    }
    final map = _map(value);
    return WorkbookPlotPoint(
      x: _double(map['x']),
      y: _double(map['y']),
      z: _nullableDouble(map['z']),
      open: _nullableDouble(map['open']),
      high: _nullableDouble(map['high']),
      low: _nullableDouble(map['low']),
      close: _nullableDouble(map['close']),
      label: map['label']?.toString(),
    );
  }
}

final class WorkbookPlotSeries {
  const WorkbookPlotSeries({
    required this.id,
    required this.label,
    required this.points,
    required this.color,
    this.axisId = 'y',
    this.visible = true,
    this.fill = false,
    this.lineWidth = 1.5,
  });

  final String id;
  final String label;
  final List<WorkbookPlotPoint> points;
  final Color color;
  final String axisId;
  final bool visible;
  final bool fill;
  final double lineWidth;

  WorkbookPlotSeries copyWith({bool? visible}) => WorkbookPlotSeries(
    id: id,
    label: label,
    points: points,
    color: color,
    axisId: axisId,
    visible: visible ?? this.visible,
    fill: fill,
    lineWidth: lineWidth,
  );

  factory WorkbookPlotSeries.fromJson(Object? value, int index) {
    final map = _map(value);
    final id = map['id']?.toString() ?? 'series-$index';
    return WorkbookPlotSeries(
      id: id,
      label: map['label']?.toString() ?? id,
      points: List<WorkbookPlotPoint>.unmodifiable(<WorkbookPlotPoint>[
        for (final point in _list(map['points']))
          WorkbookPlotPoint.fromJson(point),
      ]),
      color: _color(map['color'], index),
      axisId: map['axis']?.toString() ?? 'y',
      visible: map['visible'] != false,
      fill: map['fill'] == true,
      lineWidth: _nullableDouble(map['lineWidth']) ?? 1.5,
    );
  }
}

final class WorkbookPlotAxis {
  const WorkbookPlotAxis({
    required this.id,
    required this.label,
    required this.minimum,
    required this.maximum,
    this.unit = '',
    this.side = WorkbookPlotAxisSide.left,
    this.normalizedTop = 0,
    this.normalizedBottom = 1,
  });

  final String id;
  final String label;
  final String unit;
  final double minimum;
  final double maximum;
  final WorkbookPlotAxisSide side;
  final double normalizedTop;
  final double normalizedBottom;

  WorkbookPlotAxis copyWith({
    double? minimum,
    double? maximum,
    double? normalizedTop,
    double? normalizedBottom,
  }) => WorkbookPlotAxis(
    id: id,
    label: label,
    unit: unit,
    minimum: minimum ?? this.minimum,
    maximum: maximum ?? this.maximum,
    side: side,
    normalizedTop: normalizedTop ?? this.normalizedTop,
    normalizedBottom: normalizedBottom ?? this.normalizedBottom,
  );

  factory WorkbookPlotAxis.fromJson(Object? value, int index) {
    final map = _map(value);
    final id = map['id']?.toString() ?? (index == 0 ? 'y' : 'y$index');
    return WorkbookPlotAxis(
      id: id,
      label: map['label']?.toString() ?? id,
      unit: map['unit']?.toString() ?? '',
      minimum: _nullableDouble(map['min']) ?? 0,
      maximum: _nullableDouble(map['max']) ?? 1,
      side: WorkbookPlotAxisSide.values.firstWhere(
        (side) => side.name == map['side'],
        orElse: () => WorkbookPlotAxisSide.left,
      ),
      normalizedTop: _nullableDouble(map['top']) ?? 0,
      normalizedBottom: _nullableDouble(map['bottom']) ?? 1,
    );
  }
}

final class WorkbookPlotCursor {
  const WorkbookPlotCursor({
    required this.id,
    required this.x,
    required this.color,
    this.kind = WorkbookPlotCursorKind.vertical,
    this.x2,
    this.label,
  });

  final String id;
  final WorkbookPlotCursorKind kind;
  final double x;
  final double? x2;
  final Color color;
  final String? label;

  WorkbookPlotCursor copyWith({double? x, double? x2}) => WorkbookPlotCursor(
    id: id,
    kind: kind,
    x: x ?? this.x,
    x2: x2 ?? this.x2,
    color: color,
    label: label,
  );

  factory WorkbookPlotCursor.fromJson(Object? value, int index) {
    final map = _map(value);
    return WorkbookPlotCursor(
      id: map['id']?.toString() ?? 'cursor-$index',
      kind: map['type'] == 'band'
          ? WorkbookPlotCursorKind.band
          : WorkbookPlotCursorKind.vertical,
      x: _double(map['x']),
      x2: _nullableDouble(map['x2']),
      color: _color(map['color'], index + 4),
      label: map['label']?.toString(),
    );
  }
}

final class WorkbookPlotNode {
  const WorkbookPlotNode({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    required this.height,
    required this.color,
  });

  final String id;
  final String label;
  final double x;
  final double y;
  final double height;
  final Color color;

  WorkbookPlotNode copyWith({double? x, double? y}) => WorkbookPlotNode(
    id: id,
    label: label,
    x: x ?? this.x,
    y: y ?? this.y,
    height: height,
    color: color,
  );

  factory WorkbookPlotNode.fromJson(Object? value, int index) {
    final map = _map(value);
    return WorkbookPlotNode(
      id: map['id']?.toString() ?? 'node-$index',
      label: map['label']?.toString() ?? 'Node ${index + 1}',
      x: _double(map['x']),
      y: _double(map['y']),
      height: _nullableDouble(map['height'] ?? map['h']) ?? 0.15,
      color: _color(map['color'], index),
    );
  }
}

final class WorkbookPlotLink {
  const WorkbookPlotLink({
    required this.sourceId,
    required this.targetId,
    required this.weight,
    required this.color,
    this.label,
  });

  final String sourceId;
  final String targetId;
  final double weight;
  final Color color;
  final String? label;

  factory WorkbookPlotLink.fromJson(Object? value, int index) {
    final map = _map(value);
    return WorkbookPlotLink(
      sourceId: map['source']?.toString() ?? '',
      targetId: map['target']?.toString() ?? '',
      weight: _nullableDouble(map['weight']) ?? 0.1,
      color: _color(map['color'], index),
      label: map['label']?.toString(),
    );
  }
}

final class WorkbookPlotSpec {
  const WorkbookPlotSpec({
    required this.title,
    required this.kind,
    required this.series,
    required this.axes,
    required this.xMinimum,
    required this.xMaximum,
    this.cursors = const <WorkbookPlotCursor>[],
    this.nodes = const <WorkbookPlotNode>[],
    this.links = const <WorkbookPlotLink>[],
    this.showGrid = true,
    this.showLegend = true,
    this.isometric = false,
  });

  static const mimeType = 'application/vnd.blenderui.plot+json';

  final String title;
  final WorkbookPlotKind kind;
  final List<WorkbookPlotSeries> series;
  final List<WorkbookPlotAxis> axes;
  final List<WorkbookPlotCursor> cursors;
  final List<WorkbookPlotNode> nodes;
  final List<WorkbookPlotLink> links;
  final double xMinimum;
  final double xMaximum;
  final bool showGrid;
  final bool showLegend;
  final bool isometric;

  factory WorkbookPlotSpec.fromJson(Object? value) {
    final map = _map(value);
    final series = <WorkbookPlotSeries>[
      for (final (index, item) in _list(map['series']).indexed)
        WorkbookPlotSeries.fromJson(item, index),
    ];
    final allX = <double>[
      for (final item in series)
        for (final point in item.points) point.x,
    ];
    final axes = <WorkbookPlotAxis>[
      for (final (index, item) in _list(map['axes']).indexed)
        WorkbookPlotAxis.fromJson(item, index),
    ];
    final resolvedAxes = axes.isEmpty
        ? _inferredAxes(series)
        : List<WorkbookPlotAxis>.unmodifiable(axes);
    final rawKind = map['type']?.toString().replaceAll('-', '') ?? 'line';
    final kind = switch (rawKind.toLowerCase()) {
      '3d' => WorkbookPlotKind.threeDimensional,
      _ => WorkbookPlotKind.values.firstWhere(
        (kind) => kind.name.toLowerCase() == rawKind.toLowerCase(),
        orElse: () => WorkbookPlotKind.line,
      ),
    };
    return WorkbookPlotSpec(
      title: map['title']?.toString() ?? 'Plot',
      kind: kind,
      series: List<WorkbookPlotSeries>.unmodifiable(series),
      axes: resolvedAxes,
      cursors: List<WorkbookPlotCursor>.unmodifiable(<WorkbookPlotCursor>[
        for (final (index, item) in _list(map['cursors']).indexed)
          WorkbookPlotCursor.fromJson(item, index),
      ]),
      nodes: List<WorkbookPlotNode>.unmodifiable(<WorkbookPlotNode>[
        for (final (index, item) in _list(map['nodes']).indexed)
          WorkbookPlotNode.fromJson(item, index),
      ]),
      links: List<WorkbookPlotLink>.unmodifiable(<WorkbookPlotLink>[
        for (final (index, item) in _list(map['links']).indexed)
          WorkbookPlotLink.fromJson(item, index),
      ]),
      xMinimum:
          _nullableDouble(map['xMin']) ??
          (allX.isEmpty ? 0 : allX.reduce((a, b) => a < b ? a : b)),
      xMaximum:
          _nullableDouble(map['xMax']) ??
          (allX.isEmpty ? 1 : allX.reduce((a, b) => a > b ? a : b)),
      showGrid: map['showGrid'] != false,
      showLegend: map['showLegend'] != false,
      isometric: map['isometric'] == true,
    );
  }

  static List<WorkbookPlotAxis> _inferredAxes(List<WorkbookPlotSeries> series) {
    final points = <double>[
      for (final item in series)
        for (final point in item.points) point.y,
    ];
    var minimum = points.isEmpty ? 0.0 : points.reduce((a, b) => a < b ? a : b);
    var maximum = points.isEmpty ? 1.0 : points.reduce((a, b) => a > b ? a : b);
    if (minimum == maximum) {
      minimum -= 1;
      maximum += 1;
    }
    return <WorkbookPlotAxis>[
      WorkbookPlotAxis(
        id: 'y',
        label: 'Value',
        minimum: minimum,
        maximum: maximum,
      ),
    ];
  }
}

Map<String, Object?> _map(Object? value) {
  if (value is! Map) return const <String, Object?>{};
  return value.map((key, item) => MapEntry(key.toString(), item));
}

List<Object?> _list(Object? value) =>
    value is List ? List<Object?>.from(value) : const <Object?>[];

double _double(Object? value) => _nullableDouble(value) ?? 0;

double? _nullableDouble(Object? value) => switch (value) {
  num item => item.toDouble(),
  String item => double.tryParse(item),
  _ => null,
};

Color _color(Object? value, int index) {
  if (value is int) return Color(value);
  if (value is String) {
    final raw = value.replaceFirst('#', '');
    final parsed = int.tryParse(raw, radix: 16);
    if (parsed != null) {
      return Color(raw.length <= 6 ? 0xff000000 | parsed : parsed);
    }
  }
  const defaults = <Color>[
    Color(0xff3b82f6),
    Color(0xfff59e0b),
    Color(0xff10b981),
    Color(0xffec4899),
    Color(0xff8b5cf6),
    Color(0xff06b6d4),
  ];
  return defaults[index % defaults.length];
}
