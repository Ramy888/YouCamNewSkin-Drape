"""Recolour the beige tee in the YouCam sample image into target colourways (local, zero units)."""
import sys
import numpy as np
from PIL import Image

src, outdir = sys.argv[1], sys.argv[2]
img = np.asarray(Image.open(src).convert("RGB")).astype(np.float32) / 255.0
r, g, b = img[..., 0], img[..., 1], img[..., 2]
mx, mn = img.max(-1), img.min(-1)
lum = 0.299 * r + 0.587 * g + 0.114 * b
sat = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1e-6), 0)

h, w = lum.shape
yy, xx = np.mgrid[0:h, 0:w]
from PIL import ImageDraw
POLY = [(470,245),(490,252),(530,255),(565,240),(578,228),(605,240),(635,268),(648,300),(640,330),(615,335),(612,380),
        (615,470),(560,482),(490,488),(432,480),(432,400),(428,340),(395,320),(390,295),(410,255),(445,240)]
pm = Image.new("L", (w, h), 0); ImageDraw.Draw(pm).polygon(POLY, fill=255)
box = np.asarray(pm) > 0  # hand-traced tee outline
hair = (lum < 0.32) & ((r - b) < 0.14)
tee = box & ~hair
print("tee pixels:", int(tee.sum()))

TARGETS = {"emerald": (0.02, 0.45, 0.30), "cobalt": (0.08, 0.22, 0.62), "mustard": (0.80, 0.62, 0.10)}
shade = lum / np.percentile(lum[tee], 92)  # keep the folds and shading of the fabric
for name, col in TARGETS.items():
    out = img.copy()
    rec = np.clip(np.array(col)[None, None, :] * np.clip(shade, 0, 1.2)[..., None], 0, 1)
    out[tee] = rec[tee]
    Image.fromarray((out * 255).astype(np.uint8)).save(f"{outdir}/ref_{name}.jpg", quality=95)
Image.fromarray((tee * 255).astype(np.uint8)).save(f"{outdir}/mask.png")
