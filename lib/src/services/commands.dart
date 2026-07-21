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
    this.bindingId,
    this.keymap = 'Window',
    this.context = 'global',
    this.eventType = BlenderKeymapEventType.keyboard,
    this.eventValue = 'Press',
    this.enabled = true,
    this.repeat = false,
    this.userDefined = false,
    this.defaultActivator,
  });

  final String commandId;
  final ShortcutActivator activator;
  final String? bindingId;
  final String keymap;
  final String context;
  final BlenderKeymapEventType eventType;
  final String eventValue;
  final bool enabled;
  final bool repeat;
  final bool userDefined;
  final ShortcutActivator? defaultActivator;

  String get id => bindingId ?? '$keymap::$context::$commandId';
  bool get isModified =>
      defaultActivator != null &&
      !BlenderShortcutCodec.equivalent(defaultActivator!, activator);
  String get shortcutLabel => BlenderShortcutCodec.label(activator);

  BlenderCommandBinding copyWith({
    ShortcutActivator? activator,
    bool? enabled,
    bool? repeat,
    bool? userDefined,
    ShortcutActivator? defaultActivator,
  }) => BlenderCommandBinding(
    commandId: commandId,
    activator: activator ?? this.activator,
    bindingId: bindingId,
    keymap: keymap,
    context: context,
    eventType: eventType,
    eventValue: eventValue,
    enabled: enabled ?? this.enabled,
    repeat: repeat ?? this.repeat,
    userDefined: userDefined ?? this.userDefined,
    defaultActivator: defaultActivator ?? this.defaultActivator,
  );

  Map<String, Object?>? toJson() {
    final shortcut = BlenderShortcutCodec.encode(activator);
    if (shortcut == null) return null;
    return <String, Object?>{
      'id': id,
      'command': commandId,
      'keymap': keymap,
      'context': context,
      'eventType': eventType.name,
      'eventValue': eventValue,
      'enabled': enabled,
      'repeat': repeat,
      'userDefined': userDefined,
      'shortcut': shortcut,
      if (defaultActivator case final original?)
        'defaultShortcut': BlenderShortcutCodec.encode(original),
    };
  }
}

