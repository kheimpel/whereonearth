# Visual System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewrite the map rendering to production quality — pure coastlines on dark ocean, physically correct lamp lighting, perfected brass armature with specular shimmer, all UI at the bottom edge.

**Architecture:** Canvas renders globe layers (ocean → land → coastlines → great circle → vignette), SwiftUI `BrassArmatureView` overlay handles the brass wire with real `.shadow()` and `.drawingGroup()`. All lighting derives from a single `lampPos` uniform driven by CoreMotion.

**Tech Stack:** Swift 6 / SwiftUI / watchOS 11+ / Canvas + TimelineView / CoreMotion

---

## File Structure

| File | Responsibility | Action |
|------|---------------|--------|
| `WhereOnEarth/WhereOnEarth/Models/Clue.swift` | Clue data model | Modify: add `answerLatitude` |
| `WhereOnEarth/WhereOnEarth/Resources/clues.json` | 5 starter clues | Modify: add `answer_latitude` |
| `WhereOnEarth/WhereOnEarth/Models/GeoData.swift` | GeoJSON loading | Modify: remove places |
| `WhereOnEarth/WhereOnEarth/Services/GameEngine.swift` | Scoring | Modify: use answerLatitude |
| `WhereOnEarth/WhereOnEarth/Views/MapStripView.swift` | Globe rendering | Rewrite |
| `WhereOnEarth/WhereOnEarth/Views/BrassArmatureView.swift` | Brass instrument | Rewrite |
| `WhereOnEarth/WhereOnEarthTests/GameEngineTests.swift` | Scoring tests | Modify: new Clue fields |
| `WhereOnEarth/WhereOnEarthTests/ClueTests.swift` | Clue tests | Modify: new JSON fields |
| `WhereOnEarth/WhereOnEarth.xcodeproj/project.pbxproj` | Build config | Modify: remove files |
| `WhereOnEarth/WhereOnEarth/Resources/places.json` | City data | Delete |
| `WhereOnEarth/WhereOnEarth/Resources/ne_110m_land.geojson` | Old land data | Delete |
| `WhereOnEarth/WhereOnEarth/Resources/ne_110m_coastline.geojson` | Old coastline data | Delete |

---

### Task 1: Clean up data model — add answerLatitude, remove places

**Files:**
- Modify: `WhereOnEarth/WhereOnEarth/Models/Clue.swift`
- Modify: `WhereOnEarth/WhereOnEarth/Resources/clues.json`
- Modify: `WhereOnEarth/WhereOnEarth/Models/GeoData.swift`
- Modify: `WhereOnEarth/WhereOnEarth/Services/GameEngine.swift`
- Modify: `WhereOnEarth/WhereOnEarthTests/GameEngineTests.swift`
- Modify: `WhereOnEarth/WhereOnEarthTests/ClueTests.swift`
- Delete: `WhereOnEarth/WhereOnEarth/Resources/places.json`
- Delete: `WhereOnEarth/WhereOnEarth/Resources/ne_110m_land.geojson`
- Delete: `WhereOnEarth/WhereOnEarth/Resources/ne_110m_coastline.geojson`
- Modify: `WhereOnEarth/WhereOnEarth.xcodeproj/project.pbxproj`

- [ ] **Step 1: Add `answerLatitude` to Clue.swift**

Add after `answerLongitude`:
```swift
let answerLatitude: Double
```

Add to CodingKeys:
```swift
case answerLatitude = "answer_latitude"
```

- [ ] **Step 2: Update clues.json with answer_latitude**

Add `"answer_latitude"` to each clue. Values:
- clue_001 (Japan): `"answer_latitude": 35.7`
- clue_002 (France): `"answer_latitude": 48.9`
- clue_003 (Austria): `"answer_latitude": 48.2`
- clue_004 (Sudan): `"answer_latitude": 15.6`
- clue_005 (Germany): `"answer_latitude": 51.2`

- [ ] **Step 3: Update GameEngine to use answerLatitude**

In `GameEngine.swift`, change the `score(guessLat:guessLng:for:)` function. Replace:
```swift
lat2: clue.scrollCenterLat
```
with:
```swift
lat2: clue.answerLatitude
```

