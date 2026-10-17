"""Genera los gráficos y una versión HTML imprimible del manual técnico.

No necesita paquetes externos. El PDF se obtiene imprimiendo el HTML con Chrome
o Edge en modo headless; así el manual conserva las tablas y los SVG.
"""

from __future__ import annotations

import csv
import html
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
CSV_PATH = DOCS / "tabla_tiempos.csv"
MD_PATH = DOCS / "manual_tecnico.md"


COLORS = {
    "anio": "#3f3f3f",
    "deporte": "#777777",
    "deportista": "#aaaaaa",
}


def load_rows() -> list[dict[str, str]]:
    with CSV_PATH.open(encoding="utf-8", newline="") as stream:
        return list(csv.DictReader(stream))


def svg_text(x: float, y: float, value: str, size: int = 12, anchor: str = "middle", weight: str = "normal") -> str:
    return (
        f'<text x="{x:.1f}" y="{y:.1f}" text-anchor="{anchor}" '
        f'font-family="Arial, sans-serif" font-size="{size}px" font-weight="{weight}" '
        f'fill="#222">{html.escape(value)}</text>'
    )


def chart_frame(title: str, width: int, height: int, left: int = 70, top: int = 55, right: int = 30, bottom: int = 75) -> tuple[list[str], tuple[int, int, int, int]]:
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        '<rect width="100%" height="100%" fill="white"/>',
        svg_text(width / 2, 28, title, 16, weight="bold"),
    ]
    return parts, (left, top, width - right, height - bottom)


def finish_svg(parts: list[str]) -> str:
    parts.append("</svg>")
    return "\n".join(parts) + "\n"


def make_time_chart(rows: list[dict[str, str]]) -> None:
    width, height = 960, 470
    parts, (left, top, right, bottom) = chart_frame("Tiempo total de restauración", width, height)
    plot_w, plot_h = right - left, bottom - top
    scenarios = ["Solo FULL", "FULL + DIFF 1", "FULL + DIFF 2", "FULL + DIFF 3"]
    types = [("anio", "Por año"), ("deporte", "Por deporte"), ("deportista", "Por deportista")]
    values = {(row["tipo"], row["escenario"]): float(row["tiempo_restore_total_s"]) for row in rows}
    max_value = 0.32

    for tick in range(0, 7):
        value = tick * 0.05
        y = bottom - (value / max_value) * plot_h
        parts.append(f'<line x1="{left}" y1="{y:.1f}" x2="{right}" y2="{y:.1f}" stroke="#dddddd"/>')
        parts.append(svg_text(left - 8, y + 4, f"{value:.2f}", 10, "end"))
    parts.append(f'<line x1="{left}" y1="{top}" x2="{left}" y2="{bottom}" stroke="#333"/>')
    parts.append(f'<line x1="{left}" y1="{bottom}" x2="{right}" y2="{bottom}" stroke="#333"/>')

    group_w = plot_w / len(scenarios)
    bar_w = group_w / 5
    for index, scenario in enumerate(scenarios):
        center = left + group_w * (index + 0.5)
        parts.append(svg_text(center, bottom + 22, scenario.replace("FULL + ", "+ "), 10))
        for series_index, (tipo, _) in enumerate(types):
            value = values[(tipo, scenario)]
            x = center - 1.5 * bar_w + series_index * bar_w
            bar_h = (value / max_value) * plot_h
            y = bottom - bar_h
            parts.append(f'<rect x="{x:.1f}" y="{y:.1f}" width="{bar_w - 2:.1f}" height="{bar_h:.1f}" fill="{COLORS[tipo]}"/>')
            parts.append(svg_text(x + (bar_w - 2) / 2, y - 4, f"{value:.3f}", 9))

    legend_y = height - 24
    x = left
    for tipo, label in types:
        parts.append(f'<rect x="{x}" y="{legend_y - 10}" width="12" height="12" fill="{COLORS[tipo]}"/>')
        parts.append(svg_text(x + 18, legend_y, label, 11, "start"))
        x += 150
    (DOCS / "grafico_tiempos_restauracion.svg").write_text(finish_svg(parts), encoding="utf-8")


