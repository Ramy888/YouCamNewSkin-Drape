# YouCam API Skin AI & eCommerce VTO Hackathon: project context

**Source of truth for this folder.** Checked against the live Devpost overview and rules pages and against
docs.perfectcorp.com on **2026-10-09**. `youcam-api-skin-ai-ecommerce-hackathon.md` is the earlier planning
note (proposals, verdict). Where the two disagree, this file wins, and the **Official Rules win over
everything** (Rules §11.D). Before relying on the rules, re-check them and the Updates page:
https://youcam-api-skin-ai-ecommerce.devpost.com/updates

## 0. Status

> **RULE (owner, 2026-10-10): no API calls that spend units (tests included) without Ramy's explicit approval for that specific run.**

- **2026-10-09: Registered on Devpost.** Chosen direction: **Product B "Try & Buy", eCommerce VTO track** (see §10).
- Submission manager: https://devpost.com/submit-to/31400-youcam-api-skin-ai-ecommerce-vto-hackathon/manage/submissions
- 2026-10-09: YouCam API account created (Ramy signed in via the console). Redeem code applied → **1,000 bonus units,
  valid 2026-10-09 → 2027-01-07**. Balance confirmed at 1,000.
- Next: Ramy creates an API key in the console (API Keys → Generate) and pastes it into the project `.env` as
  `YOUCAM_API_KEY` (never in chat or the repo) → spend a few units in the Playground to test hijab/abaya try-on (see §9).

## 1. Links

| What | URL |
|---|---|
| Overview | https://youcam-api-skin-ai-ecommerce.devpost.com/ |
| Official Rules | https://youcam-api-skin-ai-ecommerce.devpost.com/rules |
| Updates · Discussions | `/updates` · `/forum_topics` (re-check weekly) |
| Discord | https://discord.com/invite/HP4BhW3hnp |
| YouCam API console (keys, Redeem Code) | https://yce.perfectcorp.com/ai-api |
| API docs | https://docs.perfectcorp.com/develop/introduction (mirror: docs.makeupar.com) |
| Unit calculator · pricing | https://yce.perfectcorp.com/ai-api/unit-calculator · `/ai-api/api-pricing` |
| Social-bonus claim form (per the Rules §8F) | https://forms.gle/JwMFYMpaExckupEk7 |
| Social-bonus form (per the overview banner, which differs) | https://forms.gle/BJd5gPzF6YqPQR4R8 |
| Hackathon contact / private-repo share address | `contact_event@PerfectCorp.com` |
| API support | YouCamOnlineEditor_API@perfectcorp.com |

## 2. Dates (Eastern Time; Cairo is ET+7 h in late Oct and early Nov)

| Item | When |
|---|---|
| Submission period | Sep 29, 2026, 12:00 PM → **Nov 2, 2026, 11:45 AM ET (6:45 PM Cairo)** |
| Judging | Nov 3 → **Nov 20, 2026**. The app must stay testable until then. |
| Winners announced | On or around **Nov 24, 2026** |
| Redeem codes | Valid for 90 days after redemption |

## 3. Eligibility

- Individuals at the age of majority, teams, and organizations. Solo entrants are fine. **Egypt is eligible.**
- Excluded per the Rules: Afghanistan, Antarctica, China, Djibouti, Iraq, Somalia, Venezuela, Western Sahara,
  Italy, Brazil, Quebec, Russia, Cuba, Iran, North Korea, Sudan, Belarus, Vietnam, Crimea, Donetsk, Luhansk,
  plus OFAC-sanctioned countries. *Discrepancy:* the overview list also excludes all of **Ukraine**. Neither
  list affects us.
- A project built with financial or preferential support from Perfect Corp. is not eligible.

## 4. Prizes ($6,000) and how many a project can win

| Prize | Cash | Extras | Open to us? |
|---|---|---|---|
| 1st | $2,500 | Feature blog post + meeting with the Product/Dev Marketing team | ✅ |
| 2nd | $1,000 | same | ✅ |
| 3rd | $500 | same | ✅ |
| Women in Tech | $1,000 | needs a team member who self-identifies as a woman (opt-in) | ❌ |
| Rising Star | $1,000 | needs a currently enrolled student with a school email (opt-in) | ❌ |

