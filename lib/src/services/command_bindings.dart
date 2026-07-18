part of '../services.dart';

/// Installs [BlenderCommandBindings] for one app or window subtree.
class BlenderCommandBindingScope extends StatelessWidget {
  const BlenderCommandBindingScope({
    super.key,
    required this.commands,
    required this.bindings,
    required this.child,
  });

  final BlenderCommandRegistry commands;
  final BlenderCommandBindings bindings;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: bindings,
      builder: (context, _) => Shortcuts(
        shortcuts: bindings.shortcuts,
        child: Actions(
          actions: <Type, Action<Intent>>{
            BlenderCommandIntent: CallbackAction<BlenderCommandIntent>(
              onInvoke: (intent) {
                unawaited(commands.execute(intent.commandId));
                return null;
              },
            ),
          },
          child: child,
        ),
      ),
    );
  }
}