And in the backward-compat `score(guessLongitude:for:)`:
```swift
return score(guessLat: clue.answerLatitude, guessLng: guessLongitude, for: clue)
```

- [ ] **Step 4: Remove GeoPlace and places loading from GeoData.swift**

Delete the `GeoPlace` struct and the `places` property. Delete the `loadPlaces()` function. The init becomes:
```swift
init() {
    landPolygons = Self.loadPolygons(resource: "ne_50m_land")
    coastlines = Self.loadLines(resource: "ne_50m_coastline")
}
```

- [ ] **Step 5: Delete unused resource files**

```bash
rm WhereOnEarth/WhereOnEarth/Resources/places.json
rm WhereOnEarth/WhereOnEarth/Resources/ne_110m_land.geojson
rm WhereOnEarth/WhereOnEarth/Resources/ne_110m_coastline.geojson
```

- [ ] **Step 6: Update pbxproj — remove deleted file references**

Read the current pbxproj. Remove these entries (PBXBuildFile, PBXFileReference, and group membership):
- `places.json`
- `ne_110m_land.geojson` (IDs: `FF00000100000000000000002A`, `FF00000100000000000000002B`)
- `ne_110m_coastline.geojson` (IDs: `FF00000100000000000000003A`, `FF00000100000000000000003B`)

Search for these IDs in the pbxproj and remove every line containing them.

- [ ] **Step 7: Update test files**

In `ClueTests.swift`, add to the test JSON:
```json
"answer_latitude": 35.7,
```

In `GameEngineTests.swift`, add `answerLatitude: 35.7` to all Clue constructors (the Japan test clue). For the Fiji antimeridian test, use `answerLatitude: -17.7`.

- [ ] **Step 8: Build and run tests**

```bash
cd /Users/konrad/Documents/06_Stuff/whereonearth/WhereOnEarth
xcodebuild test -project WhereOnEarth.xcodeproj -scheme WhereOnEarth \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' \
  -only-testing:WhereOnEarthTests 2>&1 | tail -15
```
Expected: All 7 tests pass.

- [ ] **Step 9: Commit**

```bash
git add -A && git commit -m "refactor: add answerLatitude, remove places and 110m data"
```

---

### Task 2: Rewrite MapStripView — production quality Canvas

**Files:**
- Rewrite: `WhereOnEarth/WhereOnEarth/Views/MapStripView.swift`

This is the biggest task. Replace the entire 411-line file with a clean rewrite. The new file should have these sections only:

