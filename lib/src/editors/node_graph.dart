part of '../editors.dart';

class BlenderNodeSocketDefinition {
  const BlenderNodeSocketDefinition({
    required this.id,
    required this.label,
    this.color,
    this.detail,
  });

  final String id;
  final String label;
  final Color? color;
  final String? detail;
}

class BlenderNodeSocket extends StatelessWidget {
  const BlenderNodeSocket({
    super.key,
    required this.label,
    this.color,
    this.detail,
    this.output = false,
  });

  final String label;
  final Color? color;
  final String? detail;
  final bool output;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final socket = Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color ?? theme.colors.panelHeader,
        shape: BoxShape.circle,
        border: Border.all(color: theme.colors.borderSubtle),
      ),
    );
    final labelWidget = Flexible(
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        textAlign: output ? TextAlign.right : TextAlign.left,
        style: theme.textTheme.caption,
      ),
    );
    final detailWidget = detail == null
        ? const SizedBox.shrink()
        : Text(
            detail!,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.caption.copyWith(
              color: theme.colors.foregroundMuted,
            ),
          );
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisAlignment: output
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: output
            ? <Widget>[
                detailWidget,
                const SizedBox(width: 3),
                labelWidget,
                const SizedBox(width: 4),
                socket,
              ]
            : <Widget>[
                socket,
                const SizedBox(width: 4),
                labelWidget,
                const SizedBox(width: 3),
                detailWidget,
              ],
      ),
    );
  }
}

class BlenderGraphNode {
  const BlenderGraphNode({
    required this.id,
    required this.title,
    required this.position,
    this.size = const Size(150, 90),
    this.inputs = const <BlenderNodeSocketDefinition>[],
    this.outputs = const <BlenderNodeSocketDefinition>[],
  });

  final String id;
  final String title;
  final Offset position;
  final Size size;
  final List<BlenderNodeSocketDefinition> inputs;
  final List<BlenderNodeSocketDefinition> outputs;

  BlenderGraphNode copyWith({
    String? id,
    String? title,
    Offset? position,
    Size? size,
    List<BlenderNodeSocketDefinition>? inputs,
    List<BlenderNodeSocketDefinition>? outputs,
  }) {
    return BlenderGraphNode(
      id: id ?? this.id,
      title: title ?? this.title,
      position: position ?? this.position,
      size: size ?? this.size,
      inputs: inputs ?? this.inputs,
      outputs: outputs ?? this.outputs,
    );
  }
}

class BlenderGraphLink {
  const BlenderGraphLink({required this.from, required this.to});

  final String from;
  final String to;

  BlenderGraphLink copyWith({String? from, String? to}) =>
      BlenderGraphLink(from: from ?? this.from, to: to ?? this.to);
}

class BlenderNodeGraphModel {
  const BlenderNodeGraphModel({
    this.nodes = const <BlenderGraphNode>[],
    this.links = const <BlenderGraphLink>[],
  });

  final List<BlenderGraphNode> nodes;
  final List<BlenderGraphLink> links;

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

  BlenderNodeGraphModel moveNode(String id, Offset position) {
    final node = nodes.where((node) => node.id == id);
    if (node.isEmpty || node.first.position == position) return this;
    return replaceNode(node.first.copyWith(position: position));
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
      (candidate) => candidate.from == link.from && candidate.to == link.to,
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

  BlenderNodeGraphModel removeLink({required String from, required String to}) {
    final next = links
        .where((link) => link.from != from || link.to != to)
        .toList(growable: false);
    if (next.length == links.length) return this;
    return copyWith(links: List<BlenderGraphLink>.unmodifiable(next));
  }
}
