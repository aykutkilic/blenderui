part of '../non3d_editors.dart';

/// Compatibility descriptor for hosts that only need a read-only shortcut
/// list. New Preferences surfaces should pass [bindings] and [commands] to
/// [BlenderKeymapEditor] so edits affect runtime dispatch immediately.
class BlenderKeymapEntry {
  const BlenderKeymapEntry({
    required this.id,
    required this.action,
    required this.shortcut,
    this.category = 'General',
    this.detail,
    this.enabled = true,
  });

  final String id;
  final String action;
  final String shortcut;
  final String category;
  final String? detail;
  final bool enabled;
}

/// Blender-style Keymap Preferences surface backed by the runtime command and
/// keymap services. It also retains the original static-entry mode for compact
/// catalogs and migration compatibility.
class BlenderKeymapEditor extends StatefulWidget {
  const BlenderKeymapEditor({
    super.key,
    required this.searchController,
    this.entries = const <BlenderKeymapEntry>[],
    this.bindings,
    this.commands,
    this.selectedId,
    this.onSelected,
    this.title = 'Keymap',
    this.onImport,
    this.onExport,
  });

  final List<BlenderKeymapEntry> entries;
  final BlenderCommandBindings? bindings;
  final BlenderCommandRegistry? commands;
  final TextEditingController searchController;
  final String? selectedId;
  final ValueChanged<BlenderKeymapEntry>? onSelected;
  final String title;
  final VoidCallback? onImport;
  final ValueChanged<String>? onExport;

  @override
  State<BlenderKeymapEditor> createState() => _BlenderKeymapEditorState();
}

class _BlenderKeymapEditorState extends State<BlenderKeymapEditor> {
  BlenderKeymapFilterType _filterType = BlenderKeymapFilterType.name;
  final Set<String> _expandedKeymaps = <String>{'Window'};
  final Set<String> _expandedItems = <String>{};
  String? _conflictMessage;

  bool get _isLive => widget.bindings != null && widget.commands != null;

  @override
  Widget build(BuildContext context) {
    final listenables = <Listenable>[widget.searchController];
    if (widget.bindings case final bindings?) listenables.add(bindings);
    if (widget.commands case final commands?) listenables.add(commands);
    return BlenderPanel(
      title: widget.title,
      padding: EdgeInsets.zero,
      child: AnimatedBuilder(
        animation: Listenable.merge(listenables),
        builder: (context, _) => _isLive ? _buildLive() : _buildStatic(),
      ),
    );
  }

