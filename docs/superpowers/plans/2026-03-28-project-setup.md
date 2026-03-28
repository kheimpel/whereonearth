# Where on Earth — Project Setup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Set up a fully buildable and testable Apple Watch standalone app with a Python tile pipeline, 5 starter clues, and an end-to-end game loop running on the watch simulator.

**Architecture:** Monorepo with two main components: (1) a Python tile-rendering pipeline that converts Natural Earth GeoJSON into pre-rendered map strip PNGs, and (2) a SwiftUI watchOS app that displays clues, lets the user guess longitude via Digital Crown, scores the answer, and cycles through a 5-clue session. The map strip is a horizontally-scrollable set of tile images with a SwiftUI Canvas overlay for the interactive pin.

**Tech Stack:** Swift 6.3 / SwiftUI / watchOS 11+ / Xcode 26, Python 3.11 / geopandas / cartopy / matplotlib / pillow, mapshaper, GDAL/ogr2ogr, Make

---

## File Structure

### Pipeline
| File | Responsibility |
|------|---------------|
| `pipeline/requirements.txt` | Python dependencies |
| `pipeline/config.yaml` | Tile rendering configuration (colors, dimensions, levels) |
| `pipeline/render_tiles.py` | Main renderer: reads GeoJSON + config, renders Mercator strip, slices tiles |
| `data/` | Natural Earth GeoJSON files (downloaded, checked in) |
| `Makefile` | Orchestrates `make setup`, `make tiles`, `make test`, `make clean` |

### Watch App
| File | Responsibility |
|------|---------------|
| `WhereOnEarth/WhereOnEarth/WhereOnEarthApp.swift` | App entry point |
| `WhereOnEarth/WhereOnEarth/Models/Clue.swift` | Clue data model (Codable struct) |
| `WhereOnEarth/WhereOnEarth/Models/GameSession.swift` | Session state: current clue index, guesses, scores |
| `WhereOnEarth/WhereOnEarth/Services/GameEngine.swift` | Scoring logic, session lifecycle |
| `WhereOnEarth/WhereOnEarth/Services/ClueBank.swift` | Loads clues.json, serves clues |
| `WhereOnEarth/WhereOnEarth/Services/HapticsService.swift` | Haptic feedback wrapper |
| `WhereOnEarth/WhereOnEarth/Views/MenuView.swift` | Home screen with Play button |
| `WhereOnEarth/WhereOnEarth/Views/GameView.swift` | Session controller: cycles clue -> guess -> result |
| `WhereOnEarth/WhereOnEarth/Views/ClueView.swift` | Displays clue text |
| `WhereOnEarth/WhereOnEarth/Views/MapStripView.swift` | Tile strip + Digital Crown input + Canvas pin overlay |
| `WhereOnEarth/WhereOnEarth/Views/ResultView.swift` | Shows score after each guess |
| `WhereOnEarth/WhereOnEarth/Resources/clues.json` | 5 starter clues |
| `WhereOnEarth/WhereOnEarthTests/GameEngineTests.swift` | Unit tests for scoring logic |
| `WhereOnEarth/WhereOnEarthTests/ClueTests.swift` | Unit tests for Clue model and ClueBank |
| `WhereOnEarth/WhereOnEarthUITests/GameFlowUITests.swift` | UI test for full game flow |

---

### Task 1: Repository scaffolding and .gitignore

**Files:**
- Create: `.gitignore`
- Create: `Makefile`
- Modify: `README.md`

- [ ] **Step 1: Create .gitignore**

```gitignore
# macOS
.DS_Store
*.swp
*~

# Xcode
build/
DerivedData/
*.xcuserdata/
*.xcworkspace/xcuserdata/
xcuserdata/
*.moved-aside
*.hmap
*.ipa
*.dSYM.zip
*.dSYM

# Swift Package Manager
.build/
Packages/

# Python
__pycache__/
*.pyc
*.pyo
*.egg-info/
dist/
.venv/
venv/

# Pipeline output
pipeline/output/

# Generated tiles are checked in (they go to Assets.xcassets)
# but the intermediate full-strip PNGs are not
pipeline/*.png
```

- [ ] **Step 2: Create initial Makefile**

```makefile
.PHONY: setup tiles tiles-L1 clean-tiles test clean

setup:
	pip install -r pipeline/requirements.txt
	@echo "Setup complete. Run 'make tiles' to generate map tiles."

tiles:
	python3 pipeline/render_tiles.py --config pipeline/config.yaml --level all

tiles-L1:
	python3 pipeline/render_tiles.py --config pipeline/config.yaml --level L1

clean-tiles:
	rm -rf pipeline/output/
	@echo "Tiles cleaned."

test:
	cd WhereOnEarth && xcodebuild test \
		-scheme WhereOnEarth \
		-destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' \
		-resultBundlePath ../TestResults.xcresult \
		2>&1 | tail -20

clean: clean-tiles
	rm -rf TestResults.xcresult
```

