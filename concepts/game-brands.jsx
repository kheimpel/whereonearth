import { useState } from "react";

const games = [
  {
    id: "bigger",
    name: "BIGGER?",
    tagline: "Two things. One truth. Tap fast.",
    icon: "⚖️",
    aesthetic: {
      mood: "Brutalist / Confrontational",
      description: "Black background. White type. No decoration. The content IS the design. Two massive options slam onto the screen like heavyweight fighters entering a ring. When you answer, the result hits hard — a full-screen green or red flash, then the stat line appears in a monospaced typeface like a boxing scorecard. No rounded corners. No gradients. No softness. This game doesn't ask politely — it demands you commit.",
      palette: {
        bg: "#0A0A0A",
        text: "#F5F5F0",
        accent: "#FF3B30",
        correct: "#34C759",
        wrong: "#FF3B30",
        muted: "#3A3A3C",
        highlight: "#FFFFFF",
      },
      typography: {
        display: "Knockout / Impact condensed",
        body: "SF Mono or JetBrains Mono",
        feel: "ALL CAPS for options, monospace for data. Type is oversized, condensed, and fills edge to edge."
      },
      motion: "Slam-in animations. Options appear with a hard vertical drop, no bounce. Results flash the full screen — green or red — for 300ms before the stat line types itself out character by character. No easing. Linear. Mechanical.",
      signature: "The stat line after each answer. It appears in small monospace beneath the result, showing exact numbers. This is where the learning happens, delivered with the clinical precision of a scoreboard."
    },
    watchMockup: {
      lines: [
        { type: "question", text: "WHICH IS LARGER BY AREA?" },
        { type: "versus", left: "JAPAN", right: "GERMANY" },
        { type: "result", text: "378K km² vs 357K km²" },
      ]
    }
  },
  {
    id: "whereOnEarth",
    name: "WHERE ON EARTH",
    tagline: "A clue. A spin. How close can you get?",
    icon: "🌍",
    aesthetic: {
      mood: "Dark Atlas / Explorer's Journal",
      description: "Deep navy and parchment. The feeling of a leather-bound atlas opened under a desk lamp at midnight. Clues appear as if stamped or embossed. The longitude strip at the bottom glows like an instrument panel — amber tick marks on dark blue. The Digital Crown interaction should feel like tuning a precision instrument. When you lock in, a gold line drops from your guess to the correct position. Close? Gold shimmer. Far off? The line stretches red across the map. This is the game for people who read atlases for fun.",
      palette: {
        bg: "#0C1425",
        text: "#E8DCC8",
        accent: "#D4A843",
        correct: "#D4A843",
        wrong: "#C0392B",
        muted: "#2A3A5C",
        highlight: "#F4E8C1",
      },
      typography: {
        display: "Playfair Display / Freight Big",
        body: "Source Serif / Charter",
        feel: "Serif for clues (literary, authoritative), monospace for coordinates and scoring. Clue text is set slightly larger, centered, with generous leading — like a title page."
      },
      motion: "Smooth, analog. The map strip scrolls with momentum and settles with a slight dampen — like a physical dial. The gold accuracy line draws itself from guess to answer over 400ms with a slight curve. Results fade in rather than slam.",
      signature: "The longitude strip. A dark horizontal band with amber continent outlines and a bright pin that slides as you turn the Crown. It feels like a physical instrument — a sextant, a compass, a plotting tool."
    },
    watchMockup: {
      lines: [
        { type: "clue", text: "\"Trains arrive within 7 seconds of schedule.\"" },
        { type: "map", text: "───●────────────── 139°E" },
        { type: "score", text: "● RIGHT COUNTRY  +3" },
      ]
    }
  },
  {
    id: "factOrFiction",
    name: "FACT OR FICTION",
    tagline: "Bold claims. You call the bluff.",
    icon: "⚡",
    aesthetic: {
      mood: "Neon Statement / Magazine Editorial",
      description: "High contrast with electric color accents. Each statement fills the screen like a magazine cover headline — big, provocative, designed to make you react before you think. The background shifts between deep charcoal and pure black. TRUE swipes reveal an electric blue flash. FALSE swipes reveal hot magenta. The explanation that follows uses a warm cream color — a moment of calm after the punch. This is the loudest of the three games visually, matching its content: outrageous-sounding truths and plausible-sounding lies.",
      palette: {
        bg: "#111111",
        text: "#FAFAF5",
        accent: "#00D4FF",
        correct: "#00D4FF",
        wrong: "#FF2D78",
        muted: "#2C2C2E",
        highlight: "#00D4FF",
      },
      typography: {
        display: "Obviously / Neue Machina / Tusker Grotesk",
        body: "Söhne / Suisse Intl",
        feel: "Statements in a wide, bold sans-serif — almost poster-like. Explanations in a quieter, warmer weight of the same family. The contrast between the scream of the claim and the whisper of the explanation is the whole rhythm."
      },
      motion: "Swipe-driven. The card tilts and flies off screen in the swipe direction with slight 3D rotation. TRUE cards leave a blue streak. FALSE cards leave a magenta streak. The explanation slides up from below, smooth and understated — counterpoint to the dramatic exit. Progress dots pulse softly.",
      signature: "The one-line explanation. It appears in a slightly different color (warm cream on dark) in a lighter weight, always one sentence. It's the 'actually...' moment. The design gives it room to breathe — generous top margin, no competing elements."
    },
    watchMockup: {
      lines: [
        { type: "statement", text: "\"A TEASPOON OF NEUTRON STAR WEIGHS AS MUCH AS A MOUNTAIN.\"" },
        { type: "action", text: "← FALSE          TRUE →" },
        { type: "explanation", text: "~6 billion tons. Gravity is extraordinary." },
      ]
    }
  }
];

