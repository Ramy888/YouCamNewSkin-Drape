# Design system

Two identities on purpose. **Drape** is the product (buyer app and seller console). **Noor Modest** is a made-up store that
embeds Drape. They must never look like the same brand: the only Drape element on the store page is the "Try on with Drape" button.

## Drape: "atelier"

A tailor's fitting room: warm ivory paper, near-black ink, aubergine for action, brass for metal. Quiet, precise, generous space.

| Token | Hex | Use | Contrast on paper |
|---|---|---|---|
| `paper` | `#F8F5F0` | app ground | |
| `surface` | `#FFFFFF` | cards | |
| `paperDeep` | `#EFE9E1` | sunk areas, image wells | |
| `line` | `#E3DBD0` | borders, dividers | |
| `ink` | `#1E1B22` | text | 15.6:1 |
| `inkSoft` | `#5A5560` | secondary text | 6.7:1 |
| `mulberry` | `#5E2750` | primary action, brand | 10.3:1 |
| `mulberrySoft` | `#F3E8EF` | selected, brand tint | |
| `brass` | `#7E6026` | metal, sample badge | 5.4:1 |
| `yours` / `yoursSoft` | `#1D6B46` / `#E4F1E9` | "suits you" verdict | 6.0:1 |
| `avoid` / `avoidSoft` | `#A0372A` / `#F8E6E2` | "fights your colouring" verdict | 6.3:1 |

- **Type:** Reem Kufi for display (covers Arabic and Latin), IBM Plex Sans Arabic for everything else. Display 40/34, headline 26,
  title 18, body 17/16, label 13 with tracking. Body text never below 16px.
- **Spacing:** 4, 8, 12, 16, 24, 32, 48. Page gutter 20 (16 on phones).
- **Shape:** cards 16px radius with a 1px `line` border and a soft two-layer shadow; buttons 12px radius, 52px tall; verdicts and
  swatches are pills.
- **Pattern:** every buyer screen opens with an eyebrow ("Step 2 of 4") plus a headline; a 4-segment progress bar sits under the app bar.
- **Verdicts** are always words plus an icon on a tinted pill; colour is the second cue, never the only one.
- **Seller console:** same tokens, denser: an ink top bar, KPI tiles for the unit ledger, a master-detail product editor in cards.

## Noor Modest: the demo store

A boutique look that is clearly someone else's shop: white and navy with coral, a high-contrast serif, square corners, uppercase buttons.

| Token | Hex |
|---|---|
| ground | `#FFFFFF` |
| navy (header, primary button) | `#13233F` |
| coral (accent) | `#B6452F` |
| blush (panels) | `#FBEFEA` |

- **Type:** Playfair Display (display) and Jost (body).
- **Demo label:** a sticky yellow-and-black ribbon at the very top on every screen size, plus a "Demo" tag in the cart. Nothing on the
  page can be mistaken for a real shop.
- **Drape button:** keeps Drape's aubergine and mark, so the embed reads as a guest on the page.

## Rules that carry over from the spec

44px minimum targets, visible focus rings, 4.5:1 text contrast, RTL mirroring (the approved render on the reading-start side), copy
judges the garment and never the skin.
