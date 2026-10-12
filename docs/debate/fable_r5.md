# Fable, Round 5: "Ask for it in my colour"

## 1. The one addition

Drape's only dead end is the honest one: "None of this store's colours match yet." When no colourway of a garment is "Yours", the buyer taps **See it in Terracotta (your colour)**. Drape recolours the seller's own clean shot with **YouCam AI Fabric** (task name and params to confirm in the docs on day 1; the swatch is a flat PNG of the palette hex), renders that unsold colourway on her body with Clothes VTO beside the colour she would have settled for, labels it "not sold yet", and offers **Ask Noor Modest to make it in Terracotta**. The store gets a `drape:colour-request` event and a console table, *Terracotta: 14 requests, 11 warm-palette buyers*, with **Add as colourway (draft)**, which uses the Fabric render as the draft shot. The catalogue stops being the ceiling of the try-on.

## 2. Why it wins

- **Technical:** one reading drives a four-API chain (Color Tones → Fabric → Clothes VTO → Makeup), and Fabric attacks the gate-1 failure (hand recolours drifted in shape). A store-level render cache makes VTO an asset pipeline.
- **Design:** the empty state becomes the strongest screen; the buyer → store → catalogue loop closes inside the product.
- **Impact:** MENA abaya retail is made-to-order by habit; colour demand measured before production is money.
- **Idea:** every try-on tool mirrors the catalogue; Drape asks the catalogue to change. After 40 entries the judge remembers "she asked the store to make it in her colour, and the store saw it".

## 3. Why stores run to install it

Colourways are a bet: shot, stocked, marked down. Run through our own palette engine, the demo catalogue gives a warm buyer "Yours" on 3 of 6 colourways and a cool buyer on 2; the rest of her demand leaves silently. The request table is that demand with a count, and the draft colourway needs no photo shoot. **Assumption:** at 1,000 Drape sessions a month, 10% end in a request and 30% of those pre-order: 30 orders a month for stock the store never had. Merchant line: "know which colour to make before you make it".

## 4. YouCam APIs and units

| Call | Who pays | Units |
|---|---|---|
| Fabric recolour of the seller's shot | store, cached per product × shot hash × hex | 2, once |
| Clothes VTO of the recolour on the buyer | buyer | 2 |
| Day-1 gate (2 Fabric + 1 VTO) | development, owner-approved | ≈ 6 |
| Fixtures: one cool-only product (3 × 2) + request render (2 + 2) | development | ≈ 10 |

Per buyer 2u (4u for the first to ask that colour on that product); per store 2u per requested colour; live: one request per session. Build spend ≈ 16u of the ~550 outside the reserve. Replay: the warm persona opens the new product, no colourway reads Yours, `persona/request_<product>_terracotta.jpg` serves the beat, 0u.

## 5. Build plan

- **Day 1:** confirm Fabric params; run the gate (≈ 6u, approval first); add `fabric` to `YouCamTask` in `backend/src/youcam.ts`.
- **Day 2:** `backend/src/state.ts`: job type `recolor` with a store-level cache key, `POST /v1/sessions/me/requests` (reserve 4u, 2u on cache hit), `GET /v1/admin/requests` grouped by product × colour × undertone; `embed/v1.js` emits `drape:colour-request`; third product and fixtures.
- **Day 3:** Flutter: `shop_screen.dart` chip; `compare_screen.dart` "not sold yet" variant; `look_screen.dart` ask button; `seller_screen.dart` requests table and draft colourway.
- **Day 4:** tests (reserve amounts, cache hit, RTL), EN/AR copy, README and Devpost rows, video beat.
- **Cut order:** draft-colourway button first (counts stay), then the live request path (replay only, labelled).

## 6. The 25-second beat

"Noor sells this kimono in navy, ice pink and grey. None of them is hers." Tap *See it in Terracotta*. The kimono appears in terracotta on her body beside the navy she would have bought. "Ask Noor to make it." Cut to the console: *Terracotta: 14 requests, 11 warm-palette buyers. Add as colourway.* "The store just learned what to make next."

## 7. Biggest risk

Fabric may be pattern-only, add texture to a solid abaya, or miss the hex; the recolour may still drift in VTO. Day-1 verdict: pass if the garment's median colour is within ΔE 15 of the requested hex and the silhouette overlaps the source at IoU ≥ 0.95. Fallback A: Background Removal (1u) for the mask, LAB recolour locally, then VTO. Fallback B: the request at 0u as a swatch on the drape overlay. The seller loop survives both.

## 8. Rejected alternative

**Drape Pass**, a portable colour profile reused across stores: saves 20u per returning buyer. Rejected: it uses YouCam less, not more, and a network of one demo store proves nothing in three minutes.
