part of '../property_templates.dart';

/// One host-owned object that can be assigned through [BlenderObjectPicker].
@immutable
class BlenderObjectPickerOption<T extends Object> {
  const BlenderObjectPickerOption({
    required this.value,
    required this.label,
    this.icon,
    this.detail,
    this.searchTerms = const <String>[],
    this.enabled = true,
  });

  final T value;
  final String label;
  final BlenderGlyph? icon;
  final String? detail;
  final List<String> searchTerms;
  final bool enabled;

  bool matches(String query) {
    if (query.isEmpty) return true;
    return label.toLowerCase().contains(query) ||
        (detail?.toLowerCase().contains(query) ?? false) ||
        searchTerms.any((term) => term.toLowerCase().contains(query));
  }
}

/// A searchable pointer-property control matching Blender's `prop_search`.
///
/// BlenderUI owns the field, filtering, unresolved-value presentation, and
/// clear/eyedropper affordances. The embedding application owns the object
/// catalog, the assigned value, and any modal picking behavior because only
/// the host can resolve clicks in its viewport or hierarchy.
class BlenderObjectPicker<T extends Object> extends StatefulWidget {
  const BlenderObjectPicker({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.objectTypeIcon = BlenderGlyph.object,
    this.placeholder = 'Object',
    this.searchPlaceholder,
    this.emptyLabel = 'No results found',
    this.unresolvedLabelBuilder,
    this.onPick,
    this.picking = false,
    this.enabled = true,
    this.popupMinWidth = 280,
    this.popupMaxHeight = 320,
    this.clearTooltip = 'Unlink object',
    this.pickTooltip = 'Pick object',
  });

  final T? value;
  final List<BlenderObjectPickerOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final BlenderGlyph objectTypeIcon;
  final String placeholder;
  final String? searchPlaceholder;
  final String emptyLabel;

  /// Labels a persisted reference that is not present in [options].
  ///
  /// Such references remain visible and clearable instead of being silently
  /// presented as null, allowing hosts to repair stale links without losing
  /// their original identity.
  final String Function(T value)? unresolvedLabelBuilder;

  /// Activates host-owned modal picking, analogous to Blender's ID eyedropper.
  final VoidCallback? onPick;
  final bool picking;
  final bool enabled;
  final double popupMinWidth;
  final double popupMaxHeight;
  final String clearTooltip;
  final String pickTooltip;

  @override
  State<BlenderObjectPicker<T>> createState() => _BlenderObjectPickerState<T>();
}

