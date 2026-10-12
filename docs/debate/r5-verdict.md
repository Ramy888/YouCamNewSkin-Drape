# Round 5 verdict: "Ask for it in my colour" + Colour Demand Radar

Proposals: `codex_r5.md` (Merchandising Radar), `fable_r5.md` ("Ask for it in my colour"). Cross-examination: `codex_r5b.md`,
`fable_r5b.md`. Both models converged on the same combined addition; they disagree only on whether the unsold colour is
**rendered** with YouCam (Fable) or shown as a **swatch** at 0 units (Codex).

## The addition

When no colourway of a garment suits the buyer ("None of this store's colours match yet"), she taps **See it in Terracotta**
(her palette colour). Drape recolours the seller's clean shot with **YouCam Fabric**, renders it on her body with **Clothes VTO**
beside the colour she would have settled for, labelled "not sold yet", and she taps **Ask the store to make it in Terracotta**.
The store gets a `drape:colour-request` event and a **Colour Demand** panel in the console, per product: *tried / rejected /
requested, by undertone*, with **Add as colourway (draft)**.

## Why it wins (both agree)

- **Technical:** one reading drives Color Tones → Fabric → Clothes VTO → Makeup; Fabric is a fifth YouCam API used for a reason.
- **Design / idea:** the dead end becomes the strongest screen; every try-on tool mirrors the catalogue, Drape asks the
  catalogue to change.
- **Store pull:** "know which colour to make before you make it": demand counted before stock, which a modest-fashion store
  (often made-to-order) can act on.

## Rules both models set

- **Every number on screen happened.** Counts only (tried, rejected, requested), no percentages or conversion multipliers,
  no seeded analytics: the Rules require the app to behave exactly as the video shows.
- Drop Codex's "save my colour profile" (fewer YouCam calls) and the inferred "add deep teal" line.
- The unit ledger caps live requests at one per session; replay serves the render for the sample person at 0 units.

## Day-1 go / no-go (needs the owner's approval, about 6 units)

Two Fabric recolours of the black abaya shot (emerald, terracotta) and one Clothes VTO of a recolour on the persona body.
- **Go** if the garment's median colour is within ΔE 15 of the requested hex and the silhouette matches the source (IoU ≥ 0.95).
- **No-go:** Background Removal (1 unit) mask plus local LAB recolour, then VTO; if that also drifts, ship the request as a
  swatch at 0 units. The demand panel works either way.

## Plan (about 4 days)

1. Gate test; add `fabric` to the adapter and ledger (2 units).
2. Backend: `recolor` job with a store-level cache, `POST /v1/sessions/me/requests`, `GET /v1/admin/demand`, the
   `drape:colour-request` event, a third product whose colourways don't suit the sample person, replay fixtures.
3. App: "See it in …" on Shop, a "not sold yet" Compare variant, the ask button, the console panel with "Add as colourway (draft)".
4. Tests, EN/AR copy, README/Devpost rows, the 25-second video beat.

Cut order if it slips: the draft-colourway button, then the live request path (replay only, labelled).