**View body structure:**
```swift
struct MapStripView: View {
    let clue: Clue
    let onSubmit: ((Double, Double)) -> Void
    let geoData: GeoData
    let wristMotion: WristMotion

    @State private var scrollT: Double = 0.0
    @State private var isScrolling = false
    @State private var lastScrollT: Double = 0.0

    // -- CONSTANTS --
    /// Degrees of globe surface visible from center to edge
    private let visibleRange: Double = 18.0

    var body: some View {
        ZStack {
            // Map canvas
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let lampX = wristMotion.lampX
                let lampY = wristMotion.lampY
                Canvas { context, size in
                    let w = size.width
                    let h = size.height
                    let pos = greatCirclePosition(t: scrollT)
                    let brng = localBearing(at: scrollT)
                    let lamp = CGPoint(x: lampX * w, y: lampY * h)
                    let flicker = 1.0 + sin(time * 2.5) * 0.02

                    drawOcean(context: context, w: w, h: h, lamp: lamp, flicker: flicker)
                    drawLand(context: context, w: w, h: h,
                             centerLat: pos.lat, centerLng: pos.lng, bearing: brng)
                    drawCoastlines(context: context, w: w, h: h,
                                   centerLat: pos.lat, centerLng: pos.lng, bearing: brng,
                                   flicker: flicker, time: time)
                    drawGreatCirclePath(context: context, w: w, h: h,
                                        centerLat: pos.lat, centerLng: pos.lng, bearing: brng)
                    drawLampVignette(context: context, w: w, h: h, lamp: lamp, flicker: flicker)
                }
            }
            .focusable()
            .digitalCrownRotation($scrollT, from: -180.0, through: 180.0,
                                   by: 2.0, sensitivity: .high,
                                   isContinuous: true, isHapticFeedbackEnabled: true)
            .ignoresSafeArea()

            // Brass armature (floats above the map)
            BrassArmatureView(lampX: wristMotion.lampX, lampY: wristMotion.lampY)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            // Bottom UI — coordinates, distance, lock-in
            VStack(spacing: 2) {
                Spacer()
                Text(coordinateLabel)
                    .font(.system(size: 9, weight: .regular, design: .serif))
                    .foregroundStyle(Color(hex: "D4A843").opacity(0.3))
                Text(distanceLabel)
                    .font(.system(size: 9, weight: .light, design: .serif))
                    .italic()
                    .foregroundStyle(Color(hex: "D4A843").opacity(distanceOpacity))
                if !isScrolling {
                    Button(action: { onSubmit((currentPosition.lat, currentPosition.lng)) }) {
                        Text("LOCK IN")
                            .font(.system(size: 9, weight: .medium, design: .serif))
                            .tracking(2)
                            .foregroundStyle(Color(hex: "D4A843").opacity(0.4))
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity)
                }
            }
            .padding(.bottom, 4)
            .animation(.easeInOut(duration: 0.3), value: isScrolling)
        }
        .onChange(of: scrollT) {
            isScrolling = true
            lastScrollT = scrollT
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if lastScrollT == scrollT { isScrolling = false }
            }
        }
        .onAppear { wristMotion.start() }
        .onDisappear { wristMotion.stop() }
    }
}
```

Key differences from prototype:
- **No graticule** — `drawGraticule` removed entirely
- **No compass** — `drawCompass` removed entirely
- **No crosshair/pin** — replaced by BrassArmatureView
- **`drawLand` has no lamp/flicker params** — just fills polygons
- **Lock In is `.buttonStyle(.plain)`** — text only, no button chrome, 9px serif, 40% opacity
- **All UI at bottom** — coordinates + distance + lock-in clustered at very bottom edge
- **`coordinateLabel`** combines lat + lng in one computed property

**Drawing functions to include:**

1. `drawOcean(context:w:h:lamp:flicker:)` — radial gradient centered on lamp
2. `drawLand(context:w:h:centerLat:centerLng:bearing:)` — just fills polygons, no lamp params
3. `drawCoastlines(context:w:h:centerLat:centerLng:bearing:flicker:time:)` — double-stroke with shimmer
4. `drawGreatCirclePath(context:w:h:centerLat:centerLng:bearing:)` — dashed path
5. `drawLampVignette(context:w:h:lamp:flicker:)` — asymmetric darkening + bezel shadow

**Projection functions (unchanged from current, except localBearing step fix):**

6. `greatCirclePosition(t:)` — great circle nav, longitude normalized
7. `localBearing(at:)` — **change step from 0.5 to 2.0**
8. `project(_:_:centerLat:centerLng:bearing:w:h:)` — orthographic with rotation
9. `buildProjectedPath(points:centerLat:centerLng:bearing:w:h:close:)` — path builder

**Computed properties:**

10. `currentPosition` — greatCirclePosition(t: scrollT)
11. `coordinateLabel` — "45.6°S · 166.8°W"
12. `distanceLabel` — "342 km" or "19.1k km"
13. `distanceOpacity` — brighter when closer
14. `distanceToGoalKm()` — haversine using clue.answerLatitude and clue.answerLongitude

- [ ] **Step 1: Write the complete new MapStripView.swift**

Write the entire file following the structure above. Every drawing function must have a one-line comment explaining its physical justification.

- [ ] **Step 2: Build**

