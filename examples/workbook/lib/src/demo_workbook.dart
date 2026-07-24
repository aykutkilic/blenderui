import 'package:blender_ui_workbook/blender_ui_workbook.dart';

final demoWorkbook = WorkbookDocument(
  id: 'math-ai-demo',
  title: 'Math and AI Workbook',
  cells: <WorkbookCell>[
    WorkbookCell(
      id: 'introduction',
      kind: WorkbookCellKind.markdown,
      source: r'''# Math and AI Workbook

Markdown cells support **GitHub-flavored Markdown** and inline LaTeX such as
$\sin^2(x) + \cos^2(x) = 1$.

$$
f(x) = \sum_{n=0}^{\infty} \frac{f^{(n)}(a)}{n!}(x-a)^n
$$''',
    ),
    WorkbookCell(
      id: 'sine-wave',
      source: '''from math import pi, sin
from blenderui_workbook import xy

x = [i * 2 * pi / 120 for i in range(121)]
y = [sin(value) for value in x]
xy(x, y, title="Interactive sine wave", label="sin(x)", x_label="radians")''',
    ),
    WorkbookCell(
      id: 'statistics',
      source: '''values = [12, 17, 17, 21, 24, 31]
mean = sum(values) / len(values)
variance = sum((value - mean) ** 2 for value in values) / len(values)
{"mean": mean, "variance": variance}''',
    ),
    WorkbookCell(
      id: 'variable-plot',
      kind: WorkbookCellKind.plot,
      source: '',
      plotConfiguration: WorkbookPlotCellConfiguration(
        title: 'Sine wave from x and y',
        kind: WorkbookPlotKind.line,
        xVariable: 'x',
        yVariables: <String>['y'],
      ),
    ),
    WorkbookCell(
      id: 'ai-completion',
      source: '''def fibonacci(count: int) -> list[int]:
    """Return the first count Fibonacci numbers."""
    ''',
    ),
  ],
);
