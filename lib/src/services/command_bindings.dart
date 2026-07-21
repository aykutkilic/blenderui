part of '../services.dart';

/// Installs [BlenderCommandBindings] for one app or window subtree.
class BlenderCommandBindingScope extends StatelessWidget {
  const BlenderCommandBindingScope({
    super.key,
    required this.commands,
    required this.bindings,
    required this.child,
    this.contexts = const <String>{'global'},
  });

  final BlenderCommandRegistry commands;
  final BlenderCommandBindings bindings;
  final Widget child;

  /// Active Blender-style keymap contexts for this subtree.
  final Set<String> contexts;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: bindings,
      builder: (context, _) => Shortcuts(
        shortcuts: bindings.shortcutsFor(contexts: contexts),
        child: Actions(
          actions: <Type, Action<Intent>>{
            BlenderCommandIntent: CallbackAction<BlenderCommandIntent>(
              onInvoke: (intent) {
                unawaited(commands.execute(intent.commandId));
                return null;
              },
            ),
          },
          child: Focus(
            autofocus: true,
            debugLabel: 'BlenderCommandBindingScope',
            child: child,
          ),
        ),
      ),
    );
  }
}