```bash
cd /Users/konrad/Documents/06_Stuff/whereonearth/WhereOnEarth
xcodebuild -project WhereOnEarth.xcodeproj -scheme WhereOnEarth \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build 2>&1 | tail -5
```
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add WhereOnEarth/WhereOnEarth/Views/MapStripView.swift
git commit -m "rewrite: MapStripView production quality — pure globe + lamp lighting"
```

---

### Task 3: Rewrite BrassArmatureView — perfected instrument

**Files:**
- Rewrite: `WhereOnEarth/WhereOnEarth/Views/BrassArmatureView.swift`

Replace the 138-line prototype with production quality. Key improvements:

1. **Fix specularIntensity math** — replace confusing `lampX * cx * 2` with clear `let lampNormDist = hypot(lampX - 0.5, lampY - 0.5)`
2. **Specular on wire must shimmer** — the bright band should slide smoothly with lampY
3. **Shadow must have correct parallax** — falls away from lamp
4. **Indicator must glow and breathe** — outer glow at 2Hz
5. **Named constants** — no magic numbers

The full rewrite:

```swift
import SwiftUI

struct BrassArmatureView: View {
    let lampX: Double
    let lampY: Double

    // Physical constants
    private let wireWidth: CGFloat = 1.0
    private let indicatorSize: CGFloat = 10
    private let glowSize: CGFloat = 20
    private let tickLength: CGFloat = 8
    private let tickHeight: CGFloat = 0.5
    private let shadowParallaxFactor: Double = 0.08
    private let indicatorShadowFactor: Double = 0.12  // 1.5× wire shadow
    private let specularBandWidth: Double = 0.08  // 8% of height

    // Gold color palette
    private let darkGold = Color(hex: "8C5914")
    private let midGold = Color(hex: "D9A621")
    private let brightGold = Color(hex: "FFD959")
    private let specularGold = Color(hex: "FFF2B3")
    private let glowGold = Color(hex: "D4A843")

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let flicker = 1.0 + sin(time * 2.5) * 0.02
            let glowBreath = 0.15 + 0.05 * sin(time * 2.0)

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w / 2
                let cy = h / 2
                let shadowDx = (cx - lampX * w) * shadowParallaxFactor
                let shadowDy = (cy - lampY * h) * shadowParallaxFactor
                let indShadowDx = (cx - lampX * w) * indicatorShadowFactor
                let indShadowDy = (cy - lampY * h) * indicatorShadowFactor

