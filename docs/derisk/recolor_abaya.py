"""Make the 'Everyday satin abaya' colourways from the CC0 abaya shot (local, zero units).

Usage (repo root): python3 docs/derisk/recolor_abaya.py
Selects the green garment pixels of backend/public/catalog/abaya-classic_emerald.jpg (the gold piping and white background
are not green, so they stay), then repaints them in each target colour while keeping the fabric's folds and shading.
"""
import colorsys, os
import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CAT = os.path.join(ROOT, "backend", "public", "catalog")
TARGETS = {"navy": "#1f2f5a", "icy-pink": "#f2c8d8", "cool-grey": "#9aa3ad"}

img = np.asarray(Image.open(os.path.join(CAT, "abaya-classic_emerald.jpg")).convert("RGB")).astype(np.float32) / 255.0
r, g, b = img[..., 0], img[..., 1], img[..., 2]
lum = 0.299 * r + 0.587 * g + 0.114 * b
mask = (g > r + 0.04) & (g > b - 0.02) & (lum < 0.85)  # green fabric only
shade = lum / np.percentile(lum[mask], 95)
for name, hx in TARGETS.items():
    col = np.array([int(hx[i:i + 2], 16) / 255 for i in (1, 3, 5)])
    h, l, s = colorsys.rgb_to_hls(*col)
    out = img.copy()
    # Light targets keep folds by blending toward the colour; dark targets scale it by the shading.
    rec = col[None, None, :] * np.clip(shade, 0.25, 1.15)[..., None] if l < 0.5 else \
        col[None, None, :] * (0.55 + 0.45 * np.clip(shade, 0, 1.1))[..., None]
    out[mask] = np.clip(rec, 0, 1)[mask]
    Image.fromarray((out * 255).astype(np.uint8)).save(os.path.join(CAT, f"abaya-everyday_{name}.jpg"), quality=92)
    print("wrote", f"abaya-everyday_{name}.jpg", int(mask.sum()), "px")
