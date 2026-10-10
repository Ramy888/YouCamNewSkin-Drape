# Debate brief: make "Try & Buy" unmistakably unique

You are one of two debaters (the other is a different AI model). Goal: find the product concept that wins the
YouCam API hackathon's eCommerce VTO track. The owner's demand: **"Every other participant will use AI ideas.
The addition must be from another planet."** Generic "AI stylist / chatbot / recommendation engine / agent that
picks outfits" ideas are table stakes and will NOT differentiate. Be bold, but it must be buildable and demoable.

## Hard facts (verified)
- Hackathon: Perfect Corp YouCam API, Devpost. Deadline **Nov 2, 2026**. About 750 participants. Prizes: 1st $2,500, 2nd $1,000, 3rd $500.
- Track **eCommerce VTO**: "Beauty and fashion decisions rarely happen in isolation... Build something that brings Virtual
  Try-On together into one seamless, intuitive experience... both capabilities work as one to reimagine the way we shop."
- Stage 1 pass/fail: it must integrate ≥1 YouCam API from the Skin/Beauty/Fashion/Jewelry & Watch/Hair & Beard categories.
- Stage 2, equally weighted: **Technological Implementation** (depth of YouCam integration, non-trivial; also the first
  tie-break) · **Design** (complete product, not a proof of concept) · **Potential Impact** (a credible, specific real problem
  for a real audience) · **Quality of Idea** (creative, *non-obvious* use; real understanding of the problem space).
- Judges may judge **only from the 1–3 minute video + text + screenshots**, so the "wow" must read on video in seconds.
- Video and app must avoid third-party trademarks or copyrighted material. The app must stay testable until Nov 20 (hosted web build).
- Builder: **one developer** (Flutter + small backend), based in Cairo, Egypt, Arabic + English. Realistically 1–3 focused build days.
- Budget: **1,000 API units**. Units are charged only on success. Results are deleted after 24 h.

## YouCam APIs available (async REST: upload → task → poll) and unit cost per call
Makeup VTO 1 (lip, eyeshadow, blush, foundation, liner, brows, lashes, contour, highlighter; color/texture/intensity
params) · Look VTO 2 (preset full looks) · Clothes VTO v4 2 (person photo + garment photo; categories full_body, upper_body,
lower_body, outer, shoes, auto) · Fabric VTO 2 · Scarf 2 (neck scarf, 5 fixed Western styles, NOT hijab) · Hat 2 · Bag 2 ·
Shoes v3 2 · Earrings 1 · Necklace 1 · Ring/Bracelet/Watch · Nail VTO 1 · Eye color lens · Hair color 1 · Hairstyle 2 ·
Beard · Skin Analysis ~12–22 (16 concerns, scores and masks) · Fitzpatrick skin type 2 · Facial Color Tones 20 (skin
undertone, for shade matching) · Face attributes/ratio analyzer · Aging simulation · Skin simulation. Plus image APIs that
don't count for Stage 1 (background change, photo lighting, etc.). Official MCP server and webhooks exist.

## The current product on the table: "Try & Buy"
A modest-fashion + beauty store demo for MENA: try an outfit on your own photo (Clothes VTO), get matching makeup (Makeup VTO),
build the look, add it to the cart, and check out. Arabic RTL + English. Synthetic brands only.
Known gap: **no hijab try-on API**. Hijab/abaya would have to go through Clothes VTO full_body/outer with worn-outfit photos (untested).

## Competition already visible
"Kostuma" (live on Vercel): horror-movie costume try-on plus that character's makeup, step by step, with a Halloween basket. So
"outfit + matching makeup" alone is **already taken**. Kostuma's weaknesses: film IP (trademark risk), seasonal, novelty with no real commerce.

## What to produce (Round 1)
1. A blunt critique of "Try & Buy" as it stands: why it would or wouldn't place top-3.
2. **Three "another planet" concepts** that keep the eCommerce VTO track (beauty + fashion as ONE experience). For each give:
   - the one-line hook (what a judge sees in the first 10 seconds of the video)
   - the non-obvious insight or mechanism: what is genuinely new, not "AI picks for you"
   - the exact YouCam API chain and the unit cost per user session
   - why it is credible commerce with real impact (a specific audience and problem; MENA angle welcome but not required)
   - the riskiest technical assumption, and how to de-risk it with ≤20 units
   - whether one dev can build it in ~3 days
3. Your single pick, and why.
Be concrete and opinionated. No fluff, under 900 words.
