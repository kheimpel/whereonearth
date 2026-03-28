import { useState, useRef, useEffect, useCallback } from "react";

// Simplified continent outlines as longitude-based path data
// Each continent is defined by polygonal regions with lat/lng coordinates
const continentData = [
  // Africa
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
  // Europe
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
  // Asia
  {
    name: "Asia", color: "#B89F6A", points: [
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
  // North America
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
  // South America
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
  // Australia
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

// Simplified graticule lines
const graticuleLines = {
  lats: [-60, -40, -20, 0, 20, 40, 60],
  lngs: [-180, -150, -120, -90, -60, -30, 0, 30, 60, 90, 120, 150, 180],
};

function WorldMapStrip({ longitude, width, height }) {
  const canvasRef = useRef(null);
  const stripHeight = height;
  const stripWidth = width;

  // Map projection: longitude to x, latitude to y
  // With wrap-around for seamless scrolling
  const lngToX = useCallback((lng) => {
    let adjusted = ((lng - longitude + 540) % 360) - 180;
    return (adjusted / 360) * stripWidth + stripWidth / 2;
  }, [longitude, stripWidth]);

  const latToY = useCallback((lat) => {
    // Mercator-ish projection, clamped
    const maxLat = 78;
    const clampedLat = Math.max(-maxLat, Math.min(maxLat, lat));
    const rad = (clampedLat * Math.PI) / 180;
    const mercY = Math.log(Math.tan(Math.PI / 4 + rad / 2));
    const maxMercY = Math.log(Math.tan(Math.PI / 4 + (maxLat * Math.PI) / 180 / 2));
    return stripHeight / 2 - (mercY / maxMercY) * (stripHeight / 2) * 0.85;
  }, [stripHeight]);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    const dpr = window.devicePixelRatio || 2;
    canvas.width = stripWidth * dpr;
    canvas.height = stripHeight * dpr;
    ctx.scale(dpr, dpr);

    // Ocean background - deep dark navy
    const oceanGrad = ctx.createRadialGradient(
      stripWidth / 2, stripHeight / 2, 0,
      stripWidth / 2, stripHeight / 2, stripWidth * 0.7
    );
    oceanGrad.addColorStop(0, "#0F1A2E");
    oceanGrad.addColorStop(1, "#080E1A");
    ctx.fillStyle = oceanGrad;
    ctx.fillRect(0, 0, stripWidth, stripHeight);

    // Subtle ocean texture - fine horizontal lines like aged paper
    ctx.strokeStyle = "rgba(180, 165, 130, 0.015)";
    ctx.lineWidth = 0.5;
    for (let y = 0; y < stripHeight; y += 3) {
      ctx.beginPath();
      ctx.moveTo(0, y + Math.sin(y * 0.1) * 0.5);
      ctx.lineTo(stripWidth, y + Math.sin(y * 0.1 + 2) * 0.5);
      ctx.stroke();
    }

    // Graticule lines - atlas grid
    ctx.lineWidth = 0.5;

    // Latitude lines
    graticuleLines.lats.forEach(lat => {
      const y = latToY(lat);
      ctx.strokeStyle = lat === 0
        ? "rgba(212, 168, 67, 0.18)"
        : "rgba(180, 165, 130, 0.06)";
      ctx.lineWidth = lat === 0 ? 0.8 : 0.4;
      ctx.beginPath();
      ctx.moveTo(0, y);
      ctx.lineTo(stripWidth, y);
      ctx.stroke();

      // Lat labels
      if (Math.abs(lat) > 0) {
        ctx.font = "7px Georgia";
        ctx.fillStyle = "rgba(180, 165, 130, 0.15)";
        ctx.textAlign = "left";
        ctx.fillText(`${Math.abs(lat)}°${lat > 0 ? 'N' : 'S'}`, 4, y - 2);
      }
    });

    // Longitude lines
    graticuleLines.lngs.forEach(lng => {
      const x = lngToX(lng);
      if (x < -50 || x > stripWidth + 50) return;
      ctx.strokeStyle = lng === 0
        ? "rgba(212, 168, 67, 0.18)"
        : "rgba(180, 165, 130, 0.06)";
      ctx.lineWidth = lng === 0 ? 0.8 : 0.4;
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, stripHeight);
      ctx.stroke();
    });

    // Draw continents
    continentData.forEach(continent => {
      if (continent.points.length < 3) return;

      // Check if continent is visible (any point on screen)
      const xPoints = continent.points.map(p => lngToX(p.lng));
      const visiblePoints = xPoints.filter(x => x > -100 && x < stripWidth + 100);
      if (visiblePoints.length === 0) return;

      // Check for wrap-around issues (points jumping across screen)
      let hasWrap = false;
      for (let i = 1; i < xPoints.length; i++) {
        if (Math.abs(xPoints[i] - xPoints[i - 1]) > stripWidth * 0.5) {
          hasWrap = true;
          break;
        }
      }
      if (hasWrap) return; // Skip wrapped continents for cleaner rendering

      ctx.beginPath();
      const firstX = lngToX(continent.points[0].lng);
      const firstY = latToY(continent.points[0].lat);
      ctx.moveTo(firstX, firstY);

      for (let i = 1; i < continent.points.length; i++) {
        const x = lngToX(continent.points[i].lng);
        const y = latToY(continent.points[i].lat);
        ctx.lineTo(x, y);
      }
      ctx.closePath();

      // Fill with atlas-style warm tones
      const centerX = xPoints.reduce((a, b) => a + b, 0) / xPoints.length;

      // Subtle gradient fill - like aged parchment land masses
      const landGrad = ctx.createRadialGradient(
        centerX, stripHeight / 2, 0,
        centerX, stripHeight / 2, 120
      );
      landGrad.addColorStop(0, `${continent.color}35`);
      landGrad.addColorStop(1, `${continent.color}20`);
      ctx.fillStyle = landGrad;
      ctx.fill();

      // Coastline - the key atlas detail
      ctx.strokeStyle = `${continent.color}55`;
      ctx.lineWidth = 1;
      ctx.stroke();

      // Inner glow / hatch effect for depth
      ctx.strokeStyle = `${continent.color}12`;
      ctx.lineWidth = 0.3;
      const bbox = {
        minX: Math.min(...xPoints),
        maxX: Math.max(...xPoints),
        minY: Math.min(...continent.points.map(p => latToY(p.lat))),
        maxY: Math.max(...continent.points.map(p => latToY(p.lat))),
      };

      ctx.save();
      ctx.clip();
      for (let hx = bbox.minX; hx < bbox.maxX; hx += 4) {
        ctx.beginPath();
        ctx.moveTo(hx, bbox.minY);
        ctx.lineTo(hx + 8, bbox.maxY);
        ctx.stroke();
      }
      ctx.restore();
    });

    // Globe curvature effect - darken edges for 3D feel
    const curveGrad = ctx.createLinearGradient(0, 0, stripWidth, 0);
    curveGrad.addColorStop(0, "rgba(0, 0, 0, 0.6)");
    curveGrad.addColorStop(0.15, "rgba(0, 0, 0, 0.15)");
    curveGrad.addColorStop(0.35, "rgba(0, 0, 0, 0)");
    curveGrad.addColorStop(0.65, "rgba(0, 0, 0, 0)");
    curveGrad.addColorStop(0.85, "rgba(0, 0, 0, 0.15)");
    curveGrad.addColorStop(1, "rgba(0, 0, 0, 0.6)");
    ctx.fillStyle = curveGrad;
    ctx.fillRect(0, 0, stripWidth, stripHeight);

    // Top and bottom curvature (north/south pole fade)
    const vertCurve = ctx.createLinearGradient(0, 0, 0, stripHeight);
    vertCurve.addColorStop(0, "rgba(8, 14, 26, 0.7)");
    vertCurve.addColorStop(0.12, "rgba(8, 14, 26, 0)");
    vertCurve.addColorStop(0.88, "rgba(8, 14, 26, 0)");
    vertCurve.addColorStop(1, "rgba(8, 14, 26, 0.7)");
    ctx.fillStyle = vertCurve;
    ctx.fillRect(0, 0, stripWidth, stripHeight);

    // Lamp light effect - warm spotlight from above center
    const lampGrad = ctx.createRadialGradient(
      stripWidth / 2, -20, 0,
      stripWidth / 2, stripHeight / 2, stripWidth * 0.5
    );
    lampGrad.addColorStop(0, "rgba(212, 168, 67, 0.08)");
    lampGrad.addColorStop(0.5, "rgba(212, 168, 67, 0.03)");
    lampGrad.addColorStop(1, "rgba(0, 0, 0, 0)");
    ctx.fillStyle = lampGrad;
    ctx.fillRect(0, 0, stripWidth, stripHeight);

    // Vignette - aged atlas edge feel
    const vignetteGrad = ctx.createRadialGradient(
      stripWidth / 2, stripHeight / 2, stripWidth * 0.3,
      stripWidth / 2, stripHeight / 2, stripWidth * 0.7
    );
    vignetteGrad.addColorStop(0, "rgba(0, 0, 0, 0)");
    vignetteGrad.addColorStop(1, "rgba(0, 0, 0, 0.25)");
    ctx.fillStyle = vignetteGrad;
    ctx.fillRect(0, 0, stripWidth, stripHeight);

    // Subtle paper grain
    const imageData = ctx.getImageData(0, 0, stripWidth * dpr, stripHeight * dpr);
    const data = imageData.data;
    for (let i = 0; i < data.length; i += 4) {
      const noise = (Math.random() - 0.5) * 6;
      data[i] += noise;
      data[i + 1] += noise;
      data[i + 2] += noise;
    }
    ctx.putImageData(imageData, 0, 0);

  }, [longitude, stripWidth, stripHeight, lngToX, latToY]);

  return (
    <canvas
      ref={canvasRef}
      style={{
        width: stripWidth,
        height: stripHeight,
        display: "block",
      }}
    />
  );
}

