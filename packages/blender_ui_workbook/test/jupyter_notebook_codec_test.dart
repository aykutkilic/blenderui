import 'package:blender_ui_workbook/blender_ui_workbook.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decodes notebook source and outputs without a runtime', () {
    final document = const JupyterNotebookCodec().decode('''{
        "metadata": {"kernelspec": {"name": "python-custom"}},
        "cells": [
          {"cell_type":"markdown", "source":["# Offline\\n", "notes"]},
          {"cell_type":"code", "source":["print('ok')"],
           "execution_count":3,
           "outputs":[{"output_type":"stream", "name":"stdout", "text":["ok\\n"]}]}
        ]
      }''', fallbackTitle: 'sample.ipynb');

    expect(document.title, 'sample.ipynb');
    expect(document.kernelName, 'python-custom');
    expect(document.cells, hasLength(2));
    expect(document.cells.first.kind, WorkbookCellKind.markdown);
    expect(document.cells.first.source, '# Offline\nnotes');
    expect(document.cells.last.executionCount, 3);
    expect(
      (document.cells.last.outputs.single as WorkbookStreamOutput).text,
      'ok\n',
    );
  });

  test('restores BlenderUI variable plot metadata as a plot cell', () {
    final document = const JupyterNotebookCodec().decode('''{
      "cells": [{
        "cell_type": "code",
        "source": [],
        "metadata": {
          "blenderui": {
            "plot": {
              "title": "Selected variables",
              "kind": "scatter",
              "xVariable": "time",
              "yVariables": ["speed", "acceleration"]
            }
          }
        }
      }]
    }''', fallbackTitle: 'plot.ipynb');

    final cell = document.cells.single;
    expect(cell.kind, WorkbookCellKind.plot);
    expect(cell.plotConfiguration?.title, 'Selected variables');
    expect(cell.plotConfiguration?.kind, WorkbookPlotKind.scatter);
    expect(cell.plotConfiguration?.xVariable, 'time');
    expect(cell.plotConfiguration?.yVariables, <String>[
      'speed',
      'acceleration',
    ]);
  });
}
