# Fable, Round 3: Drape, delivered seller-side and by extension

One finding reframes everything: cloth-v4 kept colour but changed silhouette (ruffle vs cape) on hand-recoloured references. The Round 2 "recolour locally, render three colourways" step is dead. The only party with real, clean colourway shots is the seller. That is the argument for the pivot.

## 1. Seller side: strengthens both, with one caveat

**Strengthens the entry.** Reliability scores as Design (complete product); seller pre-flight scores as Tech depth (VTO as automated asset QA, which nobody else will show). **Strengthens the business.** This is how VTO is actually sold: catalogue integration, retailer pays, shopper never pays.

**What the seller does** (one form page, not a CMS): upload one clean, front-facing, single-garment shot per colourway; pick category (upper/lower/full/outer); confirm the dominant colour we extract locally; we map it to palette families (suits warm/cool) automatically, seller may override; press "pre-flight".

**Seller-time YouCam calls:** optional pre-flight Clothes VTO per colourway on a neutral model photo (synthetic or owner-consented, never stock), 2u. It proves the asset renders with a stable shape and becomes the judge-mode cached asset app-flow already plans. **Buyer-time:** colour reading, their own try-on, makeup, jewelry, unchanged. Seller prep makes the buyer render reliable and the catalogue free; it does not remove the buyer's 2u own-body try-on.

**Who pays.** Hackathon: the 994-unit pool; 6 SKUs × 3 colourways = 36u pre-flight. Business: retailer pays pre-flight as a listing fee and buyer try-ons as conversion cost.

**Caveat:** the wow lives buyer-side. A console beyond one page eats the video.

## 2. Extension: one click, honest fallbacks

**Extraction ladder** (content script, then our backend): JSON-LD `Product` (image, color, category) → `og:image` → carousel attributes carrying size-keyed image maps and `srcset` maxima → largest in-content `<img>`. **Colourway:** selected variant swatch `aria-label`/`title`, URL variant params, else dominant colour of the extracted image. **Category:** breadcrumb and title keyword map (abaya/dress → full, blouse → upper, trousers → lower).

**Failure modes and handling:** collage or multi-person image → backend rejects, user gets a "pick the garment photo" thumbnail strip (one click becomes two); colour only as a swatch → palette verdict from the swatch, try-on from the base shot; `lower_body` from a flat shot → refuse unless on-model; lazy-loaded or background-image heroes → fall to og:image; CSP-locked pages → open our hosted app with the URL instead of injecting.

**Legal.** A user-initiated content script reading the page the user is viewing is standard shopping-extension behaviour, low exposure. The real exposure is the video: Amazon logo, UI chrome, or a brand's product photo on screen. Avoid it entirely: demo on two synthetic stores on different domains, name Amazon only in text as "any store", ship load-unpacked with README install steps (judges must install it, so that is Design).

## 3. Final architecture: Drape Network

One backend, one UI, three doors.

- **Seller Console** (Flutter web, `/seller`): colourway shots, category, local colour → palette family, pre-flight (2u/colourway), publish → "Drape-ready" badge and product ID.
- **Buyer Web App** (Flutter web): app-flow.md steps 1–10, store lists Drape-ready products.
- **Buyer Extension** (Chrome MV3, ~200 lines, no UI of its own): one click opens the hosted web app in a side panel with query params. Fast path: product is Drape-ready → clean asset, instant. Wild path: DOM extraction → backend checks → VTO.
- **Backend**: API key, budget guard, cache keyed by (photo, asset, params), storage copy at completion (24 h deletion), product registry, palette engine.

**Calls and units.** Seller: pre-flight 2u/colourway. Buyer, once: Fitzpatrick 2u (demo) or Facial Color Tones 20u (premium), cached forever. Per look: Clothes VTO 2u; Makeup VTO 1u **on the selfie**, shown as a face close-up beside the outfit (designs around the untested ≥100 px face risk instead of testing it); Earrings or Necklace in the palette metal 1u. Session: 6–7u demo, 24–25u premium; wild path costs nothing extra.

**3-minute demo:** 0:00–0:20 seller uploads three colourway shots, pre-flight, badge. 0:20–1:10 buyer: selfie, undertone, drape reveal (incl. hijab drape), store re-sorted by face. 1:10–2:10 extension on a second synthetic store with no prep: click, image extracted, try-on, "match my face", gold earrings; then on the Drape-ready product, instant. 2:10–2:40 bundle to cart, Arabic RTL. 2:40–3:00 architecture card, roadmap.

## 4. MVP by Nov 2

Three surfaces in three days is tight; the extension must stay trivial.

**Build:** Day 1 backend proxy, cache, budget guard, buyer app steps 1–10 in demo mode with premium toggle. Day 2 seller console as one page with pre-flight; extension with the extraction ladder and the image-picker fallback. Day 3 two synthetic stores, judge persona cached, video.

**Roadmap only:** Amazon-specific adapters, Web Store listing, lower-body, batch catalogue import, Shopify app, makeup on the full-body output, seller analytics.

## 5. Biggest risk and cheapest test

**Risk:** the wild path. Clothes VTO on arbitrary store imagery, and shape stability on real colourway pairs, are both untested; the one tested path varied silhouette.

**Test (not run; needs the owner's approval): 9 units.** Same buyer photo, four Clothes VTO calls: one clean flat-lay, one on-model single-person shot, one real colourway pair of the same SKU (8u); plus Makeup VTO on the selfie to confirm the face-path fallback (1u). Pass: the pair keeps silhouette, the on-model and flat-lay sources render. Fail on the pair: drop colourway comparison for good, verdict stays in the drape overlay. Fail on on-model: wild path ships behind the image picker only.
