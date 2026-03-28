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
