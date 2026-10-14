# Drape: build spec

Approved by the owner on 2026-10-10 after /autoplan (CEO, design, DX and eng reviews, each with a Claude and a Codex reviewer).
This file is the only thing to build from. History and review records are in `docs/history.md`.

## What it is

A modest-fashion store adds a **"Try on with Drape"** button to its product pages. The buyer's face photo is read by YouCam
Facial Color Tones. Drape then shows, on the buyer's own body, the colourway that fights their colouring next to the one that suits it,
completes the look with matching makeup and jewelry metal, and hands the bundle back to the store's cart.
Niche: MENA modest fashion, Arabic RTL and English.

## What ships by Nov 2

| Surface | Ships | Notes |
|---|---|---|
| Store button + API (`embed/v1.js`) | yes, primary | one snippet, new tab, never an iframe |
| Buyer web app (hosted URL) | yes | judge persona at 0u + capped live path |
| Seller console | yes, one page | login required |
| Synthetic sample store | yes (one) | page source is the working embed example |
| Chrome extension (URL only) | stretch | opens the hosted flow in a new tab with `?u=<url>`; `activeTab` only |
| Description links, SKU search, cross-store registry links | roadmap | see TODOS.md |
| DOM extraction, image picker, fuzzy matching | never | owner rule: no page reading, no crawling |

## Architecture

```
 Store page ─ embed/v1.js ─(new tab, signed session token)─▶ Buyer web app (Flutter web)
                                                                   │ REST + polling
 Seller console (one account + admin secret key) ────────────────▶ Backend (one long-lived host)
                                                                   ├─ API: /v1/products, /v1/sessions, /v1/sessions/:id/{photos,jobs},
                                                                   │       /v1/jobs/:id, DELETE /v1/sessions/:id
                                                                   ├─ Job runner: reserve units → YouCam adapter (replay|live) → commit/release
                                                                   │              → copy result bytes to storage
                                                                   ├─ Unit ledger (SQLite, single writer): reserve / commit / release / reconcile
                                                                   ├─ Palette engine (versioned JSON rules) · cache (24h max)
                                                                   └─ Sweeper: deletes photos, results and cache after 24h or on DELETE
```

## Buyer flow

1. **Face photo** (oval guide, "deleted in 24h", delete button, "try without your photo" → persona).
2. **Your colours:** best vs worst drape framing the face (hijab overlay as the frame), 6–8 named swatches + metal, undertone/contrast label,
   "Shop your colours". A "That's not me: warmer / cooler" toggle re-runs the rules for 0u.
