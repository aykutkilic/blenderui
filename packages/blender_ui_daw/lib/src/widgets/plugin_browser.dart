import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

import '../services/plugin_host.dart';
import 'editor_shared.dart';
import 'plugin_drag.dart';

class DawPluginBrowser extends StatefulWidget {
  const DawPluginBrowser({
    super.key,
    required this.host,
    this.onPluginSelected,
    this.searchPaths = const <String>[],
  });

  final DawPluginHost host;
  final ValueChanged<DawPluginDescriptor>? onPluginSelected;
  final List<String> searchPaths;

  @override
  State<DawPluginBrowser> createState() => _DawPluginBrowserState();
}

class _DawPluginBrowserState extends State<DawPluginBrowser> {
  final TextEditingController _search = TextEditingController();
  DawPluginCategory? _category;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge(<Listenable>[widget.host, _search]),
    builder: (context, _) {
      final query = _search.text.trim().toLowerCase();
      final items = widget.host.catalog
          .where((plugin) {
            final matchesCategory =
                _category == null || plugin.category == _category;
            final matchesQuery =
                query.isEmpty ||
                plugin.name.toLowerCase().contains(query) ||
                plugin.vendor.toLowerCase().contains(query) ||
                plugin.format.name.toLowerCase().contains(query);
            return matchesCategory && matchesQuery;
          })
          .toList(growable: false);
      return BlenderEditorFrame(
        child: Column(
          children: <Widget>[
            DawEditorHeader(
              title: 'Plugin Browser',
              menus: const <String>['View', 'Catalog'],
              actions: <Widget>[
                BlenderIconButton(
                  glyph: BlenderGlyph.refresh,
                  tooltip: 'Scan Plug-ins',
                  onPressed: widget.host.scanning
                      ? null
                      : () => widget.host.scan(widget.searchPaths),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: BlenderSearchField(
                controller: _search,
                placeholder: 'Search VST3, Audio Unit, CLAP',
              ),
            ),
            SizedBox(
              height: 24,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                children: <Widget>[
                  BlenderButton(
                    label: 'All',
                    selected: _category == null,
                    onPressed: () => setState(() => _category = null),
                  ),
                  for (final category in DawPluginCategory.values)
                    BlenderButton(
                      label: category.name,
                      selected: _category == category,
                      onPressed: () => setState(() => _category = category),
                    ),
                ],
              ),
            ),
            if (widget.host.scanning)
              const BlenderProgressBar(value: .5, label: 'Scanning…'),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        widget.host.scanning
                            ? 'Scanning plug-in paths…'
                            : 'No plug-ins found',
                      ),
                    )
                  : BlenderListView<DawPluginDescriptor>(
                      items: <BlenderListItem<DawPluginDescriptor>>[
                        for (final plugin in items)
                          BlenderListItem<DawPluginDescriptor>(
                            id: plugin.id,
                            label: plugin.name,
                            detail:
                                '${plugin.vendor} • ${plugin.format.name.toUpperCase()} • '
                                '${plugin.category.name}'
                                '${plugin.loadable ? '' : ' • Discovery only'}',
                            icon:
                                plugin.category == DawPluginCategory.instrument
                                ? BlenderGlyph.speaker
                                : BlenderGlyph.node,
                            value: plugin,
                            enabled: plugin.loadable,
                          ),
                      ],
                      onSelected: (item) {
                        final plugin = item.value;
                        if (plugin != null)
                          widget.onPluginSelected?.call(plugin);
                      },
                      onActivated: (item) {
                        final plugin = item.value;
                        if (plugin != null)
                          widget.onPluginSelected?.call(plugin);
                      },
                      itemWrapper: (context, item, row) {
                        final plugin = item.value;
                        if (plugin == null || !plugin.loadable) return row;
                        return Draggable<DawPluginDragPayload>(
                          data: DawPluginDragPayload(plugin),
                          feedback: DawPluginDragFeedback(plugin: plugin),
                          childWhenDragging: Opacity(opacity: .4, child: row),
                          child: row,
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    },
  );
}

class DawPluginRack extends StatelessWidget {
  const DawPluginRack({super.key, required this.host});

  final DawPluginHost host;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: host,
    builder: (context, _) => BlenderEditorFrame(
      child: Column(
        children: <Widget>[
          const DawEditorHeader(
            title: 'Plugin Rack',
            menus: const <String>['View', 'Plugin', 'Routing'],
          ),
          Expanded(
            child: host.instances.isEmpty
                ? const Center(child: Text('Double-click a plug-in to add it'))
                : ListView(
                    padding: const EdgeInsets.all(6),
                    children: <Widget>[
                      for (final instance in host.instances)
                        BlenderPanel(
                          title:
                              '${instance.descriptor.name} — ${instance.descriptor.vendor}',
                          headerActions: <Widget>[
                            BlenderIconButton(
                              glyph: BlenderGlyph.close,
                              tooltip: 'Remove Plug-in',
                              onPressed: () => host.remove(instance.instanceId),
                            ),
                          ],
                          child: Column(
                            children: <Widget>[
                              for (final parameter in instance.parameters)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 90,
                                        child: Text(parameter.name),
                                      ),
                                      Expanded(
                                        child: BlenderSlider(
                                          value: parameter.value,
                                          onChanged: (value) =>
                                              host.setParameter(
                                                instance.instanceId,
                                                parameter.id,
                                                value,
                                              ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 38,
                                        child: Text(
                                          parameter.value.toStringAsFixed(2),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    ),
  );
}
