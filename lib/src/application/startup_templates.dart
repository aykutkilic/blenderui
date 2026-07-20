part of '../application.dart';

@immutable
class BlenderStartupTemplateEntry {
  const BlenderStartupTemplateEntry({
    required this.id,
    required this.label,
    required this.glyph,
    this.description,
  });

  final String id;
  final String label;
  final BlenderGlyph glyph;
  final String? description;
}

/// Reusable New File/Getting Started body used by Blender-style splash screens.
class BlenderStartupTemplateChooser extends StatelessWidget {
  const BlenderStartupTemplateChooser({
    super.key,
    required this.templates,
    required this.onTemplateSelected,
    this.resources = const <BlenderStartupTemplateEntry>[],
    this.onResourceSelected,
  });

  final List<BlenderStartupTemplateEntry> templates;
  final ValueChanged<BlenderStartupTemplateEntry> onTemplateSelected;
  final List<BlenderStartupTemplateEntry> resources;
  final ValueChanged<BlenderStartupTemplateEntry>? onResourceSelected;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    Widget column(
      String title,
      List<BlenderStartupTemplateEntry> entries,
      ValueChanged<BlenderStartupTemplateEntry> onSelected,
    ) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(title, style: theme.textTheme.heading),
        const SizedBox(height: 4),
        for (final entry in entries)
          BlenderButton(
            key: ValueKey<String>('startup-template-${entry.id}'),
            label: entry.label,
            variant: BlenderButtonVariant.menu,
            leading: BlenderIcon(entry.glyph, size: 22),
            onPressed: () => onSelected(entry),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            showBorder: false,
          ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: column('New File', templates, onTemplateSelected)),
          if (resources.isNotEmpty) ...<Widget>[
            const SizedBox(width: 30),
            Expanded(
              child: column(
                'Getting Started',
                resources,
                onResourceSelected ?? (_) {},
              ),
            ),
          ],
        ],
      ),
    );
  }
}
