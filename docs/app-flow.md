# Drape: app flow (draft for approval, 2026-10-10)

Variant: **Drape, safer variant**. One outfit render per look; the colour verdict is delivered by the face drape
overlay, makeup shades, and jewelry metal. `[Nu]` = YouCam units per call. `[0u]` = local, free.

## User flow

```
 ┌──────────────────────────────┐
 │ 1. WELCOME                   │  AR / EN toggle (RTL) · "Buy the colour that suits you"
 │    consent: photo use, 24h   │  [0u]
 └──────────────┬───────────────┘
                ▼
 ┌──────────────────────────────┐
 │ 2. SELFIE (face)             │  camera + oval framing guide (face > 60% width,
 │    local quality check       │  no glasses, even light) · retake if it fails  [0u]
 └──────────────┬───────────────┘
                ▼
 ┌──────────────────────────────┐
 │ 3. COLOUR READING            │  demo mode: Fitzpatrick skin type ........ [2u]
 │    → undertone profile       │  premium:  Facial Color Tones ............ [20u]
 │    (cached per user forever) │  → palette table (JSON, deterministic):
 └──────────────┬───────────────┘    suits[] · avoid[] · metal: gold|silver ·
                ▼                    foundation + lip shade family
 ┌──────────────────────────────┐
 │ 4. THE DRAPE REVEAL  ★ wow   │  fabric swatches swing around the face:
 │    (incl. hijab drape)       │  3 "grey you out", 2 "light you up"  [0u]
 └──────────────┬───────────────┘
                ▼
 ┌──────────────────────────────┐
 │ 5. SHOP, RE-SORTED BY FACE   │  "Suits you" first · "Washes you out" badge
 │    (synthetic brands)        │  each product has real colourway photos  [0u]
 └──────────────┬───────────────┘
                ▼  tap a product → pick a colourway
                │       (vetoed colourway allowed, but the drape overlay shows why)
 ┌──────────────────────────────┐
 │ 6. FULL-BODY PHOTO (once)    │  framing guide: one person, facing front,
 │                              │  fills ≥80% of the frame  [0u]
 └──────────────┬───────────────┘
                ▼
 ┌──────────────────────────────┐
 │ 7. TRY IT ON                 │  Clothes VTO v4 (upper/lower/full/outer) .. [2u]
 │                              │  cached by (photo, sku, colourway)
 └──────────────┬───────────────┘
                ▼
 ┌──────────────────────────────┐
 │ 8. "MATCH MY FACE"           │  Makeup VTO: foundation + lip from palette  [1u]
 │                              │  Earrings or Necklace in the palette metal  [1u]
 └──────────────┬───────────────┘
                ▼
 ┌──────────────────────────────┐
 │ 9. LOOK CARD                 │  before ↔ after slider · "why this colour" chip
 │    → ADD BUNDLE TO CART      │  (outfit + shade + jewelry as one bundle)  [0u]
 └──────────────┬───────────────┘
                ▼
 ┌──────────────────────────────┐
 │ 10. CHECKOUT (mock) → DONE   │  order summary · share look  [0u]
 └──────────────────────────────┘
```

**Units per new user session:** about 6–7 in demo mode (2 + 2 + 1 + 1–2); about 24–25 in premium mode. A returning user pays only for
new try-ons (2–4).

## System flow (every paid call goes through the backend)

```
 Flutter app ──HTTPS──▶ Backend proxy (holds YOUCAM_API_KEY, never the client)
                          │ 1. budget guard: per-session cap + global cap; DEMO mode = 0u
                          │ 2. cache lookup (hash of photo + sku + params) ─ hit ─▶ return stored image
                          │ 3. miss: POST /file → PUT bytes → POST /task/<api> → poll GET until success/error
                          │ 4. copy result into our storage (YouCam deletes after 24h) → cache it
                          ▼
                       Storage (images + palette profile) ◀── app reads results
```

**Judge / demo mode:** a pre-rendered persona (all steps cached once) so judges can click through until Nov 20 without spending units.
Live mode is for their own photo, behind the per-session cap.

## Open risks to verify (each test needs the owner's approval; costs are estimates)

1. **Chaining (step 7 → 8):** can Makeup VTO run on the *clothes VTO output*? In a full-body image the face may be under Makeup VTO's
   minimum (face ≥100 px), so the call may fail. Fallback: apply makeup to the selfie and show it as a face close-up next to the outfit. Test ≈ 1–3u.
2. **Fitzpatrick → palette:** is skin type alone enough to drive the undertone (warm/cool)? If not, use Color Tones (20u) only once per user.
3. **Real colourway shots:** does the garment shape stay stable across colourways when the reference photos are real and clean? Only matters if we show side by side.
