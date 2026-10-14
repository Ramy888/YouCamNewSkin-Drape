# Devpost submission: Drape

Draft for the Devpost form, section by section. Paste each block into the matching field.
Track: **eCommerce VTO**. Every link and number below was checked against the live deployment on 2026-10-11.

---

## Project name

Drape

## Elevator pitch (200 characters max)

A "Try on with Drape" button for modest-fashion stores: YouCam reads your colouring from one photo, then shows the colour that fights you beside the one that suits you, on your own body.

---

## Inspiration

In modest fashion the garment covers almost everything, so the colour next to the face carries the whole outfit. An abaya or a hijab
in the wrong colour makes the wearer look tired, and the buyer only finds out after it arrives. Online stores show each colourway on a
model, never on the buyer, and "which colour suits me?" stays a guess. Returns follow.

Most try-on tools answer "does it fit my body?". We wanted to answer the question modest-fashion buyers actually ask: **"which of these
colours is mine?"**, and to answer it with a measurement rather than an opinion, inside the store's own checkout.

## What it does

Drape is a button a store adds to its product pages. When a buyer clicks **Try on with Drape**:

1. **Your colours.** One face photo goes to **YouCam AI Facial Color Tones**, which returns the skin, hair, eye and lip colours as hex
   values. Drape turns them into an undertone (warm / cool / neutral) and a contrast level, and from those into a palette: colours that
   lift the buyer, colours that fight them, a lip shade and a jewelry metal. The buyer sees the result as two fabric drapes framing
   their own face, one in their best colour, one in their worst.
2. **Shop your colours.** The store's catalogue is re-sorted for that buyer. Nothing is hidden; every colourway carries a plain-words
   verdict ("Yours", "Could work", "Not your colour").
3. **Compare.** The same garment in two colours, side by side **on the buyer's own body** via **YouCam AI Clothes VTO**: the colourway
   that suits them next to the one that fights them. Verdicts describe the garment ("Lifts your colouring"), never the person's skin.
4. **Complete the look.** **YouCam AI Makeup VTO** puts the matching lip shade on the face photo, and **YouCam Earrings VTO** shows an
   earring in the palette metal (gold, silver or rose gold).
5. **Add the look to cart.** The bundle goes back to the store's own cart through a browser event; Drape never takes the checkout.
6. **Not sold yet.** When none of a garment's colours suit her, **YouCam AI Fabric** re-makes her own try-on in a fabric her palette
   rates "yours" (for example Sea Green Silk, close to her Deep teal), beside the colour she would settle for. She taps **Ask the
   store to make it**, and the seller's console counts that demand: colours tried, colours the palette rejected, colours requested,
   with demo sessions counted apart from real buyers. Stores learn which colour to make before they make it.

Around the buyer flow:

- **Drape catalogue.** Opened directly, Drape lists every partner store's products sorted by what suits her, with search and store
  filters; she tries any piece on and **Buy at {store}** sends her to that store to check out. Stores join with one script tag or
  the REST API.
- **Seller console.** Sellers add products and colourways (with a colour picker of named garment colours), upload one clean photo per
  colour, list where else the product is sold, and watch the YouCam unit ledger. Judges get a view-only key.
- **Chrome extension (URL only).** On a product page the seller has linked, one click opens Drape for that product. It reads only the
  page address; it never reads page content or crawls.
- **English and Arabic** with a full right-to-left layout, built for the MENA modest-fashion market.

## How we built it

- **Frontend:** Flutter web (one codebase for the buyer flow and the seller console), served by the backend at `/app/`.
- **Backend:** a Cloudflare Worker with one Durable Object (SQLite) holding stores, products, sessions, jobs and the unit ledger;
  R2 for photos and results; an hourly cron that deletes everything older than 24 hours.
- **YouCam integration:** every call runs server side (the API key never reaches the browser): upload the file, create the task,
  poll with backoff, then copy the result into our own storage because YouCam keeps results for 24 hours. YouCam error codes become
  retake advice the buyer can act on ("Lift your chin a little", "Only one person should be in the photo").
