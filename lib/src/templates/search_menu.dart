part of '../templates.dart';

/// A searchable menu surface for operator, enum, and command pickers.
class BlenderSearchMenu<T> extends StatelessWidget {
  const BlenderSearchMenu({
    super.key,
    required this.controller,
    required this.items,
    required this.onSelected,
    this.title = 'Search',
    this.previewRows = 0,
    this.previewColumns = 0,
    this.previewTileHeight = 84,
  });

  final TextEditingController controller;
  final List<BlenderMenuItem<T>> items;
  final ValueChanged<BlenderMenuItem<T>> onSelected;
  final String title;
  final int previewRows;
  final int previewColumns;
  final double previewTileHeight;

  @override
  Widget build(BuildContext context) {
    return BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          final query = value.text.trim().toLowerCase();
          final visible = items
              .where((item) => item.label.toLowerCase().contains(query))
              .toList(growable: false);
          final usePreviewGrid = previewRows > 0 && previewColumns > 0;
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4),
                child: BlenderSearchField(
                  controller: controller,
                  placeholder: 'Search operators',
                ),
              ),
              Expanded(
                child: usePreviewGrid
                    ? GridView.builder(
                        padding: const EdgeInsets.all(5),
                        itemCount: visible.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: previewColumns,
                          mainAxisExtent: previewTileHeight,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemBuilder: (context, index) {
                          final item = visible[index];
                          return BlenderPreviewTile(
                            label: item.label,
                            preview: item.icon == null
                                ? null
                                : Center(child: item.icon),
                            width: double.infinity,
                            height: previewTileHeight,
                            onPressed: item.enabled
                                ? () => onSelected(item)
                                : null,
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final item = visible[index];
                          return BlenderButton(
                            label: item.label,
                            variant: BlenderButtonVariant.menu,
                            leading: item.icon,
                            trailing: item.shortcut == null
                                ? null
                                : Text(item.shortcut!),
                            enabled: item.enabled,
                            onPressed: item.enabled
                                ? () => onSelected(item)
                                : null,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
