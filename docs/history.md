# Drape: planning history (superseded by docs/product.md; do not build from this file)

<!-- /autoplan restore point: "/Users/ramymagdy/.gstack/projects/Developer/no-branch-autoplan-restore-20261010-194857.md" -->
## Implementation plan
# Drape Network: product definition (debate round 3 synthesis, 2026-10-10; pending the owner's approval)

Sources: docs/debate/codex_r3.md, docs/debate/fable_r3.md. Buyer flow detail: docs/app-flow.md.

**One backend, one buyer UI, three doors.**

```
 SELLER CONSOLE (Flutter web /seller)          BUYER EXTENSION (Chrome MV3, ~200 lines)
  upload 1 clean shot per colourway             one click on any product page
  pick category · confirm colour → palette      ├─ fast path: product is Drape-ready → clean asset
  pre-flight render [2u/colourway, opt.]        └─ wild path: DOM extraction ladder → backend checks
  publish → "Drape-ready" badge + product ID        (JSON-LD → og:image → carousel/srcset → largest img;
            │                                        fails → "pick the garment photo" strip)
            ▼                                                │ opens side panel ▼
 ┌────────────────────────── BACKEND (holds the API key) ──────────────────────────┐
 │ product registry · palette engine (JSON rules) · cache (photo+asset+params)     │
 │ budget guard (per-session + global; judge mode = 0u) · copies results (24h TTL) │
 └──────────────────────────────────────┬───────────────────────────────────────────┘
                                        ▼
 BUYER WEB APP (Flutter web; the same build runs in the extension side panel and as a mobile app)
  selfie → colour reading [Fitzpatrick 2u | Color Tones 20u, cached forever] → DRAPE REVEAL (incl. hijab) [0u]
  → store re-sorted by face → try on [Clothes VTO 2u] → match my face: makeup ON THE SELFIE [1u]
  + earrings/necklace in palette metal [1u] → look card → bundle to cart → mock checkout
```

## Decisions
- **The seller prepares, the buyer experiences.** Clean colourway shots from the seller fix the reliability problem the de-risk exposed.
  The seller console stays **one page** (the wow is buyer-side).
- **Makeup runs on the selfie** (face close-up beside the outfit), which avoids the untested face-size risk of chaining onto the full-body output.
- **Extension = a door, not a separate app:** one click opens the hosted buyer app in Chrome's side panel with the product context.
- **Video is trademark-clean:** two synthetic stores on different domains. "Amazon or any store" appears as text only, never their UI or logo.
  Ship load-unpacked with README install steps; Web Store listing is roadmap.

## Units
Seller pre-flight 2u per colourway (6 SKUs × 3 = 36u for the demo catalogue) · buyer 6–7u per session (demo) or 24–25u (premium)
· wild path +0u · judge mode 0u.

## MVP by Nov 2 (one dev, ~3 days)
- Day 1: backend (proxy, cache, budget guard, registry, palette rules) + buyer flow in judge/demo mode.
- Day 2: one-page seller console with pre-flight; MV3 extension (fast path + extraction ladder + picker fallback).
- Day 3: two synthetic stores, cached judge persona, Arabic RTL pass, video.
- Roadmap only: Amazon-specific adapters, Web Store listing, Shopify app, batch catalogue import, lower-body wild path,
  makeup on the full-body output, seller analytics.

## Open disagreement
Codex: keep the wild path out of the main demo (unreliable). Fable: show it, with the picker fallback. **Resolved 2026-10-10 by the gate test:** the fast path
leads the video, and the wild path is shown after it (on-model reference passed).

## Gate test: RUN 2026-10-10, 9 units, ALL PASS (was: needs the owner's approval)
Same buyer photo × Clothes VTO on (a) a clean flat-lay, (b) a single-person on-model shot, (c)+(d) a real colourway pair of one SKU (8u)
+ Makeup VTO on the selfie (1u). Pass → colourway comparison + wild path ship. Pair fails → no side-by-side; the colour verdict stays in the drape overlay.
On-model fails → the wild path stays behind the image picker only. Needs rights-cleared test images (synthetic or owned).

**Result (2026-10-10, 9u, ~985 left; `docs/derisk/2026-10-10_gate_*.jpg`, script `run_gate.py`):** same buyer photo throughout.
- (a) flat-lay tee → ✅ clean swap, print legible, jeans/face/pose kept.
- (b) on-model photo, `outer` (fur jacket over red top) → ✅ only the jacket transferred, layered over the buyer's own top.
- (c)+(d) real grey/navy colourway pair (Wikimedia CC BY-SA product shots) → ✅ **same silhouette, length and print**, colour faithful.
  The earlier ruffle/cape drift was caused by hand-masked recolours, not by colourways.
- (e) makeup on the selfie (matte berry lip) → ✅ natural, rest of the face untouched.
**Decisions from this:** side-by-side colourway comparison ships; the wild path (on-model store photos) ships in the demo with the picker fallback.
Caveat: n=1 per case, and DOM extraction on real stores is untested (free to test, no units).

## Round 4 (2026-10-10): product registry with cross-store links (docs/debate/r4.md, codex_r4.md, fable_r4.md)
Both say **yes**: sellers add products once and attach their listing links on other stores (URL, ASIN, Shopify handle, GTIN). The extension
checks the registry before anything else. They frame it as the reliability layer and a network, not yet "the business": with no sellers, nothing matches.
- **Matching (0 units, URL/DOM only):** Tier 0 = normalised URL or platform ID (ASIN `/dp/…`, Shopify handle, Noon SKU) → auto-match ·
  Tier 1 = JSON-LD GTIN/SKU/MPN, canonical URL → auto-match · Tier 2 = title + image similarity → **suggest only**, the buyer confirms ·
  no match → wild path (extraction ladder + picker).
