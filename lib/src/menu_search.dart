import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'controls.dart';
import 'icons.dart';
import 'services.dart';
import 'theme.dart';

/// Blender's command-backed Menu Search surface.
///
/// Unlike [BlenderSearchField], this widget owns selection navigation and
/// command presentation. The registry owns command metadata, fuzzy ranking,
/// recent use, enabled state, and execution.
class BlenderMenuSearch extends StatefulWidget {
  const BlenderMenuSearch({
    super.key,
    required this.commands,
    required this.onSelected,
    this.onDismiss,
    this.controller,
    this.maxResults = 50,
    this.autofocus = true,
  });

  final BlenderCommandRegistry commands;
  final ValueChanged<BlenderCommand> onSelected;
  final VoidCallback? onDismiss;
  final TextEditingController? controller;
  final int maxResults;
  final bool autofocus;

  @override
  State<BlenderMenuSearch> createState() => _BlenderMenuSearchState();
}

class _BlenderMenuSearchState extends State<BlenderMenuSearch> {
  late final TextEditingController _controller;
  late final bool _ownsController;
  final FocusNode _searchFocus = FocusNode(debugLabel: 'BlenderMenuSearch');
  final ScrollController _scroll = ScrollController();
  int _selectedIndex = 0;

  List<BlenderCommand> get _results =>
      widget.commands.search(_controller.text, maxResults: widget.maxResults);

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_queryChanged);
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_queryChanged);
    if (_ownsController) _controller.dispose();
    _searchFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _queryChanged() {
    if (!mounted) return;
    setState(() => _selectedIndex = 0);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _moveSelection(int delta) {
    final results = _results;
    if (results.isEmpty) return;
    setState(() {
      _selectedIndex = (_selectedIndex + delta).clamp(0, results.length - 1);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      const rowHeight = 31.0;
      final target = (_selectedIndex * rowHeight).clamp(
        _scroll.position.minScrollExtent,
        _scroll.position.maxScrollExtent,
      );
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
      );
    });
  }

  void _activateSelection() {
    final results = _results;
    if (results.isEmpty) return;
    final index = _selectedIndex.clamp(0, results.length - 1);
    final command = results[index];
    if (command.isEnabled) widget.onSelected(command);
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            _moveSelection(1),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
            _moveSelection(-1),
        const SingleActivator(LogicalKeyboardKey.enter): _activateSelection,
        const SingleActivator(LogicalKeyboardKey.numpadEnter):
            _activateSelection,
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            widget.onDismiss?.call(),
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.menuBackground,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 18,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              BlenderSearchField(
                key: const ValueKey<String>('menu-search-field'),
                controller: _controller,
                focusNode: _searchFocus,
                placeholder: '',
                onSubmitted: (_) => _activateSelection(),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: AnimatedBuilder(
                  animation: widget.commands,
                  builder: (context, child) =>
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _controller,
                        builder: (context, value, child) {
                          final results = _results;
                          if (results.isEmpty) {
                            return Center(
                              child: Text(
                                'No matching menu items',
                                style: theme.textTheme.body.copyWith(
                                  color: theme.colors.foregroundMuted,
                                ),
                              ),
                            );
                          }
                          final selected = math.min(
                            _selectedIndex,
                            results.length - 1,
                          );
                          return ListView.builder(
                            key: const ValueKey<String>('menu-search-results'),
                            controller: _scroll,
                            itemExtent: 31,
                            itemCount: results.length,
                            itemBuilder: (context, index) => _resultRow(
                              context,
                              results[index],
                              selected: index == selected,
                              index: index,
                            ),
                          );
                        },
                      ),
                ),
              ),
              const SizedBox(height: 2),
              BlenderIcon(
                BlenderGlyph.chevronDown,
                size: 13,
                color: theme.colors.foreground,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultRow(
    BuildContext context,
    BlenderCommand command, {
    required bool selected,
    required int index,
  }) {
    final theme = BlenderTheme.of(context);
    final path = command.menuPath.isEmpty
        ? ''
        : '${command.menuPath.join(' › ')} › ';
    final enabled = command.isEnabled;
    final foreground = enabled
        ? theme.colors.foreground
        : theme.colors.foregroundDisabled;
    return MouseRegion(
      onEnter: (_) => setState(() => _selectedIndex = index),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => widget.onSelected(command) : null,
        child: Container(
          key: ValueKey<String>('menu-search-command-${command.id}'),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: selected
                ? theme.colors.buttonHover
                : const Color(0x00000000),
            borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      if (path.isNotEmpty)
                        TextSpan(
                          text: path,
                          style: theme.textTheme.body.copyWith(
                            color: theme.colors.foregroundMuted,
                          ),
                        ),
                      if (command.glyph != null)
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: BlenderIcon(
                              command.glyph!,
                              size: 17,
                              color: foreground,
                            ),
                          ),
                        ),
                      TextSpan(
                        text: command.label,
                        style: theme.textTheme.body.copyWith(color: foreground),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (command.shortcut case final shortcut?) ...<Widget>[
                const SizedBox(width: 12),
                Text(
                  shortcut,
                  style: theme.textTheme.caption.copyWith(
                    color: theme.colors.foregroundMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens [BlenderMenuSearch] as Blender's centered Menu Search popup.
Future<void> showBlenderMenuSearch({
  required BuildContext context,
  BlenderCommandRegistry? commands,
  String initialQuery = '',
  int maxResults = 50,
}) async {
  final registry =
      commands ?? BlenderServiceScope.read<BlenderCommandRegistry>(context);
  final controller = TextEditingController(text: initialQuery);
  final liveTheme = BlenderThemeScope.maybeOf(context);
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss menu search',
    barrierColor: const Color(0x22000000),
    transitionDuration: const Duration(milliseconds: 90),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      Widget popup = SafeArea(
        child: Align(
          alignment: const Alignment(0, -.28),
          child: FractionallySizedBox(
            widthFactor: .86,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 420,
                maxWidth: 900,
                maxHeight: 520,
              ),
              child: SizedBox(
                height: math.min(
                  520,
                  MediaQuery.sizeOf(dialogContext).height * .72,
                ),
                child: BlenderMenuSearch(
                  commands: registry,
                  controller: controller,
                  maxResults: maxResults,
                  onDismiss: () => Navigator.of(dialogContext).pop(),
                  onSelected: (command) {
                    Navigator.of(dialogContext).pop();
                    unawaited(registry.execute(command.id));
                  },
                ),
              ),
            ),
          ),
        ),
      );
      if (liveTheme != null) {
        popup = AnimatedBuilder(
          animation: liveTheme,
          builder: (context, child) => BlenderTheme(
            data: liveTheme.data,
            child: DefaultTextStyle(
              style: liveTheme.data.textTheme.body,
              child: child!,
            ),
          ),
          child: popup,
        );
      }
      return InheritedTheme.captureAll(context, popup);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
  controller.dispose();
}
