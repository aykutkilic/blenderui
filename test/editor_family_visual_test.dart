import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const timelineModel = BlenderTimelineModel(
    start: 1,
    end: 120,
    currentFrame: 24,
    tracks: <BlenderTimelineTrack>[
      BlenderTimelineTrack(
        id: 'cube',
        label: 'Cube',
        keyframes: <BlenderTimelineKeyframe>[
          BlenderTimelineKeyframe(1),
          BlenderTimelineKeyframe(24),
          BlenderTimelineKeyframe(72),
        ],
      ),
      BlenderTimelineTrack(id: 'camera', label: 'Camera'),
    ],
  );
  const curves = <BlenderCurveChannel>[
    BlenderCurveChannel(
      id: 'x',
      label: 'Cube / Location X',
      keyframes: <BlenderGraphKeyframe>[
        BlenderGraphKeyframe(id: 'x-1', frame: 1, value: .2),
        BlenderGraphKeyframe(id: 'x-40', frame: 40, value: .7),
        BlenderGraphKeyframe(id: 'x-82', frame: 82, value: -.35),
        BlenderGraphKeyframe(id: 'x-120', frame: 120, value: .8),
      ],
      color: Color(0xFFFF3352),
    ),
    BlenderCurveChannel(
      id: 'y',
      label: 'Cube / Location Y',
      keyframes: <BlenderGraphKeyframe>[
        BlenderGraphKeyframe(id: 'y-1', frame: 1, value: -.6),
        BlenderGraphKeyframe(id: 'y-60', frame: 60, value: .2),
        BlenderGraphKeyframe(id: 'y-120', frame: 120, value: -.65),
      ],
      color: Color(0xFF8BDC00),
    ),
  ];
  const strips = <BlenderSequencerStrip>[
    BlenderSequencerStrip(
      id: 'walk',
      label: 'Walk',
      start: 1,
      end: 48,
      channel: 1,
      color: Color(0xFF6E8CC7),
    ),
    BlenderSequencerStrip(
      id: 'camera',
      label: 'Camera',
      start: 32,
      end: 96,
      channel: 2,
      color: Color(0xFF8C6FC0),
    ),
  ];

  Future<void> reference(
    WidgetTester tester,
    String name,
    Widget header,
    Widget body,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final key = ValueKey<String>('reference-$name');
    await tester.pumpWidget(
      BlenderApp(
        home: RepaintBoundary(
          key: key,
          child: Column(
            children: <Widget>[
              header,
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(key),
      matchesGoldenFile('goldens/${name}_editor_reference.png'),
    );
  }

  testWidgets('Timeline rendered reference', (tester) async {
    await reference(
      tester,
      'timeline',
      const BlenderDopeSheetEditorHeader(
        editorType: BlenderEditorType.timeline,
      ),
      BlenderTimeline(
        title: null,
        model: timelineModel,
        onCurrentFrameChanged: (_) {},
      ),
    );
  });

  testWidgets('Dope Sheet rendered reference', (tester) async {
    await reference(
      tester,
      'dope_sheet',
      const BlenderDopeSheetEditorHeader(
        editorType: BlenderEditorType.dopeSheet,
        actionValue: 'CubeAction',
        actionItems: <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'CubeAction', label: 'CubeAction'),
        ],
      ),
      BlenderDopeSheetEditor(
        model: timelineModel,
        onCurrentFrameChanged: (_) {},
      ),
    );
  });

  testWidgets('Graph Editor rendered reference', (tester) async {
    await reference(
      tester,
      'graph',
      const BlenderGraphEditorHeader(editorType: BlenderEditorType.graphEditor),
      const BlenderCurveEditor(
        channels: curves,
        channelTree: <BlenderGraphChannelNode>[
          BlenderGraphChannelNode(
            id: 'cube',
            label: 'Cube',
            kind: BlenderGraphChannelKind.object,
            children: <BlenderGraphChannelNode>[
              BlenderGraphChannelNode(
                id: 'action',
                label: 'CubeAction',
                kind: BlenderGraphChannelKind.action,
                children: <BlenderGraphChannelNode>[
                  BlenderGraphChannelNode(
                    id: 'x',
                    label: 'X Location',
                    kind: BlenderGraphChannelKind.curve,
                    curveId: 'x',
                  ),
                  BlenderGraphChannelNode(
                    id: 'y',
                    label: 'Y Location',
                    kind: BlenderGraphChannelKind.curve,
                    curveId: 'y',
                  ),
                ],
              ),
            ],
          ),
        ],
        currentFrame: 24,
        frameRangeStart: 1,
        frameRangeEnd: 120,
        sidebar: BlenderGraphEditorSidebar(),
      ),
    );
  });

  testWidgets('Drivers Editor rendered reference', (tester) async {
    await reference(
      tester,
      'drivers',
      const BlenderGraphEditorHeader(editorType: BlenderEditorType.drivers),
      const BlenderCurveEditor(
        channels: curves,
        currentFrame: 0,
        showCursorFrame: true,
        sidebar: BlenderGraphEditorSidebar(drivers: true),
      ),
    );
  });

  testWidgets('NLA Editor rendered reference', (tester) async {
    await reference(
      tester,
      'nla',
      const BlenderNlaEditorHeader(),
      const BlenderNLAEditor(strips: strips, start: 1, end: 120),
    );
  });

  testWidgets('Video Sequencer rendered reference', (tester) async {
    await reference(
      tester,
      'sequencer',
      const BlenderSequencerEditorHeader(
        editorType: BlenderEditorType.sequencer,
      ),
      const BlenderVideoSequencerEditor(
        strips: strips,
        start: 1,
        end: 120,
        title: null,
      ),
    );
  });

  testWidgets('Movie Clip Editor rendered reference', (tester) async {
    await reference(
      tester,
      'clip',
      const BlenderClipEditorHeader(),
      const BlenderClipEditor(
        markers: <BlenderClipMarker>[
          BlenderClipMarker(id: 'a', position: Offset(160, 110)),
          BlenderClipMarker(id: 'b', position: Offset(420, 240)),
          BlenderClipMarker(id: 'c', position: Offset(680, 170)),
        ],
        sidebar: BlenderClipEditorSidebar(),
      ),
    );
  });
}
