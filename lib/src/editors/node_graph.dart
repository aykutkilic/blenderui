part of '../editors.dart';

/// Visual and semantic type of a node socket.
///
/// Geometry-node applications can use the default colors directly, while
/// custom node systems can override [BlenderNodeSocketDefinition.color].
enum BlenderNodeSocketDataType {
  custom,
  geometry,
  floatingPoint,
  integer,
  boolean,
  vector,
  rotation,
  color,
  string,
  object,
  collection,
  texture,
  material,
  matrix,
}

enum BlenderNodeSocketShape { circle, diamond, square }

enum BlenderGraphNodeKind { standard, frame, reroute }

enum BlenderGraphLinkStyle { bezier, straight }

class BlenderNodeSocketDefinition {
  const BlenderNodeSocketDefinition({
    required this.id,
    required this.label,
    this.color,
    this.detail,
    this.description,
    this.dataType = BlenderNodeSocketDataType.custom,
    this.shape = BlenderNodeSocketShape.circle,
    this.enabled = true,
    this.connected = false,
    this.multiInput = false,
  });

  final String id;
  final String label;
  final Color? color;
  final String? detail;
  final String? description;
  final BlenderNodeSocketDataType dataType;
  final BlenderNodeSocketShape shape;
  final bool enabled;
  final bool connected;
  final bool multiInput;
}

/// Stable reference to one socket in a [BlenderNodeGraphModel].
///
/// References keep gesture state independent from the widget tree and remain
/// valid when a viewport culls the node that owns the socket.
@immutable
class BlenderNodeSocketReference {
  const BlenderNodeSocketReference({
    required this.nodeId,
    required this.socketId,
    required this.output,
  });

  final String nodeId;
  final String socketId;
  final bool output;

  @override
  bool operator ==(Object other) =>
      other is BlenderNodeSocketReference &&
      other.nodeId == nodeId &&
      other.socketId == socketId &&
      other.output == output;

  @override
  int get hashCode => Object.hash(nodeId, socketId, output);
}

class BlenderGraphNode {
  const BlenderGraphNode({
    required this.id,
    required this.title,
    required this.position,
    this.size = const Size(150, 90),
    this.inputs = const <BlenderNodeSocketDefinition>[],
    this.outputs = const <BlenderNodeSocketDefinition>[],
    this.kind = BlenderGraphNodeKind.standard,
    this.headerColor,
    this.label,
    this.description,
    this.parentId,
    this.selected = false,
    this.active = false,
    this.collapsed = false,
    this.muted = false,
    this.executionTime,
    this.warning,
  });

  final String id;
  final String title;
  final Offset position;
  final Size size;
  final List<BlenderNodeSocketDefinition> inputs;
  final List<BlenderNodeSocketDefinition> outputs;
  final BlenderGraphNodeKind kind;
  final Color? headerColor;
  final String? label;
  final String? description;
  final String? parentId;
  final bool selected;
  final bool active;
  final bool collapsed;
  final bool muted;
  final String? executionTime;
  final String? warning;

  Size get visibleSize => switch (kind) {
    BlenderGraphNodeKind.reroute => const Size(18, 18),
    BlenderGraphNodeKind.frame => size,
    BlenderGraphNodeKind.standard => collapsed ? Size(size.width, 26) : size,
  };

  BlenderGraphNode copyWith({
    String? id,
    String? title,
    Offset? position,
    Size? size,
    List<BlenderNodeSocketDefinition>? inputs,
    List<BlenderNodeSocketDefinition>? outputs,
    BlenderGraphNodeKind? kind,
    Color? headerColor,
    String? label,
    String? description,
    String? parentId,
    bool? selected,
    bool? active,
    bool? collapsed,
    bool? muted,
    String? executionTime,
    String? warning,
  }) {
    return BlenderGraphNode(
      id: id ?? this.id,
      title: title ?? this.title,
      position: position ?? this.position,
      size: size ?? this.size,
      inputs: inputs ?? this.inputs,
      outputs: outputs ?? this.outputs,
      kind: kind ?? this.kind,
      headerColor: headerColor ?? this.headerColor,
      label: label ?? this.label,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      selected: selected ?? this.selected,
      active: active ?? this.active,
      collapsed: collapsed ?? this.collapsed,
      muted: muted ?? this.muted,
      executionTime: executionTime ?? this.executionTime,
      warning: warning ?? this.warning,
    );
  }
}

