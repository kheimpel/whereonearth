#!/usr/bin/env python3
"""Renders Natural Earth GeoJSON into map strip tiles for the watch app."""

import argparse
import math
import os
from pathlib import Path

import geopandas as gpd
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from PIL import Image
import yaml


def load_config(config_path):
    with open(config_path) as f:
        return yaml.safe_load(f)


def mercator_y(lat_deg):
    """Convert latitude in degrees to Mercator y value."""
    lat_deg = max(-85.051129, min(85.051129, lat_deg))
    lat_rad = math.radians(lat_deg)
    return math.log(math.tan(math.pi / 4 + lat_rad / 2))


def render_strip(config, level_name):
    """Render a full Mercator strip for one level and return as PIL Image."""
    level = config["levels"][level_name]
    styles = config["styles"]
    lat_min, lat_max = config["lat_bounds"]
    pad = config["strip_padding_deg"]

    lng_min = -180 - pad
    lng_max = 180 + pad
    lng_range = lng_max - lng_min

    merc_y_min = mercator_y(lat_min)
    merc_y_max = mercator_y(lat_max)

    ppd = config.get("pixels_per_degree", 22)
    strip_width_px = int(ppd * lng_range)
    strip_height_px = int(ppd * math.degrees(merc_y_max - merc_y_min))

    fig_w = strip_width_px / 100
    fig_h = strip_height_px / 100
    fig, ax = plt.subplots(1, 1, figsize=(fig_w, fig_h), dpi=100)
    fig.patch.set_facecolor(styles["bg"])
    ax.set_facecolor(styles["bg"])
    ax.set_xlim(lng_min, lng_max)
    ax.set_ylim(merc_y_min, merc_y_max)
    ax.set_aspect("equal")
    ax.axis("off")
    fig.subplots_adjust(left=0, right=1, top=1, bottom=0)

    # Draw graticule
    graticule_color = styles["graticule_color"]
    graticule_alpha = styles["graticule_alpha"]
    for lat in range(-60, 81, 20):
        y = mercator_y(lat)
        ax.axhline(y=y, color=graticule_color, alpha=graticule_alpha, linewidth=0.5)
    for lng in range(-180, 181, 30):
        ax.axvline(x=lng, color=graticule_color, alpha=graticule_alpha, linewidth=0.5)

    # Load and draw layers
    for layer_name in level["layers"]:
        source_scale = level["source_scale"]
        geojson_path = f"data/ne_{source_scale}_{layer_name}.geojson"
        if not os.path.exists(geojson_path):
            print(f"  Warning: {geojson_path} not found, skipping")
            continue

        gdf = gpd.read_file(geojson_path)

        if layer_name == "land":
            for offset in [-360, 0, 360]:
                gdf_shifted = gdf.copy()
                gdf_shifted.geometry = gdf_shifted.geometry.translate(xoff=offset)
                for _, row in gdf_shifted.iterrows():
                    geom = row.geometry
                    if geom.geom_type == "Polygon":
                        xs, ys = geom.exterior.xy
                        ys_merc = [mercator_y(y) for y in ys]
                        ax.fill(
                            xs, ys_merc, facecolor=styles["land_fill"], edgecolor="none"
                        )
                    elif geom.geom_type == "MultiPolygon":
                        for poly in geom.geoms:
                            xs, ys = poly.exterior.xy
                            ys_merc = [mercator_y(y) for y in ys]
                            ax.fill(
                                xs,
                                ys_merc,
                                facecolor=styles["land_fill"],
                                edgecolor="none",
                            )

        if layer_name == "coastline":
            for offset in [-360, 0, 360]:
                gdf_shifted = gdf.copy()
                gdf_shifted.geometry = gdf_shifted.geometry.translate(xoff=offset)
                for _, row in gdf_shifted.iterrows():
                    geom = row.geometry
                    if geom.geom_type == "LineString":
                        xs, ys = geom.xy
                        ys_merc = [mercator_y(y) for y in ys]
                        ax.plot(
                            xs,
                            ys_merc,
                            color=styles["coastline"],
                            linewidth=styles["coastline_width"],
                            solid_capstyle="round",
                        )
                    elif geom.geom_type == "MultiLineString":
                        for line in geom.geoms:
                            xs, ys = line.xy
                            ys_merc = [mercator_y(y) for y in ys]
                            ax.plot(
                                xs,
                                ys_merc,
                                color=styles["coastline"],
                                linewidth=styles["coastline_width"],
                                solid_capstyle="round",
                            )

    # Save to buffer
    output_dir = Path("pipeline/output") / level_name
    output_dir.mkdir(parents=True, exist_ok=True)
    strip_path = output_dir / "strip.png"
    fig.savefig(strip_path, dpi=100, facecolor=styles["bg"], pad_inches=0)
    plt.close(fig)

    return Image.open(strip_path), strip_width_px


def slice_tiles(strip_img, config, level_name):
    """Slice a full strip image into individual tiles."""
    tile_w = config["tile_width"]
    pad = config["strip_padding_deg"]

    tile_h = config["tile_height"]
    strip_w, strip_h = strip_img.size

    # Calculate pixel offset for the padding region
    total_lng_range = 360 + 2 * pad
    pad_pixels = int(strip_w * pad / total_lng_range)

    # The "usable" strip is the central 360 degrees
    usable_start = pad_pixels
    usable_width = strip_w - 2 * pad_pixels

    num_tiles = math.ceil(usable_width / tile_w)
    output_dir = Path("pipeline/output") / level_name / "tiles"
    output_dir.mkdir(parents=True, exist_ok=True)

    for i in range(num_tiles):
        left = usable_start + i * tile_w
        right = min(left + tile_w, strip_w)
        tile = strip_img.crop((left, 0, right, strip_h))

        # Resize to exact tile dimensions if needed (last tile may be narrower)
        if tile.size[0] < tile_w:
            padded = Image.new("RGB", (tile_w, tile_h), config["styles"]["bg"])
            padded.paste(tile, (0, 0))
            tile = padded

        if tile.size[1] != tile_h:
            tile = tile.resize((tile.size[0], tile_h), Image.LANCZOS)

        tile_path = output_dir / f"tile_{i:02d}@2x.png"
        tile.save(tile_path, "PNG", optimize=True)

    print(f"  {level_name}: {num_tiles} tiles saved to {output_dir}/")
    return num_tiles


def main():
    parser = argparse.ArgumentParser(description="Render map tiles for Where on Earth")
    parser.add_argument(
        "--config", default="pipeline/config.yaml", help="Path to config file"
    )
    parser.add_argument(
        "--level", default="all", help="Level to render (L1, L2, L3, or all)"
    )
    args = parser.parse_args()

    config = load_config(args.config)

    levels_to_render = (
        list(config["levels"].keys()) if args.level == "all" else [args.level]
    )

    for level_name in levels_to_render:
        if level_name not in config["levels"]:
            print(f"Error: level '{level_name}' not found in config")
            continue
        print(f"Rendering {level_name}...")
        strip_img, strip_width = render_strip(config, level_name)
        slice_tiles(strip_img, config, level_name)

    print("Done.")


if __name__ == "__main__":
    main()