  Widget _buildLive() {
    final bindings = widget.bindings!;
    final query = widget.searchController.text.trim().toLowerCase();
    final visible = bindings.bindings
        .where((binding) {
          if (query.isEmpty) return true;
          if (_filterType == BlenderKeymapFilterType.keyBinding) {
            return binding.shortcutLabel.toLowerCase().contains(query);
          }
          final command = widget.commands![binding.commandId];
          return binding.commandId.toLowerCase().contains(query) ||
              binding.keymap.toLowerCase().contains(query) ||
              (command?.label.toLowerCase().contains(query) ?? false);
        })
        .toList(growable: false);
    final groups = <String, List<BlenderCommandBinding>>{};
    for (final binding in visible) {
      groups
          .putIfAbsent(binding.keymap, () => <BlenderCommandBinding>[])
          .add(binding);
    }
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: BlenderDropdown<String>(
                      value: bindings.configurationName,
                      items: <BlenderMenuItem<String>>[
                        BlenderMenuItem<String>(
                          value: bindings.configurationName,
                          label: bindings.configurationName,
                        ),
                      ],
                      onChanged: null,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const BlenderIconButton(
                    glyph: BlenderGlyph.plus,
                    tooltip: 'Add Preset',
                    onPressed: null,
                  ),
                  const BlenderIconButton(
                    glyph: BlenderGlyph.minus,
                    tooltip: 'Remove Preset',
                    onPressed: null,
                  ),
                  const Spacer(),
                  BlenderButton(label: 'Import...', onPressed: widget.onImport),
                  const SizedBox(width: 3),
                  BlenderButton(
                    label: 'Export...',
                    onPressed: widget.onExport == null
                        ? null
                        : () =>
                              widget.onExport!(bindings.exportConfiguration()),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 170,
                    child: BlenderDropdown<BlenderKeymapFilterType>(
                      value: _filterType,
                      items: const <BlenderMenuItem<BlenderKeymapFilterType>>[
                        BlenderMenuItem(
                          value: BlenderKeymapFilterType.name,
                          label: 'Name',
                        ),
                        BlenderMenuItem(
                          value: BlenderKeymapFilterType.keyBinding,
                          label: 'Key-Binding',
                        ),
                      ],
                      onChanged: (value) => setState(() => _filterType = value),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: BlenderFilterBar(
                      controller: widget.searchController,
                      placeholder: _filterType == BlenderKeymapFilterType.name
                          ? 'Search by Name'
                          : 'Search by Key-Binding',
                    ),
                  ),
                ],
              ),
              if (_conflictMessage case final message?)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      message,
                      style: BlenderTheme.of(context).textTheme.caption
                          .copyWith(
                            color: BlenderTheme.of(context).colors.error,
                          ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: groups.isEmpty
              ? const Center(child: Text('No matching keymap items'))
              : ListView(
                  children: <Widget>[
                    for (final group in groups.entries)
                      _buildKeymap(group.key, group.value),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildKeymap(String name, List<BlenderCommandBinding> items) {
    final expanded =
        _expandedKeymaps.contains(name) ||
        widget.searchController.text.trim().isNotEmpty;
    final modified = items.any((item) => item.isModified);
    return Column(
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() {
            expanded
                ? _expandedKeymaps.remove(name)
                : _expandedKeymaps.add(name);
          }),
          child: SizedBox(
            height: BlenderTheme.of(context).density.rowHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Row(
                children: <Widget>[
                  BlenderIcon(
                    expanded
                        ? BlenderGlyph.panelDisclosureDown
                        : BlenderGlyph.panelDisclosureRight,
                    size: 11,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      name,
                      style: BlenderTheme.of(context).textTheme.label,
                    ),
                  ),
                  if (modified)
                    BlenderButton(
                      label: 'Restore',
                      onPressed: () => widget.bindings!.resetKeymap(name),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (expanded)
          for (final item in items) _buildBinding(item),
      ],
    );
  }

  Widget _buildBinding(BlenderCommandBinding binding) {
    final theme = BlenderTheme.of(context);
    final expanded = _expandedItems.contains(binding.id);
    final command = widget.commands![binding.commandId];
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 5),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: theme.density.rowHeight,
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () => setState(() {
                    expanded
                        ? _expandedItems.remove(binding.id)
                        : _expandedItems.add(binding.id);
                  }),
                  child: BlenderIcon(
                    expanded
                        ? BlenderGlyph.panelDisclosureDown
                        : BlenderGlyph.panelDisclosureRight,
                    size: 10,
                  ),
                ),
                const SizedBox(width: 5),
                BlenderCheckbox(
                  value: binding.enabled,
                  onChanged: (value) =>
                      widget.bindings!.setEnabled(binding.id, value),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    command?.label ?? '${binding.commandId} (unavailable)',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.label.copyWith(
                      color: command == null ? theme.colors.error : null,
                    ),
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: BlenderShortcutRecorder(
                    value: binding.activator,
                    onChanged: (activator) => _rebind(binding, activator),
                  ),
                ),
                const SizedBox(width: 3),
                BlenderButton(
                  label: binding.isModified ? '↶' : '×',
                  onPressed: binding.isModified
                      ? () => widget.bindings!.reset(binding.id)
                      : binding.userDefined
                      ? () => widget.bindings!.remove(binding.id)
                      : null,
                ),
              ],
            ),
          ),
          if (expanded)
            Container(
              margin: const EdgeInsets.only(left: 16, bottom: 4),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: theme.colors.panelBackground,
                border: Border.all(color: theme.colors.borderSubtle),
                borderRadius: BorderRadius.circular(theme.shapes.panelRadius),
              ),
              child: Column(
                children: <Widget>[
                  _detailRow('Operator', binding.commandId),
                  _detailRow(
                    'Event Type',
                    binding.eventType.name.toUpperCase(),
                  ),
                  _detailRow('Value', binding.eventValue),
                  _detailRow('Context', binding.context),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: BlenderCheckbox(
                      value: binding.repeat,
                      label: 'Repeat',
                      onChanged: (value) {
                        widget.bindings!.update(
                          binding.id,
                          binding.copyWith(repeat: value),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Row(
      children: <Widget>[
        SizedBox(
          width: 95,
          child: Text(label, style: BlenderTheme.of(context).textTheme.caption),
        ),
        Expanded(
          child: Text(value, style: BlenderTheme.of(context).textTheme.label),
        ),
      ],
    ),
  );

  void _rebind(BlenderCommandBinding binding, ShortcutActivator activator) {
    final conflicts = widget.bindings!.update(
      binding.id,
      binding.copyWith(activator: activator),
    );
    setState(() {
      _conflictMessage = conflicts.isEmpty
          ? null
          : '${BlenderShortcutCodec.label(activator)} is already assigned to '
                '${widget.commands![conflicts.first.second.commandId]?.label ?? conflicts.first.second.commandId} '
                'in ${binding.keymap}.';
    });
  }

  Widget _buildStatic() {
    final query = widget.searchController.text.trim().toLowerCase();
    final visible = widget.entries
        .where(
          (entry) =>
              query.isEmpty ||
              entry.action.toLowerCase().contains(query) ||
              entry.shortcut.toLowerCase().contains(query) ||
              entry.category.toLowerCase().contains(query) ||
              (entry.detail?.toLowerCase().contains(query) ?? false),
        )
        .toList(growable: false);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
          child: BlenderFilterBar(
            controller: widget.searchController,
            placeholder: 'Search keymap',
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? const Center(child: Text('No shortcuts'))
              : ListView.builder(
                  itemCount: visible.length,
                  itemExtent: BlenderTheme.of(context).density.rowHeight,
                  itemBuilder: (context, index) {
                    final entry = visible[index];
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: entry.enabled && widget.onSelected != null
                          ? () => widget.onSelected!(entry)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text('${entry.category}: ${entry.action}'),
                            ),
                            BlenderKeycap(entry.shortcut),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Focusable Blender-style event field. Clicking it starts capture; the next
/// non-modifier key stores the complete modifier chord. Escape cancels.
class BlenderShortcutRecorder extends StatefulWidget {
  const BlenderShortcutRecorder({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ShortcutActivator value;
  final ValueChanged<ShortcutActivator> onChanged;

  @override
  State<BlenderShortcutRecorder> createState() =>
      _BlenderShortcutRecorderState();
}

class _BlenderShortcutRecorderState extends State<BlenderShortcutRecorder> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'BlenderShortcutRecorder');
  bool _recording = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Focus(
    focusNode: _focusNode,
    onKeyEvent: (_, event) {
      if (!_recording || event is! KeyDownEvent) return KeyEventResult.ignored;
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        setState(() => _recording = false);
        return KeyEventResult.handled;
      }
      if (_modifierKeys.contains(event.logicalKey))
        return KeyEventResult.handled;
      final keyboard = HardwareKeyboard.instance;
      widget.onChanged(
        SingleActivator(
          event.logicalKey,
          control: keyboard.isControlPressed,
          shift: keyboard.isShiftPressed,
          alt: keyboard.isAltPressed,
          meta: keyboard.isMetaPressed,
        ),
      );
      setState(() => _recording = false);
      return KeyEventResult.handled;
    },
    child: BlenderButton(
      label: _recording
          ? 'Press a key…'
          : BlenderShortcutCodec.label(widget.value),
      selected: _recording,
      onPressed: () {
        setState(() => _recording = true);
        _focusNode.requestFocus();
      },
    ),
  );
}

final List<LogicalKeyboardKey> _modifierKeys = <LogicalKeyboardKey>[
  LogicalKeyboardKey.control,
  LogicalKeyboardKey.controlLeft,
  LogicalKeyboardKey.controlRight,
  LogicalKeyboardKey.shift,
  LogicalKeyboardKey.shiftLeft,
  LogicalKeyboardKey.shiftRight,
  LogicalKeyboardKey.alt,
  LogicalKeyboardKey.altLeft,
  LogicalKeyboardKey.altRight,
  LogicalKeyboardKey.meta,
  LogicalKeyboardKey.metaLeft,
  LogicalKeyboardKey.metaRight,
];