                ZStack {
                    // Vertical brass wire
                    Rectangle()
                        .fill(LinearGradient(
                            stops: wireGradientStops(flicker: flicker),
                            startPoint: .top, endPoint: .bottom
                        ))
                        .frame(width: wireWidth, height: h)
                        .position(x: cx, y: cy)
                        .shadow(color: .black.opacity(0.4), radius: 3,
                                x: shadowDx, y: shadowDy)

                    // Breathing outer glow
                    Circle()
                        .fill(glowGold.opacity(glowBreath * flicker))
                        .frame(width: glowSize, height: glowSize)
                        .position(x: cx, y: cy)

                    // Gold indicator body — gradient points toward lamp
                    Circle()
                        .fill(RadialGradient(
                            colors: [
                                brightGold.opacity(0.9 * flicker),
                                midGold.opacity(0.8 * flicker),
                                darkGold.opacity(0.7 * flicker),
                            ],
                            center: UnitPoint(x: lampX, y: lampY),
                            startRadius: 0, endRadius: 8
                        ))
                        .frame(width: indicatorSize, height: indicatorSize)
                        .position(x: cx, y: cy)
                        .shadow(color: .black.opacity(0.5), radius: 4,
                                x: indShadowDx, y: indShadowDy)

                    // Specular hot spot — gold tinted, shifts toward lamp
                    Circle()
                        .fill(specularGold.opacity(specularIntensity(flicker: flicker)))
                        .frame(width: 4, height: 4)
                        .position(x: cx + (lampX - 0.5) * 3,
                                  y: cy + (lampY - 0.5) * 3)

                    // Horizontal precision ticks
                    Rectangle()
                        .fill(darkGold.opacity(0.3 * flicker))
                        .frame(width: tickLength, height: tickHeight)
                        .position(x: cx - indicatorSize / 2 - tickLength / 2 - 1, y: cy)
                        .shadow(color: .black.opacity(0.2), radius: 2,
                                x: shadowDx, y: shadowDy)

                    Rectangle()
                        .fill(darkGold.opacity(0.3 * flicker))
                        .frame(width: tickLength, height: tickHeight)
                        .position(x: cx + indicatorSize / 2 + tickLength / 2 + 1, y: cy)
                        .shadow(color: .black.opacity(0.2), radius: 2,
                                x: shadowDx, y: shadowDy)
                }
                .drawingGroup()
            }
        }
    }

    /// Wire gradient: dark gold body with a bright specular band at lampY
    private func wireGradientStops(flicker: Double) -> [Gradient.Stop] {
        let dark = darkGold.opacity(0.5 * flicker)
        let mid = midGold.opacity(0.6 * flicker)
        let bright = brightGold.opacity(0.7 * flicker)
        let bandCenter = lampY
        let halfBand = specularBandWidth

        return [
            .init(color: dark, location: 0),
            .init(color: dark, location: max(0, bandCenter - halfBand * 2)),
            .init(color: mid, location: max(0, bandCenter - halfBand)),
            .init(color: bright, location: bandCenter),
            .init(color: mid, location: min(1, bandCenter + halfBand)),
            .init(color: dark, location: min(1, bandCenter + halfBand * 2)),
            .init(color: dark, location: 1),
        ]
    }

    /// Specular intensity: brighter when lamp is closer to center
    private func specularIntensity(flicker: Double) -> Double {
        let lampDist = hypot(lampX - 0.5, lampY - 0.5)
        return max(0, (1.0 - lampDist * 2.0) * 0.7 * flicker)
    }
}
```

- [ ] **Step 1: Write the complete new BrassArmatureView.swift**

Write the file exactly as above.

- [ ] **Step 2: Build**

```bash
cd /Users/konrad/Documents/06_Stuff/whereonearth/WhereOnEarth
xcodebuild -project WhereOnEarth.xcodeproj -scheme WhereOnEarth \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build 2>&1 | tail -5
```
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add WhereOnEarth/WhereOnEarth/Views/BrassArmatureView.swift
git commit -m "rewrite: BrassArmatureView — perfected specular, shadows, named constants"
```

---

### Task 4: Final integration — run all tests, install, verify

**Files:** None (verification only)

- [ ] **Step 1: Run all unit tests**

```bash
cd /Users/konrad/Documents/06_Stuff/whereonearth/WhereOnEarth
xcodebuild test -project WhereOnEarth.xcodeproj -scheme WhereOnEarth \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' \
  -only-testing:WhereOnEarthTests 2>&1 | tail -15
```
Expected: All 7 tests pass.

- [ ] **Step 2: Install and launch on simulator**

```bash
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/WhereOnEarth-*/Build/Products/Debug-watchsimulator -name "WhereOnEarth.app" -type d | head -1)
DEVICE_ID=$(xcrun simctl list devices booted -j | python3 -c "import json,sys; devs=json.load(sys.stdin)['devices']; [print(d['udid']) for r in devs.values() for d in r if d['state']=='Booted']" | head -1)
xcrun simctl terminate "$DEVICE_ID" com.whereonearth.app 2>/dev/null
xcrun simctl install "$DEVICE_ID" "$APP_PATH"
xcrun simctl launch "$DEVICE_ID" com.whereonearth.app
```

- [ ] **Step 3: Visual verification checklist**

Verify on simulator:
- [ ] Navy ocean with warm gold pool near center (lamp default)
- [ ] Gold coastlines, no grid, no labels, no compass
- [ ] Brass wire visible with shadow offset
- [ ] Specular band on wire at ~30% from top (lampY default = 0.3)
- [ ] Center indicator with gold gradient
- [ ] Coordinates + distance + LOCK IN all at bottom, tiny serif text
- [ ] LOCK IN is text only, no button chrome
- [ ] Crown scrolling works — great circle path stays horizontal
- [ ] Coastline shimmer when stationary
- [ ] Flicker barely perceptible

- [ ] **Step 4: Final commit**

```bash
cd /Users/konrad/Documents/06_Stuff/whereonearth
git add -A && git status
# Commit any remaining changes
git push
```
