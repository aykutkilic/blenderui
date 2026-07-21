part of '../services.dart';

/// Metadata and executable behavior for menus, toolbars, shortcuts, and
/// command search surfaces.
class BlenderCommand {
  const BlenderCommand({
    required this.id,
    required this.label,
    required this.execute,
    this.description,
    this.shortcut,
    this.enabled,
    this.menuPath = const <String>[],
    this.searchTerms = const <String>[],
    this.searchWeight = 0,
    this.searchable = true,
    this.deprecated = false,
    this.glyph,
  });

  final String id;
  final String label;
  final String? description;
  final String? shortcut;
  final BlenderCommandCallback execute;
  final bool Function()? enabled;
  final List<String> menuPath;
  final List<String> searchTerms;
  final int searchWeight;
  final bool searchable;
  final bool deprecated;
  final BlenderGlyph? glyph;

  bool get isEnabled => enabled?.call() ?? true;
}

/// Application-level command catalog that can back buttons, menus, keymaps,
/// and operator search without coupling those surfaces to domain objects.
class BlenderCommandRegistry extends ChangeNotifier
    implements BlenderServiceDisposable {
  final LinkedHashMap<String, BlenderCommand> _commands =
      LinkedHashMap<String, BlenderCommand>();
  final List<String> _recentCommandIds = <String>[];

  List<BlenderCommand> get commands =>
      List<BlenderCommand>.unmodifiable(_commands.values);

  List<String> get recentCommandIds =>
      List<String>.unmodifiable(_recentCommandIds);

  void register(BlenderCommand command) {
    if (_commands.containsKey(command.id)) {
      throw StateError('A command with id "${command.id}" already exists.');
    }
    _commands[command.id] = command;
    notifyListeners();
  }

  bool unregister(String id) {
    final removed = _commands.remove(id) != null;
    if (removed) notifyListeners();
    return removed;
  }

  BlenderCommand? operator [](String id) => _commands[id];

  Future<bool> execute(String id) async {
    final command = _commands[id];
    if (command == null || !command.isEnabled) return false;
    await command.execute();
    _recentCommandIds
      ..remove(id)
      ..insert(0, id);
    if (_recentCommandIds.length > 32) _recentCommandIds.removeLast();
    notifyListeners();
    return true;
  }

  /// Returns Blender-style fuzzy menu-search results.
  ///
  /// Every query token must match at least one label, breadcrumb, description,
  /// or explicit search term. Exact and word-prefix label matches rank ahead
  /// of substring and subsequence matches; recently executed commands break
  /// ties, matching blenderapp's logical recent-time cache.
  List<BlenderCommand> search(String query, {int maxResults = 50}) {
    final normalized = _normalizeSearchText(query);
    final tokens = normalized
        .split(' ')
        .where((token) => token.isNotEmpty)
        .toList(growable: false);
    final scored =
        <({BlenderCommand command, int score, int order, String sortKey})>[];
    var order = 0;
    for (final command in _commands.values) {
      if (!command.searchable) {
        order++;
        continue;
      }
      final score = _commandSearchScore(command, tokens);
      if (score != null) {
        final recent = _recentCommandIds.indexOf(command.id);
        scored.add((
          command: command,
          score:
              score -
              command.searchWeight -
              (recent < 0 ? 0 : math.max(1, 24 - recent)),
          order: order,
          sortKey: _normalizeSearchText(
            <String>[...command.menuPath, command.label].join(' '),
          ),
        ));
      }
      order++;
    }
    scored.sort((a, b) {
      final deprecated = a.command.deprecated == b.command.deprecated
          ? 0
          : (a.command.deprecated ? 1 : -1);
      if (deprecated != 0) return deprecated;
      final byScore = a.score.compareTo(b.score);
      if (byScore != 0) return byScore;
      final alphabetical = a.sortKey.compareTo(b.sortKey);
      return alphabetical != 0 ? alphabetical : a.order.compareTo(b.order);
    });
    return <BlenderCommand>[
      for (final result in scored.take(maxResults)) result.command,
    ];
  }

  /// Re-evaluates command enablement after external state changes.
  void refresh() => notifyListeners();
}