**A project can win only one prize.** Winners must complete an exit interview and affidavit/tax forms
(W-8BEN for non-US) within 10 business days, and agree to be featured in a blog article.

## 5. Tracks (pick one that fits)

- **Skin AI:** meet the user *at the moment* they care about their skin: right before a purchase, after a
  breakout, or in front of the mirror asking whether a product works. Use Skin AI, alone or combined with
  other YouCam APIs, so the user understands their skin **and knows exactly what to do next**.
- **eCommerce VTO:** bring beauty and fashion try-on together **as one seamless experience**. Wearing and
  looking are one self-image, so both capabilities should work as one.
- The overview explicitly encourages **Agentic AI workflows** and warns against "surface-level wrappers".
  The value must be obvious to a first-time user.

## 6. Hard requirements: stage one is pass/fail, then the disqualifiers

- [ ] A **working web or mobile app** that integrates **at least one YouCam API from the Skin, Beauty,
      Fashion, Jewelry & Watch, or Hair & Beard categories** (Rules §6). The image and video generation APIs
      do **not** satisfy this on their own.
- [ ] Clear **consumer or eCommerce value**, explained in the text description.
- [ ] It installs and runs consistently and behaves exactly as the video and description show.
- [ ] It is **new**, or *significantly updated* after Sep 29, with the update explained.
- [ ] **Repo URL** containing all source code, assets, and run instructions. The repo is either public with a
      license, or private and shared with `contact_event@PerfectCorp.com`. **No API key in the repo.**
- [ ] **Testing access**, free and unrestricted until **Nov 20**: a live URL, a working demo, or a test build.
      If it is private, put login credentials in the testing instructions. Judges may judge on the
      video, text, and images alone, so the video must carry the whole story.
- [ ] **Screenshots.**
- [ ] **Demo video, 1–3 minutes** (judges stop at 3:00), public on **YouTube** (preferred) or Vimeo. The Rules
      don't list Youku. The video must **name and explain the YouCam API(s) used**, show the app **running on the
      device it was built for**, and contain **no third-party trademarks or copyrighted music** without permission.
      → Use a synthetic or generic product catalog with no real brand names on screen.
- [ ] Every submission material is **in English**, or comes with an English translation. An Arabic UI is fine;
      the description, testing instructions, and video narration or subtitles must be in English.
- [ ] Original work, and open-source licenses are followed. Third-party APIs and SDKs must be used under their terms.
- Multiple submissions are allowed only if each one is substantially different.

## 7. Judging: four equally weighted criteria

1. **Technological Implementation:** depth and skill of the YouCam integration, consumer or eCommerce value,
   a non-trivial working implementation. **This criterion is the first tie-breaker.**
2. **Design:** a complete, coherent product, not a proof of concept.
3. **Potential Impact:** a credible, specific real problem for a real audience, which the demo actually solves.
4. **Quality of the Idea:** a creative, non-obvious use, with real understanding of the problem space.

Judge listed on the site: Wendy Yen (Perfect Corp.).

## 8. API units

- 1,000 free units come from the Devpost redeem code (Console → Account → Redeem Code). **Units are charged only when
  a task succeeds**; errors are free.
- **Social Sharing Bonus (Rules §8F):** 500 units per qualifying **demo-video post**, with a **maximum of one per
  platform and two in total** (+1,000 at most). The post must tag **@YouCam API**, briefly name the APIs used,
  include the text **"Received API credits for sharing"**, stay public for **at least 30 days**, and be posted from
  an account **created before Sep 29, 2026**. Claim it through the form by Nov 2, 11:45 AM ET. ⚠️ Codes go
  out **after** the submission period, so the bonus **cannot fund the build**. Budget the whole build on 1,000 units.

## 9. YouCam API: technical guide (verified from docs, v1.16)

- **Base URL:** `https://yce-api-01.makeupar.com/s2s/v2.0`
- **Auth:** `Authorization: Bearer <API_KEY>` on every call. **The key stays server-side** behind our proxy and
  never goes into the client, the repo, or this file.
- **Async flow (every API):**
  1. `POST /file` with `{"files":[{"content_type","file_name","file_size"}]}`, which returns `file_id` plus a presigned `requests[0].url`.
  2. `PUT` the bytes to that URL with the returned headers. **Skipping this step makes the task fail with a 500 or 404.**
  3. `POST /task/<name>` with `src_file_id` (or `src_file_url`) plus params, which returns `data.task_id`.
  4. `GET /task/<name>/<task_id>` until `data.task_status` is `success` or `error`. Intermediate values include
     `running`, `queued`, and `processing`. Poll with backoff.