class BlenderGraphLink {
  const BlenderGraphLink({
    required this.from,
    required this.to,
    this.fromSocket,
    this.toSocket,
    this.color,
    this.selected = false,
    this.muted = false,
    this.style = BlenderGraphLinkStyle.bezier,
  });

  final String from;
  final String to;
  final String? fromSocket;
  final String? toSocket;
  final Color? color;
  final bool selected;
  final bool muted;
  final BlenderGraphLinkStyle style;

  BlenderGraphLink copyWith({
    String? from,
    String? to,
    String? fromSocket,
    String? toSocket,
    Color? color,
    bool? selected,
    bool? muted,
    BlenderGraphLinkStyle? style,
  }) => BlenderGraphLink(
    from: from ?? this.from,
    to: to ?? this.to,
    fromSocket: fromSocket ?? this.fromSocket,
    toSocket: toSocket ?? this.toSocket,
    color: color ?? this.color,
    selected: selected ?? this.selected,
    muted: muted ?? this.muted,
    style: style ?? this.style,
  );
}

@immutable
class BlenderNodeGroupPathEntry {
  const BlenderNodeGroupPathEntry({required this.id, required this.label});

  final String id;
  final String label;
}

/// Immutable navigation path for nested node groups.
@immutable
class BlenderNodeGroupNavigation {
  BlenderNodeGroupNavigation({required List<BlenderNodeGroupPathEntry> path})
    : assert(path.isNotEmpty),
      path = List<BlenderNodeGroupPathEntry>.unmodifiable(path);

  final List<BlenderNodeGroupPathEntry> path;

  BlenderNodeGroupPathEntry get current => path.last;
  bool get canExit => path.length > 1;

  BlenderNodeGroupNavigation enter(BlenderNodeGroupPathEntry entry) =>
      BlenderNodeGroupNavigation(
        path: List<BlenderNodeGroupPathEntry>.unmodifiable(
          <BlenderNodeGroupPathEntry>[...path, entry],
        ),
      );

  BlenderNodeGroupNavigation exit() => canExit ? jumpTo(path.length - 2) : this;

  BlenderNodeGroupNavigation jumpTo(int index) {
    if (index < 0 || index >= path.length || index == path.length - 1) {
      return this;
    }
    return BlenderNodeGroupNavigation(
      path: List<BlenderNodeGroupPathEntry>.unmodifiable(path.take(index + 1)),
    );
  }
}

class BlenderNodeGraphModel {
  const BlenderNodeGraphModel({
    this.nodes = const <BlenderGraphNode>[],
    this.links = const <BlenderGraphLink>[],
  });

  final List<BlenderGraphNode> nodes;
  final List<BlenderGraphLink> links;

  BlenderGraphNode? nodeById(String id) {
    for (final node in nodes) {
      if (node.id == id) return node;
    }
    return null;
  }

  BlenderNodeSocketDefinition? socketByReference(
    BlenderNodeSocketReference reference,
  ) {
    final node = nodeById(reference.nodeId);
    if (node == null) return null;
    final sockets = reference.output ? node.outputs : node.inputs;
    for (final socket in sockets) {
      if (socket.id == reference.socketId) return socket;
    }
    return null;
  }

  bool isSocketConnected(BlenderNodeSocketReference reference) => links.any(
    (link) => reference.output
        ? link.from == reference.nodeId && link.fromSocket == reference.socketId
        : link.to == reference.nodeId && link.toSocket == reference.socketId,
  );

  /// Whether two references can form a directed output-to-input connection.
  ///
  /// The default policy mirrors Blender's common typed-socket behavior:
  /// disabled sockets, same-direction sockets, self-links, and incompatible
  /// concrete data types are rejected. A `custom` socket is an intentional
  /// wildcard for application-defined node systems.
  bool canConnectSockets(
    BlenderNodeSocketReference first,
    BlenderNodeSocketReference second,
  ) {
    if (first.output == second.output || first.nodeId == second.nodeId) {
      return false;
    }
    final firstSocket = socketByReference(first);
    final secondSocket = socketByReference(second);
    if (firstSocket == null || secondSocket == null) return false;
    if (!firstSocket.enabled || !secondSocket.enabled) return false;
    return firstSocket.dataType == BlenderNodeSocketDataType.custom ||
        secondSocket.dataType == BlenderNodeSocketDataType.custom ||
        firstSocket.dataType == secondSocket.dataType;
  }