- [ ] **Step 3: Update README.md**

```markdown
# Where on Earth

GeoGuessr for your wrist. A geography guessing game for Apple Watch.

## Structure

- `WhereOnEarth/` — watchOS standalone app (SwiftUI, Xcode 26)
- `pipeline/` — Python tile rendering pipeline
- `data/` — Natural Earth geographic data (GeoJSON)
- `concepts/` — Game design documents

## Quick Start

```bash
make setup          # install Python dependencies
make tiles          # render map tiles
# Open WhereOnEarth/WhereOnEarth.xcodeproj in Xcode
# Run on Apple Watch simulator
```

## Requirements

- Xcode 26+ with watchOS 11 SDK
- Python 3.11+
- GDAL (`brew install gdal`)
- mapshaper (`npm install -g mapshaper`)
```

- [ ] **Step 4: Commit**

```bash
git add .gitignore Makefile README.md
git commit -m "chore: add gitignore, Makefile, and updated README"
```

---

### Task 2: Pipeline scaffolding and Natural Earth data download

**Files:**
- Create: `pipeline/requirements.txt`
- Create: `pipeline/config.yaml`
- Create: `data/` (downloaded GeoJSON files)

- [ ] **Step 1: Create pipeline/requirements.txt**

```
geopandas>=0.14
cartopy>=0.22
matplotlib>=3.8
pillow>=10.0
pyyaml>=6.0
```

- [ ] **Step 2: Install dependencies**

Run: `pip install -r pipeline/requirements.txt`
Expected: All packages install successfully. cartopy may take a minute (compiles C extensions).

- [ ] **Step 3: Create pipeline/config.yaml**

```yaml
projection: web_mercator
lat_bounds: [-72, 84]
tile_height: 800   # pixels, @2x
tile_width: 400    # pixels, @2x
strip_padding_deg: 20

styles:
  bg: "#0C1425"
  coastline: "#D4A843"
  coastline_width: 1.5
  land_fill: "#14213D"
  border: "#2A3A5C"
  river: "#1A3055"
  graticule_color: "#D4A843"
  graticule_alpha: 0.08

levels:
  L1:
    layers:
      - land
      - coastline
    source_scale: "110m"
```

- [ ] **Step 4: Download Natural Earth 110m data**

Run:
```bash
mkdir -p data
curl -L -o /tmp/ne_110m_land.zip "https://naciscdn.org/naturalearth/110m/physical/ne_110m_land.zip"
curl -L -o /tmp/ne_110m_coastline.zip "https://naciscdn.org/naturalearth/110m/physical/ne_110m_coastline.zip"
cd /tmp && unzip -o ne_110m_land.zip -d ne_110m_land && unzip -o ne_110m_coastline.zip -d ne_110m_coastline
```

Then convert to GeoJSON using Python (ogr2ogr may not be installed yet):
```python
import geopandas as gpd
land = gpd.read_file("/tmp/ne_110m_land/ne_110m_land.shp")
land.to_file("data/ne_110m_land.geojson", driver="GeoJSON")
coast = gpd.read_file("/tmp/ne_110m_coastline/ne_110m_coastline.shp")
coast.to_file("data/ne_110m_coastline.geojson", driver="GeoJSON")
```

Expected: `data/ne_110m_land.geojson` (~200KB) and `data/ne_110m_coastline.geojson` (~120KB) created.

- [ ] **Step 5: Commit**

```bash
git add pipeline/requirements.txt pipeline/config.yaml data/
git commit -m "chore: add pipeline config and Natural Earth 110m data"
```

---

### Task 3: Tile renderer — render Mercator strip and slice into tiles

**Files:**
- Create: `pipeline/render_tiles.py`

- [ ] **Step 1: Write render_tiles.py**

