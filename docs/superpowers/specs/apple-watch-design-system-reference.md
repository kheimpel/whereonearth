# Apple Watch Design System Reference (2025-2026)

Comprehensive reference for watchOS app design based on Apple's Human Interface Guidelines, WWDC sessions, and established best practices.

---

## 1. Screen Dimensions

All Apple Watch displays use a **2x scale factor** (Retina). Points = pixels / 2.

### Current Models (2025)

| Model | Case | Pixels (W x H) | Points (W x H) | PPI | Display |
|-------|------|-----------------|-----------------|-----|---------|
| Series 11 | 42mm | 374 x 446 | 187 x 223 | ~326 | LTPO3 OLED, 2000 nits |
| Series 11 | 46mm | 416 x 496 | 208 x 248 | ~330 | LTPO3 OLED, 2000 nits |
| Ultra 3 | 49mm | 514 x 422 | 257 x 211 | ~326 | LTPO3 OLED, 3000 nits |

Note: Series 10 and Series 11 share the same display dimensions (42mm/46mm). The Ultra 3 increased resolution from Ultra 2's 502x410 to 514x422.

### Historical Reference (for backward compatibility)

| Model | Case | Pixels (W x H) | Points (W x H) |
|-------|------|-----------------|-----------------|
| Series 7-9 | 41mm | 352 x 430 | 176 x 215 |
| Series 7-9 | 45mm | 396 x 484 | 198 x 242 |
| Series 4-6 | 40mm | 324 x 394 | 162 x 197 |
| Series 4-6 | 44mm | 368 x 448 | 184 x 224 |
| Ultra 1-2 | 49mm | 410 x 502 | 205 x 251 |

### Physical Dimensions

| Model | Case | Physical Size |
|-------|------|---------------|
| Series 11 | 42mm | 42 x 36 x 9.7 mm |
| Series 11 | 46mm | 46 x 39 x 9.7 mm |
| Ultra 3 | 49mm | 49 x 44 x 12 mm |

---

## 2. Safe Area Insets

The rounded display corners and navigation bar create safe area insets that reduce usable content area. These values are in **points**.

### Safe Area Insets by Model

| Case Size | Top | Left | Bottom | Right |
|-----------|-----|------|--------|-------|
| 38mm | 19 | 0 | 0 | 0 |
| 40mm | 28 | 0.5 | 28 | 0.5 |
| 41mm | 34 | 1 | 34 | 1 |
| 42mm (old) | 21 | 0 | 0 | 0 |
| 44mm | 31 | 0.5 | 31 | 0.5 |
| 45mm | 35 | 1 | 35 | 1 |

Note: Series 10/11 (42mm, 46mm) share the same display geometry as Series 7-9 (41mm, 45mm) respectively -- the case got larger but the display panel is the same. Use the 41mm/45mm insets for the new 42mm/46mm sizes.

### Usable Content Area (after safe area)

| Case Size | Width (pts) | Height (pts) |
|-----------|-------------|--------------|
| 41mm / 42mm | 174 | 147 |
| 45mm / 46mm | 196 | 172 |

### TabView Additional Insets

When using TabView, an additional bottom safe area is applied:
- 41mm / 42mm: +7 points bottom
- 45mm / 46mm: +8 points bottom

### Ignoring Safe Areas

Use `.ignoresSafeArea()` to draw content edge-to-edge (e.g., background images, maps). Use `GeometryReader` to read exact safe area values at runtime.

---

## 3. Layout and Spacing

### General Principles

- **Edge-to-edge content**: watchOS encourages extending visual content to the screen edges. Background colors, images, and maps should fill the display.
- **Minimal padding**: Minimize padding between elements to maximize usable space.
- **Limit side-by-side controls**: No more than 2-3 controls placed horizontally.
- **Vertical scrolling**: The primary layout direction. Long content scrolls vertically via Digital Crown or finger swipe.
- **Content density**: Keep views focused -- one primary task or piece of information per screen.

### Recommended Spacing Values

| Element | Spacing (pts) |
|---------|---------------|
| Horizontal margins (text to edge) | 8-10 |
| Vertical spacing between elements | 4-8 |
| Section spacing | 12-16 |
| Button internal padding | 8-12 horizontal, 6-8 vertical |
| List row height | 44 minimum |

