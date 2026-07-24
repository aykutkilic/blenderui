import 'package:blender_ui_workbook/blender_ui_workbook.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('plot MIME JSON preserves renderers, axes, and cursors', () {
    final spec = WorkbookPlotSpec.fromJson(<String, Object?>{
      'title': 'Signals',
      'type': 'stacked-area',
      'series': <Object?>[
        <String, Object?>{
          'id': 'signal',
          'label': 'Signal',
          'color': '#10b981',
          'points': <Object?>[
            <double>[0, -2],
            <double>[1, 4],
          ],
        },
      ],
      'cursors': <Object?>[
        <String, Object?>{'id': 'selection', 'type': 'band', 'x': .2, 'x2': .8},
      ],
    });

    expect(spec.kind, WorkbookPlotKind.stackedArea);
    expect(spec.axes.single.minimum, -2);
    expect(spec.axes.single.maximum, 4);
    expect(spec.cursors.single.kind, WorkbookPlotCursorKind.band);
  });

  test('ploted renderer aliases and Sankey graph data are preserved', () {
    final threeDimensional = WorkbookPlotSpec.fromJson(<String, Object?>{
      'type': '3d',
      'series': <Object?>[],
    });
    expect(threeDimensional.kind, WorkbookPlotKind.threeDimensional);

    final sankey = WorkbookPlotSpec.fromJson(<String, Object?>{
      'type': 'sankey',
      'nodes': <Object?>[
        <String, Object?>{
          'id': 'source',
          'label': 'Revenue',
          'x': .1,
          'y': .2,
          'height': .5,
        },
        <String, Object?>{
          'id': 'target',
          'label': 'Profit',
          'x': .8,
          'y': .4,
          'height': .2,
        },
      ],
      'links': <Object?>[
        <String, Object?>{'source': 'source', 'target': 'target', 'weight': .2},
      ],
    });
    expect(sankey.nodes.map((node) => node.id), <String>['source', 'target']);
    expect(sankey.links.single.weight, .2);
    final controller = WorkbookPlotController(sankey);
    controller.moveNode('source', x: .3, y: .6);
    expect((controller.nodes.first.x, controller.nodes.first.y), (.3, .6));
  });

  test(
    'plot controller applies pan, anchored zoom, visibility, and cursors',
    () {
      final controller = WorkbookPlotController(
        WorkbookPlotSpec.fromJson(<String, Object?>{
          'series': <Object?>[
            <String, Object?>{
              'id': 'a',
              'points': <Object?>[
                <double>[0, 0],
                <double>[10, 10],
              ],
            },
          ],
        }),
      );

      controller.panX(2);
      expect((controller.xMinimum, controller.xMaximum), (2, 12));
      controller.zoomX(.5, anchor: 2);
      expect((controller.xMinimum, controller.xMaximum), (2, 7));
      controller.setSeriesVisible('a', false);
      expect(controller.series.single.visible, isFalse);
      final cursor = controller.addCursor(4, x2: 5);
      controller.moveCursor(cursor, x: 5, x2: 6);
      expect(controller.cursors.single.x, 5);
      controller.removeCursor(cursor);
      expect(controller.cursors, isEmpty);
      controller.addCursor(3);
      controller.clearCursors();
      expect(controller.cursors, isEmpty);
      final yaw = controller.cameraYaw;
      controller.rotateCamera(yawDelta: .2, pitchDelta: .1);
      expect(controller.cameraYaw, closeTo(yaw + .2, 1e-9));
    },
  );

  testWidgets('every ploted renderer paints from the shared MIME model', (
    tester,
  ) async {
    const plotTypes = <String>[
      'oscilloscope',
      'line',
      'scatter',
      'bar',
      'histogram',
      'stacked-area',
      'waveform',
      'candlestick',
      'sankey',
      'gantt',
      '3d',
      'xy-map',
    ];
    for (final type in plotTypes) {
      final spec = WorkbookPlotSpec.fromJson(<String, Object?>{
        'title': type,
        'type': type,
        'xMin': 0,
        'xMax': 2,
        'axes': <Object?>[
          <String, Object?>{'id': 'y', 'label': 'value', 'min': -2, 'max': 4},
        ],
        'series': <Object?>[
          <String, Object?>{
            'id': 'a',
            'label': 'A',
            'axis': 'y',
            'points': <Object?>[
              <String, Object?>{
                'x': 0,
                'y': 0,
                'z': 1,
                'open': 0,
                'high': 2,
                'low': -1,
                'close': 1,
              },
              <String, Object?>{
                'x': 1,
                'y': 2,
                'z': 3,
                'open': 1,
                'high': 3,
                'low': 0,
                'close': 2,
              },
            ],
          },
        ],
        'nodes': <Object?>[
          <String, Object?>{
            'id': 'a',
            'label': 'A',
            'x': .1,
            'y': .2,
            'height': .4,
          },
          <String, Object?>{
            'id': 'b',
            'label': 'B',
            'x': .8,
            'y': .4,
            'height': .2,
          },
        ],
        'links': <Object?>[
          <String, Object?>{'source': 'a', 'target': 'b', 'weight': .2},
        ],
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 720, child: WorkbookPlot(spec: spec)),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'renderer: $type');
    }
  });
}
