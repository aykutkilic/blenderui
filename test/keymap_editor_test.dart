import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('live keymap preferences edit the runtime binding', (
    tester,
  ) async {
    final commands = BlenderCommandRegistry()
      ..register(
        BlenderCommand(id: 'view.move', label: 'Move', execute: () {}),
      );
    final bindings = BlenderCommandBindings()
      ..register(
        const BlenderCommandBinding(
          commandId: 'view.move',
          activator: SingleActivator(LogicalKeyboardKey.keyG),
          keymap: '3D View',
        ),
      );
    final search = TextEditingController();
    addTearDown(commands.dispose);
    addTearDown(bindings.dispose);
    addTearDown(search.dispose);

    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 720,
          height: 480,
          child: BlenderKeymapEditor(
            searchController: search,
            bindings: bindings,
            commands: commands,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('3D View'));
    await tester.pump();
    expect(find.text('Move'), findsOneWidget);
    await tester.tap(find.text('G'));
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyM);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyM);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(bindings.bindings.single.shortcutLabel, 'Ctrl M');
    expect(
      bindings.commandFor(
        const SingleActivator(LogicalKeyboardKey.keyM, control: true),
      ),
      'view.move',
    );
    expect(find.text('Ctrl M'), findsOneWidget);
    expect(bindings.bindings.single.isModified, isTrue);
  });

  testWidgets('key binding filter searches the formatted event', (
    tester,
  ) async {
    final commands = BlenderCommandRegistry()
      ..register(
        BlenderCommand(id: 'file.save', label: 'Save', execute: () {}),
      );
    final bindings = BlenderCommandBindings()
      ..register(
        const BlenderCommandBinding(
          commandId: 'file.save',
          activator: SingleActivator(LogicalKeyboardKey.keyS, control: true),
        ),
      );
    final search = TextEditingController();
    addTearDown(commands.dispose);
    addTearDown(bindings.dispose);
    addTearDown(search.dispose);

    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 720,
          height: 420,
          child: BlenderKeymapEditor(
            searchController: search,
            bindings: bindings,
            commands: commands,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Key-Binding').last);
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'ctrl s');
    await tester.pump();
    expect(find.text('Save'), findsOneWidget);
  });
}
