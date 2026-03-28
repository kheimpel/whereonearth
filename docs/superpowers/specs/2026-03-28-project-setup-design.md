# Where on Earth — Project Setup Design

## Overview

Standalone Apple Watch game (watchOS 11+, Series 10+). GeoGuessr for your wrist — a clue appears, you spin the Digital Crown to guess the longitude, tap to lock in. Single game, not the 3-game suite from the concept doc.

## Repository Structure (Monorepo)

```
whereonearth/
├── concepts/                          # existing concept docs
├── data/                              # Natural Earth GeoJSON source files
│   ├── ne_110m_land.geojson
│   ├── ne_110m_coastline.geojson
│   ├── ne_50m_admin_0_countries.geojson
│   ├── ne_10m_rivers_lake_centerlines.geojson
│   └── mountains.geojson             # hand-drawn later
├── pipeline/                          # Python tile renderer
│   ├── requirements.txt              # geopandas, cartopy, matplotlib, pillow
│   ├── config.yaml                   # colors, dimensions, crop bounds, levels
│   ├── render_tiles.py               # main renderer script
│   └── README.md
├── WhereOnEarth/                      # Xcode standalone watch app
│   ├── WhereOnEarth.xcodeproj
│   ├── WhereOnEarth/                  # app source
│   │   ├── WhereOnEarthApp.swift
│   │   ├── Views/
│   │   │   ├── GameView.swift         # main game screen (session controller)
│   │   │   ├── ClueView.swift         # clue display
│   │   │   ├── MapStripView.swift     # tile strip + Canvas overlay
│   │   │   ├── ResultView.swift       # score reveal after each guess
│   │   │   └── MenuView.swift         # home / session start
│   │   ├── Models/
│   │   │   ├── Clue.swift             # clue data model
│   │   │   ├── GameSession.swift      # 5-clue session state
│   │   │   └── PlayerStats.swift      # scores, streaks, history
│   │   ├── Services/
│   │   │   ├── GameEngine.swift       # core game logic, scoring
│   │   │   ├── ClueBank.swift         # loads/filters bundled clues
│   │   │   ├── MapRenderer.swift      # Canvas overlay drawing (pin, accuracy line)
│   │   │   └── HapticsService.swift   # .success/.failure/.click
│   │   ├── Resources/
│   │   │   ├── clues.json             # bundled clue content
│   │   │   └── Assets.xcassets/       # app icon + tile images
│   │   └── Preview Content/
│   ├── WhereOnEarthTests/             # unit tests
│   └── WhereOnEarthUITests/           # UI tests on simulator
├── Makefile                           # `make tiles`, `make test`, `make clean`
├── .gitignore
└── README.md
```

## Watch App Architecture

### Target
- watchOS 11+, standalone (no iOS companion), SwiftUI only
- @Observable for state management
- NavigationStack for navigation

### Navigation Flow
MenuView -> tap Play -> GameView (manages 5-clue session)
GameView cycles: ClueView -> MapStripView (Crown input) -> ResultView -> next clue -> session summary

### Data Flow
- `GameEngine` (@Observable) is source of truth for session state
- `ClueBank` loads `clues.json` at launch, filters by difficulty based on rolling accuracy
- `PlayerStats` persists to UserDefaults (iCloud KVS wrapper added later)
- No network calls, everything local

### Map Strip Rendering
- `MapStripView` displays pre-rendered tile PNGs in a horizontally-offset container
- Digital Crown bound via `.digitalCrownRotation(isContinuous: true)` drives longitude offset
- SwiftUI Canvas overlay draws: pin marker, longitude indicator, gold accuracy line on reveal
- Tiles wrap circularly (index modulo N) for seamless scrolling

### Scoring
| Accuracy | Points | Haptic |
|----------|--------|--------|
| Right country | 3 | .success |
| Right region | 2 | .click |
| Right continent | 1 | .click |
| Wrong continent | 0 | .failure |

5 clues per session, max score 15.

### Testing
- Unit tests: GameEngine scoring, ClueBank filtering, PlayerStats persistence
- UI tests: XCUITest full game flow on watch simulator
- CI: `xcodebuild test` on GitHub Actions macos-14/15 runner

## Tile Pipeline

### Stack
- Python (geopandas, cartopy, matplotlib, pillow)
- mapshaper for polygon simplification
- ogr2ogr (GDAL) for clipping and reprojection

### Data Source
Natural Earth (public domain): coastlines, countries, borders, rivers at 110m/50m/10m resolutions. Mountain ranges hand-drawn later.

### Configuration (pipeline/config.yaml)
```yaml
projection: web_mercator
lat_bounds: [-72, 84]
tile_height: 800              # pixels (@2x)
tile_width: 400               # pixels (@2x)
strip_padding_deg: 20         # extra degrees past +/-180 for seam handling

styles:
  bg: "#0C1425"
  coastline: "#D4A843"
  coastline_width: 1.5
  land_fill: "#14213D"
  border: "#2A3A5C"
  river: "#1A3055"
  graticule: "rgba(212,168,67,0.08)"

levels:
  L1:
    layers: [land, coastline]
    source_scale: 110m
    simplify: 5%
  L2:
    layers: [land, coastline, countries, borders]
    source_scale: 50m
    simplify: 10%
  L3:
    layers: [land, coastline, countries, borders, rivers, mountains]
    source_scale: 10m
    simplify: 15%
    river_max_scalerank: 3
```

### Pipeline Steps
1. mapshaper simplifies source GeoJSON to target percentage per level
2. ogr2ogr clips to lat bounds, reprojects to Web Mercator
3. Python renders full strip as one large PNG per level
4. Pillow slices into tiles
5. Tiles copied to Xcode Assets.xcassets

### Output
- ~20-30 tiles per level, 3 levels, ~3MB total
- @2x only (Apple Watch standard)
- Tiles wrap at antimeridian via 20-degree padding in rendering

### Commands
- `make tiles` — full pipeline
- `make tiles-L1` — single level
- `make clean-tiles` — remove generated tiles

### Dependencies
- `brew install gdal`
- `pip install -r pipeline/requirements.txt`
- `npm install -g mapshaper`

## Starter Clues (5 clues for initial build)

These 5 clues cover different clue types and difficulty levels to exercise the full game loop:

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

## What's NOT in Scope
- iOS companion app
- Other two games (Bigger?, Fact or Fiction)
- Shared engagement systems (streaks, complications, spaced repetition)
- iCloud sync (UserDefaults first, KVS later)
- App Store submission
- Clue content creation (separate effort)
