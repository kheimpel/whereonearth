# Where on Earth — Design System

## Target Device

Apple Watch Series 10+ (46mm): 208 x 248 pt (416 x 496 px @2x)
Safe area: 196 x 172 pt usable after insets (35pt top/bottom, 1pt sides)

## Typography

All text uses **serif design** (maps to Apple's New York typeface via `.design(.serif)`).

### Type Scale

| Token | Size | Weight | Use |
|-------|------|--------|-----|
| `display` | 40pt | light | Score numbers (result screen, session complete) |
| `title` | 20pt | light | App title "WHERE ON EARTH" |
| `body` | 15pt | regular | Clue text, country names |
| `label` | 12pt | medium | Button labels (PLAY, GUESS, LOCK IN, NEXT) |
| `caption` | 11pt | regular | Coordinates, distance, metadata |

**Minimum size: 11pt.** Nothing smaller. Use opacity for visual hierarchy, not smaller type.

### Tracking (letter spacing)

| Context | Tracking |
|---------|----------|
| Uppercase labels (PLAY, LOCK IN, NEXT) | 2-3 |
| Body text | 0 (default) |
| Title | 1 |

## Color Palette

OLED-optimized. Black pixels = zero power draw.

| Token | Hex | Opacity | Use |
|-------|-----|---------|-----|
| `ocean` | #0C1425 | 1.0 | Background, all screens |
| `gold` | #D4A843 | varies | Primary accent — buttons, coastlines, armature, labels |
| `parchment` | #E8DCC8 | varies | Text — clue text, country names, coordinates |
| `darkGold` | #8C5914 | varies | Brass shadow tones |
| `midGold` | #D9A621 | varies | Brass body |
| `brightGold` | #FFD959 | varies | Brass highlight |
| `specularGold` | #FFF2B3 | varies | Specular hot spot (gold-tinted, never white) |
| `land` | #152240 | 0.9 | Land polygon fill |

### Opacity Scale

Used for visual hierarchy instead of smaller font sizes:

| Level | Opacity | Use |
|-------|---------|-----|
| Primary | 0.8-1.0 | Score, clue text, country name |
| Secondary | 0.5-0.7 | Button labels, active UI |
| Tertiary | 0.3-0.4 | Coordinates, distance, metadata |
| Subtle | 0.1-0.2 | Graticule, compass, dividers |

## Spacing

| Token | Value | Use |
|-------|-------|-----|
| `xs` | 2pt | Between tightly coupled text lines (coordinate + distance) |
| `sm` | 4pt | Between related elements |
| `md` | 8pt | Between sections, button padding |
| `lg` | 12pt | Major section breaks |
| `xl` | 16pt | Screen-edge bottom padding |
| `margin` | 10pt | Horizontal margin for text/buttons |

## Buttons

Two styles only:

### Primary (PLAY, GUESS)
- Full-width capsule
- Gold background at 0.8 opacity
- Ocean text, label size (12pt medium), tracking 3
- 20pt horizontal margin
- 10pt vertical padding
- Min tap target: 44pt height

### Ghost (LOCK IN, NEXT)
- Text only, `.buttonStyle(.plain)`
- Gold text at 0.5 opacity
- Caption size (11pt medium), tracking 2
- No background, no border

## Screen Layouts

### Map Screen (game play)
```
┌──────────────────────────┐
│                          │ ← Canvas fills entire screen
│       [map content]      │    .ignoresSafeArea()
│                          │
│     ● brass armature     │ ← SwiftUI overlay
│                          │
│                          │
│        LOCK IN           │ ← ghost button, hidden while scrolling
│   45.6°S · 166.8°W      │ ← caption, 11pt, parchment 0.35
└──────────────────────────┘
   ↑ 4pt bottom padding
```

### Clue Screen
```
┌──────────────────────────┐
│                          │
│        CULTURAL          │ ← caption, 11pt, gold 0.5, tracking 3
│                          │
│   Trains arrive within   │ ← body, 15pt, parchment
│   7 seconds of schedule  │    .minimumScaleFactor(0.7)
│   on average.            │
│                          │
│  ╔══════════════════╗    │ ← primary button
│  ║      GUESS       ║    │    20pt margin, 10pt vpadding
│  ╚══════════════════╝    │
│                          │ ← 16pt bottom padding
└──────────────────────────┘
```

### Result Screen
```
┌──────────────────────────┐
│                          │
│          4,832           │ ← display, 40pt light, gold
│        EXCELLENT         │ ← caption, 11pt medium, gold 0.8, tracking 3
│                          │
│       ──────────         │ ← gold divider, 40px wide, 0.15 opacity
│                          │
│     The answer was       │ ← caption, 11pt, parchment 0.4
│         Japan            │ ← body, 15pt medium, parchment
│       342 km off         │ ← caption, 11pt, parchment 0.35
│                          │
│          NEXT            │ ← ghost button
│                          │ ← 8pt bottom padding
└──────────────────────────┘
```

### Session Complete Screen
```
┌──────────────────────────┐
│                          │
│                          │
│         18,432           │ ← display, 40pt light, gold
│     out of 25,000        │ ← caption, 11pt, parchment 0.4
│                          │
│       ──────────         │ ← divider
│                          │
│    SESSION COMPLETE      │ ← caption, 11pt medium, parchment 0.35, tracking 3
│                          │
│                          │
└──────────────────────────┘
```

### Menu Screen
```
┌──────────────────────────┐
│                          │
│                          │
│        WHERE ON          │ ← title, 20pt light, parchment, tracking 1
│          EARTH           │
│                          │
│                          │
│  ╔══════════════════╗    │ ← primary button
│  ║       PLAY       ║    │
│  ╚══════════════════╝    │
│                          │ ← 16pt bottom padding
└──────────────────────────┘
```

## Animation

| Effect | Duration | Curve |
|--------|----------|-------|
| Score reveal | 0.6s | spring(bounce: 0.3) |
| Lock In show/hide | 0.3s | easeInOut |
| Coastline shimmer | 1.2Hz cycle | sin wave |
| Crosshair breathing | 2.0Hz cycle | sin wave |
| Vignette breathing | 0.8Hz cycle | sin wave |
| Lamp flicker | 0.4Hz cycle | sin wave, ±2% amplitude |

## Haptics

| Event | Haptic |
|-------|--------|
| Lock In (4500+ pts) | `.success` |
| Lock In (3500-4500) | `.directionUp` |
| Lock In (2000-3500) | `.click` |
| Lock In (<2000) | `.failure` |
| Crown rotation | Built-in (stride: 2°) |

## Accessibility

- All text ≥ 11pt
- `.minimumScaleFactor(0.6-0.7)` on all Text views
- Contrast: gold (#D4A843) on ocean (#0C1425) = 5.2:1 (passes AA)
- Parchment (#E8DCC8) on ocean (#0C1425) = 10.4:1 (passes AAA)
- No information conveyed by color alone (tiers have text labels)
- `.toolbar(.hidden)` hides system time during gameplay (full immersion)