- **Palette engine:** the hex values from Facial Color Tones are converted to CIELAB. Undertone comes from the skin's hue angle,
  contrast from the lightness gap between skin, hair and eyes, and garment verdicts from the colour distance (CIE76 ΔE) to the palette.
  The rules live in a versioned JSON file and are unit-tested.
- **Unit ledger:** every paid call reserves units first, then commits on success or releases on error. Live mode has a total budget,
  a daily cap and one new face reading per visitor per day. When a limit is hit, the buyer gets the labelled sample result instead of
  an error, and repeated upstream failures switch the app to recorded results for 30 minutes.
- **Embed:** one script tag plus a `data-drape-product` button. Drape opens in a new tab (never an iframe) and returns the cart with a
  `postMessage` bound to the store's origin.
- **Tests:** 58 backend unit tests (palette, ledger, adapter, links, fabric choice), a 49-check end-to-end test of the live path against a mock
  YouCam server (including the view-only judge key and the Fabric limits), and 62 Flutter tests (right-to-left layout, phone,
  tablet and laptop sizes, view-only console, not-sold flow). CI also scans for secrets and checks
  that a fresh clone makes zero calls to YouCam.

## YouCam APIs used

| Step | API | Task | Units |
|---|---|---|---|
| Your colours | AI Facial Color Tones | `skin-tone-analysis` | 20, once per face (cached 24 h) |
| Compare and try-on | AI Clothes VTO v4 | `cloth-v4` (`full_body`, `outer`, `upper_body`) | 2 per render |
| Complete the look | AI Makeup VTO | `makeup-vto` (lip colour) | 1 |
| Complete the look | AI Earrings VTO | `2d-vto/earring` | 1 |
| Not sold yet | AI Fabric | `fabric` (opaque templates checked for cut and modesty) | 2, one per session |

A new buyer costs about 26 units; a returning buyer about 4–6.

## Challenges we ran into

- **There is no hijab or abaya try-on API.** The Scarf API is a Western neck scarf. Before writing product code we spent units on gate
  tests: Clothes VTO with `full_body` and `outer` keeps the abaya's shape across colourways and transfers an on-model abaya with its
  head covering. Hand-masked recolours, on the other hand, changed the garment's shape between calls, so every colourway needs a clean,
  real product photo. That finding shaped the seller console.
- **Covered ears.** Earring try-on fails when the ears are hidden, which is the normal case for a buyer in hijab. YouCam reports it as
  "earlobe alignment not confident", so we map it to a friendly message and keep showing the palette metal.
- **Being judged on a quota.** Judges must be able to test until Nov 20 without the demo breaking. The answer was the unit ledger with
  caps, a sample-person path that costs nothing, and an automatic fallback to recorded results.
- **A fabric API that can undress a modest garment.** AI Fabric only offers fixed templates and re-renders the whole outfit. Our gate
  test showed a sheer template (organza) turned an abaya into a crop top and skirt, while silk and wool kept the cut. Drape only offers
  opaque templates, picks them with the same palette engine (never one rated "avoid"), and in live mode only those whose render we checked.
- **Saying "no" kindly.** The product tells people a colour does not suit them. The copy rules are strict: judge the garment, never the
  skin; every "no" comes with a better "yes"; never describe the buyer as dark, light or fair. A test checks the verdict copy for it.

## Accomplishments that we're proud of

- One face reading drives five YouCam APIs and a real buying decision, not a gallery of effects.
- The "rejected colour beside the approved one, on your own body" comparison makes the value obvious in a few seconds.
- It plugs into an existing store with one script tag and hands back to the store's own cart.
- Arabic right-to-left is a first-class layout, not a translation pass: the approved colour sits on the reading-start side in both languages.
- Privacy by default: photos and results are deleted after 24 hours or on demand, and photo metadata is stripped on upload.

## What we learned

- Clothes VTO is reliable when the garment photo is a clean, real product shot, and unreliable on synthetic recolours. The garment input
  matters more than any parameter.
- Facial Color Tones returns hex values precise enough to build a palette from, but the colour *names* can be wrong (blonde read as
  "Auburn"), so we use the hex values only.
- Budget and failure handling are product features: a judge or a shopper should never see a quota error.

## What's next for Drape