def make_size_chart(rows: list[dict[str, str]]) -> None:
    width, height = 960, 470
    parts, (left, top, right, bottom) = chart_frame("Tamaño de respaldos", width, height)
    plot_w, plot_h = right - left, bottom - top
    types = [("anio", "Por año"), ("deporte", "Por deporte"), ("deportista", "Por deportista")]
    backup_types = [("full_mb", "FULL", "#333333"), ("diferencial_mb", "DIFF 1", "#666666"), ("diferencial_mb", "DIFF 2", "#999999"), ("diferencial_mb", "DIFF 3", "#c2c2c2")]
    diff_values = {
        "anio": [4.65, 8.09, 10.09],
        "deporte": [2.84, 3.02, 3.02],
        "deportista": [2.46, 2.46, 2.46],
    }
    full_values = {tipo: 4.02 for tipo, _ in types}
    max_value = 11.0

    for tick in range(0, 12, 2):
        y = bottom - (tick / max_value) * plot_h
        parts.append(f'<line x1="{left}" y1="{y:.1f}" x2="{right}" y2="{y:.1f}" stroke="#dddddd"/>')
        parts.append(svg_text(left - 8, y + 4, str(tick), 10, "end"))
    parts.append(f'<line x1="{left}" y1="{top}" x2="{left}" y2="{bottom}" stroke="#333"/>')
    parts.append(f'<line x1="{left}" y1="{bottom}" x2="{right}" y2="{bottom}" stroke="#333"/>')

    group_w = plot_w / len(types)
    bar_w = group_w / 6
    for group_index, (tipo, label) in enumerate(types):
        center = left + group_w * (group_index + 0.5)
        parts.append(svg_text(center, bottom + 22, label, 11))
        values = [full_values[tipo], *diff_values[tipo]]
        for index, value in enumerate(values):
            x = center - 2 * bar_w + index * bar_w
            bar_h = value / max_value * plot_h
            y = bottom - bar_h
            color = backup_types[index][2]
            parts.append(f'<rect x="{x:.1f}" y="{y:.1f}" width="{bar_w - 3:.1f}" height="{bar_h:.1f}" fill="{color}"/>')
            parts.append(svg_text(x + (bar_w - 3) / 2, y - 4, f"{value:.2f}", 9))

    legend_y = height - 24
    x = left
    labels = [("FULL", "#333333"), ("DIFF 1", "#666666"), ("DIFF 2", "#999999"), ("DIFF 3", "#c2c2c2")]
    for label, color in labels:
        parts.append(f'<rect x="{x}" y="{legend_y - 10}" width="12" height="12" fill="{color}"/>')
        parts.append(svg_text(x + 18, legend_y, label, 11, "start"))
        x += 120
    (DOCS / "grafico_tamanos_respaldo.svg").write_text(finish_svg(parts), encoding="utf-8")


def make_fragmentation_chart() -> None:
    width, height = 960, 470
    parts, (left, top, right, bottom) = chart_frame("Máximo de fragmentación observada", width, height)
    plot_w, plot_h = right - left, bottom - top
    stages = ["Carga 0", "Carga 1", "Carga 2", "Carga 3"]
    series = {
        "anio": [0.0, 50.0, 98.02, 99.49],
        "deporte": [0.0, 0.0, 0.0, 0.0],
        "deportista": [0.0, 0.0, 0.0, 0.0],
    }
    labels = {"anio": "Por año", "deporte": "Por deporte", "deportista": "Por deportista"}
    for tick in range(0, 101, 20):
        y = bottom - (tick / 100) * plot_h
        parts.append(f'<line x1="{left}" y1="{y:.1f}" x2="{right}" y2="{y:.1f}" stroke="#dddddd"/>')
        parts.append(svg_text(left - 8, y + 4, f"{tick}%", 10, "end"))
    parts.append(f'<line x1="{left}" y1="{top}" x2="{left}" y2="{bottom}" stroke="#333"/>')
    parts.append(f'<line x1="{left}" y1="{bottom}" x2="{right}" y2="{bottom}" stroke="#333"/>')
    group_w = plot_w / len(stages)
    bar_w = group_w / 5
    for stage_index, stage in enumerate(stages):
        center = left + group_w * (stage_index + 0.5)
        parts.append(svg_text(center, bottom + 22, stage, 11))
        for series_index, tipo in enumerate(("anio", "deporte", "deportista")):
            value = series[tipo][stage_index]
            x = center - 1.5 * bar_w + series_index * bar_w
            bar_h = value / 100 * plot_h
            y = bottom - bar_h
            parts.append(f'<rect x="{x:.1f}" y="{y:.1f}" width="{bar_w - 2:.1f}" height="{max(bar_h, 1):.1f}" fill="{COLORS[tipo]}"/>')
            if value > 0:
                parts.append(svg_text(x + (bar_w - 2) / 2, y - 4, f"{value:.2f}%", 9))
    legend_y = height - 24
    x = left
    for tipo in ("anio", "deporte", "deportista"):
        parts.append(f'<rect x="{x}" y="{legend_y - 10}" width="12" height="12" fill="{COLORS[tipo]}"/>')
        parts.append(svg_text(x + 18, legend_y, labels[tipo], 11, "start"))
        x += 150
    (DOCS / "grafico_fragmentacion.svg").write_text(finish_svg(parts), encoding="utf-8")


def inline_markup(value: str) -> str:
    value = re.sub(r"<(https?://[^>]+)>", r"[\1](\1)", value)
    value = html.escape(value, quote=False)
    value = re.sub(r"!\[([^]]*)\]\(([^)]+)\)", r'<img src="\2" alt="\1">', value)
    value = re.sub(r"\[([^]]+)\]\(([^)]+)\)", r'<a href="\2">\1</a>', value)
    value = re.sub(r"`([^`]+)`", r"<code>\1</code>", value)
    value = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", value)
    return value