String _normalizeSearchText(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
    .trim();

int? _commandSearchScore(BlenderCommand command, List<String> tokens) {
  if (tokens.isEmpty) return 100;
  final label = _normalizeSearchText(command.label);
  final groups = <String>[
    label,
    for (final path in command.menuPath) _normalizeSearchText(path),
    if (command.description case final description?)
      _normalizeSearchText(description),
    for (final term in command.searchTerms) _normalizeSearchText(term),
  ];
  var total = 0;
  for (final token in tokens) {
    int? best;
    for (var index = 0; index < groups.length; index++) {
      final group = groups[index];
      final score = _searchGroupScore(group, token, primary: index == 0);
      if (score != null && (best == null || score < best)) best = score;
    }
    if (best == null) return null;
    total += best;
  }
  return total;
}

int? _searchGroupScore(String text, String query, {required bool primary}) {
  final pathPenalty = primary ? 0 : 14;
  if (text == query) return pathPenalty;
  if (text.startsWith(query)) return 4 + pathPenalty;
  final wordPrefix = text
      .split(' ')
      .indexWhere((word) => word.startsWith(query));
  if (wordPrefix >= 0) return 10 + wordPrefix + pathPenalty;
  final contains = text.indexOf(query);
  if (contains >= 0) return 22 + contains + pathPenalty;
  var queryIndex = 0;
  var gaps = 0;
  for (
    var textIndex = 0;
    textIndex < text.length && queryIndex < query.length;
    textIndex++
  ) {
    if (text.codeUnitAt(textIndex) == query.codeUnitAt(queryIndex)) {
      queryIndex++;
    } else if (queryIndex > 0) {
      gaps++;
    }
  }
  return queryIndex == query.length ? 48 + gaps + pathPenalty : null;
}

/// Intent emitted by [BlenderCommandBindingScope] for a registered command.
class BlenderCommandIntent extends Intent {
  const BlenderCommandIntent(this.commandId);

  final String commandId;
}

/// One keyboard binding from a Flutter shortcut activator to a command id.
class BlenderCommandBinding {
  const BlenderCommandBinding({
    required this.commandId,
    required this.activator,
  });

  final String commandId;
  final ShortcutActivator activator;
}

/// Command-keymap service analogous to blenderapp's operator keymaps.
///
/// It intentionally binds stable command ids rather than widget callbacks, so
/// menus, keyboard shortcuts, and command search execute the same operation.
class BlenderCommandBindings extends ChangeNotifier
    implements BlenderServiceDisposable {
  final LinkedHashMap<ShortcutActivator, String> _bindings =
      LinkedHashMap<ShortcutActivator, String>();

  List<BlenderCommandBinding> get bindings =>
      List<BlenderCommandBinding>.unmodifiable(
        _bindings.entries.map(
          (entry) => BlenderCommandBinding(
            commandId: entry.value,
            activator: entry.key,
          ),
        ),
      );

  Map<ShortcutActivator, Intent> get shortcuts => <ShortcutActivator, Intent>{
    for (final entry in _bindings.entries)
      entry.key: BlenderCommandIntent(entry.value),
  };

  /// Returns the command currently assigned to [activator], if any.
  ///
  /// Hosts use this to retain application-specific overrides when installing
  /// their default keymap.
  String? commandFor(ShortcutActivator activator) => _bindings[activator];

  void register(BlenderCommandBinding binding) {
    if (_bindings.containsKey(binding.activator)) {
      throw StateError(
        'A command binding already exists for ${binding.activator}.',
      );
    }
    _bindings[binding.activator] = binding.commandId;
    notifyListeners();
  }

  bool unregister(ShortcutActivator activator) {
    final removed = _bindings.remove(activator) != null;
    if (removed) notifyListeners();
    return removed;
  }

  @override
  void dispose() {
    _bindings.clear();
    super.dispose();
  }
}
