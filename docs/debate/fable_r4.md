# Fable, Round 4: the registry with cross-store links

## 1. Verdict: yes to the links, not yet to "the registry is the business"

product.md already has a registry: the seller console mints a product ID and a Drape-ready badge. Round 4 adds one thing, a link from that record to the same product's listings elsewhere. Worth building, but a routing table, not a moat, until it has density.

- **Cold start.** Zero sellers means zero matches, so every click runs the wild path and the registry is invisible to buyers. The demo hides this because we own both stores; the business lives in it.
- **Seller incentive.** A seller already on a marketplace gains only if Drape measurably lifts conversion or cuts colour returns there. The badge proves nothing; the pitch must promise the measurement.
- **Who pays.** Unchanged: the seller pays per SKU (pre-flight plus links), the buyer never pays.
- **Link hijacking.** The real abuse: a seller attaches a competitor's ASIN so their garment renders on the competitor's page. Wrong links are the same failure with less intent. Ownership must be verified: the brand or store name on the linked page must match the seller record, and the listing image must perceptually match the registry shot.
- **ToS.** A user-initiated content script reading the page being viewed is standard shopping-extension behaviour. The exposure is server-side crawling of marketplace pages to verify links, so verification runs in the buyer's browser at click time or from seller-supplied evidence, never from our backend.

## 2. Matching: tiered, confidence-gated, zero units

All of this is URL and DOM parsing; no YouCam call is involved.

- **Tier 0, exact ID.** Normalise the URL (canonical host, strip tracking and session params), then extract the platform ID by regex: `/dp/[A-Z0-9]{10}` (ASIN), Shopify `/products/<handle>` plus `variant=`, Noon `/p/<sku>`. Exact hit in `links[]` → auto-match.
- **Tier 1, structured data.** JSON-LD `Product.gtin`, `sku`, `mpn`, `productID`, and the `og:url` canonical. GTIN is the only key truly shared across stores; sellers who enter it get matched everywhere.
- **Tier 2, fuzzy.** Title tokens plus a perceptual hash of the page's hero image against registry colourway shots, same brand required. **Suggest only, never auto-match:** a confirm chip shows the registry thumbnail beside the page image.
- **No match.** The round-3 ladder: JSON-LD image → og:image → carousel → largest image → "pick the garment photo" strip.

Stopping wrong matches: the selected-variant swatch colour must agree with the matched colourway, else fall to the base shot with a warning; one tap on "wrong product" unlinks that URL for everyone and flags the seller's link; Tier 2 spends no unit before the confirm.

## 3. Build by Nov 2 versus roadmap

**Build (about half a day on top of product.md):** `links[]` on the registry record (store, normalised URL, external ID); a "paste listing URL" field in the seller console that parses the ID locally; the extension runs Tier 0 and 1 before the extraction ladder; the Tier 2 confirm chip; the "wrong product" tap.

**Roadmap:** GTIN resolution, the pHash index, full ownership verification, bulk link import, Shopify auto-linking.

**Video.** Reuse the two synthetic stores; give Store B a synthetic `/dp/XXXXXXXXXX` URL shape so ID extraction is visible without any marketplace UI. The beat that sells the registry (about 20 s): click on Store B → wild path, picker; the seller pastes Store B's URL into the console; re-click → "Drape-ready, matched", instant, clean colourways. The round-3 script is full, so this displaces the architecture card. "Works on Amazon or any store" stays text only.

## 4. The improvement: the no-match queue is the sales funnel

Log every no-match click: normalised URL, extracted title, brand guess, image hash, and the buyer's palette family. That log is the seller acquisition list. A seller signing up sees "37 buyers tried Drape on your listings this month, 21 of them warm-palette", claims the listings by proving ownership, and the links fill themselves. Cold start turns into demand evidence: the wild-path click the registry cannot serve today recruits the seller who will serve it tomorrow. Build the log on day 1 (one table, no UI); show the count on the seller console.
