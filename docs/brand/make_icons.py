"""Draw the Drape mark (the same geometry as BrandMark/_FoldPainter in app/lib/widgets/common.dart) into every icon file.

Usage (from the repo root, needs Pillow):  python3 docs/brand/make_icons.py
Writes the Flutter web favicon and PWA icons, plus the Chrome extension icons.
"""
import os

from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MULBERRY = (0x5E, 0x27, 0x50, 255)
WHITE = (255, 255, 255, 255)
SS = 8  # supersampling factor for smooth curves


def bezier(p0, p1, p2, p3=None, n=600):
    pts = []
    for i in range(n + 1):
        t = i / n
        if p3 is None:  # quadratic
            x = (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0]
            y = (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1]
        else:
            x = (1 - t) ** 3 * p0[0] + 3 * (1 - t) ** 2 * t * p1[0] + 3 * (1 - t) * t * t * p2[0] + t ** 3 * p3[0]
            y = (1 - t) ** 3 * p0[1] + 3 * (1 - t) ** 2 * t * p1[1] + 3 * (1 - t) * t * t * p2[1] + t ** 3 * p3[1]
        pts.append((x, y))
    return pts


def stroke(d, pts, w, color):
    # Round dabs along the curve: smooth width and round caps at any size (PIL's wide lines leave gaps at joints).
    r = w / 2
    for x, y in pts:
        d.ellipse([x - r, y - r, x + r, y + r], fill=color)


def mark(size, tile=True, inset=0.0):
    """tile=True: rounded aubergine tile (favicon, app icon). tile=False: full-bleed square (maskable)."""
    S = size * SS
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if tile:
        d.rounded_rectangle([0, 0, S - 1, S - 1], radius=S * 8 / 30, fill=MULBERRY)
    else:
        d.rectangle([0, 0, S, S], fill=MULBERRY)
    # The mark lives in a box shrunk by `inset` on each side (maskable icons keep it inside the safe zone).
    o, k = S * inset, S * (1 - 2 * inset)
    P = lambda x, y: (o + x * k, o + y * k)
    w = max(k * 0.08, SS * 1.6)
    hood = bezier(P(0.28, 0.80), P(0.22, 0.45), P(0.30, 0.20), P(0.50, 0.20)) + bezier(P(0.50, 0.20), P(0.70, 0.20), P(0.78, 0.45), P(0.72, 0.80))
    stroke(d, hood, w, WHITE)
    stroke(d, bezier(P(0.42, 0.80), P(0.40, 0.52), P(0.50, 0.40)), w, WHITE)
    return img.resize((size, size), Image.LANCZOS)


def save(img, *parts):
    path = os.path.join(ROOT, *parts)
    img.save(path)
    print("wrote", os.path.relpath(path, ROOT))


save(mark(32), "app", "web", "favicon.png")
save(mark(192), "app", "web", "icons", "Icon-192.png")
save(mark(512), "app", "web", "icons", "Icon-512.png")
save(mark(192, tile=False, inset=0.12), "app", "web", "icons", "Icon-maskable-192.png")
save(mark(512, tile=False, inset=0.12), "app", "web", "icons", "Icon-maskable-512.png")
for n in (16, 32, 48, 128):
    save(mark(n), "extension", "icons", f"icon{n}.png")
