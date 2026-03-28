import { useState, useRef, useEffect, useCallback } from "react";

// Continent outlines - simplified polygons
const continentData = [
  {
    name: "Africa", color: "#C4A265", points: [
      { lng: -17, lat: 15 }, { lng: -12, lat: 5 }, { lng: 5, lat: 4 }, { lng: 9, lat: 4 },
      { lng: 10, lat: 2 }, { lng: 9, lat: -4 }, { lng: 12, lat: -6 }, { lng: 14, lat: -5 },
      { lng: 17, lat: -8 }, { lng: 25, lat: -15 }, { lng: 28, lat: -22 }, { lng: 32, lat: -26 },
      { lng: 29, lat: -34 }, { lng: 18, lat: -35 }, { lng: 15, lat: -28 }, { lng: 12, lat: -18 },
      { lng: 12, lat: -6 }, { lng: 8, lat: 4 }, { lng: 2, lat: 6 }, { lng: -5, lat: 5 },
      { lng: -8, lat: 8 }, { lng: -16, lat: 12 }, { lng: -17, lat: 15 },
    ]
  },
  {
    name: "Africa-North", color: "#C4A265", points: [
      { lng: -17, lat: 15 }, { lng: -17, lat: 21 }, { lng: -13, lat: 28 },
      { lng: -5, lat: 36 }, { lng: 3, lat: 37 }, { lng: 10, lat: 37 },
      { lng: 11, lat: 33 }, { lng: 25, lat: 32 }, { lng: 32, lat: 31 },
      { lng: 35, lat: 30 }, { lng: 40, lat: 22 }, { lng: 43, lat: 12 },
      { lng: 50, lat: 12 }, { lng: 51, lat: 9 }, { lng: 44, lat: 11 },
      { lng: 42, lat: 15 }, { lng: 36, lat: 20 }, { lng: 33, lat: 28 },
      { lng: 24, lat: 31 }, { lng: 10, lat: 35 }, { lng: 0, lat: 35 },
      { lng: -5, lat: 34 }, { lng: -13, lat: 27 }, { lng: -17, lat: 21 },
    ]
  },
  {
    name: "Europe", color: "#B89F6A", points: [
      { lng: -10, lat: 37 }, { lng: -9, lat: 43 }, { lng: -5, lat: 44 },
      { lng: -2, lat: 43 }, { lng: 3, lat: 43 }, { lng: 5, lat: 44 },
      { lng: 8, lat: 48 }, { lng: 5, lat: 51 }, { lng: 4, lat: 52 },
      { lng: 8, lat: 55 }, { lng: 12, lat: 56 }, { lng: 10, lat: 58 },
      { lng: 5, lat: 62 }, { lng: 8, lat: 64 }, { lng: 15, lat: 69 },
      { lng: 25, lat: 71 }, { lng: 30, lat: 70 }, { lng: 28, lat: 65 },
      { lng: 24, lat: 60 }, { lng: 28, lat: 57 }, { lng: 24, lat: 55 },
      { lng: 21, lat: 55 }, { lng: 18, lat: 55 }, { lng: 15, lat: 52 },
      { lng: 17, lat: 49 }, { lng: 22, lat: 49 }, { lng: 24, lat: 52 },
      { lng: 28, lat: 52 }, { lng: 40, lat: 55 }, { lng: 44, lat: 52 },
      { lng: 40, lat: 46 }, { lng: 30, lat: 46 }, { lng: 28, lat: 41 },
      { lng: 26, lat: 41 }, { lng: 24, lat: 38 }, { lng: 20, lat: 40 },
      { lng: 15, lat: 38 }, { lng: 12, lat: 37 }, { lng: 10, lat: 44 },
      { lng: 7, lat: 44 }, { lng: 3, lat: 43 }, { lng: -5, lat: 36 },
      { lng: -10, lat: 37 },
    ]
  },
  {
    name: "Asia-North", color: "#B89F6A", points: [
      { lng: 44, lat: 52 }, { lng: 50, lat: 55 }, { lng: 60, lat: 55 },
      { lng: 70, lat: 55 }, { lng: 80, lat: 52 }, { lng: 90, lat: 50 },
      { lng: 100, lat: 55 }, { lng: 110, lat: 55 }, { lng: 120, lat: 55 },
      { lng: 130, lat: 50 }, { lng: 135, lat: 48 }, { lng: 140, lat: 52 },
      { lng: 143, lat: 52 }, { lng: 150, lat: 58 }, { lng: 160, lat: 62 },
      { lng: 170, lat: 64 }, { lng: 180, lat: 66 }, { lng: 180, lat: 72 },
      { lng: 170, lat: 70 }, { lng: 150, lat: 68 }, { lng: 140, lat: 65 },
      { lng: 130, lat: 62 }, { lng: 120, lat: 66 }, { lng: 110, lat: 68 },
      { lng: 100, lat: 70 }, { lng: 80, lat: 70 }, { lng: 70, lat: 72 },
      { lng: 60, lat: 70 }, { lng: 50, lat: 67 }, { lng: 44, lat: 52 },
    ]
  },
  {
    name: "Asia-South", color: "#B89F6A", points: [
      { lng: 44, lat: 52 }, { lng: 40, lat: 46 }, { lng: 35, lat: 42 },
      { lng: 36, lat: 35 }, { lng: 35, lat: 32 }, { lng: 44, lat: 28 },
      { lng: 48, lat: 30 }, { lng: 52, lat: 24 }, { lng: 56, lat: 25 },
      { lng: 60, lat: 24 }, { lng: 66, lat: 25 }, { lng: 72, lat: 20 },
      { lng: 77, lat: 8 }, { lng: 80, lat: 7 }, { lng: 82, lat: 8 },
      { lng: 85, lat: 22 }, { lng: 88, lat: 22 }, { lng: 90, lat: 22 },
      { lng: 92, lat: 20 }, { lng: 98, lat: 16 }, { lng: 100, lat: 14 },
      { lng: 101, lat: 7 }, { lng: 103, lat: 2 }, { lng: 105, lat: 10 },
      { lng: 108, lat: 16 }, { lng: 108, lat: 22 }, { lng: 112, lat: 22 },
      { lng: 117, lat: 25 }, { lng: 122, lat: 30 }, { lng: 123, lat: 35 },
      { lng: 128, lat: 38 }, { lng: 130, lat: 43 }, { lng: 135, lat: 48 },
      { lng: 130, lat: 50 }, { lng: 120, lat: 55 }, { lng: 110, lat: 55 },
      { lng: 100, lat: 55 }, { lng: 90, lat: 50 }, { lng: 80, lat: 52 },
      { lng: 70, lat: 55 }, { lng: 60, lat: 55 }, { lng: 50, lat: 55 },
      { lng: 44, lat: 52 },
    ]
  },
  {
    name: "NorthAmerica", color: "#C4A265", points: [
      { lng: -168, lat: 66 }, { lng: -162, lat: 64 }, { lng: -152, lat: 60 },
      { lng: -140, lat: 60 }, { lng: -130, lat: 55 }, { lng: -125, lat: 50 },
      { lng: -123, lat: 48 }, { lng: -124, lat: 42 }, { lng: -118, lat: 34 },
      { lng: -112, lat: 32 }, { lng: -105, lat: 30 }, { lng: -100, lat: 28 },
      { lng: -97, lat: 26 }, { lng: -90, lat: 30 }, { lng: -82, lat: 25 },
      { lng: -80, lat: 25 }, { lng: -81, lat: 30 }, { lng: -76, lat: 35 },
      { lng: -70, lat: 42 }, { lng: -67, lat: 45 }, { lng: -65, lat: 47 },
      { lng: -60, lat: 47 }, { lng: -55, lat: 50 }, { lng: -57, lat: 52 },
      { lng: -62, lat: 54 }, { lng: -75, lat: 62 }, { lng: -80, lat: 64 },
      { lng: -85, lat: 66 }, { lng: -95, lat: 68 }, { lng: -100, lat: 72 },
      { lng: -120, lat: 74 }, { lng: -140, lat: 72 }, { lng: -155, lat: 72 },
      { lng: -168, lat: 66 },
    ]
  },
  {
    name: "SouthAmerica", color: "#C4A265", points: [
      { lng: -82, lat: 10 }, { lng: -77, lat: 8 }, { lng: -72, lat: 12 },
      { lng: -67, lat: 11 }, { lng: -60, lat: 8 }, { lng: -52, lat: 4 },
      { lng: -50, lat: 0 }, { lng: -45, lat: -3 }, { lng: -38, lat: -5 },
      { lng: -35, lat: -8 }, { lng: -35, lat: -15 }, { lng: -38, lat: -18 },
      { lng: -40, lat: -23 }, { lng: -48, lat: -28 }, { lng: -52, lat: -33 },
      { lng: -58, lat: -35 }, { lng: -65, lat: -42 }, { lng: -68, lat: -48 },
      { lng: -72, lat: -52 }, { lng: -75, lat: -52 }, { lng: -73, lat: -45 },
      { lng: -72, lat: -38 }, { lng: -72, lat: -30 }, { lng: -70, lat: -18 },
      { lng: -75, lat: -15 }, { lng: -77, lat: -7 }, { lng: -80, lat: -3 },
      { lng: -80, lat: 0 }, { lng: -78, lat: 2 }, { lng: -77, lat: 4 },
      { lng: -82, lat: 10 },
    ]
  },
  {
    name: "Australia", color: "#B89F6A", points: [
      { lng: 113, lat: -22 }, { lng: 115, lat: -35 }, { lng: 118, lat: -35 },
      { lng: 130, lat: -32 }, { lng: 136, lat: -35 }, { lng: 138, lat: -35 },
      { lng: 141, lat: -38 }, { lng: 147, lat: -38 }, { lng: 150, lat: -37 },
      { lng: 153, lat: -28 }, { lng: 150, lat: -23 }, { lng: 148, lat: -20 },
      { lng: 146, lat: -19 }, { lng: 142, lat: -14 }, { lng: 136, lat: -12 },
      { lng: 132, lat: -12 }, { lng: 129, lat: -15 }, { lng: 127, lat: -14 },
      { lng: 124, lat: -16 }, { lng: 122, lat: -18 }, { lng: 114, lat: -22 },
      { lng: 113, lat: -22 },
    ]
  },
];

