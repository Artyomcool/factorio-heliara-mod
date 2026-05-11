#!/usr/bin/env python3
import argparse
import shutil
import subprocess
import sys
from pathlib import Path


ELEMENTS = {
    "brick_dust": (1, 1),
    "shungite": (1, 2),
    "carbon": (1, 3),
    "fullerene": (2, 1),
    "graphite": (2, 2),
    "arrow": (2, 3),
}

def run(command):
    subprocess.run(command, check=True)


def capture(command):
    return subprocess.check_output(command, text=True).strip()


def require_tool(name):
    if not shutil.which(name):
        raise RuntimeError(f"`{name}` is required")


def crop_element(atlas, rows, cols, row, col, output):
    width, height = (int(value) for value in capture(["identify", "-format", "%w %h", str(atlas)]).split())
    x_edges = [round(i * width / cols) for i in range(cols + 1)]
    y_edges = [round(i * height / rows) for i in range(rows + 1)]
    x0, x1 = x_edges[col - 1], x_edges[col]
    y0, y1 = y_edges[row - 1], y_edges[row]
    run([
        "convert",
        str(atlas),
        "-crop",
        f"{x1 - x0}x{y1 - y0}+{x0}+{y0}",
        "+repage",
        str(output),
    ])


def parse_pair(value):
    x, y = value.split(",", 1)
    return int(x), int(y)


def parse_recipe(value):
    source, result = value.split(",", 1)
    if source not in ELEMENTS:
        raise argparse.ArgumentTypeError(f"unknown source element: {source}")
    if result not in ELEMENTS:
        raise argparse.ArgumentTypeError(f"unknown result element: {result}")
    if source == "arrow" or result == "arrow":
        raise argparse.ArgumentTypeError("arrow cannot be used as source or result")
    return source, result


def prepare_elements(args):
    element_dir = args.output_dir / "conversion_elements"
    element_dir.mkdir(parents=True, exist_ok=True)

    chroma_icon = Path(__file__).with_name("chroma-icon.py")
    prepared = {}
    for name, (row, col) in ELEMENTS.items():
        crop = element_dir / f"{name}_crop_chroma.png"
        output = element_dir / f"{name}.png"
        crop_element(args.atlas, args.rows, args.cols, row, col, crop)
        run([
            sys.executable,
            str(chroma_icon),
            str(crop),
            str(output),
            "--size",
            str(args.element_size),
            "--keep-intermediate",
        ])

        if name in args.flop_element:
            run(["convert", str(output), "-flop", str(output)])

        prepared[name] = output

    return prepared


def resized(input_path, output_path, size):
    run(["convert", str(input_path), "-resize", f"{size}x{size}", str(output_path)])


def compose_icon(args, prepared, source, result, output):
    output.parent.mkdir(parents=True, exist_ok=True)
    source_tmp = output.with_name(output.stem + "_source.png")
    result_tmp = output.with_name(output.stem + "_result.png")
    arrow_tmp = output.with_name(output.stem + "_arrow.png")

    resized(prepared[source], source_tmp, args.source_size)
    resized(prepared[result], result_tmp, args.result_size)
    resized(prepared["arrow"], arrow_tmp, args.arrow_size)

    source_x, source_y = args.source_pos
    result_x, result_y = args.result_pos
    arrow_x, arrow_y = args.arrow_pos

    run([
        "convert",
        "-size",
        f"{args.icon_size}x{args.icon_size}",
        "xc:none",
        str(result_tmp),
        "-geometry",
        f"+{result_x}+{result_y}",
        "-composite",
        str(arrow_tmp),
        "-geometry",
        f"+{arrow_x}+{arrow_y}",
        "-composite",
        str(source_tmp),
        "-geometry",
        f"+{source_x}+{source_y}",
        "-composite",
        "-depth",
        "8",
        str(output),
    ])


def main():
    parser = argparse.ArgumentParser(
        description="Build A-from-B recipe icons from a chroma-key element atlas."
    )
    parser.add_argument("atlas", type=Path)
    parser.add_argument(
        "--recipe",
        action="append",
        type=parse_recipe,
        required=True,
        metavar="SOURCE,RESULT",
        help="Build <result>_from_<source>.png. Can be repeated.",
    )
    parser.add_argument("--output-dir", type=Path, default=Path("src/graphics/icons"))
    parser.add_argument("--rows", type=int, default=2)
    parser.add_argument("--cols", type=int, default=3)
    parser.add_argument("--element-size", type=int, default=128)
    parser.add_argument("--icon-size", type=int, default=64)
    parser.add_argument("--source-size", type=int, default=29)
    parser.add_argument("--result-size", type=int, default=35)
    parser.add_argument("--arrow-size", type=int, default=30)
    parser.add_argument("--source-pos", type=parse_pair, default=(35, 0), metavar="X,Y")
    parser.add_argument("--result-pos", type=parse_pair, default=(4, 25), metavar="X,Y")
    parser.add_argument("--arrow-pos", type=parse_pair, default=(17, 9), metavar="X,Y")
    parser.add_argument(
        "--flop-element",
        action="append",
        choices=sorted(ELEMENTS),
        default=[],
        help="Horizontally flip a prepared atlas element. Can be repeated.",
    )
    args = parser.parse_args()

    if not args.flop_element:
        args.flop_element = ["arrow", "graphite"]

    require_tool("convert")
    require_tool("identify")

    prepared = prepare_elements(args)
    for source, result in args.recipe:
        output = args.output_dir / f"{result}_from_{source}.png"
        compose_icon(args, prepared, source, result, output)
        print(output)


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"error: {exc}", file=sys.stderr)
        sys.exit(1)
