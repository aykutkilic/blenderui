part of 'workbook_plot.dart';

final class _PlotHeader extends StatelessWidget {
  const _PlotHeader({
    required this.controller,
    required this.foreground,
    required this.onReset,
  });

  final WorkbookPlotController controller;
  final Color foreground;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 34,
    child: Row(
      children: <Widget>[
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            controller.spec.title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: foreground, fontSize: 12),
          ),
        ),
        if (controller.spec.showLegend)
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final series in controller.series)
                    InkWell(
                      onTap: () => controller.setSeriesVisible(
                        series.id,
                        !series.visible,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: series.visible
                                    ? series.color
                                    : series.color.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              series.label,
                              style: TextStyle(color: foreground, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        IconButton(
          tooltip: 'Reset view',
          onPressed: onReset,
          icon: const Icon(Icons.fit_screen, size: 16),
          color: foreground,
          padding: const EdgeInsets.all(6),
        ),
      ],
    ),
  );
}
