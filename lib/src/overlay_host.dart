import 'package:flutter/widgets.dart';

/// Supplies the local overlay and localization delegates required by widgets
/// such as reorderable lists when an embedding app does not provide them.
///
/// This is intentionally a shared host instead of per-editor private copies:
/// Properties, Preferences, and future embedded editors all need identical
/// fallback semantics.
class BlenderEnsureOverlay extends StatelessWidget {
  const BlenderEnsureOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget result = Overlay.maybeOf(context) != null
        ? child
        : _BlenderLocalOverlay(child: child);
    if (Localizations.of<WidgetsLocalizations>(context, WidgetsLocalizations) ==
        null) {
      result = Localizations(
        locale: const Locale('en', 'US'),
        delegates: const <LocalizationsDelegate<dynamic>>[
          DefaultWidgetsLocalizations.delegate,
        ],
        child: result,
      );
    }
    return result;
  }
}

class _BlenderLocalOverlay extends StatefulWidget {
  const _BlenderLocalOverlay({required this.child});

  final Widget child;

  @override
  State<_BlenderLocalOverlay> createState() => _BlenderLocalOverlayState();
}

class _BlenderLocalOverlayState extends State<_BlenderLocalOverlay> {
  late final OverlayEntry _entry = OverlayEntry(
    builder: (context) => Positioned.fill(child: widget.child),
  );

  @override
  void didUpdateWidget(_BlenderLocalOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entry.markNeedsBuild();
  }

  @override
  void dispose() {
    _entry.remove();
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Overlay(initialEntries: <OverlayEntry>[_entry]);
}