export default function WhereOnEarthGlobe() {
  const [longitude, setLongitude] = useState(10); // Start centered on Europe/Africa
  const [isDragging, setIsDragging] = useState(false);
  const [dragStart, setDragStart] = useState(0);
  const [dragLngStart, setDragLngStart] = useState(0);
  const [velocity, setVelocity] = useState(0);
  const [lastDragX, setLastDragX] = useState(0);
  const [lastDragTime, setLastDragTime] = useState(0);
  const animRef = useRef(null);
  const containerRef = useRef(null);

  const mapWidth = 380;
  const mapHeight = 240;

  // Inertia animation
  useEffect(() => {
    if (isDragging || Math.abs(velocity) < 0.1) return;

    const animate = () => {
      setLongitude(prev => {
        let next = prev + velocity;
        if (next > 180) next -= 360;
        if (next < -180) next += 360;
        return next;
      });
      setVelocity(prev => prev * 0.95);
      if (Math.abs(velocity) > 0.1) {
        animRef.current = requestAnimationFrame(animate);
      }
    };
    animRef.current = requestAnimationFrame(animate);

    return () => {
      if (animRef.current) cancelAnimationFrame(animRef.current);
    };
  }, [isDragging, velocity]);

  const handlePointerDown = (e) => {
    e.preventDefault();
    setIsDragging(true);
    setDragStart(e.clientX);
    setDragLngStart(longitude);
    setVelocity(0);
    setLastDragX(e.clientX);
    setLastDragTime(Date.now());
    if (animRef.current) cancelAnimationFrame(animRef.current);
  };

  const handlePointerMove = (e) => {
    if (!isDragging) return;
    e.preventDefault();
    const dx = e.clientX - dragStart;
    const dLng = -(dx / mapWidth) * 180;
    let newLng = dragLngStart + dLng;
    if (newLng > 180) newLng -= 360;
    if (newLng < -180) newLng += 360;
    setLongitude(newLng);

    // Track velocity
    const now = Date.now();
    const dt = now - lastDragTime;
    if (dt > 0) {
      const vx = -(e.clientX - lastDragX) / dt;
      setVelocity(vx * 8);
    }
    setLastDragX(e.clientX);
    setLastDragTime(now);
  };

  const handlePointerUp = () => {
    setIsDragging(false);
  };

  // Format longitude display
  const formatLng = (lng) => {
    const abs = Math.abs(lng).toFixed(1);
    return `${abs}° ${lng >= 0 ? 'E' : 'W'}`;
  };

  // Determine current region
  const getRegion = (lng) => {
    if (lng >= -30 && lng < 45) return "Europe / Africa";
    if (lng >= 45 && lng < 100) return "Middle East / Central Asia";
    if (lng >= 100 && lng <= 180) return "East Asia / Oceania";
    if (lng >= -180 && lng < -120) return "Pacific / Alaska";
    if (lng >= -120 && lng < -30) return "The Americas";
    return "";
  };

  return (
    <div style={{
      fontFamily: "'Georgia', 'Times New Roman', serif",
      background: "#080E1A",
      minHeight: "100vh",
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      color: "#E8DCC8",
      overflow: "hidden",
    }}>
      {/* Title */}
      <div style={{
        padding: "40px 24px 12px",
        textAlign: "center",
      }}>
        <div style={{
          fontSize: "10px",
          letterSpacing: "5px",
          textTransform: "uppercase",
          color: "#5A4F3A",
          marginBottom: "8px",
        }}>WHERE ON EARTH</div>
        <div style={{
          fontSize: "14px",
          fontStyle: "italic",
          color: "#8A7D65",
          marginBottom: "4px",
        }}>Drag to spin the globe</div>
      </div>

      {/* Watch Frame */}
      <div style={{
        width: "280px",
        height: "340px",
        borderRadius: "56px",
        background: "linear-gradient(145deg, #1a1a1a, #0d0d0d)",
        border: "2px solid #2a2a2a",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        position: "relative",
        boxShadow: "0 0 60px rgba(212, 168, 67, 0.05), inset 0 1px 0 rgba(255,255,255,0.05)",
        marginTop: "16px",
      }}>
        {/* Crown */}
        <div style={{
          position: "absolute",
          right: "-12px",
          top: "48%",
          transform: "translateY(-50%)",
          width: "8px",
          height: "32px",
          borderRadius: "4px",
          background: "linear-gradient(90deg, #3a3a3a, #555, #3a3a3a)",
          boxShadow: "1px 0 4px rgba(0,0,0,0.5)",
        }} />
        <div style={{
          position: "absolute",
          right: "-10px",
          top: "34%",
          width: "5px",
          height: "12px",
          borderRadius: "2px",
          background: "#3a3a3a",
        }} />

        {/* Screen area */}
        <div style={{
          width: "232px",
          height: "280px",
          borderRadius: "40px",
          overflow: "hidden",
          background: "#080E1A",
          display: "flex",
          flexDirection: "column",
        }}>
          {/* Clue area */}
          <div style={{
            padding: "20px 16px 12px",
            textAlign: "center",
            flexShrink: 0,
          }}>
            <div style={{
              fontSize: "12px",
              fontStyle: "italic",
              color: "#E8DCC8",
              lineHeight: 1.5,
              opacity: 0.9,
            }}>
              "Trains arrive within 7 seconds of schedule on average."
            </div>
          </div>

          {/* Map strip - the star of the show */}
          <div
            ref={containerRef}
            onPointerDown={handlePointerDown}
            onPointerMove={handlePointerMove}
            onPointerUp={handlePointerUp}
            onPointerLeave={handlePointerUp}
            style={{
              flex: 1,
              cursor: isDragging ? "grabbing" : "grab",
              touchAction: "none",
              position: "relative",
              overflow: "hidden",
            }}
          >
            {/* The map */}
            <div style={{
              position: "absolute",
              top: 0,
              left: "50%",
              transform: "translateX(-50%)",
            }}>
              <WorldMapStrip
                longitude={longitude}
                width={mapWidth}
                height={mapHeight}
              />
            </div>

            {/* Fixed pin / crosshair at center */}
            <div style={{
              position: "absolute",
              top: 0,
              bottom: 0,
              left: "50%",
              transform: "translateX(-50%)",
              width: "2px",
              background: "linear-gradient(180deg, rgba(212, 168, 67, 0), rgba(212, 168, 67, 0.7), rgba(212, 168, 67, 0))",
              pointerEvents: "none",
              zIndex: 10,
            }} />

            {/* Pin head */}
            <div style={{
              position: "absolute",
              top: "50%",
              left: "50%",
              transform: "translate(-50%, -50%)",
              width: "8px",
              height: "8px",
              borderRadius: "50%",
              background: "#D4A843",
              boxShadow: "0 0 12px rgba(212, 168, 67, 0.5), 0 0 4px rgba(212, 168, 67, 0.8)",
              pointerEvents: "none",
              zIndex: 10,
            }} />

            {/* Compass rose hint */}
            <div style={{
              position: "absolute",
              top: "6px",
              left: "50%",
              transform: "translateX(-50%)",
              fontSize: "7px",
              letterSpacing: "2px",
              color: "rgba(212, 168, 67, 0.3)",
              pointerEvents: "none",
              zIndex: 10,
            }}>▼</div>
          </div>

          {/* Coordinate readout */}
          <div style={{
            padding: "8px 16px 6px",
            textAlign: "center",
            flexShrink: 0,
            borderTop: "1px solid rgba(212, 168, 67, 0.1)",
          }}>
            <div style={{
              fontFamily: "'Courier New', monospace",
              fontSize: "12px",
              color: "#D4A843",
              letterSpacing: "1px",
            }}>
              {formatLng(longitude)}
            </div>
            <div style={{
              fontSize: "8px",
              letterSpacing: "2px",
              color: "#5A4F3A",
              marginTop: "2px",
              textTransform: "uppercase",
            }}>{getRegion(longitude)}</div>
          </div>

          {/* Progress dots */}
          <div style={{
            display: "flex",
            justifyContent: "center",
            gap: "5px",
            padding: "0 0 14px",
            flexShrink: 0,
          }}>
            {[1, 2, 3, 4, 5].map(n => (
              <div key={n} style={{
                width: "4px",
                height: "4px",
                borderRadius: "50%",
                background: n <= 3 ? "#D4A843" : "#2A3A5C",
                opacity: n <= 3 ? 0.9 : 0.3,
                transition: "all 0.3s",
              }} />
            ))}
          </div>
        </div>
      </div>

      {/* Explanation panel below watch */}
      <div style={{
        maxWidth: "380px",
        padding: "32px 24px",
        textAlign: "center",
      }}>
        <div style={{
          fontSize: "10px",
          letterSpacing: "4px",
          textTransform: "uppercase",
          color: "#5A4F3A",
          marginBottom: "16px",
        }}>HOW IT FEELS</div>

        <div style={{
          fontSize: "13px",
          color: "#8A7D65",
          lineHeight: 1.8,
          marginBottom: "24px",
        }}>
          The globe rotates under a fixed pin as you turn the Digital Crown.
          Continents emerge from darkness like landmasses on an aged chart —
          warm parchment tones on deep navy, with hand-drawn hatching for depth.
          The edges darken to simulate the curvature of a physical globe,
          and a warm lamp light pools at the center.
        </div>

        <div style={{
          display: "grid",
          gridTemplateColumns: "1fr 1fr",
          gap: "12px",
          textAlign: "left",
        }}>
          {[
            { label: "Globe feel", detail: "Edge darkening creates a curved surface illusion. The map isn't flat — it's a sphere viewed through a window." },
            { label: "Atlas feel", detail: "Crosshatch fills inside continents. Fine graticule grid with lat/lng labels. Coastlines drawn, not filled solid." },
            { label: "Lamp light", detail: "Radial warm glow from above center. Parchment-colored continents catch the light. Navy ocean stays deep." },
            { label: "Seamless spin", detail: "Wraps at ±180°. Momentum and damping from Crown rotation. The earth never stops — it decelerates like a real globe." },
          ].map(item => (
            <div key={item.label} style={{
              background: "rgba(212, 168, 67, 0.04)",
              border: "1px solid rgba(212, 168, 67, 0.08)",
              borderRadius: "8px",
              padding: "12px",
            }}>
              <div style={{
                fontSize: "11px",
                fontWeight: 700,
                color: "#D4A843",
                marginBottom: "4px",
              }}>{item.label}</div>
              <div style={{
                fontSize: "10px",
                color: "#6A5F4A",
                lineHeight: 1.5,
              }}>{item.detail}</div>
            </div>
          ))}
        </div>

        <div style={{
          marginTop: "24px",
          padding: "16px",
          background: "rgba(212, 168, 67, 0.04)",
          border: "1px solid rgba(212, 168, 67, 0.08)",
          borderRadius: "8px",
        }}>
          <div style={{
            fontSize: "10px",
            letterSpacing: "3px",
            textTransform: "uppercase",
            color: "#5A4F3A",
            marginBottom: "8px",
          }}>ON REAL WATCH</div>
          <div style={{
            fontSize: "11px",
            color: "#8A7D65",
            lineHeight: 1.6,
          }}>
            Crown rotation replaces drag. Each detent click moves ~3° of longitude
            with a subtle haptic tick. The momentum and damping transfer directly —
            fast spins coast across oceans, slow turns inch between countries.
          </div>
        </div>
      </div>
    </div>
  );
}
