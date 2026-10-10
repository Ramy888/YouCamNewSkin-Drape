# Arabic review brief

Sheet: `arabic-review.csv` (103 strings, opens in Excel or Google Sheets). Fill **Suggested Arabic** only where you would change
something, and add a **Comment** if it needs explaining. Leave rows you agree with empty.

To see the text in context, open https://drape.ramy-comm.workers.dev/app/ and switch to العربية (top right), then click
"Try with the sample person".

## Two decisions for the reviewer

1. **One dialect.** The text currently mixes Modern Standard Arabic ( "حدث خطأ ما") with Egyptian colloquial
   ( "شوفيها"). Pick one voice for the whole app: Egyptian colloquial (warmer, matches the narration) or light MSA
   (reads naturally across the Gulf). Mark the rows that don't fit.
2. **Colour names stay in English** in the Arabic screens (Emerald, Lavender, Brick coral) because they come from the store's
   catalogue and the palette data. Say whether they should be translated.

## Rules the copy must keep

- The buyer is addressed in the feminine (the audience is women shopping modest fashion).
- Judge the garment, never the skin: "يبرز ألوانك" (lifts your colouring), never anything about skin being dark, light or fair.
- Every "no" comes with a better "yes".
- Keep it short: most strings sit on buttons or small labels.

## After the review

Send the filled sheet back. The strings live in `app/lib/l10n.dart`; `python3 docs/submission/export_arabic.py` regenerates the sheet
after changes.
