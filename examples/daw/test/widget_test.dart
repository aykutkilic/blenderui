import 'package:blender_ui/blender_ui.dart';
import 'package:blender_ui_daw_example/main.dart' as app;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DAW workspace boots with its primary editors', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    app.main();
    await tester.pump();

    expect(find.text('Song'), findsOneWidget);
    expect(find.text('Arrangement'), findsWidgets);
    expect(find.text('Piano Roll'), findsWidgets);
  });

  testWidgets('native macOS Preferences request is presented immediately', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    app.main();
    await tester.pump();

    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    await messenger.handlePlatformMessage(
      'blender_ui/application_lifecycle',
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('preferencesRequested'),
      ),
      (_) {},
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(BlenderPreferencesWindow), findsOneWidget);
    expect(find.text('Audio Device'), findsWidgets);
  });

  testWidgets('each dock area can switch to the audio routing editor', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    app.main();
    await tester.pump();

    await tester.tap(
      find.byKey(const ValueKey<String>('daw-editor-view-selector')).first,
    );
    await tester.pump();
    await tester.tap(find.text('Audio Routing').last);
    await tester.pump();

    expect(find.text('Audio Graph'), findsOneWidget);
    expect(find.byType(BlenderNodeEditor), findsOneWidget);
  });
}
