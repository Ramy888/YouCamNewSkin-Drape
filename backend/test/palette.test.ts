import { describe, expect, it } from "vitest";
import fixture from "../public/persona/color_tones.json";
import { buildPalette, contrastOf, deltaE, hexToLab, undertoneOf, verdictFor } from "../src/palette";

const reading = fixture.data.results.color;

describe("hexToLab", () => {
  it("maps white and black to the lightness extremes", () => {
    expect(hexToLab("#ffffff")[0]).toBeCloseTo(100, 0);
    expect(hexToLab("#000000")[0]).toBeCloseTo(0, 0);
  });
  it("rejects anything that is not a 6-digit hex colour", () => {
    expect(() => hexToLab("#fff")).toThrow(/invalid hex/);
    expect(() => hexToLab("red")).toThrow(/invalid hex/);
  });
});

describe("recorded Color Tones response (persona fixture)", () => {
  it("reads the persona as warm with a skin hue above the warm threshold", () => {
    const { undertone, hue } = undertoneOf(reading.skin_color);
    expect(undertone).toBe("warm");
    expect(hue).toBeGreaterThan(58);
  });
  it("uses hex lightness, not the hair name, for contrast", () => {
    // The API named this blonde hair "Auburn"; contrast must come from the hex values.
    expect(contrastOf(reading)).toBe("high");
  });
  it("builds a gold-metal warm palette that includes emerald", () => {
    const p = buildPalette(reading);
    expect(p.metal).toBe("gold");
    expect(p.suits.map((s) => s.id)).toContain("emerald");
    expect(p.rulesVersion).toMatch(/^\d{4}-\d{2}-\d{2}\./);
  });
});

describe("undertone extremes", () => {
  it("reads a pink-leaning skin as cool", () => {
    expect(undertoneOf("#e0b4b4").undertone).toBe("cool");
  });
  it("reads a golden skin as warm", () => {
    expect(undertoneOf("#c69c6d").undertone).toBe("warm");
  });
});

describe("override", () => {
  it("moves warm one step cooler to neutral, and cannot go past the ends", () => {
    expect(buildPalette(reading, "cooler").undertone).toBe("neutral");
    expect(buildPalette(reading, "warmer").undertone).toBe("warm");
  });
});

describe("contrast", () => {
  it("is low when hair and eyes are close to the skin lightness", () => {
    expect(contrastOf({ skin_color: "#c8a68c", hair_color: "#b89478", eye_color: "#a8876c" })).toBe("low");
  });
  it("falls back to medium when no hair or eye colour is returned", () => {
    expect(contrastOf({ skin_color: "#c8a68c", hair_color: null })).toBe("medium");
  });
  it("adds jet black to avoid only for low contrast", () => {
    const low = buildPalette({ skin_color: "#c8a68c", hair_color: "#b89478", eye_color: "#a8876c" });
    expect(low.avoid.map((s) => s.id)).toContain("black");
    expect(buildPalette(reading).avoid.map((s) => s.id)).not.toContain("black");
  });
});

describe("verdictFor", () => {
  const warm = buildPalette(reading);
  it("calls the gate-test emerald abaya 'yours' for a warm reading", () => {
    expect(verdictFor(warm, "#1f7a55").verdict).toBe("yours");
  });
  it("calls an icy pink 'avoid' for a warm reading", () => {
    const v = verdictFor(warm, "#f2c8d8");
    expect(v.verdict).toBe("avoid");
    expect(v.closest.id).toBe("icy-pink");
  });
  it("returns neutral for a colour far from every swatch", () => {
    expect(verdictFor(warm, "#7a00ff").verdict).toBe("neutral");
  });
  it("reports how close the garment is to its nearest swatch", () => {
    expect(verdictFor(warm, "#1f7a55").distance).toBe(0);
    expect(verdictFor(warm, "#1c1c1e").distance).toBeGreaterThan(0);
  });
  it("delta-E is zero for identical colours", () => {
    expect(deltaE("#1f7a55", "#1f7a55")).toBe(0);
  });
});