- **Retention:** results and uploads expire after **24 h**, so copy the outputs (masks, images) into our own storage.
- Errors: `401 InvalidAccessToken`, `InvalidParameters`, and per-API ones such as `error_pose`, `error_multi_person`,
  `error_nsfw_content_detected`.

| API | Task name | Cost | Key facts |
|---|---|---|---|
| **AI Skin Analysis** | `skin-analysis` | **~12 units/call** (1–2 concerns), **22 units** for all 16 SD concerns; the cost scales with concern count | `dst_actions` array; SD and HD **cannot be mixed**. SD concerns: wrinkle, droopy_upper_eyelid, droopy_lower_eyelid, firmness, acne, moisture, eye_bag, dark_circle_v2, age_spot, radiance, redness, oiliness, pore, texture, tear_trough, skin_type. HD keys carry an `hd_` prefix (confirm exact action names). `"format":"json"`. Output per concern: `ui_score` (int 1–100, adjusted to motivate the user), `raw_score` (float), `mask_urls`. `miniserver_args.enable_mask_overlay` returns one blended image. Image: jpg/png under 10 MB, short side ≥480 px for SD and ≥1080 px for HD, **face width over 60% of the image**, portrait, no glasses, forehead visible, good light. → The UI needs a selfie-framing guide. |
| **AI Makeup VTO** | `makeup-vto` | **1 unit** (confirmed in the calculator) | `version:"1.0"`, `effects[]` such as `lip_color`, `eye_shadow`, `blush`, `foundation`, `bronzer`, `concealer`, `contour`, `eyebrows`, `eye_liner`, `eyelashes`, `highlighter`, `lip_liner`, `skin_smooth` (default 50). Palettes take color, texture, and colorIntensity; patterns come from the docs' JSON lists. Image: long side under 1920 px, face ≥100 px, near-frontal. |
| **AI Clothes VTO** | `cloth-v4` | **2 units** (v2/v3/v4) | `src_file_id/url` (person) + `ref_file_id/url` or `template_id` (garment) + `garment_category` ∈ **`full_body`, `lower_body`, `upper_body`, `shoes`, `outer`, `auto`** (v4; `outer` is v4-only). Options: `change_shoes` (default true; applies to full/lower), `filter_multi_person` (`off`/`normal`/`strict`). Spec: docs.perfectcorp.com/_bundle/reference/ai_clothes.yaml. Person: a single person facing forward, filling ≥80% of the frame. **Lower-body garments must come from worn-outfit photos**, not flat product shots. |
| Other qualifying APIs | see docs.perfectcorp.com/reference/… | TODO | Skin Simulation, Fitzpatrick Skin Type, Facial Color Tones (skin tone → shade matching), Face Attributes, Look VTO, Nail VTO, Eye Color Lens, Bag/Scarf/Shoes/Hat VTO, Hair Color/Style, Earrings/Ring/Bracelet/Watch/Necklace VTO. |

**Unit costs (unit calculator, 2026-10-09):** Makeup VTO 1 · Look VTO 2 · Clothes VTO v2/v3/v4 2 · Fabric 2 · Scarf 2 ·
Hat 2 · Bag 2 · Shoes v3 2 · Earrings 1 (2 stacked) · Necklace 1 · Nail VTO 1 · Hair Color 1 · Hairstyle v2.1 2 ·
Fitzpatrick 2 · **Facial Color Tones 20** · Skin Analysis ~12–22 · Background Removal 1. → For product B, one full
"outfit + look" try-on costs **about 3 units** (clothes 2 + makeup 1), so 1,000 units is roughly 300 combos.

⚠️ **Modest-fashion gap:** the Scarf API is a *neck scarf* with fixed Western styles (`style_french_elegance`, `style_light_luxury`,
`style_cottagecore`, `style_modern_chic`, `style_bohemian`), **not hijab**. The Hat API covers hats and headbands. Hijab and abaya
try-on must go through **Clothes VTO** (`full_body`/`outer` with a worn-outfit reference photo). **Test this in the Playground
before committing to it.**

