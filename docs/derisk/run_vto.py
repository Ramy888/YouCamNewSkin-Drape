"""De-risk test: Clothes VTO v4 on locally recoloured garments. Reads the key from the project .env; never prints it."""
import json
import os
import sys
import time

import requests

ENV, SRC, REFDIR, OUT = sys.argv[1:5]
COLOURS = sys.argv[5].split(",")
env = dict(l.split("=", 1) for l in open(ENV).read().splitlines() if "=" in l and not l.lstrip().startswith("#"))
KEY = env["YOUCAM_API_KEY"].strip()
BASE = env.get("YOUCAM_API_BASE", "https://yce-api-01.makeupar.com/s2s/v2.0").strip()
H = {"Authorization": f"Bearer {KEY}", "Content-Type": "application/json"}


def scrub(o):
    return json.dumps(o)[:600].replace(KEY, "***")


def upload(path):
    size = os.path.getsize(path)
    ctype = "image/jpeg" if path.lower().endswith((".jpg", ".jpeg")) else "image/png"
    r = requests.post(f"{BASE}/file/cloth-v4", headers=H, timeout=60,
                      json={"files": [{"content_type": ctype, "file_name": os.path.basename(path), "file_size": size}]})
    if r.status_code == 404:  # fall back to the generic upload endpoint
        r = requests.post(f"{BASE}/file", headers=H, timeout=60,
                          json={"files": [{"content_type": ctype, "file_name": os.path.basename(path), "file_size": size}]})
    j = r.json()
    if r.status_code != 200:
        sys.exit(f"upload init failed {r.status_code}: {scrub(j)}")
    f = j["data"]["files"][0]
    req = f["requests"][0]
    with open(path, "rb") as fh:
        u = requests.request(req.get("method", "PUT"), req["url"], headers=req.get("headers", {}), data=fh.read(), timeout=120)
    if u.status_code not in (200, 201, 204):
        sys.exit(f"binary upload failed {u.status_code}: {u.text[:300]}")
    return f["file_id"]


src_id = upload(SRC)
print("src uploaded")
for c in COLOURS:
    ref_id = upload(f"{REFDIR}/ref_{c}.jpg")
    r = requests.post(f"{BASE}/task/cloth-v4", headers=H, timeout=60,
                      json={"src_file_id": src_id, "ref_file_id": ref_id, "garment_category": "upper_body"})
    j = r.json()
    if r.status_code != 200:
        print(c, "task create failed", r.status_code, scrub(j)); continue
    tid = j["data"]["task_id"]
    for i in range(60):
        time.sleep(3 if i < 10 else 6)
        p = requests.get(f"{BASE}/task/cloth-v4/{tid}", headers=H, timeout=60).json()
        st = p.get("data", {}).get("task_status")
        if st in ("success", "error"):
            break
    if st != "success":
        print(c, "status", st, scrub(p)); continue
    res = p["data"]["results"]
    url = res["url"] if isinstance(res, dict) else (res[0]["url"] if isinstance(res, list) else None)
    img = requests.get(url, timeout=120)
    open(f"{OUT}/out_{c}.jpg", "wb").write(img.content)
    print(c, "success ->", f"out_{c}.jpg", len(img.content), "bytes")
