// "See it in your colour": when none of a garment's colourways suit the buyer, pick the YouCam AI Fabric template whose
// colour the palette engine itself calls "yours". Pure functions; the template list lives in fabrics.json.
//
//   palette ──▶ verdictFor(template hex) for each offered template ──▶ closest "yours" ──▶ suggestion (or none)
import fabrics from "./fabrics.json";
import { verdictFor, type Palette, type Swatch } from "./palette";

export interface FabricTemplate { id: string; name: string; hex: string; live: boolean }
export interface FabricSuggestion { template: string; name: string; hex: string; closest: Swatch; distance: number }

export const FABRICS_VERSION = fabrics.version;
export const FABRIC_TEMPLATES: FabricTemplate[] = fabrics.templates;

/** True when no colourway of the product reads "yours" for this palette: the moment the store's catalogue runs out. */
export function noColourwaySuits(palette: Palette, colorwayHexes: string[]): boolean {
  return colorwayHexes.every((hex) => verdictFor(palette, hex).verdict !== "yours");
}

/**
 * The template to offer, or null. Only templates the palette engine rates "yours" qualify (never "neutral" or "avoid"),
 * closest first. With `liveOnly`, only templates whose real render was checked for cut and modesty are offered.
 */
export function suggestFabric(palette: Palette, { liveOnly }: { liveOnly: boolean }): FabricSuggestion | null {
  const ranked = FABRIC_TEMPLATES
    .filter((t) => !liveOnly || t.live)
    .map((t) => ({ t, v: verdictFor(palette, t.hex) }))
    .filter(({ v }) => v.verdict === "yours")
    .sort((a, b) => a.v.distance - b.v.distance);
  const best = ranked[0];
  return best ? { template: best.t.id, name: best.t.name, hex: best.t.hex, closest: best.v.closest, distance: best.v.distance } : null;
}

export function fabricTemplate(id: string): FabricTemplate | undefined {
  return FABRIC_TEMPLATES.find((t) => t.id === id);
}

/** Replay fixture: the sample person's settled colourway, re-rendered in the template. */
export function replayRecolorPath(productId: string, colorwayId: string, template: string): string {
  return `/persona/fabric_tryon_${productId}_${colorwayId}_${template}.jpg`;
}
