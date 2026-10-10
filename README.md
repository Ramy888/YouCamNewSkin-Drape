# Drape — see the colour that suits you, on your own body, before you buy

Drape is a **"Try on with Drape"** button that modest-fashion stores add to their product pages.
One face photo is read by the **YouCam Facial Color Tones API**. Drape then shows the colourway that fights your colouring
next to the one that suits it, **on your own body** (YouCam **Clothes VTO**), finishes the look with a matching lip shade
(YouCam **Makeup VTO**) and jewellery metal, and hands the bundle back to the store's cart. English and Arabic (RTL).

Built for the YouCam API Skin AI & eCommerce VTO Hackathon (eCommerce VTO track).

## 60-second judge path

1. Open the demo shop: **https://noor-modest.ramy-comm.workers.dev** (a fictional store on its own domain).
2. Click **Try on with Drape** under the abaya. A Drape window opens.
3. Choose **Try with the sample person** (no photo, no sign-up). You'll see:
   - **Your colours** — read from the face photo by Facial Color Tones (warm undertone, gold metal).
   - **Compare** — two colourways of the same abaya on the same body.
   - **Complete the look** → **Add bundle to cart**. The look lands in the shop's own bag.
4. Prefer the Drape app directly? **https://drape.ramy-comm.workers.dev/app/**

