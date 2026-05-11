#!/usr/bin/env python3
import argparse
import binascii
import shutil
import struct
import subprocess
import sys
import zlib
from colorsys import rgb_to_hsv
from pathlib import Path


def read_png(path):
    data = path.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"{path}: not a PNG")

    chunks = []
    pos = 8
    while pos < len(data):
        size = struct.unpack(">I", data[pos:pos + 4])[0]
        kind = data[pos + 4:pos + 8]
        payload = data[pos + 8:pos + 8 + size]
        chunks.append((kind, payload))
        pos += size + 12

    ihdr = next(payload for kind, payload in chunks if kind == b"IHDR")
    width, height, bit_depth, color_type, _, _, interlace = struct.unpack(">IIBBBBB", ihdr)
    if bit_depth != 8 or color_type not in (2, 6) or interlace != 0:
        raise ValueError(
            f"{path}: unsupported PNG bit_depth={bit_depth}, color_type={color_type}, interlace={interlace}"
        )

    channels = 4 if color_type == 6 else 3
    raw = zlib.decompress(b"".join(payload for kind, payload in chunks if kind == b"IDAT"))
    stride = width * channels
    rows = []
    previous = [0] * stride
    offset = 0

    for _ in range(height):
        filter_type = raw[offset]
        offset += 1
        scanline = list(raw[offset:offset + stride])
        offset += stride
        row = [0] * stride

        for i, value in enumerate(scanline):
            left = row[i - channels] if i >= channels else 0
            up = previous[i]
            up_left = previous[i - channels] if i >= channels else 0

            if filter_type == 0:
                result = value
            elif filter_type == 1:
                result = value + left
            elif filter_type == 2:
                result = value + up
            elif filter_type == 3:
                result = value + ((left + up) // 2)
            elif filter_type == 4:
                predictor = left + up - up_left
                distances = (
                    abs(predictor - left),
                    abs(predictor - up),
                    abs(predictor - up_left),
                )
                predicted = (left, up, up_left)[distances.index(min(distances))]
                result = value + predicted
            else:
                raise ValueError(f"Unsupported PNG filter {filter_type}")

            row[i] = result & 0xFF

        rows.append(row)
        previous = row

    return width, height, channels, rows


def write_png(path, width, height, rows):
    raw = bytearray()
    for row in rows:
        raw.append(0)
        raw.extend(row)

    def chunk(kind, payload):
        checksum = binascii.crc32(kind + payload) & 0xFFFFFFFF
        return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", checksum)

    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    data = (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", ihdr)
        + chunk(b"IDAT", zlib.compress(bytes(raw), 9))
        + chunk(b"IEND", b"")
    )
    path.write_bytes(data)


def remove_green_hsv(r, g, b, alpha):
    hue, saturation, value = rgb_to_hsv(r / 255, g / 255, b / 255)
    is_green_hue = 0.20 <= hue <= 0.46
    is_green_dominant = g > r * 1.18 and g > b * 1.18

    if not (is_green_hue and is_green_dominant and saturation > 0.20 and value > 0.20):
        return r, g, b, alpha

    strength = min(
        1.0,
        max(0.0, (saturation - 0.20) / 0.38)
        * max(0.0, (value - 0.20) / 0.35),
    )
    if g > r * 1.75 and g > b * 1.75:
        strength = 1.0

    alpha = int(round(alpha * (1.0 - strength)))
    if alpha < 32:
        return 0, 0, 0, 0

    g = min(g, int((r + b) * 0.55))
    return r, g, b, alpha


def crop_and_key(rows, channels, x0, y0, x1, y1):
    output = []
    for y in range(y0, y1):
        src = rows[y]
        dst = []
        for x in range(x0, x1):
            offset = x * channels
            r, g, b = src[offset], src[offset + 1], src[offset + 2]
            alpha = src[offset + 3] if channels == 4 else 255
            dst.extend(remove_green_hsv(r, g, b, alpha))
        output.append(dst)
    return output


def run_convert(input_path, output_path, size):
    if not shutil.which("convert"):
        raise RuntimeError("ImageMagick `convert` is required for trim/resize")
    if not shutil.which("identify"):
        raise RuntimeError("ImageMagick `identify` is required for trim/resize")

    trimmed_path = output_path.with_name(output_path.stem + "_trimmed.png")
    subprocess.run(
        [
            "convert",
            str(input_path),
            "-trim",
            "+repage",
            str(trimmed_path),
        ],
        check=True,
    )
    dimensions = subprocess.check_output(
        ["identify", "-format", "%w %h", str(trimmed_path)],
        text=True,
    )
    width, height = (int(value) for value in dimensions.split())
    extent = max(width, height)

    subprocess.run(
        [
            "convert",
            str(trimmed_path),
            "-background",
            "none",
            "-gravity",
            "center",
            "-extent",
            f"{extent}x{extent}",
            "-resize",
            f"{size}x{size}",
            "-depth",
            "8",
            str(output_path),
        ],
        check=True,
    )


def parse_cell(value):
    row, column = value.split(",", 1)
    return int(row), int(column)


def main():
    parser = argparse.ArgumentParser(
        description="Cut icons from a chroma-key sheet, remove green in HSV space, and resize."
    )
    parser.add_argument("sheet", type=Path)
    parser.add_argument("--rows", type=int, required=True)
    parser.add_argument("--cols", type=int, required=True)
    parser.add_argument("--size", type=int, default=64)
    parser.add_argument(
        "--icon",
        action="append",
        required=True,
        metavar="ROW,COL:OUTPUT.png",
        help="1-based cell and output path. Can be repeated.",
    )
    parser.add_argument(
        "--keep-intermediate",
        action="store_true",
        help="Keep *_alpha_hsv.png files next to each output.",
    )
    args = parser.parse_args()

    width, height, channels, rows = read_png(args.sheet)
    x_edges = [round(i * width / args.cols) for i in range(args.cols + 1)]
    y_edges = [round(i * height / args.rows) for i in range(args.rows + 1)]

    for spec in args.icon:
        cell, output_name = spec.split(":", 1)
        row, column = parse_cell(cell)
        if row < 1 or row > args.rows or column < 1 or column > args.cols:
            raise ValueError(f"Cell out of range: {cell}")

        output = Path(output_name)
        output.parent.mkdir(parents=True, exist_ok=True)
        intermediate = output.with_name(output.stem + "_alpha_hsv.png")

        x0, x1 = x_edges[column - 1], x_edges[column]
        y0, y1 = y_edges[row - 1], y_edges[row]
        keyed_rows = crop_and_key(rows, channels, x0, y0, x1, y1)
        write_png(intermediate, x1 - x0, y1 - y0, keyed_rows)
        run_convert(intermediate, output, args.size)

        if not args.keep_intermediate:
            intermediate.unlink()
        print(output)


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"error: {exc}", file=sys.stderr)
        sys.exit(1)
