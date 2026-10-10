# Fable, Round 2: cross-examination

## 1. Attack: Return-Proof Cart

Codex's own words sink it: "scripted with smart copy and rules... it will feel intelligent without needing real AI." A hand-written stylist in a trench coat.

- **Quality of Idea.** "Neckline vs necklace, formality mismatch, warm/cool clash" are catalogue metadata rules. Nothing is measured from the shopper; the same cart gets the same three "regrets" on any face. A rule table that criticises your basket is a recommendation engine with a frown.
- **Tech Implementation (the tie-break).** The YouCam calls are renderers bolted on after the decision. No output feeds another call. Depth: zero.
- **Video wow.** The clash is a caption, not a picture. Clothes VTO will not render a neckline-necklace clash a judge perceives in two seconds; the viewer sees two renders and a label saying which is bad. The wow lives in the copy.
- **Impact claim is mis-aimed.** It is called the *Fit* Regret Simulator and promises fewer returns. Fashion returns are overwhelmingly size and fit; no YouCam API measures the body. An eCommerce judge will catch that it cannot address the return reason it names.
- **Kostuma overlap.** Outfit + makeup + accessories + basket is the taken shape; "then we tell you it's wrong" is a new ending, not a new mechanism.

Unit cost and buildability are fine: it is cheap because it does little.

## 2. Concessions

- **Budget pattern.** "One premium analysis, then many low-cost try-ons", with Fitzpatrick (2) as demo-mode fallback for Facial Color Tones (20), beats my flat 30 units per session. Judges re-testing until Nov 20 need the cheap mode.
- **Video arc.** Negative-then-positive ("rejected live", then fixed) is stronger cinema than my straight flow; contrast reads on mute.
- **Shade-Lock** is the better half of their answer and nearly identical to my Drape; calling it "colour theory homework" is a presentation problem, not a concept problem.
- **Mirror Passport's** three-selves split screen is a better opening frame.

## 3. Merged concept: "Drape: the fitting room that says no"

**Hook (first 10 s):** one selfie; fabric drapes swing across the face, three grey it out, two light it up; the shop reorders itself around the two.

**Mechanism:** the app may only veto what a measurement of the face can justify. Facial Color Tones gives undertone; a deterministic draping table maps it to garment colourways, foundation and lip shade, and metal (warm: gold, cool: silver). The veto is shown, not captioned: the rejected colourway is rendered on your body beside the approved one. No opinions on taste, neckline or formality, ever; that restraint is what makes it credible and not a stylist. Hijab colour is the same drape overlay around the face, no hijab API needed.

**API chain, per session:** Facial Color Tones 20 (once, cached) → local HSL recolour of garment image (0) → Clothes VTO x3: two approved, one vetoed (6) → Makeup VTO foundation + lip (2) → Earrings, metal by undertone (1). Premium session 29; demo mode with Fitzpatrick 11. After ~80 units of build and de-risk, roughly 25 premium plus 20 cheap sessions remain.

**60-second beat sheet:**
- 0–6: selfie upload; "What colour are you?"
- 6–16: undertone pill appears; five drapes sweep in, grey versus glow (overlay, zero units).
- 16–30: catalogue re-sorts; one dress on her body in three colourways, the vetoed one tagged "washes you out" beside the approved.
- 30–42: "Match my face": foundation, lip, earrings snap to the palette.
- 42–52: same rule applied to a hijab drape; Arabic RTL toggle.
- 52–60: look to cart, checkout, caption: "Buy the colour that suits you, not the one on the model."

**Cheapest de-risk:** 3 Clothes VTO calls on hue-shifted garment images, 6 units; that is the single load-bearing assumption. If it holds, Fitzpatrick (2) + Makeup (1), then one Color Tones call (20).

## 4. Do not build

A rules-based critique or recommendation layer with explanatory copy: "this necklace clashes with your neckline", "too much for a family dinner", persona pickers, chat, agents. The moment the app offers an opinion the API did not measure, it is every other AI entry. Vetoes come from the face or not at all.
