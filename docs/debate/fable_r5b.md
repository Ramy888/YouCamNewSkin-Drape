# Fable, Round 5b: cross-examination of Merchandising Radar

## 1. Strongest point

Codex found the merchant's money reason: not "see it on me" but "stop reordering the colour that loses". It costs 0 units, needs no approval, and runs on data Drape already produces (jobs, verdicts, `drape:add-to-cart`). "Rescued carts" is a phrase a judge repeats.

## 2. Biggest weakness

It adds no YouCam call. The first tie-breaker is technical implementation of the YouCam APIs, and r5 says the addition "must use the YouCam APIs more deeply or more cleverly"; a dashboard reads results, it does not make new ones. Worse, the numbers cannot be true by Nov 2. "62% warm", "emerald converts 2.1x", "lavender rejected 18 times" come from one store, one persona and a few judge sessions: seeded analytics on video, while Rules §6 requires the app to behave exactly as the video shows. `TODOS.md` already parks "seller colour-demand metric: needs real traffic", and Codex's own section 7 concedes it ("could feel statistically fake"). "Save my colour profile" is Drape Pass by another name: fewer YouCam calls. And its beat is a table of numbers; mine is a garment that does not exist yet, on her body.

## 3. Combine them? Yes

"Ask for it in my colour" supplies the one event Radar lacks that is honest with tiny data: a request is a buyer's action, not a statistic. Combined: **the request render plus a three-row radar**.

- Keep from Fable: Fabric recolour → Clothes VTO "not sold yet" render → `drape:colour-request` → **Add as colourway (draft)**: the beat.
- Keep from Codex: the event table in `state.ts` and `/v1/admin/radar`, limited per product to *tried*, *rejected* (avoid verdicts shown in Compare), *requested*, by undertone. Three counts from real events, no multipliers.
- Cut from Codex: the profile save, conversion ratios, percentages, and the inferred "add deep teal" line; the recommendation is the request count itself.
- Cut from Fable if it slips: the live request path (replay only, labelled). The event table folds into my day 2 (`state.ts`) and the panel into day 3 (`seller_screen.dart`); the plan stays at four days.

## 4. Recommendation

Build the combined addition: the request render is the YouCam depth and the beat, the radar is the install pitch, and every number on screen happened. **Day-1 go/no-go (≈ 6u, owner-approved):** two Fabric renders of the black abaya shot (emerald, terracotta) plus one Clothes VTO of a render on the persona body. Go if the garment's median colour is within ΔE 15 of the requested hex and the silhouette overlaps the source at IoU ≥ 0.95. No-go: Background Removal mask plus local LAB recolour, then VTO; if that also drifts, ship the request as a swatch at 0u, which still gives the radar a true event to count.
