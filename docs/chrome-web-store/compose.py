"""Compose Chrome Web Store images from the raw screenshots: four 1280x800 screenshots with captions and a 440x280 tile.
Usage (repo root, Pillow): python3 docs/chrome-web-store/compose.py
"""
import os
from PIL import Image, ImageDraw, ImageFilter, ImageFont

D = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets")
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PLUM, PAPER, INK = (94, 39, 80), (248, 245, 240), (30, 27, 34)
def font(size, bold=False):
    for f in ["/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf", "/System/Library/Fonts/Helvetica.ttc"]:
        if os.path.exists(f): return ImageFont.truetype(f, size)
    return ImageFont.load_default()

def captioned(raw, caption, out, overlay=None):
    W, H, bar = 1280, 800, 88
    canvas = Image.new("RGB", (W, H), PLUM)
    d = ImageDraw.Draw(canvas)
    d.text((40, bar // 2), caption, font=font(34, True), fill="white", anchor="lm")
    shot = Image.open(os.path.join(D, raw)).convert("RGB").resize((int(1280 * (H - bar) / 800), H - bar))
    canvas.paste(shot, ((W - shot.width) // 2, bar))
    if overlay:
        pop = Image.open(os.path.join(D, overlay)).convert("RGB").crop((0, 0, 320, 295))
        x, y = W - pop.width - 48, bar + 24
        shadow = Image.new("RGBA", (pop.width + 40, pop.height + 40), (0, 0, 0, 0))
        ImageDraw.Draw(shadow).rounded_rectangle((20, 20, pop.width + 20, pop.height + 20), 12, fill=(0, 0, 0, 110))
        canvas.paste(shadow.filter(ImageFilter.GaussianBlur(12)), (x - 20, y - 14), shadow.filter(ImageFilter.GaussianBlur(12)))
        canvas.paste(pop, (x, y))
        ImageDraw.Draw(canvas).rectangle((x, y, x + pop.width - 1, y + pop.height - 1), outline=(227, 219, 208))
    canvas.save(os.path.join(D, out))
    print("wrote", out)

captioned("raw_store.png", "On a shop's product page, one click: is it on Drape?", "screenshot_1_extension.png", overlay="raw_popup.png")
captioned("raw_colours.png", "One face photo reads the colours that suit you", "screenshot_2_colours.png")
captioned("raw_compare.png", "See the colour that fights you beside the one that lifts you", "screenshot_3_compare.png")
captioned("raw_catalogue.png", "Browse stores, try on, and buy at the store that sells it", "screenshot_4_catalogue.png")

tile = Image.new("RGB", (440, 280), PLUM)
icon = Image.open(os.path.join(ROOT, "extension", "icons", "icon128.png")).convert("RGBA").resize((96, 96))
white = Image.new("RGBA", (104, 104), (255, 255, 255, 0)); ImageDraw.Draw(white).rounded_rectangle((0, 0, 103, 103), 24, fill=(255, 255, 255, 40))
tile.paste(white, (32, 88), white); tile.paste(icon, (36, 92), icon)
d = ImageDraw.Draw(tile)
d.text((156, 112), "Drape", font=font(48, True), fill="white")
d.text((158, 170), "See the colour that suits you,", font=font(18), fill=(243, 232, 239))
d.text((158, 194), "on your own body.", font=font(18), fill=(243, 232, 239))
tile.save(os.path.join(D, "promo_small_440x280.png")); print("wrote promo_small_440x280.png")