def is_table_line(line: str) -> bool:
    return line.strip().startswith("|") and line.strip().endswith("|")


def table_html(lines: list[str]) -> str:
    rows = []
    for line in lines:
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if all(re.fullmatch(r":?-+:?", cell) for cell in cells):
            continue
        rows.append(cells)
    if not rows:
        return ""
    output = ["<table>", "<thead>", "<tr>"]
    output.extend(f"<th>{inline_markup(cell)}</th>" for cell in rows[0])
    output.extend(["</tr>", "</thead>", "<tbody>"])
    for row in rows[1:]:
        output.append("<tr>")
        output.extend(f"<td>{inline_markup(cell)}</td>" for cell in row)
        output.append("</tr>")
    output.extend(["</tbody>", "</table>"])
    return "".join(output)


def markdown_to_html(markdown: str) -> str:
    lines = markdown.splitlines()
    output: list[str] = []
    index = 0
    in_code = False
    code_lines: list[str] = []
    while index < len(lines):
        line = lines[index]
        if line.startswith("```"):
            if in_code:
                output.append(f"<pre><code>{html.escape(chr(10).join(code_lines))}</code></pre>")
                code_lines = []
                in_code = False
            else:
                in_code = True
            index += 1
            continue
        if in_code:
            code_lines.append(line)
            index += 1
            continue
        if is_table_line(line):
            table_lines = []
            while index < len(lines) and is_table_line(lines[index]):
                table_lines.append(lines[index])
                index += 1
            output.append(table_html(table_lines))
            continue
        heading = re.match(r"^(#{1,6})\s+(.+)$", line)
        if heading:
            level = len(heading.group(1))
            output.append(f"<h{level}>{inline_markup(heading.group(2))}</h{level}>")
            index += 1
            continue
        if line.strip() in {"---", "***"}:
            output.append("<hr>")
            index += 1
            continue
        if line.startswith("- "):
            items = []
            while index < len(lines) and lines[index].startswith("- "):
                items.append(f"<li>{inline_markup(lines[index][2:])}</li>")
                index += 1
            output.append("<ul>" + "".join(items) + "</ul>")
            continue
        numbered = re.match(r"^\d+\.\s+(.+)$", line)
        if numbered:
            items = []
            while index < len(lines):
                match = re.match(r"^\d+\.\s+(.+)$", lines[index])
                if not match:
                    break
                items.append(f"<li>{inline_markup(match.group(1))}</li>")
                index += 1
            output.append("<ol>" + "".join(items) + "</ol>")
            continue
        if not line.strip():
            index += 1
            continue
        output.append(f"<p>{inline_markup(line)}</p>")
        index += 1
    return "\n".join(output)


def make_html() -> None:
    content = markdown_to_html(MD_PATH.read_text(encoding="utf-8"))
    css = """
    @page { size: A4; margin: 18mm 16mm 18mm 16mm; }
    body { font-family: Arial, sans-serif; color: #222; font-size: 10.5pt; line-height: 1.35; }
    h1 { font-size: 22pt; margin-top: 0; border-bottom: 1px solid #333; padding-bottom: 5px; }
    h2 { font-size: 15pt; margin-top: 22px; border-bottom: 1px solid #aaa; padding-bottom: 3px; }
    h3 { font-size: 12pt; margin-top: 16px; }
    p { margin: 6px 0; }
    ul, ol { margin-top: 4px; }
    code { font-family: Consolas, monospace; font-size: 9pt; background: #f0f0f0; padding: 1px 3px; }
    pre { font-family: Consolas, monospace; font-size: 8.5pt; background: #f4f4f4; border: 1px solid #ccc; padding: 8px; white-space: pre-wrap; }
    table { border-collapse: collapse; width: 100%; margin: 8px 0 12px; font-size: 8.7pt; }
    th, td { border: 1px solid #999; padding: 4px 5px; vertical-align: top; }
    th { background: #e8e8e8; font-weight: bold; }
    img { display: block; max-width: 100%; height: auto; margin: 10px auto; page-break-inside: avoid; }
    a { color: #222; text-decoration: underline; }
    hr { border: 0; border-top: 1px solid #aaa; }
    """
    document = "<!doctype html><html><head><meta charset=\"utf-8\"><title>Manual técnico</title><style>" + css + "</style></head><body>" + content + "</body></html>"
    (DOCS / "manual_tecnico.html").write_text(document, encoding="utf-8")


def main() -> None:
    rows = load_rows()
    make_time_chart(rows)
    make_size_chart(rows)
    make_fragmentation_chart()
    make_html()
    print("Generados: grafico_tiempos_restauracion.svg, grafico_tamanos_respaldo.svg, grafico_fragmentacion.svg, manual_tecnico.html")


if __name__ == "__main__":
    main()