```python
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
from matplotlib.patches import Rectangle
from PIL import Image
import yaml


def load_config(config_path):
    with open(config_path) as f:
        return yaml.safe_load(f)


def mercator_y(lat_deg):
    """Convert latitude in degrees to Mercator y value."""
    lat_rad = math.radians(lat_deg)
    return math.log(math.tan(math.pi / 4 + lat_rad / 2))


def render_strip(config, level_name):
    """Render a full Mercator strip for one level and return as PIL Image."""
    level = config["levels"][level_name]
    styles = config["styles"]
    lat_min, lat_max = config["lat_bounds"]
    pad = config["strip_padding_deg"]
    tile_h = config["tile_height"]
    tile_w = config["tile_width"]

    lng_min = -180 - pad
    lng_max = 180 + pad
    lng_range = lng_max - lng_min

    merc_y_min = mercator_y(lat_min)
    merc_y_max = mercator_y(lat_max)
    merc_y_range = merc_y_max - merc_y_min

    aspect = lng_range / (math.degrees(merc_y_range))
    strip_width_px = int(tile_h * aspect * (lng_range / math.degrees(merc_y_range)))

    pixels_per_degree_lng = tile_h / math.degrees(merc_y_range)
    strip_width_px = int(pixels_per_degree_lng * lng_range)

    fig_w = strip_width_px / 100
    fig_h = tile_h / 100
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

        # Convert coordinates to Mercator y
        gdf_projected = gdf.to_crs(epsg=3857)

        if layer_name == "land":
            # Also draw duplicate for wrapping
            for offset in [-360, 0, 360]:
                gdf_shifted = gdf.copy()
                gdf_shifted.geometry = gdf_shifted.geometry.translate(xoff=offset)
                # Convert lat to mercator y for plotting
                for _, row in gdf_shifted.iterrows():
                    geom = row.geometry
                    if geom.geom_type == "Polygon":
                        xs, ys = geom.exterior.xy
                        ys_merc = [mercator_y(y) for y in ys]
                        ax.fill(xs, ys_merc, facecolor=styles["land_fill"], edgecolor="none")
                    elif geom.geom_type == "MultiPolygon":
                        for poly in geom.geoms:
                            xs, ys = poly.exterior.xy
                            ys_merc = [mercator_y(y) for y in ys]
                            ax.fill(xs, ys_merc, facecolor=styles["land_fill"], edgecolor="none")

        if layer_name == "coastline":
            for offset in [-360, 0, 360]:
                gdf_shifted = gdf.copy()
                gdf_shifted.geometry = gdf_shifted.geometry.translate(xoff=offset)
                for _, row in gdf_shifted.iterrows():
                    geom = row.geometry
                    if geom.geom_type == "LineString":
                        xs, ys = geom.xy
                        ys_merc = [mercator_y(y) for y in ys]
                        ax.plot(xs, ys_merc, color=styles["coastline"],
                                linewidth=styles["coastline_width"], solid_capstyle="round")
                    elif geom.geom_type == "MultiLineString":
                        for line in geom.geoms:
                            xs, ys = line.xy
                            ys_merc = [mercator_y(y) for y in ys]
                            ax.plot(xs, ys_merc, color=styles["coastline"],
                                    linewidth=styles["coastline_width"], solid_capstyle="round")

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
    tile_h = config["tile_height"]
    pad = config["strip_padding_deg"]

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

        tile_path = output_dir / f"tile_{i:02d}@2x.png"
        tile.save(tile_path, "PNG", optimize=True)

    print(f"  {level_name}: {num_tiles} tiles saved to {output_dir}/")
    return num_tiles


def main():
    parser = argparse.ArgumentParser(description="Render map tiles for Where on Earth")
    parser.add_argument("--config", default="pipeline/config.yaml", help="Path to config file")
    parser.add_argument("--level", default="all", help="Level to render (L1, L2, L3, or all)")
    args = parser.parse_args()

    config = load_config(args.config)

    levels_to_render = list(config["levels"].keys()) if args.level == "all" else [args.level]

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
```

- [ ] **Step 2: Run the renderer for L1**

Run: `make tiles-L1`
Expected: Terminal prints "Rendering L1..." and "L1: N tiles saved to pipeline/output/L1/tiles/". The `pipeline/output/L1/tiles/` directory contains `tile_00@2x.png` through `tile_NN@2x.png`.

- [ ] **Step 3: Visually verify a tile**

Run: `open pipeline/output/L1/tiles/tile_10@2x.png`
Expected: A dark navy image with gold continent outlines visible. The "Dark Atlas" look.

- [ ] **Step 4: Commit**

```bash
git add pipeline/render_tiles.py
git commit -m "feat: add tile rendering pipeline with L1 support"
```

---

### Task 4: Create Xcode watchOS project

**Files:**
- Create: entire `WhereOnEarth/` Xcode project

This task creates the Xcode project using the command line since we cannot use the Xcode GUI.

- [ ] **Step 1: Create the Xcode project directory structure**

```bash
mkdir -p WhereOnEarth/WhereOnEarth/Views
mkdir -p WhereOnEarth/WhereOnEarth/Models
mkdir -p WhereOnEarth/WhereOnEarth/Services
mkdir -p WhereOnEarth/WhereOnEarth/Resources
mkdir -p "WhereOnEarth/WhereOnEarth/Preview Content"
mkdir -p WhereOnEarth/WhereOnEarthTests
mkdir -p WhereOnEarth/WhereOnEarthUITests
```

- [ ] **Step 2: Create WhereOnEarthApp.swift**

```swift
import SwiftUI

@main
struct WhereOnEarthApp: App {
    var body: some Scene {
        WindowGroup {
            MenuView()
        }
    }
}
```

- [ ] **Step 3: Create placeholder MenuView.swift**

```swift
import SwiftUI

struct MenuView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("WHERE ON\nEARTH")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(hex: "E8DCC8"))

                NavigationLink("Play") {
                    Text("Game coming soon")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "D4A843"))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "0C1425"))
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}

#Preview {
    MenuView()
}
```

