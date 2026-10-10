# Fable, Round 1

## 1. Critique of "Try & Buy"

Mid-pack, not top 3. Three reasons.

1. **Quality of Idea scores derivative.** "Outfit, matching makeup, basket" is Kostuma's exact mechanism. Swapping horror for modest fashion changes the catalogue, not the idea.
2. **The headline garment is the one thing it cannot show.** A modest-fashion store with no hijab try-on demos the gap; judges will see a hijab-less "modest" shop and wonder what is modest about it.
3. **Technological Implementation reads thin.** Two APIs run side by side; neither output feeds the other. On video it is the vendor's demo output plus a cart. The tie-break goes to depth, and there is none.

Keep the Flutter shell, RTL, cart, synthetic brands; replace the idea.

## 2. Three concepts

### A. Drape: digital colour draping

- **Hook (10 s):** a face; five fabric drapes swing in; three visibly grey the face out, two make it glow; the glowing one becomes the dress on her body, and her lipstick shifts to match. Caption: "Buy the colour that suits you, not the one on the model."
- **Mechanism:** in-person seasonal colour analysis (a $150–300 service, huge on TikTok) is literally holding fabric drapes against the face. Facial Color Tones gives undertone; a deterministic palette table maps it to garment colourways and foundation/lip shades. The catalogue is *filtered and re-rendered* by a measurement of your face: fashion colourway and beauty shade come from one API output. Not "AI picks for you"; a rule table a colourist would sign. Hijab bonus: draping fabric around the face is exactly what a hijab does, so hijab colour choice works as a recoloured drape overlay with no hijab API.
- **API chain / units:** Facial Color Tones (20) → locally hue-shift the garment image into the winning and losing colourways (free) → Clothes VTO x4 (8) → Makeup VTO lip + foundation (1–2). About 30 units per session, cached per user; around 30 judge sessions from the pool after testing.
- **Commerce:** colour-driven returns ("didn't suit me") on multi-colourway garments, and foundation shade mismatch, chronic in Egypt because ranges skew light. Buyer: fashion retailers and beauty counters.
- **Riskiest assumption:** Clothes VTO renders a hue-shifted garment faithfully, and the undertone output is granular enough to map. De-risk in order: 4 Clothes VTO calls on recoloured garments (8) + 1 Fitzpatrick as proxy (2) + 1 Makeup (1) = 11 units; only then spend the single 20-unit Color Tones call.
- **3 days, one dev:** yes. Palette table is JSON; recolouring is one HSL function; the rest is the existing shell.

### B. Gift Mirror: try-on for the wearer, not the buyer

- **Hook:** a man types "for Mama". He picks earrings, a scarf, a lip shade, sends a link. Mama opens it, takes a selfie, sees the set on her own face, taps "gold instead of silver", and only then does it ship.
- **Mechanism:** every VTO assumes the shopper is the wearer. Gifting breaks that. The giver chooses; the recipient tries on and edits before dispatch ("approve before ship"). Beauty + fashion are one object: a gift set rendered on one face.
- **API chain / units:** Earrings (1) + Necklace (1) + Ring (1) + Scarf or Bag (2) + Makeup lip (1) = about 6 per session; around 150 sessions. Persist the result image at completion, since results vanish after 24 h and the link is opened later.
- **Commerce:** gifts are the highest-return category; Mother's Day (21 March) and Eid are Egypt's gifting peaks. Recipient takes her own selfie, so no consent problem.
- **Riskiest assumption:** jewelry VTO looks good on ordinary selfies, including hijabi faces where earrings may be hidden. De-risk: 5 Earrings + 5 Necklace calls = 10 units.
- **3 days:** yes, easiest; two screens and a signed link.

### C. Countdown Cart: the bridal timeline

- **Hook:** type a wedding date. The face is scanned; a timeline unrolls backwards: skincare at 12 weeks, dress at 6, hairstyle at 2, makeup at 1. The final look assembles at the end.
- **Mechanism:** the cart is a calendar. Skin Analysis concerns set what to buy *now*; Clothes, Hairstyle and Makeup VTO set the look for the day. Fashion and beauty are sequenced by a deadline. Egyptian weddings are three events (henna, katb el-ketab, wedding): three looks.
- **API chain / units:** Skin Analysis (~16) + Clothes VTO (2) + Hairstyle (2) + Makeup (1–2) = about 22; around 40 sessions.
- **Commerce:** the wedding is Egypt's largest consumer spend event; bridal boutiques and pharmacies want the pre-purchase schedule.
- **Riskiest assumption:** Skin Analysis scores map to plausible product timing without reading as medical advice. De-risk: 1 Skin Analysis (16) + 1 Hairstyle (2) = 18.
- **3 days:** tight; timeline UI plus four API types is the most surface.

## 3. Pick: A, Drape

It wins the tie-break: one API output parametrises two further calls, which is depth, not a panel. It reads on video in five seconds without narration, because wrong colours visibly fail. It fixes the hijab gap instead of hiding it, and has the best return-reduction story. Colour-analysis apps exist; none render the verdict on your own body with a buy button.

Switch trigger: if the 11-unit de-risk shows Clothes VTO smearing recoloured garments, fall to B: 6 units a session, no unproven rendering.