### Layout Width Guidance

For the 46mm (208pt wide), after safe area (196pt usable):
- Full-width text: ~176pt (with 10pt margins each side)
- Two-column layout: 2 x ~88pt columns
- Three-column layout: only for icons/small controls

For the 42mm (187pt wide), after safe area (174pt usable):
- Full-width text: ~154pt (with 10pt margins each side)
- Two-column layout: 2 x ~77pt columns

### How Much Content Fits

On the 46mm (172pt usable height):
- **Body text (17pt)**: approximately 7-8 lines visible
- **Caption text (12pt)**: approximately 10-11 lines visible
- **List rows (44pt each)**: 3-4 rows visible without scrolling
- **Large title + 2 buttons**: comfortable fit

On the 42mm (147pt usable height):
- About 15-20% less than the 46mm

---

## 4. Typography

### System Fonts

| Font | Usage | Design |
|------|-------|--------|
| **SF Compact** | Primary system font for watchOS | Flatter curves than SF Pro, wider letter spacing for small-screen legibility |
| **SF Compact Rounded** | Rounded variant | Friendlier appearance, used in fitness/activity contexts |
| **New York** | Apple's serif typeface | Available since 2019, good for editorial/literary content |

SF Compact is optimized for Apple Watch -- it has more space between characters and flatter curves than SF Pro (the iOS system font), making it more legible at small sizes on the watch display.

### Font Sizes and Styles

| Style | Size (pts) | Weight | Usage |
|-------|-----------|--------|-------|
| `.largeTitle` | 34 | Bold | Hero numbers, splash screens |
| `.title` | 28 | Bold | Screen titles (used by NavigationStack) |
| `.title2` | 22 | Bold | Section headers |
| `.title3` | 20 | Semibold | Subsection headers |
| `.headline` | 17 | Semibold | Emphasized body text |
| `.body` | 17 | Regular | Primary content |
| `.callout` | 16 | Regular | Secondary content |
| `.subheadline` | 15 | Regular | Supporting text |
| `.footnote` | 13 | Regular | Tertiary text |
| `.caption` | 12 | Regular | Labels, timestamps |
| `.caption2` | 11 | Regular | Fine print, widget text |

### Minimum Readable Size

- **Absolute minimum**: 11pt (`.caption2`) -- use sparingly, only for non-critical ancillary text
- **Comfortable minimum**: 13pt (`.footnote`) -- smallest size for text users need to read
- **Recommended minimum for primary content**: 17pt (`.body`)
- Below 11pt, text becomes illegible on the watch display regardless of font weight

### Dynamic Type

watchOS supports Dynamic Type with 7 size categories. Users can adjust text size in Settings > Display & Brightness > Text Size.

- Apps using standard text styles (`.body`, `.caption`, etc.) automatically respond to Dynamic Type
- Custom font sizes should use `UIFont.preferredFont(forTextStyle:)` or SwiftUI's built-in text styles
- Test your app at the largest and smallest Dynamic Type settings
- **Not all contexts respond**: complications and some third-party widget text do not scale with Dynamic Type

### Serif Font Guidance (New York)

New York is Apple's serif typeface, suitable for:
- Editorial or literary contexts
- Elegant, refined aesthetics
- Reading-heavy content where a traditional "book" feel is desired
- Variable optical sizes: adjusts stroke contrast and spacing based on point size

Available weights: Regular, Medium, Semibold, Bold, Heavy, Black (plus italics).

For the WhereOnEarth project's "museum instrument" aesthetic, New York (serif) is an excellent choice for clue text, coordinates, and labels. At 9pt (as specified in the visual spec), New York is below the recommended minimum -- consider using it at 11pt minimum and relying on opacity/color for visual hierarchy rather than going smaller.

---

## 5. Touch Targets

### Minimum Tap Target Sizes

| Element | Minimum Size (pts) |
|---------|-------------------|
| Buttons (full-width) | 44pt height |
| Buttons (compact/icon) | 38 x 38 |
| List rows | 44pt height |
| Interactive elements (general) | 44 x 44 recommended |
| Absolute minimum | 38 x 38 (with transparent padding if needed) |