- [ ] **Step 4: Create Assets.xcassets**

```bash
mkdir -p WhereOnEarth/WhereOnEarth/Resources/Assets.xcassets/AppIcon.appiconset
```

Create `WhereOnEarth/WhereOnEarth/Resources/Assets.xcassets/Contents.json`:
```json
{
  "info": {
    "author": "xcode",
    "version": 1
  }
}
```

Create `WhereOnEarth/WhereOnEarth/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json`:
```json
{
  "images": [
    {
      "idiom": "watch",
      "scale": "2x",
      "size": "40x44"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
```

- [ ] **Step 5: Create Package.swift for the project (SPM-based watchOS app)**

Since creating an `.xcodeproj` from scratch without Xcode GUI is complex, use a Swift Package-based approach. Create `WhereOnEarth/Package.swift`:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WhereOnEarth",
    platforms: [
        .watchOS(.v11)
    ],
    targets: [
        .executableTarget(
            name: "WhereOnEarth",
            path: "WhereOnEarth",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "WhereOnEarthTests",
            dependencies: ["WhereOnEarth"],
            path: "WhereOnEarthTests"
        ),
    ]
)
```

- [ ] **Step 6: Build the project**

Run: `cd WhereOnEarth && swift build --sdk watchOS 2>&1 | tail -5`

If `swift build --sdk watchOS` is not available, use:
```bash
xcodebuild -scheme WhereOnEarth -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' build 2>&1 | tail -10
```

Expected: Build succeeds.

- [ ] **Step 7: Commit**

```bash
git add WhereOnEarth/
git commit -m "feat: scaffold watchOS standalone app with MenuView"
```

---

### Task 5: Clue model and clues.json

**Files:**
- Create: `WhereOnEarth/WhereOnEarth/Models/Clue.swift`
- Create: `WhereOnEarth/WhereOnEarth/Resources/clues.json`
- Create: `WhereOnEarth/WhereOnEarthTests/ClueTests.swift`

- [ ] **Step 1: Write the failing test for Clue decoding**

```swift
import Testing
@testable import WhereOnEarth

