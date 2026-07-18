part of '../specialized_templates.dart';

enum BlenderLightLinkingState { include, exclude }

/// A row in Blender's light-linking collection tree.
@immutable
class BlenderLightLinkingItem {
  const BlenderLightLinkingItem({
    required this.id,
    required this.label,
    this.icon = BlenderGlyph.object,
    this.state = BlenderLightLinkingState.include,
    this.enabled = true,
    this.onStateChanged,
  });

  final String id;
  final String label;
  final BlenderGlyph icon;
  final BlenderLightLinkingState state;
  final bool enabled;
  final ValueChanged<BlenderLightLinkingState>? onStateChanged;
}

/// A compact collection tree with include/exclude state buttons.
class BlenderLightLinkingCollection extends StatefulWidget {
  const BlenderLightLinkingCollection({
    super.key,
    required this.items,
    this.title = 'Light Linking',
    this.collectionLabel = 'Linking Collection',
    this.emptyLabel = 'No linked objects or collections',
  });

  final List<BlenderLightLinkingItem> items;
  final String title;
  final String collectionLabel;
  final String emptyLabel;

  @override
  State<BlenderLightLinkingCollection> createState() =>
      _BlenderLightLinkingCollectionState();
}

class _BlenderLightLinkingCollectionState
    extends State<BlenderLightLinkingCollection> {
  late final TextEditingController _collectionController;

  @override
  void initState() {
    super.initState();
    _collectionController = TextEditingController(text: widget.collectionLabel);
  }

  @override
  void didUpdateWidget(BlenderLightLinkingCollection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collectionLabel != widget.collectionLabel &&
        _collectionController.text != widget.collectionLabel) {
      _collectionController.text = widget.collectionLabel;
    }
  }

  @override
  void dispose() {
    _collectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: widget.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          BlenderTextField(
            controller: _collectionController,
            readOnly: true,
            leading: const BlenderIcon(BlenderGlyph.collection, size: 14),
          ),
          const SizedBox(height: 5),
          if (widget.items.isEmpty)
            Text(
              widget.emptyLabel,
              style: theme.textTheme.caption.copyWith(
                color: theme.colors.foregroundMuted,
              ),
            )
          else
            for (final item in widget.items)
              SizedBox(
                height: theme.density.rowHeight,
                child: Row(
                  children: <Widget>[
                    BlenderIcon(item.icon, size: 15),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.label,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.label.copyWith(
                          color: item.enabled
                              ? theme.colors.foreground
                              : theme.colors.foregroundDisabled,
                        ),
                      ),
                    ),
                    BlenderCheckbox(
                      value: item.state == BlenderLightLinkingState.include,
                      enabled: item.enabled,
                      onChanged: item.onStateChanged == null
                          ? null
                          : (include) => item.onStateChanged!(
                              include
                                  ? BlenderLightLinkingState.include
                                  : BlenderLightLinkingState.exclude,
                            ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