**Still open:** the HD `dst_actions` names and the rate limits (the docs page returned 404). Use the API
Playground and the unit calculator. Docs also mention a **webhook** option and an official **MCP server** and Skills,
which are worth checking for the agentic angle.

## 10. Proposed product

Full proposals are in `youcam-api-skin-ai-ecommerce-hackathon.md` §8. Summary:

**Chosen (2026-10-09): B, "Try & Buy".** A and C are kept below for reference only.

- **A, "Basharti" (بشرتي) AI skin coach, Skin AI track.** Selfie → Skin Analysis → an agent builds
  an AM/PM routine and product *types* in budget tiers (AR and EN) → weekly re-scans with progress charts.
  The retail angle is a white-label recommender for MENA pharmacies and beauty retailers. Strengthen it for
  judging with Facial Color Tones (shade matching) and Makeup VTO ("see it on you"), framed around a
  "moment of need" (pre-purchase, after a breakout). Use a fictional catalog with no real brands.
- **B (CHOSEN), "Try & Buy"** modest-fashion + beauty store, eCommerce VTO track. Combines Clothes VTO and Makeup VTO into a
  single "outfit + matching look" checkout. Watch the clothes-input constraints above.
- **C, skin-aware shopping assistant**, a chat agent: skin analysis → catalog filtering → makeup VTO for the
  chosen shades. This is the most "agentic" option and bridges both tracks.

**Default platform:** Flutter app with a **hosted Flutter Web build** for judge testing (an APK is optional), plus a
small backend proxy that holds the key, runs the upload→task→poll flow, and caches results. Hosting must be live
before submission and stay up **until Nov 20**.

## 10a. Debate outcome, 2026-10-09 (Fable vs Codex, files in `docs/debate/`), pending the owner's decision

