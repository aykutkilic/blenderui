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
  });

  final String id;
  final String label;
  final String? description;
  final String? shortcut;
  final BlenderCommandCallback execute;
  final bool Function()? enabled;

  bool get isEnabled => enabled?.call() ?? true;
}

/// Application-level command catalog that can back buttons, menus, keymaps,
/// and operator search without coupling those surfaces to domain objects.
class BlenderCommandRegistry extends ChangeNotifier
    implements BlenderServiceDisposable {
  final LinkedHashMap<String, BlenderCommand> _commands =
      LinkedHashMap<String, BlenderCommand>();

  List<BlenderCommand> get commands =>
      List<BlenderCommand>.unmodifiable(_commands.values);

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
    notifyListeners();
    return true;
  }

  /// Re-evaluates command enablement after external state changes.
  void refresh() => notifyListeners();
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