  BlenderGraphLink? linkForSockets(
    BlenderNodeSocketReference first,
    BlenderNodeSocketReference second,
  ) {
    if (!canConnectSockets(first, second)) return null;
    final output = first.output ? first : second;
    final input = first.output ? second : first;
    return BlenderGraphLink(
      from: output.nodeId,
      fromSocket: output.socketId,
      to: input.nodeId,
      toSocket: input.socketId,
    );
  }

  Rect get bounds {
    if (nodes.isEmpty) return Rect.zero;
    return nodes
        .map((node) => node.position & node.visibleSize)
        .reduce((a, b) => a.expandToInclude(b));
  }

  BlenderNodeGraphModel copyWith({
    List<BlenderGraphNode>? nodes,
    List<BlenderGraphLink>? links,
  }) => BlenderNodeGraphModel(
    nodes: nodes ?? this.nodes,
    links: links ?? this.links,
  );

  BlenderNodeGraphModel replaceNode(BlenderGraphNode replacement) {
    final index = nodes.indexWhere((node) => node.id == replacement.id);
    if (index == -1) return this;
    final next = List<BlenderGraphNode>.of(nodes);
    next[index] = replacement;
    return copyWith(nodes: List<BlenderGraphNode>.unmodifiable(next));
  }

  BlenderNodeGraphModel addNode(BlenderGraphNode node) {
    if (nodes.any((candidate) => candidate.id == node.id)) return this;
    return copyWith(
      nodes: List<BlenderGraphNode>.unmodifiable(<BlenderGraphNode>[
        ...nodes,
        node,
      ]),
    );
  }

  BlenderNodeGraphModel selectNode(String id, {bool additive = false}) {
    if (!nodes.any((node) => node.id == id)) return this;
    return copyWith(
      nodes: List<BlenderGraphNode>.unmodifiable(<BlenderGraphNode>[
        for (final node in nodes)
          node.copyWith(
            selected: node.id == id || (additive && node.selected),
            active: node.id == id,
          ),
      ]),
    );
  }

  /// Replaces selection from a reusable canvas policy while retaining one
  /// caller-chosen active node.
  BlenderNodeGraphModel selectNodes(Set<String> ids, {String? activeId}) {
    if (ids.isEmpty && !nodes.any((node) => node.selected || node.active)) {
      return this;
    }
    return copyWith(
      nodes: List<BlenderGraphNode>.unmodifiable(<BlenderGraphNode>[
        for (final node in nodes)
          node.copyWith(
            selected: ids.contains(node.id),
            active: activeId == node.id,
          ),
      ]),
    );
  }

  BlenderNodeGraphModel selectAll() => copyWith(
    nodes: List<BlenderGraphNode>.unmodifiable(<BlenderGraphNode>[
      for (final node in nodes) node.copyWith(selected: true),
    ]),
  );

  BlenderNodeGraphModel clearSelection() => copyWith(
    nodes: List<BlenderGraphNode>.unmodifiable(<BlenderGraphNode>[
      for (final node in nodes) node.copyWith(selected: false, active: false),
    ]),
  );

  BlenderNodeGraphModel invertSelection() => copyWith(
    nodes: List<BlenderGraphNode>.unmodifiable(<BlenderGraphNode>[
      for (final node in nodes)
        node.copyWith(selected: !node.selected, active: false),
    ]),
  );

  BlenderNodeGraphModel removeSelectedNodes() {
    final selectedIds = <String>{
      for (final node in nodes)
        if (node.selected) node.id,
    };
    if (selectedIds.isEmpty) return this;
    return BlenderNodeGraphModel(
      nodes: List<BlenderGraphNode>.unmodifiable(
        nodes.where((node) => !selectedIds.contains(node.id)),
      ),
      links: List<BlenderGraphLink>.unmodifiable(
        links.where(
          (link) =>
              !selectedIds.contains(link.from) &&
              !selectedIds.contains(link.to),
        ),
      ),
    );
  }

