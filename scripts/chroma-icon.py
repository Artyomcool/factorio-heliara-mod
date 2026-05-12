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
    path.write_bytes(
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", ihdr)
        + chunk(b"IDAT", zlib.compress(bytes(raw), 9))
        + chunk(b"IEND", b"")
    )


def remove_chroma_hsv(r, g, b, alpha, key):
    hue, saturation, value = rgb_to_hsv(r / 255, g / 255, b / 255)

    if key == "green":
        is_key_hue = 0.20 <= hue <= 0.46
        is_key_dominant = g > r * 1.18 and g > b * 1.18
        strong_key = g > r * 1.75 and g > b * 1.75
    elif key == "magenta":
        is_key_hue = 0.60 <= hue <= 0.98
        is_key_dominant = r > g * 1.01 and b > g * 1.01
        strong_key = r > g * 1.20 and b > g * 1.20
    else:
        raise ValueError(f"Unsupported chroma key {key}")

    min_saturation = 0.05 if key == "magenta" else 0.20
    min_value = 0.12 if key == "magenta" else 0.20
    if not (is_key_hue and is_key_dominant and saturation > min_saturation and value > min_value):
        return r, g, b, alpha

    strength = min(
        1.0,
        max(0.0, (saturation - min_saturation) / 0.24)
        * max(0.0, (value - min_value) / 0.22),
    )
    if strong_key:
        strength = 1.0

    if key == "magenta" and strength > 0.08:
        return 0, 0, 0, 0

    alpha = int(round(alpha * (1.0 - strength)))
    if alpha < 32:
        return 0, 0, 0, 0

    if key == "green":
        g = min(g, int((r + b) * 0.55))
    elif key == "magenta":
        spill_limit = max(g, int(g * 1.25))
        r = min(r, spill_limit)
        b = min(b, spill_limit)
    return r, g, b, alpha


def key_image(input_path, alpha_path, key):
    width, height, channels, rows = read_png(input_path)
    output_rows = []
    for row in rows:
        output = []
        for offset in range(0, len(row), channels):
            r, g, b = row[offset], row[offset + 1], row[offset + 2]
            alpha = row[offset + 3] if channels == 4 else 255
            output.extend(remove_chroma_hsv(r, g, b, alpha, key))
        output_rows.append(output)
    write_png(alpha_path, width, height, output_rows)


def trim_and_resize(input_path, output_path, size):
    if not shutil.which("convert"):
        raise RuntimeError("ImageMagick `convert` is required")
    if not shutil.which("identify"):
        raise RuntimeError("ImageMagick `identify` is required")

    trimmed_path = output_path.with_name(output_path.stem + "_trimmed.png")
    subprocess.run(
        ["convert", str(input_path), "-trim", "+repage", str(trimmed_path)],
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
    return trimmed_path


def main():
    parser = argparse.ArgumentParser(
        description="Remove green chroma-key in HSV space and produce a square resized icon."
    )
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--size", type=int, default=64)
    parser.add_argument("--key", choices=("green", "magenta"), default="green")
    parser.add_argument(
        "--keep-intermediate",
        action="store_true",
        help="Keep *_alpha_hsv.png and *_trimmed.png next to the output.",
    )
    args = parser.parse_args()

    args.output.parent.mkdir(parents=True, exist_ok=True)
    alpha_path = args.output.with_name(args.output.stem + "_alpha_hsv.png")
    key_image(args.input, alpha_path, args.key)
    trimmed_path = trim_and_resize(alpha_path, args.output, args.size)

    if not args.keep_intermediate:
        alpha_path.unlink()
        trimmed_path.unlink()

    print(args.output)


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"error: {exc}", file=sys.stderr)
        sys.exit(1)