Both agree: Try & Buy as-is is mid-pack (it copies Kostuma's shape, the hijab gap is exposed, and the integration is thin). Both converge on
**face-measured colour as the engine**: one undertone measurement drives garment colourway + makeup shade + jewelry metal, and
the **rejected option is rendered on the body beside the approved one** (a negative→positive video arc).
- **Fable's "Drape: the fitting room that says no":** vetoes only what the face measurement justifies; hijab colour handled as a drape overlay.
- **Codex's "Regret Mirror":** the same engine framed as "visual return insurance" (bad cart → fixed cart).
- Cost: Fitzpatrick demo mode about 7–11 units per session; premium mode with Facial Color Tones (20, cached) about 25–29.
- **Load-bearing de-risk (6 units):** 3 Clothes VTO calls on locally hue-shifted garment images. Does the recolour render faithfully?
- **Do not build:** a chat or "AI stylist" layer, rule-based critique captions, persona pickers.
- **De-risk result (2026-10-09, 6 units spent, ~994 left; images and scripts in `docs/derisk/`):** cloth-v4 `upper_body`, the YouCam
  sample tee recoloured locally (polygon mask), applied to a *different* person: ✅ **the colour transfers faithfully** (emerald stays emerald;
  mustard drifts slightly olive); ✅ face, pose, hair and jeans are preserved exactly. ❌ **The garment shape is NOT stable across colourways**: the
  same tee came back as a ruffled asymmetric top in one call and a one-shoulder cape in another (partly provoked by mask leftovers that read
  as bare shoulder). ⚠️ When src and ref are the same person, the API returns the reference almost verbatim (useless as a test).
  → Implications: use **clean, flat, real colourway product shots** (or proper segmentation), not hand masks; expect shape variance and
  cache one approved render per colourway; or keep **one** try-on render and apply the Drape colour logic via makeup, jewelry and the face drape overlay.

- **Round 3 (2026-10-10) → "Drape Network"**, see `docs/product.md`: a seller console (clean colourway shots + pre-flight) + buyer web app
  + one-click Chrome extension (side panel), all over one backend. Makeup runs on the selfie.
- **Round 4 (2026-10-10):** registry with cross-store links (seller attaches Amazon/Shopify/Noon listing links → extension matches by URL/ID first). Both models agree. **Owner direction:** official doors only (store API/button, description link, SKU search; extension reads the URL only, no crawling). See `docs/product.md`.
- **/autoplan (2026-10-10): APPROVED.** Embed-first (store button + hosted buyer flow + seller console; extension stretch; links/SKU search roadmap). Color Tones replaces Fitzpatrick; replay mode default (0u); unit ledger with 400u judging reserve. Build spec + tasks + TODOS.md.
- **Gate 2 (2026-10-10, 26u, owner-approved one-time; ≈959 left):** Color Tones works on a frontal face (fails free on a tilted face); abaya colourway pair keeps shape on `full_body`; on-model abaya transfers with head covering. `docs/product.md` is now the clean build spec; history in `docs/history.md`.
- **Build (2026-10-10):** live (replay mode, 0 units) at https://drape.ramy-comm.workers.dev (API + app at /app/) and demo shop https://noor-modest.ramy-comm.workers.dev. Cloudflare Worker + Durable Object (SQLite ledger) + R2 + hourly sweep cron. Seller/session secrets in `backend/.dev.vars` (gitignored). Repo: github.com/Ramy888/YouCamNewSkin-Drape (private). Coding complete 2026-10-10 (earrings VTO, extension + /v1/lookup, hijab drape, live path e2e-tested against a mock). Live switch + persona renders pending Ramy's approval.
- **Gate test (2026-10-10, 9 units, approved, ~985 left): all 4 pass.** Flat-lay ✅, on-model `outer` ✅, real colourway pair keeps the same shape ✅, makeup on selfie ✅. → Colourway side-by-side and the wild path both ship. Details in `docs/product.md`.
- **Persona renders, option A (2026-10-10, approved, 9 units charged, ~976 left):** abaya lavender, kaftan saffron/aqua/blush, makeup ✅. Gold earring failed free ("earlobe alignment not confident": ears under hair), now mapped to the covered-ears message. Option B (consented photos) still open.
- **LIVE (2026-10-10, Ramy approved budget 400):** deployed with `npm run deploy:live` (mode live, budget 400). `wrangler.jsonc` stays replay/0 so clones and CI never spend; a plain `npm run deploy` reverts production to replay.
- **Round 5 + Fabric gate (2026-10-12, approved, 6 units, ~947 left):** debate (`docs/debate/r5-verdict.md`) → "Ask for it in my colour" + Colour Demand. AI Fabric = 40 fixed templates on a person photo (not hex). Sea Green Silk ✅ and Blue Wool ✅ kept the abaya's cut; Peach Organza ❌ (crop top + skirt) → opaque-only, live only for checked templates. Built + deployed: recolor job (2u, one per session), free requests, seller demand panel, third product. Fixture run (navy try-on + Fabric, ~4u) pending approval.
- **Live test (2026-10-10, approved, 23 units, ~953 left):** reading 20 ✅ (warm/high/gold), try-on 2 ✅, makeup 1 ✅, earrings failed free with the covered-ears message ✅. Ledger 23/400, nothing stuck; session deleted, files 404.

## 10b. Competition watch (Discord #showcase)

- **Kostuma** (posted by Vlad and a partner, 2026-10-08), https://kostuma.vercel.app/: horror-movie costume try-on on
  your own photo, then **the character's makeup step by step**. It has 82 characters, a "Pumpkin Basket", sign-in, and a language
  switch, with a Halloween countdown. **This is the same "outfit + matching makeup" pattern as our product B**, already live and polished.
  - Their weak spots, which we should beat: built entirely on **film-character IP** (the rules ban third-party trademarks
    and copyrighted material in the video), **seasonal** (it peaks Oct 31, before judging), and a novelty use case rather than
    retail value (the basket is not real shopping).
  - Our differentiation: year-round **modest fashion** for MENA, a real store flow (catalog → try-on → matching look →
    cart → checkout) with retailer value, an **Arabic RTL** UI, synthetic brands only, and makeup matched *to the outfit*, not to a character.

## 11. Plan and verdict

The planning note's verdict still stands: this is a low-priority portfolio piece, with only $4,000 reachable
($2,500 for 1st), after Nebius and Qloo (Oct 30). Timeline: Oct 6–10 register, redeem, and test the API on sample
images while resolving the §9 open items → Oct 31–Nov 1 build → Nov 2 morning video, screenshots, submit before
6:45 PM Cairo. Unit discipline: cache every result, use fixed test images, and make no repeat calls while
developing UI.
