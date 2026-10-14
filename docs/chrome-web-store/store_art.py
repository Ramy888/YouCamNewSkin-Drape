"""Chrome Web Store art: the 128x128 store icon (96x96 artwork, 16 px transparent padding, per the image guidelines)
and the 1400x560 marquee tile (RGB, no alpha).
Usage (repo root, Pillow): python3 docs/chrome-web-store/store_art.py
"""
import os
from PIL import Image, ImageDraw, ImageFilter, ImageFont

D = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets")
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PLUM, PAPER, INK = (94, 39, 80), (248, 245, 240), (30, 27, 34)
def font(size, bold=False):
    f = "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf"
    return ImageFont.truetype(f, size) if os.path.exists(f) else ImageFont.load_default()

icon_src = Image.open(os.path.join(ROOT, "extension", "icons", "icon128.png")).convert("RGBA")

store_icon = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
store_icon.paste(icon_src.resize((96, 96), Image.LANCZOS), (16, 16))
store_icon.save(os.path.join(D, "store_icon_128.png")); print("wrote store_icon_128.png")

W, H = 1400, 560
tile = Image.new("RGB", (W, H), PLUM)
d = ImageDraw.Draw(tile)
d.rounded_rectangle((84, 104, 216, 236), 30, fill=(122, 74, 110))
tile.paste(icon_src.resize((120, 120), Image.LANCZOS), (90, 110), icon_src.resize((120, 120), Image.LANCZOS))
d.text((236, 170), "Drape", font=font(96, True), fill="white", anchor="lm")
d.text((92, 300), "Which colour is yours?", font=font(46, True), fill="white")
d.text((92, 368), "See the colour that suits you beside the one", font=font(26), fill=(243, 232, 239))
d.text((92, 404), "that fights you, on your own body.", font=font(26), fill=(243, 232, 239))
d.text((92, 470), "Powered by YouCam API", font=font(22, True), fill=(214, 190, 207))

def card(name, label, bg, fg, x):
    cw, ch = 280, 420
    photo = Image.open(os.path.join(ROOT, "backend", "public", "persona", name)).convert("RGB")
    photo = photo.resize((cw, int(photo.height * cw / photo.width)), Image.LANCZOS).crop((0, 0, cw, ch))
    y = 50
    shadow = Image.new("RGBA", (cw + 60, ch + 60), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle((30, 30, cw + 30, ch + 30), 18, fill=(0, 0, 0, 120))
    shadow = shadow.filter(ImageFilter.GaussianBlur(14))
    tile.paste(shadow, (x - 30, y - 22), shadow)
    mask = Image.new("L", (cw, ch), 0); ImageDraw.Draw(mask).rounded_rectangle((0, 0, cw - 1, ch - 1), 18, fill=255)
    tile.paste(photo, (x, y), mask)
    f = font(22, True); tw = d.textlength(label, font=f)
    px, py = x + (cw - tw - 36) / 2, y + ch + 16
    d.rounded_rectangle((px, py, px + tw + 36, py + 40), 20, fill=bg)
    d.text((px + 18, py + 20), label, font=f, fill=fg, anchor="lm")

card("tryon_abaya-classic_emerald.jpg", "Lifts your colouring", (228, 241, 233), (29, 107, 70), 760)
card("tryon_abaya-classic_lavender.jpg", "Fights your colouring", (248, 230, 226), (160, 55, 42), 1070)
tile.save(os.path.join(D, "marquee_1400x560.png")); print("wrote marquee_1400x560.png")