@Test func clueDecodesFromJSON() throws {
    let json = """
    {
        "id": "clue_001",
        "type": "cultural",
        "text": "Trains arrive within 7 seconds of schedule on average.",
        "answer_longitude": 139.7,
        "answer_country": "Japan",
        "answer_region": "East Asia",
        "answer_continent": "Asia",
        "difficulty": 2
    }
    """.data(using: .utf8)!

    let clue = try JSONDecoder().decode(Clue.self, from: json)
    #expect(clue.id == "clue_001")
    #expect(clue.type == .cultural)
    #expect(clue.answerLongitude == 139.7)
    #expect(clue.answerCountry == "Japan")
    #expect(clue.difficulty == 2)
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd WhereOnEarth && swift test --filter ClueTests 2>&1 | tail -10`
Expected: FAIL — `Clue` type not found.

- [ ] **Step 3: Write Clue.swift**

```swift
import Foundation

struct Clue: Codable, Identifiable, Sendable {
    let id: String
    let type: ClueType
    let text: String
    let answerLongitude: Double
    let answerCountry: String
    let answerRegion: String
    let answerContinent: String
    let difficulty: Int

    enum ClueType: String, Codable, Sendable {
        case cultural
        case landmark
        case food
        case language
        case flag
        case street
    }

    enum CodingKeys: String, CodingKey {
        case id, type, text, difficulty
        case answerLongitude = "answer_longitude"
        case answerCountry = "answer_country"
        case answerRegion = "answer_region"
        case answerContinent = "answer_continent"
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd WhereOnEarth && swift test --filter ClueTests 2>&1 | tail -10`
Expected: PASS

- [ ] **Step 5: Create clues.json with 5 starter clues**

Create `WhereOnEarth/WhereOnEarth/Resources/clues.json`:
```json
[
  {
    "id": "clue_001",
    "type": "cultural",
    "text": "Trains arrive within 7 seconds of schedule on average.",
    "answer_longitude": 139.7,
    "answer_country": "Japan",
    "answer_region": "East Asia",
    "answer_continent": "Asia",
    "difficulty": 2
  },
  {
    "id": "clue_002",
    "type": "landmark",
    "text": "This tower was supposed to be temporary, built for a world fair in 1889.",
    "answer_longitude": 2.3,
    "answer_country": "France",
    "answer_region": "Western Europe",
    "answer_continent": "Europe",
    "difficulty": 1
  },
  {
    "id": "clue_003",
    "type": "food",
    "text": "This country invented the croissant.",
    "answer_longitude": 16.4,
    "answer_country": "Austria",
    "answer_region": "Central Europe",
    "answer_continent": "Europe",
    "difficulty": 3
  },
  {
    "id": "clue_004",
    "type": "cultural",
    "text": "This country has more pyramids than Egypt.",
    "answer_longitude": 32.5,
    "answer_country": "Sudan",
    "answer_region": "North Africa",
    "answer_continent": "Africa",
    "difficulty": 3
  },
  {
    "id": "clue_005",
    "type": "language",
    "text": "Danke schoen.",
    "answer_longitude": 10.4,
    "answer_country": "Germany",
    "answer_region": "Central Europe",
    "answer_continent": "Europe",
    "difficulty": 1
  }
]
```

- [ ] **Step 6: Add test for loading clues from bundle**

Add to `ClueTests.swift`:
```swift
@Test func cluesBundleLoadsAllFive() throws {
    let url = Bundle.module.url(forResource: "clues", withExtension: "json")!
    let data = try Data(contentsOf: url)
    let clues = try JSONDecoder().decode([Clue].self, from: data)
    #expect(clues.count == 5)
    #expect(clues[0].id == "clue_001")
    #expect(clues[4].id == "clue_005")
}
```

- [ ] **Step 7: Run tests**

Run: `cd WhereOnEarth && swift test --filter ClueTests 2>&1 | tail -10`
Expected: Both tests PASS.

- [ ] **Step 8: Commit**

```bash
git add WhereOnEarth/WhereOnEarth/Models/Clue.swift WhereOnEarth/WhereOnEarth/Resources/clues.json WhereOnEarth/WhereOnEarthTests/ClueTests.swift
git commit -m "feat: add Clue model with 5 starter clues and tests"
```

---

### Task 6: GameEngine — scoring logic

**Files:**
- Create: `WhereOnEarth/WhereOnEarth/Services/GameEngine.swift`
- Create: `WhereOnEarth/WhereOnEarth/Services/ClueBank.swift`
- Create: `WhereOnEarth/WhereOnEarthTests/GameEngineTests.swift`

- [ ] **Step 1: Write failing tests for scoring**

Create `WhereOnEarth/WhereOnEarthTests/GameEngineTests.swift`:
```swift
import Testing
@testable import WhereOnEarth

@Test func scoreRightCountry() {
    let clue = Clue(
        id: "test", type: .cultural, text: "Test",
        answerLongitude: 139.7, answerCountry: "Japan",
        answerRegion: "East Asia", answerContinent: "Asia",
        difficulty: 1
    )
    let result = GameEngine.score(guessLongitude: 140.0, for: clue)
    #expect(result.points == 3)
    #expect(result.accuracy == .country)
}

@Test func scoreRightRegion() {
    let clue = Clue(
        id: "test", type: .cultural, text: "Test",
        answerLongitude: 139.7, answerCountry: "Japan",
        answerRegion: "East Asia", answerContinent: "Asia",
        difficulty: 1
    )
    // ~20 degrees off — same region but not same country
    let result = GameEngine.score(guessLongitude: 120.0, for: clue)
    #expect(result.points == 2)
    #expect(result.accuracy == .region)
}

@Test func scoreRightContinent() {
    let clue = Clue(
        id: "test", type: .cultural, text: "Test",
        answerLongitude: 139.7, answerCountry: "Japan",
        answerRegion: "East Asia", answerContinent: "Asia",
        difficulty: 1
    )
    // ~70 degrees off — same continent but not same region
    let result = GameEngine.score(guessLongitude: 70.0, for: clue)
    #expect(result.points == 1)
    #expect(result.accuracy == .continent)
}

@Test func scoreWrongContinent() {
    let clue = Clue(
        id: "test", type: .cultural, text: "Test",
        answerLongitude: 139.7, answerCountry: "Japan",
        answerRegion: "East Asia", answerContinent: "Asia",
        difficulty: 1
    )
    // Way off — different continent
    let result = GameEngine.score(guessLongitude: -80.0, for: clue)
    #expect(result.points == 0)
    #expect(result.accuracy == .wrong)
}

@Test func scoringWrapsAroundAntimeridian() {
    let clue = Clue(
        id: "test", type: .cultural, text: "Test",
        answerLongitude: 170.0, answerCountry: "Fiji",
        answerRegion: "Oceania", answerContinent: "Oceania",
        difficulty: 1
    )
    // Guess at -175 is only 15 degrees away (crossing antimeridian)
    let result = GameEngine.score(guessLongitude: -175.0, for: clue)
    #expect(result.points == 2) // within region range
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd WhereOnEarth && swift test --filter GameEngineTests 2>&1 | tail -10`
Expected: FAIL — `GameEngine` not found.

- [ ] **Step 3: Write GameEngine.swift**

```swift
import Foundation

struct ScoreResult: Sendable {
    let points: Int
    let accuracy: Accuracy
    let distanceDegrees: Double

    enum Accuracy: Sendable {
        case country   // 3 points
        case region    // 2 points
        case continent // 1 point
        case wrong     // 0 points
    }
}

enum GameEngine {
    /// Thresholds in degrees of longitude distance
    static let countryThreshold: Double = 10.0
    static let regionThreshold: Double = 30.0
    static let continentThreshold: Double = 60.0

    static func score(guessLongitude: Double, for clue: Clue) -> ScoreResult {
        let distance = longitudeDistance(from: guessLongitude, to: clue.answerLongitude)

        if distance <= countryThreshold {
            return ScoreResult(points: 3, accuracy: .country, distanceDegrees: distance)
        } else if distance <= regionThreshold {
            return ScoreResult(points: 2, accuracy: .region, distanceDegrees: distance)
        } else if distance <= continentThreshold {
            return ScoreResult(points: 1, accuracy: .continent, distanceDegrees: distance)
        } else {
            return ScoreResult(points: 0, accuracy: .wrong, distanceDegrees: distance)
        }
    }

    static func longitudeDistance(from a: Double, to b: Double) -> Double {
        var diff = abs(a - b)
        if diff > 180 {
            diff = 360 - diff
        }
        return diff
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd WhereOnEarth && swift test --filter GameEngineTests 2>&1 | tail -10`
Expected: All 5 tests PASS.

- [ ] **Step 5: Write ClueBank.swift**

```swift
import Foundation

@Observable
final class ClueBank {
    private(set) var allClues: [Clue] = []

    init() {
        loadClues()
    }

    func loadClues() {
        guard let url = Bundle.main.url(forResource: "clues", withExtension: "json") else {
            return
        }
        guard let data = try? Data(contentsOf: url) else {
            return
        }
        allClues = (try? JSONDecoder().decode([Clue].self, from: data)) ?? []
    }

    func cluesForSession(count: Int = 5) -> [Clue] {
        Array(allClues.shuffled().prefix(count))
    }
}
```

- [ ] **Step 6: Commit**

```bash
git add WhereOnEarth/WhereOnEarth/Services/GameEngine.swift WhereOnEarth/WhereOnEarth/Services/ClueBank.swift WhereOnEarth/WhereOnEarthTests/GameEngineTests.swift
git commit -m "feat: add GameEngine scoring logic and ClueBank with tests"
```

---

### Task 7: GameSession model

**Files:**
- Create: `WhereOnEarth/WhereOnEarth/Models/GameSession.swift`

- [ ] **Step 1: Write GameSession.swift**

```swift
import Foundation

@Observable
final class GameSession {
    let clues: [Clue]
    private(set) var currentIndex: Int = 0
    private(set) var results: [ScoreResult] = []
    private(set) var phase: Phase = .showingClue

    enum Phase {
        case showingClue
        case guessing
        case showingResult
        case finished
    }

    var currentClue: Clue? {
        guard currentIndex < clues.count else { return nil }
        return clues[currentIndex]
    }

    var totalScore: Int {
        results.reduce(0) { $0 + $1.points }
    }

    var maxPossibleScore: Int {
        clues.count * 3
    }

    var isFinished: Bool {
        phase == .finished
    }

    init(clues: [Clue]) {
        self.clues = clues
    }

    func startGuessing() {
        phase = .guessing
    }

    func submitGuess(longitude: Double) {
        guard let clue = currentClue else { return }
        let result = GameEngine.score(guessLongitude: longitude, for: clue)
        results.append(result)
        phase = .showingResult
    }

    func nextClue() {
        currentIndex += 1
        if currentIndex >= clues.count {
            phase = .finished
        } else {
            phase = .showingClue
        }
    }
}
```

- [ ] **Step 2: Build to verify**

Run: `cd WhereOnEarth && swift build 2>&1 | tail -5`
Expected: Build succeeds.

- [ ] **Step 3: Commit**

```bash
git add WhereOnEarth/WhereOnEarth/Models/GameSession.swift
git commit -m "feat: add GameSession model for 5-clue session lifecycle"
```

---

### Task 8: HapticsService

**Files:**
- Create: `WhereOnEarth/WhereOnEarth/Services/HapticsService.swift`

- [ ] **Step 1: Write HapticsService.swift**

```swift
import WatchKit

enum HapticsService {
    static func play(for accuracy: ScoreResult.Accuracy) {
        switch accuracy {
        case .country:
            WKInterfaceDevice.current().play(.success)
        case .region, .continent:
            WKInterfaceDevice.current().play(.click)
        case .wrong:
            WKInterfaceDevice.current().play(.failure)
        }
    }
}
```

- [ ] **Step 2: Build to verify**

Run: `cd WhereOnEarth && swift build 2>&1 | tail -5`
Expected: Build succeeds.

- [ ] **Step 3: Commit**

```bash
git add WhereOnEarth/WhereOnEarth/Services/HapticsService.swift
git commit -m "feat: add HapticsService for score feedback"
```

---

### Task 9: Game views — ClueView, MapStripView, ResultView

**Files:**
- Create: `WhereOnEarth/WhereOnEarth/Views/ClueView.swift`
- Create: `WhereOnEarth/WhereOnEarth/Views/MapStripView.swift`
- Create: `WhereOnEarth/WhereOnEarth/Views/ResultView.swift`

- [ ] **Step 1: Write ClueView.swift**

```swift
import SwiftUI

struct ClueView: View {
    let clue: Clue
    let onReady: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(clue.type.rawValue.uppercased())
                .font(.caption2)
                .fontWeight(.semibold)
                .tracking(2)
                .foregroundStyle(Color(hex: "D4A843").opacity(0.6))

            Text(clue.text)
                .font(.body)
                .foregroundStyle(Color(hex: "E8DCC8"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            Button("Guess") {
                onReady()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "D4A843"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "0C1425"))
    }
}
```

- [ ] **Step 2: Write MapStripView.swift**

```swift
import SwiftUI

struct MapStripView: View {
    let clue: Clue
    let onSubmit: (Double) -> Void

    @State private var longitude: Double = 0.0

    var body: some View {
        VStack(spacing: 0) {
            // Longitude display
            Text(longitudeLabel)
                .font(.caption)
                .fontDesign(.monospaced)
                .foregroundStyle(Color(hex: "D4A843"))
                .padding(.top, 4)

            // Map strip area with Canvas overlay
            ZStack {
                // Placeholder gradient for map strip (replaced by tiles later)
                LinearGradient(
                    colors: [
                        Color(hex: "0C1425"),
                        Color(hex: "14213D"),
                        Color(hex: "0C1425")
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 100)

                // Pin indicator
                Canvas { context, size in
                    let centerX = size.width / 2
                    let pinTop = size.height * 0.2
                    let pinBottom = size.height * 0.8

                    var path = Path()
                    path.move(to: CGPoint(x: centerX, y: pinTop))
                    path.addLine(to: CGPoint(x: centerX, y: pinBottom))
                    context.stroke(path, with: .color(Color(hex: "D4A843")), lineWidth: 2)

                    let dotSize: CGFloat = 8
                    let dotRect = CGRect(
                        x: centerX - dotSize / 2,
                        y: pinTop - dotSize / 2,
                        width: dotSize,
                        height: dotSize
                    )
                    context.fill(Circle().path(in: dotRect), with: .color(Color(hex: "D4A843")))
                }
                .frame(height: 100)
            }

            // Submit button
            Button("Lock In") {
                onSubmit(longitude)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "D4A843"))
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "0C1425"))
        .focusable()
        .digitalCrownRotation(
            $longitude,
            from: -180.0,
            through: 180.0,
            by: 1.0,
            sensitivity: .medium,
            isContinuous: true,
            isHapticFeedbackEnabled: true
        )
    }

    private var longitudeLabel: String {
        let absLng = abs(longitude)
        let dir = longitude >= 0 ? "E" : "W"
        return String(format: "%.0f\u{00B0}%@", absLng, dir)
    }
}
```

- [ ] **Step 3: Write ResultView.swift**

```swift
import SwiftUI

struct ResultView: View {
    let clue: Clue
    let result: ScoreResult
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(accuracyLabel)
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundStyle(accuracyColor)

            Text("+\(result.points)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(accuracyColor)

            Text(clue.answerCountry)
                .font(.caption)
                .foregroundStyle(Color(hex: "E8DCC8"))

            Text(String(format: "%.0f\u{00B0} off", result.distanceDegrees))
                .font(.caption2)
                .fontDesign(.monospaced)
                .foregroundStyle(Color(hex: "E8DCC8").opacity(0.6))

            Button("Next") {
                onNext()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "D4A843"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "0C1425"))
    }

    private var accuracyLabel: String {
        switch result.accuracy {
        case .country: return "RIGHT COUNTRY"
        case .region: return "RIGHT REGION"
        case .continent: return "RIGHT CONTINENT"
        case .wrong: return "WRONG"
        }
    }

    private var accuracyColor: Color {
        switch result.accuracy {
        case .country: return Color(hex: "D4A843")
        case .region: return Color(hex: "D4A843").opacity(0.8)
        case .continent: return Color(hex: "D4A843").opacity(0.6)
        case .wrong: return Color(hex: "C0392B")
        }
    }
}
```

- [ ] **Step 4: Build to verify**

Run: `cd WhereOnEarth && swift build 2>&1 | tail -5`
Expected: Build succeeds.

- [ ] **Step 5: Commit**

```bash
git add WhereOnEarth/WhereOnEarth/Views/ClueView.swift WhereOnEarth/WhereOnEarth/Views/MapStripView.swift WhereOnEarth/WhereOnEarth/Views/ResultView.swift
git commit -m "feat: add ClueView, MapStripView, and ResultView"
```

---

### Task 10: GameView — session controller wiring everything together

**Files:**
- Create: `WhereOnEarth/WhereOnEarth/Views/GameView.swift`
- Modify: `WhereOnEarth/WhereOnEarth/Views/MenuView.swift`

- [ ] **Step 1: Write GameView.swift**

```swift
import SwiftUI

struct GameView: View {
    @State private var session: GameSession

    init(clues: [Clue]) {
        _session = State(initialValue: GameSession(clues: clues))
    }

    var body: some View {
        Group {
            switch session.phase {
            case .showingClue:
                if let clue = session.currentClue {
                    ClueView(clue: clue) {
                        session.startGuessing()
                    }
                }
            case .guessing:
                if let clue = session.currentClue {
                    MapStripView(clue: clue) { guessLongitude in
                        session.submitGuess(longitude: guessLongitude)
                        if let lastResult = session.results.last {
                            HapticsService.play(for: lastResult.accuracy)
                        }
                    }
                }
            case .showingResult:
                if let clue = session.currentClue, let result = session.results.last {
                    ResultView(clue: clue, result: result) {
                        session.nextClue()
                    }
                }
            case .finished:
                VStack(spacing: 12) {
                    Text("SESSION\nCOMPLETE")
                        .font(.headline)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(hex: "D4A843"))

                    Text("\(session.totalScore)/\(session.maxPossibleScore)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "E8DCC8"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "0C1425"))
            }
        }
        .navigationBarBackButtonHidden(session.phase != .finished)
    }
}
```

- [ ] **Step 2: Update MenuView.swift to wire up GameView**

Replace the NavigationLink destination in MenuView:
```swift
import SwiftUI

struct MenuView: View {
    private let clueBank = ClueBank()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("WHERE ON\nEARTH")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(hex: "E8DCC8"))

                NavigationLink("Play") {
                    GameView(clues: clueBank.cluesForSession())
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "D4A843"))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "0C1425"))
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}

#Preview {
    MenuView()
}
```

- [ ] **Step 3: Build and run on simulator**

Run:
```bash
cd WhereOnEarth && xcodebuild \
  -scheme WhereOnEarth \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' \
  build 2>&1 | tail -10