- **Safety:** link hijacking (a seller claims a competitor's listing) is the main abuse, so a link must match the seller's brand or store and the listing image.
  A "wrong product" tap unlinks it. Never auto-merge across sellers. Verify in the buyer's browser at click time, never by crawling marketplaces from our server.
- **Build by Nov 2 (~half a day extra):** `links[]` on each registry product, "paste listing URL" in the seller console, Tier 0/1 in the extension,
  Tier 2 confirm chip, "wrong product" tap, **no-match log**. Roadmap: GTIN lookup, image-hash index, ownership verification, bulk import, Shopify auto-link.
- **Video beat (~20 s):** click on synthetic Store B → no match, picker → seller pastes Store B's URL → re-click → "Drape-ready, matched".
- **Extras:** Fable's no-match log becomes the seller sales funnel ("37 buyers tried Drape on your listings, 21 warm-palette") → claim the listings.
  Codex's link-health dashboard covers broken links, duplicates and missing colourways.

## Owner direction (2026-10-10): official doors only, no crawling
1. **Drape API + "Try on with Drape" button** that stores integrate themselves (an embed script or Shopify-style app). The store sends the product ID and images, so consent is explicit.
2. **Drape link in the listing:** the seller pastes `drape.app/p/<id>` into the description, or any field the store allows. A buyer who follows it lands on the product, already matched.
   The link also proves the seller controls that listing. ⚠️ Some marketplaces (Amazon in particular) restrict external URLs in listings; check each store's policy.
3. **Search on Drape:** the seller registers store name + SKU (e.g. ASIN). The buyer pastes the product link, or types store + SKU, in Drape.
4. **Extension (convenience only):** on click it reads **only the page address** in the buyer's own browser, then looks it up in the registry. It does no page reading and no server crawling.
   No match → "not on Drape yet; ask the seller", which goes into the no-match log.
Demo: a synthetic store with the embedded button (API door) + a second synthetic store using the description link + search by SKU.

<!-- autoplan-accepted:ceo -->
- One superseding scope block governs the build: the extension reads only the page URL; no DOM extraction, picker or Tier 1–2 matching ships (owner rule 2026-10-10). Verify: no code path reads page content.
- Colour reading uses Facial Color Tones (`skin-tone-analysis`, 20u), cached per face hash; undertone and contrast are derived from the returned hex values by tested JSON rules. Verify: unit tests map sample hex inputs to expected palettes.
- Judges get a cached persona plus a capped live "try your own photo" path; the budget guard reserves ~400u for Nov 3–20 and blocks atomically at the cap. Verify: a test fires concurrent calls at the cap and only the allowed number spend.
- The video and demo lead with the rejected colourway rendered beside the approved one on the buyer's body.
- Every YouCam failure in the Error & Rescue Registry maps to a named user message; nothing fails silently. Verify: adapter tests with recorded error responses.
- Shipped garments are synthetic or owned (no Wikimedia/branded images in the catalogue or video).
- Abaya/full_body Clothes VTO test (2–4u) runs only after the owner approves that specific run.
<!-- /autoplan-accepted:ceo -->

<!-- autoplan-accepted:design -->
- Buyer capture is two photos: a face close-up (colour reading + makeup) first, a full-body photo requested only at the first try-on; both show 24h-retention copy and a delete action, and a "try without your photo" persona path is on every capture screen.
- A Compare screen renders the off-palette colourway beside the palette pick on the buyer's body, labelled by verdict on the garment (never on skin); 4u live, cached in judge mode.
- The reveal shows, in order: best vs worst drape on the face (hijab overlay as frame), 6–8 named swatches + metal, an undertone/contrast label, then "Shop your colours".
- The store never hides items: palette badges on colourway chips, palette items sorted first, a defined empty state.
- The interaction-state table above is the spec for loading, error, partial, cap-reached and expired states; partial results always render what succeeded.
- The Drape flow opens in its own tab/popup (never an iframe); layouts use start/end directions from day 1; 44px targets, focus rings, named swatches with text verdicts, ≥16px body text, 4.5:1 contrast.
- Copy rules: judge the garment, never the skin; every "no" comes with a better "yes"; Arabic copy reviewed by a native speaker.
<!-- /autoplan-accepted:design -->

<!-- autoplan-accepted:dx -->
- `YOUCAM_MODE=replay` is the default: recorded responses, 0 units, no key; live mode requires both `YOUCAM_API_KEY` and `YOUCAM_LIVE_BUDGET`. Verify: a fresh clone runs the full demo with no key and no network call to YouCam.
- One embed snippet (`/embed/v1.js` + `data-drape-*` attributes) and three endpoints (`POST /v1/products`, `GET /v1/products/:id`, `POST /v1/sessions`); publishable key + domain allowlist for the button, secret key for registration; host page receives `drape:add-to-cart`.
- Canonical identifiers: `productId` (`dr_…`), `colorwayId`, `garmentCategory`, `paletteVerdict`; "color" spelling in code.
- Every developer-facing error uses `{code, message, fix, docs_url, request_id}`; `embed.js` warns in the console and never fails silently.
- Root README in the order given above, with a 60-second judge path first; the sample store page source is the working embed example.
- Budget caps and a force-replay kill switch are runtime-configurable; a "warmer / cooler" override re-runs the palette rules for 0u.
- If the extension ships: it opens the hosted flow in a new tab with the page URL, uses `activeTab` only, no host permissions.
<!-- /autoplan-accepted:dx -->
## Build spec (supersedes everything above where they conflict; 2026-10-10)
- **Doors that ship:** (1) the merchant embed button + API (primary); (2) the buyer flow at the hosted URL with a cached persona; (3) the seller console (one page).
  **Stretch/roadmap (UC1 accepted 2026-10-10):** the URL-only extension, description links, SKU search, the no-match funnel. **Cut:** the DOM extraction ladder, image picker, Tier 1–2 matching (owner rule: no page reading).
- **Colour reading:** Facial Color Tones (`skin-tone-analysis`, 20u) only, cached per face hash; Fitzpatrick mode removed.
- **Unit table:** colour reading 20u (once per face) · try-on 2u · Compare +2u · makeup 1u · jewelry 1u → new live buyer ~26u, returning buyer 4–6u, judge persona 0u.
  Seller pre-flight 2u per colorway. Reserve ~400u for judging (Nov 3–20).
- **Buyer flow:** face photo → your colours (reveal) → Compare on your body (full-body photo asked here) → complete the look → look card + cart.


<!-- autoplan-accepted:eng -->
- Async job model: endpoints return job ids, the client polls the backend, the backend polls YouCam with backoff and an overall deadline; one long-lived host + SQLite + object storage, chosen before Day 1 and kept up until Nov 20.
- Unit ledger with reserve → commit/release; a timed-out task stays reserved until reconciled; tests cover two processes at the cap; auto-switch to replay when the balance falls below the judging reserve.
- Public live mode has per-visitor and global daily caps (optional judge code) and falls back to the labelled persona; the publishable key alone can never spend units.
- Replay fixtures store result bytes, never URLs; an unknown photo in replay mode returns the persona result labelled "sample"; a test asserts no fixture contains an http result URL; a fresh-clone test makes zero calls to *.makeupar.com.
- Cache key = normalised-upload SHA-256 + session + API name/version + garment category + colorwayId + params + palette-rules version; 24h max; DELETE and the sweeper purge photos, results and cache entries; EXIF stripped on upload.
- Seller console requires authentication; keys stored hashed; pre-flight goes through the ledger; uploads checked by magic bytes and size.
- Cross-window cart events use postMessage with an explicit targetOrigin bound at session creation; embed.js validates event.origin and session id.
- CI greps the built Flutter bundle for the API key pattern; /health checks key presence, balance above reserve and replay assets; repeated upstream 5xx forces replay.
- Before palette rules are written, one real skin-tone-analysis response is recorded as a fixture (20u, owner approval required); the shipped synthetic garments are re-gated through cloth-v4 before the Compare UI is built (owner approval required).
- The hijab overlay method is chosen up front (client-side face landmarks or a fixed oval guide), with colour swatches framing the face crop as the fallback.
- The plan document is collapsed to the Build spec before coding starts; superseded history moves to docs/history.md.
<!-- /autoplan-accepted:eng -->
## Review record

### Phase 1 — CEO review (mode: SELECTIVE EXPANSION, 2026-10-10)

**System audit.** Greenfield, no code yet, not a git repo (needs `git init` + a remote before submission). No TODOS.md. Inputs: CLAUDE.md, docs/app-flow.md,
docs/derisk/run_gate.py (working upload→task→poll client, reusable as the backend's YouCam adapter), docs/debate/*. No prior design doc.
Docs check (0u): `skin-tone-analysis` ("Facial Color Tones", 20u) returns hex `skin_color`, `hair_color`, `eye_color`, `lip_color`, `eyebrow_color`.
Undertone and contrast can be derived from these deterministically (Lab a*/b*, skin–hair lightness gap). Fitzpatrick gives skin *type* only, so it cannot drive a colour palette.

**0A Premises.**
| # | Premise | Verdict |
|---|---|---|
| P1 | Face-measured colour is a real purchase problem (wrong-colour returns, "does this suit me") | Accept. It is the wedge both voices back. |
| P2 | Fitzpatrick (2u) is enough to drive the palette | **Wrong.** It returns type, not undertone. Use Color Tones hex output, cached per face. |
| P3 | A four-door network (embed, description link, SKU search, extension) can ship and be judged | **Challenged by both voices.** See User Challenge UC1. |
| P4 | Judge mode at 0u (cached persona only) proves the integration | **Wrong for stage one.** Add a capped live "try your own photo" path. |
| P5 | Wild path / DOM ladder ships | **Superseded** by the owner's no-page-reading rule (2026-10-10). Roadmap. |
| P6 | CLAUDE.md build window Oct 31–Nov 1 | Stale. The build is starting now (Oct 10), so there are about 3 weeks, not 2 days. Scope pressure is lower, but the cut line still matters. |

**0B Existing leverage.** YouCam client → `docs/derisk/run_gate.py` (upload, PUT, task, poll, download, key scrub). Buyer flow → `docs/app-flow.md`. Palette concept → debate r1–r2.
Garment shots → none rights-cleared for shipping (the Wikimedia tees are CC BY-SA and branded): **make synthetic garments**.

**0C Dream state.**
```
CURRENT                         THIS PLAN (Nov 2)                         12-MONTH IDEAL
docs + 9u gate test     --->    embeddable "Try on with Drape" widget --->  Shopify/Salla/Zid app; any merchant embeds;
no code                         on 1-2 synthetic modest-fashion stores      registry links across stores; marketplace
                                + seller console + live capped buyer        partnerships (official APIs); seller analytics
                                flow (Color Tones→palette→VTO chain)        on colour demand; extension as a lookup door
```

**0C-bis Approaches.**
| | A: Embed-first (recommended) | B: Four doors as written | C: Consumer app only |
|---|---|---|---|
| Summary | Merchant embeds a button; one buyer flow; seller console; extension as URL-lookup stretch | Embed + description link + SKU search + extension, all in the demo | Standalone Drape store, no merchant story |
| Effort / risk | M / Low | XL / High | S / Med (Kostuma overlap) |
| Completeness | 9/10 for what judges can verify | 10/10 on paper, ~5/10 shipped | 6/10 |
Auto-decision: **A** (P1 completeness of what actually ships + P5 explicit). This changes the user's stated direction, so it is **User Challenge UC1** at the gate, not applied silently.

**0D Selective expansion candidates** (auto-decided by the 6 principles; logged in the audit trail):
1. Color Tones as the default reading (cached per face) → **accepted** (in blast radius, fixes P2).
2. Capped live judge path → **accepted** (fixes P4).
3. Rejected colourway rendered beside the approved one on the body → **accepted** (proven by the gate test; it is the video's hero moment).
4. Abaya/`full_body` Clothes VTO test (2–4u) → **accepted as an owner-approval item** (no spend until Ramy says yes).
5. Skin Analysis bridge for foundation finish → **deferred** (TODOS; 12–22u per call, not the wedge).
6. Seller "colour demand" metric on the console → **deferred** (needs real traffic).

**0E Temporal interrogation.**
- Hour 1: hosting choice for the backend (must stay up to Nov 20) and storage for copied results (YouCam deletes after 24h).
- Hours 2–3: palette rules from hex: the undertone thresholds and the hijab-drape colours must be written down as data, not guessed in code.
- Hours 4–5: the embed button runs on a third-party origin, so CORS, the iframe vs popup choice, and camera permission in an iframe will surprise.
- Hour 6+: the judge budget (reserve ~400u), cache keys, and a retry policy for YouCam 5xx/timeouts.

**Dual voices (CEO).**
```
CEO DUAL VOICES — CONSENSUS TABLE
  Dimension                              Claude   Codex    Consensus
  1. Premises valid?                     No (P2,P4,P5)  No (wedge gutted, colour premise assumed)  CONFIRMED: no
  2. Right problem to solve?             Yes, engine; no, network  Yes, merchant widget  CONFIRMED
  3. Scope calibration correct?          No (too wide)  No (too wide)  CONFIRMED: cut
  4. Alternatives explored?              No (embed-only dismissed)  No  CONFIRMED
  5. Competitive risks covered?          Partly (Kostuma, Perfect Corp plugins)  Partly  CONFIRMED: lead with wedge
  6. 6-month trajectory sound?           Network premature  Network premature  CONFIRMED
```
Disagreements → taste: (T1) makeup + jewelry: Codex says possible dilution, Claude says they are the API depth for the Tech tie-break → keep them, bundled into the cart.
(T2) Arabic RTL: Codex says cut unless MENA modest fashion is the committed niche; Claude backs the MENA wedge → keep RTL and commit to the niche.

**Sections 1–11 (CEO lens).**
1. Architecture: one backend (YouCam adapter, budget guard, cache, registry, palette engine) + one Flutter web buyer app + seller console + embed script. Diagram below. SPOF = the backend host; mitigation: judge persona assets served statically as a fallback.
```
 [Merchant page] --embed.js--> (popup/new tab) [Buyer web app] --HTTPS--> [Backend]
 [Seller console] -------------------------------------------------------> [Backend] --> YouCam API (key server-side)
 [Extension (stretch)] --URL only--> [Backend /lookup] --> [Buyer web app]      [Backend] --> [Object storage: results, garments]
```
2. Errors: YouCam errors (`error_pose`, `error_multi_person`, `error_nsfw_content_detected`, 401, 429, 5xx, timeout, 24h expiry) each need a named user message (registry below).
3. Security: the key stays server-side; the budget guard is the abuse control for public live mode; selfie images are PII (consent screen, 24h deletion, no logging of image bytes).
4. Data/UX edge cases: no face, two faces, dark photo, the user leaves mid-poll, double tap on "try on" (must not double-spend; idempotency key = cache key).
5. Quality: the YouCam adapter in one module; palette rules as a JSON file with tests.
6. Tests: unit tests for the palette (hex → undertone/contrast → palette), cache key, and budget guard; adapter tests with recorded responses (0u).
7. Performance: try-on takes ~12s, makeup ~5s (measured in the gate test). Show progress, and pre-render seller colourways.
8. Observability: per-call log of api, units, status, latency, and cache hit; a units-left counter.
9. Deploy: host must stay up to Nov 20; a smoke test after deploy; a static fallback for judge mode.
10. Future: reversibility 4/5; the network layer can be added later on the same registry.
11. Design: see Phase 2.

**Error & Rescue Registry**
| Codepath | Failure | Rescued | Action | User sees |
|---|---|---|---|---|
| upload (POST /file + PUT) | 4xx/5xx, PUT skipped | Y | retry once, then fail | "Couldn't upload your photo, try again" |
| task create | 401 InvalidAccessToken | Y | alert owner, use the judge persona | "Live try-on is paused; showing the demo" |
| task create | 429 / units exhausted | Y | budget guard blocks first | "Live try-on limit reached; here's the demo look" |
| poll | timeout > 90s | Y | stop, no charge (units only on success) | "This is taking too long, try again" |
| poll | error_pose / error_multi_person | Y | map to framing advice | "One person, facing the camera, full body in frame" |
| poll | error_nsfw_content_detected | Y | reject | "This photo can't be used" |
| result download | URL expired (24h) | Y | copy to our storage at success time | nothing (transparent) |
| colour reading | no face / face too small | Y | local check before spending | "Move closer, face the light" |

**Failure Modes Registry**
| Codepath | Failure | Rescued | Test | User sees | Logged |
|---|---|---|---|---|---|
| budget guard | race lets two calls through at the cap | Y (atomic counter) | Y | limit message | Y |
| cache | key collision across users | Y (hash includes photo bytes) | Y | n/a | Y |
| embed button | blocked third-party popup | Y (fallback link) | Y | "Open Drape" link | Y |
| palette | grey hair/dyed hair skews contrast | partial (user override) | Y | "Adjust" control | N |
No critical gaps once these remedies land.

**NOT in scope (Nov 2):** description-link door, SKU search, no-match funnel, link health, Tier 1–2 matching, DOM ladder/picker, Web Store listing, Shopify app,
Skin Analysis bridge, makeup on the full-body output. (UC1 decides whether the extension stays as a URL-only stretch.)

**Dream state delta:** Nov 2 delivers the engine + the merchant widget + the seller console; the 12-month network (registry links, marketplace partnerships) remains roadmap.

<!-- autoplan-accepted:ceo -->
- One superseding scope block governs the build: the extension reads only the page URL; no DOM extraction, picker or Tier 1–2 matching ships (owner rule 2026-10-10). Verify: no code path reads page content.
- Colour reading uses Facial Color Tones (`skin-tone-analysis`, 20u), cached per face hash; undertone and contrast are derived from the returned hex values by tested JSON rules. Verify: unit tests map sample hex inputs to expected palettes.
- Judges get a cached persona plus a capped live "try your own photo" path; the budget guard reserves ~400u for Nov 3–20 and blocks atomically at the cap. Verify: a test fires concurrent calls at the cap and only the allowed number spend.
- The video and demo lead with the rejected colourway rendered beside the approved one on the buyer's body.
- Every YouCam failure in the Error & Rescue Registry maps to a named user message; nothing fails silently. Verify: adapter tests with recorded error responses.
- Shipped garments are synthetic or owned (no Wikimedia/branded images in the catalogue or video).
- Abaya/full_body Clothes VTO test (2–4u) runs only after the owner approves that specific run.
<!-- /autoplan-accepted:ceo -->


### Phase 2 — Design review (2026-10-10)

**Step 0.** Initial design completeness: **3/10**. The plan names screens ("DRAPE REVEAL", "look card") but does not say what is on them, has no states,
and has no screen for its own hero moment. No DESIGN.md (recommend `/design-consultation` before UI build). No existing UI to reuse.
A 10 would specify the two-photo capture, a Compare screen, a reveal hierarchy, a state table per step, four surface layouts, RTL rules and tone-of-voice rules.
Mockups: the gstack designer is available but **not run in autoplan** (it needs interactive board feedback and may bill an image API); queued as `/design-shotgun` after the gate.

**Litmus scorecard (dual voices).**
```
  Check                                Claude      Codex       Consensus
  1. Brand unmistakable first screen?  No (unspec) No          CONFIRMED: fail
  2. One strong visual anchor?         Yes, no screen  Yes, not locked  CONFIRMED: promote Compare to core UI
  3. Scannable by headlines?           Not spec'd  Partial     NOT SPEC'D
  4. Each section one job?             Partial     Partial     CONFIRMED: partial
  5. Cards necessary?                  Not spec'd  No          DISAGREE-lite → no cards by default
  6. Motion improves hierarchy?        Not spec'd  Not proven  CONFIRMED: needs rules
  7. Premium without shadows?          Not spec'd  Not spec'd  NOT SPEC'D
  Hard rejections at risk:             stacked cards, weak brand   stacked cards, weak brand, carousel   CONFIRMED
```

**Pass 1 Information architecture: 2/10 → 8/10.**
```
 Merchant product page ──[Try on with Drape]──▶ Drape flow (own tab on mobile, popup/new tab on desktop; never an iframe: camera)
   1 Face photo (framing oval) ─▶ 2 Your colours (reveal) ─▶ 3 Compare on your body ─▶ 4 Complete the look ─▶ 5 Look + cart
        │ "Try without your photo" → cached persona at any step         ▲ full-body photo asked here, first time only
```
Reveal order: (1) the face framed by the best drape colour beside the worst one (hijab overlay as the frame); (2) 6–8 named swatches + metal; (3) a short undertone/contrast label; (4) CTA "Shop your colours".
Store: never hide items; palette badge on each colourway chip; "Yours" sorted first; empty state "None of this store's colours match yet — closest options".

**Pass 2 Interaction states: 1/10 → 8/10.**
| Feature | Loading | Empty | Error | Success | Partial |
|---|---|---|---|---|---|
| Face photo | local check spinner <1s | camera denied → upload button | specific retake copy (closer / one face / no glasses / light) | thumbnail + "Read my colours" | — |
| Colour reading (~5–10s) | "Reading your skin, hair and eyes" steps | — | retry once, then persona fallback | reveal; cache-hit note "From your saved reading" | — |
| Compare (2×Clothes VTO ~12s each) | two skeleton bodies fill one by one | no colourway in palette → closest | per-side retry | both renders, verdict labels | one side done, other retrying |
| Complete the look | face close-up skeleton | — | "Makeup unavailable" chip, look still shown | makeup + metal | outfit shown, makeup failed |
| Live cap reached | — | — | "Live try-on limit reached today — here is the demo look" | — | — |
| Seller pre-flight | per-colourway progress | "Add your first colourway" | "Shape changed, retake photo" | Drape-ready badge | some colourways ready |
| Returning user (24h expiry) | — | "Your last look expired, re-render (2u)?" | — | — | — |

**Pass 3 Journey: 3/10 → 8/10.**
| Step | User does | Feels | Plan specifies |
|---|---|---|---|
| 1 | taps Try on with Drape on a product | curious, slightly wary | privacy line + persona escape hatch |
| 2 | face photo | exposed | oval guide, "deleted in 24h", delete button |
| 3 | sees reveal | recognised ("that's why navy looks off") | best/worst drape on own face |
| 4 | compares two colourways on body | confident | side-by-side, verdict on garment not skin |
| 5 | adds makeup + metal | delighted | "complete the approved look" |
| 6 | bundles to cart | decided | itemised look card, demo checkout labelled |
Tone rules: judge the garment, never the skin; always pair a "no" with a better "yes"; never call the user dark/light/fair; Arabic copy reviewed by a native speaker.

**Pass 4 AI slop: 4/10 → 8/10.** Classifier: merchant page = HYBRID, Drape flow = OPERATE. No card grids, no carousel for colourways (swatch row + Compare),
Compare is the single visual anchor and the video thumbnail; Drape lockup on the widget button and flow header; one authored motion: the drape reveal
(worst colours enter, face dims, best colour replaces them) with a reduced-motion fallback; no decorative shadows.

**Pass 5 Design system: 0/10 → 6/10.** No DESIGN.md. Decided now: CSS/Flutter tokens for colour, one display + one body face that both cover Arabic
(e.g. IBM Plex Sans Arabic + a Latin pair), 8-pt spacing. Remaining gap: a real DESIGN.md → run `/design-consultation` (TODO).

**Pass 6 Responsive & a11y: 1/10 → 8/10.** Surfaces: mobile portrait (primary), desktop judge view (Compare side by side), extension (if kept) hands off to a tab
instead of running the full flow in a ~360px panel. Directional (start/end) layout from day 1; in RTL the approved render sits on the reading-start side.
44px targets, visible focus rings, keyboard-operable compare slider, every swatch named with a text verdict (no red/green meaning), body text ≥16px, 4.5:1 contrast,
captions in the video.

**Pass 7 Decisions resolved (auto, see audit trail):** two photos (face first, full body at first try-on); the system picks the "rejected" colourway as the user's
chosen one when it is off-palette, else the palette's worst match in that SKU; Compare costs 4u live, cached for judges; non-palette items badged not hidden;
extension hands off to a tab; judge cap = 1 live reading + 1 compare per visitor code; external-store products checkout via "Buy on <store>".

**NOT in scope (design):** seller analytics UI, description-link landing page design, SKU search UI (if UC1 is accepted), animations beyond the reveal.
**What already exists:** docs/app-flow.md screen list; the published flowchart artifact; no components.

<!-- autoplan-accepted:design -->
- Buyer capture is two photos: a face close-up (colour reading + makeup) first, a full-body photo requested only at the first try-on; both show 24h-retention copy and a delete action, and a "try without your photo" persona path is on every capture screen.
- A Compare screen renders the off-palette colourway beside the palette pick on the buyer's body, labelled by verdict on the garment (never on skin); 4u live, cached in judge mode.
- The reveal shows, in order: best vs worst drape on the face (hijab overlay as frame), 6–8 named swatches + metal, an undertone/contrast label, then "Shop your colours".
- The store never hides items: palette badges on colourway chips, palette items sorted first, a defined empty state.
- The interaction-state table above is the spec for loading, error, partial, cap-reached and expired states; partial results always render what succeeded.
- The Drape flow opens in its own tab/popup (never an iframe); layouts use start/end directions from day 1; 44px targets, focus rings, named swatches with text verdicts, ≥16px body text, 4.5:1 contrast.
- Copy rules: judge the garment, never the skin; every "no" comes with a better "yes"; Arabic copy reviewed by a native speaker.
<!-- /autoplan-accepted:design -->


### Phase 2.5 — DX review (mode: DX POLISH, 2026-10-10)

**Product type:** embeddable widget + small REST API (Platform/API). **Personas:** (a) a storefront developer at a small modest-fashion store pasting the button;
(b) a hackathon judge with ~5 minutes; (c) the solo builder working under the no-unit-spend rule.
```
TARGET DEVELOPER PERSONA
Who:       storefront dev / store owner (Shopify-style or hand-built site), MENA, small team
Context:   wants fewer colour returns; has 20 minutes on a Friday
Tolerance: ~5 minutes to a working button, or they leave
Expects:   one script tag, a demo key, a sample product, clear errors in the console
```
**Empathy narrative.** "I open the repo. There's no README at the root, just CLAUDE.md and a docs folder full of debate files. I find product.md; it talks about
four doors, a DOM ladder, then says the ladder is cut. I can't find what to paste into my product page. There is a `.env.example` asking for a YouCam key,
which I don't have, and a note that every call costs units. I close the tab." (Initial TTHW: undefined, >10 min, Red Flag.)

**Competitive benchmark** (reference set, search not run): Stripe Checkout ~30s to a test button; Shopify app embed ~2 min; generic VTO widgets
(vendor demo pages) ~2–5 min but usually behind a sales call. **Target: Competitive tier, under 3 minutes** for both judge and storefront dev.

**Magical moment:** the judge clicks "Try on with Drape" on synthetic Store A and within seconds sees the Compare screen (cached persona, 0u).
Vehicle: hosted live URL + a copy-paste snippet visible in the store's page source.

**Dual voices (DX).**
```
  Dimension                        Claude        Codex         Consensus
  1. Getting started < 5 min?      No (no API)   No (no README/demo)   CONFIRMED: fail
  2. API naming guessable?         No (IDs mixed) No (IDs/spelling)    CONFIRMED
  3. Error messages actionable?    No (dev errors missing) No          CONFIRMED
  4. Docs findable & complete?     No            No                    CONFIRMED
  5. Upgrade path safe?            Not addressed No (unversioned)      CONFIRMED
  6. Dev env friction-free?        No (no replay mode) No (key-first)  CONFIRMED
```

**Passes (score before → after decisions).**
1. Getting started 1 → 8: replay mode default (`YOUCAM_MODE=replay`, uses recorded responses, 0u, no key); `make demo` (or 3 commands) runs backend + buyer app + seller console + sample store; hosted URL opens on the cached persona.
2. API design 2 → 8: one embed snippet, three endpoints, canonical names (`productId`, `colorwayId`, `garmentCategory`, `paletteVerdict`; American "color" in code, British "colour" allowed in UI copy only), publishable key + domain allowlist for the button, secret key for registration.
```html
<script src="https://<host>/embed/v1.js" async></script>
<button data-drape-product="dr_abaya_001" data-drape-colorway="navy" data-drape-lang="ar">Try on with Drape</button>
```
   `POST /v1/products` (secret key) · `GET /v1/products/:id` · `POST /v1/sessions` (publishable key) · host page receives `drape:add-to-cart` with SKU list.
3. Errors 2 → 8: JSON envelope `{code, message, fix, docs_url, request_id}`; codes `DRAPE_PRODUCT_NOT_FOUND`, `DRAPE_DOMAIN_NOT_ALLOWED`, `DRAPE_BAD_KEY`, `DRAPE_IMAGE_TOO_SMALL`, `DRAPE_CATEGORY_UNSUPPORTED`, `DRAPE_POPUP_BLOCKED`, `DRAPE_BUDGET_EXHAUSTED`; `embed.js` logs one console warning with a docs link, never fails silently.
4. Docs 1 → 8: root README in this order: what it does → 60-second judge path → APIs used per step with unit cost → run locally (replay) → embed snippet → API reference → extension (optional) → limitations. Synthetic store page source is the live example.
5. Upgrade 0 → 6: versioned `/embed/v1.js` and `/v1/*`; CHANGELOG. Deprecation policy is roadmap.
6. Dev environment 2 → 8: replay/live adapter; live needs `YOUCAM_API_KEY` **and** `YOUCAM_LIVE_BUDGET`; runtime caps + kill switch (force replay) via env/admin secret.
7. Community 3 → 6: public repo with a license (rules), issue template; no community channel (hackathon).
8. Measurement 1 → 6: log TTHW events (snippet loaded → first session) and per-step drop-off in the backend log.

**Developer journey map**
| Stage | Developer does | Friction | Status |
|---|---|---|---|
| Discover | reads Devpost page / video | API names visible in video | fixed |
| Evaluate | opens live URL | 0 clicks to the reveal | fixed |
| Install | copies snippet from README | none | fixed |
| Hello world | button on sample store opens Drape | replay mode, no key | fixed |
| Integrate | `POST /v1/products` with colorways | canonical IDs | fixed |
| Debug | console warning + error envelope | docs links | fixed |
| Go live | sets live key + budget | explicit budget required | fixed |
| Upgrade | v1 URLs | deprecation policy | deferred |
| Scale | Shopify app | — | roadmap |

**First-time developer report (after fixes):** T+0:00 opens README, sees the 60-second judge path; T+0:30 live URL shows the reveal; T+1:30 runs `make demo`; T+2:30 sample store button works in replay mode; done.

**DX scorecard:** Getting started 8 · API 8 · Errors 8 · Docs 8 · Upgrade 6 · Dev env 8 · Community 6 · Measurement 6 · **Overall 2/10 → 7/10** · TTHW >10 min → <3 min.

**Extension (if UC1 keeps it):** opens the hosted flow in a new tab with `?u=<page url>`; manifest uses `activeTab` only and no host permissions, so "reads only the address" is provable in code.
Buyer override: "That's not me: warmer / cooler" toggle re-runs the palette rules for 0u.

**NOT in scope (DX):** SDKs in other languages, Shopify app, deprecation codemods, community channel.
**What already exists:** `docs/derisk/run_gate.py` (adapter core), `.env.example` (needs `YOUCAM_MODE`, `YOUCAM_LIVE_BUDGET`), gate-test responses for replay fixtures.

<!-- autoplan-accepted:dx -->
- `YOUCAM_MODE=replay` is the default: recorded responses, 0 units, no key; live mode requires both `YOUCAM_API_KEY` and `YOUCAM_LIVE_BUDGET`. Verify: a fresh clone runs the full demo with no key and no network call to YouCam.
- One embed snippet (`/embed/v1.js` + `data-drape-*` attributes) and three endpoints (`POST /v1/products`, `GET /v1/products/:id`, `POST /v1/sessions`); publishable key + domain allowlist for the button, secret key for registration; host page receives `drape:add-to-cart`.
- Canonical identifiers: `productId` (`dr_…`), `colorwayId`, `garmentCategory`, `paletteVerdict`; "color" spelling in code.
- Every developer-facing error uses `{code, message, fix, docs_url, request_id}`; `embed.js` warns in the console and never fails silently.
- Root README in the order given above, with a 60-second judge path first; the sample store page source is the working embed example.
- Budget caps and a force-replay kill switch are runtime-configurable; a "warmer / cooler" override re-runs the palette rules for 0u.
- If the extension ships: it opens the hosted flow in a new tab with the page URL, uses `activeTab` only, no host permissions.
<!-- /autoplan-accepted:dx -->


### Phase 3 — Eng review (2026-10-10)

**Step 0 scope challenge.** Existing code: `docs/derisk/run_gate.py` (upload → PUT → task → poll → download, key scrubbed in logs). It's a reference only:
it has no replay, budget, idempotency, validation or storage, and assumes happy response shapes. Complexity check triggers (backend + buyer app + seller console
+ embed SDK + ledger + job model: >8 files, >2 services). Per autoplan override "never reduce scope", scope is held; the reductions both voices want are already
UC1 at the gate. Search: unavailable in this run (in-distribution knowledge).

**Dual voices (eng).**
```
  Dimension                     Claude                         Codex                          Consensus
  1. Architecture sound?        No: zombie scope, no job model No: zombie scope, API too thin  CONFIRMED: needs job model + doc collapse
  2. Test coverage sufficient?  No                             No                             CONFIRMED
  3. Performance risks?         Partly (Flutter cold load)     Partly (serial calls)           CONFIRMED: parallel + resize
  4. Security covered?          No: open console, public drain No: allowlist spoofable, PII    CONFIRMED
  5. Error paths handled?       No: replay misses, partial     No: adapter assumes shapes      CONFIRMED
  6. Deployment risk ok?        No hosting chosen              No hosting chosen               CONFIRMED
```
Cross-phase theme: **public live mode must not drain units** (CEO P4, DX caps, Eng E1/E2). **Zombie scope in the doc** (flagged in all four phases).

**1. Architecture** (final, embed-first):
```
 Store page ─ embed/v1.js ─(popup/tab, signed session token)─▶ Buyer web app (Flutter web)
                                                                   │ REST + polling
 Seller console (auth: one account + admin secret key) ──────────▶ Backend (one long-lived host)
                                                                   ├─ API: /v1/products, /v1/sessions, /v1/sessions/:id/{photos,jobs}, /v1/jobs/:id, DELETE /v1/sessions/:id
                                                                   ├─ Job runner: reserve units → YouCam adapter (replay|live) → commit/release → copy bytes to storage
                                                                   ├─ Unit ledger (SQLite single writer): reserve / commit / release / reconcile
                                                                   ├─ Palette engine (JSON rules, versioned) · cache (key incl. API+version+params+rules version, 24h)
                                                                   └─ Sweeper: deletes photos/results/cache after 24h or on DELETE
 Extension (stretch): activeTab only, opens hosted flow with ?u=<url>
```
Decisions: job model (no request held open); single long-lived host + SQLite + object storage, chosen before Day 1 and kept up to Nov 20; record one real
`skin-tone-analysis` response before writing palette rules (needs owner approval, 20u).

**2. Code quality.** One YouCam adapter module (typed requests, error mapping), one ledger module, palette rules as data. Fix the `run_gate.py` docstring
("3 cloth-v4 calls", actually 4). Identifier lint for `productId`/`colorwayId`/`paletteVerdict`.

**3. Test diagram.**
```
CODE PATHS                                         USER FLOWS
[+] youcam adapter                                 [+] Buyer: face → reveal → compare → look → cart
  ├─ [GAP] upload init 4xx/5xx, non-JSON              ├─ [GAP][→E2E] replay mode, fresh clone, zero egress to *.makeupar.com
  ├─ [GAP] PUT failure                                 ├─ [GAP][→E2E] live mode, capped
  ├─ [GAP] task error_pose/multi_person/nsfw/401       ├─ [GAP] double tap "Try on" → one job, one reservation
  ├─ [GAP] poll timeout then late success              ├─ [GAP] navigate away mid-poll, return → job resumes
  └─ [GAP] empty results / expired URL                 └─ [GAP] Compare partial: one side fails, retry only that side
[+] ledger: [GAP] reserve/commit/release; 2-process concurrency at cap; auto-replay below reserve
[+] palette: [GAP] hex fixtures → undertone/contrast/palette; override warmer/cooler
[+] cache: [GAP] key includes rules version; 24h expiry; delete purges all derived data
[+] embed: [GAP] allowlist +/-; postMessage targetOrigin; console warnings
[+] seller: [GAP] auth required; upload magic-byte check; pre-flight hits ledger
[+] security: [GAP] built bundle contains no key; EXIF stripped; no fixture holds http URLs
[+] ops: [GAP] /health (key present, balance > reserve, replay assets); force-replay on repeated 5xx
COVERAGE: 0/30 (greenfield) — all are build-time requirements below
```
Test plan artifact: `~/.gstack/projects/Developer/ramymagdy-no-branch-eng-review-test-plan-*.md`.

**4. Performance.** Resize/normalise (EXIF, long side ≤1920, ≤10MB) before upload; run the two Compare renders in parallel under one reservation; stream job
progress; measure Flutter web cold load early, with an `<input type=file capture>` fallback for mobile Safari.

**Failure modes registry (eng).**
| Codepath | Failure | Test | Handling | User sees | Critical? |
|---|---|---|---|---|---|
| ledger | poll times out, task later succeeds → under-count | Y | reservation kept until reconciled | nothing | no |
| public live | script drains units | Y | per-visitor + daily caps, auto-replay | cap message + persona | no |
| replay | unknown photo | Y | persona result labelled "sample" | sample label | no |
| host | sleeps/cold start during judging | Y (/health monitor) | long-lived host + monitor | slow first load | no |
| seller | open console spends pre-flight | Y | auth + ledger | login | no |
| bundle | key leaked into Flutter build | Y (CI grep) | key server-side only | — | no |
No critical gaps once the accepted requirements below land.

**Unit ledger (budget).** ~985 left · seller pre-flight on the shipped catalogue ~36u · judging reserve 400u · one Color Tones fixture 20u · abaya test 2–4u ·
re-gate of the synthetic garments (covered by pre-flight) → ~525u for development and video. A new live buyer is ~27–28u (jewelry can be 2u).

**NOT in scope (eng):** multi-instance scaling, Redis, Shopify app, GTIN lookup, image-hash index, deprecation codemods.
**What already exists:** `run_gate.py` (adapter reference), gate-test images (dev fixtures only, not shipped), `.env`/`.env.example`.
**Parallelization:** Lane A backend (adapter → ledger → jobs → API); Lane B buyer app against replay fixtures; Lane C embed.js + sample store. A first, B/C in parallel once the API contract is frozen.

<!-- autoplan-accepted:eng -->
- Async job model: endpoints return job ids, the client polls the backend, the backend polls YouCam with backoff and an overall deadline; one long-lived host + SQLite + object storage, chosen before Day 1 and kept up until Nov 20.
- Unit ledger with reserve → commit/release; a timed-out task stays reserved until reconciled; tests cover two processes at the cap; auto-switch to replay when the balance falls below the judging reserve.
- Public live mode has per-visitor and global daily caps (optional judge code) and falls back to the labelled persona; the publishable key alone can never spend units.
- Replay fixtures store result bytes, never URLs; an unknown photo in replay mode returns the persona result labelled "sample"; a test asserts no fixture contains an http result URL; a fresh-clone test makes zero calls to *.makeupar.com.
- Cache key = normalised-upload SHA-256 + session + API name/version + garment category + colorwayId + params + palette-rules version; 24h max; DELETE and the sweeper purge photos, results and cache entries; EXIF stripped on upload.
- Seller console requires authentication; keys stored hashed; pre-flight goes through the ledger; uploads checked by magic bytes and size.
- Cross-window cart events use postMessage with an explicit targetOrigin bound at session creation; embed.js validates event.origin and session id.
- CI greps the built Flutter bundle for the API key pattern; /health checks key presence, balance above reserve and replay assets; repeated upstream 5xx forces replay.
- Before palette rules are written, one real skin-tone-analysis response is recorded as a fixture (20u, owner approval required); the shipped synthetic garments are re-gated through cloth-v4 before the Compare UI is built (owner approval required).
- The hijab overlay method is chosen up front (client-side face landmarks or a fixed oval guide), with colour swatches framing the face crop as the fallback.
- The plan document is collapsed to the Build spec before coding starts; superseded history moves to docs/history.md.
<!-- /autoplan-accepted:eng -->

<!-- AUTONOMOUS DECISION LOG -->
## Decision Audit Trail

| # | Phase | Decision | Classification | Principle | Rationale | Rejected |
|---|---|---|---|---|---|---|
| 1 | CEO | Mode = SELECTIVE EXPANSION | Mechanical | context default | iteration on an existing plan | EXPANSION, HOLD |
| 2 | CEO | Approach A, embed-first | **User Challenge UC1** | P1, P5 | both voices: four doors cannot ship credibly; the network needs adoption the demo can't prove | B (four doors), C (consumer only) |
| 3 | CEO | Owner's no-page-reading rule supersedes DOM ladder, picker, Tier 1–2 | Mechanical | P5 | the plan contradicted itself; the latest owner rule wins | keep wild path |
| 4 | CEO | Color Tones (20u) replaces Fitzpatrick as the default reading | Mechanical | P1 | docs: Color Tones returns hex skin/hair/eye; Fitzpatrick returns type only | Fitzpatrick demo mode |
| 5 | CEO | Add capped live judge path, reserve ~400u | Mechanical | P1 | stage one needs a working integration, not only a replay | cache-only judge mode |
| 6 | CEO | Lead the video with rejected-vs-approved colourway on the body | Mechanical | P6 | proven by the gate test; it is the wedge | registry beat |
| 7 | CEO | Keep makeup + jewelry in the bundle | Taste T1 | P1 | API depth for the Tech tie-break; Codex flagged dilution | cut add-ons |
| 8 | CEO | Keep Arabic RTL, commit to the MENA modest-fashion niche | Taste T2 | P1 | Codex: cut unless committed; Claude: commit | cut RTL |
| 9 | CEO | Abaya Clothes VTO test queued for owner approval | Mechanical | unit rule | no spend without approval | run now |
| 10 | CEO | Skin Analysis bridge, seller colour-demand metric → deferred | Mechanical | P3 | outside the wedge; needs traffic | build now |
| 11 | CEO | Synthetic garments for everything shipped | Mechanical | rules | trademark + CC BY-SA ShareAlike risk | Wikimedia tees |
| 12 | Design | Skip mockup generation inside autoplan; run /design-shotgun after the gate | Mechanical | P6 | needs interactive board feedback and may bill an image API | generate now |
| 13 | Design | Two-photo capture, face first | Mechanical | P1 | Clothes VTO needs full body, colour/makeup need a close face | one photo |
| 14 | Design | Add Compare screen (4u live, cached for judges) | Mechanical | P1 | the hero moment had no screen | single render |
| 15 | Design | Badge, don't hide, off-palette items | Mechanical | P5 | users satisfice; hiding stock looks broken | hide |
| 16 | Design | Flow opens in own tab/popup, never iframe; extension hands off | Mechanical | P5 | camera permission + 360px panel width | full flow in side panel |
| 17 | Design | Tone-of-voice rules (garment not skin) | Mechanical | P1 | colourism risk in MENA | none |
| 18 | Design | DESIGN.md via /design-consultation | Taste T3 | P1 | Pass 5 stays 6/10 without it | skip |
| 19 | DX | Mode = DX POLISH | Mechanical | override rule | autoplan default | EXPANSION |
| 20 | DX | Replay mode default, live needs key + budget | Mechanical | P1 | judges and the unit rule both need 0u runs | key-first |
| 21 | DX | 1 snippet + 3 endpoints, publishable/secret keys | Mechanical | P5 | smallest complete integrator surface | open API |
| 22 | DX | Error envelope + console warnings | Mechanical | P1 | problem + cause + fix | user-only messages |
| 23 | DX | Extension opens a tab, activeTab only | Mechanical | P5 | resolves side panel vs no-iframe conflict | side-panel iframe |
| 24 | DX | "color" in code, "colour" in UI copy | Taste T4 | P5 | Codex wants one spelling everywhere | British everywhere |
| 25 | Eng | Hold scope (override: never reduce); reductions stay in UC1 | Mechanical | P2 | autoplan rule | reduce now |
| 26 | Eng | Job model + long-lived host + SQLite | Mechanical | P5 | serverless timeouts break polling; boring tech | serverless sync |
| 27 | Eng | Reservation ledger, not counter | Mechanical | P1 | units charge on success; late completions | in-memory counter |
| 28 | Eng | Per-visitor + daily caps, optional judge code | Mechanical | P1 | public URL can drain 400u | publishable key only |
| 29 | Eng | Fixtures as bytes, persona fallback | Mechanical | P1 | presigned URLs expire 24h | URL fixtures |
| 30 | Eng | 24h cache, drop "forever" | Mechanical | P1 | privacy promise | face cache forever |
| 31 | Eng | Seller auth + hashed keys | Mechanical | P1 | open console spends units | open console |
| 32 | Eng | Record Color Tones fixture + re-gate synthetic garments | Owner approval | unit rule | rules need a real response shape | assume fields |
| 33 | Eng | Collapse doc to Build spec before code | Mechanical | P5 | zombie scope flagged in all 4 phases | keep history inline |

## GSTACK REVIEW REPORT

| Review | Trigger | Why | Runs | Status | Findings |
|--------|---------|-----|------|--------|----------|
| CEO Review | `/autoplan` | Scope & strategy | 1 | issues_open (gate) | 6 proposals, 3 accepted, 2 deferred, 1 owner-approval; UC1 pending |
| Outside Review | codex exec (all 4 phases) | Independent 2nd opinion | 4 | completed | CEO 12, Design 10, DX 8, Eng 17 concerns |
| Eng Review | `/autoplan` | Architecture & tests (required) | 1 | issues_open (gate) | 25 issues, 0 critical gaps after accepted remedies |
| Design Review | `/autoplan` | UI/UX gaps | 1 | issues_open (gate) | score 3/10 → 6/10 (Pass 5 limits it), 7 decisions |
| DX Review | `/autoplan` | Developer experience gaps | 1 | issues_open (gate) | score 2/10 → 7/10, TTHW >10 min → <3 min |

- **OUTSIDE COVERAGE:** codex completed for CEO, design, DX and eng (run with `--skip-git-repo-check`, since the folder is not a git repo; the gstack outside-review marker validator was not run).
- **CROSS-MODEL:** Claude subagent and Codex agreed on every consensus dimension in all four phases; the only disagreements were taste calls T1–T4.
- **VERDICT:** APPROVED by owner 2026-10-10 (UC1 accepted: embed-first; taste T1–T4 accepted). Ready to build from the Build spec; first task is collapsing this doc.

**UNRESOLVED DECISIONS:**
- Owner approvals for paid runs (none run yet): Color Tones fixture (20u), synthetic-garment re-gate (~2u per colorway), abaya test (2–4u)
