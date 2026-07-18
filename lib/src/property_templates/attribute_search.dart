part of '../property_templates.dart';

/// A data-only attribute entry for [BlenderAttributeSearch].
@immutable
class BlenderAttributeOption<T> {
  const BlenderAttributeOption({
    required this.name,
    required this.value,
    this.domain = 'Point',
    this.dataType = 'Float',
    this.enabled = true,
  });

  final String name;
  final T value;
  final String domain;
  final String dataType;
  final bool enabled;

  String get displayLabel => '$domain  →  $name  ·  $dataType';
}

/// A searchable attribute picker matching Blender's domain/name/type menu.
///
/// The widget intentionally does not assume a Blender data model. Callers
/// provide the available attributes and receive either an existing value or a
/// newly typed name through [onCreate].
class BlenderAttributeSearch<T> extends StatefulWidget {
  const BlenderAttributeSearch({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.onCreate,
    this.onClear,
    this.placeholder = 'Attribute',
    this.title = 'Search Attributes',
    this.allowCreate = true,
    this.popupWidth = 320,
    this.popupHeight = 280,
  });

  final List<BlenderAttributeOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final ValueChanged<String>? onCreate;
  final VoidCallback? onClear;
  final String placeholder;
  final String title;
  final bool allowCreate;
  final double popupWidth;
  final double popupHeight;

  @override
  State<BlenderAttributeSearch<T>> createState() =>
      _BlenderAttributeSearchState<T>();
}

class _BlenderAttributeSearchState<T> extends State<BlenderAttributeSearch<T>> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _selectedLabel {
    for (final option in widget.options) {
      if (option.value == widget.value) return option.name;
    }
    return widget.placeholder;
  }

  void _resetSearch(bool open) {
    if (open) _controller.clear();
  }

  Widget _buildPopup(BuildContext context, VoidCallback close) {
    final theme = BlenderTheme.of(context);
    return SizedBox(
      width: widget.popupWidth,
      height: widget.popupHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.menuBackground,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
        ),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, child) {
            final query = value.text.trim().toLowerCase();
            final visible = widget.options
                .where(
                  (option) =>
                      option.enabled &&
                      (query.isEmpty ||
                          option.name.toLowerCase().contains(query) ||
                          option.domain.toLowerCase().contains(query) ||
                          option.dataType.toLowerCase().contains(query)),
                )
                .toList(growable: false);
            final exact = widget.options.any(
              (option) => option.name.toLowerCase() == query,
            );
            final canCreate =
                widget.allowCreate &&
                widget.onCreate != null &&
                query.isNotEmpty &&
                !exact;
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: BlenderSearchField(
                    controller: _controller,
                    placeholder: widget.title,
                  ),
                ),
                if (widget.onClear != null && widget.value != null)
                  BlenderButton(
                    label: 'Clear attribute',
                    variant: BlenderButtonVariant.menu,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: () {
                      widget.onClear!();
                      close();
                    },
                  ),
                Expanded(
                  child: visible.isEmpty && !canCreate
                      ? Center(
                          child: Text(
                            'No matching attributes',
                            style: theme.textTheme.caption.copyWith(
                              color: theme.colors.foregroundMuted,
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 4),
                          children: <Widget>[
                            if (canCreate)
                              BlenderButton(
                                label: 'Create "$query"',
                                leading: const BlenderIcon(
                                  BlenderGlyph.plus,
                                  size: 13,
                                ),
                                variant: BlenderButtonVariant.menu,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                onPressed: () {
                                  widget.onCreate!(value.text.trim());
                                  close();
                                },
                              ),
                            for (final option in visible)
                              BlenderButton(
                                label: option.displayLabel,
                                variant: BlenderButtonVariant.menu,
                                selected: option.value == widget.value,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                onPressed: () {
                                  widget.onChanged?.call(option.value);
                                  close();
                                },
                              ),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlenderPopover(
      onOpenChanged: _resetSearch,
      child: IgnorePointer(
        child: BlenderButton(
          label: _selectedLabel,
          trailing: const BlenderIcon(
            BlenderGlyph.panelDisclosureDown,
            size: 9,
          ),
          onPressed: () {},
          enabled: widget.onChanged != null || widget.onCreate != null,
        ),
      ),
      popover: _buildPopup,
    );
  }
}