```
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add WhereOnEarth/WhereOnEarth/Views/GameView.swift WhereOnEarth/WhereOnEarth/Views/MenuView.swift
git commit -m "feat: add GameView session controller, wire up full game loop"
```

---

### Task 11: UI test — full game flow

**Files:**
- Create: `WhereOnEarth/WhereOnEarthUITests/GameFlowUITests.swift`

- [ ] **Step 1: Write GameFlowUITests.swift**

```swift
import XCTest

final class GameFlowUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testFullGameSession() throws {
        // Tap Play on menu
        let playButton = app.buttons["Play"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 5))
        playButton.tap()

        // Play through 5 clues
        for _ in 0..<5 {
            // Clue screen — tap Guess
            let guessButton = app.buttons["Guess"]
            XCTAssertTrue(guessButton.waitForExistence(timeout: 5))
            guessButton.tap()

            // Map screen — tap Lock In (default longitude 0)
            let lockInButton = app.buttons["Lock In"]
            XCTAssertTrue(lockInButton.waitForExistence(timeout: 5))
            lockInButton.tap()

            // Result screen — tap Next
            let nextButton = app.buttons["Next"]
            XCTAssertTrue(nextButton.waitForExistence(timeout: 5))
            nextButton.tap()
        }

        // Session complete screen should show score
        let completeText = app.staticTexts["SESSION\nCOMPLETE"]
        XCTAssertTrue(completeText.waitForExistence(timeout: 5))
    }
}
```

