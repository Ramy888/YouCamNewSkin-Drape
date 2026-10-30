# Drape — see the colour that suits you, on your own body, before you buy

Drape is a **"Try on with Drape"** button that modest-fashion stores add to their product pages.
One face photo is read by the **YouCam Facial Color Tones API**. Drape then shows the colourway that fights your colouring
next to the one that suits it, **on your own body** (YouCam **Clothes VTO**), finishes the look with a matching lip shade
(YouCam **Makeup VTO**) and earrings in the right metal (YouCam **Earrings VTO**), and hands the bundle back to the store's cart.
When none of a garment's colours suit her, YouCam **AI Fabric** re-makes her own try-on in a fabric from her palette, "not sold yet",
and she can ask the store to make it; the seller sees that demand in the console. English and Arabic (RTL).

Built for the YouCam API Skin AI & eCommerce VTO Hackathon (eCommerce VTO track).

## 60-second judge path

1. Open the demo shop: **https://noor-modest.ramy-comm.workers.dev** (a fictional store on its own domain).
2. Click **Try on with Drape** under the abaya. Drape opens in a new tab.
3. Choose **Try with the sample person** (no photo, no sign-up). You'll see:
   - **Your colours** — read from the face photo by Facial Color Tones (warm undertone, gold metal).
   - **Compare** — two colourways of the same abaya on the same body.
   - **Complete the look** → **Add bundle to cart**. The look lands in the shop's own bag.
4. Prefer the Drape app directly? **https://drape.ramy-comm.workers.dev/app/**