The judge path runs in **replay mode**: every YouCam result shown was produced by a real API call during development and is
served from recorded fixtures, so judging never fails because of quota. A capped live mode ("use my photo") can be switched on;
see [Live mode](#live-mode).

## YouCam APIs used

| Step | YouCam API | Task name | Units | What Drape does with it |
|---|---|---|---|---|
| Your colours | AI Facial Color Tones | `skin-tone-analysis` | 20 (once per face, cached 24h) | skin / hair / eye hex → undertone (CIELAB hue angle) + contrast → palette |
| Compare + try-on | AI Clothes VTO v4 | `cloth-v4` | 2 per render | the chosen product colourway on the buyer's full-body photo (`full_body`, `upper_body`, `outer`) |
| Complete the look | AI Makeup VTO | `makeup-vto` | 1 | lip colour from the palette on the face photo |

Every call goes through the backend (the API key never reaches the browser). Flow per call: `POST /file/<task>` → `PUT` bytes →
`POST /task/<task>` → poll `GET /task/<task>/<id>` → copy the result into our storage (YouCam deletes results after 24h).

## How it works

```
 Store page ─ embed/v1.js ─(popup, never an iframe)─▶ Drape web app (Flutter web, /app/)
                                                          │ REST + polling
 Seller console (/app/#/seller, secret key) ─────────────▶ Cloudflare Worker
                                                          ├─ Durable Object "DrapeState" (SQLite): stores, products, sessions, jobs, unit ledger
                                                          ├─ YouCam adapter: replay (default, 0 units) | live (key + budget required)
                                                          ├─ Palette engine (versioned JSON rules, unit-tested)
                                                          ├─ R2: uploaded photos + results (deleted after 24h; EXIF stripped)
                                                          └─ Cron (hourly): deletes expired sessions, photos and results
```

- **Unit ledger:** every paid call reserves units first and commits on success or releases on error. A timed-out task stays
  reserved until reconciled (YouCam may still charge for it). One Durable Object = one writer, so two requests can never both pass the cap.
- **Limits in live mode:** one new face reading per visitor per day, a global daily cap, a total budget, optional judge code.
  When any limit is hit, the buyer sees the labelled sample result instead of an error.
- **Kill switch:** `FORCE_REPLAY=1`, and three upstream failures in a row (or one auth failure) switch to replay for 30 minutes.

## Run locally (replay mode, no API key, no units)

Requirements: Node 20+, Flutter 3.41+ (only to rebuild the app).

```bash
git clone https://github.com/Ramy888/YouCamNewSkin-Drape.git && cd YouCamNewSkin-Drape
cd backend && npm install && npm test        # 40+ tests: palette, ledger, adapter, images, tokens
npx wrangler dev --port 8787                  # API + app + embed on http://localhost:8787
# in another terminal: the demo shop on a second origin
cd stores/noor && npx --prefix ../../backend wrangler dev --port 8788
```

Open http://localhost:8788 and click **Try on with Drape**. A fresh clone makes **zero** calls to YouCam.

To rebuild the web app: `cd app && flutter build web --release --base-href /app/ -o ../backend/public/app`.

## Add the button to a store

```html
<script src="https://drape.ramy-comm.workers.dev/embed/v1.js" data-drape-key="pk_demo_drape" async></script>

<button data-drape-product="abaya-classic" data-drape-colorway="emerald" data-drape-lang="ar">
  Try on with Drape
</button>

<script>
  // Drape hands the chosen look back to your cart.
  document.addEventListener("drape:add-to-cart", (e) => {
    console.log(e.detail.items); // [{ productId, colorwayId }]
  });
</script>
```

The store's origin must be on the allowed list (`ALLOWED_ORIGINS`). Misconfiguration is reported in the browser console with a fix.

## API reference (v1)

| Method | Path | Auth | Purpose |
|---|---|---|---|
| GET | `/v1/catalog?key=pk_…` | publishable key | published products of a store |
| GET | `/v1/products/:id` | none | one product (CORS open, public data) |
| POST | `/v1/products` | `Bearer sk_…` | create / update a product and its colorways |
| PUT | `/v1/products/:id/colorways/:cid/image` | `Bearer sk_…` | upload a colorway image (JPEG/PNG ≤ 10 MB) |
| POST | `/v1/sessions` | publishable key in body | start a buyer session `{key, storeOrigin, persona?}` → `{token, session}` |
| GET / DELETE | `/v1/sessions/me` | `Bearer <token>` | session state / delete everything for this session |
| POST | `/v1/sessions/me/photos?kind=face\|body` | token | upload a photo (raw bytes) |
| POST | `/v1/sessions/me/jobs` | token | `{type: color_reading \| tryon \| makeup, productId?, colorwayId?}` → job |
| GET | `/v1/jobs/:id` | token | job status and result |
| POST | `/v1/sessions/me/palette` | token | `{override: "warmer" \| "cooler" \| null}` (0 units) |
| GET | `/v1/admin/products` | `Bearer sk_…` | all products, including drafts and disabled ones |
| GET | `/v1/admin/ledger` | `Bearer sk_…` | unit ledger summary |
| GET | `/health` | none | mode, key present, units, replay assets |

## Errors

Every error has the same shape:

```json
{ "error": { "code": "DRAPE_DOMAIN_NOT_ALLOWED", "message": "…", "fix": "…", "docs_url": "…", "request_id": "…" } }
```

Codes: `DRAPE_BAD_REQUEST`, `DRAPE_BAD_KEY`, `DRAPE_UNAUTHORIZED`, `DRAPE_DOMAIN_NOT_ALLOWED`, `DRAPE_PRODUCT_NOT_FOUND`,
`DRAPE_SESSION_NOT_FOUND`, `DRAPE_JOB_NOT_FOUND`, `DRAPE_IMAGE_INVALID`, `DRAPE_IMAGE_TOO_LARGE`, `DRAPE_CATEGORY_UNSUPPORTED`,
`DRAPE_PHOTO_MISSING`, `DRAPE_BUDGET_EXHAUSTED`, `DRAPE_NOT_FOUND`, `DRAPE_INTERNAL`.
YouCam photo errors (for example `error_face_angle_downward`, `error_multi_person`, `error_pose`) become retake advice for the buyer.

## Live mode

Off by default. To turn it on (spends YouCam units):

```bash
cd backend
npx wrangler secret put YOUCAM_API_KEY
# in wrangler.jsonc vars: "YOUCAM_MODE": "live", "YOUCAM_LIVE_BUDGET": "<units>", optional "JUDGE_CODE"
npx wrangler deploy
```

## Privacy

Photos and results are deleted after 24 hours (hourly sweeper) or immediately with **Delete my photos**. JPEG metadata (GPS,
camera serials) is stripped on upload and the app re-encodes photos on the device. Raw IPs are never stored: visitor limits use a
salted daily hash.

## Limitations

- Replay mode serves recorded results for the sample person; a real photo in replay mode gets the sample result, clearly labelled.
- Makeup preview for the sample person is not recorded yet (the lip shade is shown as a swatch).
- The hijab frame on the reveal is a colour frame around the face, not a rendered hijab.
- Garment images: the abaya photo is public domain (Wikimedia Commons); colourways are recoloured from it.

## Repository

- `backend/` — Cloudflare Worker, Durable Object, tests, static assets (`public/`: app build, embed script, persona fixtures, catalogue)
- `app/` — Flutter web app (buyer flow + seller console)
- `stores/noor/` — the fictional demo shop
- `docs/product.md` — build spec · `docs/derisk/` — API gate tests and recorded fixtures · `docs/history.md` — planning history

## License

MIT — see [LICENSE](LICENSE).