  /// Duplicates the selected subgraph and selects the copies.
  ///
  /// The host supplies IDs so this generic model does not impose a document
  /// naming scheme. Links whose two endpoints are duplicated are recreated;
  /// external links intentionally remain attached only to the originals.
  BlenderNodeGraphModel duplicateSelectedNodes({
    required String Function(BlenderGraphNode node) idBuilder,
    Offset offset = const Offset(30, 30),
  }) {
    final selected = nodes.where((node) => node.selected).toList();
    if (selected.isEmpty) return this;
    final ids = <String, String>{
      for (final node in selected) node.id: idBuilder(node),
    };
    if (ids.values.toSet().length != ids.length ||
        ids.values.any((id) => nodes.any((node) => node.id == id))) {
      return this;
    }
    final copies = <BlenderGraphNode>[
      for (final node in selected)
        node.copyWith(
          id: ids[node.id],
          position: node.position + offset,
          parentId: ids[node.parentId] ?? node.parentId,
          selected: true,
          active: node == selected.last,
        ),
    ];
    return BlenderNodeGraphModel(
      nodes: List<BlenderGraphNode>.unmodifiable(<BlenderGraphNode>[
        for (final node in nodes) node.copyWith(selected: false, active: false),
        ...copies,
      ]),
      links: List<BlenderGraphLink>.unmodifiable(<BlenderGraphLink>[
        ...links,
        for (final link in links)
          if (ids.containsKey(link.from) && ids.containsKey(link.to))
            link.copyWith(from: ids[link.from], to: ids[link.to]),
      ]),
    );
  }

  /// Removes links crossed by a scene-space cut stroke.
  BlenderNodeGraphModel cutLinks(Offset start, Offset end) {
    final retained = links.where((link) => !_linkCrosses(link, start, end));
    final next = retained.toList(growable: false);
    return next.length == links.length
        ? this
        : copyWith(links: List<BlenderGraphLink>.unmodifiable(next));
  }

  bool _linkCrosses(BlenderGraphLink link, Offset cutStart, Offset cutEnd) {
    final from = nodeById(link.from);
    final to = nodeById(link.to);
    if (from == null || to == null) return false;
    final start = _BlenderNodeGeometry.socketPosition(
      from,
      link.fromSocket,
      output: true,
    );
    final end = _BlenderNodeGeometry.socketPosition(
      to,
      link.toSocket,
      output: false,
    );
    var previous = start;
    const samples = 24;
    for (var index = 1; index <= samples; index++) {
      final t = index / samples;
      final current = link.style == BlenderGraphLinkStyle.straight
          ? Offset.lerp(start, end, t)!
          : _bezierLinkPoint(start, end, t);
      if (_segmentsIntersect(previous, current, cutStart, cutEnd)) return true;
      previous = current;
    }
    return false;
  }

  BlenderNodeGraphModel moveNode(
    String id,
    Offset position, {
    bool moveFrameChildren = true,
  }) {
    final node = nodeById(id);
    if (node == null || node.position == position) return this;
    final delta = position - node.position;
    return copyWith(
      nodes: List<BlenderGraphNode>.unmodifiable(<BlenderGraphNode>[
        for (final candidate in nodes)
          if (candidate.id == id)
            candidate.copyWith(position: position)
          else if (moveFrameChildren &&
              node.kind == BlenderGraphNodeKind.frame &&
              candidate.parentId == id)
            candidate.copyWith(position: candidate.position + delta)
          else
            candidate,
      ]),
    );
  }

  /// Applies one grouped move transaction emitted by [BlenderNodeEditor].
  BlenderNodeGraphModel moveNodes(Map<String, Offset> positions) {
    if (positions.isEmpty) return this;
    return copyWith(
      nodes: List<BlenderGraphNode>.unmodifiable(<BlenderGraphNode>[
        for (final node in nodes)
          positions.containsKey(node.id)
              ? node.copyWith(position: positions[node.id]!)
              : node,
      ]),
    );
  }