3. **Compare on your body:** full-body photo requested here the first time. The off-palette colourway (the buyer's pick, or the worst match in the SKU)
   beside the palette pick, labelled on the garment, never on the skin.
4. **Complete the look:** makeup on the face photo + earrings/necklace in the palette metal.
5. **Look card → add bundle:** host page receives `drape:add-to-cart`; demo checkout is labelled as a demo.

Store pages never hide items: palette badges on colourway chips, "Yours" sorted first, empty state "None of this store's colours match yet — closest options".

## YouCam calls and units

| Step | API | Units |
|---|---|---|
| Colour reading | `skin-tone-analysis` (Facial Color Tones) | 20, once per face (24h cache) |
| Try-on | `cloth-v4` (`upper_body`/`outer`/`full_body`) | 2 |
| Compare (second colourway) | `cloth-v4` | 2 |
| Makeup | `makeup-vto` on the face photo | 1 |
| Jewelry | earrings / necklace | 1–2 |
| Seller pre-flight | `cloth-v4` per colourway | 2 |

New live buyer ≈ 27–28u · returning buyer 4–6u · judge persona 0u.
Ledger (≈959 left after gate 2): seller pre-flight ≈36u · judging reserve 400u · the rest for development and the video.

## Proven by gate tests (docs/derisk/)

- Clothes VTO keeps face, pose and body; flat-lay, on-model `outer`, and real colourway pairs keep the same silhouette (gate 1).
- **Abaya colourway pair, `full_body`, same shape in black and emerald** (gate 2).
- **On-model abaya photo → full abaya + head covering on the buyer, face visible** (gate 2); bag and niqab were not copied.
- Makeup on the face photo looks natural (gate 1).
- **Facial Color Tones** returns `skin_color`, `hair_color`, `eye_color`, `lip_color`, `eyebrow_color` (hex + names) and `face_quality`
  (`has_face`, `area`, `frontal`, `lighting`, `faceangle`). A downward-tilted face fails with `error_face_angle_downward` (no charge).
  Fixture: `docs/derisk/fixtures/a_color_tones.json`. Hair name can be wrong (blonde read as "Auburn"), so contrast uses the hex lightness, not the name.

## Requirements (accepted in review)

**Product**
- Colour reading uses Facial Color Tones only; undertone and contrast come from the hex values through tested, versioned JSON rules.
- The video and demo lead with the rejected colourway beside the approved one on the buyer's body.
- Shipped garments are synthetic, owned, CC0 or public domain, with no branding.
- Copy rules: judge the garment, never the skin; every "no" comes with a better "yes"; never call the user dark, light or fair; Arabic copy reviewed by a native speaker.

**Design**
- Two photos: face first, full body only at the first try-on.
- Interaction states (loading, empty, error, partial, cap reached, expired) are specified per step in `docs/history.md` (Phase 2); partial results always render what succeeded.
- Start/end layout from day 1; in RTL the approved render is on the reading-start side; 44px targets, focus rings, named swatches with text verdicts,
  body text ≥16px, 4.5:1 contrast.

**Developer experience**
- `YOUCAM_MODE=replay` is the default: recorded fixtures, 0 units, no key. Live mode needs `YOUCAM_API_KEY` and `YOUCAM_LIVE_BUDGET`.
- Embed snippet:
  ```html
  <script src="https://<host>/embed/v1.js" async></script>
  <button data-drape-product="dr_abaya_001" data-drape-colorway="emerald" data-drape-lang="ar">Try on with Drape</button>
  ```
- Identifiers: `productId` (`dr_…`), `colorwayId`, `garmentCategory`, `paletteVerdict`. "color" in code, "colour" in on-screen text.
- Errors: `{code, message, fix, docs_url, request_id}` with codes `DRAPE_PRODUCT_NOT_FOUND`, `DRAPE_DOMAIN_NOT_ALLOWED`, `DRAPE_BAD_KEY`,
  `DRAPE_IMAGE_TOO_SMALL`, `DRAPE_CATEGORY_UNSUPPORTED`, `DRAPE_POPUP_BLOCKED`, `DRAPE_BUDGET_EXHAUSTED`. `embed.js` warns in the console, never fails silently.
- Root README order: what it does → 60-second judge path → APIs used per step with units → run locally (replay) → embed snippet → API reference →
  extension (optional) → limitations.

**Engineering**
- Async job model; one long-lived host + SQLite + object storage, chosen before Day 1, up until Nov 20.
- Unit ledger: reserve → commit/release; a timed-out task stays reserved until reconciled; tested with two processes at the cap;
  auto-replay when the balance falls below the judging reserve.
- Public live mode: per-visitor (one new face) and global daily caps, optional judge code, persona fallback; the publishable key alone never spends units.
- Replay fixtures store bytes, never URLs; an unknown photo in replay returns the persona result labelled "sample"; a fresh clone makes zero calls to `*.makeupar.com`.
- Cache key = normalised-upload SHA-256 + session + API name/version + garment category + colorwayId + params + palette-rules version; 24h max;
  DELETE and the sweeper purge everything derived; EXIF stripped on upload.
- Seller console requires auth; keys stored hashed; pre-flight goes through the ledger; uploads checked by magic bytes and size.
- Cart events use `postMessage` with an explicit `targetOrigin` bound at session creation; `embed.js` validates `event.origin` and the session id.
- CI greps the built Flutter bundle for the key pattern; `/health` checks key presence, balance above reserve and replay assets; repeated upstream 5xx forces replay.
- Images are validated and resized before upload (EXIF orientation, long side ≤1920, ≤10MB, JPG/PNG); `face_quality` from Color Tones feeds the retake copy.
- Hijab overlay: choose client-side face landmarks or a fixed oval guide before building; fallback is colour swatches framing the face crop.

## Build tasks (status 2026-10-10)

Done (deployed, replay mode):
- [x] Cloudflare Worker + Durable Object (SQLite unit ledger, sessions, jobs), R2, hourly sweep cron, `/health`
- [x] YouCam adapter replay|live; named error mapping; live path proven end to end against a mock (`npm run test:e2e`)
- [x] Unit ledger reserve/commit/release/stuck + reconcile; per-visitor and daily caps; auto-replay after upstream failures; kill switch
- [x] Palette engine from Color Tones hex (versioned rules); warmer/cooler override
- [x] Cache/dedupe, 24h deletion, DELETE purge, EXIF strip; seller auth; error envelope; CORS only for public catalogue reads
- [x] `embed/v1.js` + `drape:add-to-cart`; Noor Modest demo shop on its own domain
- [x] Flutter web app: capture, hijab-drape reveal, shop with verdicts, Compare, makeup + earrings, look card, Arabic RTL, seller console
- [x] Earrings VTO (2D) in the palette metal; listing links + `/v1/lookup`; URL-only Chrome extension (activeTab only)
- [x] README, MIT licence, CI (typecheck, unit, e2e, secret scan, extension guard)
- [x] "Not sold yet" (round 5): YouCam AI Fabric re-makes her try-on in an opaque palette fabric
  (live only for templates checked for cut and modesty), free "ask the store" requests, seller Colour Demand panel, third product
- [x] Replay fixtures for the not-sold beat: persona try-on of the Everyday abaya in navy + Fabric Sea Green Silk (2026-10-12)

Waiting for the live switch (needs the owner's approval, spends units):
- [x] Persona renders for every catalogue colourway and persona makeup (earrings fail on the sample: ears covered by hair)
- [x] Synthetic persona (generated face + full body, warm/high) replaces the YouCam sample images: reading, makeup, all 9 colourways, Fabric (41u, 2026-10-12)
- [x] `YOUCAM_API_KEY` secret set; live with budget 400 via `npm run deploy:live` (config file stays replay)

Open:
- [x] DESIGN.md (atelier system for Drape, separate demo-store identity)
- [ ] Arabic copy review by a native speaker
- [ ] Repo public (licence in place) or shared with contact_event@PerfectCorp.com; demo video

Test plan: `~/.gstack/projects/Developer/ramymagdy-no-branch-eng-review-test-plan-20261010-200636.md`.
