# Chrome Web Store: Drape extension listing

Everything needed to publish `extension/` (v1.0.1). The upload, account and payment steps are yours; the content is ready.

## Files

| What | File | Store requirement |
|---|---|---|
| Package | `drape-extension-1.0.1.zip` (same as `backend/public/extension/drape-extension.zip`) | ZIP with `manifest.json` at the root |
| Icon | inside the package, `icons/icon128.png` | 128×128 |
| Screenshots | `assets/screenshot_1_extension.png` … `screenshot_4_catalogue.png` | 1280×800, 1–5 |
| Small promo tile | `assets/promo_small_440x280.png` | 440×280 |
| Privacy policy | https://drape.ramy-comm.workers.dev/privacy | public URL |

Regenerate the images with `node docs/chrome-web-store/make_assets.mjs <popup harness URL>` then `python3 docs/chrome-web-store/compose.py`.

## Store listing tab

- **Name:** Drape: see the colour that suits you
- **Summary (≤132 chars):** On a shop's product page, one click opens Drape to see which colour of that garment suits you, on your own body.
- **Category:** Shopping
- **Language:** English
- **Description:**

  > Shopping for modest fashion online and not sure which colour is yours? Drape shows you.
  >
  > On a product page from a shop that works with Drape, click the Drape icon. If the seller has added the product, Drape opens in
  > a new tab: one face photo (or our sample person, no photo needed) reads the colours that suit you, then you see the colour that
  > fights you beside the one that lifts you, on your own body, with a matching lip shade and jewelry metal. Checkout stays at the
  > shop.
  >
  > Not on Drape yet? Browse Drape's catalogue of partner stores instead.
  >
  > Private by design: the extension reads only the address of the page you click it on, never the page content. It has no
  > background code and stores nothing. Photos you choose to upload in Drape are deleted after 24 hours.
  >
  > Powered by the YouCam API by Perfect Corp. English and Arabic.

## Privacy practices tab

- **Single purpose:** Open Drape's colour try-on for the product on the current shop page, when the seller has added it to Drape.
- **Permission justification, `activeTab`:** Used only when the user clicks the icon, to read the current tab's address so Drape can
  check whether a seller added that product. No other permissions, no host permissions, no content scripts.
- **Remote code:** No. All code is in the package.
- **Data usage (disclose):** *Web history* — the address of the current page, sent to Drape only when the user clicks the icon, used to
  find the product, not stored. Nothing else is collected.
- **Certify:** not sold to third parties; not used for purposes unrelated to the single purpose; not used for creditworthiness or
  lending.
- **Privacy policy URL:** https://drape.ramy-comm.workers.dev/privacy

## Publishing steps (yours)

1. Go to the Chrome Web Store Developer Dashboard (chrome.google.com/webstore/devconsole) and register as a developer
   (one-time US$5 fee, Google account, identity verification).
2. **Items → New item** → upload `drape-extension-1.0.1.zip`.
3. Fill the Store listing and Privacy practices tabs with the text above; upload the four screenshots and the small promo tile.
4. **Distribution:** Public (or Unlisted to share by link first). Regions: all.
5. **Submit for review.** Review usually takes from a day to a few weeks; a single `activeTab` permission is the fastest
   kind to review. Until it's approved, judges can load it unpacked (README, "Chrome extension").
6. Once published, send me the store URL and I'll add it to the README and the Devpost "Try it out" links.
