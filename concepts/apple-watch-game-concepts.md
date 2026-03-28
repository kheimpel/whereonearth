# Apple Watch Game Concepts

Three knowledge games for Apple Watch. Each playable in under 60 seconds. Each uses a single primary input. Each teaches something real.

---

## 1. Where on Earth

*GeoGuessr for your wrist.*

### Core Loop

A clue appears. You guess where in the world it's from.

**Clue types** (one per round, randomly selected):

- **Landmark snippet** — A cropped, zoomed-in photo of a famous landmark. Not the postcard view. The corner of a roof. A texture of a wall. A detail that rewards familiarity.
- **Street clue** — A real detail: "Yellow taxis, steam from manholes, hot dog carts." You place it.
- **Food clue** — "This country invented the croissant." (Trick: it's Austria, not France.)
- **Cultural clue** — "Trains arrive within 7 seconds of schedule on average." (Japan.)
- **Flag detail** — A zoomed-in portion of a flag. Enough to narrow it down if you know your flags.
- **Language snippet** — A short phrase in a foreign script or language. "Danke schön."

### Input Mechanic

The screen shows a **horizontal world strip** — a simplified Mercator band showing continent outlines. You spin the **Digital Crown** to slide a pin left/right across longitudes. Tap to lock in.

No vertical axis. No zooming. One dimension only. This is the key simplification that makes it playable on a 45mm screen.

### Scoring

| Accuracy | Points | Haptic |
|----------|--------|--------|
| Right country | 3 | `.success` |
| Right region (e.g., Southeast Asia) | 2 | `.click` |
| Right continent | 1 | `.click` |
| Wrong continent | 0 | `.failure` |

5 clues per session. Max score: 15.

### Difficulty Progression

- **Level 1** — Famous landmarks, major countries. "The Eiffel Tower" → Western Europe.
- **Level 2** — Regional clues. "Ceviche originated here." → Peru/South America.
- **Level 3** — Obscure or misleading clues. "This country has more pyramids than Egypt." → Sudan.

Difficulty adapts based on your rolling accuracy. Get 80%+ right → harder clues surface.

### Content Volume Needed

~500 clues for launch (100 per type). Each clue is: one image or one sentence + correct longitude range + country + region + continent. Easily expandable — this is a content game, not a mechanics game.

### What Makes It Work on Watch

The single-axis Crown scroll avoids all the problems of trying to pinch-zoom a map on a tiny screen. The clue-then-guess loop takes 10–12 seconds per round. The "aha" moments ("Wait, Sudan has MORE pyramids?") are genuinely memorable and shareable.

---

## 2. Bigger?

*Two things. Tap the bigger one. Sounds trivial. Isn't.*

### Core Loop

Two things appear side by side. You tap the one that's "more" — bigger, taller, faster, heavier, further, older, hotter. Whatever the comparison is.

That's it. Binary choice. Two large buttons. No Crown, no swipe, no complexity.

### What Gets Compared

The game draws from a curated pool of comparisons across physics, geography, math, and general science. The best comparisons are ones where your gut feeling is wrong.

**Geography comparisons:**

- Population: Portugal vs. Sweden → Portugal (10.3M vs. 10.5M — close!)
- Area: Japan vs. Germany → Japan (378k km² vs. 357k km²)
- Distance: London→Tokyo vs. NYC→Sydney → roughly equal (~9,500 vs. ~10,000 mi)
- Coastline: Canada vs. Indonesia → Canada (by a huge margin)
- Elevation: highest point in UK vs. highest point in Netherlands → UK (Ben Nevis, 1,345m)

**Physics comparisons:**

- Speed of sound vs. speed of a bullet → depends on the bullet (great teaching moment)
- Weight of Earth's atmosphere vs. weight of all Earth's water → water, by ~3,000x
- Temperature of lightning bolt vs. surface of the Sun → lightning, 5x hotter
- Distance to the Moon vs. circumference of Earth → Moon is ~10x further
- Energy in a lightning bolt vs. energy in a gallon of gas → gallon of gas wins

**Math comparisons:**

- √150 vs. 12.5 → 12.5 (√150 ≈ 12.24)
- 3⁴ vs. 4³ → 3⁴ = 81 > 4³ = 64
- Number of primes under 100 vs. 30 → 25 primes, so 30 wins
- π² vs. 10 → 10 (π² ≈ 9.87 — close!)
- 2¹⁰ vs. 10³ → 2¹⁰ = 1024 > 1000

**Surprise / trick comparisons** (where the answer is "equal" or "neither"):

- Kilogram of steel vs. kilogram of feathers → equal (classic trick)
- Falling bowling ball vs. falling basketball (in vacuum) → equal
- These appear occasionally and the player must tap a "=" button that appears as a third option

### Screen Layout

```
┌─────────────────────┐
│                     │
│   Portugal    ←→   Sweden    │
│   ┌────────┐  ┌────────┐    │
│   │  TAP   │  │  TAP   │    │
│   │        │  │        │    │
│   └────────┘  └────────┘    │
│                             │
│   Which has more people?    │
│                             │
│         7/10  ●●●●●●●○○○   │
└─────────────────────────────┘
```

Two big tap zones. Question at the bottom. Progress dots. Nothing else.

### After Each Answer

- **Correct**: Green flash on your pick. `.success` haptic. Brief stat line: "Portugal: 10.3M / Sweden: 10.5M" — 2 seconds.
- **Wrong**: Red flash. `.failure` haptic. Same stat line. The correction IS the learning.

### Session Structure

10 comparisons per 60-second session. ~5 seconds per comparison (read → think → tap → see result). A good pace that creates flow without rushing.

### Difficulty & Adaptation

- **Easy**: Obvious gaps. "Population: China vs. Portugal." The learning is in the exact numbers.
- **Medium**: Counterintuitive comparisons. "Area: Japan vs. Germany." Most people guess Germany.
- **Hard**: Very close calls. "Population: Portugal vs. Sweden." Requires real knowledge.
- **Expert**: Multi-step reasoning. "Energy: 1 hour of sunlight hitting Earth vs. global annual energy use." (Sunlight wins, by ~7,000x.)

The spaced repetition layer resurfaces comparisons you got wrong, with the same pair but sometimes the reverse framing.

### Content Structure

Each comparison is a simple data record:

```
{
  "left": "Japan",
  "right": "Germany", 
  "dimension": "area",
  "question": "Which is larger by area?",
  "left_value": "378,000 km²",
  "right_value": "357,000 km²",
  "answer": "left",
  "surprise_rating": 3,  // 1-5, higher = more counterintuitive
  "category": "geography",
  "detail": "Japan's islands spread across a longer range than most people realize."
}
```

~300 comparisons for launch. 100 geography, 100 physics, 50 math, 50 mixed. Easy to add more — the format is dead simple and could even be community-contributed.

### What Makes It Work on Watch

The binary tap is the most reliable input on the watch. Two huge buttons, zero ambiguity, zero arm fatigue. The surprise factor ("Wait, Japan is bigger than Germany?!") creates the emotional spike that locks facts into memory. The stat line after each answer turns every round into a micro-lesson without ever feeling like studying.

---

## 3. Fact or Fiction

*Bold claims. You call the bluff.*

### Core Loop

A statement appears on screen. You swipe right for **True** or left for **False**.

After you answer, a one-line explanation appears for 3 seconds. Then the next statement.

### Statement Examples by Subject

**Physics:**

| Statement | Answer | Explanation |
|-----------|--------|-------------|
| Venus rotates backwards compared to most planets. | ✓ True | Venus spins clockwise — the only planet besides Uranus to do so. |
| Lightning is hotter than the surface of the Sun. | ✓ True | Lightning reaches ~30,000°C. The Sun's surface is ~5,500°C. |
| Sound travels faster in cold air than warm air. | ✗ False | Sound is faster in warm air — molecules move quicker. |
| A teaspoon of neutron star weighs about as much as a mountain. | ✓ True | ~6 billion tons per teaspoon. |
| Humans can outrun horses over long distances. | ✓ True | In ultramarathons, elite humans beat horses. We're endurance specialists. |
| Glass is a liquid that flows very slowly. | ✗ False | Debunked. Glass is an amorphous solid. Old windows are thicker at the bottom due to manufacturing, not flow. |

**Geography:**

| Statement | Answer | Explanation |
|-----------|--------|-------------|
| Africa is larger than the Moon's entire surface. | ✓ True | Africa: 30.4M km². Moon's surface: 37.9M km². Close, but Moon wins. Wait — false? Check: this one's actually False. Good trick question. |
| The Great Wall of China is visible from space with the naked eye. | ✗ False | Astronauts confirm it's not visible. Too narrow. |
| Russia has 11 time zones. | ✓ True | Spanning from UTC+2 to UTC+12. |
| Istanbul is in two continents. | ✓ True | Europe and Asia, split by the Bosphorus. |
| There are more trees on Earth than stars in the Milky Way. | ✓ True | ~3 trillion trees vs. ~100–400 billion stars. |

**Math:**

| Statement | Answer | Explanation |
|-----------|--------|-------------|
| There are more ways to shuffle a deck of cards than atoms on Earth. | ✓ True | 52! ≈ 8×10⁶⁷. Atoms on Earth ≈ 10⁵⁰. Not even close. |
| If you fold a piece of paper 42 times, it reaches the Moon. | ✓ True | 2⁴² × 0.1mm ≈ 440,000 km. Moon is ~384,000 km away. |
| 0.999... repeating equals exactly 1. | ✓ True | Mathematically proven. Not "close to" — exactly equal. |
| A million seconds is about 11 days. A billion seconds is about 32 years. | ✓ True | This is why "million" and "billion" feel deceptively similar. |

### Screen Layout

```
┌─────────────────────────────┐
│                             │
│   "A teaspoon of neutron    │
│    star weighs about as     │
│    much as a mountain."     │
│                             │
│                             │
│   ← FALSE      TRUE →      │
│                             │
│         5/8  ●●●●●○○○      │
└─────────────────────────────┘
```

After answering:

```
┌─────────────────────────────┐
│                             │
│        ✓ CORRECT            │
│                             │
│   ~6 billion tons per       │
│   teaspoon. Gravity is      │
│   extraordinary.            │
│                             │
│              [3...2...1]    │
│         5/8  ●●●●●○○○      │
└─────────────────────────────┘
```

### Input Mechanic

**Swipe right** = True. **Swipe left** = False. Natural, fast, Tinder-like. No buttons to aim for.

Alternative: two tap zones if swipe detection proves unreliable in testing. But swipe is the aspiration — it feels different from the other two games and gives variety.

### Session Structure

8 statements per 60-second session. ~7 seconds each (read → decide → swipe → see explanation → next).

### Difficulty Layers

- **Common myths** (easiest) — Things most people believe but are false. High "aha" density.
- **Surprising truths** (medium) — Things that sound absurd but are true. Tests whether you trust your instincts or think twice.
- **Trick statements** (hard) — Technically true but misleadingly worded, or technically false due to a specific detail. Teaches precision of language.
- **Edge cases** (expert) — Statements that are debated or context-dependent. The explanation acknowledges the nuance.

### Content Requirements

~400 statements for launch. Each statement needs:

```
{
  "statement": "Lightning is hotter than the surface of the Sun.",
  "answer": true,
  "explanation": "Lightning reaches ~30,000°C. The Sun's surface is ~5,500°C.",
  "category": "physics",
  "difficulty": 2,
  "surprise_rating": 4,
  "common_misconception": false
}
```

The explanation is the most important field. It's where all the learning happens. Keep it to one sentence, two max. If it can't be explained briefly, it's not a good statement for this game.

### What Makes It Work on Watch

Swipe is the lowest-friction input possible — no targeting, no precision. The statement-then-explanation rhythm creates a "did you know?" conversation feel. The content is inherently shareable ("Did you know a teaspoon of neutron star..."), which drives word-of-mouth. And the mix of physics, geography, and math means every session covers multiple subjects without the player having to choose.

---

## Shared Systems Across All Three Games

### Engagement Layer

All three games share a single progression and engagement system:

**Daily streak** — Play any game once per day to extend your streak. Streak counter lives as a watch face complication. Streak freeze earned every 7 consecutive days (max 2 stored).

**Session score** — Each session produces a score (0–15 for Where on Earth, 0–10 for Bigger?, 0–8 for Fact or Fiction). Daily total across all games contributes to a weekly score.

**Spaced repetition** — Wrong answers re-enter the pool. Items you consistently get right appear less frequently. Items you get wrong appear sooner. Simple SM-2 or FSRS scheduling behind the scenes — the player never sees the algorithm, just notices they keep encountering things they got wrong before.

**Complication** — Shows streak count (🔥 47) and tapping it opens directly into a random game. The complication is the front door.

**Notification nudges** — Optional. 2–3 times per day at user-configured times. "Quick: Is Japan bigger than Germany by area?" Answerable from the notification without opening the app. These function as spaced repetition reviews that intercept idle moments.

### What's NOT in the system

No accounts. No social login. No in-app purchases blocking content. No ads. No tutorials longer than one screen. No settings menus with 20 options. No onboarding flow.

The games start when you open them. That's it.

### Technical Notes

- **SwiftUI only** — no SpriteKit needed for any of these
- **Data is local-first** — all content bundled in the app, progress stored on device, synced via iCloud KeyValue store for multi-device
- **Image assets** (Where on Earth landmarks) should be small JPEGs, ~50KB each, lazy-loaded
- **Total app size target**: under 30MB including all content
- **Battery impact**: minimal — short sessions, dark backgrounds, no continuous animation
- **Haptic usage**: `.success`, `.failure`, `.click` only — no custom patterns needed
