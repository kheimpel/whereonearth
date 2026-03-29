# Where on Earth — Visual System Design

## Vision

Museum instrument meets cinematic. The screen is a window into a dark room where an antique globe sits under a brass desk lamp at midnight. Physical realism of real brass and light, combined with the drama and atmosphere of a film about exploration.

## Physical Model

Three depth planes:

1. **Globe surface** (deepest) — ocean + land + coastlines. Rotated by Digital Crown along a great circle.
2. **Lamp light** (environmental) — single virtual desk lamp above-left. Its position shifts with wrist tilt via CoreMotion. All lighting derives from this one `lampPos` value.
3. **Brass armature** (closest) — vertical meridian wire + indicator dot. Hovers above the globe. Casts shadow. Catches specular highlights.

## Aesthetic Decisions

- **Surface style:** Dark Atlas — deep navy ocean, dark blue-grey land, gold coastlines
- **No graticule grid** — pure coastlines are the orientation
- **No city markers** — maximum cinematic, zero clutter
- **No compass labels** — the rotating view makes fixed N/E/S/W meaningless
- **Armature:** Single vertical brass wire + center indicator only

## Rendering Architecture

### Layer Stack (Canvas + SwiftUI overlay)

| Layer | Renderer | Description |
|-------|----------|-------------|
| 1. Ocean | Canvas | Radial gradient centered on lampPos: warm near lamp (#0F1A2E → warm gold tint), dark away (#080E1A) |
| 2. Land fills | Canvas | 50m Natural Earth polygons filled #152240 at 0.9 opacity |
| 3. Coastlines | Canvas | Double-stroke: wide dim glow (3px, 12% opacity) + narrow bright (0.8px, 70% opacity). Shimmer when stationary (opacity oscillates 0.6–0.75 at 1.2Hz) |
| 4. Great circle path | Canvas | Dashed line (0.5px, 6% opacity, dash [4,6]) showing scroll track |
| 5. Lamp vignette | Canvas | Asymmetric edge darkening centered on lampPos. Near-lamp edges: minimal darkening. Far-from-lamp edges: strong darkening (55% black). Fixed bezel shadow (12% at very edges). All modulated by flicker. |
| 6. Brass armature | SwiftUI `BrassArmatureView` | Separate view layer with `.drawingGroup()` for Metal compositing |

### Lighting Uniform: `lampPos`

```
lampX = 0.5 + sin(roll) × 0.25    // range [0.25, 0.75]
lampY = 0.3 + sin(pitch) × 0.2   // range [0.1, 0.5]
```

Computed from CoreMotion at 20Hz. Default (wrist flat): (0.5, 0.3).

All visual effects derive from this single value:
- Ocean warm pool position and intensity
- Vignette shadow direction
- Brass wire specular highlight position
- Brass indicator specular hot spot
- Shadow offset direction (parallax)
- Flicker: `1.0 + sin(time × 2.5) × 0.02` (±2% at 0.4Hz)

### Brass Armature (SwiftUI Overlay)

**Vertical wire:**
- Width: 1.0px (ultra thin)
- Color: `LinearGradient` with 7 stops, dark gold (#8C5914) body
- Specular band: bright gold (#FFD959) sliding to `lampY` position, width 8% of height
- Specular core: near-white gold (#FFF2B3) at center of band
- When wrist tilts → highlight slides up/down the wire

**Center indicator:**
- Size: 10px circle
- Fill: `RadialGradient` with center offset toward lampPos
  - Core: bright gold #FFD959
  - Body: mid gold #D9A621
  - Edge: dark gold #8C5914
- Specular hot spot: 4px gold-tinted circle (#FFF2B3), shifts toward lamp
- Outer glow: 20px breathing circle (#D4A843, 15±5% opacity at 2Hz)

**Shadow (depth separation):**
- `.shadow(color: .black.opacity(0.5), radius: 4, x: shadowDx, y: shadowDy)`
- `shadowDx = (cx - lampX × w) × 0.08`
- `shadowDy = (cy - lampY × h) × 0.08`
- Shadow falls AWAY from lamp (correct physics)
- Larger shadow on indicator (1.5× offset) for more depth
- Horizontal tick marks: 8px each side, 0.5px height, with own shadows

**Compositing:** `.drawingGroup()` wrapping all elements for Metal-backed rendering.

## Globe Projection

### Great Circle Navigation

Each clue defines a great circle via `scrollCenterLat`, `scrollCenterLng`, `scrollBearing`.

Position along the path:
```
φ(t) = asin(sin(φ₀)·cos(t) + cos(φ₀)·sin(t)·cos(bearing))
λ(t) = λ₀ + atan2(sin(bearing)·sin(t)·cos(φ₀), cos(t) - sin(φ₀)·sin(φ(t)))
```

Longitude normalized to [-180, 180] after computation.

### Orthographic Projection with Rotation

```
xOrtho = cos(φ) · sin(λ - λ₀)
yOrtho = cos(φ₁)·sin(φ) - sin(φ₁)·cos(φ)·cos(λ - λ₀)
visible = sin(φ₁)·sin(φ) + cos(φ₁)·cos(φ)·cos(λ - λ₀) > 0

rotation = localBearing - π/2
xRot = xOrtho·cos(rotation) - yOrtho·sin(rotation)
yRot = xOrtho·sin(rotation) + yOrtho·cos(rotation)

scale = min(w, h) / 2 / sin(visibleRange × π/180)
screenX = w/2 + xRot × scale
screenY = h/2 - yRot × scale
```

`visibleRange = 18°` — shows ±18° of globe surface around center.

### Local Bearing Computation

Computed numerically via finite difference with step size 2.0° (increased from 0.5° to reduce noise near great circle apex):

```
localBearing = atan2(sin(Δλ)·cos(φ₂), cos(φ₁)·sin(φ₂) - sin(φ₁)·cos(φ₂)·cos(Δλ))
```

Where (φ₁,λ₁) and (φ₂,λ₂) are positions at t±2°.

## UI Overlay Layout

All UI overlays sit at the **bottom edge** of the screen, below the map. The map fills the entire screen unobstructed.

**Bottom stack (bottom-up):**
1. "LOCK IN" — tiny text-only link, no button chrome. Serif, 9px, gold at 40% opacity. Appears only when stationary. Tapping anywhere on screen could also trigger lock-in.
2. Distance — italic serif, 9px, gold at variable opacity (brighter when closer)
3. Coordinates — "45.6°S · 166.8°W", serif 9px, gold at 30% opacity

All three lines clustered tight at the very bottom edge. Total height: ~30px. The map gets the remaining ~210px of the 242px screen.

**Removed from top:** Coordinates no longer at the top of the screen. Nothing competes with the map.

## Bug Fixes Included

1. **Add `answerLatitude` to Clue model** — currently scoring mixes scrollCenterLat with answerLongitude for the haversine distance. Each clue needs both answer coordinates.
2. **Remove unused `lamp`/`flicker` params from `drawLand()`** — dead parameters.
3. **Increase localBearing step** from 0.5° to 2.0° — reduces noise at great circle turning points.
4. **Remove places.json** loading and `GeoPlace` struct — no city markers.
5. **Remove 110m geo data** — superseded by 50m.
6. **Fix `specularIntensity()` in BrassArmatureView** — confusing geometry math, rewrite clearly.

## Files Changed

| File | Action |
|------|--------|
| `MapStripView.swift` | Rewrite — clean layers, remove graticule/compass/crosshair, fix localBearing |
| `BrassArmatureView.swift` | Rewrite — perfect specular, shadow, shimmer |
| `Clue.swift` | Add `answerLatitude` field |
| `clues.json` | Add `answer_latitude` to all 5 clues |
| `GeoData.swift` | Remove places loading |
| `GameEngine.swift` | Use `answerLatitude` in haversine |
| `GameEngineTests.swift` | Update Clue constructors |
| `ClueTests.swift` | Update test JSON |
| `project.pbxproj` | Remove places.json, remove 110m files |
| `Resources/places.json` | Delete |
| `Resources/ne_110m_*.geojson` | Delete |

## Verification

1. Build succeeds: `xcodebuild -scheme WhereOnEarth -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build`
2. All unit tests pass
3. Visual on simulator: navy ocean, gold coastlines, no grid, no labels, just pure globe
4. Brass wire visible with shadow offset, specular at default lampPos (0.5, 0.3)
5. Scrolling smooth — great circle path stays horizontal, no sharp turns
6. Coastline shimmer animates when stationary
7. Lamp flicker barely perceptible (2%)
8. Vignette follows lampPos (on real device — tilting wrist shifts the lit area)