const familyTraits = [
  { trait: "Dark-first", detail: "All three use near-black backgrounds. No white screens. The OLED display makes black pixels disappear — the content floats in darkness." },
  { trait: "One typeface per game", detail: "Each game owns a single display typeface. No mixing display fonts within a game. The body/data font can differ, but the headline voice is singular." },
  { trait: "Full-screen feedback", detail: "Every answer produces a full-screen color flash (300ms) before showing the result. Green/gold/blue for correct, red/magenta for wrong. The haptic fires simultaneously." },
  { trait: "No chrome", detail: "Zero navigation bars, zero settings icons, zero hamburger menus visible during play. The game IS the screen. Everything else is reached by scrolling past the game or through the companion app." },
  { trait: "Edge-to-edge type", detail: "Text goes big. On a 45mm watch face, the display type should feel like it's pressing against the edges. Generous vertical spacing, aggressive horizontal filling." },
  { trait: "Progress dots, not bars", detail: "A row of small dots (●○○○○) at the bottom tracks position in the session. Subtle. Never distracting. Consistent across all three games." },
];

export default function GameBrands() {
  const [activeGame, setActiveGame] = useState(0);
  const game = games[activeGame];

  return (
    <div style={{
      fontFamily: "'Helvetica Neue', 'Arial', sans-serif",
      background: "#0A0A0A",
      color: "#E8E8E3",
      minHeight: "100vh",
      padding: "0",
    }}>
      {/* Header */}
      <div style={{ padding: "48px 32px 24px", borderBottom: "1px solid #222" }}>
        <div style={{
          fontSize: "11px",
          letterSpacing: "4px",
          textTransform: "uppercase",
          color: "#666",
          marginBottom: "12px",
        }}>Brand & Visual Identity</div>
        <h1 style={{
          fontSize: "36px",
          fontWeight: 800,
          letterSpacing: "-1px",
          margin: 0,
          lineHeight: 1.1,
        }}>Three Games.<br/>One Family.<br/>All Bold.</h1>
      </div>

      {/* Game Selector */}
      <div style={{
        display: "flex",
        borderBottom: "1px solid #222",
        cursor: "pointer",
      }}>
        {games.map((g, i) => (
          <div
            key={g.id}
            onClick={() => setActiveGame(i)}
            style={{
              flex: 1,
              padding: "20px 16px",
              textAlign: "center",
              background: activeGame === i ? g.aesthetic.palette.bg : "transparent",
              borderBottom: activeGame === i ? `3px solid ${g.aesthetic.palette.accent}` : "3px solid transparent",
              transition: "all 0.2s ease",
            }}
          >
            <div style={{ fontSize: "24px", marginBottom: "6px" }}>{g.icon}</div>
            <div style={{
              fontSize: "11px",
              fontWeight: 700,
              letterSpacing: "2px",
              color: activeGame === i ? g.aesthetic.palette.accent : "#666",
            }}>{g.name}</div>
          </div>
        ))}
      </div>

      {/* Active Game Detail */}
      <div style={{ padding: "32px" }}>

        {/* Tagline */}
        <div style={{
          fontSize: "20px",
          fontWeight: 300,
          fontStyle: "italic",
          color: game.aesthetic.palette.accent,
          marginBottom: "32px",
          lineHeight: 1.4,
        }}>{game.tagline}</div>

        {/* Mood */}
        <div style={{ marginBottom: "32px" }}>
          <div style={{
            fontSize: "10px",
            letterSpacing: "3px",
            textTransform: "uppercase",
            color: "#555",
            marginBottom: "8px",
          }}>AESTHETIC DIRECTION</div>
          <div style={{
            fontSize: "18px",
            fontWeight: 700,
            color: game.aesthetic.palette.text,
            marginBottom: "12px",
          }}>{game.aesthetic.mood}</div>
          <div style={{
            fontSize: "14px",
            lineHeight: 1.7,
            color: "#999",
          }}>{game.aesthetic.description}</div>
        </div>

        {/* Color Palette */}
        <div style={{ marginBottom: "32px" }}>
          <div style={{
            fontSize: "10px",
            letterSpacing: "3px",
            textTransform: "uppercase",
            color: "#555",
            marginBottom: "12px",
          }}>COLOR PALETTE</div>
          <div style={{ display: "flex", gap: "8px", flexWrap: "wrap" }}>
            {Object.entries(game.aesthetic.palette).map(([name, color]) => (
              <div key={name} style={{
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                gap: "6px",
              }}>
                <div style={{
                  width: "48px",
                  height: "48px",
                  borderRadius: "8px",
                  background: color,
                  border: color === "#0A0A0A" || color === "#0C1425" || color === "#111111" ? "1px solid #333" : "none",
                }} />
                <div style={{
                  fontSize: "9px",
                  letterSpacing: "1px",
                  textTransform: "uppercase",
                  color: "#555",
                }}>{name}</div>
                <div style={{
                  fontSize: "9px",
                  fontFamily: "monospace",
                  color: "#444",
                }}>{color}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Typography */}
        <div style={{ marginBottom: "32px" }}>
          <div style={{
            fontSize: "10px",
            letterSpacing: "3px",
            textTransform: "uppercase",
            color: "#555",
            marginBottom: "12px",
          }}>TYPOGRAPHY</div>
          <div style={{
            display: "grid",
            gridTemplateColumns: "1fr 1fr",
            gap: "16px",
          }}>
            <div>
              <div style={{ fontSize: "11px", color: "#666", marginBottom: "4px" }}>Display</div>
              <div style={{ fontSize: "14px", fontWeight: 700, color: game.aesthetic.palette.accent }}>{game.aesthetic.typography.display}</div>
            </div>
            <div>
              <div style={{ fontSize: "11px", color: "#666", marginBottom: "4px" }}>Body / Data</div>
              <div style={{ fontSize: "14px", fontWeight: 700, color: game.aesthetic.palette.text }}>{game.aesthetic.typography.body}</div>
            </div>
          </div>
          <div style={{
            fontSize: "13px",
            color: "#777",
            marginTop: "12px",
            lineHeight: 1.6,
          }}>{game.aesthetic.typography.feel}</div>
        </div>

        {/* Motion */}
        <div style={{ marginBottom: "32px" }}>
          <div style={{
            fontSize: "10px",
            letterSpacing: "3px",
            textTransform: "uppercase",
            color: "#555",
            marginBottom: "8px",
          }}>MOTION & ANIMATION</div>
          <div style={{
            fontSize: "13px",
            color: "#888",
            lineHeight: 1.7,
          }}>{game.aesthetic.motion}</div>
        </div>

        {/* Signature Element */}
        <div style={{ marginBottom: "32px" }}>
          <div style={{
            fontSize: "10px",
            letterSpacing: "3px",
            textTransform: "uppercase",
            color: "#555",
            marginBottom: "8px",
          }}>SIGNATURE ELEMENT</div>
          <div style={{
            fontSize: "14px",
            color: game.aesthetic.palette.accent,
            lineHeight: 1.6,
            borderLeft: `3px solid ${game.aesthetic.palette.accent}`,
            paddingLeft: "16px",
          }}>{game.aesthetic.signature}</div>
        </div>

        {/* Watch Mockup */}
        <div style={{
          display: "flex",
          justifyContent: "center",
          marginBottom: "32px",
        }}>
          <div style={{
            width: "200px",
            height: "240px",
            borderRadius: "40px",
            background: game.aesthetic.palette.bg,
            border: `2px solid ${game.aesthetic.palette.muted}`,
            display: "flex",
            flexDirection: "column",
            justifyContent: "center",
            padding: "24px 16px",
            gap: "16px",
            position: "relative",
            boxShadow: `0 0 40px ${game.aesthetic.palette.accent}15`,
          }}>
            {/* Crown */}
            <div style={{
              position: "absolute",
              right: "-10px",
              top: "50%",
              transform: "translateY(-50%)",
              width: "6px",
              height: "28px",
              borderRadius: "3px",
              background: "#444",
            }} />

            {game.watchMockup.lines.map((line, i) => (
              <div key={i} style={{
                textAlign: "center",
                fontSize: line.type === "question" || line.type === "clue" || line.type === "statement"
                  ? "10px" : line.type === "versus" ? "18px" : "9px",
                fontWeight: line.type === "versus" || line.type === "statement" ? 800 : 400,
                fontFamily: line.type === "result" || line.type === "map" ? "monospace" : "inherit",
                color: line.type === "result" || line.type === "explanation" || line.type === "score"
                  ? game.aesthetic.palette.accent
                  : line.type === "action" || line.type === "map"
                  ? game.aesthetic.palette.muted
                  : game.aesthetic.palette.text,
                letterSpacing: line.type === "versus" || line.type === "statement" ? "1px" : "0.5px",
                lineHeight: 1.4,
              }}>
                {line.type === "versus" ? (
                  <div style={{ display: "flex", justifyContent: "space-around", alignItems: "center" }}>
                    <span>{line.left}</span>
                    <span style={{ fontSize: "10px", color: game.aesthetic.palette.muted }}>vs</span>
                    <span>{line.right}</span>
                  </div>
                ) : line.text}
              </div>
            ))}

            {/* Progress dots */}
            <div style={{
              display: "flex",
              justifyContent: "center",
              gap: "4px",
              position: "absolute",
              bottom: "14px",
              left: 0,
              right: 0,
            }}>
              {[1,2,3,4,5,6,7].map(n => (
                <div key={n} style={{
                  width: "4px",
                  height: "4px",
                  borderRadius: "50%",
                  background: n <= 4 ? game.aesthetic.palette.accent : game.aesthetic.palette.muted,
                  opacity: n <= 4 ? 1 : 0.3,
                }} />
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Family Traits */}
      <div style={{
        borderTop: "1px solid #222",
        padding: "32px",
      }}>
        <div style={{
          fontSize: "10px",
          letterSpacing: "3px",
          textTransform: "uppercase",
          color: "#555",
          marginBottom: "20px",
        }}>SHARED FAMILY TRAITS — WHAT TIES THEM TOGETHER</div>

        {familyTraits.map((item, i) => (
          <div key={i} style={{
            marginBottom: "16px",
            paddingBottom: "16px",
            borderBottom: i < familyTraits.length - 1 ? "1px solid #1a1a1a" : "none",
          }}>
            <div style={{
              fontSize: "14px",
              fontWeight: 700,
              color: "#E8E8E3",
              marginBottom: "4px",
            }}>{item.trait}</div>
            <div style={{
              fontSize: "12px",
              color: "#666",
              lineHeight: 1.6,
            }}>{item.detail}</div>
          </div>
        ))}
      </div>

      {/* App Name suggestion */}
      <div style={{
        borderTop: "1px solid #222",
        padding: "32px",
      }}>
        <div style={{
          fontSize: "10px",
          letterSpacing: "3px",
          textTransform: "uppercase",
          color: "#555",
          marginBottom: "16px",
        }}>UMBRELLA BRAND — THE APP ITSELF</div>

        <div style={{
          fontSize: "13px",
          color: "#888",
          lineHeight: 1.8,
        }}>
          The three games live inside a single app. The umbrella needs a name that says "knowledge" and "boldness" without being corny. Some directions:
        </div>

        <div style={{
          display: "grid",
          gridTemplateColumns: "1fr 1fr",
          gap: "12px",
          marginTop: "16px",
        }}>
          {[
            { name: "KNOW", vibe: "Short. Aggressive. A verb and a dare." },
            { name: "CORTEX", vibe: "Brain science. Premium. Slightly intimidating." },
            { name: "BOLD", vibe: "The shared trait. Describes the design and the player." },
            { name: "DATUM", vibe: "Latin for 'given.' Data-driven knowledge. Clean." },
            { name: "WRIST", vibe: "Platform-native. Unpretentious. Memorable." },
            { name: "SNAP", vibe: "Speed. Quick judgments. Snap decisions." },
          ].map(n => (
            <div key={n.name} style={{
              background: "#151515",
              padding: "14px",
              borderRadius: "8px",
              border: "1px solid #222",
            }}>
              <div style={{
                fontSize: "16px",
                fontWeight: 800,
                letterSpacing: "3px",
                color: "#E8E8E3",
                marginBottom: "4px",
              }}>{n.name}</div>
              <div style={{
                fontSize: "10px",
                color: "#555",
                lineHeight: 1.5,
              }}>{n.vibe}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