class _BlenderObjectPickerState<T extends Object>
    extends State<BlenderObjectPicker<T>> {
  late final TextEditingController _displayController;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _displayController = TextEditingController(text: _selectedLabel);
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant BlenderObjectPicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final label = _selectedLabel;
    if (_displayController.text != label) {
      _displayController.value = TextEditingValue(
        text: label,
        selection: TextSelection.collapsed(offset: label.length),
      );
    }
  }

  @override
  void dispose() {
    _displayController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  BlenderObjectPickerOption<T>? get _selectedOption {
    for (final option in widget.options) {
      if (option.value == widget.value) return option;
    }
    return null;
  }

  String get _selectedLabel {
    final selected = _selectedOption;
    if (selected != null) return selected.label;
    final value = widget.value;
    if (value == null) return '';
    return widget.unresolvedLabelBuilder?.call(value) ?? value.toString();
  }

  List<BlenderObjectPickerOption<T>> _visibleOptions(String text) {
    final query = text.trim().toLowerCase();
    return widget.options
        .where((option) => option.matches(query))
        .toList(growable: false);
  }

  void _handleOpenChanged(bool open) {
    if (!open) {
      _searchFocusNode.unfocus();
      return;
    }
    _searchController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  void _select(BlenderObjectPickerOption<T> option, VoidCallback close) {
    if (!option.enabled || widget.onChanged == null) return;
    widget.onChanged!(option.value);
    close();
  }

  void _submitSearch(String text, VoidCallback close) {
    final visible = _visibleOptions(
      text,
    ).where((option) => option.enabled).toList(growable: false);
    if (visible.isNotEmpty) _select(visible.first, close);
  }

  Widget? _trailingAction() {
    if (widget.value != null && widget.onChanged != null) {
      return BlenderIconButton(
        key: const ValueKey<String>('blender-object-picker-clear'),
        glyph: BlenderGlyph.close,
        tooltip: widget.clearTooltip,
        enabled: widget.enabled,
        onPressed: widget.enabled ? () => widget.onChanged!(null) : null,
        size: 19,
        iconSize: 12,
        showBorder: false,
        scaleWithDensity: false,
        variant: BlenderButtonVariant.menu,
      );
    }
    if (widget.onPick == null) return null;
    return BlenderIconButton(
      key: const ValueKey<String>('blender-object-picker-pick'),
      glyph: BlenderGlyph.eyedropper,
      tooltip: widget.pickTooltip,
      selected: widget.picking,
      enabled: widget.enabled,
      onPressed: widget.enabled ? widget.onPick : null,
      size: 19,
      iconSize: 14,
      showBorder: false,
      scaleWithDensity: false,
      variant: BlenderButtonVariant.menu,
    );
  }

  Widget _field({Widget? trailing}) {
    final selected = _selectedOption;
    return BlenderTextField(
      key: const ValueKey<String>('blender-object-picker-field'),
      controller: _displayController,
      label: 'Browse ${widget.placeholder}',
      placeholder: widget.placeholder,
      leading: BlenderIcon(selected?.icon ?? widget.objectTypeIcon, size: 14),
      trailing: trailing,
      readOnly: true,
      enabled: widget.enabled,
    );
  }

  Widget _popup(BuildContext context, VoidCallback close, double anchorWidth) {
    final theme = BlenderTheme.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_searchFocusNode.hasFocus) {
        _searchFocusNode.requestFocus();
      }
    });
    return SizedBox(
      width: anchorWidth < widget.popupMinWidth
          ? widget.popupMinWidth
          : anchorWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          BlenderTextField(
            key: const ValueKey<String>('blender-object-picker-search'),
            controller: _searchController,
            focusNode: _searchFocusNode,
            placeholder: widget.searchPlaceholder ?? widget.placeholder,
            leading: BlenderIcon(widget.objectTypeIcon, size: 14),
            trailing: widget.onPick == null
                ? null
                : const BlenderIcon(BlenderGlyph.eyedropper, size: 14),
            onSubmitted: (text) => _submitSearch(text, close),
          ),
          const SizedBox(height: 2),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: widget.popupMaxHeight),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.menuBackground,
                border: Border.all(color: theme.colors.borderSubtle),
                borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
              ),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, search, child) {
                  final visible = _visibleOptions(search.text);
                  return BlenderListView<T>(
                    items: <BlenderListItem<T>>[
                      for (final indexed in visible.indexed)
                        BlenderListItem<T>(
                          id: '${indexed.$1}',
                          label: indexed.$2.label,
                          value: indexed.$2.value,
                          icon: indexed.$2.icon ?? widget.objectTypeIcon,
                          detail: indexed.$2.detail,
                          enabled: indexed.$2.enabled,
                        ),
                    ],
                    selectedId: _selectedOption == null
                        ? null
                        : '${visible.indexOf(_selectedOption!)}',
                    emptyLabel: widget.emptyLabel,
                    onSelected: widget.onChanged == null
                        ? null
                        : (item) {
                            final value = item.value;
                            if (value == null) return;
                            final option = visible.firstWhere(
                              (candidate) => candidate.value == value,
                            );
                            _select(option, close);
                          },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Blender opens prop_search even when its filtered collection is empty.
    // Keeping the popup reachable lets the user see the explicit empty state
    // instead of making an empty catalog look like a broken text field.
    final canBrowse = widget.enabled && widget.onChanged != null;
    return LayoutBuilder(
      builder: (context, constraints) {
        final anchorWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : widget.popupMinWidth;
        final trailingAction = _trailingAction();
        return Semantics(
          container: true,
          button: canBrowse,
          enabled: widget.enabled,
          label: 'Browse ${widget.placeholder}',
          child: Stack(
            children: <Widget>[
              BlenderPopover(
                offset: Offset.zero,
                targetAnchor: Alignment.topLeft,
                followerAnchor: Alignment.topLeft,
                openOnTap: canBrowse,
                onOpenChanged: _handleOpenChanged,
                popover: (context, close) =>
                    _popup(context, close, anchorWidth),
                child: IgnorePointer(
                  child: _field(
                    trailing: trailingAction == null
                        ? null
                        : const SizedBox(width: 19),
                  ),
                ),
              ),
              if (trailingAction != null)
                Positioned(
                  right: 1,
                  top: 0,
                  bottom: 0,
                  child: Center(child: trailingAction),
                ),
            ],
          ),
        );
      },
    );
  }
}
