"""Gate test: 3 cloth-v4 calls + 1 makeup-vto on the same buyer. Reads the key from .env; never prints it."""
import json, os, sys, time
import requests
ENV, G = sys.argv[1:3]
env = dict(l.split("=", 1) for l in open(ENV).read().splitlines() if "=" in l and not l.lstrip().startswith("#"))
KEY = env["YOUCAM_API_KEY"].strip(); BASE = env.get("YOUCAM_API_BASE", "https://yce-api-01.makeupar.com/s2s/v2.0").strip()
H = {"Authorization": f"Bearer {KEY}", "Content-Type": "application/json"}
scrub = lambda o: json.dumps(o)[:500].replace(KEY, "***")
def upload(path, api):
    body = {"files": [{"content_type": "image/jpeg", "file_name": os.path.basename(path), "file_size": os.path.getsize(path)}]}
    r = requests.post(f"{BASE}/file/{api}", headers=H, json=body, timeout=60)
    if r.status_code == 404: r = requests.post(f"{BASE}/file", headers=H, json=body, timeout=60)
    j = r.json()
    if r.status_code != 200: raise SystemExit(f"upload init {r.status_code}: {scrub(j)}")
    f = j["data"]["files"][0]; q = f["requests"][0]
    u = requests.request(q.get("method", "PUT"), q["url"], headers=q.get("headers", {}), data=open(path, "rb").read(), timeout=120)
    if u.status_code not in (200, 201, 204): raise SystemExit(f"put {u.status_code}")
    return f["file_id"]
def run(api, name, payload):
    r = requests.post(f"{BASE}/task/{api}", headers=H, json=payload, timeout=60); j = r.json()
    if r.status_code != 200: print(name, "CREATE FAILED", r.status_code, scrub(j)); return
    tid = j["data"]["task_id"]; t0 = time.time()
    for i in range(80):
        time.sleep(3 if i < 10 else 6)
        p = requests.get(f"{BASE}/task/{api}/{tid}", headers=H, timeout=60).json(); st = p.get("data", {}).get("task_status")
        if st in ("success", "error"): break
    if st != "success": print(name, "STATUS", st, scrub(p)); return
    res = p["data"]["results"]; url = res["url"] if isinstance(res, dict) else res[0]["url"]
    open(f"{G}/out/{name}.jpg", "wb").write(requests.get(url, timeout=120).content)
    print(name, "success", f"{time.time()-t0:.0f}s")
buyer = upload(f"{G}/in/buyer.jpg", "cloth-v4")
for name, ref, cat in [("a_flatlay", "a_flatlay", "upper_body"), ("b_onmodel", "b_onmodel", "outer"),
                       ("c_gray", "c_gray", "upper_body"), ("d_navy", "d_navy", "upper_body")]:
    run("cloth-v4", name, {"src_file_id": buyer, "ref_file_id": upload(f"{G}/in/{ref}.jpg", "cloth-v4"), "garment_category": cat})
selfie = upload(f"{G}/in/selfie.jpg", "makeup-vto")
run("makeup-vto", "e_makeup", {"src_file_id": selfie, "version": "1.0", "effects": [
    {"category": "lip_color", "shape": {"name": "original"}, "style": {"type": "full"},
     "palettes": [{"color": "#b5485d", "texture": "matte", "colorIntensity": 70}]}]})
