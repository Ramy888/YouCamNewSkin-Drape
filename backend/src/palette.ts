// Palette engine: Facial Color Tones hex values -> undertone + contrast -> palette -> garment verdicts.
// Pure functions, no I/O. Thresholds live in palette-rules.json so they can change without code changes.
//
//   skin/hair/eye hex ──▶ CIELAB ──▶ undertone (skin hue angle) ─┐
//                                 └▶ contrast (lightness gaps) ──┴▶ palette ──▶ verdict(garment hex)
import rules from "./palette-rules.json";

export type Undertone = "warm" | "neutral" | "cool";
export type Contrast = "low" | "medium" | "high";
export type Verdict = "yours" | "neutral" | "avoid";

export interface Swatch { id: string; name: string; hex: string }
export interface ColorReading {
  skin_color: string;
  hair_color?: string | null;
  eye_color?: string | null;
}
export interface Palette {
  rulesVersion: string;
  undertone: Undertone;
  contrast: Contrast;
  skinHue: number;
  metal: string;
  lip: { name: string; hex: string };
  suits: Swatch[];
  avoid: Swatch[];
}

const HEX = /^#?([0-9a-f]{6})$/i;

export function hexToLab(hex: string): [number, number, number] {
  const m = HEX.exec(hex.trim());
  if (!m) throw new Error(`invalid hex colour: ${hex}`);
  const n = parseInt(m[1], 16);
  const lin = (c: number) => {
    const v = c / 255;
    return v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4;
  };
  const r = lin((n >> 16) & 255), g = lin((n >> 8) & 255), b = lin(n & 255);
  const x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047;
  const y = 0.2126 * r + 0.7152 * g + 0.0722 * b;
  const z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883;
  const f = (t: number) => (t > 0.008856 ? Math.cbrt(t) : 7.787 * t + 16 / 116);
  return [116 * f(y) - 16, 500 * (f(x) - f(y)), 200 * (f(y) - f(z))];
}

export function deltaE(a: string, b: string): number {
  const [l1, a1, b1] = hexToLab(a);
  const [l2, a2, b2] = hexToLab(b);
  return Math.hypot(l1 - l2, a1 - a2, b1 - b2);
}

export function undertoneOf(skinHex: string): { undertone: Undertone; hue: number } {
  const [, a, b] = hexToLab(skinHex);
  const hue = (Math.atan2(b, a) * 180) / Math.PI;
  if (hue >= rules.undertone.warmMinHue) return { undertone: "warm", hue };
  if (hue <= rules.undertone.coolMaxHue) return { undertone: "cool", hue };
  return { undertone: "neutral", hue };
}

export function contrastOf(reading: ColorReading): Contrast {
  const skinL = hexToLab(reading.skin_color)[0];
  const gaps = [reading.hair_color, reading.eye_color]
    .filter((h): h is string => typeof h === "string" && HEX.test(h))
    .map((h) => Math.abs(skinL - hexToLab(h)[0]));
  if (gaps.length === 0) return "medium";
  const gap = Math.max(...gaps);
  if (gap >= rules.contrast.highMin) return "high";
  if (gap <= rules.contrast.lowMax) return "low";
  return "medium";
}

export function shiftUndertone(u: Undertone, override?: "warmer" | "cooler"): Undertone {
  if (!override) return u;
  const order = rules.shift.order as Undertone[];
  const i = order.indexOf(u) + (override === "warmer" ? 1 : -1);
  return order[Math.max(0, Math.min(order.length - 1, i))];
}

export function buildPalette(reading: ColorReading, override?: "warmer" | "cooler"): Palette {
  const { undertone: measured, hue } = undertoneOf(reading.skin_color);
  const undertone = shiftUndertone(measured, override);
  const contrast = contrastOf(reading);
  const base = rules.palettes[undertone];
  const suits: Swatch[] = [...base.suits];
  const avoid: Swatch[] = [...base.avoid];
  if (contrast === "high") suits.push(...rules.highContrastSuits);
  if (contrast === "low") avoid.push(...rules.lowContrastAvoid);
  return {
    rulesVersion: rules.version,
    undertone,
    contrast,
    skinHue: Math.round(hue * 10) / 10,
    metal: base.metal,
    lip: base.lip,
    suits,
    avoid,
  };
}

export function verdictFor(palette: Palette, garmentHex: string): { verdict: Verdict; closest: Swatch; distance: number } {
  const nearest = (list: Swatch[]) =>
    list
      .map((s) => ({ s, d: deltaE(s.hex, garmentHex) }))
      .sort((x, y) => x.d - y.d)[0];
  const suit = nearest(palette.suits);
  const bad = palette.avoid.length ? nearest(palette.avoid) : undefined;
  const round = (d: number) => Math.round(d * 10) / 10;
  if (bad && bad.d <= rules.verdict.avoidMax && bad.d < suit.d) return { verdict: "avoid", closest: bad.s, distance: round(bad.d) };
  if (suit.d <= rules.verdict.yoursMax) return { verdict: "yours", closest: suit.s, distance: round(suit.d) };
  return { verdict: "neutral", closest: suit.s, distance: round(suit.d) };
}
