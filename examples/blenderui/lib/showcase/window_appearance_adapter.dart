import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/services.dart';

/// Desktop-runner implementation of BlenderUI's portable appearance contract.
class ShowcaseWindowAppearanceAdapter
    implements BlenderWindowAppearanceAdapter {
  const ShowcaseWindowAppearanceAdapter();

  static const MethodChannel _channel = MethodChannel(
    'blender_ui/window_chrome',
  );

  @override
  Future<void> apply(BlenderWindowAppearance appearance) async {
    try {
      await _channel.invokeMethod<void>('setAppearance', appearance.name);
    } on MissingPluginException {
      // Web, tests, and runners without native window chrome remain supported.
    } on PlatformException {
      // Window decoration is best effort and must never interrupt editing.
    }
  }
}
