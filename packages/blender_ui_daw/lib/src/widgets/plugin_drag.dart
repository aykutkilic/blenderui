import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

import '../services/plugin_host.dart';

/// Typed payload shared by plug-in catalogs and device-chain drop targets.
class DawPluginDragPayload {
  const DawPluginDragPayload(this.descriptor);

  final DawPluginDescriptor descriptor;
}

class DawPluginDragFeedback extends StatelessWidget {
  const DawPluginDragFeedback({super.key, required this.plugin});

  final DawPluginDescriptor plugin;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return IgnorePointer(
      child: Container(
        width: 190,
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colors.surfaceElevated,
          border: Border.all(color: theme.colors.accent),
          borderRadius: BorderRadius.circular(4),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x66000000), blurRadius: 8),
          ],
        ),
        child: Row(
          children: <Widget>[
            BlenderIcon(
              plugin.category == DawPluginCategory.instrument
                  ? BlenderGlyph.speaker
                  : BlenderGlyph.node,
              size: 14,
            ),
            const SizedBox(width: 6),
            Expanded(child: Text(plugin.name, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
