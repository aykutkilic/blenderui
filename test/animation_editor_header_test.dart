import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child) => BlenderApp(home: BlenderTheme(child: child));

  testWidgets('Graph and Drivers headers own their source branches', (
    tester,
  ) async {
    var value = const BlenderGraphEditorHeaderState();
    Future<void> pump(BlenderEditorType type) => tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => BlenderGraphEditorHeader(
            editorType: type,
            state: value,
            onStateChanged: (next) => setState(() => value = next),
          ),
        ),
      ),
    );

    await pump(BlenderEditorType.graphEditor);
    var header = tester.widget<BlenderAreaHeader>(
      find.byType(BlenderAreaHeader),
    );
    expect(
      header.menuDescriptors.map(
        (menu) => (menu as BlenderMenuDescriptor<String>).label,
      ),
      <String>['View', 'Select', 'Marker', 'Channel', 'Key'],
    );
    expect(
      (header.menuDescriptors.first as BlenderMenuDescriptor<String>).items.map(
        (item) => item.label,
      ),
      containsAll(<String>['Playback Controls', 'Show Markers']),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('graph-normalize-button')),
    );
    await tester.pump();
    expect(value.normalize, isTrue);
    await tester.tap(
      find.byKey(const ValueKey<String>('graph-auto-normalize-button')),
    );
    await tester.pump();
    expect(value.autoNormalize, isTrue);

    await pump(BlenderEditorType.drivers);
    header = tester.widget<BlenderAreaHeader>(find.byType(BlenderAreaHeader));
    expect(
      header.menuDescriptors.map(
        (menu) => (menu as BlenderMenuDescriptor<String>).label,
      ),
      <String>['View', 'Select', 'Channel', 'Key'],
    );
    final channel = header.menuDescriptors[2] as BlenderMenuDescriptor<String>;
    expect(
      channel.items.map((item) => item.label),
      contains('Delete Invalid Drivers'),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('graph-filters-button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Driver Fallback as Error'), findsOneWidget);
  });

  testWidgets('NLA header owns source menus filters and snapping state', (
    tester,
  ) async {
    var value = const BlenderNlaEditorHeaderState();
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => BlenderNlaEditorHeader(
            state: value,
            onStateChanged: (next) => setState(() => value = next),
          ),
        ),
      ),
    );

    final header = tester.widget<BlenderAreaHeader>(
      find.byType(BlenderAreaHeader),
    );
    expect(
      header.menuDescriptors.map(
        (menu) => (menu as BlenderMenuDescriptor<String>).label,
      ),
      <String>['View', 'Select', 'Marker', 'Add', 'Track', 'Strip'],
    );
    final strip = header.menuDescriptors.last as BlenderMenuDescriptor<String>;
    expect(
      strip.items.map((item) => item.label),
      containsAll(<String>['Linked Duplicate', 'Make Meta', 'Bake Action']),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('nla-snapping-toggle-button')),
    );
    await tester.pump();
    expect(value.snapping, isTrue);
    await tester.tap(find.byKey(const ValueKey<String>('nla-filters-button')));
    await tester.pumpAndSettle();
    expect(find.text('Grease Pencil Objects'), findsOneWidget);
    expect(find.text('Use Data-Block Sort'), findsOneWidget);
  });

  testWidgets('Timeline and Dope Sheet share source header state', (
    tester,
  ) async {
    var value = const BlenderDopeSheetEditorHeaderState();
    Future<void> pump(BlenderEditorType type) => tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => BlenderDopeSheetEditorHeader(
            editorType: type,
            state: value,
            onStateChanged: (next) => setState(() => value = next),
            actionValue: 'CubeAction',
            actionItems: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'CubeAction', label: 'CubeAction'),
            ],
          ),
        ),
      ),
    );

    await pump(BlenderEditorType.timeline);
    var header = tester.widget<BlenderAreaHeader>(
      find.byType(BlenderAreaHeader),
    );
    expect(
      header.menuDescriptors.map(
        (menu) => (menu as BlenderMenuDescriptor<String>).label,
      ),
      <String>['View', 'Marker'],
    );
    await tester.tap(
      find.byKey(
        const ValueKey<String>('main-animation-autokey-toggle-button'),
      ),
    );
    await tester.pump();
    expect(value.autoKeying, isTrue);

    await pump(BlenderEditorType.dopeSheet);
    header = tester.widget<BlenderAreaHeader>(find.byType(BlenderAreaHeader));
    expect(
      header.menuDescriptors.map(
        (menu) => (menu as BlenderMenuDescriptor<String>).label,
      ),
      <String>['View', 'Select', 'Marker', 'Channel', 'Key', 'Action'],
    );
    expect(
      find.byKey(const ValueKey<String>('main-animation-action-selector')),
      findsOneWidget,
    );
    final channel = header.menuDescriptors[3] as BlenderMenuDescriptor<String>;
    expect(
      channel.items.map((item) => item.label),
      containsAll(<String>['Clean Channels', 'Bake Channels']),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('main-animation-filters-button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Only Selected'), findsOneWidget);
  });

  testWidgets('animation playback footer reuses playhead settings', (
    tester,
  ) async {
    var value = const BlenderDopeSheetEditorHeaderState();
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => BlenderAnimationPlaybackFooter(
            state: value,
            onStateChanged: (next) => setState(() => value = next),
          ),
        ),
      ),
    );
    await tester.tap(
      find.byKey(
        const ValueKey<String>(
          'animation-playback-playhead-snap-toggle-button',
        ),
      ),
    );
    await tester.pump();
    expect(value.playheadSnapping, isTrue);
    await tester.tap(
      find.byKey(
        const ValueKey<String>('animation-playback-playhead-snap-button'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Frame Step'), findsOneWidget);
  });

  testWidgets('Sequencer header conditions menus and preview controls', (
    tester,
  ) async {
    var value = const BlenderSequencerEditorHeaderState();
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => BlenderSequencerEditorHeader(
            editorType: BlenderEditorType.sequencer,
            state: value,
            onStateChanged: (next) => setState(() => value = next),
          ),
        ),
      ),
    );

    var header = tester.widget<BlenderAreaHeader>(
      find.byType(BlenderAreaHeader),
    );
    expect(
      header.menuDescriptors.map(
        (menu) => (menu as BlenderMenuDescriptor<String>).label,
      ),
      <String>['View', 'Select', 'Marker', 'Add', 'Strip', 'Image'],
    );
    expect(
      find.byKey(const ValueKey<String>('sequencer-overlap-mode')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('sequencer-display-mode')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('sequencer-snapping-toggle-button')),
    );
    await tester.pump();
    expect(value.snapping, isTrue);

    value = value.copyWith(viewType: 'Preview');
    await tester.pumpWidget(
      host(
        BlenderSequencerEditorHeader(
          editorType: BlenderEditorType.sequencer,
          state: value,
        ),
      ),
    );
    header = tester.widget<BlenderAreaHeader>(find.byType(BlenderAreaHeader));
    expect(
      header.menuDescriptors.map(
        (menu) => (menu as BlenderMenuDescriptor<String>).label,
      ),
      <String>['View', 'Select', 'Strip', 'Image'],
    );
    expect(
      find.byKey(const ValueKey<String>('sequencer-overlap-mode')),
      findsNothing,
    );
  });

  testWidgets('Movie Clip header switches Tracking Graph and Mask branches', (
    tester,
  ) async {
    var value = const BlenderClipEditorHeaderState();
    Future<void> pump() => tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => BlenderClipEditorHeader(
            state: value,
            onStateChanged: (next) => setState(() => value = next),
          ),
        ),
      ),
    );

    await pump();
    var header = tester.widget<BlenderAreaHeader>(
      find.byType(BlenderAreaHeader),
    );
    expect(
      header.menuDescriptors.map(
        (menu) => (menu as BlenderMenuDescriptor<String>).label,
      ),
      <String>['View', 'Select', 'Clip', 'Track', 'Reconstruction'],
    );

    value = value.copyWith(view: 'Graph');
    await pump();
    header = tester.widget<BlenderAreaHeader>(find.byType(BlenderAreaHeader));
    expect(
      header.menuDescriptors.map(
        (menu) => (menu as BlenderMenuDescriptor<String>).label,
      ),
      <String>['View', 'Select'],
    );

    value = value.copyWith(mode: 'Mask');
    await pump();
    header = tester.widget<BlenderAreaHeader>(find.byType(BlenderAreaHeader));
    expect(
      header.menuDescriptors.map(
        (menu) => (menu as BlenderMenuDescriptor<String>).label,
      ),
      <String>['View', 'Select', 'Clip', 'Add', 'Mask'],
    );
    expect(
      find.byKey(const ValueKey<String>('clip-proportional-button')),
      findsOneWidget,
    );
  });
}
