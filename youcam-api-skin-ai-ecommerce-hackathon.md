# YouCam API Skin AI & eCommerce VTO Hackathon

> **Verified rules and the API guide are in `CLAUDE.md` (source of truth, checked 2026-10-09).** This file is the original planning note.

> **Hackathon URL:** https://youcam-api-skin-ai-ecommerce.devpost.com/
> **Rules:** https://youcam-api-skin-ai-ecommerce.devpost.com/rules · **Gallery:** https://youcam-api-skin-ai-ecommerce.devpost.com/project-gallery
> **YouCam API platform:** https://yce.perfectcorp.com/ai-api
> **Host:** Perfect Corp. (managed by Devpost) · Online · 747 participants (Oct 9, 2026)

---

## 1. Key dates
| Item | Date |
|---|---|
| **Submission deadline** | **Nov 2, 2026, 11:45 AM EST (6:45 PM Cairo)** |
| Judging | Nov 3 – Nov 20, 2026 (the app must stay testable until then) |
| Winners | On or around Nov 24, 2026 |

## 2. Prizes ($6,000 cash)
| Prize | Amount | Can you win it? |
|---|---|---|
| 1st place | **$2,500** | ✅ |
| 2nd place | $1,000 | ✅ |
| 3rd place | $500 | ✅ |
| Women in Tech Special Award | $1,000 | ❌ |
| Rising Star Award (students only) | $1,000 | ❌ |

## 3. Eligibility
- ✅ Individuals of legal age, teams and organizations. **Solo with no company is fine.**
- Excluded (22): Afghanistan, Antarctica, China, Djibouti, Iraq, Somalia, Venezuela, Western Sahara, **Italy**, Brazil, Quebec, Russia, Cuba, Iran, North Korea, Sudan, Belarus, Vietnam, Crimea, Donetsk, Luhansk, plus OFAC-sanctioned countries. **Egypt is OK.**

## 4. What to build
A **functional web or mobile prototype** that integrates **at least one YouCam API**. It can be a brand-new build or a **major upgrade** of an existing project.

**Tracks:**
1. **Skin AI:** use AI skin analysis (alone or with other YouCam APIs) to help users understand their skin at key consumer moments (diagnosis → routine → product choice).
2. **eCommerce VTO:** combine **virtual try-on** (generative apparel VTO; beauty VTO) into one seamless shopping experience for beauty and fashion.

These are the same models used by 800+ global beauty and fashion brands.

## 5. API access and limits
1. Register on Devpost and you'll get an **exclusive redemption code by email**.
2. Sign up at https://yce.perfectcorp.com/ai-api and verify your email.
3. Account → **Redeem Code**: **1,000 free API units**.
4. **Bonus:** +500 units per qualifying demo-video post, one per platform, up to **+1,000**. Codes are sent **after** Nov 2, so they can't fund the build (see CLAUDE.md §8).
5. ⚠️ Budget your units: cache results, use test images, and avoid repeated calls while developing.

## 6. What to submit
- [ ] Code repo (public with a license, or private and shared with contact_event@PerfectCorp.com)
- [ ] Text description showing **consumer or retail value**
- [ ] Screenshots
- [ ] **Demo video, 1–3 min** (YouTube preferred, or Vimeo); names the YouCam API, runs on the real device, no copyrighted music or trademarks
- [ ] Testing access (live URL or test build) until Nov 20 · everything in English
- [ ] If you win: an exit interview and a feature in a blog post (1st–3rd also get a marketing-team meeting)

## 7. Judging
Technological implementation (quality of API integration) · Design · Potential impact · Quality of the idea

## 8. Product proposals

### A (recommended, Skin AI): **"Basharti" (بشرتي), an AI skin coach app (Flutter)**
- Selfie → **YouCam Skin AI** analysis (concerns such as acne, spots, wrinkles, hydration, depending on the API's output).
- AI builds a **personalized AM/PM routine** and suggests product types (budget tiers), in Arabic and English.
- **Progress tracking:** weekly re-scans with charts showing improvement; reminders.
- Retail angle: a white-label module for MENA pharmacies and beauty retailers to recommend their catalog.

### B (eCommerce VTO): **"Try & Buy", a modest-fashion and beauty try-on store**
- A shop demo where users **virtually try apparel** (including modest fashion / abaya styles) plus makeup looks, build an outfit and check out.
- An "outfit + matching makeup" combo is a strong fit for the track's "one seamless experience".

### C: **Skin-aware shopping assistant**
- A chat assistant that runs a skin analysis, then filters a product catalog to items suited to the user's skin, and shows makeup VTO for the chosen shades.

## 9. Timeline
| Dates | Goal |
|---|---|
| Oct 6–10 | Register, redeem the units, test the API with sample images |
| Oct 31 – Nov 1 | Build the Flutter app plus a small backend (proxy the API key server-side) |
| Nov 2 (morning) | Video, screenshots, submit before 6:45 PM Cairo |

## 10. Verdict
- **Fit:** high (Flutter, consumer AI, beauty and creative AI experience).
- **Value:** low. Only $4,000 is open to you, with $2,500 for 1st place.
- **Do it only** as a quick portfolio piece after Nebius and Qloo (Oct 30), or skip it.