- Shopify and WooCommerce apps that add the button without code.
- Seller pre-flight: a test render of each new colourway before it goes live.
- Necklace and hijab-pin try-on in the palette metal, and full-face makeup looks matched to the outfit.
- A colour profile the buyer can keep and reuse across stores.

## Built with

flutter, dart, cloudflare-workers, durable-objects, sqlite, cloudflare-r2, typescript, youcam-api, chrome-extension

---

## Try it out (links)

- Demo store with the button: https://noor-modest.ramy-comm.workers.dev
- Second demo store: https://layla-boutique.ramy-comm.workers.dev
- Drape app: https://drape.ramy-comm.workers.dev/app/
- Seller console: https://drape.ramy-comm.workers.dev/app/#/seller (sign-in key in the testing instructions)
- Chrome extension: https://chromewebstore.google.com/detail/ecbnnlodjpegdmdflgnkhcplfcimacnc
  (Devpost link swapped from the zip on 2026-10-14; the store item was submitted the same day and is pending Google's review,
  so the link opens only once it is approved. The zip stays at https://drape.ramy-comm.workers.dev/extension/drape-extension.zip.)

The source code link is **not** a public "Try it out" link (Ramy removed it on 2026-10-13); it lives only in Additional info
("URL to your code repository"), which is for judges and organizers.

## Testing instructions (for judges)

No account or sign-up is needed. The app runs in English and Arabic (switch with the button at the top right).

**Path A: sample person, about 1 minute, always available**

1. Open https://noor-modest.ramy-comm.workers.dev. It is a fictional store, labelled as a demo.
2. Under the abaya, click **Try on with Drape**. Drape opens in a new tab.
3. Click **Try with the sample person**.
4. **Your colours:** the reading from YouCam Facial Color Tones, shown as the best and worst colour framing the face.
5. **Shop your colours** → **See it on me** on the abaya: the emerald colourway (suits her) beside lavender (fights her), on her body.
6. **Complete the look:** lip shade and metal. **Add the look to cart**: the store's bag opens with the look in it.

The sample person's results were produced by real YouCam calls and are served from recordings, so this path costs nothing and never
fails.

**Path B: your own photo (live YouCam calls)**

1. Open https://drape.ramy-comm.workers.dev/app/ and click **Use my photo**.
2. Upload a front-facing face photo in even light, then a full-length photo when asked (one person, head to feet).
3. Each visitor gets one new face reading per day. If the shared judging budget runs out, Drape shows the labelled sample result
   instead of an error.
4. **Delete my photos** removes everything immediately; otherwise photos are deleted after 24 hours.

**Path D: not sold yet (YouCam AI Fabric).** With the sample person, open Shop your colours, scroll to "Everyday satin abaya" (none
of its colours suit her), tap **See it in Sea Green Silk**, then **Ask the store to make it**. The request appears in the seller
console under Colour demand, counted as demo.

**Path E: the Drape catalogue.** Open https://drape.ramy-comm.workers.dev/app/, try with the sample person, then **Shop your
colours**: search, filter by store (Noor Modest, Layla Boutique, both fictional), **See it on me**, and **Buy at {store}** on the
look card. Layla Boutique (https://layla-boutique.ramy-comm.workers.dev) has its own Drape button too.

**Seller console (view-only judge access):** https://drape.ramy-comm.workers.dev/app/#/seller. The judge key is given in the
Devpost "Additional info" (judges only) and is kept out of this public repository. It shows everything; saving, uploads and unit
reconciling are refused by the server.

**Chrome extension (optional):** install it from the Chrome Web Store link above, or download
https://drape.ramy-comm.workers.dev/extension/drape-extension.zip, unzip, open `chrome://extensions`, turn on Developer mode, click
**Load unpacked**, choose the folder, open the demo store and click the Drape icon.

## Built since the submission period opened

The project is new. The repository's first commit is dated 2026-10-10, after the submission period opened on Sep 29, 2026.

## Video (to record)

1–3 minutes, public on YouTube. It must name and explain each YouCam API, show the app running in the browser, use no third-party
trademarks or copyrighted music, and be narrated or subtitled in English.
