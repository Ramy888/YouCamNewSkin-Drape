import { describe, expect, it } from "vitest";
import { FABRIC_TEMPLATES, noColourwaySuits, suggestFabric } from "../src/fabric";
import { buildPalette, verdictFor } from "../src/palette";
import { PERSONA_READING } from "../src/youcam";

const warm = buildPalette(PERSONA_READING);
const cool = buildPalette({ skin_color: "#e8c4c8", hair_color: "#2a2020", eye_color: "#3a4a6a" });

describe("see it in your colour", () => {
  it("the sample person (warm) gets Sea Green Silk, close to her Deep teal", () => {
    expect(warm.undertone).toBe("warm");
    const s = suggestFabric(warm, { liveOnly: true });
    expect(s?.template).toBe("full_body_sea_green_silk");
    expect(s?.closest.name).toBe("Deep teal");
  });

  it("never offers a template the palette rates neutral or avoid", () => {
    for (const p of [warm, cool, buildPalette(PERSONA_READING, "cooler")]) {
      for (const liveOnly of [true, false]) {
        const s = suggestFabric(p, { liveOnly });
        if (s) expect(verdictFor(p, s.hex).verdict).toBe("yours");
      }
    }
  });

  it("live mode offers only templates whose render was checked", () => {
    const live = new Set(FABRIC_TEMPLATES.filter((t) => t.live).map((t) => t.id));
    expect(live).toEqual(new Set(["full_body_sea_green_silk", "full_body_blue_wool"]));
    for (const p of [warm, cool]) {
      const s = suggestFabric(p, { liveOnly: true });
      if (s) expect(live.has(s.template)).toBe(true);
    }
  });

  it("ships no sheer template (organza, chiffon, lace turned an abaya into a crop top)", () => {
    for (const t of FABRIC_TEMPLATES) expect(t.id).not.toMatch(/organza|chiffon|lace|feather|sequin|shimmer/);
  });

  it("the new everyday abaya has no colourway that suits the warm sample person", () => {
    expect(noColourwaySuits(warm, ["#1f2f5a", "#f2c8d8", "#9aa3ad"])).toBe(true);
    expect(noColourwaySuits(warm, ["#1c1c1e", "#1f7a55", "#b7a6d8"])).toBe(false);
  });
});