The sample-person path is served from recordings of real YouCam calls, so it costs nothing and never fails. **Use my photo**
runs live YouCam calls under a capped budget (one new face reading per visitor per day); when a limit is hit, the buyer sees the
labelled sample result instead of an error. See [Live mode](#live-mode).

## YouCam APIs used

| Step | YouCam API | Task name | Units | What Drape does with it |
|---|---|---|---|---|
| Your colours | AI Facial Color Tones | `skin-tone-analysis` | 20 (once per face, cached 24h) | skin / hair / eye hex → undertone (CIELAB hue angle) + contrast → palette |
| Compare + try-on | AI Clothes VTO v4 | `cloth-v4` | 2 per render | the chosen product colourway on the buyer's full-body photo (`full_body`, `upper_body`, `outer`) |
| Complete the look | AI Makeup VTO | `makeup-vto` | 1 | lip colour from the palette on the face photo |
| Complete the look | AI Earrings VTO (2D) | `2d-vto/earring` | 1 | an earring in the palette metal (gold, silver or rose gold) on the face photo |
| Not sold yet | AI Fabric | `fabric` | 2 (one per session) | her try-on re-made in an opaque fabric template the palette rates "yours" (only templates checked to keep the cut and modesty) |

Every call goes through the backend (the API key never reaches the browser). Flow per call: `POST /file/<task>` → `PUT` bytes →
`POST /task/<task>` → poll `GET /task/<task>/<id>` → copy the result into our storage (YouCam deletes results after 24h).

## How it works

```
 Store page ─ embed/v1.js ─(new tab, never an iframe)─▶ Drape web app (Flutter web, /app/)
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

## Drape catalogue (all stores)

Opened directly (https://drape.ramy-comm.workers.dev/app/), Drape is a catalogue of every partner store's products, sorted by what
suits you, with search and store filters. Try any piece on, then **Buy at {store}** opens that store's page to check out. Demo stores
are fictional: **Noor Modest** (https://noor-modest.ramy-comm.workers.dev) and **Layla Boutique**
(https://layla-boutique.ramy-comm.workers.dev), both built from one page template (`stores/noor/public/index.html`, configured by
each store's `config.js`). Stores integrate with one script tag (below) or the REST API; `GET /v1/stores` lists partner stores.

## Chrome extension (optional)

On a product page whose link the seller added to Drape, one click on the Drape icon opens Drape for that product.
The extension uses only the page address (`activeTab` permission; no content scripts, no host access), and CI checks that.

1. Install it from the [Chrome Web Store](https://chromewebstore.google.com/detail/drape-see-the-colour-that/ecbnnlodjpegdmdflgnkhcplfcimacnc).
2. Open the demo shop and click the Drape icon in the toolbar.

To run it from source, load the `extension/` folder with **Load unpacked** on `chrome://extensions` (Developer mode on).

Sellers add links in the seller console ("Where you sell it"). Amazon listings match by ASIN on any Amazon domain.

## Run locally (replay mode, no API key, no units)

Requirements: Node 20+, Flutter 3.41+ (only to rebuild the app).

```bash
git clone https://github.com/Ramy888/YouCamNewSkin-Drape.git && cd YouCamNewSkin-Drape
cd backend && npm install && npm test        # unit tests: palette, ledger, adapter, images, tokens
npm run test:e2e                              # live mode end to end against a mock YouCam (no key, no units)
npx wrangler dev --port 8787                  # API + app + embed on http://localhost:8787
# in another terminal: the demo shop on a second origin
cd stores/noor && npx --prefix ../../backend wrangler dev --port 8788
```

Open http://localhost:8788 and click **Try on with Drape**. A fresh clone makes **zero** calls to YouCam.

To rebuild the web app: `cd app && flutter build web --release --base-href /app/ --no-wasm-dry-run --output ../backend/public/app`.

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
| GET | `/v1/stores` | none | partner stores and how many products each has on Drape |
| GET | `/v1/lookup?url=…` | none | the product whose seller-added listing link matches this page address |
| POST | `/v1/products` | `Bearer sk_…` | create / update a product and its colorways |
| PUT | `/v1/products/:id/colorways/:cid/image` | `Bearer sk_…` | upload a colorway image (JPEG/PNG ≤ 10 MB) |
| POST | `/v1/sessions` | publishable key in body | start a buyer session `{key, storeOrigin, persona?}` → `{token, session}` |
| GET / DELETE | `/v1/sessions/me` | `Bearer <token>` | session state / delete everything for this session |
| POST | `/v1/sessions/me/photos?kind=face\|body` | token | upload a photo (raw bytes) |
| POST | `/v1/sessions/me/jobs` | token | `{type: color_reading \| tryon \| makeup \| jewelry \| recolor, productId?, colorwayId?, template?}` → job |
| GET | `/v1/jobs/:id` | token | job status and result |
| POST | `/v1/sessions/me/requests` | token | `{productId, template}`: ask the store for a colour it doesn't sell (free) |
| GET | `/v1/admin/demand` | `Bearer sk_…` | per product: tried, told "fights your colouring", requested (real buyers and demo counted apart) |
| POST | `/v1/sessions/me/palette` | token | `{override: "warmer" \| "cooler" \| null}` (0 units) |
| GET | `/v1/admin/products` | `Bearer sk_…` | all products, including drafts and disabled ones |
| GET | `/v1/admin/ledger` | `Bearer sk_…` | unit ledger summary and `role` (`owner` or `judge`) |
| GET | `/health` | none | mode, key present, units, replay assets |

## Errors

Every error has the same shape:

```json
{ "error": { "code": "DRAPE_DOMAIN_NOT_ALLOWED", "message": "…", "fix": "…", "docs_url": "…", "request_id": "…" } }
```

Codes: `DRAPE_BAD_REQUEST`, `DRAPE_BAD_KEY`, `DRAPE_UNAUTHORIZED`, `DRAPE_READ_ONLY`, `DRAPE_DOMAIN_NOT_ALLOWED`, `DRAPE_PRODUCT_NOT_FOUND`,
`DRAPE_SESSION_NOT_FOUND`, `DRAPE_JOB_NOT_FOUND`, `DRAPE_IMAGE_INVALID`, `DRAPE_IMAGE_TOO_LARGE`, `DRAPE_CATEGORY_UNSUPPORTED`,
`DRAPE_PHOTO_MISSING`, `DRAPE_BUDGET_EXHAUSTED`, `DRAPE_NOT_FOUND`, `DRAPE_INTERNAL`.
YouCam photo errors (for example `error_face_angle_downward`, `error_multi_person`, `error_pose`) become retake advice for the buyer.

## Live mode

Off by default: `wrangler.jsonc` keeps `YOUCAM_MODE=replay` and a budget of 0, so a clone or CI never spends units.
The hosted demo is deployed live with a judging budget:

```bash
cd backend
npx wrangler secret put YOUCAM_API_KEY
npm run deploy:live        # wrangler deploy --var YOUCAM_MODE:live --var YOUCAM_LIVE_BUDGET:400
```

A plain `npm run deploy` puts production back in replay mode.

Optional `JUDGE_SELLER_KEY` secret: a view-only seller key for judges. It can read the console (products, ledger); every write
(save, photo upload, reconcile) returns `DRAPE_READ_ONLY`. `FORCE_REPLAY=1` is the kill switch.

## Privacy

Photos and results are deleted after 24 hours (hourly sweeper) or immediately with **Delete my photos**. JPEG metadata (GPS,
camera serials) is stripped on upload and the app re-encodes photos on the device. Raw IPs are never stored: visitor limits use a
salted daily hash.

## Limitations

- In replay mode a real photo gets the sample person's result, clearly labelled.
- Earring try-on needs visible ears. With a hijab it fails (free of charge) and the look shows the palette metal instead.
- The colour drape on "Your colours" is drawn around the face photo; it is not a rendered hijab.
- Clothes VTO can vary a garment's details between renders (for example sleeve shape); the colour comparison stays clear.
- Garment images are public domain or CC0 (sources in `docs/derisk/IMAGE_SOURCES.md`); colourways are recoloured locally.

## Repository

- `backend/` — Cloudflare Worker, Durable Object, tests, static assets (`public/`: app build, embed script, persona fixtures, catalogue)
- `app/` — Flutter web app (buyer flow + seller console)
- `stores/noor/`, `stores/layla/` — the fictional demo shops
- `extension/` — the URL-only Chrome extension
- `DESIGN.md` — design system · `docs/submission/` — Devpost write-up and Arabic review sheet
- `docs/product.md` — build spec · `docs/derisk/` — API gate tests and recorded fixtures · `docs/history.md` — planning history

## License

MIT — see [LICENSE](LICENSE).
