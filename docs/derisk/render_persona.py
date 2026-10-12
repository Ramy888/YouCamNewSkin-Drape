"""Render the judge persona's replay fixtures. SPENDS UNITS: run only after Ramy approves the exact run.

Usage (from the repo root):
  python3 docs/derisk/render_persona.py .env tryon:abaya-classic:lavender makeup
Each `tryon:<productId>:<colorwayId>` costs 2 units (cloth-v4 full_body on backend/public/persona/body.jpg with
backend/public/catalog/<productId>_<colorwayId>.jpg). `makeup` costs 1 unit (lip from the persona's palette on face.jpg).
`earring:<gold|silver|rose-gold>` costs 1 unit (2D earring VTO on face.jpg).
`fabric:<persona image name>:<template_id>` costs 2 units (AI Fabric on an existing persona render, e.g. tryon_abaya-classic_black).
`colortones` costs 20 units (Facial Color Tones on face.jpg; saved as color_tones.json, the persona's reading).
PERSONA_DIR=<folder under backend/public> reads face.jpg/body.jpg from and writes results to that folder (default: persona),
so a new persona can be rendered into a staging folder and swapped in at once.
Results go to backend/public/persona/ as images; raw responses are saved with remote URLs replaced by the local file name.
"""
import json, os, re, sys, time

import requests

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PUB = os.path.join(ROOT, "backend", "public")
PDIR = os.path.join(PUB, os.environ.get("PERSONA_DIR", "persona"))
ENV, jobs = sys.argv[1], sys.argv[2:]
env = dict(l.split("=", 1) for l in open(ENV).read().splitlines() if "=" in l and not l.lstrip().startswith("#"))
KEY = env["YOUCAM_API_KEY"].strip()
BASE = env.get("YOUCAM_API_BASE", "https://yce-api-01.makeupar.com/s2s/v2.0").strip()
H = {"Authorization": f"Bearer {KEY}", "Content-Type": "application/json"}
scrub = lambda o: json.dumps(o)[:600].replace(KEY, "***")
CATEGORY = {"abaya-classic": "full_body", "kaftan-coat": "outer"}
WARM_LIP = "#b5523b"  # persona reads warm; must match backend/src/palette-rules.json palettes.warm.lip


def upload(path, task):
    body = {"files": [{"content_type": "image/jpeg", "file_name": os.path.basename(path), "file_size": os.path.getsize(path)}]}
    r = requests.post(f"{BASE}/file/{task}", headers=H, json=body, timeout=60)
    if r.status_code == 404:
        r = requests.post(f"{BASE}/file", headers=H, json=body, timeout=60)
    j = r.json()
    if r.status_code != 200:
        raise SystemExit(f"upload init {r.status_code}: {scrub(j)}")
    f = j["data"]["files"][0]
    q = f["requests"][0]
    u = requests.request(q.get("method", "PUT"), q["url"], headers=q.get("headers", {}), data=open(path, "rb").read(), timeout=120)
    if u.status_code not in (200, 201, 204):
        raise SystemExit(f"put {u.status_code}")
    return f["file_id"]


def run(task, name, payload, save_image=True):
    r = requests.post(f"{BASE}/task/{task}", headers=H, json=payload, timeout=60)
    j = r.json()
    if r.status_code != 200:
        print(name, "CREATE FAILED", r.status_code, scrub(j))
        return
    tid = j["data"]["task_id"]
    for i in range(80):
        time.sleep(3 if i < 10 else 6)
        p = requests.get(f"{BASE}/task/{task}/{tid}", headers=H, timeout=60).json()
        st = p.get("data", {}).get("task_status")
        if st in ("success", "error"):
            break
    if st != "success":
        print(name, "STATUS", st, scrub(p))
        return
    if not save_image:
        open(os.path.join(PDIR, f"{name}.json"), "w").write(json.dumps(p, indent=1))
        print(name, "success ->", json.dumps(p["data"].get("results")))
        return
    res = p["data"].get("results")
    url = res.get("url") if isinstance(res, dict) else (res[0].get("url") if isinstance(res, list) and res else None)
    out = os.path.join(PDIR, f"{name}.jpg")
    open(out, "wb").write(requests.get(url, timeout=120).content)
    clean = re.sub(r'"https?://[^"]+"', json.dumps(f"{name}.jpg"), json.dumps(p))
    open(os.path.join(PDIR, f"{name}.json"), "w").write(json.dumps(json.loads(clean), indent=1))
    print(name, "success ->", out)


for job in jobs:
    if job.startswith("tryon:"):
        _, pid, cid = job.split(":")
        body = upload(os.path.join(PDIR, "body.jpg"), "cloth-v4")
        ref = upload(os.path.join(PUB, "catalog", f"{pid}_{cid}.jpg"), "cloth-v4")
        run("cloth-v4", f"tryon_{pid}_{cid}", {"src_file_id": body, "ref_file_id": ref, "garment_category": CATEGORY.get(pid, "full_body")})
    elif job == "makeup":
        face = upload(os.path.join(PDIR, "face.jpg"), "makeup-vto")
        run("makeup-vto", "makeup", {"src_file_id": face, "version": "1.0", "effects": [
            {"category": "lip_color", "shape": {"name": "original"}, "style": {"type": "full"},
             "palettes": [{"color": WARM_LIP, "texture": "matte", "colorIntensity": 70}]}]})
    elif job == "colortones":
        face = upload(os.path.join(PDIR, "face.jpg"), "skin-tone-analysis")
        run("skin-tone-analysis", "color_tones", {"src_file_id": face}, save_image=False)
    elif job.startswith("earring:"):
        metal = job.split(":")[1]
        face = upload(os.path.join(PDIR, "face.jpg"), "2d-vto/earring")
        ref = upload(os.path.join(PUB, "catalog", "jewelry", f"earring_{metal}.jpg"), "2d-vto/earring")
        run("2d-vto/earring", f"earring_{metal}", {"src_file_id": face, "ref_file_ids": [ref], "source_info": {"name": face},
            "object_infos": [{"name": ref, "parameter": {"earring_need_remove_background": True, "earring_occluded_type": 0}}]})
    elif job.startswith("fabric:"):
        _, src, template = job.split(":")
        body = upload(os.path.join(PDIR, f"{src}.jpg"), "fabric")
        run("fabric", f"fabric_{src}_{template}", {"src_file_id": body, "template_id": template})
    else:
        raise SystemExit(f"unknown job {job}")