// Mountain ranges as simple line segments for relief effect
const mountainRanges = [
  // Alps
  { points: [{ lng: 6, lat: 46 }, { lng: 8, lat: 47 }, { lng: 10, lat: 47 }, { lng: 13, lat: 47 }, { lng: 16, lat: 47 }], intensity: 0.8 },
  // Himalayas
  { points: [{ lng: 72, lat: 35 }, { lng: 76, lat: 34 }, { lng: 80, lat: 30 }, { lng: 84, lat: 28 }, { lng: 88, lat: 27 }, { lng: 92, lat: 28 }], intensity: 1.0 },
  // Andes
  { points: [{ lng: -78, lat: 2 }, { lng: -76, lat: -5 }, { lng: -72, lat: -15 }, { lng: -70, lat: -25 }, { lng: -70, lat: -35 }, { lng: -72, lat: -42 }], intensity: 0.9 },
  // Rockies
  { points: [{ lng: -120, lat: 38 }, { lng: -115, lat: 42 }, { lng: -112, lat: 45 }, { lng: -114, lat: 48 }, { lng: -118, lat: 52 }], intensity: 0.7 },
  // Atlas
  { points: [{ lng: -5, lat: 34 }, { lng: 0, lat: 35 }, { lng: 5, lat: 35 }, { lng: 9, lat: 34 }], intensity: 0.5 },
  // Urals
  { points: [{ lng: 58, lat: 50 }, { lng: 60, lat: 55 }, { lng: 62, lat: 60 }, { lng: 64, lat: 65 }], intensity: 0.5 },
  // East African Rift
  { points: [{ lng: 35, lat: 10 }, { lng: 36, lat: 5 }, { lng: 34, lat: 0 }, { lng: 30, lat: -5 }, { lng: 32, lat: -10 }], intensity: 0.6 },
  // Scandinavian range
  { points: [{ lng: 8, lat: 60 }, { lng: 12, lat: 63 }, { lng: 15, lat: 66 }, { lng: 18, lat: 69 }], intensity: 0.5 },
  // Japanese Alps
  { points: [{ lng: 136, lat: 34 }, { lng: 137, lat: 36 }, { lng: 139, lat: 37 }, { lng: 140, lat: 39 }], intensity: 0.6 },
  // Caucasus
  { points: [{ lng: 40, lat: 42 }, { lng: 43, lat: 42.5 }, { lng: 46, lat: 42 }], intensity: 0.6 },
  // Appalachians
  { points: [{ lng: -84, lat: 34 }, { lng: -80, lat: 37 }, { lng: -77, lat: 40 }, { lng: -74, lat: 43 }], intensity: 0.4 },
  // Great Rift / Ethiopian Highlands
  { points: [{ lng: 38, lat: 8 }, { lng: 40, lat: 10 }, { lng: 42, lat: 12 }], intensity: 0.5 },
  // Pyrenees
  { points: [{ lng: -2, lat: 42.5 }, { lng: 0, lat: 42.8 }, { lng: 2, lat: 42.5 }], intensity: 0.4 },
  // Carpathians
  { points: [{ lng: 18, lat: 49 }, { lng: 20, lat: 48 }, { lng: 24, lat: 47 }, { lng: 26, lat: 46 }], intensity: 0.4 },
];