- [ ] **Step 2: Run UI test on simulator**

Run:
```bash
cd WhereOnEarth && xcodebuild test \
  -scheme WhereOnEarth \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' \
  -only-testing:WhereOnEarthUITests/GameFlowUITests/testFullGameSession \
  2>&1 | tail -20
```
Expected: Test passes — the full 5-clue game loop completes on the simulator.

- [ ] **Step 3: Commit**

```bash
git add WhereOnEarth/WhereOnEarthUITests/GameFlowUITests.swift
git commit -m "test: add UI test for full 5-clue game flow"
```

---

### Task 12: Final integration — run all tests and verify

**Files:** None (verification only)

- [ ] **Step 1: Run all unit tests**

Run:
```bash
cd WhereOnEarth && xcodebuild test \
  -scheme WhereOnEarth \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' \
  -only-testing:WhereOnEarthTests \
  2>&1 | tail -20
```
Expected: All unit tests pass (Clue decoding, bundle loading, scoring).

- [ ] **Step 2: Run all UI tests**

Run:
```bash
cd WhereOnEarth && xcodebuild test \
  -scheme WhereOnEarth \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' \
  -only-testing:WhereOnEarthUITests \
  2>&1 | tail -20
```
Expected: UI test passes.

- [ ] **Step 3: Verify tile pipeline**

Run: `make tiles-L1`
Expected: Tiles generated in `pipeline/output/L1/tiles/`.

- [ ] **Step 4: Final commit with all uncommitted files**

```bash
git status
# If any uncommitted files remain, add and commit them
```
