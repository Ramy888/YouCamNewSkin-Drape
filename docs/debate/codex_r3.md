1. **Seller-side verdict: strengthen, but only if it becomes the core reliability layer.** Drape should not depend on messy buyer-scraped product photos. Sellers prepare each SKU before buyers arrive: upload clean front-facing product/colorway shots, choose category (`upper_body`, `full_body`, `outer`, etc.), tag color family, undertone fit, metal pairing, fabric finish, and optionally approve seller-time test renders on a standard model.

Seller-time YouCam calls: optional Clothes VTO validation on a stock/persona body for each colorway, plus maybe pre-rendered demo assets for judges. Seller pays these units because it is catalog onboarding, like product photography.

Buyer-time YouCam calls: tone read once, then Clothes VTO on the buyer’s body, Makeup VTO on face or full output if supported, jewelry VTO if used. Buyer, retailer, or platform pays depending on business model, but the app should present it as retailer-funded confidence, not a user tax.

This strengthens both hackathon and business: it turns Drape from “consumer app hoping random images work” into “commerce infrastructure for color-confidence shopping.”

2. **Extension verdict: good as a buyer acquisition surface, bad as the main demo dependency.** One click works like this: content script detects product images from DOM/OpenGraph/schema.org, picks the largest visible product-like image, extracts title/price/color text, guesses category from page text and image aspect, then sends candidate image URL + page metadata to backend. Backend checks whether the merchant/SKU is already seller-prepared. If yes, launch Drape with reliable assets. If no, show “needs seller-ready image” or a limited “save to Drape” flow.

Failure modes: model photos instead of garment-only shots, collages, swatches with no garment image, hidden carousel images, CORS/image blocking, wrong category, multiple people, rear/angled garments, and colorways represented only by tiny swatches. Arbitrary Amazon/store extraction is therefore not reliable enough for the winning demo.

Legal/ToS/trademark: do not show Amazon branding, checkout, logo, URL bar, or recognizable third-party product pages in the video. Demo the extension on a synthetic local storefront or a generic mock store page. For judging, include a load-unpacked Chrome extension in the repo that works on the mock page and “generic product pages,” but keep the video trademark-clean.

3. **Final architecture: Drape Seller-Prepared Commerce.**

Surfaces:
- Seller console: upload SKU, clean colorway images, category, palette tags, price, product copy, optional approved demo renders.
- Buyer app/web: selfie, tone read, drape reveal, seller-prepared catalog, full-body try-on, match-my-face bundle, mock checkout.
- Buyer extension: one-click bridge from generic product page into Drape, best when SKU is seller-prepared.

Data:
- Seller provides clean garment/colorway images, category, color tags, approved/avoid palette mapping, synthetic brand/product data.
- Buyer provides selfie and full-body photo.
- Backend stores cached palette profile, result images, product metadata, and unit budget state.

API calls:
- Seller onboarding: optional Clothes VTO validation, 2u per colorway/persona test, owner-approved only.
- Buyer demo mode: Fitzpatrick 2u or cached profile, Clothes VTO 2u, Makeup VTO 1u, Earrings/Necklace 1u. Around 6u live demo.
- Premium mode: Facial Color Tones 20u once, then 4–5u per new look.
- Extension: 0u until it finds a seller-prepared SKU or the buyer explicitly starts try-on.

3-minute demo:
- Seller uploads three clean colorways and tags them.
- Buyer clicks extension on a mock store product; Drape opens.
- Selfie gets color profile; drapes show “lights you up” vs “washes you out.”
- Catalog reorders by face.
- Buyer tries the approved colorway on full body.
- “Match my face” applies lip/foundation and gold/silver jewelry.
- Bundle goes to cart.
- End with architecture shot: seller prep makes buyer VTO cheap, reliable, and extension-ready.

4. **MVP cut by Nov 2.** Build seller console-lite, backend proxy/cache/budget guard, Flutter buyer flow, synthetic catalog, mock checkout, and load-unpacked Chrome extension for a local/mock product page. Use cached judge persona so testing until Nov 20 costs nothing. Build live buyer mode behind owner-approved caps.

Roadmap only: real Amazon support, public Chrome Web Store review, arbitrary merchant scraping, seller billing, automated garment QA, full marketplace integrations, and premium Color Tones for every user.

5. **Biggest single risk:** whether real clean colorway product shots preserve garment shape consistently in Clothes VTO. If colorway A renders as a ruffle and colorway B as a cape, seller prep does not save the product.

Cheapest test: owner-approved 6 units. Use one person photo and three real clean colorway images of the same garment. Run Clothes VTO x3. If silhouette stays stable, Drape is viable. If not, MVP must show one approved colorway per SKU and keep color comparison in the face-drape overlay only.