// Major rivers as thin lines
const rivers = [
  { name: "Nile", points: [{ lng: 31, lat: 31 }, { lng: 32, lat: 25 }, { lng: 33, lat: 15 }, { lng: 32, lat: 5 }] },
  { name: "Amazon", points: [{ lng: -50, lat: -2 }, { lng: -55, lat: -3 }, { lng: -60, lat: -4 }, { lng: -65, lat: -5 }, { lng: -72, lat: -5 }] },
  { name: "Danube", points: [{ lng: 10, lat: 48 }, { lng: 15, lat: 48 }, { lng: 19, lat: 47 }, { lng: 25, lat: 44 }, { lng: 29, lat: 44 }] },
  { name: "Yangtze", points: [{ lng: 122, lat: 31 }, { lng: 115, lat: 30 }, { lng: 110, lat: 30 }, { lng: 105, lat: 29 }, { lng: 100, lat: 28 }] },
  { name: "Mississippi", points: [{ lng: -90, lat: 30 }, { lng: -90, lat: 35 }, { lng: -92, lat: 40 }, { lng: -93, lat: 45 }] },
];

const graticuleLines = {
  lats: [-60, -40, -20, 0, 20, 40, 60],
  lngs: [-180, -150, -120, -90, -60, -30, 0, 30, 60, 90, 120, 150, 180],
};

// Example game scenarios
const scenarios = [
  {
    clue: "\"Trains arrive within 7 seconds of schedule on average.\"",
    answer: { lng: 139.7, lat: 35.7, name: "Tokyo, Japan" },
    playerGuess: { lng: 105 },
    result: "region", // continent | region | country
    points: 2,
  },
  {
    clue: "\"This country has more pyramids than Egypt.\"",
    answer: { lng: 32.5, lat: 15.6, name: "Sudan" },
    playerGuess: { lng: -15 },
    result: "continent",
    points: 1,
  },
  {
    clue: "\"The world's oldest restaurant has been open since 1725.\"",
    answer: { lng: -3.7, lat: 40.4, name: "Madrid, Spain" },
    playerGuess: { lng: 2 },
    result: "country",
    points: 3,
  },
];

