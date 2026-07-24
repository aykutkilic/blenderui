"""Rich display helpers for BlenderUI math and AI workbooks.

Copy or add this directory to PYTHONPATH, then use `plot(...)` to emit the
versioned MIME bundle understood by the Flutter workbook plot editor.
"""

from __future__ import annotations

from typing import Any, Iterable, Mapping, Sequence

from IPython.display import display

MIME_TYPE = "application/vnd.blenderui.plot+json"


def plot(
    series: Sequence[Mapping[str, Any]],
    *,
    title: str = "Plot",
    plot_type: str = "line",
    axes: Sequence[Mapping[str, Any]] | None = None,
    cursors: Sequence[Mapping[str, Any]] | None = None,
    nodes: Sequence[Mapping[str, Any]] | None = None,
    links: Sequence[Mapping[str, Any]] | None = None,
    x_min: float | None = None,
    x_max: float | None = None,
    show_grid: bool = True,
    show_legend: bool = True,
    isometric: bool = False,
) -> Mapping[str, Any]:
    """Display and return an interactive BlenderUI plot specification."""

    spec: dict[str, Any] = {
        "version": 1,
        "title": title,
        "type": plot_type,
        "series": list(series),
        "axes": list(axes or []),
        "cursors": list(cursors or []),
        "nodes": list(nodes or []),
        "links": list(links or []),
        "showGrid": show_grid,
        "showLegend": show_legend,
        "isometric": isometric,
    }
    if x_min is not None:
        spec["xMin"] = x_min
    if x_max is not None:
        spec["xMax"] = x_max
    display({MIME_TYPE: spec, "text/plain": f"<{plot_type} plot: {title}>"}, raw=True)
    return spec


def xy(
    x: Iterable[float],
    y: Iterable[float],
    *,
    title: str = "Plot",
    label: str = "Series",
    color: str = "#3b82f6",
    plot_type: str = "line",
    x_label: str = "x",
    y_label: str = "y",
    unit: str = "",
) -> Mapping[str, Any]:
    """Convenience helper for line, scatter, bar, or histogram data."""

    points = [[float(x_value), float(y_value)] for x_value, y_value in zip(x, y)]
    y_values = [point[1] for point in points]
    minimum = min(y_values, default=0.0)
    maximum = max(y_values, default=1.0)
    if minimum == maximum:
        minimum -= 1.0
        maximum += 1.0
    return plot(
        [{"id": "series", "label": label, "color": color, "points": points}],
        title=title,
        plot_type=plot_type,
        axes=[
            {
                "id": "y",
                "label": y_label,
                "unit": unit,
                "side": "left",
                "min": minimum,
                "max": maximum,
            }
        ],
    )


def sankey(
    nodes: Sequence[Mapping[str, Any]],
    links: Sequence[Mapping[str, Any]],
    *,
    title: str = "Sankey",
) -> Mapping[str, Any]:
    """Display a manipulable Sankey diagram using normalized node geometry."""

    return plot(
        [],
        title=title,
        plot_type="sankey",
        nodes=nodes,
        links=links,
        show_grid=False,
        show_legend=False,
    )


def xyz(
    x: Iterable[float],
    y: Iterable[float],
    z: Iterable[float],
    *,
    title: str = "3D plot",
    label: str = "Surface",
    color: str = "#10b981",
) -> Mapping[str, Any]:
    """Display a software-projected 3D trace."""

    points = [
        {"x": float(x_value), "y": float(y_value), "z": float(z_value)}
        for x_value, y_value, z_value in zip(x, y, z)
    ]
    z_values = [point["z"] for point in points]
    minimum = min(z_values, default=-1.0)
    maximum = max(z_values, default=1.0)
    if minimum == maximum:
        minimum -= 1.0
        maximum += 1.0
    return plot(
        [{"id": "surface", "label": label, "color": color, "points": points}],
        title=title,
        plot_type="3d",
        axes=[
            {
                "id": "y",
                "label": "z",
                "side": "left",
                "min": minimum,
                "max": maximum,
            }
        ],
    )