/// Command-keymap service analogous to blenderapp's operator keymaps.
///
/// It intentionally binds stable command ids rather than widget callbacks, so
/// menus, keyboard shortcuts, and command search execute the same operation.
class BlenderCommandBindings extends ChangeNotifier
    implements BlenderServiceDisposable {
  final List<BlenderCommandBinding> _bindings = <BlenderCommandBinding>[];
  String _configurationName = 'Blender';

  String get configurationName => _configurationName;

  List<BlenderCommandBinding> get bindings =>
      List<BlenderCommandBinding>.unmodifiable(_bindings);

  Map<ShortcutActivator, Intent> get shortcuts => shortcutsFor();

  Map<ShortcutActivator, Intent> shortcutsFor({
    Set<String> contexts = const <String>{'global'},
  }) => <ShortcutActivator, Intent>{
    for (final binding in _bindings)
      if (binding.enabled && contexts.contains(binding.context))
        binding.activator: BlenderCommandIntent(binding.commandId),
  };

  /// Returns the command currently assigned to [activator], if any.
  ///
  /// Hosts use this to retain application-specific overrides when installing
  /// their default keymap.
  String? commandFor(
    ShortcutActivator activator, {
    Set<String> contexts = const <String>{'global'},
  }) {
    for (final binding in _bindings.reversed) {
      if (binding.enabled &&
          contexts.contains(binding.context) &&
          BlenderShortcutCodec.equivalent(binding.activator, activator)) {
        return binding.commandId;
      }
    }
    return null;
  }

  BlenderCommandBinding? bindingById(String id) {
    for (final binding in _bindings) {
      if (binding.id == id) return binding;
    }
    return null;
  }

  void register(BlenderCommandBinding binding) {
    if (bindingById(binding.id) != null) {
      throw StateError('A command binding with id "${binding.id}" exists.');
    }
    if (_conflictingBinding(binding) != null) {
      throw StateError(
        'A command binding already exists for ${binding.activator}.',
      );
    }
    _bindings.add(
      binding.defaultActivator == null
          ? binding.copyWith(defaultActivator: binding.activator)
          : binding,
    );
    notifyListeners();
  }

  bool unregister(ShortcutActivator activator) {
    final index = _bindings.indexWhere(
      (item) => BlenderShortcutCodec.equivalent(item.activator, activator),
    );
    final removed = index >= 0;
    if (removed) _bindings.removeAt(index);
    if (removed) notifyListeners();
    return removed;
  }

  bool remove(String id) {
    final index = _bindings.indexWhere((item) => item.id == id);
    if (index < 0) return false;
    _bindings.removeAt(index);
    notifyListeners();
    return true;
  }

  /// Replaces an item while preserving its stable id and default binding.
  /// Returns conflicts rather than silently shadowing another operator.
  List<BlenderKeymapConflict> update(
    String id,
    BlenderCommandBinding replacement,
  ) {
    final index = _bindings.indexWhere((item) => item.id == id);
    if (index < 0) throw StateError('Unknown command binding "$id".');
    final current = _bindings[index];
    final normalized = BlenderCommandBinding(
      commandId: replacement.commandId,
      activator: replacement.activator,
      bindingId: current.bindingId,
      keymap: current.keymap,
      context: current.context,
      eventType: replacement.eventType,
      eventValue: replacement.eventValue,
      enabled: replacement.enabled,
      repeat: replacement.repeat,
      userDefined: current.userDefined,
      defaultActivator: current.defaultActivator,
    );
    final other = _conflictingBinding(normalized, excludingId: id);
    if (other != null)
      return <BlenderKeymapConflict>[BlenderKeymapConflict(normalized, other)];
    _bindings[index] = normalized;
    notifyListeners();
    return const <BlenderKeymapConflict>[];
  }

  void setEnabled(String id, bool enabled) {
    final binding = bindingById(id);
    if (binding == null || binding.enabled == enabled) return;
    update(id, binding.copyWith(enabled: enabled));
  }

  void reset(String id) {
    final binding = bindingById(id);
    final original = binding?.defaultActivator;
    if (binding == null || original == null) return;
    update(id, binding.copyWith(activator: original, enabled: true));
  }

  void resetKeymap(String keymap) {
    var changed = false;
    for (var index = 0; index < _bindings.length; index++) {
      final binding = _bindings[index];
      if (binding.keymap != keymap || binding.defaultActivator == null)
        continue;
      _bindings[index] = binding.copyWith(
        activator: binding.defaultActivator,
        enabled: true,
      );
      changed = true;
    }
    if (changed) notifyListeners();
  }

  List<BlenderKeymapConflict> conflictsFor(String id) {
    final binding = bindingById(id);
    if (binding == null || !binding.enabled) return const [];
    return <BlenderKeymapConflict>[
      for (final other in _bindings)
        if (other.id != id &&
            other.enabled &&
            other.context == binding.context &&
            BlenderShortcutCodec.equivalent(other.activator, binding.activator))
          BlenderKeymapConflict(binding, other),
    ];
  }

  BlenderCommandBinding? _conflictingBinding(
    BlenderCommandBinding candidate, {
    String? excludingId,
  }) {
    if (!candidate.enabled) return null;
    for (final binding in _bindings) {
      if (binding.id != excludingId &&
          binding.enabled &&
          binding.context == candidate.context &&
          BlenderShortcutCodec.equivalent(
            binding.activator,
            candidate.activator,
          )) {
        return binding;
      }
    }
    return null;
  }

  BlenderKeymapConfiguration snapshot() =>
      BlenderKeymapConfiguration(name: _configurationName, items: bindings);

  String exportConfiguration() => snapshot().encode();

  /// Imports keyboard items previously produced by [exportConfiguration].
  /// Unknown/non-keyboard records are ignored so hosts can extend the format.
  void importConfiguration(String encoded) {
    final decoded = jsonDecode(encoded);
    if (decoded is! Map || decoded['items'] is! List) {
      throw const FormatException('Invalid keymap configuration.');
    }
    final imported = <BlenderCommandBinding>[];
    for (final raw in decoded['items'] as List) {
      if (raw is! Map) continue;
      final activator = BlenderShortcutCodec.decode(raw['shortcut']);
      final defaultActivator =
          BlenderShortcutCodec.decode(raw['defaultShortcut']) ?? activator;
      final command = raw['command'];
      if (activator == null || command is! String) continue;
      final eventTypeName = raw['eventType'] as String?;
      final eventType = BlenderKeymapEventType.values.firstWhere(
        (value) => value.name == eventTypeName,
        orElse: () => BlenderKeymapEventType.keyboard,
      );
      final item = BlenderCommandBinding(
        commandId: command,
        activator: activator,
        bindingId: raw['id'] as String?,
        keymap: raw['keymap'] as String? ?? 'Window',
        context: raw['context'] as String? ?? 'global',
        eventType: eventType,
        eventValue: raw['eventValue'] as String? ?? 'Press',
        enabled: raw['enabled'] != false,
        repeat: raw['repeat'] == true,
        userDefined: raw['userDefined'] == true,
        defaultActivator: defaultActivator,
      );
      final duplicate = imported.any(
        (other) =>
            other.enabled &&
            item.enabled &&
            other.context == item.context &&
            BlenderShortcutCodec.equivalent(other.activator, item.activator),
      );
      if (duplicate) {
        throw FormatException(
          'Conflicting shortcut ${item.shortcutLabel} in ${item.context}.',
        );
      }
      imported.add(item);
    }
    _bindings
      ..clear()
      ..addAll(imported);
    _configurationName = decoded['name'] as String? ?? 'Imported';
    notifyListeners();
  }

  @override
  void dispose() {
    _bindings.clear();
    super.dispose();
  }
}