function WorldMap({ longitude, zoom, reliefIntensity, width, height, answerLng, answerLat, showAnswer, guessLng, showGuessLine, phase }) {
  const canvasRef = useRef(null);

  const lngToX = useCallback((lng) => {
    let adjusted = ((lng - longitude + 540) % 360) - 180;
    return (adjusted / 360) * width * zoom + width / 2;
  }, [longitude, width, zoom]);

  const latToY = useCallback((lat) => {
    const maxLat = 78;
    const clampedLat = Math.max(-maxLat, Math.min(maxLat, lat));
    const rad = (clampedLat * Math.PI) / 180;
    const mercY = Math.log(Math.tan(Math.PI / 4 + rad / 2));
    const maxMercY = Math.log(Math.tan(Math.PI / 4 + (maxLat * Math.PI) / 180 / 2));
    const centerLatRad = (answerLat * Math.PI) / 180;
    const centerMercY = Math.log(Math.tan(Math.PI / 4 + centerLatRad / 2));
    const offsetY = phase === "zoomed" ? (centerMercY / maxMercY) * (height / 2) * 0.85 * (zoom - 1) * 0.3 : 0;
    return height / 2 - (mercY / maxMercY) * (height / 2) * 0.85 * zoom + offsetY;
  }, [height, zoom, answerLat, longitude, phase]);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    const dpr = window.devicePixelRatio || 2;
    canvas.width = width * dpr;
    canvas.height = height * dpr;
    ctx.scale(dpr, dpr);

    // Ocean
    const oceanGrad = ctx.createRadialGradient(width / 2, height / 2, 0, width / 2, height / 2, width * 0.7);
    oceanGrad.addColorStop(0, "#0F1A2E");
    oceanGrad.addColorStop(1, "#080E1A");
    ctx.fillStyle = oceanGrad;
    ctx.fillRect(0, 0, width, height);

    // Bathymetric subtle depth lines in ocean
    if (reliefIntensity > 0.2) {
      ctx.strokeStyle = `rgba(30, 50, 80, ${reliefIntensity * 0.3})`;
      ctx.lineWidth = 0.3;
      [-70, -50, -30, -10, 10, 30].forEach(lat => {
        const y = latToY(lat);
        ctx.beginPath();
        for (let x = 0; x < width; x += 2) {
          const wave = Math.sin(x * 0.02 + lat * 0.5) * 2 * reliefIntensity;
          if (x === 0) ctx.moveTo(x, y + wave);
          else ctx.lineTo(x, y + wave);
        }
        ctx.stroke();
      });
    }

    // Graticule
    graticuleLines.lats.forEach(lat => {
      const y = latToY(lat);
      if (y < -20 || y > height + 20) return;
      ctx.strokeStyle = lat === 0 ? "rgba(212, 168, 67, 0.15)" : "rgba(180, 165, 130, 0.04)";
      ctx.lineWidth = lat === 0 ? 0.6 : 0.3;
      ctx.beginPath();
      ctx.moveTo(0, y);
      ctx.lineTo(width, y);
      ctx.stroke();
    });

    graticuleLines.lngs.forEach(lng => {
      const x = lngToX(lng);
      if (x < -50 || x > width + 50) return;
      ctx.strokeStyle = lng === 0 ? "rgba(212, 168, 67, 0.15)" : "rgba(180, 165, 130, 0.04)";
      ctx.lineWidth = lng === 0 ? 0.6 : 0.3;
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, height);
      ctx.stroke();
    });

    // Continents
    continentData.forEach(continent => {
      const xPoints = continent.points.map(p => lngToX(p.lng));
      const yPoints = continent.points.map(p => latToY(p.lat));
      const visibleX = xPoints.filter(x => x > -150 && x < width + 150);
      if (visibleX.length === 0) return;

      let hasWrap = false;
      for (let i = 1; i < xPoints.length; i++) {
        if (Math.abs(xPoints[i] - xPoints[i - 1]) > width * 0.5) { hasWrap = true; break; }
      }
      if (hasWrap) return;

      ctx.beginPath();
      ctx.moveTo(xPoints[0], yPoints[0]);
      for (let i = 1; i < xPoints.length; i++) ctx.lineTo(xPoints[i], yPoints[i]);
      ctx.closePath();

      // Hypsometric base fill
      const baseAlpha = 0.15 + reliefIntensity * 0.25;
      const landGrad = ctx.createLinearGradient(0, Math.min(...yPoints), 0, Math.max(...yPoints));
      landGrad.addColorStop(0, `rgba(184, 159, 106, ${baseAlpha * 0.7})`);
      landGrad.addColorStop(0.5, `rgba(196, 162, 101, ${baseAlpha})`);
      landGrad.addColorStop(1, `rgba(160, 140, 90, ${baseAlpha * 0.8})`);
      ctx.fillStyle = landGrad;
      ctx.fill();

      // Coastline
      ctx.strokeStyle = `rgba(196, 162, 101, ${0.3 + reliefIntensity * 0.3})`;
      ctx.lineWidth = 0.8 + reliefIntensity * 0.5;
      ctx.stroke();

      // Crosshatch fill
      ctx.save();
      ctx.clip();
      const hatchAlpha = 0.04 + reliefIntensity * 0.06;
      ctx.strokeStyle = `rgba(196, 162, 101, ${hatchAlpha})`;
      ctx.lineWidth = 0.3;
      const bbox = {
        minX: Math.min(...xPoints) - 5, maxX: Math.max(...xPoints) + 5,
        minY: Math.min(...yPoints) - 5, maxY: Math.max(...yPoints) + 5,
      };
      for (let hx = bbox.minX; hx < bbox.maxX; hx += 3 + (1 - reliefIntensity) * 3) {
        ctx.beginPath();
        ctx.moveTo(hx, bbox.minY);
        ctx.lineTo(hx + (bbox.maxY - bbox.minY) * 0.3, bbox.maxY);
        ctx.stroke();
      }
      ctx.restore();
    });

    // Mountain ranges - relief
    if (reliefIntensity > 0.05) {
      mountainRanges.forEach(range => {
        const pts = range.points.map(p => ({ x: lngToX(p.lng), y: latToY(p.lat) }));
        const visible = pts.some(p => p.x > -50 && p.x < width + 50 && p.y > -50 && p.y < height + 50);
        if (!visible) return;

        const alpha = reliefIntensity * range.intensity;
        const ridgeWidth = 3 + reliefIntensity * 8;

        // Light side (NW illumination)
        ctx.strokeStyle = `rgba(230, 200, 130, ${alpha * 0.5})`;
        ctx.lineWidth = ridgeWidth;
        ctx.lineCap = "round";
        ctx.lineJoin = "round";
        ctx.beginPath();
        pts.forEach((p, i) => {
          const offset = ridgeWidth * 0.3;
          if (i === 0) ctx.moveTo(p.x - offset, p.y - offset);
          else ctx.lineTo(p.x - offset, p.y - offset);
        });
        ctx.stroke();

        // Shadow side
        ctx.strokeStyle = `rgba(40, 30, 15, ${alpha * 0.6})`;
        ctx.lineWidth = ridgeWidth * 0.7;
        ctx.beginPath();
        pts.forEach((p, i) => {
          const offset = ridgeWidth * 0.2;
          if (i === 0) ctx.moveTo(p.x + offset, p.y + offset);
          else ctx.lineTo(p.x + offset, p.y + offset);
        });
        ctx.stroke();

        // Peak ridge line
        ctx.strokeStyle = `rgba(244, 232, 193, ${alpha * 0.7})`;
        ctx.lineWidth = 1 + reliefIntensity * 1.5;
        ctx.beginPath();
        pts.forEach((p, i) => { if (i === 0) ctx.moveTo(p.x, p.y); else ctx.lineTo(p.x, p.y); });
        ctx.stroke();

        // Peak dots at high points
        if (reliefIntensity > 0.4) {
          pts.forEach((p, i) => {
            if (i === 0 || i === pts.length - 1) return;
            ctx.fillStyle = `rgba(255, 245, 220, ${alpha * 0.6})`;
            ctx.beginPath();
            ctx.arc(p.x, p.y, 1 + reliefIntensity, 0, Math.PI * 2);
            ctx.fill();
          });
        }
      });
    }

    // Rivers
    if (reliefIntensity > 0.15) {
      rivers.forEach(river => {
        const pts = river.points.map(p => ({ x: lngToX(p.lng), y: latToY(p.lat) }));
        const visible = pts.some(p => p.x > -50 && p.x < width + 50);
        if (!visible) return;

        ctx.strokeStyle = `rgba(100, 140, 180, ${reliefIntensity * 0.25})`;
        ctx.lineWidth = 0.5 + reliefIntensity * 0.8;
        ctx.lineCap = "round";
        ctx.beginPath();
        pts.forEach((p, i) => { if (i === 0) ctx.moveTo(p.x, p.y); else ctx.lineTo(p.x, p.y); });
        ctx.stroke();
      });
    }

    // Globe curvature
    const curveGrad = ctx.createLinearGradient(0, 0, width, 0);
    curveGrad.addColorStop(0, "rgba(0, 0, 0, 0.55)");
    curveGrad.addColorStop(0.12, "rgba(0, 0, 0, 0.12)");
    curveGrad.addColorStop(0.35, "rgba(0, 0, 0, 0)");
    curveGrad.addColorStop(0.65, "rgba(0, 0, 0, 0)");
    curveGrad.addColorStop(0.88, "rgba(0, 0, 0, 0.12)");
    curveGrad.addColorStop(1, "rgba(0, 0, 0, 0.55)");
    ctx.fillStyle = curveGrad;
    ctx.fillRect(0, 0, width, height);

    const vertCurve = ctx.createLinearGradient(0, 0, 0, height);
    vertCurve.addColorStop(0, "rgba(8, 14, 26, 0.6)");
    vertCurve.addColorStop(0.1, "rgba(8, 14, 26, 0)");
    vertCurve.addColorStop(0.9, "rgba(8, 14, 26, 0)");
    vertCurve.addColorStop(1, "rgba(8, 14, 26, 0.6)");
    ctx.fillStyle = vertCurve;
    ctx.fillRect(0, 0, width, height);

    // Lamp
    const lampGrad = ctx.createRadialGradient(width / 2, -30, 0, width / 2, height / 2, width * 0.5);
    lampGrad.addColorStop(0, `rgba(212, 168, 67, ${0.06 + reliefIntensity * 0.06})`);
    lampGrad.addColorStop(0.5, "rgba(212, 168, 67, 0.02)");
    lampGrad.addColorStop(1, "rgba(0, 0, 0, 0)");
    ctx.fillStyle = lampGrad;
    ctx.fillRect(0, 0, width, height);

    // Answer marker
    if (showAnswer) {
      const ax = lngToX(answerLng);
      const ay = latToY(answerLat);

      // Glow
      const glowGrad = ctx.createRadialGradient(ax, ay, 0, ax, ay, 20);
      glowGrad.addColorStop(0, "rgba(212, 168, 67, 0.4)");
      glowGrad.addColorStop(0.5, "rgba(212, 168, 67, 0.1)");
      glowGrad.addColorStop(1, "rgba(212, 168, 67, 0)");
      ctx.fillStyle = glowGrad;
      ctx.fillRect(ax - 25, ay - 25, 50, 50);

      // Pin
      ctx.fillStyle = "#D4A843";
      ctx.beginPath();
      ctx.arc(ax, ay, 4, 0, Math.PI * 2);
      ctx.fill();
      ctx.strokeStyle = "#F4E8C1";
      ctx.lineWidth = 1.5;
      ctx.stroke();
    }

    // Guess line
    if (showGuessLine) {
      const gx = lngToX(guessLng);
      const ax = lngToX(answerLng);

      ctx.setLineDash([3, 4]);
      ctx.strokeStyle = "rgba(192, 57, 43, 0.5)";
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(gx, 0);
      ctx.lineTo(gx, height);
      ctx.stroke();
      ctx.setLineDash([]);

      // Guess pin
      ctx.fillStyle = "rgba(192, 57, 43, 0.7)";
      ctx.beginPath();
      ctx.arc(gx, height / 2, 3, 0, Math.PI * 2);
      ctx.fill();
    }

    // Paper grain
    const imageData = ctx.getImageData(0, 0, width * dpr, height * dpr);
    const d = imageData.data;
    for (let i = 0; i < d.length; i += 16) {
      const noise = (Math.random() - 0.5) * 5;
      d[i] += noise; d[i + 1] += noise; d[i + 2] += noise;
    }
    ctx.putImageData(imageData, 0, 0);

  }, [longitude, zoom, reliefIntensity, width, height, answerLng, answerLat, showAnswer, guessLng, showGuessLine, lngToX, latToY, phase]);

  return <canvas ref={canvasRef} style={{ width, height, display: "block" }} />;
}

