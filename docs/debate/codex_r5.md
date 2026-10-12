1. **The one addition**  
**Drape Merchandising Radar:** after buyers use Drape, the seller console shows a “colour money map”: measured shopper palettes from YouCam Facial Color Tones, which colourways they tried, which ones Drape rescued, and which palette-matched colourway is missing from the catalogue. The buyer sees only one tiny addition: after Add bundle, “Save my colour profile for this store” so returning sessions are cached. The store sees: “Warm/high-contrast shoppers are 62% of tries; lavender is the top rejected colour; emerald converts 2.1x better; add deep teal to this abaya.”

2. **Why it wins**  
**Technical implementation:** it turns YouCam from try-on output into a closed retail measurement loop: Facial Color Tones → palette engine → Clothes/Makeup/Earrings VTO decisions → cart intent → seller insight. That is deeper than “apply effect to photo.”  
**Design:** it completes both sides of the product: buyer confidence and merchant control room.  
**Potential impact:** modest-fashion stores do not just need VTO; they need to know which colours to stock, photograph, reorder, and discount.  
**Idea quality:** judges remember the moment the app says “this colour fights her” and then the console says “this colour also loses money.”

3. **Why stores run to install it**  
The merchant reason is conversion plus inventory. Assumption: if 100 product-page visitors click Drape, 35 try a look, and Drape shifts only 4 buyers from hesitation to cart at an 890 EGP abaya price, that is 3,560 EGP influenced revenue from one SKU. More importantly, it tells the seller not to reorder weak colours. Even avoiding one bad 20-unit colour run at 500 EGP landed cost saves 10,000 EGP. That is the install pitch.

4. **YouCam APIs and units**  
No extra buyer calls beyond today: new buyer ≈ 26 units: Facial Color Tones 20, two Clothes VTO renders 4, Makeup 1, Earrings 1. Returning saved-profile buyer: 4–6 units, or 0 if replay/sample. Per store: 0 units for analytics; optional seller “test this proposed colourway” costs 2 units per Clothes VTO pre-flight render. Replay covers the full judge path with recorded persona readings, try-ons, makeup, and synthetic analytics seeded from those events.

5. **Build plan**  
Day 1: add event tables in `backend/src/state.ts`: palette segment, product, colourway, verdict, job result, add-to-cart. Add `/v1/admin/radar`.  
Day 2: emit events from app state when reveal, compare, complete look, add bundle happen; keep raw photos out.  
Day 3: seller console panel in `app/lib/screens/seller_screen.dart`: palette mix, rescued carts, rejected colours, missing colour recommendation.  
Day 4: seed replay analytics and tests for privacy, judge key read-only, no extra YouCam spend.  
Cut if slipping: proposed-colour pre-flight. Keep the analytics board.

6. **The 25-second video beat.**  
Buyer tries lavender, Drape shows lavender versus emerald on her body, she adds emerald bundle. Smash cut to seller console: “Lavender rejected 18 times; emerald rescued 11 carts; recommended next colour: deep teal.” Cursor hovers over “Add colourway.”

7. **Biggest risk**  
The insight could feel statistically fake with tiny demo data. Day 1 proof: build the seeded radar from real replay/session events and see whether one SKU produces a legible recommendation without hand-written narrative. If it needs explanation, kill it.

8. **Alternative rejected**  
I rejected a chatbot stylist. It would be easy to demo, but it weakens Drape: generic AI advice instead of YouCam-measured commerce proof.