### Button Sizing

- **Full-width buttons**: Extend to the safe area margins, minimum 44pt tall
- **Rounded rectangle buttons**: Default SwiftUI button style, automatically sized appropriately
- **Icon-only buttons**: Add transparent padding around the icon to reach 38-44pt tappable area
- Apple recommends adding transparent hit-testing padding if your visual element is smaller than the minimum target size

### Practical Guidance

- On a 46mm watch, you can comfortably fit 3 full-width buttons in the visible area
- Side-by-side buttons: limit to 2 maximum
- For the "LOCK IN" button in WhereOnEarth: even though the visual text is small, the tappable area should be at least 44pt tall -- use `.contentShape(Rectangle())` with generous padding

---

## 6. Colors

### Dark Mode Only

watchOS is **always dark**. There is no light mode. The system background is pure black (#000000).

### OLED Considerations

- **Pure black is free**: Black pixels on OLED are fully off, consuming zero power. Use true black (#000000) for backgrounds.
- **Bright colors cost battery**: Large areas of bright color increase power draw. Use bright accents sparingly.
- **Avoid pure white backgrounds**: Large white areas are harsh on OLED and drain battery significantly.
- **Burn-in prevention**: The Always-On Display shifts content slightly. Avoid static bright elements in the same position for extended periods.

### Contrast Ratios

| Context | Minimum Ratio | Recommended |
|---------|--------------|-------------|
| Normal text on background | 4.5:1 | 7:1 |
| Large text (18pt+ or 14pt+ bold) | 3:1 | 4.5:1 |
| UI components / icons | 3:1 | 4.5:1 |

### Color Usage Best Practices

- **Key color**: Each app defines a "key color" that appears in the status bar title and notification app name
- **High-contrast text**: Use white or near-white text on the black background
- **Accent colors**: Bright, saturated colors work well against black -- they pop without competing
- **Semantic colors**: Use system colors (`.red`, `.green`, `.blue`, `.orange`) which are pre-tuned for dark backgrounds
- **Opacity for hierarchy**: Use white text at different opacities (100%, 60%, 30%) rather than gray values -- this ensures consistency across different background colors
- **Tinted backgrounds**: Subtle dark-tinted backgrounds (e.g., dark navy, dark green) can separate sections while remaining OLED-efficient

### Color Palette Guidance for WhereOnEarth

The existing visual spec's approach (gold on dark navy/black) is ideal for watchOS:
- Pure black and near-black backgrounds minimize power draw
- Gold accent colors provide excellent contrast against dark backgrounds
- The 30-70% opacity range for secondary/tertiary text aligns with watchOS conventions

---

## 7. Navigation Patterns

### Three Core Patterns (watchOS 10+)

**1. NavigationSplitView** (Source-Detail)
- Best for: apps with a list of items and detail views
- Shows a source list with a detail pane
- Example: Mail, Messages

**2. TabView with Vertical Paging**
- Best for: apps with 2-5 distinct, equally important sections
- Pages are swiped vertically (Digital Crown or gesture)
- Each tab is a full-screen view
- Example: Activity, Weather
- New in watchOS 10: vertical page style replaced horizontal swiping
- TabView automatically detects scrolling content within a tab and accommodates it

**3. NavigationStack** (Hierarchical)
- Best for: apps with deep content hierarchies
- Push/pop navigation with back button
- First view shows a large title; subviews show a back button instead
- Example: Settings

### Navigation Best Practices

- **Choose one primary pattern** -- don't mix NavigationSplitView and TabView at the top level
- **Keep hierarchy shallow** -- ideally no more than 2-3 levels deep
- **Use large titles** on the root view of a NavigationStack (automatic in watchOS 10+)
- **Full-screen presentations**: use `.sheet()` or `.fullScreenCover()` for modal flows
- **Swipe from left edge**: system gesture to go back -- don't override this
- **Toolbar items**: bottom toolbar for primary actions, top for status

### Smart Stack Integration

The Smart Stack (Digital Crown scroll from watch face) is a key entry point:
- Widgets in the Smart Stack can deep-link into your app
- Design your app's first screen to provide immediate value (no loading screens)
- Use `WidgetURL` to handle deep links from widgets/complications

---

## 8. Digital Crown

### Core Interaction Patterns

- **Scrolling**: Default behavior -- scrolls lists, pages, and scrollable content
- **Value selection**: Picker controls respond to Crown rotation for precise value selection
- **Custom input**: Use `digitalCrownRotation()` modifier for custom Crown-driven interactions (e.g., rotating a globe, adjusting a value)

### Best Practices

- **1:1 tracking**: Crown rotation should map directly to on-screen movement. Users expect immediate, proportional response.
- **Haptic detents**: System provides linear haptic taps as the Crown rotates. These can be:
  - Enabled (default) for discrete values
  - Disabled if the animation doesn't match linear detents (e.g., continuous scrolling)
  - Custom stride: specify how much rotation moves between haptic clicks
- **Sensitivity**: Adjust how much rotation is needed to move between elements -- fine control for precise values, coarse for fast scrolling
- **Don't fight the system**: If your view has a ScrollView, the Crown will control scrolling. Don't add competing Crown behaviors.
- **Crown idle**: Detect when the user stops rotating for "settle" animations

### Digital Crown in SwiftUI

Key modifier: `.digitalCrownRotation($value, from:, through:, by:, sensitivity:, isContinuous:, isHapticFeedbackEnabled:)`

Parameters:
- `from` / `through`: value range
- `by`: stride (step size between detents)
- `sensitivity`: `.low`, `.medium`, `.high` -- how much physical rotation per unit
- `isContinuous`: whether value wraps around
- `isHapticFeedbackEnabled`: whether Crown clicks at each step

### For WhereOnEarth

The globe rotation via Digital Crown is a textbook use case. Recommendations:
- Use continuous rotation (no start/end boundaries -- the globe wraps)
- Enable haptic feedback with a stride that matches meaningful geographic intervals
- Sensitivity should be medium -- fast enough to traverse the globe without being twitchy

---

## 9. Haptics

### Available Haptic Types (WKHapticType)

| Type | Feel | Usage |
|------|------|-------|
| `.click` | Light tick | Selection changes, detent feedback |
| `.success` | Rising double-tap | Task completed successfully |
| `.failure` | Harsh triple-tap | Error, incorrect action |
| `.retry` | Brief buzz | Try again |
| `.start` | Rising ramp | Activity beginning (timer, workout) |
| `.stop` | Falling ramp | Activity ending |
| `.directionUp` | Upward sweep | Navigating up, increasing value |
| `.directionDown` | Downward sweep | Navigating down, decreasing value |
| `.notification` | Distinct pulse | Alert, incoming notification |

### Playing Haptics

```
// WatchKit (legacy)
WKInterfaceDevice.current().play(.success)

// SwiftUI (modern)
.sensoryFeedback(.success, trigger: someValue)
```

### Best Practices

- **Exercise restraint**: Overuse of haptics diminishes their meaning. Reserve them for important events.
- **No overlapping**: The Taptic Engine cannot overlap haptics. Rapid sequential plays will be dropped.
- **Match semantics**: Use `.success` for correct answers, `.failure` for wrong ones. Users learn these patterns across all their apps.
- **Don't replace visual feedback**: Haptics supplement visual/audio feedback -- never the sole indicator.
- **Background limitation**: Haptics require the app to be in the foreground.
- **Custom patterns**: watchOS does not support custom haptic patterns (unlike iOS CoreHaptics). You are limited to the predefined `WKHapticType` set.

### For WhereOnEarth (from existing spec)

The game concept already specifies:
- `.success` for correct country guess
- `.click` for correct region/continent
- `.failure` for wrong continent
- This is the correct idiomatic usage

---

## 10. Animation

### Recommended Durations

| Animation Type | Duration | Notes |
|----------------|----------|-------|
| Quick transitions | 0.15-0.2s | Button state changes, highlights |
| Standard transitions | 0.25-0.35s | View transitions, slides |
| Emphasis animations | 0.3-0.5s | Drawing attention to something |
| Breathing/pulsing | 1.5-3.0s cycle | Ambient animations (idle states) |

### Recommended Curves

| Curve | Use Case |
|-------|----------|
| `.spring(response: 0.3, dampingFraction: 0.7)` | Default recommendation -- feels natural, no overshoot |
| `.spring(response: 0.5, dampingFraction: 0.8)` | Gentler spring for larger movements |
| `.easeInOut(duration: 0.25)` | Standard UI transitions |
| `.easeOut(duration: 0.2)` | Appearing elements (fast start, slow finish) |
| `.snappy` | Quick interactive responses |
| `.smooth` | Gentle, non-jarring transitions |

### Apple's WWDC 2023 Spring Guidance

Springs are the preferred animation type:
- They maintain velocity continuity (if the user interrupts an animation, a new spring picks up the current velocity)
- They feel more natural than cubic bezier curves
- Use `response` (speed) and `dampingFraction` (bounciness) to tune:
  - `dampingFraction: 1.0` = critically damped (no bounce)
  - `dampingFraction: 0.7` = slight bounce
  - `dampingFraction: 0.5` = noticeable bounce

### watchOS-Specific Considerations

- **Battery**: Continuous animations drain battery. Use sparingly and stop when the screen dims (Always-On Display should be static).
- **Always-On Display**: Animations are paused in the always-on state. Design a static "reduced" version of your UI.
- **Frame rate**: Apple Watch Series 7+ supports up to 60fps. Older models may be 30fps. Keep animations simple enough to maintain smooth frame rates.
- **`.drawingGroup()`**: Use this modifier when compositing complex layered animations -- it forces Metal-backed rendering for better performance.
- **Reduce Motion**: Respect the `accessibilityReduceMotion` environment value. Provide non-animated alternatives.

### For WhereOnEarth

The visual spec's animation approach is well-calibrated:
- Coastline shimmer: 1.2Hz oscillation (0.6-0.75 opacity) -- within the "breathing" range
- Lamp flicker: 0.4Hz at 2% -- subtle ambient animation
- Brass indicator glow: 2Hz breathing -- subtle enough to not distract
- All use `.drawingGroup()` for Metal compositing -- correct for this complexity level

---

## 11. Complications and Glanceability

### Design Principles

- **5-second rule**: Users glance at their watch for under 5 seconds. All information must be instantly parseable.
- **20-character limit**: Text exceeding 20 characters in complications reduces engagement by 38%.
- **One number or status**: Each complication should convey exactly one piece of information.
- **Limit to 3 elements**: Per complication region, show no more than 3 data points.

### Complication Families

| Family | Shape | Content Capacity |
|--------|-------|-----------------|
| `.accessoryCircular` | Circle | 1 number or icon, optionally with gauge |
| `.accessoryRectangular` | Rectangle | 2-3 lines of text or small chart |
| `.accessoryCorner` | Curved (watchOS only) | Short label + gauge arc |
| `.accessoryInline` | Single line | Under 20 characters of text |

### Smart Stack Widgets (watchOS 10+)

- Scrollable stack of widgets accessed by Crown rotation from the watch face
- Can be larger than complications
- Use `TimelineEntryRelevance` scores to surface your widget at contextually appropriate times
- Relevance scoring: 0 (default) to 100 (urgent/active)

### Rendering Modes

Widgets must support three rendering modes:
1. **Full color** -- Smart Stack, some watch faces
2. **Accented** -- two-tone, mark key elements with `.widgetAccentable()`
3. **Vibrant** -- desaturated, system applies vibrancy effect

---

## 12. Design Patterns from Top Watch Apps

### Activity (Apple)
- Three-ring gauge as hero element -- instantly recognizable at a glance
- TabView with vertical paging between summary, sharing, and trends
- Large numbers with minimal labels
- System green/red/blue ring colors against pure black

### Weather (Apple)
- Current temperature as the hero number (large title)
- Horizontal scrolling hourly forecast
- Vertical list for 10-day forecast
- Color-coded temperature bars
- Condition icons are large and unambiguous

### Nike Run Club / Strava
- Large, bold metrics (pace, distance, time) during workout
- High-contrast white/green on black
- Minimal chrome during activity -- the data IS the interface
- Crown controls pause/resume, not navigation
- Post-workout summary uses vertical scroll through stats

### Workout (Apple)
- Full-screen data view during activity
- 3-4 metrics visible simultaneously (HR, pace, distance, time)
- Color coding for heart rate zones
- Swipe between data screens (vertical pages)
- Water lock mode locks the touchscreen

### Common Patterns Across Top Apps

1. **Hero metric**: One large number dominates the screen
2. **Supporting data below**: Smaller metrics underneath in a stack
3. **Minimal navigation**: Most interactions are on a single screen
4. **High contrast**: White or bright accent on pure black
5. **Haptic confirmation**: Success/failure haptics for user actions
6. **Crown for value input**: Rotation for continuous value selection
7. **No onboarding walls**: Apps launch directly to content

---

## 13. watchOS 26 / Liquid Glass (2025)

With watchOS 26, Apple introduced **Liquid Glass** -- a major visual redesign emphasizing translucency, depth, and fluid responsiveness:

- Translucent, glassy material effects across system UI
- New visual language for navigation bars, toolbars, and controls
- Apps should ensure text remains legible against dynamic translucent backgrounds
- New watch faces and complications adopt the Liquid Glass aesthetic
- One-handed wrist flick gesture to dismiss notifications

### Impact on App Design

- System controls (buttons, navigation bars) adopt Liquid Glass automatically
- Custom views should consider how they look with translucent overlays
- Contrast requirements become more important with translucent backgrounds
- Test thoroughly against the new system appearance

---

## Quick Reference Card

| Property | 42mm (Series 10/11) | 46mm (Series 10/11) | 49mm (Ultra 3) |
|----------|---------------------|---------------------|-----------------|
| Pixels | 374 x 446 | 416 x 496 | 514 x 422 |
| Points | 187 x 223 | 208 x 248 | 257 x 211 |
| Scale | 2x | 2x | 2x |
| Safe top/bottom | ~34pt | ~35pt | TBD |
| Usable content | 174 x 147 | 196 x 172 | ~200 x 143 |
| Min tap target | 38 x 38 pt | 38 x 38 pt | 38 x 38 pt |
| Min readable font | 11pt | 11pt | 11pt |
| Recommended body | 17pt | 17pt | 17pt |
| Background | Always dark (#000) | Always dark (#000) | Always dark (#000) |
| Min contrast | 4.5:1 text | 4.5:1 text | 4.5:1 text |

---

## Sources

- [Apple Watch Series 10 Tech Specs](https://support.apple.com/en-us/121202)
- [Apple Watch Series 11 Specs](https://www.apple.com/apple-watch-series-11/specs/)
- [Apple Watch Ultra 3 Specs](https://www.apple.com/apple-watch-ultra-3/specs/)
- [Supporting Multiple Watch Sizes (Apple Developer)](https://developer.apple.com/documentation/watchos-apps/supporting-multiple-watch-sizes)
- [Apple Watch Screen Sizes Deep Dive (Nature Engineering)](https://engineering.nature.global/entry/blog-fes-2022-apple-watch-screen-sizes)
- [Human Interface Guidelines (Apple Developer)](https://developer.apple.com/design/human-interface-guidelines)
- [Designing for watchOS (Apple HIG)](https://developer.apple.com/design/human-interface-guidelines/designing-for-watchos)
- [Design and Build Apps for watchOS 10 (WWDC23)](https://developer.apple.com/videos/play/wwdc2023/10138/)
- [Creating an Intuitive UI in watchOS 10 (Apple Developer)](https://developer.apple.com/documentation/watchos-apps/creating-an-intuitive-and-effective-ui-in-watchos-10)
- [Animate with Springs (WWDC23)](https://developer.apple.com/videos/play/wwdc2023/10158/)
- [Apple Fonts (Developer)](https://developer.apple.com/fonts/)
- [Designing Complications Best Practices (MoldStud)](https://moldstud.com/articles/p-the-ultimate-guide-to-designing-complications-for-apple-watch-dos-and-donts)
- [Apple Watch Ultra 3 GSMArena](https://www.gsmarena.com/apple_watch_ultra_3-14130.php)
- [Apple Watch Series 11 GSMArena](https://www.gsmarena.com/apple_watch_series_11-14131.php)