// Easing function
function easeInOutCubic(t) {
  return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
}

export default function WhereOnEarthReveal() {
  const [scenarioIndex, setScenarioIndex] = useState(0);
  const [phase, setPhase] = useState("browsing"); // browsing | locked | flying | zoomed | result
  const [longitude, setLongitude] = useState(10);
  const [zoom, setZoom] = useState(1);
  const [reliefIntensity, setReliefIntensity] = useState(0.12);
  const [showAnswer, setShowAnswer] = useState(false);
  const [showGuessLine, setShowGuessLine] = useState(false);
  const [isDragging, setIsDragging] = useState(false);
  const [dragStart, setDragStart] = useState(0);
  const [dragLngStart, setDragLngStart] = useState(0);
  const [resultText, setResultText] = useState("");
  const [resultSubtext, setResultSubtext] = useState("");
  const animRef = useRef(null);

  const scenario = scenarios[scenarioIndex];
  const mapWidth = 380;
  const mapHeight = 260;

  const handlePointerDown = (e) => {
    if (phase !== "browsing") return;
    e.preventDefault();
    setIsDragging(true);
    setDragStart(e.clientX);
    setDragLngStart(longitude);
  };

  const handlePointerMove = (e) => {
    if (!isDragging || phase !== "browsing") return;
    const dx = e.clientX - dragStart;
    const dLng = -(dx / mapWidth) * 180;
    let newLng = dragLngStart + dLng;
    if (newLng > 180) newLng -= 360;
    if (newLng < -180) newLng += 360;
    setLongitude(newLng);
  };

  const handlePointerUp = () => setIsDragging(false);

  // Lock in guess and trigger reveal animation
  const lockIn = () => {
    if (phase !== "browsing") return;
    setPhase("locked");
    setShowGuessLine(true);

    // After brief pause, fly to answer
    setTimeout(() => {
      setPhase("flying");
      const startLng = longitude;
      const targetLng = scenario.answer.lng;
      const startZoom = 1;
      const targetZoom = 2.2;
      const startRelief = 0.12;
      const targetRelief = 0.65;
      const duration = 1800;
      const startTime = Date.now();

      // Calculate shortest rotation path
      let dLng = targetLng - startLng;
      if (dLng > 180) dLng -= 360;
      if (dLng < -180) dLng += 360;

      const animate = () => {
        const elapsed = Date.now() - startTime;
        const t = Math.min(elapsed / duration, 1);
        const e = easeInOutCubic(t);

        let newLng = startLng + dLng * e;
        if (newLng > 180) newLng -= 360;
        if (newLng < -180) newLng += 360;

        setLongitude(newLng);
        setZoom(startZoom + (targetZoom - startZoom) * e);
        setReliefIntensity(startRelief + (targetRelief - startRelief) * e);

        if (t >= 0.7 && !showAnswer) {
          setShowAnswer(true);
        }

        if (t < 1) {
          animRef.current = requestAnimationFrame(animate);
        } else {
          setPhase("zoomed");
          setShowAnswer(true);

          const resultMap = { country: "RIGHT COUNTRY", region: "RIGHT REGION", continent: "RIGHT CONTINENT" };
          setResultText(`● ${resultMap[scenario.result]}  +${scenario.points}`);
          setResultSubtext(scenario.answer.name);

          setTimeout(() => setPhase("result"), 400);
        }
      };

      animRef.current = requestAnimationFrame(animate);
    }, 600);
  };

  // Reset for next scenario
  const nextScenario = () => {
    if (animRef.current) cancelAnimationFrame(animRef.current);
    const nextIdx = (scenarioIndex + 1) % scenarios.length;
    setScenarioIndex(nextIdx);
    setPhase("browsing");
    setZoom(1);
    setReliefIntensity(0.12);
    setShowAnswer(false);
    setShowGuessLine(false);
    setResultText("");
    setResultSubtext("");
    setLongitude(10);
  };

  const formatLng = (lng) => `${Math.abs(lng).toFixed(1)}° ${lng >= 0 ? 'E' : 'W'}`;

  return (
    <div style={{
      fontFamily: "'Georgia', serif",
      background: "#080E1A",
      minHeight: "100vh",
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      color: "#E8DCC8",
    }}>
      {/* Header */}
      <div style={{ padding: "32px 24px 8px", textAlign: "center" }}>
        <div style={{
          fontSize: "10px", letterSpacing: "5px", textTransform: "uppercase", color: "#5A4F3A", marginBottom: "4px",
        }}>WHERE ON EARTH</div>
        <div style={{ fontSize: "12px", fontStyle: "italic", color: "#6A5F4A" }}>
          {phase === "browsing" ? "Drag to spin · Tap \"Lock In\" to guess" : phase === "locked" ? "Locked..." : phase === "flying" ? "Finding answer..." : ""}
        </div>
      </div>

      {/* Watch frame */}
      <div style={{
        width: "300px", height: "360px", borderRadius: "60px",
        background: "linear-gradient(145deg, #1a1a1a, #0d0d0d)",
        border: "2px solid #2a2a2a",
        display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center",
        position: "relative",
        boxShadow: "0 0 60px rgba(212, 168, 67, 0.05), inset 0 1px 0 rgba(255,255,255,0.05)",
        marginTop: "12px",
      }}>
        {/* Crown */}
        <div style={{
          position: "absolute", right: "-12px", top: "48%", transform: "translateY(-50%)",
          width: "8px", height: "32px", borderRadius: "4px",
          background: "linear-gradient(90deg, #3a3a3a, #555, #3a3a3a)",
        }} />

        {/* Screen */}
        <div style={{
          width: "252px", height: "300px", borderRadius: "44px", overflow: "hidden", background: "#080E1A",
          display: "flex", flexDirection: "column",
        }}>
          {/* Clue */}
          <div style={{
            padding: "16px 14px 8px", textAlign: "center", flexShrink: 0,
            opacity: phase === "result" ? 0.4 : 1, transition: "opacity 0.5s",
          }}>
            <div style={{
              fontSize: "11px", fontStyle: "italic", color: "#E8DCC8", lineHeight: 1.5,
            }}>{scenario.clue}</div>
          </div>

          {/* Map */}
          <div
            onPointerDown={handlePointerDown}
            onPointerMove={handlePointerMove}
            onPointerUp={handlePointerUp}
            onPointerLeave={handlePointerUp}
            style={{
              flex: 1, position: "relative", overflow: "hidden",
              cursor: phase === "browsing" ? (isDragging ? "grabbing" : "grab") : "default",
              touchAction: "none",
            }}
          >
            <div style={{ position: "absolute", top: "50%", left: "50%", transform: "translate(-50%, -50%)" }}>
              <WorldMap
                longitude={longitude} zoom={zoom} reliefIntensity={reliefIntensity}
                width={mapWidth} height={mapHeight}
                answerLng={scenario.answer.lng} answerLat={scenario.answer.lat}
                showAnswer={showAnswer} guessLng={scenario.playerGuess.lng}
                showGuessLine={showGuessLine} phase={phase}
              />
            </div>

            {/* Fixed center pin (browsing only) */}
            {phase === "browsing" && (
              <>
                <div style={{
                  position: "absolute", top: 0, bottom: 0, left: "50%", transform: "translateX(-50%)",
                  width: "2px", background: "linear-gradient(180deg, rgba(212,168,67,0), rgba(212,168,67,0.6), rgba(212,168,67,0))",
                  pointerEvents: "none", zIndex: 10,
                }} />
                <div style={{
                  position: "absolute", top: "50%", left: "50%", transform: "translate(-50%,-50%)",
                  width: "8px", height: "8px", borderRadius: "50%", background: "#D4A843",
                  boxShadow: "0 0 12px rgba(212,168,67,0.5)", pointerEvents: "none", zIndex: 10,
                }} />
              </>
            )}

            {/* Result overlay */}
            {phase === "result" && (
              <div style={{
                position: "absolute", bottom: "8px", left: "50%", transform: "translateX(-50%)",
                textAlign: "center", zIndex: 20,
                animation: "fadeUp 0.5s ease-out",
              }}>
                <div style={{
                  background: "rgba(8, 14, 26, 0.85)", backdropFilter: "blur(8px)",
                  borderRadius: "12px", padding: "8px 16px",
                  border: "1px solid rgba(212, 168, 67, 0.2)",
                }}>
                  <div style={{
                    fontFamily: "monospace", fontSize: "11px", letterSpacing: "1px",
                    color: scenario.result === "country" ? "#D4A843" : scenario.result === "region" ? "#B89F6A" : "#8A7D65",
                    fontWeight: 700,
                  }}>{resultText}</div>
                  <div style={{
                    fontSize: "13px", color: "#E8DCC8", marginTop: "4px", fontStyle: "italic",
                  }}>{resultSubtext}</div>
                </div>
              </div>
            )}
          </div>

          {/* Coordinate + controls */}
          <div style={{
            padding: "6px 14px", textAlign: "center", flexShrink: 0,
            borderTop: "1px solid rgba(212, 168, 67, 0.08)",
          }}>
            {phase === "browsing" ? (
              <div style={{ fontFamily: "monospace", fontSize: "11px", color: "#D4A843", letterSpacing: "1px" }}>
                {formatLng(longitude)}
              </div>
            ) : (
              <div style={{ fontFamily: "monospace", fontSize: "10px", color: "#5A4F3A", letterSpacing: "1px" }}>
                {formatLng(scenario.answer.lng)}
              </div>
            )}
          </div>

          {/* Progress dots */}
          <div style={{
            display: "flex", justifyContent: "center", gap: "5px", padding: "0 0 12px", flexShrink: 0,
          }}>
            {scenarios.map((_, n) => (
              <div key={n} style={{
                width: "4px", height: "4px", borderRadius: "50%",
                background: n <= scenarioIndex ? "#D4A843" : "#2A3A5C",
                opacity: n <= scenarioIndex ? 0.9 : 0.3,
              }} />
            ))}
          </div>
        </div>
      </div>

      {/* Action button */}
      <div style={{ padding: "20px" }}>
        {phase === "browsing" && (
          <button onClick={lockIn} style={{
            background: "rgba(212, 168, 67, 0.12)", border: "1px solid rgba(212, 168, 67, 0.3)",
            color: "#D4A843", padding: "10px 32px", borderRadius: "24px", cursor: "pointer",
            fontFamily: "'Georgia', serif", fontSize: "13px", letterSpacing: "2px",
            transition: "all 0.2s",
          }}
            onMouseOver={e => { e.target.style.background = "rgba(212, 168, 67, 0.2)"; }}
            onMouseOut={e => { e.target.style.background = "rgba(212, 168, 67, 0.12)"; }}
          >LOCK IN</button>
        )}
        {(phase === "result" || phase === "zoomed") && (
          <button onClick={nextScenario} style={{
            background: "rgba(212, 168, 67, 0.12)", border: "1px solid rgba(212, 168, 67, 0.3)",
            color: "#D4A843", padding: "10px 32px", borderRadius: "24px", cursor: "pointer",
            fontFamily: "'Georgia', serif", fontSize: "13px", letterSpacing: "2px",
          }}
            onMouseOver={e => { e.target.style.background = "rgba(212, 168, 67, 0.2)"; }}
            onMouseOut={e => { e.target.style.background = "rgba(212, 168, 67, 0.12)"; }}
          >NEXT CLUE →</button>
        )}
      </div>

      {/* Annotation */}
      <div style={{
        maxWidth: "380px", padding: "0 24px 40px", textAlign: "center",
      }}>
        <div style={{
          fontSize: "10px", letterSpacing: "4px", textTransform: "uppercase", color: "#5A4F3A", marginBottom: "12px",
        }}>THE REVEAL SEQUENCE</div>
        <div style={{
          fontSize: "12px", color: "#6A5F4A", lineHeight: 1.8,
        }}>
          Lock in → brief pause (tension builds) → globe rotates to answer with simultaneous zoom
          → relief and terrain detail emerge as you get closer → golden pin drops on the answer
          → your guess line appears as a dashed red meridian → score fades in at bottom.
          The whole sequence takes ~2.5 seconds. On the watch, the haptic fires at the moment the pin drops.
        </div>

        <div style={{
          display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: "8px", marginTop: "16px",
        }}>
          {[
            { time: "0–0.6s", label: "Tension", detail: "Guess line appears. Globe pauses." },
            { time: "0.6–2.4s", label: "Flight", detail: "Globe rotates + zooms. Relief intensifies from 12% to 65%." },
            { time: "2.4–3s", label: "Landing", detail: "Gold pin drops. Score appears. Haptic fires." },
          ].map(step => (
            <div key={step.time} style={{
              background: "rgba(212, 168, 67, 0.04)", border: "1px solid rgba(212, 168, 67, 0.08)",
              borderRadius: "8px", padding: "10px 8px", textAlign: "left",
            }}>
              <div style={{ fontFamily: "monospace", fontSize: "9px", color: "#D4A843", marginBottom: "2px" }}>{step.time}</div>
              <div style={{ fontSize: "11px", fontWeight: 700, color: "#B89F6A", marginBottom: "2px" }}>{step.label}</div>
              <div style={{ fontSize: "9px", color: "#5A4F3A", lineHeight: 1.4 }}>{step.detail}</div>
            </div>
          ))}
        </div>
      </div>

      <style>{`
        @keyframes fadeUp {
          from { opacity: 0; transform: translateX(-50%) translateY(10px); }
          to { opacity: 1; transform: translateX(-50%) translateY(0); }
        }
      `}</style>
    </div>
  );
}