  BlenderNodeGraphModel removeNode(String id) {
    if (!nodes.any((node) => node.id == id)) return this;
    bool belongsToNode(String socket) =>
        socket == id || socket.startsWith('$id.');
    return BlenderNodeGraphModel(
      nodes: List<BlenderGraphNode>.unmodifiable(
        nodes.where((node) => node.id != id),
      ),
      links: List<BlenderGraphLink>.unmodifiable(
        links.where(
          (link) => !belongsToNode(link.from) && !belongsToNode(link.to),
        ),
      ),
    );
  }

  BlenderNodeGraphModel addLink(BlenderGraphLink link) {
    if (links.any(
      (candidate) =>
          candidate.from == link.from &&
          candidate.to == link.to &&
          candidate.fromSocket == link.fromSocket &&
          candidate.toSocket == link.toSocket,
    )) {
      return this;
    }
    return copyWith(
      links: List<BlenderGraphLink>.unmodifiable(<BlenderGraphLink>[
        ...links,
        link,
      ]),
    );
  }

  /// Adds a validated socket link and applies Blender's single-input policy.
  ///
  /// Existing links into a normal input are replaced. Multi-input sockets keep
  /// their existing links. Invalid and duplicate connections leave the model
  /// unchanged.
  BlenderNodeGraphModel connectSockets(
    BlenderNodeSocketReference first,
    BlenderNodeSocketReference second,
  ) {
    final link = linkForSockets(first, second);
    if (link == null) return this;
    final input = first.output ? second : first;
    final inputSocket = socketByReference(input)!;
    var base = this;
    if (!inputSocket.multiInput) {
      final retained = links
          .where(
            (candidate) =>
                candidate.to != input.nodeId ||
                candidate.toSocket != input.socketId,
          )
          .toList(growable: false);
      if (retained.length != links.length) {
        base = copyWith(links: List<BlenderGraphLink>.unmodifiable(retained));
      }
    }
    return base.addLink(link);
  }

  List<String> validate() {
    final issues = <String>[];
    final ids = <String>{};
    for (final node in nodes) {
      if (!ids.add(node.id)) issues.add('Duplicate node id: ${node.id}');
    }
    for (final link in links) {
      final fromNode = nodeById(link.from);
      final toNode = nodeById(link.to);
      if (fromNode == null) issues.add('Missing link source: ${link.from}');
      if (toNode == null) issues.add('Missing link target: ${link.to}');
      if (link.fromSocket != null &&
          fromNode != null &&
          !fromNode.outputs.any((socket) => socket.id == link.fromSocket)) {
        issues.add('Missing output socket: ${link.from}.${link.fromSocket}');
      }
      if (link.toSocket != null &&
          toNode != null &&
          !toNode.inputs.any((socket) => socket.id == link.toSocket)) {
        issues.add('Missing input socket: ${link.to}.${link.toSocket}');
      }
    }
    return List<String>.unmodifiable(issues);
  }

  BlenderNodeGraphModel removeLink({required String from, required String to}) {
    final next = links
        .where((link) => link.from != from || link.to != to)
        .toList(growable: false);
    if (next.length == links.length) return this;
    return copyWith(links: List<BlenderGraphLink>.unmodifiable(next));
  }
}

Offset _bezierLinkPoint(Offset start, Offset end, double t) {
  final distance = (end.dx - start.dx).abs();
  final handle = math.max(42.0, distance * .5);
  final first = Offset(start.dx + handle, start.dy);
  final second = Offset(end.dx - handle, end.dy);
  final inverse = 1 - t;
  return start * (inverse * inverse * inverse) +
      first * (3 * inverse * inverse * t) +
      second * (3 * inverse * t * t) +
      end * (t * t * t);
}

bool _segmentsIntersect(Offset a, Offset b, Offset c, Offset d) {
  double cross(Offset first, Offset second, Offset third) =>
      (second.dx - first.dx) * (third.dy - first.dy) -
      (second.dy - first.dy) * (third.dx - first.dx);

  final abC = cross(a, b, c);
  final abD = cross(a, b, d);
  final cdA = cross(c, d, a);
  final cdB = cross(c, d, b);
  return ((abC <= 0 && abD >= 0) || (abC >= 0 && abD <= 0)) &&
      ((cdA <= 0 && cdB >= 0) || (cdA >= 0 && cdB <= 0));
}
